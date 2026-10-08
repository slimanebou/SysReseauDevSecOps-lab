# SSH sécurisé & fail2ban

> **Phase 1 — Administration Linux & Système**
> Statut : ✅ Terminé

---

## Objectif

Maîtriser le protocole SSH, générer des clés ED25519, sécuriser le démon `sshd`, configurer des alias de connexion et déployer `fail2ban` pour bloquer automatiquement les attaquants.

---

## Sommaire

- [1. Le protocole SSH](#1-le-protocole-ssh)
- [2. Générer une paire de clés ED25519](#2-générer-une-paire-de-clés-ed25519)
- [3. Déployer la clé sur le serveur](#3-déployer-la-clé-sur-le-serveur)
- [4. Alias de connexion — ~/.ssh/config](#4-alias-de-connexion--sshconfig)
- [5. Sécuriser sshd_config](#5-sécuriser-sshd_config)
- [6. fail2ban](#6-fail2ban)
- [7. Documentation de sécurité](#7-documentation-de-sécurité)
- [Commandes clés apprises](#commandes-clés-apprises)
- [Difficultés rencontrées & solutions](#difficultés-rencontrées--solutions)

---

## 1. Le protocole SSH

SSH (**Secure Shell**) permet d'administrer une machine distante de façon chiffrée.

**Composants :**

| Élément | Rôle |
|---|---|
| `ssh` | Client de connexion (sortant) |
| `sshd` | Démon serveur (écoute les connexions entrantes) |
| `ssh-keygen` | Génération de paires de clés |
| `ssh-copy-id` | Déploiement de la clé publique sur un serveur |
| `ssh-agent` | Gestionnaire de clés (évite de retaper la passphrase) |

**Principe de l'échange de clés :** l'échange de clés **Diffie-Hellman** permet de négocier une clé de session chiffrée sur un canal non sécurisé. L'authentification se fait ensuite par **clé publique/privée** (ou mot de passe).

```text
┌──────────┐                ┌──────────┐
│  Client  │  Diffie-Hellman │ Serveur  │
│ (ssh)    │◄──────────────►│ (sshd)   │
│ Clé privée│  Clé publique  │ Clé publique
└──────────┘                └──────────┘
```

---

## 2. Générer une paire de clés ED25519

**ED25519** est plus rapide et plus sécurisé que RSA 2048.

```bash
ssh-keygen -t ed25519 -C "slimane@lab-vm"
```

| Option | Rôle |
|---|---|
| `-t ed25519` | Type de clé (moderne, compacte, recommandée) |
| `-C "commentaire"` | Étiquette pour identifier la clé (visible dans authorized_keys) |
| `-f ~/.ssh/id_custom` | Chemin personnalisé pour la clé |
| `-N "passphrase"` | Définir la passphrase |

### Permissions des fichiers générés

| Fichier | Permissions | Rôle |
|---|---|---|
| `~/.ssh/` | `700` (`drwx------`) | Dossier réservé au propriétaire |
| `id_ed25519` (clé privée) | `600` (`-rw-------`) | **À protéger absolument** — jamais partagée |
| `id_ed25519.pub` (clé publique) | `644` (`-rw-r--r--`) | Diffusée librement sur les serveurs |

> **⚠️ Important :** OpenSSH **refuse** d'utiliser une clé privée dont les permissions sont trop ouvertes (`chmod 600` obligatoire).

---

## 3. Déployer la clé sur le serveur

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub devops@192.168.10.10
```

**Ce que fait `ssh-copy-id` :**

1. Se connecte au serveur (avec le mot de passe, une dernière fois)
2. Ajoute la clé publique à `~/.ssh/authorized_keys` sur le serveur
3. Ajuste les permissions si nécessaire

> **💡 Alternative manuelle :** `cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys` (sur le serveur).

---

## 4. Alias de connexion — ~/.ssh/config

Configuration locale dans `~/.ssh/config` (permissions `600`) :

```plaintext
Host lab
    HostName 192.168.10.10
    User devops
    Port 2222
    IdentityFile ~/.ssh/id_ed25519

Host lab-interne
    HostName 192.168.30.10
    User devops
    ProxyJump lab
    IdentityFile ~/.ssh/id_ed25519
```

| Directive | Rôle |
|---|---|
| `Host` | Nom d'alias (ce qu'on tape après `ssh`) |
| `HostName` | Adresse IP ou nom DNS réel du serveur |
| `User` | Nom d'utilisateur de connexion |
| `Port` | Port SSH (non standard ici : 2222) |
| `IdentityFile` | Clé privée à utiliser |
| `ProxyJump` | Saut via un serveur intermédiaire (bastion) |

**Connexion simplifiée :**

```bash
ssh lab          # Équivaut à : ssh -p 2222 -i ~/.ssh/id_ed25519 devops@192.168.10.10
ssh lab-interne  # Passe par le bastion "lab" pour atteindre la machine interne
```

> **✅ Bonne pratique :** `chmod 600 ~/.ssh/config` — SSH refuse un fichier de config lisible par tous.

---

## 5. Sécuriser sshd_config

Éditer `/etc/ssh/sshd_config` :

```plaintext
Port 2222
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
AllowUsers devops
MaxAuthTries 3
ClientAliveInterval 300
```

| Directive | Valeur | Rôle |
|---|---|---|
| `Port` | `2222` | Changer le port par défaut (22) — réduit le bruit des scans automatiques |
| `PermitRootLogin` | `no` | Interdit la connexion directe en root |
| `PubkeyAuthentication` | `yes` | Autorise l'authentification par clé |
| `PasswordAuthentication` | `no` | **Désactive totalement le mot de passe** (anti brute-force) |
| `AllowUsers` | `devops` | Liste blanche : seuls ces utilisateurs peuvent se connecter |
| `MaxAuthTries` | `3` | Nombre d'échecs d'authentification avant coupure |
| `ClientAliveInterval` | `300` | Envoie un keepalive toutes les 300 s (garde la session active) |

**Validation et application :**

```bash
sudo sshd -t                          # Tester la syntaxe de la configuration
sudo systemctl restart ssh            # Redémarrer SSH
```

> **🔑 Règle d'or :** conserver la session SSH courante **ouverte** pendant les tests de configuration dans un **second terminal**. En cas d'erreur, la session existante reste active pour revenir en arrière.

**Ordre de sécurisation recommandé :**

1. Générer la clé et la déployer (`ssh-copy-id`)
2. **Vérifier** que la connexion par clé fonctionne dans un second terminal
3. Seulement ensuite désactiver `PasswordAuthentication`
4. Redémarrer sshd et tester

---

## 6. fail2ban

`fail2ban` lit `/var/log/auth.log` et ajoute des règles **iptables/nftables** pour bloquer les adresses IP suspectes.

### Principe de fonctionnement

```text
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  auth.log   │────►│ fail2ban     │────►│ iptables    │
│ (échecs SSH)│     │ (détecte +   │     │ (bannit     │
│             │     │  compte)     │     │  l'IP)      │
└─────────────┘     └──────────────┘     └─────────────┘
```

### Configuration (`/etc/fail2ban/jail.local`)

```ini
[DEFAULT]
bantime  = 3600
findtime = 600
maxretry = 3
ignoreip = 127.0.0.1/8 192.168.10.0/24

[sshd]
enabled  = true
port     = 2222
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 3
bantime  = 3600
```

| Directive | Valeur | Rôle |
|---|---|---|
| `bantime` | `3600` | Durée du bannissement en secondes (ici : 1 heure) |
| `findtime` | `600` | Fenêtre de détection en secondes (ici : 10 minutes) |
| `maxretry` | `3` | Nombre d'échecs tolérés avant bannissement |
| `ignoreip` | `127.0.0.1/8 192.168.10.0/24` | IP/réseaux **jamais bannis** (localhost + LAN) |
| `filter` | `sshd` | Filtre de détection des échecs (regex) |
| `logpath` | `/var/log/auth.log` | Fichier de logs à surveiller |

> **💡 Logique :** si une IP échoue **3 fois** (`maxretry`) en moins de **10 minutes** (`findtime`), elle est **bannie pendant 1 heure** (`bantime`).

### Administration

```bash
sudo systemctl restart fail2ban
sudo fail2ban-client status sshd                      # Voir les adresses IP bannies
sudo fail2ban-client set sshd unbanip 192.168.10.5    # Débannir une IP
```

| Commande | Rôle |
|---|---|
| `fail2ban-client status` | État global de fail2ban |
| `fail2ban-client status sshd` | Statistiques de la jail sshd (IP bannies) |
| `fail2ban-client set sshd banip <IP>` | Bannir manuellement une IP |
| `fail2ban-client set sshd unbanip <IP>` | Débannir une IP |

---

## 7. Documentation de sécurité

Un fichier résumé des paramètres appliqués est maintenu pour audit.

| Paramètre | Valeur appliquée |
|---|---|
| Clé SSH | ED25519 avec passphrase |
| Port SSH | 2222 |
| Root Login | Interdit (`no`) |
| Password Auth | Désactivé (`no`) |
| Fail2ban | Actif (Ban 1h après 3 échecs) |

---

## Commandes clés apprises

```bash
ssh-keygen -t ed25519; ssh-copy-id; sshd -t; fail2ban-client status sshd; fail2ban-client set sshd unbanip
```

---

## Difficultés rencontrées & solutions

| Difficulté rencontrée | Solution appliquée |
|----------------------|--------------------|
| Refus de connexion SSH par clé | Corriger les permissions : `chmod 600 ~/.ssh/id_ed25519` et `chmod 700 ~/.ssh/` |
| Bloqué hors du serveur après modification | Conserver la session principale ouverte pendant la validation de sshd_config |

---

## Fiche mémo — Déploiement SSH sécurisé

| Étape | Action | Vérification |
|-------|--------|--------------|
| 1 | `ssh-keygen -t ed25519 -C "commentaire"` | Clé créée dans `~/.ssh/` |
| 2 | `ssh-copy-id -i ~/.ssh/id_ed25519.pub user@serveur` | Clé dans `authorized_keys` |
| 3 | Configurer `~/.ssh/config` | `ssh alias` fonctionne |
| 4 | Tester `sudo sshd -t` | Aucune erreur de syntaxe |
| 5 | Modifier `sshd_config` (port, no root, no password) | — |
| 6 | Redémarrer : `sudo systemctl restart ssh` | Nouvelle connexion OK |
| 7 | Configurer `jail.local` + démarrer fail2ban | `fail2ban-client status sshd` OK |

### Checklist de sécurité SSH

- [ ] Clés ED25519 avec passphrase (pas de clé sans protection)
- [ ] Port non standard configuré
- [ ] `PermitRootLogin no`
- [ ] `PasswordAuthentication no`
- [ ] `AllowUsers` limité aux comptes nécessaires
- [ ] Permissions strictes : `700` sur `~/.ssh/`, `600` sur clés et config
- [ ] fail2ban actif avec `ignoreip` pour le LAN
- [ ] Session de secours ouverte pendant toute modification

---

*Document généré pour la Phase 1 — Module 4 : SSH sécurisé & fail2ban*
