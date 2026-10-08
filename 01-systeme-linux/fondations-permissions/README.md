# Linux : Fondations, FHS, Navigation & Gestion des identités

> **Phase 1 — Administration Linux & Système**
> Statut : ✅ Terminé

---

## Objectif

Maîtriser les bases indispensables de l'environnement Linux : l'historique du système, la structure du système de fichiers (FHS), la navigation en ligne de commande, la manipulation de fichiers, la gestion complète des utilisateurs et des groupes, ainsi que les permissions avancées (ACL & sudoers).

---

## Sommaire

1. [Histoire & distributions](#1-histoire--distributions)
2. [Terminal, Shell & raccourcis](#2-terminal-shell--raccourcis)
3. [Système de fichiers FHS](#3-système-de-fichiers-fhs)
4. [Navigation & recherche](#4-navigation--recherche)
5. [Manipulation de fichiers](#5-manipulation-de-fichiers)
6. [Utilisateurs & groupes](#6-utilisateurs--groupes)
7. [Permissions & chmod](#7-permissions--chmod)
8. [Permissions Unix : chown, chgrp](#8-permissions-unix--chown-chgrp)
9. [Permissions avancées : ACL & sudoers](#9-permissions-avancées--acl--sudoers)
10. [Commandes clés apprises](#10-commandes-clés-apprises)
11. [Difficultés rencontrées & solutions](#11-difficultés-rencontrées--solutions)

---

## 1. Histoire & distributions

### Ligne de temps

```text
1969  Multics (General Electric + Bell Labs + MIT)
        └─> Bell Labs abandonne et crée Unix (écrit en C)

1983  Richard Stallman lance le projet GNU (GNU's Not Unix)
        └─> GNU fournit les outils : compilateur, shell, éditeur...
        └─> Kernel GNU Hurd : trop instable pour la production

1991  Linus Torvalds publie le kernel Linux
        └─> Fusion GNU + Linux Kernel = GNU/Linux
              (souvent appelé simplement "Linux")
```

> **⚠️ Important :** le nom complet et correct est **GNU/Linux**. "Linux" désigne uniquement le noyau (kernel), pas le système complet.

### Les deux familles de distributions

| Famille | Distribution mère | Dérivées notables |
|---------|-------------------|-------------------|
| Debian | Debian (1993) | Ubuntu, Lubuntu, Linux Mint |
| Red Hat | Red Hat (1994) | Fedora, RHEL, Rocky Linux, CentOS |

---

## 2. Terminal, Shell & raccourcis

### Concepts clés

| Terme | Définition |
|-------|------------|
| **Kernel** | Noyau du système : gère le matériel et les ressources |
| **Shell** | Interface entre l'utilisateur et le kernel |
| **Terminal** | Émulateur de shell (interface graphique vers le shell) |
| **Bash** | Bourne Again Shell — version améliorée du shell Unix original |
| **TTY** | TeleTYpewriter — terminal virtuel (tty1 à tty6) |

### Anatomie du prompt

```plaintext
[slimane @ debian ~ $]
  │        │       │  └─ $ = utilisateur normal  |  # = root (admin)
  │        │       └──── ~ = répertoire courant (home par défaut)
  │        └──────────── nom de la machine (hostname)
  └───────────────────── nom de l'utilisateur connecté
```

### Raccourcis clavier essentiels

| Raccourci | Action |
|-----------|--------|
| `Ctrl + A` | Déplacer le curseur au début de la ligne |
| `Ctrl + E` | Déplacer le curseur à la fin de la ligne |
| `Ctrl + U` | Effacer toute la ligne avant le curseur |
| `Ctrl + W` | Effacer le mot précédent le curseur |
| `Ctrl + L` | Nettoyer l'écran (équivalent de `clear`) |
| `Ctrl + C` | Interrompre l'exécution d'une commande |
| `Ctrl + D` | Fermer le terminal / se déconnecter |
| `Alt + .` | Réutiliser le dernier argument de la commande précédente |

### Commandes de base du terminal

```bash
date              # Afficher la date et l'heure complètes
date +%r          # Afficher uniquement l'heure
date +%x          # Afficher uniquement la date
cal               # Calendrier du mois courant
cal 2024          # Calendrier de l'année 2024
cal 1 2024        # Calendrier de janvier 2024
clear             # Vider l'écran
tty               # Savoir dans quel TTY on se trouve
sleep 50          # Ne rien faire pendant 50 secondes

# Exécuter plusieurs commandes sur une seule ligne
date ; pwd ; whoami
```

---

## 3. Système de fichiers FHS

**FHS = Filesystem Hierarchy Standard**

- Tout part d'un seul point de départ : `/` (la racine).
- Contrairement à Windows (`C:\`), Linux n'a **qu'un seul arbre de fichiers**.

```plaintext
/
├── bin/      Commandes de base (ls, cp, mv...) — accessibles à tous
├── sbin/     Commandes système (reboot, fdisk...) — réservées à root
├── etc/      Fichiers de configuration (/etc/hostname, /etc/passwd...)
├── home/     Répertoires personnels des utilisateurs (/home/slimane)
├── root/     Répertoire personnel de l'administrateur root
├── usr/      Programmes installés et ressources (/usr/bin, /usr/share)
├── var/      Données variables : logs (/var/log), bases de données
├── dev/      Représentation des périphériques (/dev/sda, /dev/sdb1)
├── boot/     Fichiers de démarrage (kernel vmlinuz, GRUB)
├── tmp/      Fichiers temporaires (effacés au redémarrage)
├── lib/      Bibliothèques partagées (.so = équivalent .dll Windows)
├── media/    Montage automatique des disques amovibles (clé USB)
├── mnt/      Montage manuel par l'administrateur
├── proc/     Système de fichiers virtuel : infos sur les processus en cours
└── sys/      Système de fichiers virtuel : infos sur le matériel (sysfs)
```

> **💡 Note :** `/proc` et `/sys` n'existent pas sur le disque. Ils sont générés dynamiquement par le kernel en mémoire vive.

### Comparaison Linux / Windows

| Linux | Windows |
|-------|---------|
| `/home/slimane/documents` | `C:\Users\slimane\Documents` |
| Séparateur `/` | Séparateur `\` |
| `/etc/hostname` | Registre Windows |
| Simples fichiers texte lisibles | Base de registre |
| `/dev/sdb1` | `D:` |
| Les périphériques sont des fichiers | Lettres de lecteur |

---

## 4. Navigation & recherche

### Se déplacer dans l'arborescence

```bash
pwd                     # Afficher le répertoire courant (Print Working Directory)
ls                      # Lister les fichiers du répertoire courant
ls /                    # Lister le contenu de la racine
ls -l                   # Format long : permissions, propriétaire, taille, date
ls -a                   # Afficher les fichiers cachés (commençant par .)
ls -lah                 # Long + cachés + tailles lisibles (Ko, Mo, Go)
ls -R                   # Lister récursivement tous les sous-dossiers
ls -lr work/            # Lister en ordre décroissant
ls -ld work/            # Infos sur le dossier lui-même (pas son contenu)

cd /var                 # Aller dans /var (chemin absolu)
cd ~   ou   cd          # Retourner dans son répertoire personnel (home)
cd ..                   # Remonter d'un niveau dans l'arborescence
cd -                    # Retourner au répertoire précédent (comme "retour arrière")
cd .                    # Rester dans le répertoire actuel (utile en scripting)
```

- **Chemin absolu** : part toujours de `/` → `cd /home/slimane/Desktop`
- **Chemin relatif** : part de l'endroit où on est → `cd Desktop`

### Lire une ligne `ls -l`

```plaintext
drwxr-xr-x  2  slimane  dev-team  4096  15 juin 14:30  Desktop
│            │  │        │         │     │              │
│            │  │        │         │     │              └─ Nom du fichier/dossier
│            │  │        │         │     └──────────────── Date de dernière modification
│            │  │        │         └────────────────────── Taille en octets
│            │  │        └──────────────────────────────── Groupe propriétaire
│            │  └───────────────────────────────────────── Utilisateur propriétaire
│            └──────────────────────────────────────────── Nombre de liens physiques
└───────────────────────────────────────────────────────── Type + permissions (10 car.)
```

### Premier caractère — type de l'objet

| Caractère | Signification |
|-----------|---------------|
| `-` | Fichier standard (texte, script, image...) |
| `d` | Répertoire / Dossier (Directory) |
| `l` | Lien symbolique (raccourci vers un autre fichier) |

### Rechercher des fichiers avec `find`

```bash
find . -name "rapport.txt"          # Nom exact dans le dossier courant
find /home -iname "rapport.txt"     # Insensible à la casse
find /etc -name "*.conf"            # Tous les fichiers .conf dans /etc
find . -type d -name "src"          # Uniquement les dossiers nommés "src"
find . -type f -name "*.sh"         # Uniquement les fichiers .sh
find /var -size +10M                # Fichiers de plus de 10 Mo
find /home -size -50k               # Fichiers de moins de 50 Ko
```

### Rechercher avec `locate`

```bash
locate nginx.conf          # Tous les chemins contenant "nginx.conf"
locate backup              # Tout ce qui contient "backup" dans le chemin
locate -i rapport          # Insensible à la casse
locate -c rapport          # Afficher uniquement le nombre de résultats
locate -l 10 rapport       # Limiter aux 10 premiers résultats
locate -e rapport          # Vérifier que le fichier existe vraiment sur le disque
sudo updatedb              # Mettre à jour la base de données de locate
```

### `find` vs `locate`

| Critère | `find` | `locate` |
|---------|--------|----------|
| Vitesse | Lent (scan disque en temps réel) | Ultra rapide (base indexée) |
| Précision | 100 % temps réel | Peut rater des fichiers récents |
| Critères de recherche | Nom, taille, date, type, droits | Uniquement par le nom |

### Localiser les exécutables

```bash
which ls                   # Emplacement de ls dans le $PATH
which -a python3           # Toutes les versions de python3 installées
whereis ls                 # Exécutable + manuel + sources d'un coup
whereis -b nginx           # Uniquement le binaire
whereis -m nginx           # Uniquement la page de manuel
```

### Chercher dans le contenu avec `grep`

```bash
grep "error" /var/log/syslog           # Chercher "error" dans un fichier
grep -i "error" /var/log/syslog        # Insensible à la casse
grep -r "password" /etc/               # Chercher récursivement dans /etc
grep -v "error" fichier.log            # Tout sauf les lignes avec "error"
grep -n "error" fichier.log            # Afficher le numéro de ligne
grep -c "error" fichier.log            # Compter les occurrences
grep -w "an" fichier.txt               # Mot exact (ne trouve pas "important")

# Combinaison avec le pipe
cat /etc/passwd | grep slimane         # Récupérer tout, filtrer ensuite
grep slimane /etc/passwd               # Équivalent, plus direct et efficace
```

---

## 5. Manipulation de fichiers

### Créer des fichiers et dossiers

```bash
touch fichier.txt             # Créer un fichier vide (met à jour la date si existant)
touch f1 f2 f3                # Créer plusieurs fichiers en une commande
touch f{1..10}                # Créer f1, f2, ..., f10 d'un coup (expansion)

mkdir MonDossier              # Créer un dossier
mkdir -p dir1/dir2/dir3       # Créer toute une arborescence en une commande

nano fichier.txt              # Créer/éditer un fichier avec l'éditeur nano
```

### Lire le contenu des fichiers

```bash
cat fichier.txt               # Afficher tout le contenu dans le terminal
head fichier.txt              # Afficher les 10 premières lignes (défaut)
head -n 5 fichier.txt         # Afficher les 5 premières lignes
tail fichier.txt              # Afficher les 10 dernières lignes (défaut)
tail -n 15 /var/log/auth.log  # Afficher les 15 dernières lignes
tail -f /var/log/syslog       # Suivre en temps réel (Ctrl+C pour arrêter)
tail -F /var/log/syslog       # Idem, résiste à la rotation automatique des logs
more /etc/services            # Lire page par page (ancien, navigation limitée)
less /var/log/syslog          # Lire avec navigation complète (recommandé)
```

### Copier, déplacer, renommer, supprimer

```bash
# Copier (cp)
cp rapport.pdf /home/slimane/                    # Copier vers un dossier
cp rapport.pdf /home/slimane/rapport_v2.pdf      # Copier avec un nouveau nom
cp -r MonDossier/ /var/backup/                   # Copier un dossier et son contenu
cp -rv /media/* /var/backup/                     # Copier avec affichage de l'avancement

# Déplacer / Renommer (mv)
mv rapport.pdf /home/slimane/                    # Déplacer (même nom)
mv rapport.pdf /home/slimane/newname.pdf         # Déplacer avec renommage
mv file1 file2                                   # Renommer dans le même dossier

# Supprimer (rm)
rm fichier.txt                                   # Supprimer un fichier
rm -i fichier.txt                                # Demander confirmation
rm -r MonDossier/                                # Supprimer un dossier et son contenu
rm -rf MonDossier/                               # Forcer la suppression sans confirmation
```

---

## 6. Utilisateurs & groupes

### Les identifiants UID et GID

| Plage UID | Type | Exemples |
|-----------|------|----------|
| `0` | Root — super-administrateur | `root` |
| `1` à `999` | Utilisateurs système (services) | `www-data` (33), `docker` |
| `1000+` | Utilisateurs humains | `slimane` (1000), `alice` (1001) |

### `/etc/passwd` — liste des utilisateurs

```bash
cat /etc/passwd                 # Afficher tous les utilisateurs
grep slimane /etc/passwd        # Filtrer l'utilisateur slimane
getent passwd slimane           # Autre méthode d'interrogation
```

**Format d'une ligne (7 champs) :**

```text
slimane:x:1000:1000:Slimane B.:/home/slimane:/bin/bash
```

| Champ | Signification |
|-------|---------------|
| 1. `slimane` | Nom d'utilisateur (login) |
| 2. `x` | Mot de passe (stocké dans /etc/shadow, jamais ici) |
| 3. `1000` | UID |
| 4. `1000` | GID du groupe principal |
| 5. `Slimane B.` | Commentaire (nom complet, description) |
| 6. `/home/slimane` | Répertoire personnel (home) |
| 7. `/bin/bash` | Shell par défaut |

### Gérer les utilisateurs et groupes

```bash
# Créer un utilisateur avec home et bash
sudo useradd -m -s /bin/bash slimane

# Ajouter à un groupe secondaire (-aG)
sudo usermod -aG docker slimane
sudo usermod -aG sudo slimane

# Supprimer un utilisateur et son dossier home
sudo userdel -r slimane

# Gérer les groupes
sudo groupadd dev-team
sudo gpasswd -a slimane dev-team
sudo gpasswd -d slimane dev-team
```

---

## 7. Permissions & chmod

### Lire les permissions

```plaintext
- | rwx | r-x | ---
│    │     │     └─ Others  : tous les autres utilisateurs du système
│    │     └─────── Group   : membres du groupe propriétaire
│    └───────────── User    : propriétaire du fichier (owner)
└────────────────── Type    : - fichier  |  d dossier  |  l lien symbolique
```

### Méthode octale (numérique)

```plaintext
r = 4   w = 2   x = 1   - = 0
```

```bash
chmod 755 script.sh          # rwxr-xr-x : proprio=tout, groupe+autres=lecture+exec
chmod 644 document.txt       # rw-r--r-- : proprio=lect+écriture, autres=lecture seule
chmod 700 dossier-prive/     # rwx------ : proprio=tout, personne d'autre
chmod 600 ~/.ssh/id_ed25519  # rw------- : clé privée SSH (obligatoire)
```

### Correspondances fréquentes

| Octal | Permissions | Usage typique |
|-------|-------------|---------------|
| `777` | `rwxrwxrwx` | ⚠️ Tout le monde fait tout — dangereux |
| `755` | `rwxr-xr-x` | Scripts, binaires, dossiers publics |
| `644` | `rw-r--r--` | Fichiers de documents (lecture publique) |
| `700` | `rwx------` | Dossiers privés |
| `600` | `rw-------` | Clés privées SSH, mots de passe, secrets |

---

## 8. Permissions Unix : chown, chgrp

```bash
sudo chown ali fichier.txt             # Changer le propriétaire
sudo chown ali:dev-team fichier.txt    # Changer propriétaire ET groupe
sudo chown -R ali:dev-team dossier/    # Appliquer récursivement
sudo chgrp dev-team fichier.txt        # Changer uniquement le groupe
```

---

## 9. Permissions avancées : ACL & sudoers

### 9.1 ACL — Access Control Lists

```bash
# Vérifier et lire les ACL
getfacl fichier.txt

# Donner la lecture à alice sur rapport.pdf
setfacl -m u:alice:r-- rapport.pdf

# Donner lecture+écriture au groupe comptabilite
setfacl -m g:comptabilite:rw- rapport.pdf

# Supprimer l'ACL d'alice
setfacl -x u:alice rapport.pdf

# Supprimer TOUTES les ACL
setfacl -b rapport.pdf

# Définir une ACL par défaut sur un dossier (héritage)
setfacl -d -m u:alice:rw- MonDossier/
```

### 9.2 Le fichier sudoers & visudo

```bash
sudo visudo                              # Modifier /etc/sudoers de façon sécurisée
sudo visudo -f /etc/sudoers.d/devops    # Fichier séparé (bonne pratique)
```

### Exercice — Utilisateur devops avec sudo restreint

```text
# Contenu du fichier /etc/sudoers.d/devops-restricted
Cmnd_Alias DEVOPS_PAQUETS   = /usr/bin/apt update, /usr/bin/apt upgrade, /usr/bin/apt list
Cmnd_Alias DEVOPS_SERVICES  = /usr/bin/systemctl start *, /usr/bin/systemctl stop *, /usr/bin/systemctl restart *, /usr/bin/systemctl status *
Cmnd_Alias DEVOPS_LOGS      = /usr/bin/journalctl
Cmnd_Alias DEVOPS_INTERDIT  = /usr/sbin/visudo, /bin/su, /usr/bin/sudo, /bin/bash, /bin/sh

devops ALL=(ALL) NOPASSWD: DEVOPS_PAQUETS, DEVOPS_SERVICES, DEVOPS_LOGS
devops ALL=(ALL) !DEVOPS_INTERDIT
```

```bash
# Sécurisation du fichier sudoers restreint
sudo chmod 440 /etc/sudoers.d/devops-restricted
sudo visudo -c
```

**Explication de la syntaxe :**

| Élément | Signification |
|---------|---------------|
| `devops` | L'utilisateur concerné |
| `ALL` | Depuis tous les hôtes |
| `(ALL)` | Peut agir en tant que n'importe quel utilisateur |
| `NOPASSWD:` | Ne demande pas de mot de passe |
| `!DEVOPS_INTERDIT` | Négation : interdiction explicite de ces commandes |

---

## 10. Commandes clés apprises

```bash
# Terminal & Navigation
date; cal; clear; tty; pwd; ls -lah; cd -; tree

# Recherche & Inspection
find . -name "*.conf"; locate -i rapport; sudo updatedb; which; whereis; grep -rn "error"

# Manipulation & Permissions
touch f{1..10}; mkdir -p; cp -rv; mv; rm -rf; chmod 755; chmod 600; chown -R user:group

# ACL & Sudoers
getfacl; setfacl -m u:user:rw; visudo; visudo -c
```

---

## 11. Difficultés rencontrées & solutions

| Difficulté rencontrée | Solution appliquée |
|----------------------|--------------------|
| `useradd` ne crée pas `/home` automatiquement | Toujours ajouter l'option `-m` à `useradd` |
| `usermod -G` retire tous les groupes existants | Toujours utiliser `-aG` (Append + Group) jamais `-G` seul |
| `locate` ne trouve pas un fichier récent | Lancer `sudo updatedb` pour mettre à jour l'index |
| `chmod 7 fichier` donne les droits aux Others | `7` seul équivaut à `007` — toujours écrire les 3 chiffres |

---

## Fiche mémo — Raccourcis & bonnes pratiques

| Raccourci | Action |
|-----------|--------|
| `Tab` | Complétion automatique (chemin, commande) |
| `↑` / `↓` | Historique des commandes précédentes |
| `Ctrl + R` | Rechercher dans l'historique |
| `!!` | Répéter la dernière commande (souvent avec `sudo !!`) |

| Bonne pratique | Raison |
|----------------|--------|
| Toujours `visudo` pour sudoers | Vérification de syntaxe + verrouillage anti corruption |
| `chmod 440` sur les fichiers sudoers | Lecture root uniquement |
| `chmod 600` sur les clés SSH | OpenSSH refuse les permissions trop ouvertes |
| `-aG` et non `-G` pour les groupes | Évite de perdre l'appartenance aux groupes existants |

---

*Document généré pour la Phase 1 — Administration Linux & Système*
