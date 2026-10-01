# Semaine 01 — Linux : Fondations, FHS, Navigation & Gestion des identités

> **Phase 1 — Administration Linux & Système**  
> Rythme : 3 soirs × 45 min · Statut : ✅ Terminé

---

## Objectif de la semaine

Maîtriser les bases indispensables de l'environnement Linux : l'historique du système, la structure du système de fichiers (FHS), la navigation en ligne de commande, la manipulation de fichiers et la gestion complète des utilisateurs et des groupes.

---

## Sommaire

1. [Histoire & distributions](#1-histoire--distributions)
2. [Terminal, Shell & raccourcis](#2-terminal-shell--raccourcis)
3. [Système de fichiers FHS](#3-système-de-fichiers-fhs)
4. [Navigation & recherche](#4-navigation--recherche)
5. [Manipulation de fichiers](#5-manipulation-de-fichiers)
6. [Utilisateurs & groupes](#6-utilisateurs--groupes)
7. [Permissions & chmod](#7-permissions--chmod)
8. [Commandes clés apprises](#8-commandes-clés-apprises)
9. [Livrables & preuves](#9-livrables--preuves)
10. [Difficultés rencontrées & solutions](#10-difficultés-rencontrées--solutions)

---

## 1. Histoire & distributions

### Ligne de temps

```
1969  Multics (General Electric + Bell Labs + MIT)
        └─> Bell Labs abandonne et crée Unix (écrit en C)

1983  Richard Stallman lance le projet GNU (GNU's Not Unix)
        └─> GNU fournit les outils : compilateur, shell, éditeur...
        └─> Kernel GNU Hurd : trop instable pour la production

1991  Linus Torvalds publie le kernel Linux
        └─> Fusion GNU + Linux Kernel = GNU/Linux
              (souvent appelé simplement "Linux")
```

> Le nom complet et correct est **GNU/Linux**.  
> "Linux" désigne uniquement le noyau (kernel), pas le système complet.

### Les deux familles de distributions

| Famille | Distribution mère | Dérivées notables |
|---|---|---|
| **Debian** | Debian (1993) | Ubuntu, Lubuntu, Linux Mint |
| **Red Hat** | Red Hat (1994) | Fedora, RHEL, Rocky Linux, CentOS |

---

## 2. Terminal, Shell & raccourcis

### Concepts clés

| Terme | Définition |
|---|---|
| **Kernel** | Noyau du système : gère le matériel et les ressources |
| **Shell** | Interface entre l'utilisateur et le kernel |
| **Terminal** | Émulateur de shell (interface graphique vers le shell) |
| **Bash** | *Bourne Again Shell* — version améliorée du shell Unix original |
| **TTY** | *TeleTYpewriter* — terminal virtuel (`tty1` à `tty6`) |

### Anatomie du prompt

```
[slimane @ debian ~ $]
  │        │       │  └─ $ = utilisateur normal  |  # = root (admin)
  │        │       └──── ~ = répertoire courant (home par défaut)
  │        └──────────── nom de la machine (hostname)
  └─────────────────────── nom de l'utilisateur connecté
```

### Raccourcis clavier essentiels

| Raccourci | Action |
|---|---|
| `Ctrl + A` | Déplacer le curseur au **début** de la ligne |
| `Ctrl + E` | Déplacer le curseur à la **fin** de la ligne |
| `Ctrl + U` | Effacer toute la ligne avant le curseur |
| `Ctrl + W` | Effacer le **mot** précédent le curseur |
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

> **FHS = Filesystem Hierarchy Standard**  
> Tout part d'un seul point de départ : `/` (la racine).  
> Contrairement à Windows (`C:\`), Linux n'a qu'un seul arbre de fichiers.

```
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

> **`/proc` et `/sys` n'existent pas sur le disque.**  
> Ils sont générés dynamiquement par le kernel en mémoire vive.

| Linux | Windows | Note |
|---|---|---|
| `/home/slimane/documents` | `C:\Users\slimane\Documents` | Séparateur `/` vs `\` |
| `/etc/hostname` | Registre Windows | Simples fichiers texte lisibles |
| `/dev/sdb1` | `D:` | Les périphériques sont des fichiers |

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

> **Chemin absolu** : part toujours de `/` → `cd /home/slimane/Desktop`  
> **Chemin relatif** : part de l'endroit où on est → `cd Desktop`

### Lire une ligne `ls -l`

```
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

**Premier caractère — type de l'objet :**

| Caractère | Signification |
|---|---|
| `-` | Fichier standard (texte, script, image...) |
| `d` | Répertoire / Dossier (Directory) |
| `l` | Lien symbolique (raccourci vers un autre fichier) |

### Rechercher des fichiers avec `find`

> `find` scanne le disque **en temps réel** — résultats toujours à jour.

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

> `locate` cherche dans une **base de données indexée** — ultra rapide mais pas toujours à jour.

```bash
locate nginx.conf          # Tous les chemins contenant "nginx.conf"
locate backup              # Tout ce qui contient "backup" dans le chemin
locate -i rapport          # Insensible à la casse
locate -c rapport          # Afficher uniquement le nombre de résultats
locate -l 10 rapport       # Limiter aux 10 premiers résultats
locate -e rapport          # Vérifier que le fichier existe vraiment sur le disque
sudo updatedb              # Mettre à jour la base de données de locate
```

| Critère | `find` | `locate` |
|---|---|---|
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

| Commande | Périmètre | Ce qu'elle retourne |
|---|---|---|
| `which` | Variable `$PATH` uniquement | Premier exécutable trouvé |
| `whereis` | Dossiers système standards | Exécutable + manuel + sources |
| `locate` | Tout le système (base indexée) | Tout fichier contenant le mot-clé |

### Chercher dans le contenu avec `grep`

> `grep` cherche dans le **contenu** des fichiers, pas dans leurs noms.

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

> **Convention Linux** : nommer les fichiers **en minuscules**, sans espaces.  
> Utiliser `_` ou `-` comme séparateurs → `mon_script.sh`, `rapport-2024.pdf`

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

**Navigation dans `less` :**

| Touche | Action |
|---|---|
| `↑` / `↓` | Monter / descendre d'une ligne |
| `Page Up` / `Page Down` | Page précédente / suivante |
| `G` (majuscule) | Aller à la fin du fichier |
| `g` (minuscule) | Retourner au début |
| `/mot` + `Entrée` | Chercher un mot |
| `n` | Occurrence suivante |
| `q` | Quitter |

### Copier, déplacer, renommer, supprimer

```bash
# Copier (cp)
cp rapport.pdf /home/slimane/                    # Copier vers un dossier (même nom)
cp rapport.pdf /home/slimane/rapport_v2.pdf      # Copier avec un nouveau nom
cp -r MonDossier/ /var/backup/                   # Copier un dossier et son contenu
cp -rv /media/* /var/backup/                     # Copier avec affichage de l'avancement
cp -r f* d* project/                             # Copier tous les f* et d* dans project/

# Déplacer / Renommer (mv)
mv rapport.pdf /home/slimane/                    # Déplacer (même nom)
mv rapport.pdf /home/slimane/newname.pdf         # Déplacer avec renommage
mv file1 file2                                   # Renommer dans le même dossier
mv dir1 dir2                                     # Renommer un dossier
mv f* d* project/                                # Déplacer plusieurs éléments

# Supprimer (rm)
rm fichier.txt                                   # Supprimer un fichier
rm -i fichier.txt                                # Demander confirmation avant de supprimer
rm -r MonDossier/                                # Supprimer un dossier et son contenu
rm -rf MonDossier/                               # Forcer la suppression sans confirmation
```

> ⚠️ **`rm -rf` est définitif et irréversible.** Il n'y a pas de corbeille en CLI.  
> Toujours vérifier le chemin deux fois avant d'exécuter cette commande.

---

## 6. Utilisateurs & groupes

### Les identifiants UID et GID

| Plage UID | Type | Exemples |
|---|---|---|
| `0` | **Root** — super-administrateur | `root` |
| `1 à 999` | **Utilisateurs système** (services) | `www-data` (33), `docker` |
| `1000+` | **Utilisateurs humains** | `slimane` (1000), `alice` (1001) |

### Les fichiers de base de données

#### `/etc/passwd` — liste des utilisateurs

```bash
cat /etc/passwd                 # Afficher tous les utilisateurs
grep slimane /etc/passwd        # Filtrer l'utilisateur slimane
getent passwd slimane           # Autre méthode d'interrogation
```

Format d'une ligne (7 champs séparés par `:`) :

```
slimane : x    : 1000 : 1000 : Slimane B. : /home/slimane : /bin/bash
   │       │      │       │        │             │               │
   │       │      │       │        │             │               └─ Shell de connexion
   │       │      │       │        │             └──── Répertoire personnel (home)
   │       │      │       │        └────────────────── Commentaire (GECOS)
   │       │      │       └─────────────────────────── GID du groupe principal
   │       │      └─────────────────────────────────── UID de l'utilisateur
   │       └────────────────────────────────────────── Mot de passe → stocké dans /etc/shadow
   └────────────────────────────────────────────────── Nom d'utilisateur (login)
```

> `x` dans le champ mot de passe = le hash est sécurisé dans `/etc/shadow`.  
> Un utilisateur avec `/usr/sbin/nologin` comme shell ne peut pas se connecter interactivement.

#### `/etc/shadow` — mots de passe chiffrés (root uniquement)

```
slimane:$6$rounds=40000$xyz...:19500:0:99999:7:::
```

Contient le hash (SHA-512 ou yescrypt), la date du dernier changement, et les règles d'expiration du mot de passe.

#### `/etc/group` — liste des groupes

```
sudo:x:27:slimane,alice
  │    │   │   └─ Membres du groupe (groupes secondaires)
  │    │   └───── GID du groupe
  │    └────────── Mot de passe groupe (rarement utilisé)
  └─────────────── Nom du groupe
```

### Groupe principal vs groupes secondaires

| Type | Rôle | Effet concret |
|---|---|---|
| **Principal** | Attribué à la création de l'utilisateur | Les nouveaux fichiers appartiennent automatiquement à ce groupe |
| **Secondaires** | Permissions supplémentaires | Ex : `sudo` → peut exécuter des commandes root ; `docker` → peut lancer des conteneurs |

### Inspecter les utilisateurs et groupes

```bash
id                          # UID, GID et tous les groupes de l'utilisateur courant
id slimane                  # Infos complètes d'un utilisateur spécifique
whoami                      # Nom de l'utilisateur actuellement connecté
groups                      # Tous les groupes de l'utilisateur courant
groups slimane              # Groupes d'un autre utilisateur
```

### Changer d'utilisateur

```bash
su root                     # Basculer en root (reste dans le dossier courant)
su -                        # Basculer en root + ouvrir son environnement complet (/root)
su slimane                  # Basculer vers slimane (reste dans le dossier courant)
su - slimane                # Basculer vers slimane + aller dans /home/slimane
sudo commande               # Exécuter UNE commande en root (avec son propre mot de passe)
sudo -i                     # Ouvrir un shell root complet (utile si le compte root est désactivé)
exit                        # Fermer la session courante et revenir à la précédente
```

> **`su` vs `sudo`** :
> - `su` → tu te **connectes en root** (besoin du mot de passe de root)
> - `sudo` → tu **restes ton utilisateur** et exécutes une commande avec les droits root (besoin de ton propre mot de passe + appartenir au groupe `sudo`)

### Gérer les utilisateurs

```bash
# Créer un utilisateur
sudo useradd -m -s /bin/bash slimane                      # Créer avec home + bash
sudo useradd -m -s /bin/bash -c "Slimane B." slimane      # Avec commentaire (GECOS)

# Modifier un utilisateur
sudo usermod -aG docker slimane      # Ajouter au groupe secondaire docker
sudo usermod -aG sudo slimane        # Ajouter aux sudoers
sudo usermod -l newname slimane      # Renommer le login
sudo usermod -L slimane              # Verrouiller le compte (ajoute ! dans shadow)
sudo usermod -U slimane              # Déverrouiller le compte

# Supprimer un utilisateur
sudo userdel slimane                 # Supprimer l'utilisateur (garde /home)
sudo userdel -r slimane              # Supprimer l'utilisateur ET son /home

# Gérer le mot de passe
sudo passwd slimane                  # Changer le mot de passe de slimane
sudo passwd -e slimane               # Forcer le changement au prochain login
sudo passwd -l slimane               # Verrouiller le compte
sudo passwd -u slimane               # Déverrouiller le compte
```

> ⚠️ **`usermod -aG` : ne jamais oublier le `-a` (Append).**  
> Sans `-a`, l'utilisateur est retiré de **tous** ses autres groupes secondaires existants.

### Gérer les groupes

```bash
# Créer un groupe
sudo groupadd dev-team                  # Créer un groupe standard
sudo groupadd -g 1500 dev-team          # Avec un GID spécifique
sudo groupadd -r docker                 # Groupe système (GID < 1000)

# Modifier un groupe
sudo groupmod -n devs dev-team          # Renommer dev-team en devs
sudo groupmod -g 1600 devs              # Changer le GID du groupe

# Supprimer un groupe
sudo groupdel devs                      # Impossible si groupe principal d'un utilisateur

# Gérer les membres du groupe
sudo gpasswd -a slimane dev-team        # Ajouter slimane au groupe dev-team
sudo gpasswd -d slimane dev-team        # Retirer slimane du groupe dev-team
sudo gpasswd -M slimane,alice dev-team  # Remplacer toute la liste de membres
sudo gpasswd -A slimane dev-team        # Désigner slimane comme admin du groupe
```

---

## 7. Permissions & chmod

### Lire les permissions

```
- | rwx | r-x | ---
│    │     │     └─ Others  : tous les autres utilisateurs du système
│    │     └─────── Group   : membres du groupe propriétaire
│    └───────────── User    : propriétaire du fichier (owner)
└────────────────── Type    : - fichier  |  d dossier  |  l lien symbolique
```

**Règle de priorité** : `User` override `Group` override `Others`.  
Si tu es le propriétaire, seuls tes droits User s'appliquent, peu importe le groupe.

### Signification de r, w, x

| Droit | Valeur | Sur un fichier | Sur un dossier |
|---|---|---|---|
| `r` (Read) | 4 | Lire le contenu (`cat`, `less`) | Lister les fichiers (`ls`) |
| `w` (Write) | 2 | Modifier / vider le fichier | Créer/supprimer des fichiers dedans |
| `x` (eXecute) | 1 | Exécuter le fichier (`./script.sh`) | Entrer dans le dossier (`cd`) |
| `-` (aucun) | 0 | Droit refusé | Droit refusé |

### Méthode symbolique

```
chmod  [qui]  [opération]  [droit]  fichier
         │         │           │
       u/g/o/a   +/-/=       r/w/x
```

```bash
chmod u+x script.sh              # Ajouter l'exécution pour le propriétaire
chmod go-w document.txt          # Retirer l'écriture pour groupe et autres
chmod g=r rapport.pdf            # Forcer le groupe à avoir uniquement la lecture
chmod u=rwx,go=r fichier.txt     # Définir exactement : user=tout, group+others=lecture
chmod -R u=rwx,go=r MonDossier/  # Appliquer récursivement dans tout le dossier
```

### Méthode octale (numérique)

```
r = 4   w = 2   x = 1   - = 0

rwx = 4+2+1 = 7
rw- = 4+2+0 = 6
r-x = 4+0+1 = 5
r-- = 4+0+0 = 4
--- = 0+0+0 = 0
```

```bash
chmod 755 script.sh          # rwxr-xr-x : proprio=tout, groupe+autres=lecture+exec
chmod 644 document.txt       # rw-r--r-- : proprio=lect+écriture, autres=lecture seule
chmod 700 dossier-prive/     # rwx------ : proprio=tout, personne d'autre n'a accès
chmod 600 ~/.ssh/id_ed25519  # rw------- : clé privée SSH (obligatoire pour SSH)
chmod -R 755 MonDossier/     # Appliquer récursivement à tout le dossier
```

### Valeurs de référence

| Valeur | Permissions | Usage typique |
|---|---|---|
| `755` | `rwxr-xr-x` | Scripts exécutables, dossiers publics |
| `644` | `rw-r--r--` | Fichiers texte, fichiers de configuration |
| `700` | `rwx------` | Dossiers privés, scripts sensibles |
| `600` | `rw-------` | Clés SSH, fichiers de secrets |
| `777` | `rwxrwxrwx` | ⚠️ À éviter absolument en production |

### Changer le propriétaire

```bash
sudo chown slimane fichier.txt             # Changer le propriétaire
sudo chown slimane:dev-team fichier.txt    # Changer propriétaire ET groupe
sudo chown -R slimane:dev-team dossier/   # Appliquer récursivement
sudo chgrp dev-team fichier.txt            # Changer uniquement le groupe
```

---

## 8. Commandes clés apprises

```bash
# Terminal & date
date    date +%r    cal    clear    tty    sleep    pwd

# Navigation
ls -lah    cd    cd -    cd ..    tree

# Recherche
find . -name    find /etc -name "*.conf"    find -type f    find -size +10M
locate    locate -c    locate -e    sudo updatedb
which    whereis    grep -i    grep -r    grep -v    grep -n

# Manipulation de fichiers
touch    touch f{1..10}    cat    nano    head -n    tail -f    less
mkdir -p    cp -r    cp -rv    mv    rm -rf

# Utilisateurs & groupes
id    whoami    groups    su -    sudo    sudo -i
useradd -m -s /bin/bash    usermod -aG    userdel -r
passwd    passwd -e    passwd -l
groupadd    groupadd -g    groupmod -n    groupdel
gpasswd -a    gpasswd -d    gpasswd -M

# Permissions
chmod 755    chmod 644    chmod 700    chmod u+x    chmod -R
chown slimane:groupe    chgrp
```

---

## 9. Livrables & preuves

- [ ] Capture d'écran de la VM Ubuntu/Debian Server démarrée en CLI
- [ ] Résultat de `ls -lah /etc/` sur la VM
- [ ] Résultat de `cat /etc/passwd | grep slimane` avec les 7 champs identifiés
- [ ] Résultat de `id slimane` après ajout à plusieurs groupes secondaires
- [ ] Démonstration de `chmod` : avant/après `ls -l` sur un fichier de test
- [ ] Arborescence `tree /home/slimane/` après création de dossiers de lab

---

## 10-1. Difficultés rencontrées & solutions

| Difficulté rencontrée | Solution appliquée |
|---|---|
| `useradd` ne crée pas `/home` automatiquement | Toujours ajouter l'option `-m` à `useradd` |
| `usermod -G` retire tous les groupes existants | Toujours utiliser `-aG` (Append + Group) jamais `-G` seul |
| `rm -r` demande confirmation pour chaque fichier | Utiliser `-rf` pour forcer — vérifier le chemin avant |
| `locate` ne trouve pas un fichier créé récemment | Lancer `sudo updatedb` pour mettre à jour l'index |
| `chmod 7 fichier` donne tous les droits aux Others | `7` seul = `007` — toujours écrire les 3 chiffres |
| Confusion entre chemin absolu et relatif | Absolu commence par `/`, relatif part du dossier courant |

---
## 10-2. Permissions Unix : chown, chgrp

## `chown` — changer le propriétaire

`chown` signifie **change owner**. Il permet de changer le propriétaire, le groupe, ou les deux.

| Commande | Effet |
|---|---|
| `sudo chown ali fichier.txt` | Change le propriétaire → `ali`.<br>Avant : `-rw-r--r-- 1 slimane dev-team 120 fichier.txt`<br>Après : `-rw-r--r-- 1 ali dev-team 120 fichier.txt` |
| `sudo chown ali:dev-team fichier.txt` | Change le propriétaire **et** le groupe |
| `sudo chown -R ali:dev-team dossier/` | Change le propriétaire/groupe d'un dossier et de tout son contenu.<br>`-R` = récursif (dossier + fichiers + sous-dossiers) |

## `chgrp` — changer le groupe propriétaire

`chgrp` signifie **change group**. Il change uniquement le groupe propriétaire.

| Commande | Effet |
|---|---|
| `sudo chgrp dev-team fichier.txt` | Le propriétaire reste inchangé, le groupe devient `dev-team` |
| `sudo chgrp -R dev-team dossier/` | Applique le changement à un dossier et tout son contenu |
---

## 11. Permissions avancées : ACL & sudoers

### 11.1 Rappel chmod — ce qu'il ne peut pas faire

`chmod` fonctionne sur 3 blocs fixes : **User / Group / Others**.  
Problème : que faire si tu veux donner accès à un utilisateur précis qui n'est ni le propriétaire ni dans le groupe ?

```
Exemple concret :
  -rw-r----- slimane dev-team rapport.pdf

  → alice (hors dev-team) doit pouvoir LIRE ce fichier.
  → bob (hors dev-team) ne doit PAS y accéder.

  Avec chmod seul : impossible de distinguer alice et bob.
  Solution : les ACL (Access Control Lists).
```

---

### 11.2 ACL — Access Control Lists

> Les ACL permettent de définir des permissions **par utilisateur ou par groupe spécifique**,
> en plus du système chmod classique.
> Elles sont stockées dans les métadonnées du système de fichiers (ext4, xfs...).

#### Vérifier que les ACL sont supportées

```bash
# Vérifier que le système de fichiers est monté avec les ACL
mount | grep acl
# ou
tune2fs -l /dev/sda1 | grep "Default mount"

# Installer les outils si nécessaire
sudo apt install acl
```

#### `getfacl` — lire les ACL d'un fichier

```bash
getfacl fichier.txt
```

Exemple de sortie :

```
# file: fichier.txt
# owner: slimane
# group: dev-team
user::rw-          ← droits du propriétaire (slimane)
user:alice:r--     ← ACL spécifique : alice peut lire
user:bob:---       ← ACL spécifique : bob n'a aucun droit
group::r--         ← droits du groupe dev-team
mask::r--          ← masque maximum autorisé pour les ACL
other::---         ← droits des autres
```

> La ligne `mask` est le **plafond maximum** des droits ACL.
> Si mask = `r--`, une ACL avec `rwx` sera réduite à `r--` en pratique.

#### `setfacl` — définir des ACL

```bash
# Syntaxe générale
setfacl [OPTIONS] [u:user:perms | g:group:perms] fichier

# Donner la lecture à alice sur rapport.pdf
setfacl -m u:alice:r-- rapport.pdf

# Donner lecture+écriture au groupe comptabilite
setfacl -m g:comptabilite:rw- rapport.pdf

# Supprimer l'ACL d'alice
setfacl -x u:alice rapport.pdf

# Supprimer TOUTES les ACL du fichier (retour à chmod pur)
setfacl -b rapport.pdf

# Appliquer récursivement à un dossier et tout son contenu
setfacl -R -m u:alice:rwx MonDossier/

# Définir une ACL par défaut (héritée par les nouveaux fichiers créés dans le dossier)
setfacl -d -m u:alice:rw- MonDossier/
```

#### Vérifier qu'une ACL est active

```bash
ls -l rapport.pdf
# -rw-r-----+ slimane dev-team rapport.pdf
#           ^
#           └─ Le "+" indique qu'une ACL est présente
```

#### Tableau de référence `setfacl`

| Option | Signification | Exemple |
|---|---|---|
| `-m` | Modifier / ajouter une ACL | `setfacl -m u:alice:rw- f.txt` |
| `-x` | Supprimer une ACL spécifique | `setfacl -x u:alice f.txt` |
| `-b` | Supprimer toutes les ACL | `setfacl -b f.txt` |
| `-R` | Appliquer récursivement | `setfacl -R -m u:alice:r-- dir/` |
| `-d` | ACL par défaut (héritage) | `setfacl -d -m u:alice:rw- dir/` |
| `u:user:perms` | ACL pour un utilisateur | `u:alice:rw-` |
| `g:group:perms` | ACL pour un groupe | `g:devs:r--` |

#### chmod vs ACL — quand utiliser quoi ?

| Situation | Outil recommandé |
|---|---|
| Permissions standard (proprio, groupe, autres) | `chmod` |
| Donner accès à **un utilisateur précis** hors groupe | `setfacl` |
| Donner accès à **un groupe spécifique** en plus | `setfacl` |
| Héritage automatique sur un dossier partagé | `setfacl -d` |
| Serveur simple avec peu d'utilisateurs | `chmod` suffit |
| Environnement multi-équipes (dev, ops, compta...) | `setfacl` |

---

### 11.3 Le fichier sudoers & visudo

#### Pourquoi sudoers ?

`sudo` permet à un utilisateur normal d'exécuter des commandes avec les droits root,
**sans connaître le mot de passe root**.
Le fichier `/etc/sudoers` définit **qui** peut faire **quoi** avec `sudo`.

> ⚠️ **Ne jamais éditer `/etc/sudoers` directement avec nano ou vim.**
> Toujours utiliser `visudo` qui vérifie la syntaxe avant de sauvegarder.
> Une erreur dans sudoers peut rendre `sudo` inutilisable sur tout le système.

```bash
sudo visudo              # Ouvre /etc/sudoers dans l'éditeur par défaut (nano ou vi)
sudo visudo -f /etc/sudoers.d/devops    # Créer un fichier de règles séparé (bonne pratique)
```

#### Anatomie d'une règle sudoers

```
slimane  ALL=(ALL:ALL)  ALL
   │      │     │   │    │
   │      │     │   │    └─ Commandes autorisées (ALL = toutes)
   │      │     │   └────── Groupe cible (ALL = tous les groupes)
   │      │     └────────── Utilisateur cible (ALL = peut devenir n'importe qui)
   │      └──────────────── Hôte (ALL = tous les serveurs)
   └─────────────────────── Qui est concerné par cette règle
```

#### Les directives essentielles

```bash
# 1. Accès sudo complet (équivalent root)
slimane ALL=(ALL:ALL) ALL

# 2. Accès sudo complet SANS mot de passe (NOPASSWD)
slimane ALL=(ALL) NOPASSWD: ALL
# Utile pour : scripts automatisés, pipelines CI/CD, serveurs de déploiement

# 3. Accès à des commandes spécifiques seulement
slimane ALL=(ALL) /usr/bin/apt, /usr/sbin/service, /usr/bin/systemctl

# 4. Commandes spécifiques SANS mot de passe
slimane ALL=(ALL) NOPASSWD: /usr/bin/apt update, /usr/bin/apt upgrade

# 5. Groupe entier avec accès sudo (le % indique un groupe)
%sudo   ALL=(ALL:ALL) ALL
%dev-team ALL=(ALL) /usr/bin/docker, /usr/bin/docker-compose

# 6. Interdire une commande spécifique (!) même si la règle globale l'autorise
slimane ALL=(ALL) ALL, !/usr/sbin/visudo, !/bin/su
```

#### Alias dans sudoers (pour factoriser les règles)

```bash
# Regrouper des commandes sous un alias
Cmnd_Alias RESEAU = /usr/sbin/iptables, /usr/sbin/ufw, /usr/bin/ss
Cmnd_Alias SERVICES = /usr/bin/systemctl start *, /usr/bin/systemctl stop *
Cmnd_Alias PAQUETS = /usr/bin/apt update, /usr/bin/apt upgrade

# Regrouper des utilisateurs
User_Alias ADMINS = slimane, alice
User_Alias DEVS = bob, charlie

# Appliquer les alias
ADMINS ALL=(ALL) RESEAU, SERVICES
DEVS   ALL=(ALL) PAQUETS
```

#### Bonne pratique : fichiers dans `/etc/sudoers.d/`

```bash
# Plutôt que modifier /etc/sudoers directement,
# créer un fichier séparé par utilisateur ou équipe
sudo visudo -f /etc/sudoers.d/devops-user

# Contenu du fichier
devops ALL=(ALL) NOPASSWD: /usr/bin/apt update, /usr/bin/apt upgrade, \
                            /usr/bin/systemctl restart nginx, \
                            /usr/bin/systemctl status *

# Sécuriser le fichier (obligatoire, sudo le refuse sinon)
sudo chmod 440 /etc/sudoers.d/devops-user
```

> Les fichiers dans `/etc/sudoers.d/` sont inclus automatiquement
> grâce à la directive `#includedir /etc/sudoers.d` dans `/etc/sudoers`.

---

### 11.4 Exercice — Utilisateur `devops` avec sudo restreint

#### Énoncé

Créer un utilisateur `devops` qui peut exécuter **uniquement** :
- `apt update` et `apt upgrade` (maintenance des paquets)
- `systemctl` avec les actions `start`, `stop`, `restart`, `status` (gestion des services)
- `journalctl` (lecture des logs)

Il **ne doit pas** pouvoir :
- Devenir root (`su`, `sudo bash`, `sudo -i`)
- Modifier les fichiers sudoers (`visudo`)
- Utiliser d'autres commandes root

#### Solution complète

**Étape 1 — Créer l'utilisateur devops**

```bash
sudo useradd -m -s /bin/bash -c "Utilisateur DevOps restreint" devops
sudo passwd devops
# Entrer un mot de passe sécurisé
```

**Étape 2 — Vérifier la création**

```bash
id devops
# uid=1001(devops) gid=1001(devops) groups=1001(devops)

getent passwd devops
# devops:x:1001:1001:Utilisateur DevOps restreint:/home/devops:/bin/bash

ls -la /home/devops/
# drwxr-xr-x 2 devops devops 4096 ...
```

**Étape 3 — Créer le fichier sudoers dédié**

```bash
sudo visudo -f /etc/sudoers.d/devops-restricted
```

Contenu exact à saisir :

```sudoers
# Alias des commandes autorisées pour l'utilisateur devops
Cmnd_Alias DEVOPS_PAQUETS   = /usr/bin/apt update, \
                               /usr/bin/apt upgrade, \
                               /usr/bin/apt list

Cmnd_Alias DEVOPS_SERVICES  = /usr/bin/systemctl start *, \
                               /usr/bin/systemctl stop *, \
                               /usr/bin/systemctl restart *, \
                               /usr/bin/systemctl status *, \
                               /usr/bin/systemctl is-active *

Cmnd_Alias DEVOPS_LOGS      = /usr/bin/journalctl

# Commandes explicitement interdites (même si incluses dans les wildcards)
Cmnd_Alias DEVOPS_INTERDIT  = /usr/sbin/visudo, \
                               /bin/su, \
                               /usr/bin/sudo, \
                               /bin/bash, \
                               /bin/sh

# Règle finale : devops peut utiliser les commandes autorisées sans mot de passe
# et est explicitement bloqué sur les commandes interdites
devops ALL=(ALL) NOPASSWD: DEVOPS_PAQUETS, DEVOPS_SERVICES, DEVOPS_LOGS
devops ALL=(ALL) !DEVOPS_INTERDIT
```

**Étape 4 — Sécuriser le fichier**

```bash
sudo chmod 440 /etc/sudoers.d/devops-restricted

# Vérifier la syntaxe sans risque
sudo visudo -c
# → /etc/sudoers: parsed OK
# → /etc/sudoers.d/devops-restricted: parsed OK
```

**Étape 5 — Tester les commandes autorisées**

```bash
# Basculer vers l'utilisateur devops
su - devops

# Test 1 : apt update → doit fonctionner
sudo apt update
# [sudo] password for devops: (entrer le mot de passe)
# Hit:1 http://deb.debian.org/debian bookworm InRelease
# → OK ✓

# Test 2 : systemctl status nginx → doit fonctionner
sudo systemctl status ssh
# ● ssh.service - OpenBSD Secure Shell server
# → OK ✓

# Test 3 : journalctl → doit fonctionner
sudo journalctl -n 10
# -- Logs begin at ...
# → OK ✓
```

**Étape 6 — Tester les commandes interdites**

```bash
# Test 4 : sudo bash → doit être refusé
sudo bash
# Sorry, user devops is not allowed to execute '/bin/bash' as root
# → Bloqué ✓

# Test 5 : sudo -i (shell root interactif) → doit être refusé
sudo -i
# Sorry, user devops is not allowed to execute '/usr/bin/bash' as root
# → Bloqué ✓

# Test 6 : visudo → doit être refusé
sudo visudo
# Sorry, user devops is not allowed to execute '/usr/sbin/visudo' as root
# → Bloqué ✓

# Test 7 : commande non listée → doit être refusée
sudo rm -rf /etc/
# Sorry, user devops is not allowed to execute '/bin/rm' as root
# → Bloqué ✓
```

**Étape 7 — Vérifier depuis root les règles appliquées**

```bash
# Revenir en admin
exit

# Afficher toutes les règles sudo de devops
sudo -l -U devops
```

Sortie attendue :

```
Matching Defaults entries for devops on debian:
    env_reset, mail_badpass, secure_path=...

User devops may run the following commands on debian:
    (ALL) NOPASSWD: /usr/bin/apt update, /usr/bin/apt upgrade, /usr/bin/apt list
    (ALL) NOPASSWD: /usr/bin/systemctl start *, /usr/bin/systemctl stop *, ...
    (ALL) NOPASSWD: /usr/bin/journalctl
    (ALL) !/usr/sbin/visudo, !/bin/su, !/usr/bin/sudo, !/bin/bash, !/bin/sh
```

#### Récapitulatif de l'exercice

| Commande | Résultat attendu |
|---|---|
| `sudo apt update` | ✅ Autorisé sans mot de passe |
| `sudo systemctl restart nginx` | ✅ Autorisé sans mot de passe |
| `sudo journalctl -f` | ✅ Autorisé sans mot de passe |
| `sudo bash` | ❌ Refusé |
| `sudo -i` | ❌ Refusé |
| `sudo visudo` | ❌ Refusé |
| `sudo rm -rf /` | ❌ Refusé (non listé) |


*Semaine 01 terminée · Prochaine étape → [Semaine 02 — SSH sécurisé & Bash scripting](../02-ssh-bash/README.md)*


# Semaine 02 — Processus, Surveillance système & systemd

> **Phase 1 — Administration Linux & Système**
> Rythme : 3 soirs × 45 min · Statut : ✅ Terminé

---

## Objectif de la semaine

Maîtriser la gestion des processus Linux, la surveillance des ressources système (RAM, disque, CPU) et l'administration complète des services via systemd. À la fin, tu es capable de diagnostiquer un serveur, tuer un processus bloqué, créer un service custom et analyser les logs système.

---

## Sommaire

- [Module 1 — Processus \& Surveillance](#module-1--processus--surveillance)
  - [1. Gestion des processus](#1-gestion-des-processus)
  - [2. Signaux Unix](#2-signaux-unix)
  - [3. Priorité des processus](#3-priorité-des-processus)
  - [4. nohup](#4-nohup)
  - [5. Mémoire](#5-mémoire)
  - [6. Disque \& Stockage](#6-disque--stockage)
  - [7. Variables d'environnement](#7-variables-denvironnement)
  - [8. Exercice 1 — Top 5 processus par RAM](#8-exercice-1--top-5-processus-par-ram)
- [Module 2 — systemd \& Services](#module-2--systemd--services)
  - [9. Concepts systemd](#9-concepts-systemd)
  - [10. Commandes systemctl](#10-commandes-systemctl)
  - [11. Anatomie d'un fichier .service](#11-anatomie-dun-fichier-service)
  - [12. journalctl](#12-journalctl)
  - [13. Exercice 2 — Service systemd health-check](#13-exercice-2--service-systemd-health-check)
- [Commandes clés apprises](#commandes-clés-apprises)
- [Livrables \& preuves](#livrables--preuves)
- [Difficultés rencontrées \& solutions](#difficultés-rencontrées--solutions)

---

## Module 1 — Processus & Surveillance

### 1. Gestion des processus

Un **processus** est une instance en cours d'exécution d'un programme. Chaque processus possède un identifiant unique (**PID**), un processus parent (**PPID**), un propriétaire et un état.

**États possibles d'un processus :**

| État | Lettre | Signification |
|---|---|---|
| Running | `R` | En cours d'exécution ou prêt à tourner |
| Sleeping | `S` | En attente d'un événement (ex : clavier) |
| Disk wait | `D` | Bloqué sur une opération disque (non interruptible) |
| Zombie | `Z` | Terminé mais pas encore nettoyé par son parent |
| Stopped | `T` | Mis en pause (ex : `Ctrl+Z`) |

---

#### `ps` — photographier les processus à un instant T

`ps` (**Process Status**) affiche une liste **statique** des processus actifs au moment de l'exécution.

```bash
ps                        # Processus du terminal courant uniquement
ps aux                    # Tous les processus de tous les utilisateurs
ps aux | grep nginx       # Filtrer un processus précis
ps -ef                    # Format UNIX (affiche aussi le PPID)
ps -ef --forest           # Arborescence parent → enfant
ps aux --sort=-%mem       # Trier par consommation mémoire décroissante
ps aux --sort=-%cpu       # Trier par consommation CPU décroissante
```

**Décoder une ligne `ps aux` :**

```
USER       PID  %CPU  %MEM    VSZ    RSS  TTY  STAT  START   TIME  COMMAND
slimane   1234   0.5   1.2  12345   4096  pts/0  S   10:00   0:01  nginx
```

| Colonne | Signification |
|---|---|
| `USER` | Propriétaire du processus |
| `PID` | Identifiant unique du processus |
| `%CPU` | Pourcentage CPU utilisé |
| `%MEM` | Pourcentage RAM utilisée |
| `VSZ` | Mémoire virtuelle allouée (Ko) |
| `RSS` | RAM physique réellement utilisée (Ko) |
| `STAT` | État du processus (R, S, D, Z, T) |
| `COMMAND` | Commande qui a lancé le processus |

---

#### `top` — surveillance dynamique en temps réel

`top` se rafraîchit toutes les 3 secondes et trie par consommation CPU.

```bash
top                 # Lancer top
top -u slimane      # Filtrer par utilisateur
top -p 1234         # Surveiller uniquement le PID 1234
```

**Navigation dans `top` :**

| Touche | Action |
|---|---|
| `M` | Trier par consommation **mémoire** |
| `P` | Trier par consommation **CPU** (défaut) |
| `1` | Afficher chaque cœur CPU séparément |
| `k` | Tuer un processus (demande le PID) |
| `r` | Changer la priorité (renice) |
| `q` | Quitter |
| `h` | Aide |

**Lire l'en-tête de `top` :**

```
load average: 0.15, 0.10, 0.08
```

Les 3 valeurs sont la charge moyenne sur **1 min**, **5 min**, **15 min**.
Si la charge dépasse le nombre de cœurs CPU → le serveur est surchargé.

---

#### `htop` — version améliorée et interactive

```bash
sudo apt install htop     # Installer si absent
htop                      # Lancer htop
htop -u slimane           # Filtrer par utilisateur
```

**Raccourcis dans `htop` :**

| Touche | Action |
|---|---|
| `F3` | Chercher un processus par nom |
| `F4` | Filtrer la liste |
| `F5` | Vue arborescente (parent → enfant) |
| `F6` | Choisir le critère de tri |
| `F9` | Envoyer un signal à un processus |
| `F10` | Quitter |

---

#### `pgrep` et `pkill` — cibler par nom

```bash
pgrep nginx               # Retourner le(s) PID de nginx
pgrep -l nginx            # PID + nom du processus
pgrep -u slimane          # Tous les PID des processus de slimane
pgrep -a nginx            # PID + commande complète

pkill nginx               # Envoyer SIGTERM à tous les processus nginx
pkill -9 nginx            # Envoyer SIGKILL (arrêt forcé)
pkill -u slimane          # Tuer tous les processus de l'utilisateur slimane
```

---

#### `kill` — envoyer des signaux

```bash
kill 1234                 # Envoyer SIGTERM (15) au PID 1234
kill -9 1234              # Envoyer SIGKILL (9) — arrêt forcé immédiat
kill -1 1234              # Envoyer SIGHUP (1) — rechargement de config
kill -l                   # Lister tous les signaux disponibles
```

---

### 2. Signaux Unix

Un **signal** est un message envoyé à un processus pour lui demander d'effectuer une action. C'est le seul moyen de communiquer avec un processus depuis l'extérieur.

| Signal | Numéro | Comportement |
|---|---|---|
| `SIGHUP` | 1 | Rechargement de configuration sans redémarrage |
| `SIGINT` | 2 | Interruption clavier (`Ctrl+C`) |
| `SIGTERM` | 15 | Demande d'arrêt propre (le processus peut nettoyer) |
| `SIGKILL` | 9 | Arrêt forcé immédiat et inévitable |
| `SIGSTOP` | 19 | Mise en pause (`Ctrl+Z`) |
| `SIGCONT` | 18 | Reprise après `SIGSTOP` |

**SIGTERM vs SIGKILL — la différence clé :**

```
SIGTERM (15) — La demande polie
  → Le processus REÇOIT le signal
  → Il peut fermer proprement les connexions,
    vider ses buffers, écrire dans les logs
  → Utilisé par : systemctl stop

SIGKILL (9) — La force brutale
  → Envoyé directement au kernel, pas au processus
  → Impossible à intercepter ou ignorer
  → Risque : données non sauvegardées, fichiers corrompus
  → À utiliser en dernier recours UNIQUEMENT
```

**Bonne pratique — ordre d'arrêt :**

```bash
kill 1234                 # 1. Essayer SIGTERM d'abord
sleep 5                   # 2. Attendre 5 secondes
ps aux | grep 1234        # 3. Vérifier si encore présent
kill -9 1234              # 4. Forcer seulement si nécessaire
```

**SIGHUP — rechargement sans downtime :**

```bash
kill -1 $(pgrep nginx)    # Nginx relit sa config sans couper les connexions
sudo systemctl reload nginx   # Équivalent via systemd
```

---

### 3. Priorité des processus

La **niceness** détermine la priorité d'un processus. Un processus "gentil" (valeur haute) laisse la priorité aux autres.

```
-20  →  Priorité maximale (root uniquement)
  0  →  Priorité normale (défaut)
+19  →  Priorité minimale
Plus la valeur est BASSE, plus le processus est PRIORITAIRE.
```

```bash
nice -n 15 tar -czf backup.tar.gz /home/    # Lancer avec priorité basse
nice -n 19 dd if=/dev/sda of=/dev/null      # Tâche très basse priorité

renice -n 10 -p 1234        # Changer la priorité du PID 1234
renice -n -5 -p 1234        # Augmenter la priorité (nécessite root)
renice -n 5 -u slimane      # Changer la priorité de tous les processus de slimane
```

> Utiliser `nice` pour les backups, compressions, tâches longues en arrière-plan pour ne pas impacter les services en production.

---

### 4. nohup

Par défaut, fermer un terminal envoie **SIGHUP** à tous ses processus, qui se terminent. `nohup` immunise un processus contre ce signal.

```bash
nohup ./mon-script.sh &                              # Arrière-plan, sortie → nohup.out
nohup ./mon-script.sh > /var/log/script.log 2>&1 &  # Rediriger vers un fichier de log

jobs -l                         # Vérifier les processus en arrière-plan
ps aux | grep mon-script        # Vérifier depuis n'importe où
```

---

### 5. Mémoire

#### `free -h` — vue d'ensemble de la RAM

```bash
free -h            # Affichage lisible (Mo, Go)
free -h -s 2       # Rafraîchir toutes les 2 secondes
```

**Décoder la sortie :**

```
              total    used    free   shared  buff/cache  available
Mem:          1.9Gi   891Mi   312Mi    45Mi       784Mi      896Mi
Swap:         975Mi     0Mi   975Mi
```

| Colonne | Signification |
|---|---|
| `total` | RAM totale installée |
| `used` | RAM utilisée par les programmes |
| `free` | RAM complètement libre |
| `buff/cache` | Cache disque (libérable rapidement si besoin) |
| `available` | ✅ **La vraie valeur utile** : RAM dispo pour de nouveaux programmes |

> La colonne `available` est plus fiable que `free` seul. Linux utilise agressivement le cache disque, donc `free` peut sembler faible même si tout va bien.

---

#### `vmstat` — statistiques système avancées

```bash
vmstat              # Snapshot depuis le démarrage
vmstat 2            # Rafraîchir toutes les 2 secondes
vmstat 2 5          # 5 mesures espacées de 2 secondes
```

**Colonnes clés à surveiller :**

| Colonne | Signification | Alerte si |
|---|---|---|
| `r` | Processus en attente de CPU | > nombre de cœurs |
| `b` | Processus bloqués en I/O | Régulièrement > 0 |
| `swpd` | Swap utilisé (Ko) | > 0 de façon persistante |
| `si/so` | Swap in/out par seconde | > 0 régulièrement |
| `wa` | % CPU en attente I/O | > 20% |
| `id` | % CPU inactif (idle) | < 20% = serveur surchargé |

---

#### `/proc/meminfo` — informations détaillées

```bash
cat /proc/meminfo
grep -E "MemTotal|MemFree|MemAvailable|SwapTotal|SwapFree" /proc/meminfo
```

```
MemTotal:        2035100 kB   → RAM totale
MemFree:          319488 kB   → RAM libre (sans cache)
MemAvailable:     917504 kB   → RAM réellement disponible
SwapTotal:        998396 kB   → Swap total
SwapFree:         998396 kB   → Swap libre (0 utilisé = bon signe)
```

---

### 6. Disque & Stockage

#### `df -h` — espace des partitions montées

```bash
df -h              # Toutes les partitions, format lisible
df -hT             # Avec le type de système de fichiers (ext4, tmpfs...)
df -h /home        # Uniquement la partition contenant /home
```

**Décoder `df -h` :**

```
Filesystem    Size  Used  Avail  Use%  Mounted on
/dev/sda1      20G    8G    11G   43%  /
/dev/sda2      50G   12G    36G   25%  /home
```

> Surveiller `Use%` : déclencher une alerte si > **80%**.

---

#### `du -sh` — taille d'un dossier

```bash
du -sh /var/log              # Taille totale du dossier
du -sh /home/*               # Taille de chaque répertoire utilisateur
du -h --max-depth=1 /        # Taille de chaque dossier à la racine
du -h /var | sort -rh | head -10   # Top 10 des plus gros consommateurs
```

---

#### `lsblk` — lister les périphériques de stockage

```bash
lsblk                        # Vue arborescente de tous les disques
lsblk -f                     # Avec type de FS et UUID
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT   # Colonnes personnalisées
```

```
NAME   SIZE  TYPE  MOUNTPOINT
sda     20G  disk
├─sda1  19G  part  /
└─sda2   1G  part  [SWAP]
sdb     50G  disk
└─sdb1  50G  part  /home
```

---

#### `fdisk -l` — table de partitions

```bash
sudo fdisk -l                # Toutes les partitions de tous les disques
sudo fdisk -l /dev/sdb       # Partitions d'un disque spécifique
```

---

#### `mount` et `umount`

**Monter** une partition = la rendre accessible dans l'arborescence à un **point de montage** (dossier vide).

```bash
sudo mount /dev/sdb1 /mnt/data          # Monter sdb1 dans /mnt/data
sudo mount -t ext4 /dev/sdb1 /mnt/data  # Spécifier le type de FS
sudo umount /mnt/data                   # Démonter par le point de montage
sudo umount /dev/sdb1                   # Démonter par le périphérique
mount | column -t                       # Lister tous les montages actifs
```

---

#### `/etc/fstab` — montage automatique au démarrage

`fstab` liste les partitions à monter automatiquement. C'est un fichier **critique** — une erreur peut empêcher le démarrage.

```bash
cat /etc/fstab
```

**Format d'une ligne :**

```
UUID=a1b2c3d4   /mnt/data   ext4   defaults,noatime   0   2
      │              │         │           │            │   │
      │              │         │           │            │   └─ Ordre fsck (0=aucun, 2=non-root)
      │              │         │           │            └───── Dump (0=pas de backup)
      │              │         │           └───────────────── Options de montage
      │              │         └───────────────────────────── Type de FS
      │              └─────────────────────────────────────── Point de montage
      └────────────────────────────────────────────────────── UUID du périphérique
```

**Options courantes :**

| Option | Signification |
|---|---|
| `defaults` | rw, suid, dev, exec, auto, async |
| `noatime` | Ne pas mettre à jour l'heure d'accès (améliore les perfs) |
| `ro` | Monter en lecture seule |
| `nofail` | Ne pas bloquer le démarrage si le disque est absent |

```bash
sudo blkid /dev/sdb1          # Obtenir l'UUID d'un périphérique
sudo mount -a                  # Tester fstab sans redémarrer (signale les erreurs)
```

> Toujours utiliser l'**UUID** plutôt que `/dev/sdb1` dans fstab. Le nom de périphérique peut changer après un redémarrage.

---

### 7. Variables d'environnement

Une variable d'environnement est une variable **globale** accessible par tous les processus enfants du shell.

```bash
env                           # Afficher toutes les variables
printenv                      # Équivalent
echo $HOME                    # /home/slimane
echo $USER                    # slimane
echo $PATH                    # /usr/bin:/bin:/usr/sbin:...
echo $SHELL                   # /bin/bash
echo $PWD                     # Répertoire courant
```

---

#### `export` — créer et exporter des variables

```bash
MA_VARIABLE="valeur"          # Variable locale (shell courant seulement)
export MA_VARIABLE="valeur"   # Exportée (accessible aux processus enfants)
export MON_API_KEY="abc123"
```

---

#### La variable `PATH`

`PATH` liste les dossiers où Linux cherche les exécutables quand tu tapes une commande.

```bash
echo $PATH
# /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

export PATH=$PATH:/opt/mon-outil/bin    # Ajouter un dossier au PATH (temporaire)
which python3                           # Vérifier où une commande est trouvée
```

---

#### `.bashrc` et `.bash_profile` — persistance

| Fichier | Chargé quand |
|---|---|
| `~/.bashrc` | À chaque ouverture de terminal interactif |
| `~/.bash_profile` | À chaque connexion (SSH, console) |
| `/etc/environment` | Variables globales pour tous les utilisateurs |
| `/etc/profile` | Script global à la connexion |

```bash
nano ~/.bashrc

# Ajouter à la fin du fichier :
export MON_API_KEY="abc123"
export PATH=$PATH:/opt/mon-outil/bin
alias ll='ls -lah'
alias grep='grep --color=auto'

source ~/.bashrc              # Appliquer sans fermer le terminal
```

---

### 8. Exercice 1 — Top 5 processus par RAM

**Objectif :** Afficher les 5 processus consommant le plus de RAM sur la VM.

```bash
ps aux --sort=-%mem | head -6
```

```bash
ps aux --sort=-%mem | awk 'NR<=6 {printf "%-10s %-8s %-6s %s\n", $1, $2, $4, $11}'
```

```bash
ps aux --sort=-%mem | awk 'NR>1 {print $4"% - "$11" (PID:"$2")"}' | head -5
```

**Exemple de sortie :**

```
USER       PID    %MEM  COMMAND
root       856     4.2  /usr/bin/python3
mysql      923     3.8  /usr/sbin/mysqld
www-data  1204     2.1  nginx: worker process
slimane   1456     1.8  /usr/bin/python3 monapp.py
root       312     1.2  /usr/bin/dockerd
```

---

## Module 2 — systemd & Services

### 9. Concepts systemd

#### Pourquoi systemd remplace SysVinit

| SysVinit | systemd |
|---|---|
| Démarrage **séquentiel** (un service à la fois) | Démarrage **parallèle** (tous en même temps si possible) |
| Scripts shell `/etc/init.d/` | Fichiers `.service` déclaratifs |
| Pas de gestion automatique des dépendances | Gestion fine des dépendances entre services |
| Pas de redémarrage automatique | `Restart=on-failure` intégré |
| Logs éparpillés dans `/var/log/` | Journal centralisé via `journald` |

---

#### Les Units systemd

Tout dans systemd est une **unit** :

| Extension | Type | Exemple |
|---|---|---|
| `.service` | Service système | `nginx.service` |
| `.timer` | Tâche planifiée | `backup.timer` |
| `.socket` | Socket réseau ou IPC | `ssh.socket` |
| `.mount` | Point de montage | `mnt-data.mount` |
| `.target` | Groupe de services | `multi-user.target` |

---

#### Les Targets (équivalents des runlevels)

| SysVinit Runlevel | systemd Target | Usage |
|---|---|---|
| 0 | `poweroff.target` | Extinction |
| 1 | `rescue.target` | Mode maintenance |
| 3 | `multi-user.target` | Serveur sans GUI ✅ |
| 5 | `graphical.target` | Avec interface graphique |
| 6 | `reboot.target` | Redémarrage |

```bash
systemctl get-default                          # Voir la target active
sudo systemctl set-default multi-user.target   # Changer la target par défaut
```

---

### 10. Commandes systemctl

#### Cycle de vie d'un service

```bash
sudo systemctl start nginx        # Démarrer le service
sudo systemctl stop nginx         # Arrêter proprement (SIGTERM)
sudo systemctl restart nginx      # Arrêter puis redémarrer
sudo systemctl reload nginx       # Recharger la config SANS redémarrer
```

**`restart` vs `reload` :**

| | `restart` | `reload` |
|---|---|---|
| Mécanisme | Stop complet + redémarrage | Envoi de SIGHUP |
| Connexions actives | ❌ Coupées | ✅ Maintenues |
| Temps d'arrêt | Oui | Non (zéro downtime) |
| Quand l'utiliser | Après mise à jour du binaire | Après modif de config |
| Support universel | ✅ Tous les services | ⚠️ Pas tous les services |

---

#### État et activation

```bash
systemctl status nginx            # État détaillé + dernières lignes de log
systemctl is-active nginx         # Retourne "active" ou "inactive"
systemctl is-enabled nginx        # Retourne "enabled" ou "disabled"
systemctl is-failed nginx         # Retourne "failed" si le service a crashé
```

---

#### Activation au démarrage

```bash
sudo systemctl enable nginx       # Activer au démarrage
sudo systemctl disable nginx      # Désactiver au démarrage
sudo systemctl enable --now nginx # Activer ET démarrer immédiatement
```

---

#### Vue d'ensemble du système

```bash
systemctl list-units                      # Tous les units actifs
systemctl list-units --type=service       # Uniquement les services
systemctl list-units --state=failed       # Services en échec uniquement
systemctl list-unit-files                 # Tous les units installés
sudo systemctl daemon-reload              # Recharger après modif d'un .service
```

> `daemon-reload` est **obligatoire** après toute modification d'un fichier `.service`. Sans lui, systemd continue d'utiliser l'ancienne version en mémoire.

---

### 11. Anatomie d'un fichier .service

Les fichiers `.service` personnalisés se placent dans `/etc/systemd/system/` (prioritaires sur ceux de `/lib/systemd/system/`).

```bash
cat /lib/systemd/system/nginx.service
```

**Structure complète annotée :**

```ini
[Unit]
Description=The nginx HTTP and reverse proxy server
# Texte affiché dans systemctl status

After=network.target
# Démarrer APRÈS l'initialisation du réseau

Wants=network-online.target
# Dépendance souple : on préfère que ça tourne, mais on démarre quand même si absent

Requires=postgresql.service
# Dépendance forte : si postgresql échoue, ce service ne démarre pas


[Service]
Type=forking
# forking  → le processus principal fork (nginx, apache)
# simple   → le processus reste en premier plan (défaut)
# oneshot  → tâche ponctuelle qui se termine (scripts)
# notify   → le service signale à systemd quand il est prêt

ExecStart=/usr/sbin/nginx
# Commande de démarrage — chemin ABSOLU obligatoire

ExecReload=/bin/kill -s HUP $MAINPID
# Commande lors de systemctl reload
# $MAINPID = PID principal géré par systemd

ExecStop=/bin/kill -s QUIT $MAINPID
# Commande d'arrêt propre

User=www-data
Group=www-data
# Lancer sous un utilisateur non-root (bonne pratique de sécurité)

Restart=on-failure
# always      → toujours redémarrer
# on-failure  → redémarrer si code de sortie non nul
# no          → jamais redémarrer

RestartSec=5s
# Attendre 5 secondes avant de redémarrer

WorkingDirectory=/var/www
# Répertoire de travail du processus

Environment="NODE_ENV=production"
# Variables d'environnement pour le service

StandardOutput=journal
StandardError=journal
# Rediriger stdout et stderr vers journald


[Install]
WantedBy=multi-user.target
# Ce service s'active quand la target multi-user est atteinte
# = démarrage automatique sur un serveur sans GUI
```

---

### 12. journalctl

`journalctl` est l'interface pour lire le **journal systemd** (journald), qui centralise tous les logs système et des services.

#### Consultation de base

```bash
journalctl                   # Tout le journal
journalctl -b                # Journal du démarrage actuel
journalctl -b -1             # Journal du démarrage précédent
journalctl -n 50             # 50 dernières lignes
```

---

#### Filtrer par service

```bash
journalctl -u nginx                    # Logs du service nginx
journalctl -u nginx -u ssh             # Logs de plusieurs services
```

---

#### Suivre en temps réel

```bash
journalctl -f                          # Tout le système en temps réel
journalctl -u nginx -f                 # Uniquement nginx en temps réel
```

---

#### Filtrer par date et heure

```bash
journalctl --since "2024-01-15 10:00:00"
journalctl --until "2024-01-15 18:00:00"
journalctl --since "2024-01-15 10:00" --until "2024-01-15 11:00"
journalctl --since "1 hour ago"
journalctl --since "yesterday"
```

---

#### Filtrer par priorité

```bash
journalctl -p err            # Erreurs uniquement
journalctl -p warning        # Avertissements et plus grave
journalctl -p crit           # Critique uniquement
```

**Niveaux de priorité :**

| Niveau | Numéro | Signification |
|---|---|---|
| `emerg` | 0 | Système inutilisable |
| `alert` | 1 | Action immédiate requise |
| `crit` | 2 | Condition critique |
| `err` | 3 | Erreur |
| `warning` | 4 | Avertissement |
| `notice` | 5 | Événement notable |
| `info` | 6 | Information |
| `debug` | 7 | Débogage |

---

#### Options d'affichage et combinaisons

```bash
journalctl --no-pager                          # Sans pagination (idéal pour grep)
journalctl -u nginx -n 20 --no-pager           # 20 dernières lignes nginx
journalctl -u nginx --since "1 hour ago" -p err --no-pager
# Logs nginx de la dernière heure, erreurs seulement, sans pagination
```

---

### 13. Exercice 2 — Service systemd health-check

**Objectif :** Créer un service systemd qui exécute automatiquement un script de surveillance système au démarrage.

---

#### Étape 1 — Créer le script

```bash
sudo mkdir -p /opt/scripts
sudo nano /opt/scripts/health_check.sh
```

```bash
#!/bin/bash
# ============================================================
# health_check.sh — Surveillance système automatique
# Auteur : Slimane B. | Master 2 IRS
# ============================================================
set -euo pipefail

# ── Configuration ────────────────────────────────────────────
LOG_FILE="/var/log/health_check.log"
SEUIL_DISQUE=80
SEUIL_CHARGE=2.0
SERVICES=("ssh" "cron" "rsyslog")

# ── Fonctions ────────────────────────────────────────────────
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

check_disk() {
    local usage
    usage=$(df -h / | awk 'NR==2 {gsub(/%/,"",$5); print $5}')
    if [ "$usage" -gt "$SEUIL_DISQUE" ]; then
        log "ALERTE  Disque / utilise a ${usage}% (seuil: ${SEUIL_DISQUE}%)"
    else
        log "OK      Disque / : ${usage}%"
    fi
}

check_memory() {
    local mem_dispo
    mem_dispo=$(free -m | awk 'NR==2 {print $7}')
    log "INFO    RAM disponible : ${mem_dispo} Mo"
}

check_load() {
    local load
    load=$(awk '{print $1}' /proc/loadavg)
    log "INFO    Load average (1min) : ${load}"
}

check_services() {
    for service in "${SERVICES[@]}"; do
        if systemctl is-active --quiet "$service"; then
            log "OK      Service ${service} : actif"
        else
            log "ALERTE  Service ${service} : INACTIF ou en echec"
        fi
    done
}

# ── Exécution ────────────────────────────────────────────────
log "===== Debut du health check ====="
check_disk
check_memory
check_load
check_services
log "===== Fin du health check ====="
```

```bash
sudo chmod +x /opt/scripts/health_check.sh
sudo /opt/scripts/health_check.sh          # Tester manuellement
cat /var/log/health_check.log              # Vérifier le fichier de log
```

---

#### Étape 2 — Créer le fichier .service

```bash
sudo nano /etc/systemd/system/health-check.service
```

```ini
[Unit]
Description=Health Check systemique - surveillance disque, RAM et services
After=network.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/opt/scripts/health_check.sh
User=root
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

---

#### Étape 3 — Activer et tester

```bash
sudo systemctl daemon-reload
sudo systemctl start health-check.service
systemctl status health-check.service
journalctl -u health-check.service -n 30 --no-pager
cat /var/log/health_check.log
```

---

#### Étape 4 — Activer au démarrage

```bash
sudo systemctl enable health-check.service
sudo reboot
journalctl -u health-check.service -b --no-pager   # Vérifier après redémarrage
```

---

#### Résultat attendu dans `journalctl`

```
systemd[1]: Starting Health Check systemique...
health_check.sh[1234]: [2024-01-15 10:00:01] ===== Debut du health check =====
health_check.sh[1234]: [2024-01-15 10:00:01] OK      Disque / : 43%
health_check.sh[1234]: [2024-01-15 10:00:01] INFO    RAM disponible : 896 Mo
health_check.sh[1234]: [2024-01-15 10:00:01] INFO    Load average (1min) : 0.15
health_check.sh[1234]: [2024-01-15 10:00:01] OK      Service ssh : actif
health_check.sh[1234]: [2024-01-15 10:00:01] OK      Service cron : actif
health_check.sh[1234]: [2024-01-15 10:00:01] OK      Service rsyslog : actif
health_check.sh[1234]: [2024-01-15 10:00:01] ===== Fin du health check =====
systemd[1]: health-check.service: Succeeded.
```

---

## Commandes clés apprises

```bash
# Processus
ps aux              ps aux --sort=-%mem     ps -ef --forest
top                 htop
pgrep -l nginx      pkill -9 nginx
kill 1234           kill -9 1234            kill -1 1234
nice -n 15 cmd      renice -n 10 -p PID
nohup ./script.sh &

# Signaux
kill -l             kill -SIGTERM PID       kill -SIGKILL PID

# Mémoire
free -h             free -h -s 2
vmstat 2 5
grep MemAvailable /proc/meminfo

# Disque
df -h               df -hT
du -sh /var/log     du -h --max-depth=1 /
lsblk               lsblk -f
sudo fdisk -l
sudo mount /dev/sdb1 /mnt/data      sudo umount /mnt/data
sudo mount -a       sudo blkid /dev/sdb1

# Variables
env                 printenv            echo $PATH
export VAR="val"    source ~/.bashrc

# systemd
sudo systemctl start/stop/restart/reload nginx
sudo systemctl enable/disable nginx
systemctl status/is-active/is-enabled nginx
sudo systemctl daemon-reload
systemctl list-units --type=service
systemctl list-units --state=failed

# journalctl
journalctl -u nginx -f
journalctl -u nginx --since "1 hour ago" -p err --no-pager
journalctl -b
```

---

## Livrables & preuves

- [ ] Capture de `ps aux --sort=-%mem | head -6` sur la VM
- [ ] Capture de `free -h` et `vmstat 2 5` sur la VM
- [ ] Capture de `df -hT` et `lsblk -f` sur la VM
- [ ] Script `health_check.sh` fonctionnel dans `/opt/scripts/`
- [ ] Fichier `health-check.service` dans `/etc/systemd/system/`
- [ ] Capture de `systemctl status health-check.service` après démarrage
- [ ] Capture de `journalctl -u health-check.service -b --no-pager`
- [ ] Contenu de `/var/log/health_check.log` après exécution

---

## Difficultés rencontrées & solutions

| Difficulté rencontrée | Solution appliquée |
|---|---|
| `kill -9` corrompt des données | Toujours essayer SIGTERM d'abord, attendre 5s, puis SIGKILL |
| `free` montre peu de RAM libre alors que tout va bien | La colonne `available` est la vraie valeur — le cache est libérable |
| `umount` échoue avec "device is busy" | `lsof +D /mnt/data` pour trouver quel processus bloque |
| fstab avec `/dev/sdb1` → mauvaise partition après reboot | Utiliser l'UUID (`sudo blkid`) à la place de `/dev/sdX` |
| Modifications dans `.service` non prises en compte | Toujours lancer `sudo systemctl daemon-reload` après modification |
| Service en `failed` après `systemctl start` | `journalctl -u nom-service -n 50 --no-pager` pour voir l'erreur exacte |
| `nohup` : le processus s'arrête quand on ferme le terminal | Vérifier que `&` est bien ajouté à la fin de la commande |

---

*Semaine 02 terminée · Prochaine étape → [Semaine 03 — Stockage, logs & automatisation cron](../03-stockage-logs/README.md)*

# Semaine 03 — Logs & Surveillance système

> **Phase 1 — Administration Linux & Système**
> Rythme : 3 soirs × 45 min · Statut : ✅ Terminé

---

## Objectif de la semaine

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
- [Livrables & preuves](#livrables--preuves)
- [Difficultés rencontrées & solutions](#difficultés-rencontrées--solutions)

---

## 1. Architecture des logs Linux

### Le flux d'un log

```
Application / Kernel / Service
         │
         ▼
     rsyslog          ← collecte et trie les messages
         │
         ▼
   /var/log/          ← stockage sur disque
```

`rsyslog` est le démon central qui reçoit les messages de toutes les sources et les redistribue vers les bons fichiers selon des règles de filtrage définies dans `/etc/rsyslog.conf`.

```bash
systemctl status rsyslog        # Vérifier que rsyslog tourne
cat /etc/rsyslog.conf           # Configuration principale
ls /etc/rsyslog.d/              # Règles supplémentaires par application
```

---

### Fichiers importants dans `/var/log/`

| Fichier | Contenu | Quand le consulter |
|---|---|---|
| `syslog` | Messages système généraux | Premier réflexe en cas de problème |
| `auth.log` | Authentifications, sudo, SSH | Détecter les tentatives d'intrusion |
| `kern.log` | Messages du kernel | Erreurs matérielles, drivers |
| `apt/history.log` | Paquets installés/supprimés | Tracer les changements système |
| `apt/term.log` | Sortie complète d'apt | Déboguer une installation ratée |
| `dpkg.log` | Actions dpkg bas niveau | Tracer chaque fichier installé |
| `faillog` | Échecs de connexion | Comptes sous attaque |
| `lastlog` | Dernières connexions par user | Audit des accès |

```bash
ls -lh /var/log/                # Lister tous les fichiers de log avec leur taille
sudo tail -f /var/log/syslog    # Surveiller syslog en temps réel
sudo cat /var/log/auth.log      # Lire les logs d'authentification
```

---

### Niveaux de sévérité

| Niveau | Numéro | Signification |
|---|---|---|
| `emerg` | 0 | Système inutilisable |
| `alert` | 1 | Action immédiate requise |
| `crit` | 2 | Condition critique |
| `err` | 3 | Erreur |
| `warning` | 4 | Avertissement |
| `notice` | 5 | Événement normal mais notable |
| `info` | 6 | Information |
| `debug` | 7 | Très verbeux — débogage |

---

## 2. Analyser des logs

### `grep` et `grep -E`

`grep` cherche un motif dans le contenu d'un fichier. `grep -E` active les **expressions régulières étendues** (ERE) pour des motifs plus puissants.

```bash
grep "Failed password" /var/log/auth.log        # Motif exact
grep -i "error" /var/log/syslog                 # Insensible à la casse
grep -n "sshd" /var/log/auth.log                # Avec numéro de ligne
grep -v "debug" /var/log/syslog                 # Tout SAUF les lignes "debug"
grep -c "Failed password" /var/log/auth.log     # Compter les occurrences
grep -B 3 -A 3 "Failed password" /var/log/auth.log   # 3 lignes de contexte avant/après
```

```bash
grep -E "error|warning|critical" /var/log/syslog
grep -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" /var/log/auth.log
```

> `grep -E` permet d'utiliser `|` (ou), `{n}` (répétition), `+`, `?` sans les échapper.

---

### `awk`

`awk` lit un fichier ligne par ligne et découpe chaque ligne en **champs** séparés par des espaces. `$1` = 1er champ, `$2` = 2ème, `$NF` = dernier champ.

**Anatomie d'une ligne `auth.log` :**

```
Jan 15 10:23:44 debian sshd[1234]: Failed password for root from 192.168.1.50 port 54321 ssh2
$1   $2    $3     $4      $5          $6      $7    $8   $9   $10    $11       $12   $13
```

`$11` = adresse IP de l'attaquant.

```bash
awk '{print $1, $9}' /var/log/auth.log                   # Afficher colonnes 1 et 9
awk '/Failed/ {print $0}' /var/log/auth.log              # Lignes contenant "Failed"
awk '/Failed password/ {print $11}' /var/log/auth.log   # Extraire l'IP (champ 11)
awk '{print NF}' /var/log/auth.log                       # Afficher le nombre de champs
awk 'NR>=10 && NR<=20 {print}' /var/log/syslog          # Lignes 10 à 20
```

---

### `sed`

`sed` (**Stream EDitor**) modifie le texte à la volée **sans toucher au fichier source**.

```bash
sed 's/error/ERREUR/' /var/log/syslog           # Remplacer première occurrence par ligne
sed 's/error/ERREUR/g' /var/log/syslog          # Remplacer toutes les occurrences (g=global)
sed -n '10,20p' /var/log/syslog                 # Afficher uniquement les lignes 10 à 20
sed '/^$/d' /var/log/syslog                     # Supprimer les lignes vides
sed '/debug/d' /var/log/syslog                  # Supprimer les lignes contenant "debug"
sed -n '/Failed/p' /var/log/syslog              # Afficher uniquement les lignes "Failed"
```

---

### `cut`

`cut` extrait des colonnes définies par un **délimiteur** précis.

```bash
cut -d: -f1 /etc/passwd             # Champ 1 (username), délimiteur ":"
cut -d: -f1,3 /etc/passwd           # Champs 1 et 3 (username + UID)
cut -c1-10 /var/log/syslog          # Les 10 premiers caractères de chaque ligne
cut -d' ' -f1-3 /var/log/syslog     # Les 3 premiers champs (= la date)
```

---

### `sort`

```bash
sort fichier.txt                    # Tri alphabétique croissant
sort -r fichier.txt                 # Tri alphabétique décroissant
sort -n fichier.txt                 # Tri numérique
sort -rn fichier.txt                # Tri numérique décroissant
sort -k2 fichier.txt                # Trier sur la 2ème colonne
sort -u fichier.txt                 # Supprimer les doublons après tri
```

---

### `uniq -c`

`uniq` supprime les lignes **consécutives** identiques. L'option `-c` ajoute le compteur devant chaque ligne.

```bash
sort fichier.txt | uniq             # Supprimer les doublons
sort fichier.txt | uniq -c         # Compter les occurrences
sort fichier.txt | uniq -c | sort -rn   # Trier par fréquence décroissante
```

> `uniq` doit **toujours** être précédé de `sort`. Il ne détecte que les doublons consécutifs.

---

### `wc -l`

```bash
wc -l /var/log/syslog                               # Nombre total de lignes
grep "Failed password" /var/log/auth.log | wc -l   # Compter les tentatives SSH
grep -E "error|warning" /var/log/syslog | wc -l    # Compter erreurs + warnings
```

---

## 3. logrotate

### Pourquoi logrotate

Sans rotation, les fichiers de log grossissent indéfiniment jusqu'à saturer le disque. `logrotate` tourne automatiquement via `/etc/cron.daily/logrotate` et :

- Archive les vieux logs (compresse en `.gz`)
- Crée un nouveau fichier vide
- Supprime les archives trop anciennes

### Configuration principale

```bash
cat /etc/logrotate.conf
```

```
weekly          # Rotation hebdomadaire par défaut
rotate 4        # Garder 4 archives
create          # Créer un nouveau fichier après rotation
compress        # Compresser les archives en .gz
include /etc/logrotate.d    # Inclure les règles des applications
```

---

### Règles spécifiques dans `/etc/logrotate.d/`

Chaque application installe sa propre règle dans ce dossier.

```bash
ls /etc/logrotate.d/            # Voir toutes les règles installées
cat /etc/logrotate.d/nginx      # Exemple : règle nginx
```

**Exemple de règle nginx commentée :**

```
/var/log/nginx/*.log {
    daily                           # Rotation quotidienne
    missingok                       # Pas d'erreur si le fichier est absent
    rotate 14                       # Garder 14 archives
    compress                        # Compresser en .gz
    delaycompress                   # Compresser à partir de la 2ème rotation
    notifempty                      # Ne pas tourner si le fichier est vide
    create 0640 www-data adm        # Créer le nouveau fichier avec ces droits
    sharedscripts                   # Scripts pre/post exécutés une seule fois
    postrotate
        /usr/sbin/nginx -s reopen   # Dire à nginx de rouvrir ses fichiers de log
    endscript
}
```

---

### Directives importantes

| Directive | Signification |
|---|---|
| `daily` / `weekly` / `monthly` | Fréquence de rotation |
| `rotate N` | Nombre d'archives à conserver |
| `compress` | Compresser en `.gz` |
| `delaycompress` | Compresser à partir de la 2ème rotation (pas la plus récente) |
| `missingok` | Pas d'erreur si le fichier est absent |
| `notifempty` | Ne pas tourner si le fichier est vide |
| `create MODE USER GROUP` | Créer le nouveau fichier avec ces droits |
| `postrotate / endscript` | Script exécuté après la rotation |

---

### Créer une règle custom

```bash
sudo nano /etc/logrotate.d/monapp
```

```
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

```bash
sudo logrotate -d /etc/logrotate.d/monapp    # Tester sans rien modifier (dry-run)
sudo logrotate -f /etc/logrotate.d/monapp    # Forcer la rotation immédiatement
```

---

## 4. Surveillance en temps réel

### `tail -f`

```bash
sudo tail -f /var/log/syslog                    # Suivre syslog en temps réel
sudo tail -f /var/log/auth.log                  # Suivre les connexions
sudo tail -n 50 -f /var/log/syslog              # 50 dernières lignes puis suivre
sudo tail -f /var/log/syslog /var/log/auth.log  # Suivre plusieurs fichiers
```

> `Ctrl+C` pour arrêter le suivi.

---

### `multitail` — plusieurs logs dans un seul terminal

```bash
sudo apt install multitail

sudo multitail /var/log/syslog /var/log/auth.log              # 2 logs côte à côte
sudo multitail -s 3 /var/log/syslog /var/log/auth.log /var/log/kern.log   # 3 logs
```

**Raccourcis dans multitail :**

| Touche | Action |
|---|---|
| `q` | Quitter |
| `b` | Remonter dans l'historique |
| `h` | Afficher l'aide |

---

## 5. Exercice — Top 10 IPs SSH

**Objectif :** Extraire de `auth.log` les 10 adresses IP ayant fait le plus de tentatives de connexion SSH échouées.

### Comprendre la structure d'une ligne auth.log

```
Jan 15 10:23:44 debian sshd[1234]: Failed password for root from 192.168.1.50 port 54321 ssh2
$1   $2    $3     $4      $5          $6      $7    $8   $9   $10    $11       $12   $13
```

Le mot-clé est `Failed password`. L'IP est toujours le **11ème champ**.

---

### Solution complète

```bash
sudo awk '/Failed password/ {print $11}' /var/log/auth.log \
  | sort \
  | uniq -c \
  | sort -rn \
  | head -10
```

---

### Décortiqué étape par étape

```bash
# Étape 1 : extraire l'IP (champ 11) des lignes "Failed password"
sudo awk '/Failed password/ {print $11}' /var/log/auth.log

# Étape 2 : trier pour regrouper les IPs identiques (obligatoire avant uniq)
| sort

# Étape 3 : compter les occurrences de chaque IP
| uniq -c

# Étape 4 : retrier par nombre décroissant
| sort -rn

# Étape 5 : garder les 10 premières
| head -10
```

---

### Exemple de sortie

```
    847 185.234.219.45
    412 103.99.0.122
    389 45.146.164.110
    201 185.220.101.33
    198 23.129.64.133
    156 89.248.167.131
    134 198.235.24.155
     98 167.94.145.60
     87 80.82.77.139
     71 62.210.230.100
```

---

### Variante avec formatage lisible

```bash
sudo awk '/Failed password/ {print $11}' /var/log/auth.log \
  | sort \
  | uniq -c \
  | sort -rn \
  | head -10 \
  | awk '{printf "Tentatives: %-6s | IP: %s\n", $1, $2}'
```

Sortie :

```
Tentatives: 847    | IP: 185.234.219.45
Tentatives: 412    | IP: 103.99.0.122
Tentatives: 389    | IP: 45.146.164.110
```

---

### Commandes complémentaires

```bash
sudo grep -c "Failed password" /var/log/auth.log        # Total des tentatives
sudo grep "185.234.219.45" /var/log/auth.log | tail -5  # Dernières tentatives d'une IP
sudo grep "Accepted password" /var/log/auth.log         # Connexions réussies
```

---

## Commandes clés apprises

```bash
# Architecture des logs
ls -lh /var/log/
systemctl status rsyslog
cat /etc/rsyslog.conf

# grep
grep "Failed password" /var/log/auth.log
grep -i -n -v -c "motif" fichier
grep -E "error|warning" /var/log/syslog
grep -B 3 -A 3 "motif" fichier

# awk
awk '{print $1, $11}' fichier
awk '/motif/ {print $11}' fichier
awk 'NR>=10 && NR<=20 {print}' fichier

# sed
sed 's/ancien/nouveau/g' fichier
sed -n '10,20p' fichier
sed '/debug/d' fichier

# cut
cut -d: -f1,3 /etc/passwd
cut -d' ' -f1-3 /var/log/syslog

# sort + uniq + wc
sort fichier | uniq -c | sort -rn | head -10
wc -l fichier
grep "motif" fichier | wc -l

# logrotate
sudo logrotate -d /etc/logrotate.d/monapp
sudo logrotate -f /etc/logrotate.d/monapp
cat /etc/logrotate.conf
ls /etc/logrotate.d/

# Temps réel
sudo tail -f /var/log/syslog
sudo tail -n 50 -f /var/log/auth.log
sudo multitail /var/log/syslog /var/log/auth.log
```

---

## Livrables & preuves

- [ ] Capture du résultat de `ls -lh /var/log/` sur la VM
- [ ] Capture du top 10 IPs SSH (`awk + sort + uniq + head`)
- [ ] Règle logrotate custom créée dans `/etc/logrotate.d/`
- [ ] Capture de `logrotate -d` (dry-run) sur la règle custom
- [ ] Capture de `multitail` avec 2 fichiers de log en simultané

---

## Difficultés rencontrées & solutions

| Difficulté rencontrée | Solution appliquée |
|---|---|
| `uniq -c` ne compte pas correctement | Toujours faire `sort` avant `uniq` — il ne détecte que les doublons consécutifs |
| `awk` retourne le mauvais champ pour l'IP | Compter les champs sur une ligne réelle avec `awk '{print NF}'` pour ajuster |
| `logrotate -f` ne tourne pas car `notifempty` | Le fichier de log était vide — le remplir ou retirer `notifempty` pour tester |
| `tail -f` s'arrête après rotation du log | Utiliser `tail -F` (majuscule) qui résiste à la rotation automatique |
| `grep -E` ne matche pas le motif attendu | Tester le motif regex sur explainshell.com avant de l'utiliser |

---

*Semaine 03 terminée · Prochaine étape → [Semaine 04 — Réseau Linux & pare-feu UFW](../04-reseau-diagnostic/README.md)*

# Semaine 04 — SSH sécurisé & fail2ban

> **Phase 1 — Administration Linux & Système**
> Rythme : 3 soirs × 45 min · Statut : ✅ Terminé

---

## Objectif de la semaine

Maîtriser le protocole SSH, générer des clés ED25519, sécuriser le démon sshd, configurer des alias de connexion et déployer fail2ban pour bloquer automatiquement les attaquants.

---

## Sommaire

- [1. Le protocole SSH](#1-le-protocole-ssh)
- [2. Générer une paire de clés ED25519](#2-générer-une-paire-de-clés-ed25519)
- [3. Déployer la clé sur le serveur](#3-déployer-la-clé-sur-le-serveur)
- [4. Alias de connexion — ~/.ssh/config](#4-alias-de-connexion--sshconfig)
- [5. Sécuriser sshd_config](#5-sécuriser-sshd_config)
- [6. fail2ban](#6-fail2ban)
- [7. SECURITY.md](./SECURITY.md)
- [Commandes clés apprises](#commandes-clés-apprises)
- [Livrables & preuves](#livrables--preuves)
- [Difficultés rencontrées & solutions](#difficultés-rencontrées--solutions)

---

## 1. Le protocole SSH

SSH (**Secure Shell**) est un protocole réseau qui permet d'administrer un serveur distant de façon **chiffrée et authentifiée**. Avant SSH, on utilisait Telnet — tout passait en clair sur le réseau, mot de passe inclus.

### Flux d'une connexion SSH

```
Ton poste (client SSH)          Serveur distant (démon sshd)
      │                                    │
      │──── connexion TCP port 22 ────────>│
      │<─── échange de clés (DH) ─────────│
      │──── authentification ─────────────>│
      │<─── session chiffrée ─────────────>│
```

---

### L'échange de clés Diffie-Hellman

Mécanisme qui permet à deux machines de **se mettre d'accord sur une clé de chiffrement sans jamais l'envoyer sur le réseau**.

```
Slimane                              Serveur
   │                                    │
   │── Couleur commune publique : JAUNE ─>│  (échangée en clair, pas grave)
   │                                    │
   │  Choisit secret : ROUGE           │  Choisit secret : BLEU
   │  Mélange : JAUNE+ROUGE = ORANGE   │  Mélange : JAUNE+BLEU = VERT
   │                                    │
   │──────── envoie ORANGE ────────────>│
   │<──────── reçoit VERT ──────────────│
   │                                    │
   │  VERT + ROUGE = MARRON            │  ORANGE + BLEU = MARRON
   │                                    │
   └──── Clé commune : MARRON ─────────┘
         (jamais envoyée sur le réseau)
```

Un attaquant qui intercepte JAUNE + ORANGE + VERT ne peut pas retrouver MARRON sans connaître ROUGE ou BLEU.

---

### Clés publique / privée

```
Clé PRIVÉE                         Clé PUBLIQUE
   │                                    │
   │  Tu gardes sur ton poste          │  Tu déposes sur le serveur
   │  NE JAMAIS partager               │  Peut être lue par tous
   │  ~/.ssh/id_ed25519                │  ~/.ssh/authorized_keys (serveur)
   │                                    │
   └──── Prouve que tu possèdes ───────┘
         la clé privée correspondante
```

**Déroulement de l'authentification par clé :**

```
Client                              Serveur
  │                                    │
  │──── "je veux me connecter" ───────>│
  │<─── challenge chiffré ─────────────│  (chiffré avec ta clé publique)
  │                                    │
  │  Déchiffre avec la clé privée     │
  │──── réponse au challenge ─────────>│
  │<─── accès accordé ─────────────────│
```

Seul le possesseur de la clé privée peut répondre correctement au challenge.

---

## 2. Générer une paire de clés ED25519

### ED25519 vs RSA 2048

| Critère | RSA 2048 | ED25519 |
|---|---|---|
| Taille de clé | 2048 bits | 256 bits |
| Vitesse | Lente | Très rapide |
| Sécurité | Correcte | Excellente |
| Recommandé 2024 | Non | ✅ Oui |

ED25519 utilise les courbes elliptiques — 256 bits offrent une sécurité équivalente à RSA 3072 bits.

---

### Générer la paire de clés

```bash
ssh-keygen -t ed25519 -C "slimane@lab-vm"
```

```
Generating public/private ed25519 key pair.
Enter file in which to save the key (/home/slimane/.ssh/id_ed25519):
# Entrée pour accepter le chemin par défaut

Enter passphrase (empty for no passphrase):
# Recommandé : entrer une passphrase
# Protège la clé privée si ton poste est compromis
```

---

### Vérifier les fichiers générés

```bash
ls -la ~/.ssh/
```

```
drwx------ 2 slimane slimane 4096  .             ← 700 obligatoire
-rw------- 1 slimane slimane  411  id_ed25519    ← 600 clé privée
-rw-r--r-- 1 slimane slimane  101  id_ed25519.pub ← 644 clé publique
```

```bash
cat ~/.ssh/id_ed25519.pub
# ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... slimane@lab-vm
```

> Les permissions du dossier `~/.ssh/` et de la clé privée sont critiques. Si elles sont trop ouvertes, SSH refuse de les utiliser.

---

## 3. Déployer la clé sur le serveur

### `ssh-copy-id` — méthode simple

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub devops@192.168.10.10
# Entrer le mot de passe une dernière fois
# La clé est ajoutée dans ~/.ssh/authorized_keys sur le serveur
```

### Méthode manuelle

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "ssh-ed25519 AAAAC3Nz..." >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### Tester la connexion par clé

```bash
ssh -i ~/.ssh/id_ed25519 devops@192.168.10.10
# Connexion réussie sans mot de passe système = clé fonctionnelle
```

---

## 4. Alias de connexion — ~/.ssh/config

Sans config, chaque connexion nécessite de taper l'IP, le port, le user et la clé. `~/.ssh/config` crée des **alias** pour simplifier.

```bash
nano ~/.ssh/config
```

```
# Serveur lab principal
Host lab
    HostName 192.168.10.10
    User devops
    Port 2222
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 60

# Serveur DMZ
Host lab-dmz
    HostName 192.168.20.10
    User devops
    Port 2222
    IdentityFile ~/.ssh/id_ed25519

# Bastion (gateway)
Host bastion
    HostName 192.168.10.1
    User admin
    Port 2222
    IdentityFile ~/.ssh/id_ed25519

# Passer par le bastion pour atteindre les serveurs internes
Host lab-interne
    HostName 192.168.30.10
    User devops
    ProxyJump bastion
    IdentityFile ~/.ssh/id_ed25519
```

```bash
chmod 600 ~/.ssh/config

# Utilisation simplifiée
ssh lab          # au lieu de : ssh -i ~/.ssh/id_ed25519 -p 2222 devops@192.168.10.10
ssh lab-dmz
ssh lab-interne  # passe automatiquement par le bastion
```

---

## 5. Sécuriser sshd_config

`/etc/ssh/sshd_config` est la configuration du **démon SSH côté serveur**.

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak   # Sauvegarder avant
sudo nano /etc/ssh/sshd_config
```

### Directives essentielles

| Directive | Valeur | Raison |
|---|---|---|
| `Port` | `2222` | Réduire l'exposition aux scans automatisés |
| `PermitRootLogin` | `no` | Forcer l'usage d'un compte dédié + sudo |
| `PasswordAuthentication` | `no` | Rendre le brute-force inutile |
| `PubkeyAuthentication` | `yes` | Activer l'auth par clé |
| `AllowUsers` | `devops` | Liste blanche d'utilisateurs autorisés |
| `MaxAuthTries` | `3` | Limiter les tentatives par connexion |
| `LoginGraceTime` | `20` | Réduire la fenêtre d'authentification |
| `X11Forwarding` | `no` | Désactiver les fonctions inutiles |
| `ClientAliveInterval` | `300` | Fermer les sessions inactives |

### Configuration complète recommandée

```bash
Port 2222
AddressFamily inet

PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no

AllowUsers devops

MaxAuthTries 3
LoginGraceTime 20
MaxSessions 5

ClientAliveInterval 300
ClientAliveCountMax 2

X11Forwarding no
AllowTcpForwarding no
PrintMotd no
```

### Appliquer et vérifier

```bash
sudo sshd -t                          # Vérifier la syntaxe (aucun output = OK)
sudo systemctl restart ssh            # Redémarrer sshd
sudo ss -tlnp | grep sshd             # Vérifier le port d'écoute
ssh -p 2222 devops@192.168.10.10      # Tester (garder l'ancienne session ouverte)
```

> ⚠️ Ne jamais fermer la session SSH active avant d'avoir testé la nouvelle config. Une erreur dans sshd_config peut bloquer l'accès au serveur.

---

## 6. fail2ban

fail2ban surveille les logs en temps réel et bannit automatiquement via iptables les IPs qui dépassent le seuil de tentatives échouées.

```
/var/log/auth.log
      │
      ▼
  fail2ban        ← surveille les logs
      │
      │  Trop de tentatives depuis une IP ?
      ▼
  iptables        ← ajoute une règle de blocage
      │
      ▼
  IP bloquée      ← pour la durée configurée
```

### Installation

```bash
sudo apt install fail2ban
sudo systemctl enable --now fail2ban
systemctl status fail2ban
```

### Architecture de configuration

```
/etc/fail2ban/
├── fail2ban.conf    ← config globale (ne pas modifier)
├── jail.conf        ← jails par défaut (ne pas modifier)
└── jail.local       ← tes surcharges (toujours modifier ici)
```

> La règle d'or : **ne jamais modifier les `.conf`**. Toujours créer/modifier le `.local` correspondant. Les `.local` survivent aux mises à jour.

### Créer `jail.local`

```bash
sudo nano /etc/fail2ban/jail.local
```

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
findtime = 600
```

**Paramètres expliqués :**

| Paramètre | Valeur | Signification |
|---|---|---|
| `bantime` | `3600` | Durée du ban en secondes (1h). `-1` = ban permanent |
| `findtime` | `600` | Fenêtre de temps pour compter les tentatives (10 min) |
| `maxretry` | `3` | Nombre de tentatives échouées avant ban |
| `ignoreip` | `127.0.0.1/8` | IPs jamais bannies — toujours y mettre son propre réseau |

### Redémarrer et vérifier

```bash
sudo systemctl restart fail2ban

sudo fail2ban-client status           # Liste des jails actives
sudo fail2ban-client status sshd      # Détails de la jail SSH
sudo tail -f /var/log/fail2ban.log    # Suivre les bans en temps réel
```

### Gérer les bans

```bash
sudo fail2ban-client set sshd unbanip 192.168.10.5    # Débannir une IP
sudo fail2ban-client set sshd banip 185.234.219.45    # Bannir manuellement
```

### Tester le fonctionnement

```bash
# Depuis une autre machine, faire 4 tentatives échouées
ssh -p 2222 mauvaisuser@192.168.10.10   # × 4 fois

# Vérifier le ban
sudo fail2ban-client status sshd
# Banned IP list: <ip-testée>

# Vérifier dans les logs
sudo tail /var/log/fail2ban.log
# NOTICE [sshd] Ban <ip>
```

## 7. SECURITY.md

Le fichier de documentation sécurité est disponible ici → [SECURITY.md](./SECURITY.md)

## Type de clé

ED25519 (Curve25519) — plus sécurisé et plus rapide que RSA 2048.

## fail2ban

| Paramètre | Valeur                   |
|---|---|
| maxretry  | 3 tentatives             |
| findtime  | 600 secondes (10 min)    |
| bantime   | 3600 secondes (1 heure)  |
| Port      | 2222                     |
| Log       | /var/log/auth.log        |

## Checklist de validation

- [x] Connexion par clé ED25519 fonctionnelle
- [x] Connexion par mot de passe refusée
- [x] Connexion root directe refusée
- [x] fail2ban actif — jail sshd enabled
- [x] Port changé à 2222
- [x] Ban déclenché après 3 tentatives échouées
```

```bash
git add SECURITY.md
git commit -m "security: add SSH hardening and fail2ban documentation"
git push
```

---

## Commandes clés apprises

```bash
# Génération de clés
ssh-keygen -t ed25519 -C "commentaire"
cat ~/.ssh/id_ed25519.pub

# Déploiement
ssh-copy-id -i ~/.ssh/id_ed25519.pub devops@IP
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod 600 ~/.ssh/config

# Connexion
ssh -i ~/.ssh/id_ed25519 -p 2222 devops@IP
ssh lab                                # avec alias ~/.ssh/config

# sshd
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo sshd -t                           # Vérifier la syntaxe
sudo systemctl restart ssh
sudo ss -tlnp | grep sshd

# fail2ban
sudo apt install fail2ban
sudo systemctl enable --now fail2ban
sudo fail2ban-client status
sudo fail2ban-client status sshd
sudo fail2ban-client set sshd unbanip IP
sudo fail2ban-client set sshd banip IP
sudo tail -f /var/log/fail2ban.log
```

---

## Livrables & preuves

- [ ] Capture de `ls -la ~/.ssh/` avec les bonnes permissions
- [ ] Capture de la connexion SSH par clé réussie (sans mot de passe)
- [ ] Capture de `sudo ss -tlnp | grep sshd` sur le port 2222
- [ ] Capture de `sudo fail2ban-client status sshd` avec la jail active
- [ ] Capture d'un ban déclenché après 3 tentatives échouées
- [ ] Fichier `SECURITY.md` pushé sur GitHub

---

## Difficultés rencontrées & solutions

| Difficulté rencontrée | Solution appliquée |
|---|---|
| SSH refuse la clé privée | Vérifier les permissions : `chmod 600 ~/.ssh/id_ed25519` et `chmod 700 ~/.ssh/` |
| Bloqué hors du serveur après modif sshd_config | Toujours garder une session active pendant les tests — ne jamais se déconnecter avant validation |
| `sshd -t` retourne une erreur | Lire le message ligne par ligne — souvent une faute de frappe dans une directive |
| fail2ban banne sa propre IP | Ajouter son réseau dans `ignoreip` dans `jail.local` |
| fail2ban ne détecte pas les tentatives | Vérifier que `port = 2222` dans jail.local correspond au port dans sshd_config |
| Connexion SSH refusée après `PasswordAuthentication no` | La clé n'était pas dans `authorized_keys` — utiliser `ssh-copy-id` avant de désactiver les mots de passe |

---

*Semaine 04 terminée · Prochaine étape → [Semaine 05 — DNS, DHCP & VPN WireGuard](../05-dns-dhcp-vpn/README.md)*

# Semaine 05 — Réseau Linux : outils de diagnostic

> **Phase 2 — Réseaux & Sécurité**
> Rythme : 3 soirs × 45 min · Statut : ✅ Terminé

---

## Objectif de la semaine

Maîtriser les outils modernes de diagnostic réseau sous Linux : inspecter les interfaces et la table de routage avec `ip`, lister les ports ouverts avec `ss`, tester la connectivité avec `ping` / `traceroute` / `mtr`, interroger le DNS avec `dig`, capturer le trafic avec `tcpdump` et tester des services HTTP avec `curl`.

---

## Sommaire

- [1. La commande ip — paquet iproute2](#1-la-commande-ip--paquet-iproute2)
- [2. ss — sockets et ports ouverts](#2-ss--sockets-et-ports-ouverts)
- [3. Tester la connectivité et le DNS](#3-tester-la-connectivité-et-le-dns)
- [4. tcpdump — capturer le trafic](#4-tcpdump--capturer-le-trafic)
- [5. curl et wget](#5-curl-et-wget)
- [6. Exercice — Lister et identifier tous les ports ouverts](#6-exercice--lister-et-identifier-tous-les-ports-ouverts)
- [Réflexe de diagnostic](#réflexe-de-diagnostic)
- [Commandes clés apprises](#commandes-clés-apprises)
- [Livrables & preuves](#livrables--preuves)
- [Difficultés rencontrées & solutions](#difficultés-rencontrées--solutions)

---

## 1. La commande ip — paquet iproute2

`ifconfig`, `route`, `arp` et `netstat` appartiennent au paquet `net-tools`, déprécié et souvent absent des installations récentes. `ip` et `ss` les remplacent.

### Tableau de correspondance ancien → moderne

| Ancienne commande | Équivalent moderne |
|---|---|
| `ifconfig` | `ip a` (ou `ip addr`) |
| `ifconfig eth0 up` | `ip link set eth0 up` |
| `route -n` | `ip r` (ou `ip route`) |
| `route add default gw X` | `ip route add default via X` |
| `arp -a` | `ip neigh` |
| `netstat -tulpn` | `ss -tulpn` |

---

### `ip a` — adresses (couche 3)

```bash
ip a                    # Toutes les interfaces avec leurs adresses
ip -br a                # Version compacte et lisible
ip a show ens33         # Une seule interface
```

**Exemple de sortie `ip a` :**

```
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP
    link/ether 00:0c:29:4a:b1:7e brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.20/24 brd 192.168.1.255 scope global dynamic ens33
    inet6 fe80::20c:29ff:fe4a:b17e/64 scope link
```

**Décoder la sortie :**

| Élément | Signification |
|---|---|
| `ens33` | Nom de l'interface (eth0, enp0s3, ens33 selon la distribution) |
| `UP` | Interface activée administrativement |
| `LOWER_UP` | Câble ou lien détecté — UP sans LOWER_UP = problème physique |
| `link/ether` | Adresse MAC |
| `inet 192.168.1.20/24` | Adresse IPv4 et masque CIDR |
| `dynamic` | Adresse obtenue par DHCP |
| `mtu 1500` | Taille maximale des trames |

**Version compacte :**

```bash
ip -br a
# lo      UNKNOWN  127.0.0.1/8
# ens33   UP       192.168.1.20/24 fe80::20c:29ff:fe4a:b17e/64
```

---

### `ip link` — couche 2

```bash
ip link                         # Liste des interfaces, état, MAC
ip -s link show ens33           # Statistiques : paquets, erreurs, drops
sudo ip link set ens33 down     # Désactiver une interface
sudo ip link set ens33 up       # Réactiver une interface
```

> Dans `ip -s link`, des compteurs `errors` et `dropped` non nuls révèlent souvent un problème de câble, de duplex ou de saturation.

---

### `ip r` — table de routage

```bash
ip r                            # Afficher la table de routage complète
ip route get 8.8.8.8            # Par où sortirait un paquet vers 8.8.8.8 ?
```

**Exemple de sortie :**

```
default via 192.168.1.1 dev ens33 proto dhcp metric 100
192.168.1.0/24 dev ens33 proto kernel scope link src 192.168.1.20
```

| Ligne | Signification |
|---|---|
| `default via 192.168.1.1` | Passerelle par défaut — tout ce qui n'est pas local passe par elle |
| `192.168.1.0/24 dev ens33` | Réseau directement connecté |

```bash
ip route get 8.8.8.8
# 8.8.8.8 via 192.168.1.1 dev ens33 src 192.168.1.20
```

---

### Modifier la configuration (temporaire — perdu au reboot)

```bash
sudo ip addr add 192.168.1.50/24 dev ens33          # Ajouter une IP
sudo ip addr del 192.168.1.50/24 dev ens33          # Supprimer une IP
sudo ip route add 10.10.0.0/16 via 192.168.1.254    # Ajouter une route statique
sudo ip route del 10.10.0.0/16                       # Supprimer une route
sudo ip route add default via 192.168.1.1            # Changer la passerelle
```

> Pour rendre les modifications permanentes : Netplan (Ubuntu), `/etc/network/interfaces` (Debian), `nmcli` (NetworkManager) ou `systemd-networkd`.

---

### `ip neigh` — table ARP

```bash
ip neigh                        # Afficher les voisins ARP connus
```

**Exemple :**

```
192.168.1.1  dev ens33 lladdr 00:50:56:c0:00:08 REACHABLE
192.168.1.15 dev ens33 lladdr 00:0c:29:aa:bb:cc STALE
```

| État | Signification |
|---|---|
| `REACHABLE` | Voisin récemment confirmé |
| `STALE` | À revérifier (cache expiré) |
| `FAILED` | Pas de réponse ARP — machine éteinte ou mauvais VLAN |

---

## 2. ss — sockets et ports ouverts

`ss` (**socket statistics**) lit directement les informations du noyau. Plus rapide que `netstat` et permet des filtres puissants.

### Options à retenir : `-tulpn`

| Option | Signification |
|---|---|
| `-t` | Sockets TCP |
| `-u` | Sockets UDP |
| `-l` | Uniquement les sockets en écoute (listening) |
| `-p` | Affiche le processus associé (nécessite sudo) |
| `-n` | Pas de résolution de noms — affiche `22` et non `ssh` |
| `-a` | Toutes les sockets (écoute + connexions établies) |
| `-s` | Résumé statistique |

```bash
sudo ss -tulpn                  # La commande la plus utilisée
ss -tn state established        # Connexions TCP établies
ss -s                           # Résumé statistique
```

---

### Lire la colonne `Local Address`

| Adresse | Signification |
|---|---|
| `0.0.0.0:22` | Écoute sur toutes les interfaces IPv4 → joignable depuis le réseau |
| `127.0.0.1:8080` | Écoute uniquement en local → invisible de l'extérieur |
| `[::]:22` | Toutes les interfaces IPv6 |
| `192.168.1.20:80` | Écoute uniquement sur cette IP |

---

### Filtres utiles

```bash
ss -tn state established                        # Connexions TCP actives
ss -tn state established '( dport = :443 )'    # Connexions vers port 443
ss -tulpn 'sport = :22'                         # Qui écoute sur le port 22 ?
ss -tn dst 192.168.1.15                         # Connexions vers une IP
ss -tan | grep -c TIME-WAIT                     # Compter les TIME-WAIT
```

---

## 3. Tester la connectivité et le DNS

### `ping` — test ICMP

```bash
ping -c 4 8.8.8.8               # 4 paquets vers Google DNS
ping -c 2 -i 0.2 192.168.1.1    # Intervalle de 0.2 secondes
ping -s 1472 192.168.1.1        # Taille de paquet personnalisée
ping -I ens33 8.8.8.8           # Forcer une interface source
```

> Un ping échoué ne prouve pas que la machine est éteinte : un pare-feu peut bloquer l'ICMP.

---

### Méthode de diagnostic — du plus proche au plus loin

```bash
ping -c2 127.0.0.1          # 1. Pile TCP/IP locale OK ?
ping -c2 192.168.1.20       # 2. Sa propre IP
ping -c2 192.168.1.1        # 3. La passerelle → LAN OK ?
ping -c2 8.8.8.8            # 4. Internet en IP → routage/NAT OK ?
ping -c2 google.com         # 5. Par nom → DNS OK ?
```

**Interprétation :**

| Résultat | Cause probable |
|---|---|
| Étape 1 échoue | Pile réseau locale cassée |
| Étape 3 échoue | Problème LAN, vSwitch ou VLAN |
| Étape 4 passe, étape 5 échoue | Problème DNS uniquement |

---

### `traceroute` et `mtr`

```bash
traceroute -n 8.8.8.8          # Tracer le chemin vers 8.8.8.8 (sans résolution DNS)
traceroute -T -n 8.8.8.8       # Utiliser TCP au lieu d'UDP (contourne certains firewalls)
mtr -rwc 20 8.8.8.8            # Rapport continu — 20 cycles
```

> `* * *` dans traceroute = le routeur ne répond pas (filtrage), ce n'est pas forcément une panne.
> Dans `mtr` : une perte qui persiste jusqu'au **dernier saut** est réelle. Une perte sur un saut intermédiaire seulement est du rate-limiting ICMP.

---

### DNS : `dig`, `nslookup`, `host`

```bash
dig example.com +short              # Réponse courte (IP uniquement)
dig example.com A                   # Enregistrement IPv4
dig example.com MX                  # Serveurs de messagerie
dig example.com NS                  # Serveurs de noms
dig @8.8.8.8 example.com            # Interroger un serveur DNS précis
dig -x 8.8.8.8 +short               # Résolution inverse (PTR)
dig +trace example.com              # Suivre la délégation depuis les racines
```

**Lire la sortie de `dig` :**

| Champ | Signification |
|---|---|
| `status: NOERROR` | Requête réussie |
| `status: NXDOMAIN` | Le nom n'existe pas |
| `status: SERVFAIL` | Erreur côté serveur DNS |
| `TTL` | Durée de mise en cache de la réponse |
| `Query time` | Temps de réponse du serveur DNS |

```bash
nslookup example.com 8.8.8.8        # Interroger un serveur précis (ancien)
host example.com                    # Sortie lisible
host -t MX example.com             # Enregistrement MX uniquement
```

> Si `dig @8.8.8.8 monsite.fr` fonctionne mais `dig monsite.fr` échoue → le résolveur dans `/etc/resolv.conf` est en cause.

---

## 4. tcpdump — capturer le trafic

```bash
sudo tcpdump -i ens33 -nn           # Capturer sur ens33, sans résolution de noms
sudo tcpdump -i any -nn             # Toutes les interfaces
```

### Options principales

| Option | Rôle |
|---|---|
| `-i ens33` | Interface à écouter |
| `-nn` | Pas de résolution DNS ni de noms de ports |
| `-c 10` | S'arrêter après 10 paquets |
| `-v` / `-vv` | Plus de détails |
| `-A` | Contenu en ASCII (utile pour HTTP en clair) |
| `-X` | Contenu en hexadécimal et ASCII |
| `-w fichier.pcap` | Écrire dans un fichier (ouvrable dans Wireshark) |
| `-r fichier.pcap` | Relire un fichier pcap |

---

### Filtres BPF

```bash
sudo tcpdump -i ens33 -nn port 80                           # Trafic sur le port 80
sudo tcpdump -i ens33 -nn host 192.168.1.15                # Vers/depuis une IP
sudo tcpdump -i ens33 -nn src 192.168.1.15                 # Uniquement source
sudo tcpdump -i ens33 -nn net 10.0.0.0/8                   # Un réseau entier
sudo tcpdump -i ens33 -nn icmp                             # Uniquement ping
sudo tcpdump -i ens33 -nn udp port 53                      # Requêtes DNS
sudo tcpdump -i ens33 -nn 'tcp port 22 and host 192.168.1.15'
sudo tcpdump -i ens33 -nn 'port 80 or port 443'
sudo tcpdump -i ens33 -nn 'tcp[tcpflags] & tcp-syn != 0'   # Seulement les SYN
```

---

### Exemple 1 — Observer un ping

```bash
# Terminal 1
sudo tcpdump -i ens33 -nn -c 4 icmp

# Terminal 2
ping -c 2 192.168.1.1
```

Sortie attendue :

```
10:02:11.104 IP 192.168.1.20 > 192.168.1.1: ICMP echo request, seq 1
10:02:11.105 IP 192.168.1.1 > 192.168.1.20: ICMP echo reply, seq 1
```

---

### Exemple 2 — Observer le handshake TCP

```bash
sudo tcpdump -i ens33 -nn 'tcp port 80 and host 192.168.1.15' -c 6
```

**Séquence des flags TCP :**

| Flag | Signification |
|---|---|
| `[S]` | SYN — demande de connexion |
| `[S.]` | SYN-ACK — acceptation |
| `[.]` | ACK — confirmation |
| `[P.]` | PUSH — données envoyées |
| `[F.]` | FIN — fermeture |
| `[R.]` | RST — reset — port fermé ou connexion refusée |

> Un `[S]` qui se répète sans réponse = pare-feu qui filtre ou service absent.
> Un `[R.]` = port fermé.

---

### Exemple 3 — Vérifier le DNS

```bash
# Terminal 1
sudo tcpdump -i ens33 -nn udp port 53

# Terminal 2
dig example.com
```

On voit la requête `A? example.com.` et la réponse avec l'IP.

---

### Sauvegarder pour Wireshark

```bash
sudo tcpdump -i ens33 -w capture.pcap port 443
# Ouvrir capture.pcap dans Wireshark pour analyse graphique
```

---

## 5. curl et wget

### `curl` — tester des services HTTP

```bash
curl http://example.com                                     # Corps de la réponse
curl -I http://example.com                                  # En-têtes uniquement (HEAD)
curl -v http://example.com                                  # Détail complet requête + réponse
curl -s -o /dev/null -w "%{http_code}\n" http://example.com # Juste le code HTTP
curl -L http://example.com                                  # Suit les redirections
curl -k https://192.168.1.15                                # Ignore les erreurs de certificat
curl --max-time 5 http://192.168.1.15                       # Timeout à 5 secondes
```

**Cas d'usage avancés :**

```bash
curl -H "Authorization: Bearer TOKEN" http://api.local/data        # Header custom
curl -X POST -H "Content-Type: application/json" \
     -d '{"nom":"test"}' http://api.local/items                     # POST JSON

curl --resolve monsite.local:80:192.168.1.15 http://monsite.local/ # Tester un vhost sans DNS
curl -H "Host: monsite.local" http://192.168.1.15/                 # Idem

curl -s -o /dev/null -w "DNS:%{time_namelookup}s connect:%{time_connect}s total:%{time_total}s\n" \
     https://example.com                                            # Mesurer les temps
```

---

### Codes HTTP à retenir

| Code | Signification |
|---|---|
| `200` | OK — succès |
| `301` | Redirection permanente |
| `302` | Redirection temporaire |
| `401` | Non authentifié |
| `403` | Accès interdit |
| `404` | Ressource introuvable |
| `500` | Erreur interne du serveur |
| `502` | Bad Gateway |
| `503` | Service indisponible |
| `504` | Timeout de la passerelle |

**Codes d'erreur curl fréquents :**

| Code curl | Cause |
|---|---|
| `(6)` | Could not resolve host — problème DNS |
| `(7)` | Failed to connect — port fermé, service arrêté ou filtré |
| `(28)` | Timeout dépassé |
| `(60)` | Certificat SSL non vérifiable |

---

### `wget` — télécharger des fichiers

```bash
wget http://example.com/fichier.iso                         # Télécharger
wget -O sortie.html http://example.com                      # Nom de fichier choisi
wget -c http://example.com/gros.iso                         # Reprendre un téléchargement
wget --spider http://example.com                            # Vérifier l'existence sans télécharger
wget -S --spider http://example.com                         # Idem avec les en-têtes
wget -r -np -l 2 http://example.com/docs/                   # Téléchargement récursif limité
```

> En règle générale : `curl` pour tester des APIs et diagnostiquer, `wget` pour télécharger des fichiers.

---

## 6. Exercice — Lister et identifier tous les ports ouverts

**Objectif :** Lister tous les ports en écoute sur la VM, identifier chaque service et évaluer son exposition réseau.

---

### Étape 1 — Lister les ports

```bash
sudo ss -tulpn
```

**Exemple de sortie (VM avec SSH, Nginx, MariaDB) :**

```
Netid  State   Local Address:Port   Process
udp    UNCONN  127.0.0.53%lo:53     users:(("systemd-resolve",...))
udp    UNCONN  192.168.1.20%ens33:68 users:(("systemd-network",...))
tcp    LISTEN  0.0.0.0:22           users:(("sshd",...))
tcp    LISTEN  0.0.0.0:80           users:(("nginx",...))
tcp    LISTEN  127.0.0.1:3306       users:(("mariadbd",...))
```

---

### Étape 2 — Identifier chaque service

| Port | Proto | Écoute sur | Processus | Rôle | Exposition |
|---|---|---|---|---|---|
| 53 | UDP+TCP | `127.0.0.53` | systemd-resolved | Résolveur DNS local | ✅ Local uniquement |
| 68 | UDP | IP ens33 | systemd-networkd | Client DHCP | ✅ Normal |
| 22 | TCP | `0.0.0.0` | sshd | Accès SSH distant | ⚠️ Exposé réseau |
| 80 | TCP | `0.0.0.0` | nginx | Serveur web HTTP | ⚠️ Exposé réseau |
| 3306 | TCP | `127.0.0.1` | mariadbd | Base de données | ✅ Local uniquement |

---

### Étape 3 — Vérifier et recouper

```bash
sudo ss -tulpn 'sport = :3306'              # Qui écoute sur 3306 ?
sudo lsof -i :80                            # Autre méthode
ps -fp 845                                  # Détails du processus PID 845
systemctl status mariadb                    # Unité systemd correspondante
grep -w 3306 /etc/services                  # Nom officiel du port
```

**Vérifier depuis l'extérieur (depuis une autre VM) :**

```bash
nmap -sT -p- 192.168.1.20                  # Scanner tous les ports TCP
nc -zv 192.168.1.20 3306                   # Ce port est-il joignable ?
```

**Confirmer avec le trafic :**

```bash
sudo tcpdump -i ens33 -nn port 80 -c 5
# Puis depuis un autre poste : curl http://192.168.1.20
```

---

### Étape 4 — Analyse et principe de moindre exposition

```
Ce qui est joignable du réseau : SSH (22) et HTTP (80) → voulu
Ce qui est local : DNS stub, chrony, MariaDB → correct

Si on voyait 0.0.0.0:3306 → PROBLÈME
  → Corriger : bind-address = 127.0.0.1 dans /etc/mysql/mariadb.conf.d/
  → Ou filtrer avec UFW : sudo ufw deny 3306
```

```bash
sudo systemctl disable --now nom_du_service     # Désactiver un service inutile
```

**Si un port inconnu apparaît :**

```bash
ss -tulpn                               # 1. Identifier le PID
ls -l /proc/PID/exe                     # 2. Retrouver le binaire
dpkg -S /chemin/du/binaire              # 3. Retrouver le paquet
                                        # 4. Décider : garder, restreindre ou supprimer
```

---

## Réflexe de diagnostic

```
Ma machine a-t-elle une IP, une route ?   →  ip -br a    ip r
Le réseau répond-il ?                     →  ping (passerelle → IP externe → nom)
Où ça casse ?                             →  traceroute / mtr
Le nom se résout-il ?                     →  dig
Le service écoute-t-il ?                  →  ss -tulpn
Le service répond-il correctement ?       →  curl -v
Que se passe-t-il sur le fil ?            →  tcpdump -nn
```

---

## Commandes clés apprises

```bash
# ip
ip a              ip -br a          ip a show ens33
ip link           ip -s link show ens33
ip r              ip route get 8.8.8.8
ip neigh
sudo ip addr add 192.168.1.50/24 dev ens33
sudo ip route add 10.0.0.0/8 via 192.168.1.254

# ss
sudo ss -tulpn
ss -tn state established
ss -tulpn 'sport = :22'
ss -s

# ping / traceroute / mtr
ping -c 4 8.8.8.8
traceroute -n 8.8.8.8
mtr -rwc 20 8.8.8.8

# dig
dig example.com +short
dig example.com A
dig @8.8.8.8 example.com
dig -x 8.8.8.8 +short
dig +trace example.com

# tcpdump
sudo tcpdump -i ens33 -nn port 80
sudo tcpdump -i ens33 -nn host 192.168.1.15
sudo tcpdump -i ens33 -nn icmp
sudo tcpdump -i ens33 -nn udp port 53
sudo tcpdump -i ens33 -w capture.pcap port 443

# curl / wget
curl -I http://example.com
curl -v http://example.com
curl -s -o /dev/null -w "%{http_code}\n" http://example.com
wget --spider http://example.com
```

---

## Livrables & preuves

- [ ] Capture de `ip -br a` et `ip r` sur la VM
- [ ] Capture de `sudo ss -tulpn` avec tous les ports identifiés
- [ ] Capture de la méthode de diagnostic `ping` étape par étape
- [ ] Capture de `dig example.com +short` et `dig @8.8.8.8 example.com`
- [ ] Capture tcpdump d'un ping (ICMP request + reply)
- [ ] Capture tcpdump du handshake TCP (SYN, SYN-ACK, ACK)
- [ ] Tableau d'analyse des ports rempli avec les services de ta VM

---

## Difficultés rencontrées & solutions

| Difficulté rencontrée | Solution appliquée |
|---|---|
| `ifconfig` introuvable sur Debian | Utiliser `ip a` — ou installer `net-tools` si vraiment nécessaire |
| `ss -p` n'affiche pas le processus | Ajouter `sudo` — les PID des autres utilisateurs nécessitent les droits root |
| `ping google.com` échoue mais `ping 8.8.8.8` fonctionne | Problème DNS — vérifier `/etc/resolv.conf` et tester avec `dig` |
| `traceroute` bloqué sur `* * *` | Normal si le routeur filtre l'ICMP — utiliser `-T` (TCP) pour contourner |
| `tcpdump` ne capture rien | Vérifier le nom de l'interface avec `ip -br a` — utiliser `-i any` pour toutes |
| `curl` renvoie code `(7)` | Port fermé ou service arrêté — vérifier avec `ss -tulpn` |
| `dig` retourne `NXDOMAIN` | Le nom n'existe pas — tester avec `dig @8.8.8.8` pour isoler le résolveur local |

---

*Semaine 05 terminée · Prochaine étape → [Semaine 06 — DNS (Bind9), DHCP & VPN WireGuard](../06-dns-dhcp-vpn/README.md)*