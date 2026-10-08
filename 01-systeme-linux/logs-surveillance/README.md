# Logs & Surveillance système

> **Phase 1 — Administration Linux & Système**
> Statut : ✅ Terminé

---

## Objectif

Maîtriser l'architecture des logs Linux, savoir analyser des fichiers de logs avec les outils CLI (`grep`, `awk`, `sed`, `cut`, `sort`, `uniq`), configurer la rotation automatique avec `logrotate`, et surveiller un serveur en temps réel.

---

## Sommaire

- [1. Architecture des logs Linux](#1-architecture-des-logs-linux)
- [2. Analyser des logs](#2-analyser-des-logs)
  - [grep et grep -E](#grep-et-grep--e)
  - [awk](#awk)
  - [sed](#sed)
  - [cut](#cut)
  - [sort](#sort)
  - [uniq -c](#uniq--c)
  - [wc -l](#wc--l)
- [3. logrotate](#3-logrotate)
- [4. Surveillance en temps réel](#4-surveillance-en-temps-réel)
- [5. Exercice — Top 10 IPs SSH](#5-exercice--top-10-ips-ssh)
- [Commandes clés apprises](#commandes-clés-apprises)
- [Difficultés rencontrées & solutions](#difficultés-rencontrées--solutions)

---

## 1. Architecture des logs Linux

### Le flux d'un log

```text
Application / Kernel / Service
         │
         ▼
     rsyslog          ← collecte et trie les messages
         │
         ▼
   /var/log/          ← stockage sur disque
```

### Fichiers importants dans /var/log/

| Fichier | Contenu |
|---|---|
| `syslog` | Messages système généraux |
| `auth.log` | Authentifications, sudo, connexions SSH |
| `kern.log` | Messages du noyau |
| `apt/history.log` | Historique d'installation des paquets |

> **💡 Note :** rsyslog est le démon traditionnel qui centralise les logs. Sur les distributions récentes, **systemd-journald** coexiste et stocke des logs binaires dans `/run/log/journal/` (consultés via `journalctl`).

---

## 2. Analyser des logs

### grep et grep -E

```bash
grep "Failed password" /var/log/auth.log         # Recherche exacte
grep -i "error" /var/log/syslog                  # Insensible à la casse
grep -v "debug" /var/log/syslog                  # Exclure un motif
grep -E "error|warning|critical" /var/log/syslog # Expressions régulières étendues
```

| Option | Rôle |
|---|---|
| `-i` | Insensible à la casse |
| `-v` | Inverser (exclure les lignes correspondantes) |
| `-E` | Expressions régulières étendues (`|`, `+`, `()`, `{}`...) |
| `-n` | Afficher les numéros de ligne |
| `-c` | Compter les occurrences |
| `-r` | Recherche récursive dans un dossier |

---

### awk

`awk` découpe chaque ligne en champs séparés par des espaces (`$1`, `$2`, ...).

```bash
# Extraire l'IP (champ 11) des tentatives de connexion échouées dans auth.log
awk '/Failed password/ {print $11}' /var/log/auth.log
```

| Élément | Rôle |
|---|---|
| `$0` | Ligne entière |
| `$1`, `$2`, `$11`... | Champ 1, 2, 11... |
| `$NF` | Dernier champ de la ligne |
| `/motif/` | Filtrer les lignes contenant le motif |
| `{print ...}` | Action à exécuter sur les lignes filtrées |

---

### sed

```bash
sed 's/error/ERREUR/g' /var/log/syslog          # Remplacer du texte
sed -n '10,20p' /var/log/syslog                 # Afficher les lignes 10 à 20
```

| Commande | Rôle |
|---|---|
| `s/motif/remplacement/g` | Substituter (remplacer) `g` = toutes les occurrences de la ligne |
| `-n 'Xp'` | Afficher uniquement la ligne X |
| `-n 'X,Yp'` | Afficher les lignes X à Y |
| `-i` | Modifier le fichier directement (in place) |

> **⚠️ Attention :** `sed` ne modifie que l'affichage par défaut. Ajouter `-i` pour écrire dans le fichier (ou `-i.bak` pour garder une sauvegarde).

---

### cut

```bash
cut -d: -f1 /etc/passwd                         # Extraire les noms d'utilisateurs
cut -d' ' -f1-3 /var/log/syslog                 # Extraire la date/heure
```

| Option | Rôle |
|---|---|
| `-d:` | Délimiteur (`:` ou espace `' '`) |
| `-f1` | Champ 1 |
| `-f1-3` | Champs 1 à 3 |
| `-f2-` | Champ 2 jusqu'à la fin |

---

### sort

```bash
sort fichier.txt                  # Tri alphabétique croissant
sort -r fichier.txt               # Tri décroissant
sort -n fichier.txt               # Tri numérique
sort -rn fichier.txt              # Tri numérique décroissant
sort -u fichier.txt               # Éliminer les doublons (équivalent de sort + uniq)
sort -k2 fichier.txt              # Trier sur le champ 2
sort -t: -k3 -n /etc/passwd       # Trier les utilisateurs par UID (délimiteur :)
```

---

### uniq -c

```bash
sort fichier.txt | uniq -c | sort -rn           # Compter les occurrences et trier du + au - grand
```

| Option | Rôle |
|---|---|
| `-c` | Préfixer chaque ligne par son nombre d'occurrences |
| `-d` | Afficher uniquement les doublons |
| `-u` | Afficher uniquement les lignes uniques |

> **⚠️ Important :** `uniq` ne compare que les lignes **adjacentes**. Il doit toujours être précédé de `sort` pour traiter les lignes identiques réparties dans le fichier.

---

### wc -l

```bash
wc -l /var/log/auth.log           # Compter le nombre de lignes
grep -c "Failed password" /var/log/auth.log   # Compter les échecs de connexion
```

| Option | Rôle |
|---|---|
| `-l` | Nombre de lignes |
| `-w` | Nombre de mots |
| `-c` | Nombre d'octets |

---

## 3. logrotate

`logrotate` tourne automatiquement (via cron/systemd timer) pour **compresser, archiver et effacer** les anciens logs afin d'éviter la saturation du disque.

### Configuration (`/etc/logrotate.d/monapp`)

```plaintext
/var/log/monapp.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0644 root root
}
```

| Directive | Rôle |
|---|---|
| `daily` | Rotation quotidienne (`weekly`, `monthly`, `size 100M`...) |
| `rotate 7` | Garder 7 archives (ici : 7 jours d'historique) |
| `compress` | Compresser les anciens logs (`.gz`) |
| `delaycompress` | Compresser à partir de la 2ème rotation (le plus récent reste lisible) |
| `missingok` | Ne pas échouer si le fichier de log est absent |
| `notifempty` | Ne pas tourner si le fichier est vide |
| `create 0644 root root` | Recréer le fichier neuf avec ces permissions et ce propriétaire |

```bash
sudo logrotate -d /etc/logrotate.d/monapp    # Tester la règle sans l'appliquer (dry-run)
sudo logrotate -f /etc/logrotate.d/monapp    # Forcer la rotation
```

> **✅ Bonne pratique :** toujours tester avec `-d` (dry-run) avant d'activer une règle, surtout sur les applications actives.

---

## 4. Surveillance en temps réel

```bash
sudo tail -f /var/log/syslog                    # Suivre un log
sudo tail -F /var/log/syslog                    # Suivre même après rotation du fichier
sudo multitail /var/log/syslog /var/log/auth.log # Suivre plusieurs logs dans un écran
```

| Outil | Usage |
|---|---|
| `tail -f` | Suit le fichier par son **descripteur** : s'arrête si le fichier est renommé (rotation) |
| `tail -F` | Suit le fichier par son **nom** : réouvre automatiquement le nouveau fichier après rotation |
| `multitail` | Suivre plusieurs fichiers en écran partagé (couleurs, filtres) |
| `watch -n 2 'commande'` | Relance la commande toutes les 2 secondes (surveillance d'un résultat) |

---

## 5. Exercice — Top 10 IPs SSH

**Objectif :** extraire de `auth.log` les 10 adresses IP ayant échoué le plus de connexions SSH.

```bash
sudo awk '/Failed password/ {print $11}' /var/log/auth.log \
  | sort \
  | uniq -c \
  | sort -rn \
  | head -10 \
  | awk '{printf "Tentatives: %-6s | IP: %s\n", $1, $2}'
```

**Explication étape par étape :**

| Étape | Commande | Rôle |
|---|---|---|
| 1 | `awk '/Failed password/ {print $11}'` | Filtre les échecs SSH et extrait l'IP (champ 11) |
| 2 | `sort` | Trie les IP identiques côte à côte (prérequis pour uniq) |
| 3 | `uniq -c` | Compte les occurrences de chaque IP |
| 4 | `sort -rn` | Trie numériquement par nombre de tentatives décroissant |
| 5 | `head -10` | Garde le top 10 |
| 6 | `awk '{printf ...}'` | Met en forme le résultat final |

**Exemple de sortie :**

```text
Tentatives: 243    | IP: 185.220.101.4
Tentatives: 87     | IP: 45.155.205.86
...
```

> **🛡️ Usage :** cette commande est un classique de l'analyse de sécurité pour détecter des attaques par force brute et alimenter un outil comme `fail2ban`.

---

## Commandes clés apprises

```bash
grep -i -E -v; awk '{print $NF}'; sed 's/a/b/g'; cut -d' ' -f1; sort -rn; uniq -c; logrotate -d; tail -F
```

---

## Difficultés rencontrées & solutions

| Difficulté rencontrée | Solution appliquée |
|----------------------|--------------------|
| `uniq -c` ne compte pas correctement | Toujours exécuter `sort` avant `uniq` car il ne compare que les lignes adjacentes |
| `tail -f` s'arrête lors de la rotation | Utiliser `tail -F` qui réouvre le nouveau fichier créé par logrotate |

---

## Fiche mémo — Analyse de logs

| Besoin | Commande |
|--------|----------|
| Erreurs récentes | `grep -i error /var/log/syslog \| tail` |
| Nombre d'erreurs | `grep -c error /var/log/syslog` |
| Trier par fréquence | `sort \| uniq -c \| sort -rn` |
| Champ spécifique | `awk '{print $N}'` ou `cut -d' ' -fN` |
| Dernier champ (IP, URL...) | `awk '{print $NF}'` |
| Tester logrotate | `logrotate -d` |
| Surveiller plusieurs logs | `multitail` |

### Pipeline d'analyse type

```text
Filtrer (grep) → Extraire (awk/cut) → Trier (sort) → Compter (uniq -c)
```

---

*Document généré pour la Phase 1 — Module 3 : Logs & Surveillance système*
