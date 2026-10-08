# Semaine 06
 — UFW & iptables : pare-feu sous Linux

> **Phase 2 — Réseaux & Sécurité**
> Statut : ✅ Terminé

---

## Objectif de la semaine

Comprendre l'architecture de filtrage réseau sous Linux (Netfilter, iptables, UFW), savoir écrire des règles de pare-feu, distinguer DROP et REJECT, et déployer un pare-feu complet en DEFAULT DENY avec UFW.

---

## Sommaire

- [1. Architecture : Netfilter, iptables, UFW](#1-architecture--netfilter-iptables-ufw)
- [2. iptables — concepts fondamentaux](#2-iptables--concepts-fondamentaux)
- [3. Commandes iptables](#3-commandes-iptables)
- [4. UFW — Uncomplicated Firewall](#4-ufw--uncomplicated-firewall)
- [5. DROP vs REJECT](#5-drop-vs-reject)
- [6. Exercice — DEFAULT DENY avec UFW](#6-exercice--default-deny-avec-ufw)
- [Commandes clés apprises](#commandes-clés-apprises)
- [Livrables & preuves](#livrables--preuves)
- [Difficultés rencontrées & solutions](#difficultés-rencontrées--solutions)

---

## 1. Architecture : Netfilter, iptables, UFW

```
   UFW       ──▶   iptables   ──▶   Netfilter (noyau)
 (simple)         (détaillé)         (filtrage réel)
```

| Composant | Rôle |
|---|---|
| **Netfilter** | Framework du noyau Linux qui intercepte et filtre réellement les paquets |
| **iptables** | Outil CLI historique pour écrire des règles Netfilter |
| **nftables** | Successeur moderne d'iptables (Debian 10+, Ubuntu récents) |
| **UFW** | Surcouche simplifiée qui génère des règles iptables |

> Sur Debian/Ubuntu récents, `iptables` est souvent un wrapper vers nftables.
> Vérifier avec : `iptables -V` → affiche `(nf_tables)` ou `(legacy)`.

---

## 2. iptables — concepts fondamentaux

### Le parcours d'un paquet — les 5 chaînes

```
                    ┌───────────────┐
 Paquet entrant ──▶ │  PREROUTING   │ (nat, mangle, raw)
                    └───────┬───────┘
                   destination = moi ?
                 ┌──── oui ─┴─ non ────┐
                 ▼                     ▼
           ┌──────────┐          ┌──────────┐
           │  INPUT   │          │ FORWARD  │
           └────┬─────┘          └────┬─────┘
                ▼                     │
        Processus local               │
                │                     │
           ┌────▼─────┐               │
           │  OUTPUT  │               │
           └────┬─────┘               │
                └──────────┬──────────┘
                    ┌──────▼───────┐
                    │ POSTROUTING  │ (nat, mangle)
                    └──────┬───────┘
                           ▼
                    Paquet sortant
```

| Chaîne | Quand est-elle traversée ? |
|---|---|
| `PREROUTING` | Dès l'arrivée, avant la décision de routage (DNAT) |
| `INPUT` | Paquets à destination de cette machine |
| `FORWARD` | Paquets qui traversent la machine (routeur, Docker) |
| `OUTPUT` | Paquets émis par la machine |
| `POSTROUTING` | Juste avant le départ (SNAT, MASQUERADE) |

---

### Les tables

| Table | Rôle | Chaînes disponibles |
|---|---|---|
| `filter` (défaut) | Filtrer : autoriser ou bloquer | INPUT, FORWARD, OUTPUT |
| `nat` | Traduire les adresses (NAT, redirection de ports) | PREROUTING, OUTPUT, POSTROUTING |
| `mangle` | Modifier des champs de paquets (TTL, marquage) | Toutes |
| `raw` | Exclure du suivi de connexion | PREROUTING, OUTPUT |

> Pour un pare-feu d'hôte classique, on travaille presque toujours dans `filter`. Sans `-t`, iptables utilise `filter` par défaut.

---

### Les cibles (targets)

| Cible | Effet |
|---|---|
| `ACCEPT` | Laisse passer le paquet |
| `DROP` | Le jette silencieusement — aucune réponse |
| `REJECT` | Le jette et prévient l'émetteur (ICMP ou TCP RST) |
| `LOG` | Écrit dans les logs du noyau, puis continue l'évaluation |
| `RETURN` | Sort de la chaîne courante |
| `MASQUERADE` | Change l'adresse source (table nat) |
| `DNAT` | Change l'adresse/port de destination (table nat) |

---

### Règle d'or — l'ordre compte

Les règles d'une chaîne sont lues **de haut en bas**. La première qui correspond gagne (sauf LOG). Si aucune ne correspond, la politique par défaut (`-P`) s'applique.

```
Règle 1 : DROP  tout depuis 10.0.0.5
Règle 2 : ACCEPT tcp/22 depuis 10.0.0.5
→ La règle 2 ne sera JAMAIS atteinte pour 10.0.0.5
```

---

### Le suivi de connexion (stateful)

Sans `conntrack`, il faudrait ouvrir manuellement les ports de retour de chaque connexion. Avec conntrack, Netfilter sait si un paquet appartient à une connexion déjà autorisée.

| État | Signification |
|---|---|
| `NEW` | Premier paquet d'une nouvelle connexion |
| `ESTABLISHED` | Fait partie d'une connexion déjà vue dans les deux sens |
| `RELATED` | Lié à une connexion existante (erreur ICMP, FTP data...) |
| `INVALID` | N'appartient à rien de cohérent — à DROP systématiquement |

---

## 3. Commandes iptables

### Afficher les règles

```bash
sudo iptables -L -n -v --line-numbers      # Table filter, numérique, compteurs, numéros de ligne
sudo iptables -S                           # Format "commandes" (plus fidèle)
sudo iptables -t nat -L -n -v              # Table nat
```

---

### Ajouter des règles

```bash
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT          # -A : à la FIN de la chaîne
sudo iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT        # -I : en position 1 (début)
```

---

### Supprimer des règles

```bash
sudo iptables -D INPUT 3                                     # Par numéro de ligne
sudo iptables -D INPUT -p tcp --dport 80 -j ACCEPT          # Par spécification exacte
sudo iptables -F INPUT                                       # Vider une chaîne entière
```

---

### Politique par défaut

```bash
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT
```

---

### Options de filtrage courantes

| Option | Signification |
|---|---|
| `-p tcp/udp/icmp` | Protocole |
| `-s IP` / `-d IP` | Source / Destination (accepte CIDR : `192.168.1.0/24`) |
| `--dport` / `--sport` | Port destination / source (avec `-p tcp` ou `udp`) |
| `-i ens33` / `-o ens33` | Interface d'entrée / de sortie |
| `-m conntrack --ctstate` | État de la connexion |
| `-m multiport --dports 80,443` | Plusieurs ports en une règle |
| `-j CIBLE` | Que faire du paquet |

---

### Exemple complet — pare-feu serveur web

```bash
# 0. Repartir de zéro
sudo iptables -F
sudo iptables -X

# 1. Autoriser l'existant AVANT de durcir la politique
sudo iptables -A INPUT -i lo -j ACCEPT                                       # Loopback
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT  # Retours
sudo iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

# 2. Les services voulus
sudo iptables -A INPUT -p tcp --dport 2222 -j ACCEPT
sudo iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT
sudo iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

# 3. Politique stricte ENSUITE
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT
```

> ⚠️ Ne jamais mettre `-P INPUT DROP` avant les règles SSH. Tu te coupes de la machine instantanément.

---

### Persistance des règles iptables

Les règles iptables sont **perdues au redémarrage** sans sauvegarde.

```bash
sudo apt install iptables-persistent
sudo netfilter-persistent save                            # Sauvegarde dans /etc/iptables/rules.v4

# Manuellement
sudo iptables-save > /etc/iptables/rules.v4
sudo iptables-restore < /etc/iptables/rules.v4
```

---

### Table nat — exemples

**Partage de connexion (masquerade) :**

```bash
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o ens33 -j MASQUERADE
sudo iptables -A FORWARD -i ens34 -o ens33 -j ACCEPT
sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
```

**Redirection de port (port forwarding) :**

```bash
sudo iptables -t nat -A PREROUTING -i ens33 -p tcp --dport 8080 \
     -j DNAT --to-destination 10.0.0.10:80
```

> C'est exactement ce que fait pfSense derrière son interface graphique.

---

## 4. UFW — Uncomplicated Firewall

UFW est l'outil par défaut d'Ubuntu. Il écrit dans des chaînes iptables dédiées (`ufw-user-input`, `ufw-before-input`...). Il est **désactivé par défaut** à l'installation.

```bash
sudo apt install ufw        # Si absent
sudo ufw status             # "Status: inactive" au départ
```

---

### Politiques par défaut

```bash
sudo ufw default deny incoming      # Bloquer tout ce qui entre
sudo ufw default allow outgoing     # Autoriser tout ce qui sort
```

---

### Autoriser des ports et services

```bash
sudo ufw allow 80/tcp                           # Un port précis
sudo ufw allow 443                              # TCP + UDP
sudo ufw allow 6000:6010/tcp                    # Plage de ports
sudo ufw allow ssh                              # Par nom (lit /etc/services → 22)
sudo ufw allow OpenSSH                          # Par profil d'application
sudo ufw allow 'Nginx Full'                     # Profil : 80 + 443
sudo ufw allow 2222/tcp comment 'SSH custom'    # Avec commentaire
```

---

### Bloquer des ports et IPs

```bash
sudo ufw deny 3306/tcp                                          # DROP silencieux
sudo ufw reject 25/tcp                                          # REJECT avec réponse
sudo ufw deny from 203.0.113.50                                 # Bannir une IP
```

---

### Règles ciblées

```bash
sudo ufw allow from 192.168.1.15                                # Toute connexion depuis une IP
sudo ufw allow from 192.168.1.0/24 to any port 3306 proto tcp   # MariaDB pour le LAN seulement
sudo ufw allow in on ens33 to any port 80                       # Sur une interface précise
sudo ufw limit 2222/tcp                                         # Anti brute-force (6 cx / 30s)
```

---

### Activer / désactiver / recharger

```bash
sudo ufw enable             # Activer (et au démarrage)
sudo ufw disable            # Désactiver
sudo ufw reload             # Recharger les règles sans désactiver
sudo ufw reset              # Effacer TOUT et désactiver
```

---

### Voir et supprimer des règles

```bash
sudo ufw status             # Résumé
sudo ufw status verbose     # Avec politiques et logging
sudo ufw status numbered    # Avec numéros de règles

sudo ufw delete 3                   # Par numéro
sudo ufw delete allow 80/tcp        # Par spécification (plus sûr)
```

> Après une suppression par numéro, les numéros changent. Refaire `status numbered` avant une deuxième suppression.

---

### Logs UFW

```bash
sudo ufw logging on                  # Activer (niveaux : off, low, medium, high, full)
sudo tail -f /var/log/ufw.log        # Suivre les logs en temps réel
sudo journalctl -k | grep UFW        # Via journald
```

**Exemple de ligne de blocage :**

```
[UFW BLOCK] IN=ens33 SRC=192.168.1.15 DST=192.168.1.20 PROTO=TCP SPT=51544 DPT=3306
```

Elle donne la source, la destination, le protocole et le port visé.

---

### Fichiers de configuration UFW

| Fichier | Rôle |
|---|---|
| `/etc/default/ufw` | Politiques par défaut, IPv6 (`IPV6=yes`) |
| `/etc/ufw/user.rules` | Tes règles (générées automatiquement) |
| `/etc/ufw/before.rules` | Règles appliquées avant les tiennes (loopback, ICMP, conntrack) |
| `/etc/ufw/after.rules` | Règles appliquées après les tiennes |
| `/etc/ufw/applications.d/` | Profils d'applications (Nginx, OpenSSH...) |

---

### Pièges importants

| Piège | Solution |
|---|---|
| Se couper de SSH | Toujours autoriser SSH **avant** `ufw enable` |
| Docker contourne UFW | Publier sur `127.0.0.1` : `-p 127.0.0.1:8080:80` |
| IPv6 non filtré | Vérifier `IPV6=yes` dans `/etc/default/ufw` |
| Mélanger UFW et iptables | Éviter — UFW peut écraser tes règles manuelles |

---

## 5. DROP vs REJECT

| Critère | DROP | REJECT |
|---|---|---|
| Comportement | Le paquet disparaît, aucune réponse | Une réponse d'erreur est renvoyée |
| Côté client TCP | Attente puis timeout (~2 min) | Échec immédiat (`Connection refused`) |
| Ce que voit nmap | Port `filtered` | Port `closed` |
| Information donnée | Minimale | Révèle la présence d'un filtre actif |
| Charge réseau | Ralentit les scanners | Réponses à générer |

---

### Observer la différence avec tcpdump

**Port REJECT — le client reçoit un reset immédiatement :**

```
IP 192.168.1.20.80 > 192.168.1.15.51544: Flags [R.]
```

**Port DROP — le client envoie des SYN sans réponse :**

```
IP 192.168.1.15.51544 > 192.168.1.20.80: Flags [S]   (retransmissions : 1s, 2s, 4s...)
```

---

### Quand utiliser quoi

| Situation | Règle recommandée |
|---|---|
| Trafic venant d'Internet / réseau non fiable | `DROP` — ralentit les scanners, moins d'info |
| Réseau interne / de confiance | `REJECT` — échec rapide, facilite le diagnostic |
| Services que tes utilisateurs atteignent par erreur | `REJECT` — message clair immédiat |

---

### En iptables

```bash
sudo iptables -A INPUT -p tcp --dport 3306 -j DROP
sudo iptables -A INPUT -p tcp --dport 3306 -j REJECT --reject-with tcp-reset
sudo iptables -A INPUT -p udp --dport 53  -j REJECT --reject-with icmp-port-unreachable
```

---

## 6. Exercice — DEFAULT DENY avec UFW

**Objectif :** Configurer UFW en DEFAULT DENY et ouvrir uniquement SSH (port 2222), HTTP (80) et HTTPS (443).

---

### Étape 1 — Vérifier que SSH écoute sur 2222

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo nano /etc/ssh/sshd_config
# Port 2222

sudo sshd -t && echo "config OK"           # Vérifier la syntaxe
sudo systemctl restart ssh
sudo ss -tlnp | grep sshd                  # Confirmer : 0.0.0.0:2222
```

> Garder la session SSH actuelle ouverte pendant toute la configuration. C'est le filet de sécurité.

---

### Étape 2 — Politiques par défaut

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

---

### Étape 3 — Ouvrir les ports nécessaires

```bash
sudo ufw allow 22/tcp   comment 'SSH temporaire'     # Filet de sécurité pendant la migration
sudo ufw allow 2222/tcp comment 'SSH custom'
sudo ufw allow 80/tcp   comment 'HTTP'
sudo ufw allow 443/tcp  comment 'HTTPS'
```

---

### Étape 4 — Activer UFW

```bash
sudo ufw enable
# Command may disrupt existing ssh connections. Proceed with operation (y|n)? y
```

> La session existante survit : les connexions `ESTABLISHED` sont autorisées par `before.rules`.

---

### Étape 5 — Tester le port 2222 depuis un second terminal

```bash
ssh -p 2222 devops@192.168.1.20     # Doit fonctionner
```

Si la connexion réussit → passer à l'étape suivante. Sinon, la session d'origine est toujours ouverte pour corriger.

---

### Étape 6 — Supprimer la règle temporaire du port 22

```bash
sudo ufw status numbered            # Voir les numéros
sudo ufw delete allow 22/tcp        # Supprimer par spécification (plus sûr que le numéro)
```

---

### Étape 7 — Vérification finale

```bash
sudo ufw status verbose
```

Sortie attendue :

```
Status: active
Default: deny (incoming), allow (outgoing), disabled (routed)

To                    Action      From
--                    ------      ----
2222/tcp              ALLOW IN    Anywhere     # SSH custom
80/tcp                ALLOW IN    Anywhere     # HTTP
443/tcp               ALLOW IN    Anywhere     # HTTPS
2222/tcp (v6)         ALLOW IN    Anywhere (v6)
80/tcp (v6)           ALLOW IN    Anywhere (v6)
443/tcp (v6)          ALLOW IN    Anywhere (v6)
```

---

### Étape 8 — Tests depuis une autre machine

```bash
nmap -Pn -p 22,80,443,2222,3306 192.168.1.20
# 22/tcp    filtered    ← bloqué (DROP)
# 80/tcp    open        ← autorisé
# 443/tcp   open/closed ← autorisé (closed si aucun service n'écoute)
# 2222/tcp  open        ← SSH
# 3306/tcp  filtered    ← bloqué (DROP)

ssh -p 2222 devops@192.168.1.20     # OK
ssh -p 22   devops@192.168.1.20     # Timeout : bloqué
curl -I http://192.168.1.20         # 200 OK
```

> `open` sur 443 n'apparaît que si un service écoute réellement sur ce port. Le pare-feu autorise mais ne lance aucun service.

---

### Étape 9 — Observer le blocage dans les logs

```bash
sudo tail -f /var/log/ufw.log
# Depuis l'autre machine : nmap -p 3306 192.168.1.20
# [UFW BLOCK] IN=ens33 SRC=192.168.1.15 DST=192.168.1.20 PROTO=TCP DPT=3306
```

```bash
sudo tcpdump -i ens33 -nn 'tcp port 22 and host 192.168.1.15'
# Uniquement des [S] répétés sans réponse → DROP confirmé
```

---

### Étape 10 — Vérifier ce qu'UFW a généré en iptables

```bash
sudo iptables -S | head -20
# -P INPUT DROP
# -P FORWARD DROP
# -P OUTPUT ACCEPT
# -N ufw-user-input ...

sudo iptables -L ufw-user-input -n -v --line-numbers
# 1  tcp dpt:2222
# 2  tcp dpt:80
# 3  tcp dpt:443
```

---

### Équivalent iptables pur (pour comprendre ce qu'UFW fait)

```bash
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 2222 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80   -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443  -j ACCEPT
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT
```

> Les 8 commandes iptables (plus la persistance et l'IPv6) se résument à ce qu'UFW fait en 5 lignes.

---

### Durcissement supplémentaire

```bash
sudo ufw limit 2222/tcp                                          # Anti brute-force SSH
sudo ufw allow from 192.168.1.0/24 to any port 2222             # SSH limité au LAN
sudo ufw logging medium                                          # Niveau de log intermédiaire
```

---

### Plan de secours si tu t'es coupé

```bash
# 1. Console VMware (connexion locale, pas réseau)
sudo ufw disable

# 2. Ré-ouvrir SSH puis recharger
sudo ufw allow 2222/tcp
sudo ufw reload

# 3. En dernier recours
sudo ufw reset              # Efface tout, désactive UFW
```

---

## Commandes clés apprises

```bash
# iptables
sudo iptables -L -n -v --line-numbers
sudo iptables -S
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT
sudo iptables -D INPUT 3
sudo iptables -F INPUT
sudo iptables -P INPUT DROP
sudo iptables -t nat -L -n -v
sudo iptables-save > /etc/iptables/rules.v4

# UFW
sudo ufw status verbose
sudo ufw status numbered
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 2222/tcp comment 'SSH'
sudo ufw allow 'Nginx Full'
sudo ufw deny 3306/tcp
sudo ufw limit 2222/tcp
sudo ufw allow from 192.168.1.0/24 to any port 3306 proto tcp
sudo ufw delete allow 80/tcp
sudo ufw enable / disable / reload / reset
sudo ufw logging on
sudo tail -f /var/log/ufw.log
```

---

## Livrables & preuves

- [ ] Capture de `sudo ufw status verbose` avec DEFAULT DENY actif
- [ ] Capture de `nmap -Pn -p 22,80,443,2222,3306` depuis une autre VM
- [ ] Capture de `sudo iptables -L ufw-user-input -n -v` générée par UFW
- [ ] Capture de `sudo tcpdump` montrant les `[S]` sans réponse sur un port bloqué
- [ ] Capture de `sudo tail /var/log/ufw.log` avec une ligne `[UFW BLOCK]`
- [ ] Connexion SSH réussie sur le port 2222

---

## Difficultés rencontrées & solutions

| Difficulté rencontrée | Solution appliquée |
|---|---|
| Coupure SSH après `ufw enable` | Toujours autoriser le port SSH **avant** d'activer UFW |
| Règle SSH ignorée sur Ubuntu 22.10+ | `sudo systemctl restart ssh.socket` — socket activation |
| nmap affiche `closed` sur le port 443 | Normal : UFW autorise mais aucun service n'écoute sur ce port |
| Docker contourne UFW | Publier les conteneurs sur `127.0.0.1` : `-p 127.0.0.1:8080:80` |
| Numéros de règles qui changent après suppression | Utiliser `delete allow PORT/tcp` plutôt que `delete N` |
| `ufw reset` a tout effacé | Reconfigurer depuis zéro : default deny → allow SSH → enable |
| Règles iptables perdues après reboot | Installer `iptables-persistent` et sauvegarder |
