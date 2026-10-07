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

# Semaine 06 — UFW & iptables : pare-feu sous Linux

> **Phase 2 — Réseaux & Sécurité**
> Rythme : 3 soirs × 45 min · Statut : ✅ Terminé

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

---

*Semaine 06 terminée · Prochaine étape → [Semaine 07 — Active Directory & Windows Server](../07-active-directory/README.md)*


# Semaine 07 — DNS (Bind9) & DHCP

> **Phase 2 — Réseaux & Sécurité**
> Rythme : 3 soirs × 45 min · Statut : ✅ Terminé

---

## Objectif de la semaine

Comprendre l'architecture DNS hiérarchique, installer et configurer Bind9 comme serveur DNS autoritaire pour `lab.internal` (zone directe + zone inverse), déployer isc-dhcp-server avec une plage dynamique et une réservation statique, et valider la chaîne complète depuis un client.

---

## Sommaire

- [1. Comprendre le DNS](#1-comprendre-le-dns)
- [2. Installer et configurer Bind9](#2-installer-et-configurer-bind9)
- [3. DHCP avec isc-dhcp-server](#3-dhcp-avec-isc-dhcp-server)
- [4. Outils de test](#4-outils-de-test)
- [5. Exercice — Lab DNS + DHCP complet](#5-exercice--lab-dns--dhcp-complet)
- [6. Dépannage](#6-dépannage)
- [Commandes clés apprises](#commandes-clés-apprises)
- [Livrables & preuves](#livrables--preuves)
- [Difficultés rencontrées & solutions](#difficultés-rencontrées--solutions)

---

## 1. Comprendre le DNS

### Rôle et hiérarchie

Le DNS traduit des noms (`www.example.com`) en adresses IP et inversement. C'est une base de données **hiérarchique et distribuée** : aucun serveur ne connaît tout, chacun connaît sa zone.

```
                     . (racine)
                     │
        ┌────────────┼────────────┐
       com          org          fr        ← TLD
        │
     example
        │
       www                                 → www.example.com.
```

> Le point final (`example.com.`) représente la racine. Il est **obligatoire** dans les fichiers de zone Bind — son absence est la faute la plus fréquente.

---

### Les acteurs du DNS

| Acteur | Rôle |
|---|---|
| **Stub resolver** | Client sur ta machine (libc, systemd-resolved) — pose la question et attend la réponse finale |
| **Résolveur récursif** | Serveur (FAI, 1.1.1.1, ton bind9) — fait tout le travail de recherche et met en cache |
| **Serveur autoritaire** | Détient la zone, répond de façon définitive pour ses domaines |
| **Serveurs racine / TLD** | N'ont pas la réponse finale — indiquent qui interroger ensuite |

---

### Récursif vs itératif

```
Client ──(récursive: www.example.com ?)──▶ Résolveur (cache vide)
                                               │
                     (itératif) ──▶ Racine     : "demande aux serveurs .com"
                     (itératif) ──▶ Serveur .com : "demande à ns1.example.com"
                     (itératif) ──▶ ns1.example.com : "www = 93.184.216.34"
                                               │
Client ◀────── 93.184.216.34 (mis en cache, TTL) ─┘
```

```bash
dig +trace www.example.com      # Rejouer ce chemin complet
```

---

### Cache et TTL

```bash
dig example.com +noall +answer
# example.com.    3600  IN  A  93.184.216.34
# 10 secondes plus tard :
# example.com.    3590  IN  A  93.184.216.34   ← TTL décroît
```

| TTL | Avantage | Inconvénient |
|---|---|---|
| Long (86400 = 24h) | Moins de trafic | Changement d'IP long à propager |
| Court (300 = 5min) | Changements rapides | Plus de requêtes DNS |

> Avant une migration, baisser le TTL **quelques jours à l'avance**.

---

### Types d'enregistrements

| Type | Rôle | Exemple |
|---|---|---|
| `A` | Nom → IPv4 | `web IN A 192.168.100.20` |
| `AAAA` | Nom → IPv6 | `web IN AAAA 2001:db8::20` |
| `CNAME` | Alias vers un autre nom | `www IN CNAME web.lab.internal.` |
| `MX` | Serveur de messagerie (priorité basse = prioritaire) | `@ IN MX 10 mail.lab.internal.` |
| `TXT` | Texte libre (SPF, DKIM) | `@ IN TXT "v=spf1 mx -all"` |
| `NS` | Serveurs de noms de la zone | `@ IN NS ns1.lab.internal.` |
| `SOA` | Métadonnées de la zone (un seul par zone) | voir ci-dessous |
| `PTR` | IP → Nom (résolution inverse) | `20 IN PTR web.lab.internal.` |
| `SRV` | Localise un service (Active Directory, LDAP) | `_ldap._tcp IN SRV 0 100 389 dc1` |

---

### Le SOA en détail

```
@ IN SOA ns1.lab.internal. admin.lab.internal. (
        2026100101 ; serial   ← version de la zone (AAAAMMJJNN)
        3600       ; refresh  ← fréquence de vérification par les secondaires
        900        ; retry    ← délai si le primaire ne répond pas
        604800     ; expire   ← durée avant qu'un secondaire cesse de répondre
        300 )      ; negative ← TTL du cache négatif (NXDOMAIN)
```

> Le **serial doit être incrémenté à chaque modification** de la zone. Sans ça, les secondaires et `rndc reload` ne voient pas le changement.

---

### Règles importantes

| Règle | Explication |
|---|---|
| CNAME ne coexiste pas avec d'autres enregistrements | Jamais de CNAME sur l'apex `@` |
| MX et NS pointent vers un nom avec enregistrement A | Jamais vers un CNAME ni directement vers une IP |
| DNS utilise UDP/53 et TCP/53 | Les deux doivent être ouverts dans le pare-feu |

---

## 2. Installer et configurer Bind9

### Installation

```bash
sudo apt update
sudo apt install bind9 bind9-utils bind9-dnsutils -y
systemctl status bind9
```

---

### Organisation des fichiers (Debian/Ubuntu)

| Fichier | Rôle |
|---|---|
| `/etc/bind/named.conf` | Fichier principal — inclut les autres |
| `/etc/bind/named.conf.options` | Options globales (écoute, forwarders, ACL) |
| `/etc/bind/named.conf.local` | Tes zones |
| `/etc/bind/named.conf.default-zones` | Zones par défaut (localhost, racine) |
| `/var/cache/bind/` | Cache et zones secondaires |

---

### Les trois rôles d'un serveur DNS

| Rôle | Description |
|---|---|
| **Autoritaire** | Répond pour ses propres zones (`lab.internal`) |
| **Récursif / cache** | Résout aussi `google.com` pour les clients |
| **Forwarder** | Délègue la récursion externe à un résolveur amont (1.1.1.1) |

> ⚠️ Un résolveur récursif ouvert à tout Internet peut servir aux attaques DDoS par amplification. **Toujours limiter la récursion au LAN**.

---

### `named.conf.options`

```
acl "lan" {
    127.0.0.1;
    192.168.100.0/24;
};

options {
    directory "/var/cache/bind";

    listen-on { 127.0.0.1; 192.168.100.10; };
    listen-on-v6 { none; };

    allow-query     { lan; };
    recursion yes;
    allow-recursion { lan; };

    forwarders { 1.1.1.1; 9.9.9.9; };
    dnssec-validation auto;
};
```

> `listen-on` précis évite le conflit avec `systemd-resolved` qui écoute déjà sur `127.0.0.53:53`.

---

### `named.conf.local` — déclarer les zones

```
zone "lab.internal" {
    type primary;
    file "/etc/bind/zones/db.lab.internal";
    allow-transfer { none; };
};

zone "100.168.192.in-addr.arpa" {
    type primary;
    file "/etc/bind/zones/db.192.168.100";
    allow-transfer { none; };
};
```

**Construire le nom de zone inverse :**

```
192.168.100.0/24  →  écrire les octets à l'envers  →  100.168.192.in-addr.arpa
10.0.0.0/8        →  10.in-addr.arpa
172.16.5.0/24     →  5.16.172.in-addr.arpa
```

---

### Fichier de zone directe

```bash
sudo mkdir -p /etc/bind/zones
sudo nano /etc/bind/zones/db.lab.internal
```

```
$TTL 86400
@   IN  SOA ns1.lab.internal. admin.lab.internal. (
            2026100101  ; serial
            3600        ; refresh
            900         ; retry
            604800      ; expire
            300 )       ; negative cache TTL

; Serveurs de noms
@       IN  NS      ns1.lab.internal.

; Messagerie et texte
@       IN  MX  10  mail.lab.internal.
@       IN  TXT     "v=spf1 mx -all"

; Enregistrements A
ns1     IN  A       192.168.100.10
web     IN  A       192.168.100.20
db      IN  A       192.168.100.21
mail    IN  A       192.168.100.25

; Alias
www     IN  CNAME   web.lab.internal.
```

**Pièges fréquents :**

| Piège | Explication |
|---|---|
| `ns1.lab.internal.` avec point final | Nom absolu — sans le point, Bind ajoute la zone et obtient `ns1.lab.internal.lab.internal.` |
| `ns1` sans point | Nom relatif — Bind ajoute automatiquement `.lab.internal` |
| `@` | Désigne la zone elle-même (`lab.internal.`) |

---

### Fichier de zone inverse

```bash
sudo nano /etc/bind/zones/db.192.168.100
```

```
$TTL 86400
@   IN  SOA ns1.lab.internal. admin.lab.internal. (
            2026100101
            3600
            900
            604800
            300 )

@       IN  NS      ns1.lab.internal.

10      IN  PTR     ns1.lab.internal.
20      IN  PTR     web.lab.internal.
21      IN  PTR     db.lab.internal.
25      IN  PTR     mail.lab.internal.
```

> `20 IN PTR web.lab.internal.` → désigne `20.100.168.192.in-addr.arpa.` → donc l'IP `192.168.100.20`.

---

### Valider, démarrer, recharger

```bash
sudo named-checkconf && echo "named.conf OK"
sudo named-checkzone lab.internal /etc/bind/zones/db.lab.internal
sudo named-checkzone 100.168.192.in-addr.arpa /etc/bind/zones/db.192.168.100

sudo systemctl restart bind9
sudo systemctl enable bind9
sudo ss -tulpn | grep :53                   # Vérifier que bind écoute sur 53
```

**Modifier une zone sans redémarrer :**

```bash
# 1. Éditer le fichier et incrémenter le serial
# 2. Vérifier
sudo named-checkzone lab.internal /etc/bind/zones/db.lab.internal
# 3. Recharger une seule zone
sudo rndc reload lab.internal
sudo rndc flush                             # Vider le cache si besoin
```

---

## 3. DHCP avec isc-dhcp-server

### Le protocole DORA

```
Client                              Serveur DHCP
  │──── DISCOVER (broadcast) ───────▶│  "Quelqu'un a une IP pour moi ?"
  │◀─── OFFER  (192.168.100.100) ────│  "Je te propose celle-ci"
  │──── REQUEST ────────────────────▶│  "Je prends celle-là"
  │◀─── ACK (bail + options) ────────│  "Confirmé pour X secondes"
```

| Port | Rôle |
|---|---|
| UDP/67 | Serveur DHCP |
| UDP/68 | Client DHCP |

> ISC DHCP est en fin de vie (remplacé par Kea depuis 2022) mais reste le plus enseigné. Les concepts sont identiques dans Kea.

---

### Installation

```bash
sudo apt install isc-dhcp-server -y
```

---

### Étape 1 — Choisir l'interface d'écoute

```bash
sudo nano /etc/default/isc-dhcp-server
```

```
INTERFACESv4="ens34"
INTERFACESv6=""
```

> Le serveur DHCP doit écouter **uniquement sur l'interface du réseau interne**. Jamais sur l'interface NAT (sinon conflit avec le DHCP de la box ou de VMware).

---

### Étape 2 — `/etc/dhcp/dhcpd.conf`

```
authoritative;
ddns-update-style none;

default-lease-time 600;
max-lease-time 7200;

subnet 192.168.100.0 netmask 255.255.255.0 {
    range 192.168.100.100 192.168.100.150;
    option routers 192.168.100.1;
    option domain-name-servers 192.168.100.10;
    option domain-name "lab.internal";
    option broadcast-address 192.168.100.255;
}

host web {
    hardware ethernet 00:0c:29:aa:bb:cc;
    fixed-address 192.168.100.20;
}
```

**Points clés :**

| Directive | Rôle |
|---|---|
| `authoritative` | Ce serveur fait référence — répond NAK aux demandes invalides |
| `range` | Plage d'IPs dynamiques (.100 à .150) |
| `option routers` | Passerelle envoyée aux clients |
| `option domain-name-servers` | Adresse du DNS (notre bind9) |
| `host` + `hardware ethernet` | Réservation statique par adresse MAC |

> La réservation doit être **hors de la plage dynamique** (`.20` hors de `.100-.150`).

---

### Étape 3 — Valider et démarrer

```bash
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf         # Test de syntaxe
sudo systemctl enable --now isc-dhcp-server
sudo systemctl status isc-dhcp-server
sudo ss -ulpn | grep :67                        # Vérifier l'écoute
```

---

### Voir les baux actifs

```bash
sudo dhcp-lease-list                            # Résumé lisible
sudo cat /var/lib/dhcp/dhcpd.leases             # Fichier brut
sudo journalctl -u isc-dhcp-server -f           # Logs en direct
```

---

### Piège VMware

Si tu utilises un réseau VMware host-only ou NAT, VMware lance son propre DHCP — deux DHCP sur le même segment répondent à tour de rôle.

**Désactiver le DHCP VMware :**

```
Virtual Network Editor → VMnet concerné → décocher "Use local DHCP service"
```

---

## 4. Outils de test

### `dig` — interroger le serveur DNS

```bash
dig @localhost web.lab.internal +short          # Réponse courte
dig @localhost www.lab.internal +short          # Suit le CNAME automatiquement
dig @localhost -x 192.168.100.20 +short         # Résolution inverse (PTR)
dig @localhost lab.internal MX +short           # Enregistrement MX
dig @localhost lab.internal NS +short           # Serveurs de noms
dig @localhost lab.internal SOA +short          # Enregistrement SOA
dig @localhost lab.internal TXT +short          # Enregistrement TXT
dig @localhost google.com +short                # Test récursion + forwarders
dig @localhost lab.internal AXFR                # Transfert de zone (doit être refusé)
dig +trace www.example.com                      # Suivre la délégation depuis les racines
```

**Lire la sortie complète de `dig` :**

| Champ | Signification |
|---|---|
| `status: NOERROR` | Réponse OK |
| `status: NXDOMAIN` | Nom inexistant |
| `status: SERVFAIL` | Problème côté serveur (zone qui ne charge pas) |
| `status: REFUSED` | ACL qui refuse le client |
| `flags: aa` | Authoritative Answer — réponse depuis la propre zone |
| `flags: ra` | Recursion Available — récursion disponible |

```bash
dig @localhost web.lab.internal | grep flags
# flags: qr aa rd ra   ← aa confirme que c'est une réponse autoritaire
```

---

### `nslookup` et `host`

```bash
nslookup web.lab.internal localhost
nslookup 192.168.100.20 localhost               # Résolution inverse
nslookup -type=MX lab.internal localhost
host web.lab.internal localhost
```

---

### Contrôles côté serveur

```bash
sudo named-checkconf                                                   # Syntaxe named.conf
sudo named-checkzone lab.internal /etc/bind/zones/db.lab.internal      # Syntaxe zone directe
sudo named-checkzone 100.168.192.in-addr.arpa /etc/bind/zones/db.192.168.100

sudo rndc reload                                # Recharger toutes les zones
sudo rndc reload lab.internal                   # Recharger une seule zone
sudo rndc flush                                 # Vider le cache
sudo rndc status
sudo journalctl -u bind9 -f
```

---

## 5. Exercice — Lab DNS + DHCP complet

### Plan d'adressage

| Machine | Rôle | IP |
|---|---|---|
| `ns1` | Serveur DNS + DHCP | `192.168.100.10` (statique) |
| `web` | Serveur web (réservation DHCP) | `192.168.100.20` |
| `db` | Base de données | `192.168.100.21` |
| `mail` | Serveur messagerie | `192.168.100.25` |
| `client1` | Poste de test | DHCP : `.100` à `.150` |

Réseau : `192.168.100.0/24` · ns1 a deux interfaces : `ens33` (NAT) et `ens34` (réseau interne).

---

### Étape 1 — IP statique sur ns1 (Netplan)

```bash
sudo nano /etc/netplan/50-cloud-init.yaml
```

```yaml
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: true
    ens34:
      dhcp4: false
      addresses: [192.168.100.10/24]
```

```bash
sudo netplan apply
ip -br a                        # Vérifier : ens34 a 192.168.100.10/24
```

---

### Étape 2 — Installer Bind9

```bash
sudo apt install bind9 bind9-utils bind9-dnsutils -y
```

---

### Étape 3 — Options globales

```bash
sudo nano /etc/bind/named.conf.options
```

```
acl "lan" {
    127.0.0.1;
    192.168.100.0/24;
};

options {
    directory "/var/cache/bind";

    listen-on { 127.0.0.1; 192.168.100.10; };
    listen-on-v6 { none; };

    allow-query     { lan; };
    recursion yes;
    allow-recursion { lan; };

    forwarders { 1.1.1.1; 9.9.9.9; };
    dnssec-validation auto;
};
```

---

### Étape 4 — Déclarer les zones

```bash
sudo nano /etc/bind/named.conf.local
```

```
zone "lab.internal" {
    type primary;
    file "/etc/bind/zones/db.lab.internal";
    allow-transfer { none; };
};

zone "100.168.192.in-addr.arpa" {
    type primary;
    file "/etc/bind/zones/db.192.168.100";
    allow-transfer { none; };
};
```

---

### Étape 5 — Zone directe

```bash
sudo mkdir -p /etc/bind/zones
sudo nano /etc/bind/zones/db.lab.internal
```

```
$TTL 86400
@   IN  SOA ns1.lab.internal. admin.lab.internal. (
            2026100101  ; serial
            3600        ; refresh
            900         ; retry
            604800      ; expire
            300 )       ; negative cache TTL

@       IN  NS      ns1.lab.internal.
@       IN  MX  10  mail.lab.internal.
@       IN  TXT     "v=spf1 mx -all"

ns1     IN  A       192.168.100.10
web     IN  A       192.168.100.20
db      IN  A       192.168.100.21
mail    IN  A       192.168.100.25

www     IN  CNAME   web.lab.internal.
```

---

### Étape 6 — Zone inverse

```bash
sudo nano /etc/bind/zones/db.192.168.100
```

```
$TTL 86400
@   IN  SOA ns1.lab.internal. admin.lab.internal. (
            2026100101
            3600
            900
            604800
            300 )

@       IN  NS      ns1.lab.internal.

10      IN  PTR     ns1.lab.internal.
20      IN  PTR     web.lab.internal.
21      IN  PTR     db.lab.internal.
25      IN  PTR     mail.lab.internal.
```

---

### Étape 7 — Valider et démarrer Bind9

```bash
sudo named-checkconf && echo "named.conf OK"
sudo named-checkzone lab.internal /etc/bind/zones/db.lab.internal
sudo named-checkzone 100.168.192.in-addr.arpa /etc/bind/zones/db.192.168.100

sudo systemctl restart bind9
sudo systemctl enable bind9
sudo ss -tulpn | grep :53
```

---

### Étape 8 — Tests DNS

```bash
dig @localhost web.lab.internal +short
# 192.168.100.20

dig @localhost www.lab.internal +short
# web.lab.internal.
# 192.168.100.20

dig @localhost -x 192.168.100.20 +short
# web.lab.internal.

dig @localhost lab.internal MX +short
# 10 mail.lab.internal.

dig @localhost lab.internal SOA +short
# ns1.lab.internal. admin.lab.internal. 2026100101 3600 900 604800 300

dig @localhost inexistant.lab.internal | grep status
# status: NXDOMAIN

dig @localhost google.com +short
# 142.250.xx.xx   ← forwarders + récursion fonctionnent

dig @localhost lab.internal AXFR
# Transfer failed.   ← transfert refusé (allow-transfer { none; })
```

**Test du cache :**

```bash
dig @localhost google.com | grep "Query time"
# 1ère requête : Query time: 45 msec

dig @localhost google.com | grep "Query time"
# 2ème requête : Query time: 0 msec   ← réponse depuis le cache
```

---

### Étape 9 — Installer le DHCP

```bash
sudo apt install isc-dhcp-server -y

sudo nano /etc/default/isc-dhcp-server
# INTERFACESv4="ens34"
```

```bash
sudo nano /etc/dhcp/dhcpd.conf
```

```
authoritative;
ddns-update-style none;

default-lease-time 600;
max-lease-time 7200;

subnet 192.168.100.0 netmask 255.255.255.0 {
    range 192.168.100.100 192.168.100.150;
    option routers 192.168.100.1;
    option domain-name-servers 192.168.100.10;
    option domain-name "lab.internal";
    option broadcast-address 192.168.100.255;
}

host web {
    hardware ethernet 00:0c:29:aa:bb:cc;
    fixed-address 192.168.100.20;
}
```

```bash
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf
sudo systemctl enable --now isc-dhcp-server
sudo ss -ulpn | grep :67
```

---

### Étape 10 — Ouvrir le pare-feu (lien avec semaine 06)

```bash
sudo ufw allow from 192.168.100.0/24 to any port 53          # DNS (TCP + UDP)
sudo ufw allow in on ens34 to any port 67 proto udp           # DHCP
sudo ufw status verbose
```

---

### Étape 11 — Test côté client

```bash
# Sur client1 — activer DHCP sur l'interface
sudo netplan apply
ip -br a                        # IP dans 192.168.100.100-150
ip r                            # default via 192.168.100.1
resolvectl status ens33         # DNS Server: 192.168.100.10

# Résolution sans préciser le serveur
dig web.lab.internal +short     # 192.168.100.20
ping -c2 web.lab.internal
nslookup mail.lab.internal
```

---

### Étape 12 — Observer côté serveur

```bash
sudo dhcp-lease-list
# MAC                IP                hostname   valid until
# 00:0c:29:11:22:33  192.168.100.101   client1    ...

sudo journalctl -u isc-dhcp-server -n 20
# DHCPDISCOVER from 00:0c:29:11:22:33 via ens34
# DHCPOFFER on 192.168.100.101 to 00:0c:29:11:22:33
# DHCPREQUEST for 192.168.100.101 from ...
# DHCPACK on 192.168.100.101 to ...
```

**Observer les 4 étapes DORA avec tcpdump :**

```bash
sudo tcpdump -i ens34 -nn 'port 67 or port 68' -c 8
# 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request  (Discover)
# 192.168.100.10.67 > 192.168.100.101.68: BOOTP/DHCP, Reply (Offer)
# ...
```

**Observer les requêtes DNS :**

```bash
sudo tcpdump -i ens34 -nn udp port 53
# client : A? web.lab.internal.
# serveur : A 192.168.100.20
```

---

### Étape 13 — Modifier une zone

```bash
# 1. Éditer le fichier
sudo nano /etc/bind/zones/db.lab.internal
# Ajouter : app IN A 192.168.100.30
# Incrémenter le serial : 2026100101 → 2026100102

# 2. Vérifier
sudo named-checkzone lab.internal /etc/bind/zones/db.lab.internal

# 3. Recharger
sudo rndc reload lab.internal

# 4. Tester
dig @localhost app.lab.internal +short
# 192.168.100.30
```

---

## 6. Dépannage

| Symptôme | Cause probable | Solution |
|---|---|---|
| bind9 ne démarre pas | Erreur de syntaxe | `named-checkconf` + `journalctl -u bind9` |
| `address already in use` | Conflit avec systemd-resolved sur le port 53 | Restreindre `listen-on` à `127.0.0.1` + IP du serveur |
| Zone non chargée, SERVFAIL | Erreur dans le fichier de zone | `named-checkzone` |
| NXDOMAIN pour un nom déclaré | Point final oublié **ou** serial non incrémenté | Relire le fichier + `rndc reload` |
| REFUSED | Client non dans l'ACL | Vérifier `allow-query` et `allow-recursion` |
| Pas de `aa` dans la réponse | Réponse depuis le cache | Vérifier la déclaration de la zone |
| Résolution externe KO | Forwarders injoignables | `ping 1.1.1.1` depuis ns1 |
| Client n'obtient pas d'IP | Mauvaise interface ou DHCP VMware actif | `journalctl -u isc-dhcp-server` + désactiver DHCP VMware |
| Client reçoit une IP inattendue | Second serveur DHCP répond | `nmap --script broadcast-dhcp-discover` |
| DHCP refuse de démarrer | Pas d'IP statique dans le sous-réseau déclaré | L'interface doit avoir une IP dans `192.168.100.0/24` |
| IP obtenue mais pas de résolution | `option domain-name-servers` absent | Relire `dhcpd.conf` + `resolvectl status` |

---

## Commandes clés apprises

```bash
# Bind9
sudo apt install bind9 bind9-utils bind9-dnsutils
sudo named-checkconf
sudo named-checkzone lab.internal /etc/bind/zones/db.lab.internal
sudo systemctl restart bind9
sudo rndc reload lab.internal
sudo rndc flush
sudo rndc status

# dig
dig @localhost web.lab.internal +short
dig @localhost -x 192.168.100.20 +short
dig @localhost lab.internal MX +short
dig @localhost lab.internal SOA +short
dig +trace www.example.com
dig @localhost google.com | grep "Query time"

# nslookup / host
nslookup web.lab.internal localhost
nslookup -type=MX lab.internal localhost
host web.lab.internal localhost

# DHCP
sudo apt install isc-dhcp-server
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf
sudo systemctl enable --now isc-dhcp-server
sudo dhcp-lease-list
sudo cat /var/lib/dhcp/dhcpd.leases
sudo journalctl -u isc-dhcp-server -f

# Tcpdump DNS + DHCP
sudo tcpdump -i ens34 -nn udp port 53
sudo tcpdump -i ens34 -nn 'port 67 or port 68' -c 8
```

---

## Livrables & preuves

- [ ] Capture de `sudo ss -tulpn | grep :53` — bind9 écoute sur 53
- [ ] Capture de `dig @localhost web.lab.internal +short` → `192.168.100.20`
- [ ] Capture de `dig @localhost -x 192.168.100.20 +short` → `web.lab.internal.`
- [ ] Capture de `dig @localhost www.lab.internal +short` → CNAME suivi
- [ ] Capture de `dig @localhost google.com` — 1ère (45ms) vs 2ème requête (0ms)
- [ ] Capture de `dig @localhost lab.internal AXFR` → `Transfer failed.`
- [ ] Capture de `sudo dhcp-lease-list` avec un bail actif
- [ ] Capture de `sudo journalctl -u isc-dhcp-server` montrant les 4 étapes DORA
- [ ] Capture tcpdump des échanges DORA (ports 67/68)

---

## Difficultés rencontrées & solutions

| Difficulté rencontrée | Solution appliquée |
|---|---|
| bind9 refuse de démarrer — `address already in use` | Restreindre `listen-on` à `127.0.0.1; 192.168.100.10;` au lieu de `0.0.0.0` |
| NXDOMAIN pour un nom pourtant déclaré | Oubli du point final sur un enregistrement NS ou MX — ex: `ns1.lab.internal` sans point |
| Serial non incrémenté — zone non rechargée | Toujours incrémenter le serial AVANT `rndc reload` |
| Client n'obtient pas d'IP | DHCP VMware actif sur le même VMnet — désactivé dans Virtual Network Editor |
| Réservation DHCP ignorée | IP de réservation dans la plage dynamique — déplacée hors de `range` |
| `dig @localhost google.com` échoue | ns1 n'avait pas d'accès Internet via ens33 — vérifier la route par défaut |

---

*Semaine 07 terminée · Prochaine étape → [Semaine 08 — Active Directory & Windows Server](../08-active-directory/README.md)*

# Semaine 08 — VPN WireGuard

> **Phase 2 — Réseaux & Sécurité**
> Rythme : 3 soirs × 45 min · Statut : ✅ Terminé

---

## Objectif de la semaine

Comprendre le fonctionnement d'un VPN, installer WireGuard sur deux VMs, générer les paires de clés, configurer le tunnel, activer le forwarding IP et valider le chiffrement avec tcpdump. Aller plus loin avec le split tunnel et le full tunnel.

---

## Sommaire

- [1. WireGuard vs OpenVPN](#1-wireguard-vs-openvpn)
- [2. Concepts WireGuard](#2-concepts-wireguard)
- [3. Installation et génération des clés](#3-installation-et-génération-des-clés)
- [4. Exercice — Tunnel WireGuard entre deux VMs](#4-exercice--tunnel-wireguard-entre-deux-vms)
- [5. Pour aller plus loin](#5-pour-aller-plus-loin)
- [6. Dépannage](#6-dépannage)
- [Commandes clés apprises](#commandes-clés-apprises)
- [Livrables & preuves](#livrables--preuves)
- [Difficultés rencontrées & solutions](#difficultés-rencontrées--solutions)

---

## 1. WireGuard vs OpenVPN

### Principe d'un VPN

Un VPN crée une interface réseau virtuelle (`wg0`, `tun0`) dont le trafic est **chiffré puis encapsulé** dans des paquets UDP envoyés à travers le réseau réel.

```
VM client                                            VM serveur
10.8.0.2  ──▶ [wg0] ══ chiffré, UDP/51820 ══▶ [wg0]  10.8.0.1
              (192.168.100.11)  réseau réel  (192.168.100.10)
```

---

### Comparaison WireGuard vs OpenVPN

| Critère | WireGuard | OpenVPN |
|---|---|---|
| Code | ~4 000 lignes, audit facile | Plusieurs centaines de milliers de lignes |
| Intégration | Module du noyau Linux (depuis 5.6) | Processus en espace utilisateur |
| Cryptographie | Fixe et moderne : Curve25519, ChaCha20-Poly1305, BLAKE2s | Négociable (TLS, nombreux chiffrements) |
| Protocole | UDP uniquement | UDP ou TCP (443/TCP traverse presque tous les pare-feux) |
| Configuration | Un fichier de ~10 lignes | Fichier long, souvent une PKI |
| Performances | Très bonnes, faible latence | Correctes, plus coûteux en CPU |
| Itinérance (roaming) | Changement d'IP sans coupure | Reconnexion nécessaire |
| Discrétion | Invisible aux scans (ne répond pas aux paquets non authentifiés) | Répond au handshake TLS |
| Authentification | Une clé publique par pair | Certificats, login/mot de passe, LDAP, 2FA |

---

### Pourquoi WireGuard est devenu le standard

- **Simplicité** : peu de code = moins de bugs et de mauvaises configurations
- **Pas de négociation d'algorithmes** : pas d'attaque par rétrogradation possible
- **Performance** : exécuté dans le noyau, handshake rapide (framework Noise)
- **Natif** : Linux, Windows, macOS, Android, iOS, BSD, pfSense, OPNsense

---

### Limites à connaître

| Limite | Explication |
|---|---|
| UDP seulement | Bloqué sur certains réseaux d'entreprise ou publics |
| Pas d'IP dynamique | Chaque pair a une IP VPN fixe déclarée à la main |
| Pas d'auth utilisateur native | Pas de login/mot de passe, pas de 2FA — l'identité = la clé |
| Vie privée | Le serveur garde en mémoire l'IP publique de chaque client |

> OpenVPN reste pertinent pour le TCP/443 ou une intégration annuaire (LDAP, 2FA).

---

## 2. Concepts WireGuard

### Une paire de clés par machine

Chaque pair possède une **clé privée** (secrète, ne quitte jamais la machine) et une **clé publique** (dérivée de la privée, à donner à l'autre pair). Même modèle que SSH avec `authorized_keys`.

---

### Sections `[Interface]` et `[Peer]`

| Section | Champ | Rôle |
|---|---|---|
| `[Interface]` | `Address` | IP de la machine dans le VPN |
| | `PrivateKey` | Clé privée locale |
| | `ListenPort` | Port UDP d'écoute (51820 par convention) |
| | `DNS` | DNS actif tant que le VPN est actif (géré par wg-quick) |
| | `PostUp` / `PostDown` | Commandes exécutées à l'activation/désactivation |
| `[Peer]` | `PublicKey` | Clé publique du pair distant |
| | `Endpoint` | IP:port réel du pair (indispensable côté client) |
| | `AllowedIPs` | Routage sortant + filtre entrant (voir ci-dessous) |
| | `PersistentKeepalive` | Paquet toutes les N secondes pour maintenir le NAT ouvert (`25` est la valeur usuelle) |
| | `PresharedKey` | Secret symétrique optionnel en couche supplémentaire |

---

### `AllowedIPs` — le concept central

`AllowedIPs` joue **deux rôles simultanément** :

- **Table de routage (sortant)** : tout paquet vers ces IP est chiffré et envoyé à ce pair
- **Filtre (entrant)** : un paquet reçu de ce pair dont l'IP source n'est pas dans cette liste est jeté

C'est le **cryptokey routing**.

| `AllowedIPs` côté client | Effet |
|---|---|
| `10.8.0.1/32` | Seul le serveur est joignable via le VPN |
| `10.8.0.0/24` | Tout le réseau VPN |
| `10.8.0.0/24, 192.168.200.0/24` | Le VPN + un LAN derrière le serveur (split tunnel) |
| `0.0.0.0/0, ::/0` | Tout le trafic passe par le VPN (full tunnel) |

> Côté serveur, `AllowedIPs = 10.8.0.2/32` signifie « ce pair n'a le droit d'utiliser que l'IP 10.8.0.2 » — empêche l'usurpation d'IP.

---

### Sans connexion, sans démon

WireGuard n'a pas de notion de session établie. L'interface est toujours "up" et le handshake se déclenche au **premier paquet** à envoyer, puis se renouvelle toutes les ~2 minutes.

> `wg show` n'affiche pas de `latest handshake` tant qu'aucun trafic n'a circulé. **Lancer un ping avant de lire `wg show`**.

---

## 3. Installation et génération des clés

### Installation (sur les deux VMs)

```bash
sudo apt update
sudo apt install wireguard -y

wg --version
sudo modprobe wireguard && lsmod | grep wireguard      # Module chargé
```

> Sur Ubuntu 20.04+ et Debian 11+, le module est déjà dans le noyau.

---

### Générer les clés

```bash
sudo mkdir -p /etc/wireguard
cd /etc/wireguard
umask 077                                               # Fichiers créés en 600
wg genkey | sudo tee privatekey | wg pubkey | sudo tee publickey
```

**Décortiqué :**

```
wg genkey      → génère une clé privée (base64, 44 caractères)
tee privatekey → écrit dans le fichier ET transmet à la suite
wg pubkey      → calcule la clé publique correspondante
```

```bash
sudo ls -l /etc/wireguard
# -rw------- 1 root root 45 ...  privatekey
# -rw------- 1 root root 45 ...  publickey

sudo cat publickey
# 7Jq4Z...hQ8=
```

**Clé pré-partagée (optionnelle, couche symétrique supplémentaire) :**

```bash
wg genpsk | sudo tee presharedkey
```

---

### Règles de sécurité des clés

| Règle | Explication |
|---|---|
| Ne jamais partager la clé privée | Pas de dépôt Git, pas de capture d'écran |
| Seules les clés publiques s'échangent | Entre les VMs uniquement |
| Permissions `600`, propriété `root` | `sudo chmod 600 /etc/wireguard/*` |

---

## 4. Exercice — Tunnel WireGuard entre deux VMs

### Plan d'adressage

| Élément | Valeur |
|---|---|
| Réseau hôte (host-only) | `192.168.100.0/24` |
| VM-A (serveur) | `192.168.100.10` |
| VM-B (client) | `192.168.100.11` |
| Réseau VPN | `10.8.0.0/24` |
| IP VPN serveur | `10.8.0.1` |
| IP VPN client | `10.8.0.2` |
| Port | `51820/udp` |

---

### Étape 0 — Vérifier la connectivité sous-jacente

```bash
# Sur VM-B
ping -c2 192.168.100.10
```

> Le VPN ne fonctionnera que si les deux VMs se voient déjà en IP réelle.

---

### Étape 1 — Générer les clés (sur chaque VM)

```bash
# VM-A (serveur)
cd /etc/wireguard && umask 077
wg genkey | sudo tee server_private.key | wg pubkey | sudo tee server_public.key
sudo cat server_public.key          # noter la clé publique du serveur

# VM-B (client)
cd /etc/wireguard && umask 077
wg genkey | sudo tee client_private.key | wg pubkey | sudo tee client_public.key
sudo cat client_public.key          # noter la clé publique du client
```

> Dans la suite : `<SRV_PRIV>`, `<SRV_PUB>`, `<CLI_PRIV>`, `<CLI_PUB>` désignent le contenu de ces fichiers.

---

### Étape 2 — Configuration du serveur (VM-A)

```bash
sudo nano /etc/wireguard/wg0.conf
```

```ini
[Interface]
Address = 10.8.0.1/24
ListenPort = 51820
PrivateKey = <SRV_PRIV>

[Peer]
# client1
PublicKey = <CLI_PUB>
AllowedIPs = 10.8.0.2/32
```

```bash
sudo chmod 600 /etc/wireguard/wg0.conf
```

> Le serveur écoute sur le port 51820, se donne l'IP 10.8.0.1, et accepte un seul pair — identifié par sa clé publique — qui n'a le droit d'utiliser que l'IP 10.8.0.2.

---

### Étape 3 — Configuration du client (VM-B)

```bash
sudo nano /etc/wireguard/wg0.conf
```

```ini
[Interface]
Address = 10.8.0.2/24
PrivateKey = <CLI_PRIV>

[Peer]
# serveur
PublicKey = <SRV_PUB>
Endpoint = 192.168.100.10:51820
AllowedIPs = 10.8.0.0/24
PersistentKeepalive = 25
```

```bash
sudo chmod 600 /etc/wireguard/wg0.conf
```

> **Erreur fréquente** : mettre la clé privée du serveur dans `[Peer]`. Dans `[Peer]`, c'est **toujours la clé publique de l'autre machine**.

---

### Étape 4 — Activer le forwarding IP (serveur)

```bash
# Temporaire (perdu au reboot)
sudo sysctl -w net.ipv4.ip_forward=1

# Permanent
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-wireguard.conf
sudo sysctl --system

# Vérification
cat /proc/sys/net/ipv4/ip_forward          # doit afficher 1
sysctl net.ipv4.ip_forward                 # net.ipv4.ip_forward = 1
```

> Le forwarding est obligatoire dès que le serveur relaie du trafic (LAN derrière lui ou full tunnel).

---

### Étape 5 — Ouvrir le pare-feu (si UFW actif)

```bash
# Sur le serveur uniquement
sudo ufw allow 51820/udp comment 'WireGuard'
sudo ufw allow in on wg0 comment 'trafic VPN'
sudo ufw status verbose
```

> Le client n'a rien à ouvrir — il initie la connexion, les réponses passent par le suivi de connexion.

---

### Étape 6 — Démarrer le tunnel

```bash
# Sur serveur ET client
sudo wg-quick up wg0
# [#] ip link add wg0 type wireguard
# [#] wg setconf wg0 /dev/fd/63
# [#] ip -4 address add 10.8.0.1/24 dev wg0
# [#] ip link set mtu 1420 up dev wg0

# Activer au démarrage
sudo systemctl enable --now wg-quick@wg0
sudo systemctl status wg-quick@wg0

# Arrêter le tunnel
sudo wg-quick down wg0
```

---

### Étape 7 — Tests

#### 7.1 — Interface et routes

```bash
ip -br a show wg0
# wg0   UNKNOWN   10.8.0.2/24    ← UNKNOWN est normal (pas de lien physique)

ip r
# 10.8.0.0/24 dev wg0 proto kernel scope link src 10.8.0.2

ip route get 10.8.0.1
# 10.8.0.1 dev wg0 src 10.8.0.2
```

---

#### 7.2 — Ping à travers le tunnel

```bash
# Depuis le client
ping -c 4 10.8.0.1
# 64 bytes from 10.8.0.1: icmp_seq=1 ttl=64 time=0.9 ms

# Depuis le serveur
ping -c 4 10.8.0.2
```

---

#### 7.3 — État du tunnel avec `wg show`

```bash
sudo wg show
```

```
interface: wg0
  public key: <SRV_PUB>
  private key: (hidden)
  listening port: 51820

peer: <CLI_PUB>
  endpoint: 192.168.100.11:49821
  allowed ips: 10.8.0.2/32
  latest handshake: 12 seconds ago
  transfer: 1.45 KiB received, 1.12 KiB sent
```

**Indicateurs clés :**

| Indicateur | Signification |
|---|---|
| `latest handshake` récent | Tunnel établi ✅ |
| `latest handshake` absent | Aucun échange cryptographique — lancer un ping d'abord |
| `transfer` monte des deux côtés | Trafic bidirectionnel ✅ |
| `sent` monte mais pas `received` | Paquets partent mais aucune réponse ne revient |
| `endpoint` côté serveur | IP réelle du client, apprise dynamiquement |

---

#### 7.4 — Prouver le chiffrement avec tcpdump

```bash
# Terminal 1 : interface RÉELLE → trafic chiffré
sudo tcpdump -i ens33 -nn udp port 51820 -c 4
# IP 192.168.100.11.49821 > 192.168.100.10.51820: UDP, length 128
# IP 192.168.100.10.51820 > 192.168.100.11.49821: UDP, length 128

# Terminal 2 : interface VIRTUELLE → trafic en clair
sudo tcpdump -i wg0 -nn icmp -c 4
# IP 10.8.0.2 > 10.8.0.1: ICMP echo request, seq 1
# IP 10.8.0.1 > 10.8.0.2: ICMP echo reply, seq 1
```

> Sur `ens33` : paquets UDP opaques (aucun ICMP lisible).
> Sur `wg0` : le même échange ICMP apparaît en clair.
> C'est la **démonstration du fonctionnement du tunnel**.

---

#### 7.5 — Service à travers le VPN

```bash
# Serveur : lancer un serveur HTTP de test dans le VPN
python3 -m http.server 8000 --bind 10.8.0.1

# Client : tester
curl -I http://10.8.0.1:8000            # HTTP/1.0 200 OK
ssh utilisateur@10.8.0.1               # SSH à travers le tunnel
```

---

## 5. Pour aller plus loin

### Split tunnel — accéder à un LAN derrière le serveur

Cas : le serveur a un LAN interne `192.168.200.0/24` (carte `ens34`) et le client doit y accéder.

**Serveur — ajouter dans `[Interface]` :**

```ini
PostUp   = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o ens34 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -s 10.8.0.0/24 -o ens34 -j MASQUERADE
```

**Client — étendre `AllowedIPs` :**

```ini
AllowedIPs = 10.8.0.0/24, 192.168.200.0/24
```

```bash
sudo wg-quick down wg0 && sudo wg-quick up wg0
ping -c2 192.168.200.20             # Machine du LAN interne
```

---

### Full tunnel — tout le trafic via le VPN

**Serveur :**

```ini
PostUp   = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o ens33 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -s 10.8.0.0/24 -o ens33 -j MASQUERADE
```

**Client :**

```ini
[Interface]
Address = 10.8.0.2/24
PrivateKey = <CLI_PRIV>
DNS = 1.1.1.1

[Peer]
PublicKey = <SRV_PUB>
Endpoint = 192.168.100.10:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
```

```bash
curl -s ifconfig.me         # Affiche l'IP publique du SERVEUR, pas celle du client
ip route get 8.8.8.8        # ... dev wg0
```

---

### Ajouter un second client sans couper les autres

```bash
# Ajout à chaud
sudo wg set wg0 peer <CLI2_PUB> allowed-ips 10.8.0.3/32

# Rendre permanent dans wg0.conf
sudo nano /etc/wireguard/wg0.conf        # Ajouter un [Peer]

# Recharger sans interrompre les tunnels existants
sudo wg syncconf wg0 <(sudo wg-quick strip wg0)
```

> Pour **révoquer** un client : supprimer son `[Peer]` dans le fichier + `wg syncconf`. L'accès est révoqué immédiatement sans toucher aux autres.

---

### Client mobile par QR code

```bash
sudo apt install qrencode
qrencode -t ansiutf8 < client.conf      # Scanner avec l'appli WireGuard mobile
```

> ⚠️ Ce QR code contient une clé privée. Ne pas le partager ni le laisser traîner.

---

## 6. Dépannage

| Symptôme | Cause probable | Solution |
|---|---|---|
| Pas de `latest handshake` | Clés inversées, mauvais Endpoint, port bloqué | Relire `PublicKey` des deux côtés + `tcpdump udp port 51820` |
| Paquets reçus mais pas de handshake | Clé publique du client absente ou erronée côté serveur | Les paquets de pairs inconnus sont ignorés silencieusement |
| Handshake OK, ping KO | `AllowedIPs` trop restreint, pare-feu sur `wg0` | `wg show`, `ufw status`, `ip route get 10.8.0.1` |
| LAN derrière serveur inaccessible | `ip_forward=0`, règle FORWARD manquante | `cat /proc/sys/net/ipv4/ip_forward`, `iptables -L FORWARD -n -v` |
| Full tunnel : plus d'Internet | Pas de NAT côté serveur, DNS non configuré | Règle MASQUERADE, `DNS =` côté client |
| `Warning: ... is world accessible` | Permissions trop ouvertes sur le fichier de config | `sudo chmod 600 /etc/wireguard/wg0.conf` |
| `Operation not supported` | Module absent (noyau ancien, conteneur LXC) | `sudo modprobe wireguard`, vérifier version du noyau |
| `Address already in use` | Interface `wg0` existe déjà | `sudo wg-quick down wg0` puis `up` |
| Connexions lentes sur gros transferts | Problème de MTU | `ping -M do -s 1372 10.8.0.1`, ajuster `MTU =` |
| Tunnel tombe derrière un NAT | Le NAT oublie la correspondance | `PersistentKeepalive = 25` côté client |
| Modification de `wg0.conf` sans effet | Interface non rechargée | `wg-quick down/up` ou `wg syncconf` |

---

## Commandes clés apprises

```bash
# Installation
sudo apt install wireguard
wg --version
sudo modprobe wireguard

# Clés
wg genkey | sudo tee privatekey | wg pubkey | sudo tee publickey
wg genpsk | sudo tee presharedkey
sudo chmod 600 /etc/wireguard/*

# wg-quick
sudo wg-quick up wg0
sudo wg-quick down wg0
sudo systemctl enable --now wg-quick@wg0

# État et diagnostic
sudo wg show
sudo wg show wg0

# Modifier à chaud
sudo wg set wg0 peer <PUB> allowed-ips 10.8.0.3/32
sudo wg syncconf wg0 <(sudo wg-quick strip wg0)

# Forwarding
sudo sysctl -w net.ipv4.ip_forward=1
cat /proc/sys/net/ipv4/ip_forward
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-wireguard.conf

# Pare-feu
sudo ufw allow 51820/udp comment 'WireGuard'
sudo ufw allow in on wg0

# tcpdump (preuve du chiffrement)
sudo tcpdump -i ens33 -nn udp port 51820 -c 4      # Interface réelle = chiffré
sudo tcpdump -i wg0 -nn icmp -c 4                  # Interface virtuelle = en clair

# Routes (outils du cours réseau)
ip -br a show wg0
ip r
ip route get 10.8.0.1
```

---

## Livrables & preuves

- [ ] Capture de `sudo wg show` avec `latest handshake` récent et `transfer` dans les deux sens
- [ ] Capture de `ping -c4 10.8.0.1` depuis le client — temps de réponse < 2ms
- [ ] Capture de `ip r` montrant la route `10.8.0.0/24 dev wg0`
- [ ] Capture tcpdump `ens33` → paquets UDP opaques (aucun ICMP lisible)
- [ ] Capture tcpdump `wg0` → ICMP echo request/reply en clair
- [ ] Capture de `cat /proc/sys/net/ipv4/ip_forward` → `1`
- [ ] Capture de `sudo ufw status` avec le port 51820/udp ouvert

---

## Difficultés rencontrées & solutions

| Difficulté rencontrée | Solution appliquée |
|---|---|
| Pas de handshake — tunnel silencieux | Clé publique du serveur copiée dans `[Interface]` au lieu de `[Peer]` — corrigé |
| `wg show` n'affiche pas de `latest handshake` | Pas de trafic lancé — un `ping` déclenche le premier handshake |
| Ping OK dans un sens, KO dans l'autre | `AllowedIPs` trop restreint d'un côté — ajusté à `/24` |
| `Warning: ... is world accessible` au démarrage | `chmod 600 /etc/wireguard/wg0.conf` — permissions corrigées |
| Tunnel ne passe pas le pare-feu | Port 51820/udp non ouvert dans UFW sur le serveur |
| Forwarding actif mais LAN inaccessible | Règles `iptables -A FORWARD` manquantes dans `PostUp` |

---

*Semaine 08 terminée · Prochaine étape → [Semaine 09 — Active Directory & Windows Server](../09-active-directory/README.md)*

# Semaine 09 — Bash avancé : scripts robustes

> **Phase 3 — Virtualisation & Services**
> Rythme : 3 soirs × 45 min · Statut : ✅ Terminé

---

## Objectif de la semaine

Écrire des scripts Bash production-ready : fonctions réutilisables, gestion des arguments courts et longs, gestion d'erreurs avec `set -Eeuo pipefail` et `trap`, heredocs, tableaux associatifs et expressions régulières. L'exercice final réécrit le script de monitoring S1 avec tous ces éléments.

---

## Sommaire

- [1. Fonctions Bash](#1-fonctions-bash)
- [2. Gestion des arguments](#2-gestion-des-arguments)
- [3. Gestion d'erreurs](#3-gestion-derreurs)
- [4. Here documents](#4-here-documents)
- [5. Arrays et boucles avancées](#5-arrays-et-boucles-avancées)
- [6. Expressions régulières avec =~](#6-expressions-régulières-avec-)
- [7. Exercice — Réécriture du script monitoring](#7-exercice--réécriture-du-script-monitoring)
- [Commandes clés apprises](#commandes-clés-apprises)
- [Livrables & preuves](#livrables--preuves)
- [Difficultés rencontrées & solutions](#difficultés-rencontrées--solutions)

---

## 1. Fonctions Bash

### Syntaxe

```bash
saluer() {
    local nom=${1:-inconnu}      # $1 avec valeur par défaut
    echo "Bonjour, $nom"
}

saluer Alice        # Bonjour, Alice
saluer              # Bonjour, inconnu
```

> Préférer `nom() { ... }` (POSIX) plutôt que `function nom { ... }` (spécifique Bash).

**Règles :**
- Une fonction doit être définie **avant** d'être appelée
- Les arguments `$1`, `$2`, `$@`, `$#` sont propres à la fonction
- `$0` reste le nom du script — utiliser `${FUNCNAME[0]}` pour le nom de la fonction

---

### Variables locales — toujours `local`

```bash
compteur=0
mauvaise()  { compteur=99; }          # modifie la globale !
correcte()  { local compteur=99; }    # variable locale

correcte;  echo "$compteur"   # 0  ← globale préservée
mauvaise;  echo "$compteur"   # 99 ← globale modifiée
```

> Toujours déclarer les variables de fonction avec `local`.

---

### `return` vs `echo` — deux canaux différents

| | `return N` | `echo / printf` |
|---|---|---|
| Ce que c'est | Code de statut (0 à 255) | Texte sur stdout |
| Récupération | `$?` ou dans un `if` | `valeur=$(fonction)` |
| Usage | Succès/échec, test booléen | Renvoyer une donnée (chaîne, nombre) |

```bash
# return : un test
est_pair() { (( $1 % 2 == 0 )); }

if est_pair 4; then echo "pair"; fi

# echo : une valeur
ip_de() { ip -4 -br addr show "$1" | awk '{print $3}'; }

adresse=$(ip_de ens33)
echo "$adresse"             # 192.168.100.10/24
```

**Erreurs classiques :**

| Erreur | Explication |
|---|---|
| `return 300` | Donne `300 % 256 = 44` — un return ne transporte pas de données |
| `$()` crée un sous-shell | Une variable modifiée dans la fonction n'est pas modifiée dans l'appelant |
| `echo` de debug dans une fonction capturée | Pollue le résultat — les messages vont sur `>&2` |

---

### Combiner statut et valeur

```bash
lire_port() {
    local fichier=$1 port
    port=$(grep -oP '^Port\s+\K[0-9]+' "$fichier") || return 1
    echo "$port"
}

if port=$(lire_port /etc/ssh/sshd_config); then
    echo "SSH sur le port $port"
else
    echo "Port non défini (22 par défaut)" >&2
fi
```

---

### Piège : `local x=$(commande)` masque l'erreur

```bash
f() { local x=$(false); echo "statut : $?"; }   # statut : 0 ← l'échec est PERDU
f() { local x; x=$(false); }                    # ici, l'échec est visible
```

> ShellCheck signale cela (SC2155). Toujours **déclarer d'abord, affecter ensuite**.

---

### Fonctions utilitaires typiques

```bash
die()  { echo "ERREUR : $*" >&2; exit 1; }
info() { printf '[%s] %s\n' "$(date +%T)" "$*"; }
need() { command -v "$1" >/dev/null 2>&1 || die "commande manquante : $1"; }

need dig
need curl
```

---

## 2. Gestion des arguments

### Variables spéciales

| Variable | Contenu |
|---|---|
| `$0` | Nom du script tel qu'appelé |
| `$1` … `$9`, `${10}` | Arguments positionnels |
| `$#` | Nombre d'arguments |
| `$@` | Tous les arguments, chacun séparé |
| `$*` | Tous les arguments en une seule chaîne |
| `$?` | Statut de la dernière commande |
| `$$` | PID du shell courant |
| `$!` | PID du dernier processus en arrière-plan |

---

### `"$@"` vs `"$*"` — toujours `"$@"`

```bash
test_args() {
    for a in "$@"; do echo "  [$a]"; done
}
test_args "un" "deux mots" "trois"
# [un]
# [deux mots]    ← préservé en un seul argument
# [trois]
```

> Avec `"$*"`, tout serait fusionné. Sans guillemets, `$@` redécoupe sur les espaces.

---

### `shift` et valeurs par défaut

```bash
echo "$1"; shift          # consomme $1
shift 2                   # consomme deux arguments
```

```bash
${var:-défaut}     # défaut si var est vide ou non définie
${var:=défaut}     # idem, et AFFECTE var
${var:?message}    # quitte avec un message si var est vide/non définie
${var:+autre}      # "autre" si var est définie, sinon rien
```

---

### Manipulations de chaînes

```bash
f="/var/log/nginx/access.log"
echo "${f##*/}"           # access.log        (basename)
echo "${f%/*}"            # /var/log/nginx    (dirname)
echo "${f%.log}"          # /var/log/nginx/access
echo "${f/nginx/apache}"  # remplace la 1re occurrence
echo "${#f}"              # longueur de la chaîne
```

---

### `getopts` — options courtes

```bash
while getopts ":vo:n:h" opt; do
    case $opt in
        v) verbose=true ;;
        o) sortie=$OPTARG ;;
        n) compte=$OPTARG ;;
        h) echo "Usage : $0 [-v] [-o fichier] [-n nombre]"; exit 0 ;;
        :)  echo "L'option -$OPTARG attend une valeur" >&2; exit 2 ;;
        \?) echo "Option inconnue : -$OPTARG" >&2; exit 2 ;;
    esac
done
shift $((OPTIND - 1))      # il ne reste que les arguments non-options
```

> `getopts` gère uniquement les options **courtes** (`-v`, `-o`). Pour les options longues, utiliser une boucle `while/case`.

---

### Options longues — boucle `while/case` (recommandée)

```bash
while (( $# > 0 )); do
    case $1 in
        -v|--verbose) verbose=true; shift ;;
        -o|--output)  sortie=$2; shift 2 ;;
        --output=*)   sortie=${1#*=}; shift ;;     # forme --output=fichier
        -h|--help)    usage; exit 0 ;;
        --)           shift; break ;;
        -*)           echo "Option inconnue : $1" >&2; exit 2 ;;
        *)            break ;;
    esac
done
```

> C'est la méthode la plus lisible et la plus portable — elle n'a pas besoin de commande externe.

---

## 3. Gestion d'erreurs

### Le mode strict : `set -Eeuo pipefail`

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
```

| Option | Effet |
|---|---|
| `-e` (errexit) | Le script s'arrête dès qu'une commande échoue |
| `-u` (nounset) | Une variable non définie est une erreur |
| `-o pipefail` | Le statut d'un pipeline est celui de la première commande en échec |
| `-E` (errtrace) | Le `trap ERR` est hérité dans les fonctions |

**Pourquoi `pipefail` ?**

```bash
false | cat; echo $?       # Sans pipefail : 0 ← l'échec est invisible
set -o pipefail
false | cat; echo $?       # Avec pipefail : 1
```

**Pourquoi `-u` ?**

```bash
rm -rf "$REPERTOIRE/"*     # si REPERTOIRE est vide → rm -rf /*  ← catastrophe
```

---

### Les limites de `set -e`

```bash
# Ces cas NE déclenchent PAS l'arrêt :
if grep -q x fichier; then ...; fi        # condition d'un if
commande1 && commande2                     # liste &&/||
commande || true                           # volontairement toléré

# Ces cas déclenchent un arrêt surprenant :
(( i++ ))              # si i vaut 0, expression = 0 → statut 1 → arrêt
grep motif fichier     # aucune correspondance = statut 1 → arrêt
```

**Solutions :**

```bash
i=$(( i + 1 ))                      # au lieu de (( i++ ))
grep -q motif fichier || true        # tolérer l'absence de correspondance
```

> `set -euo pipefail` est un **filet de sécurité**, pas une garantie. Tester explicitement les commandes critiques avec `cmd || die "..."`.

---

### Codes de sortie

| Code | Signification |
|---|---|
| `0` | Succès |
| `1` | Erreur générale |
| `2` | Mauvais usage (arguments, syntaxe) |
| `126` | Commande trouvée mais non exécutable |
| `127` | Commande introuvable |
| `128 + N` | Tué par le signal N (130 = Ctrl+C, 143 = SIGTERM) |

```bash
commande
statut=$?           # sauvegarder IMMÉDIATEMENT : $? change à chaque commande

# Statut de chaque commande d'un pipeline
false | true | false; echo "${PIPESTATUS[@]}"   # 1 0 1
```

---

### `trap` — exécuter du code sur un signal ou une sortie

```bash
trap 'commande' SIGNAL
```

| Pseudo-signal | Déclenché quand |
|---|---|
| `EXIT` | Le script se termine, quelle qu'en soit la raison |
| `ERR` | Une commande échoue |
| `INT` | Ctrl+C |
| `TERM` | `kill PID` |
| `HUP` | Fermeture du terminal |

**Nettoyage de fichiers temporaires :**

```bash
tmp=$(mktemp -d)                    # répertoire temporaire unique et sûr
cleanup() { rm -rf -- "$tmp"; }
trap cleanup EXIT                   # exécuté dans TOUS les cas de sortie

curl -sS https://example.com -o "$tmp/page.html"
# même si curl échoue ou si on fait Ctrl+C : $tmp est supprimé
```

> Toujours utiliser `mktemp` (pas `/tmp/fichier.tmp` prévisible).

**Diagnostic avec `trap ERR` :**

```bash
set -Eeuo pipefail
trap 'echo "ERREUR ligne $LINENO : « $BASH_COMMAND » (code $?)" >&2' ERR

cd /repertoire/inexistant
# ERREUR ligne 4 : « cd /repertoire/inexistant » (code 1)
```

**Gérer Ctrl+C proprement :**

```bash
trap 'echo "Interrompu" >&2; exit 130' INT TERM
trap cleanup EXIT                   # l'exit 130 déclenche aussi trap EXIT
```

---

### Redirection de `stderr`

```bash
echo "message d'erreur" >&2          # sur stderr (réflexe pour tout message d'erreur)
commande 2>erreurs.log               # stderr → fichier
commande >sortie.log 2>&1            # les deux dans le même fichier
commande &>tout.log                  # raccourci Bash
commande 2>/dev/null                 # ignorer les erreurs
commande 2>&1 | tee -a fichier.log   # écran + fichier

# Rediriger tout le script
exec >>"$LOG" 2>&1
```

> L'ordre compte : `cmd >fichier 2>&1` (correct) ≠ `cmd 2>&1 >fichier` (autre effet).

---

## 4. Here documents

### Syntaxe de base

```bash
cat <<EOF
Bonjour $USER,
nous sommes le $(date +%F) sur $(hostname).
EOF
```

> Le délimiteur (`EOF`) doit être **seul sur sa ligne**, sans espace avant.

---

### Les variantes

| Forme | Comportement |
|---|---|
| `<<EOF` | Variables et `$()` développées |
| `<<'EOF'` (guillemets) | Texte **littéral** — rien n'est développé |
| `<<-EOF` | Supprime les tabulations en début de ligne |
| `<<< "texte"` | Here-string : une chaîne sur l'entrée standard |

---

### Cas d'usage concrets

**Aide d'un script :**

```bash
usage() {
    cat <<EOF
Usage : ${0##*/} [-v] [-o fichier] cible

Options :
  -v        mode verbeux
  -o FICHIER  écrit le résultat dans FICHIER
EOF
}
```

**Écrire un fichier root (le `>` n'hérite pas de `sudo`) :**

```bash
sudo tee /etc/systemd/system/monitor.service >/dev/null <<'EOF'
[Unit]
Description=Surveillance système

[Service]
Type=oneshot
ExecStart=/usr/local/bin/monitor.sh -q -l /var/log/monitor.log -s ssh
EOF
```

**Exécuter plusieurs commandes en SSH :**

```bash
ssh -p 2222 admin@192.168.100.20 'bash -s' <<'EOF'
hostname
ss -tulpn | grep :80
df -h /
EOF
```

**Here-string avec `read` :**

```bash
read -r ip masque <<< "192.168.100.10 255.255.255.0"
echo "$ip / $masque"

IFS=/ read -r reseau prefixe <<< "192.168.100.0/24"
```

> Pourquoi `<<<` plutôt que `echo | read` ? Parce que `read` dans un pipeline s'exécute dans un sous-shell — les variables sont perdues.

---

## 5. Arrays et boucles avancées

### Tableaux indexés

```bash
services=(ssh nginx mariadb)         # déclaration
services+=(bind9)                    # ajout en fin
echo "${services[0]}"                # ssh
echo "${services[-1]}"               # bind9 (dernier)
echo "${services[@]}"                # tous les éléments
echo "${#services[@]}"               # 4 (nombre d'éléments)
echo "${!services[@]}"               # 0 1 2 3 (indices)
echo "${services[@]:1:2}"            # nginx mariadb (tranche)
unset 'services[1]'                  # supprime un élément
```

```bash
# Lire un fichier dans un tableau
mapfile -t lignes < /etc/hostname
mapfile -t ports < <(ss -tln | awk 'NR>1 {print $4}')
```

> Les guillemets sont essentiels : `"${tableau[@]}"` préserve les éléments avec espaces.

---

### Tableaux associatifs (Bash ≥ 4)

```bash
declare -A port=( [ssh]=2222 [http]=80 [https]=443 )
port[dns]=53

echo "${port[ssh]}"              # 2222
echo "${!port[@]}"               # les clés
for nom in "${!port[@]}"; do
    echo "$nom → ${port[$nom]}"
done

[[ -v port[ftp] ]] || echo "ftp absent"    # tester l'existence d'une clé
```

---

### Boucles

```bash
# for sur liste, intervalle, glob
for h in web db mail; do ping -c1 -W1 "$h.lab.internal" >/dev/null && echo "$h up"; done
for i in {1..5}; do echo "$i"; done
for f in /var/log/*.log; do echo "$f"; done      # glob : JAMAIS « for f in $(ls) »

# for à la C
for (( i = 0; i < 5; i++ )); do echo "$i"; done

# while / until
n=0
while (( n < 3 )); do echo "$n"; n=$(( n + 1 )); done
until ping -c1 -W1 192.168.100.10 >/dev/null 2>&1; do echo "attente..."; sleep 2; done

# break/continue avec niveau
for a in 1 2 3; do
    for b in 1 2 3; do
        (( b == 2 )) && continue       # saute ce b
        (( a == 2 )) && break 2        # sort des DEUX boucles
    done
done
```

---

### Lire un fichier ligne par ligne — la bonne forme

```bash
while IFS= read -r ligne; do
    echo "→ $ligne"
done < fichier.txt
```

| Option | Rôle |
|---|---|
| `IFS=` | Conserve les espaces de début et de fin |
| `-r` | Empêche l'interprétation des `\` |
| `< fichier` | Évite un sous-shell inutile (pas de `cat fichier |`) |

---

### Piège du sous-shell dans un pipeline

```bash
compte=0
cat /etc/passwd | while read -r l; do compte=$(( compte + 1 )); done
echo "$compte"       # 0 ← la boucle tournait dans un sous-shell !

# Solution : substitution de processus
compte=0
while read -r l; do compte=$(( compte + 1 )); done < <(cat /etc/passwd)
echo "$compte"       # correct
```

---

### Tester des ports avec un tableau associatif

```bash
declare -A services=( [ssh]=2222 [http]=80 [https]=443 [dns]=53 )
hote=${1:-127.0.0.1}

for nom in "${!services[@]}"; do
    p=${services[$nom]}
    if (timeout 1 bash -c ": < /dev/tcp/$hote/$p") 2>/dev/null; then
        printf '%-6s %-5s OUVERT\n' "$nom" "$p"
    else
        printf '%-6s %-5s fermé/filtré\n' "$nom" "$p"
    fi
done
```

---

## 6. Expressions régulières avec `=~`

### Principe

Dans `[[ ... ]]` uniquement, `=~` teste une expression régulière étendue (ERE). Les captures vont dans `BASH_REMATCH`.

```bash
texte="serveur-web-03"
if [[ $texte =~ ^serveur-([a-z]+)-([0-9]+)$ ]]; then
    echo "match : ${BASH_REMATCH[0]}"    # serveur-web-03
    echo "rôle  : ${BASH_REMATCH[1]}"   # web
    echo "num   : ${BASH_REMATCH[2]}"   # 03
fi
```

---

### Règles importantes

| Règle | Explication |
|---|---|
| Pas de guillemets autour de la regex | Entre guillemets, elle devient littérale |
| Stocker la regex dans une variable | Évite les problèmes d'échappement |
| `=~` ≠ `==` | `==` est un glob shell, `=~` est une vraie regex |
| Classes POSIX | `[[:digit:]]`, `[[:alpha:]]`, `[[:space:]]` — préférer à `\d`, `\w` |

```bash
re='^[0-9]{1,3}(\.[0-9]{1,3}){3}$'
[[ $ip =~ $re ]]
```

---

### Valider une adresse IPv4

```bash
est_ipv4() {
    local ip=$1
    local re='^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$'
    [[ $ip =~ $re ]] || return 1
    local octet
    for octet in "${BASH_REMATCH[@]:1}"; do
        (( 10#$octet <= 255 )) || return 1    # 10# évite l'interprétation octale de 08, 09
    done
}

est_ipv4 192.168.100.20  && echo "valide"
est_ipv4 192.168.100.256 || echo "invalide"
```

---

### Analyser une ligne de log nginx

```bash
ligne='192.168.1.15 - - [01/Oct/2026:10:15:02 +0200] "GET /index.html HTTP/1.1" 200 612'
re='^([0-9.]+) .*\[([^]]+)\] "([A-Z]+) ([^ ]+) [^"]*" ([0-9]{3}) ([0-9]+)$'

if [[ $ligne =~ $re ]]; then
    ip=${BASH_REMATCH[1]}
    methode=${BASH_REMATCH[3]}
    url=${BASH_REMATCH[4]}
    code=${BASH_REMATCH[5]}
    echo "$ip a fait $methode $url → HTTP $code"
fi
# 192.168.1.15 a fait GET /index.html → HTTP 200
```

---

### Valider un nom d'hôte et un port

```bash
[[ $h =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$ ]] || echo "nom d'hôte invalide"
[[ $p =~ ^[0-9]+$ ]] && (( p >= 1 && p <= 65535 )) || echo "port invalide"
```

---

### Outils d'analyse de scripts

```bash
shellcheck script.sh          # détecte guillemets manquants, local x=$(), etc.
bash -n script.sh             # vérifie la syntaxe sans exécuter
bash -x script.sh             # trace chaque commande (debug)
export PS4='+ ${BASH_SOURCE##*/}:${LINENO}: '   # trace plus lisible
```

---

## 7. Exercice — Réécriture du script monitoring

### Version S1 (point de départ)

```bash
#!/bin/bash
echo "=== Monitoring ==="
date
echo "CPU :"
top -bn1 | grep "Cpu(s)"
echo "RAM :"
free -m
echo "Disque :"
df -h
echo "Service ssh :"
systemctl status ssh
```

**Problèmes :**

| Problème | Impact |
|---|---|
| Affichage brut sans décision | Inutilisable par cron ou supervision |
| Aucun code de sortie | Les outils ne savent pas si c'est OK ou pas |
| Valeurs codées en dur | Pas configurable |
| Aucune gestion d'erreur | Echec silencieux |
| Code monolithique | Impossible à tester ou réutiliser |

---

### Version v2 — `monitor.sh`

```bash
#!/usr/bin/env bash
#
# monitor.sh - Surveillance CPU / mémoire / disques / services
# Codes de sortie : 0 = OK | 1 = alerte(s) | 2 = erreur d'usage | 3 = erreur interne

set -Eeuo pipefail

# ─── Constantes ─────────────────────────────────────────────────────────────
readonly SCRIPT_NAME=${0##*/}
readonly VERSION="2.0"
readonly EX_OK=0 EX_ALERT=1 EX_USAGE=2 EX_SOFTWARE=3
readonly LOCK_DIR="/tmp/${SCRIPT_NAME}.lock"

# ─── Paramètres (modifiables) ─────────────────────────────────────────────
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=85
LOG_FILE=""
QUIET=false
LOCK_HELD=false
SERVICES=()
ALERTS=()

# ─── Journalisation ───────────────────────────────────────────────────────
log() {
    local level=$1; shift
    local line
    line="$(date '+%F %T') [$level] $*"

    case $level in
        ERROR) printf '%s\n' "$line" >&2 ;;
        INFO)  [[ $QUIET == true ]] || printf '%s\n' "$line" ;;
        *)     printf '%s\n' "$line" ;;
    esac

    if [[ -n $LOG_FILE ]]; then
        printf '%s\n' "$line" >> "$LOG_FILE"
    fi
}

die() {
    local code=$1; shift
    log ERROR "$*"
    exit "$code"
}

usage() {
    cat <<EOF
Usage : $SCRIPT_NAME [options]

Options :
  -c, --cpu SEUIL        seuil CPU en %            (défaut : $CPU_THRESHOLD)
  -m, --mem SEUIL        seuil mémoire en %        (défaut : $MEM_THRESHOLD)
  -d, --disk SEUIL       seuil disque en %         (défaut : $DISK_THRESHOLD)
  -s, --service NOM      service à vérifier (répétable)
  -l, --log FICHIER      écrire aussi dans FICHIER
  -q, --quiet            n'afficher que les alertes et erreurs
  -h, --help             afficher cette aide
  -V, --version          afficher la version

Codes de sortie : 0 OK, 1 alerte(s), 2 erreur d'usage, 3 erreur interne.

Exemples :
  $SCRIPT_NAME
  $SCRIPT_NAME -c 90 -m 70 -s ssh -s nginx
  $SCRIPT_NAME --disk 50 --log /var/log/monitor.log --quiet
EOF
}

# ─── Traps ────────────────────────────────────────────────────────────────
on_error() { log ERROR "Échec ligne $1 (code $3) : $2"; }
cleanup()  { [[ $LOCK_HELD == true ]] && rmdir "$LOCK_DIR" 2>/dev/null || true; }

trap 'on_error "$LINENO" "$BASH_COMMAND" "$?"' ERR
trap cleanup EXIT
trap 'log WARN "Interruption reçue"; exit 130' INT TERM

# ─── Analyse des arguments ─────────────────────────────────────────────────
need_value() { (( $# >= 2 )) || die "$EX_USAGE" "L'option $1 attend une valeur"; }

validate_percent() {
    local name=$1 value=$2
    if [[ ! $value =~ ^[0-9]{1,3}$ ]] || (( 10#$value < 1 || 10#$value > 100 )); then
        die "$EX_USAGE" "Seuil $name invalide : '$value' (entier entre 1 et 100)"
    fi
}

parse_args() {
    while (( $# > 0 )); do
        case $1 in
            -c|--cpu)     need_value "$@"; CPU_THRESHOLD=$2;  shift 2 ;;
            -m|--mem)     need_value "$@"; MEM_THRESHOLD=$2;  shift 2 ;;
            -d|--disk)    need_value "$@"; DISK_THRESHOLD=$2; shift 2 ;;
            -s|--service) need_value "$@"; SERVICES+=("$2");  shift 2 ;;
            -l|--log)     need_value "$@"; LOG_FILE=$2;       shift 2 ;;
            -q|--quiet)   QUIET=true; shift ;;
            -h|--help)    usage; exit "$EX_OK" ;;
            -V|--version) echo "$SCRIPT_NAME $VERSION"; exit "$EX_OK" ;;
            --)           shift; break ;;
            -*)           usage >&2; die "$EX_USAGE" "Option inconnue : $1" ;;
            *)            die "$EX_USAGE" "Argument inattendu : $1" ;;
        esac
    done
    validate_percent "CPU"     "$CPU_THRESHOLD"
    validate_percent "mémoire" "$MEM_THRESHOLD"
    validate_percent "disque"  "$DISK_THRESHOLD"
    local svc re='^[A-Za-z0-9@._-]+$'
    for svc in "${SERVICES[@]}"; do
        [[ $svc =~ $re ]] || die "$EX_USAGE" "Nom de service invalide : '$svc'"
    done
}

# ─── Préparation ──────────────────────────────────────────────────────────
check_dependencies() {
    local cmd
    local -a needed=(awk df sleep date hostname)
    (( ${#SERVICES[@]} == 0 )) || needed+=(systemctl)
    for cmd in "${needed[@]}"; do
        command -v "$cmd" >/dev/null || die "$EX_SOFTWARE" "Commande requise : $cmd"
    done
}

acquire_lock() {
    if mkdir "$LOCK_DIR" 2>/dev/null; then
        LOCK_HELD=true
    else
        die "$EX_SOFTWARE" "Une autre instance est en cours ($LOCK_DIR)"
    fi
}

# ─── Mesures ──────────────────────────────────────────────────────────────
get_cpu_usage() {
    local u1 n1 s1 i1 w1 q1 sq1 st1 u2 n2 s2 i2 w2 q2 sq2 st2
    read -r _ u1 n1 s1 i1 w1 q1 sq1 st1 _ < /proc/stat
    sleep 1
    read -r _ u2 n2 s2 i2 w2 q2 sq2 st2 _ < /proc/stat
    local idle=$(( (i2 + w2) - (i1 + w1) ))
    local total=$(( (u2+n2+s2+i2+w2+q2+sq2+st2) - (u1+n1+s1+i1+w1+q1+sq1+st1) ))
    (( total > 0 )) || { echo 0; return 0; }
    echo $(( 100 * (total - idle) / total ))
}

get_mem_usage() {
    awk '/^MemTotal:/     { t = $2 }
         /^MemAvailable:/ { a = $2 }
         END { if (t > 0) printf "%d\n", (t - a) * 100 / t; else print 0 }' /proc/meminfo
}

# ─── Vérifications ────────────────────────────────────────────────────────
evaluate() {
    local label=$1 value=$2 threshold=$3
    if (( value >= threshold )); then
        log WARN "$label : ${value}% (seuil ${threshold}%) ALERTE"
        ALERTS+=("${label// /_}=${value}%")
    else
        log INFO "$label : ${value}% (seuil ${threshold}%) OK"
    fi
}

check_disks() {
    local pct mount
    while read -r pct mount; do
        evaluate "Disque $mount" "$pct" "$DISK_THRESHOLD"
    done < <(df -P -x tmpfs -x devtmpfs -x squashfs -x overlay \
             | awk 'NR > 1 { gsub(/%/, "", $5); print $5, $6 }')
}

check_service() {
    if systemctl is-active --quiet "$1"; then
        log INFO "Service $1 : actif"
    else
        log WARN "Service $1 : INACTIF"
        ALERTS+=("service:$1")
    fi
}

report() {
    if (( ${#ALERTS[@]} == 0 )); then
        log INFO "Résultat : tout est OK"
    else
        log WARN "Résultat : ${#ALERTS[@]} alerte(s) : ${ALERTS[*]}"
    fi
}

# ─── Main ─────────────────────────────────────────────────────────────────
main() {
    parse_args "$@"
    check_dependencies
    [[ -n $LOG_FILE ]] && touch "$LOG_FILE" 2>/dev/null \
        || [[ -z $LOG_FILE ]] || die "$EX_USAGE" "Fichier de log non inscriptible : $LOG_FILE"
    acquire_lock

    log INFO "Démarrage de la surveillance sur $(hostname)"

    local cpu mem svc
    cpu=$(get_cpu_usage)
    mem=$(get_mem_usage)

    evaluate "CPU"     "$cpu" "$CPU_THRESHOLD"
    evaluate "Mémoire" "$mem" "$MEM_THRESHOLD"
    check_disks

    for svc in "${SERVICES[@]}"; do
        check_service "$svc"
    done

    report
    (( ${#ALERTS[@]} == 0 )) || exit "$EX_ALERT"
    exit "$EX_OK"
}

main "$@"
```

---

### Installation et tests

```bash
sudo install -m 755 monitor.sh /usr/local/bin/monitor.sh
shellcheck monitor.sh                              # analyse statique
bash -n monitor.sh                                 # vérification syntaxe
```

**Test 1 — exécution normale :**

```bash
monitor.sh -s ssh -s nginx
# 2026-10-06 14:02:11 [INFO] Démarrage de la surveillance sur ns1
# 2026-10-06 14:02:12 [INFO] CPU : 7% (seuil 80%) OK
# 2026-10-06 14:02:12 [WARN] Service nginx : INACTIF
echo $?     # 1
```

**Test 2 — forcer une alerte :**

```bash
monitor.sh --disk 10 --mem 5
echo "code : $?"   # 1
```

**Test 3 — erreurs d'usage :**

```bash
monitor.sh --cpu abc       # [ERROR] Seuil CPU invalide → code 2
monitor.sh --cpu           # [ERROR] L'option --cpu attend une valeur → code 2
monitor.sh -s 'ssh; rm -rf /'   # [ERROR] Nom de service invalide → code 2
```

**Test 4 — séparation stdout/stderr :**

```bash
monitor.sh -q --cpu 999 2>erreurs.txt >sortie.txt
cat erreurs.txt    # message d'erreur
cat sortie.txt     # vide
```

**Test 5 — verrou anti double exécution :**

```bash
monitor.sh & monitor.sh
# [ERROR] Une autre instance est en cours → code 3
```

---

### Ce que la v2 apporte par rapport à S1

| S1 | v2 |
|---|---|
| Affichage brut | Décision basée sur des seuils |
| Aucun code de sortie | `0 / 1 / 2 / 3` exploitable par cron |
| Valeurs codées en dur | Options courtes et longues validées |
| Bloc monolithique | Fonctions réutilisables |
| Échec silencieux | `set -Eeuo pipefail` + `trap` |
| Messages mélangés | Erreurs sur stderr, résultats sur stdout |
| Pas de trace | Log avec horodatage |
| Exécutions concurrentes | Verrou nettoyé par `trap EXIT` |

---

### Exploitation avec cron

```bash
# crontab -e
*/5 * * * * /usr/local/bin/monitor.sh -q -l /var/log/monitor.log -s ssh -s nginx
```

---

## Commandes clés apprises

```bash
# Fonctions
local var                           # variable locale
die()  { echo "ERREUR : $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null || die "..."; }

# Variables spéciales
echo "$@" "$#" "$?" "$$" "${PIPESTATUS[@]}"

# Modes stricts
set -Eeuo pipefail

# Traps
trap 'cleanup' EXIT
trap 'echo "Err ligne $LINENO : $BASH_COMMAND" >&2' ERR
trap 'exit 130' INT TERM

# Arguments
while (( $# > 0 )); do case $1 in -v) ...; shift ;; esac; done
getopts ":vo:h" opt

# Heredoc
cat <<EOF ... EOF
cat <<'EOF' ... EOF              # littéral
sudo tee /etc/fichier >/dev/null <<'EOF' ... EOF
read -r ip mask <<< "192.168.1.1 255.255.255.0"

# Arrays
declare -A assoc=( [cle]=val )
mapfile -t arr < fichier
"${arr[@]}" "${!arr[@]}" "${#arr[@]}"

# Boucles
while IFS= read -r ligne; do ... done < fichier
while read -r l; do ... done < <(commande)

# Regex
[[ $var =~ ^regex$ ]]
echo "${BASH_REMATCH[0]}" "${BASH_REMATCH[1]}"

# Debug
shellcheck script.sh
bash -n script.sh
bash -x script.sh
```

---

## Livrables & preuves

- [ ] Script `monitor.sh` v2 dans `/usr/local/bin/` avec `chmod 755`
- [ ] Capture de `shellcheck monitor.sh` — aucune erreur
- [ ] Capture de `monitor.sh -s ssh -s nginx` avec code de sortie `0` ou `1`
- [ ] Capture de `monitor.sh --cpu abc` → code de sortie `2` et message sur stderr
- [ ] Capture du verrou anti double exécution → code `3`
- [ ] Capture de `monitor.sh --disk 10` → alerte déclenchée

---

## Difficultés rencontrées & solutions

| Difficulté rencontrée | Solution appliquée |
|---|---|
| `local x=$(commande)` masque l'échec | Déclarer `local x` puis `x=$(commande)` sur deux lignes séparées |
| `(( i++ ))` avec `i=0` arrête le script sous `set -e` | Utiliser `i=$(( i + 1 ))` à la place |
| Variables d'un `while` dans un pipeline perdues | Utiliser la substitution de processus `< <(commande)` |
| `trap ERR` ne se déclenche pas dans une fonction | Ajouter `-E` au `set` : `set -Eeuo pipefail` |
| Heredoc avec `sudo` ne fonctionne pas | Utiliser `sudo tee fichier >/dev/null <<'EOF'` |
| Tableau vide provoque une erreur avec `set -u` | Vérifier `(( ${#SERVICES[@]} == 0 ))` avant de parcourir |

---

*Semaine 09 terminée · Prochaine étape → [Semaine 10 — Docker & conteneurisation](../10-docker/README.md)*

# Semaine 10 — Sécurité Linux : hardening

> **Phase 3 — Virtualisation & Services**
> Rythme : 3 soirs × 45 min · Statut : ✅ Terminé

---

## Objectif de la semaine

Appliquer les mesures de hardening fondamentales sur un serveur Ubuntu : auditd pour tracer les accès, ClamAV pour la détection de malwares, unattended-upgrades pour les correctifs automatiques, désactivation des services inutiles et analyse des binaires SUID/SGID. Documenter chaque étape dans un `SECURITY_CHECKLIST.md` avec preuves mesurables (Lynis avant/après).

---

## Sommaire

- [1. Principes du hardening](#1-principes-du-hardening)
- [2. Auditd — tracer les accès](#2-auditd--tracer-les-accès)
- [3. ClamAV — antivirus](#3-clamav--antivirus)
- [4. unattended-upgrades](#4-unattended-upgrades)
- [5. Désactiver les services inutiles](#5-désactiver-les-services-inutiles)
- [6. SUID / SGID](#6-suid--sgid)
- [7. Exercice — Hardening complet + SECURITY\_CHECKLIST.md](#7-exercice--hardening-complet--security_checklistmd)
- [8. Dépannage](#8-dépannage)
- [Commandes clés apprises](#commandes-clés-apprises)
- [Livrables & preuves](#livrables--preuves)
- [Difficultés rencontrées & solutions](#difficultés-rencontrées--solutions)

---

## 1. Principes du hardening

| Principe | Application |
|---|---|
| Réduire la surface d'attaque | Désactiver les services inutiles, limiter les SUID, fermer les ports |
| Moindre privilège | Peu de binaires SUID, `sudo` plutôt que root, `nosuid` sur les montages |
| Corriger vite | Mises à jour de sécurité automatiques |
| Détecter | auditd (qui a modifié quoi), ClamAV (fichiers malveillants), logs |
| Documenter et vérifier | `SECURITY_CHECKLIST.md`, audit Lynis avant/après |

**Référentiels :**
- **CIS Benchmark Ubuntu** : contrôles numérotés, Level 1 (bon compromis) et Level 2 (plus strict). Ne pas appliquer aveuglément — chaque règle doit être comprise.
- **Lynis** : outil d'audit qui évalue la machine et donne un score. Il n'applique rien.

> Le hardening réduit la surface d'attaque, il ne rend pas une machine "sûre". C'est de la **défense en profondeur**.

---

## 2. Auditd — tracer les accès

### Rôle

`auditd` est le démon d'audit du noyau Linux. Il enregistre des événements précis (appel système, fichier touché, utilisateur, programme) dans `/var/log/audit/audit.log`.

**Différence avec `/var/log/auth.log`** : l'audit voit tout ce qui touche un fichier, même si le programme ne logue rien.

**Concept clé — `auid` :** l'identité de connexion d'origine, **conservée après `sudo` ou `su`**. Si `admin` fait `sudo vim /etc/passwd`, `uid=root` mais `auid=admin` : on sait qui est réellement derrière.

---

### Installation

```bash
sudo apt install auditd audispd-plugins -y
sudo systemctl enable --now auditd
sudo auditctl -s          # état : enabled 1, lost 0
```

---

### Fichiers de configuration

| Fichier | Rôle |
|---|---|
| `/etc/audit/auditd.conf` | Configuration du démon (taille et rotation des logs) |
| `/etc/audit/rules.d/*.rules` | Tes règles (fragments) |
| `/etc/audit/audit.rules` | Fichier généré par `augenrules` — ne pas éditer |
| `/var/log/audit/audit.log` | Journal d'audit |

---

### Syntaxe des règles

**Surveillance de fichier (watch) :**

```
-w CHEMIN -p PERMISSIONS -k CLÉ
```

| Permission | Déclenche sur |
|---|---|
| `r` | Lecture |
| `w` | Écriture |
| `x` | Exécution |
| `a` | Changement d'attributs (chmod, chown) |

> `-p wa` (écriture + attributs) est le choix usuel pour les fichiers de configuration.
> La clé `-k` permet de retrouver les événements avec `ausearch -k`.

**Surveillance d'appel système :**

```bash
-a always,exit -F arch=b64 -S init_module,finit_module,delete_module -k modules
```

---

### Fichier de règles

```bash
sudo nano /etc/audit/rules.d/50-hardening.rules
```

```
## Identité et authentification
-w /etc/passwd   -p wa -k identity
-w /etc/shadow   -p wa -k identity
-w /etc/group    -p wa -k identity
-w /etc/gshadow  -p wa -k identity
-w /etc/security/opasswd -p wa -k identity

## Élévation de privilèges
-w /etc/sudoers    -p wa -k sudoers
-w /etc/sudoers.d/ -p wa -k sudoers

## Accès distant
-w /etc/ssh/sshd_config    -p wa -k sshd_config
-w /etc/ssh/sshd_config.d/ -p wa -k sshd_config

## Planification de tâches
-w /etc/crontab      -p wa -k cron
-w /etc/cron.d/      -p wa -k cron
-w /var/spool/cron/  -p wa -k cron

## Pare-feu
-w /etc/ufw/ -p wa -k firewall

## Modules noyau et changement d'heure
-a always,exit -F arch=b64 -S init_module,finit_module,delete_module -k modules
-a always,exit -F arch=b64 -S adjtimex,settimeofday,clock_settime -k time-change
```

---

### Charger et vérifier

```bash
sudo augenrules --check          # dit si les règles ont changé
sudo augenrules --load           # fusionne rules.d/ → audit.rules et charge
sudo auditctl -l                 # liste les règles actives
```

---

### Rendre les règles immuables (optionnel)

```bash
echo "-e 2" | sudo tee /etc/audit/rules.d/99-finalize.rules
```

> Avec `-e 2`, les règles ne peuvent plus être modifiées avant un redémarrage, même par root.
> **En phase de mise au point, ne pas activer** — chaque modification impose un reboot.

---

### Lire les événements

```bash
sudo ausearch -k identity -ts recent -i        # -i = noms lisibles, -ts = 10 dernières min
sudo ausearch -f /etc/shadow -i               # tout ce qui touche shadow
sudo ausearch -k sudoers --start today -i
sudo aureport --summary                        # synthèse globale
sudo aureport -k --summary                    # événements par clé
sudo aureport -au --failed                    # échecs d'authentification
sudo aureport -x --summary                    # exécutables les plus actifs
sudo tail -f /var/log/audit/audit.log         # brut, en direct
```

**Lire un événement :**

```
type=SYSCALL  auid=admin  uid=root  exe=/usr/sbin/useradd  key=identity
                │              │          │                      │
                │              │          │                      └─ clé de la règle déclenchée
                │              │          └─ binaire responsable
                │              └─ uid sous lequel tourne le processus (root après sudo)
                └─ identité de connexion RÉELLE (celui qui a fait sudo)
```

---

### Rotation des logs

Dans `/etc/audit/auditd.conf` :

```
max_log_file = 20              # Mo par fichier
num_logs = 10                  # fichiers conservés
max_log_file_action = ROTATE
```

---

## 3. ClamAV — antivirus

### Les composants

| Composant | Rôle |
|---|---|
| `clamscan` | Scanner CLI — charge toute la base à chaque lancement (lent, autonome) |
| `clamd` | Démon qui garde la base en mémoire — interrogé via `clamdscan` (rapide, ~1 Go RAM) |
| `freshclam` | Mise à jour des signatures (vérifie plusieurs fois par jour) |

---

### Installation

```bash
sudo apt install clamav -y

sudo systemctl stop clamav-freshclam
sudo freshclam                               # mise à jour manuelle
sudo systemctl start clamav-freshclam
```

> Si tu lances `freshclam` pendant que le service tourne : `log file is locked`. Stopper le service d'abord.

---

### Test EICAR

```bash
printf '%s\n' 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' > /tmp/eicar.txt
clamscan /tmp/eicar.txt
# /tmp/eicar.txt: Win.Test.EICAR_HDB-1 FOUND
rm /tmp/eicar.txt
```

> Le fichier EICAR est une chaîne de test inoffensive, reconnue par tous les antivirus.

---

### Scanner le système

```bash
sudo clamscan -r -i \
    --exclude-dir='^/proc' --exclude-dir='^/sys' --exclude-dir='^/dev' \
    --exclude-dir='^/run'  --exclude-dir='^/var/lib/clamav' \
    --log=/var/log/clamav/scan-manuel.log /
```

| Option | Effet |
|---|---|
| `-r` | Récursif |
| `-i` | N'affiche que les fichiers infectés |
| `--exclude-dir='^/proc'` | Exclut par regex (pseudo-fichiers : inutile et lent) |
| `--log=FICHIER` | Écrit un journal |

**Codes de sortie :** `0` = rien trouvé · `1` = virus trouvé · `2` = erreur

> ⚠️ Ne jamais utiliser `--remove` en automatique. Un faux positif supprimerait un fichier légitime.

---

### Script de scan hebdomadaire

```bash
sudo nano /usr/local/bin/clamav-weekly-scan
```

```bash
#!/usr/bin/env bash
set -uo pipefail
LOG=/var/log/clamav/weekly-scan.log
status=0
{
    echo "===== Début du scan : $(date '+%F %T') sur $(hostname) ====="
    nice -n 19 ionice -c3 clamscan -r -i \
        --exclude-dir='^/proc' --exclude-dir='^/sys' --exclude-dir='^/dev' \
        --exclude-dir='^/run'  --exclude-dir='^/var/lib/clamav' \
        / || status=$?
    echo "===== Fin du scan : $(date '+%F %T') (code $status) ====="
} >> "$LOG" 2>&1

case $status in
    0) logger -t clamav-weekly "Scan terminé : aucune menace" ;;
    1) logger -t clamav-weekly -p auth.alert "MENACE DÉTECTÉE : voir $LOG" ;;
    *) logger -t clamav-weekly -p daemon.err "Erreur de scan (code $status) : voir $LOG" ;;
esac
exit "$status"
```

```bash
sudo chmod 750 /usr/local/bin/clamav-weekly-scan
```

> `nice -n 19 ionice -c3` donnent au scan la priorité CPU et disque la plus basse — ne ralentit pas la machine.

---

### Cron hebdomadaire

```bash
sudo nano /etc/cron.d/clamav-weekly
```

```
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# Dimanche 03h00
0 3 * * 0 root /usr/local/bin/clamav-weekly-scan
```

```bash
sudo chmod 644 /etc/cron.d/clamav-weekly
sudo chown root:root /etc/cron.d/clamav-weekly
```

**Pièges cron sur Debian/Ubuntu :**

| Piège | Explication |
|---|---|
| Champ utilisateur | Dans `/etc/cron.d/`, il y a un champ `root` en plus des 5 champs horaires |
| Nom avec un point | `clamav.weekly` est ignoré silencieusement — utiliser `clamav-weekly` |
| Pas de retour à la ligne finale | Le fichier doit se terminer par `\n` |

---

### Limites de ClamAV

ClamAV détecte surtout des signatures connues, en grande partie de malwares Windows. Sur un serveur Linux, son intérêt est de scanner les fichiers entrants (uploads web, partages Samba) et de repérer certains webshells.

---

## 4. unattended-upgrades

### Principe

La majorité des compromissions exploitent des failles **corrigées depuis des semaines**. Appliquer automatiquement les correctifs de sécurité réduit fortement ce risque.

---

### Installation

```bash
sudo apt install unattended-upgrades apt-listchanges -y
sudo dpkg-reconfigure -plow unattended-upgrades    # répondre « Oui »
```

Cela crée `/etc/apt/apt.conf.d/20auto-upgrades` :

```
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
```

---

### Configuration

```bash
sudo nano /etc/apt/apt.conf.d/52unattended-upgrades-local
```

```
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};

Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
// Unattended-Upgrade::Automatic-Reboot-Time "03:30";
```

> Un correctif de noyau n'est actif **qu'après reboot**. Le fichier `/var/run/reboot-required` signale ce besoin.

---

### Vérifier

```bash
sudo unattended-upgrade --dry-run --debug         # simulation complète
systemctl list-timers 'apt-daily*' --no-pager     # minuteurs systemd
apt-config dump | grep -E 'Periodic|Unattended-Upgrade::(Allowed|Automatic)'
sudo tail -n 30 /var/log/unattended-upgrades/unattended-upgrades.log
ls /var/run/reboot-required 2>/dev/null && cat /var/run/reboot-required.pkgs
```

---

## 5. Désactiver les services inutiles

Un service qui ne tourne pas **ne peut pas être exploité**.

### Inventaire

```bash
systemctl list-unit-files --type=service --state=enabled --no-pager   # lancés au boot
systemctl list-units --type=service --state=running --no-pager        # actifs maintenant
systemctl list-units --type=socket --state=listening --no-pager       # sockets d'activation
sudo ss -tulpn                                                         # ports ouverts
systemd-analyze security --no-pager                                   # score d'exposition
```

---

### `stop` vs `disable` vs `mask`

| Commande | Arrêt immédiat | Pas de boot | Manuel possible | Via dépendance |
|---|---|---|---|---|
| `systemctl stop X` | ✅ | ❌ | ✅ | ✅ |
| `systemctl disable X` | ❌ | ✅ | ✅ | ✅ |
| `systemctl disable --now X` | ✅ | ✅ | ✅ | ✅ |
| `systemctl mask X` | ❌ | ✅ | ❌ | ❌ |

> `mask` lie l'unité à `/dev/null` : **rien ne peut la lancer**. Pour annuler : `systemctl unmask X`.

```bash
sudo systemctl disable --now bluetooth.service
sudo systemctl mask bluetooth.service
systemctl is-enabled bluetooth.service        # masked
```

---

### Piège de l'activation par socket

Beaucoup de services ont une unité `.socket` qui les relance à la première connexion. Si tu ne désactives que le `.service`, il revient.

```bash
sudo systemctl disable --now cups.service cups.socket cups.path
```

> Ne jamais masquer `ssh.service` / `ssh.socket` sur la machine à laquelle tu es connecté.

---

### Services à évaluer

| Service | Rôle | Décision sur un serveur |
|---|---|---|
| `avahi-daemon` | Découverte réseau mDNS | Désactiver / désinstaller |
| `cups`, `cups-browsed` | Impression | Désactiver / désinstaller |
| `bluetooth` | Bluetooth | Désactiver |
| `ModemManager` | Modems 3G/4G | Désactiver |
| `multipathd` | Multipath SAN | Désactiver sur VM sans SAN |
| `apport` | Rapports de plantage | Désactiver |
| `ssh`, `cron`, `rsyslog`, `ufw`, `auditd` | Essentiels | **Garder** |

> Le mieux est de **désinstaller** : un paquet absent n'a ni démon, ni mise à jour à suivre.

```bash
sudo apt purge avahi-daemon cups-browsed -y
sudo apt autoremove --purge -y
```

---

## 6. SUID / SGID

### Rappel des bits spéciaux

| Bit | Octal | Effet | Affichage |
|---|---|---|---|
| SUID | 4000 | S'exécute avec les droits du **propriétaire** (souvent root) | `-rw**s**r-xr-x` |
| SGID | 2000 | S'exécute avec les droits du **groupe** | `-rwxr-**s**r-x` |
| Sticky | 1000 | Sur un répertoire : seul le propriétaire peut supprimer son fichier (`/tmp`) | `drwxrwxrw**t**` |

**Exemple légitime :** `/usr/bin/passwd` est SUID root pour modifier `/etc/shadow`.

**Le risque :** un binaire SUID root avec une faille permet une escalade de privilèges.

---

### Commandes de recherche

```bash
find / -perm /4000 -ls 2>/dev/null              # SUID
find / -perm /2000 -ls 2>/dev/null              # SGID
find / -xdev -type f -perm /6000 -ls 2>/dev/null   # les deux, fichiers seulement
```

**Syntaxe de `-perm` :**

| Forme | Signification |
|---|---|
| `-perm 4000` | Permissions exactement 4000 |
| `-perm -4000` | Tous les bits indiqués sont positionnés |
| `-perm /4000` | Au moins un des bits indiqués |
| `-perm +4000` | Ancienne syntaxe — **supprimée des `find` récents** |

---

### Ce qui est normal sur Ubuntu

**SUID normaux :** `su`, `sudo`, `passwd`, `chsh`, `chfn`, `gpasswd`, `newgrp`, `mount`, `umount`, `pkexec`, `fusermount3`, `ssh-keysign`

**Ce qui est suspect :**

| Indice | Explication |
|---|---|
| SUID dans `/tmp`, `/var/tmp`, `/dev/shm`, `/home` | Aucun SUID ne devrait être là |
| SUID sur un interpréteur (`bash`, `python`, `vim`, `find`...) | GTFOBins : escalade de privilèges possible |
| Binaire inconnu de dpkg | Hors paquet = suspect |
| SUID récemment modifié | Vérifier avec `-mtime -7` |

```bash
# Référentiel GTFOBins pour la défense
# https://gtfobins.github.io
```

---

### Recherches ciblées

```bash
# Emplacements suspects
sudo find /tmp /var/tmp /dev/shm /home -type f -perm /6000 -ls 2>/dev/null

# Récemment modifiés (7 derniers jours)
sudo find / -xdev -type f -perm /6000 -mtime -7 -ls 2>/dev/null

# Appartenance à un paquet
dpkg -S /usr/bin/passwd

# Intégrité des binaires
sudo apt install debsums -y && sudo debsums -s

# Capabilities (autre mécanisme de privilèges)
getcap -r / 2>/dev/null
```

---

### Créer une référence et comparer

```bash
# Créer la référence
sudo find / -xdev -type f -perm /6000 2>/dev/null | sort | sudo tee /root/suid_baseline.txt

# Plus tard : détecter les changements
sudo find / -xdev -type f -perm /6000 2>/dev/null | sort | diff /root/suid_baseline.txt -
# > /tmp/suid-test    ← un nouveau SUID est apparu : à investiguer
```

---

### Réduire les SUID

```bash
sudo chmod u-s /usr/bin/chfn
sudo dpkg-statoverride --update --add root root 0755 /usr/bin/chfn
```

> Sans `dpkg-statoverride`, la prochaine mise à jour du paquet **rétablit le bit SUID**.
> Ne jamais retirer le SUID de `su`, `sudo`, `passwd`, `mount`.

**Option `nosuid` sur les montages (`/etc/fstab`) :**

```
tmpfs  /dev/shm  tmpfs  defaults,nosuid,nodev,noexec  0 0
```

---

## 7. Exercice — Hardening complet + SECURITY_CHECKLIST.md

### Plan d'hypothèses

Ubuntu Server 22.04/24.04, utilisateur `admin` dans le groupe `sudo`, SSH sur port 2222, UFW actif, nginx et MariaDB installés.

---

### Étape 0 — État initial (la preuve « avant »)

```bash
# Snapshot VMware AVANT de commencer !

mkdir -p ~/hardening && cd ~/hardening
sudo apt update && sudo apt upgrade -y

# Audit initial
sudo apt install lynis -y
sudo lynis audit system --quick > lynis_avant.txt 2>&1
sudo grep hardening_index /var/log/lynis-report.dat    # ex. hardening_index=61

# Références
sudo ss -tulpn > ports_avant.txt
systemctl list-unit-files --type=service --state=enabled --no-pager > services_avant.txt
sudo find / -xdev -type f -perm /6000 2>/dev/null | sort | sudo tee /root/suid_baseline.txt > suid_avant.txt
```

---

### Étape 1 — auditd

```bash
sudo apt install auditd audispd-plugins -y
sudo systemctl enable --now auditd

sudo tee /etc/audit/rules.d/50-hardening.rules >/dev/null <<'EOF'
-w /etc/passwd   -p wa -k identity
-w /etc/shadow   -p wa -k identity
-w /etc/group    -p wa -k identity
-w /etc/gshadow  -p wa -k identity
-w /etc/security/opasswd -p wa -k identity
-w /etc/sudoers    -p wa -k sudoers
-w /etc/sudoers.d/ -p wa -k sudoers
-w /etc/ssh/sshd_config    -p wa -k sshd_config
-w /etc/ssh/sshd_config.d/ -p wa -k sshd_config
-w /etc/crontab     -p wa -k cron
-w /etc/cron.d/     -p wa -k cron
-w /var/spool/cron/ -p wa -k cron
-w /etc/ufw/ -p wa -k firewall
-a always,exit -F arch=b64 -S init_module,finit_module,delete_module -k modules
-a always,exit -F arch=b64 -S adjtimex,settimeofday,clock_settime -k time-change
EOF

sudo augenrules --load
sudo auditctl -l | grep -c .          # nombre de règles chargées
sudo auditctl -s | grep -E 'enabled|lost'
```

**Test :**

```bash
sudo useradd -m testaudit
sudo ausearch -k identity -ts recent -i | grep -E 'name=|exe=|auid='
sudo userdel -r testaudit
sudo aureport -k --summary
```

---

### Étape 2 — unattended-upgrades

```bash
sudo apt install unattended-upgrades apt-listchanges -y
echo 'unattended-upgrades unattended-upgrades/enable_auto_updates boolean true' | sudo debconf-set-selections
sudo dpkg-reconfigure -f noninteractive unattended-upgrades

sudo tee /etc/apt/apt.conf.d/52unattended-upgrades-local >/dev/null <<'EOF'
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
EOF

cat /etc/apt/apt.conf.d/20auto-upgrades
sudo unattended-upgrade --dry-run --debug 2>&1 | grep -E 'Allowed origins|No packages|Packages that will'
systemctl list-timers 'apt-daily*' --no-pager
```

---

### Étape 3 — ClamAV et cron

```bash
sudo apt install clamav -y
sudo systemctl stop clamav-freshclam
sudo freshclam
sudo systemctl enable --now clamav-freshclam

sudo tee /usr/local/bin/clamav-weekly-scan >/dev/null <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
LOG=/var/log/clamav/weekly-scan.log
status=0
{
    echo "===== Début du scan : $(date '+%F %T') sur $(hostname) ====="
    nice -n 19 ionice -c3 clamscan -r -i \
        --exclude-dir='^/proc' --exclude-dir='^/sys' --exclude-dir='^/dev' \
        --exclude-dir='^/run'  --exclude-dir='^/var/lib/clamav' \
        / || status=$?
    echo "===== Fin du scan : $(date '+%F %T') (code $status) ====="
} >> "$LOG" 2>&1
case $status in
    0) logger -t clamav-weekly "Scan terminé : aucune menace" ;;
    1) logger -t clamav-weekly -p auth.alert "MENACE DÉTECTÉE : voir $LOG" ;;
    *) logger -t clamav-weekly -p daemon.err "Erreur de scan (code $status) : voir $LOG" ;;
esac
exit "$status"
EOF
sudo chmod 750 /usr/local/bin/clamav-weekly-scan

sudo tee /etc/cron.d/clamav-weekly >/dev/null <<'EOF'
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
0 3 * * 0 root /usr/local/bin/clamav-weekly-scan
EOF
sudo chmod 644 /etc/cron.d/clamav-weekly
```

**Tests :**

```bash
printf '%s\n' 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' | sudo tee /root/eicar.txt >/dev/null
sudo clamscan -i /root/eicar.txt          # ... FOUND
sudo rm /root/eicar.txt

sudo /usr/local/bin/clamav-weekly-scan; echo "code : $?"
sudo tail -n 15 /var/log/clamav/weekly-scan.log
journalctl -t clamav-weekly --since today --no-pager
```

---

### Étape 4 — Services inutiles

```bash
systemctl list-units --type=service --state=running --no-pager
systemctl list-units --type=socket --state=listening --no-pager

for svc in bluetooth ModemManager multipathd apport; do
    if systemctl list-unit-files "${svc}.service" --no-legend 2>/dev/null | grep -q .; then
        sudo systemctl disable --now "${svc}.service" 2>/dev/null
        sudo systemctl mask "${svc}.service"
        echo "$svc : $(systemctl is-enabled ${svc}.service 2>&1)"
    fi
done

for u in cups.socket cups.path cups-browsed.service avahi-daemon.socket avahi-daemon.service; do
    systemctl list-unit-files "$u" --no-legend 2>/dev/null | grep -q . \
        && sudo systemctl disable --now "$u" && sudo systemctl mask "$u"
done

sudo apt purge avahi-daemon cups-browsed -y 2>/dev/null
sudo apt autoremove --purge -y
```

**Vérifications :**

```bash
systemctl is-enabled bluetooth.service ModemManager.service 2>&1    # masked
systemctl --failed --no-pager                                       # 0 unité en échec
sudo ss -tulpn > ports_apres.txt
diff ports_avant.txt ports_apres.txt
```

> Contrôle indispensable : SSH (2222), nginx et MariaDB répondent encore.

---

### Étape 5 — SUID/SGID

```bash
# Liste complète
find / -perm /4000 -ls 2>/dev/null

# Fichiers seulement, un seul disque, triés
sudo find / -xdev -type f -perm /6000 2>/dev/null | sort > suid_apres.txt
wc -l suid_apres.txt

# Emplacements suspects (résultat attendu : vide)
sudo find /tmp /var/tmp /dev/shm /home -type f -perm /6000 -ls 2>/dev/null

# Récemment modifiés (résultat attendu : vide hors MAJ récente)
sudo find / -xdev -type f -perm /6000 -mtime -7 -ls 2>/dev/null

# Binaires hors paquet (résultat attendu : vide)
while read -r f; do dpkg -S "$f" >/dev/null 2>&1 || echo "HORS PAQUET : $f"; done < suid_apres.txt

# Intégrité
sudo apt install debsums -y && sudo debsums -s
```

**Test de détection avec un faux SUID :**

```bash
sudo cp /usr/bin/id /tmp/suid-test && sudo chmod u+s /tmp/suid-test
sudo find / -xdev -type f -perm /6000 2>/dev/null | sort | diff /root/suid_baseline.txt -
# > /tmp/suid-test    ← détecté
sudo find /tmp -type f -perm /6000 -ls
sudo rm /tmp/suid-test
```

---

### Étape 6 — Audit Lynis « après »

```bash
sudo lynis audit system --quick > lynis_apres.txt 2>&1
sudo grep hardening_index /var/log/lynis-report.dat    # ex. hardening_index=72
sudo grep -E '^(warning|suggestion)' /var/log/lynis-report.dat | head -20
```

---

### Étape 7 — SECURITY_CHECKLIST.md

```bash
nano ~/hardening/SECURITY_CHECKLIST.md
```

```markdown
# SECURITY_CHECKLIST : Hardening Ubuntu Server

| | |
|---|---|
| **Machine** | ns1 (Ubuntu Server 24.04) |
| **Date** | 2026-10-06 |
| **Responsable** | admin |
| **Référentiels** | CIS Benchmark Ubuntu (Level 1, partiel), Lynis |
| **Score Lynis** | avant : 61 → après : 72 |

## 1. Préparation
- [x] Snapshot VMware avant modification
- [x] Système à jour (`apt update && apt upgrade`)
- [x] Audit initial Lynis, liste des ports, services et SUID sauvegardés
- [x] Session SSH de secours ouverte pendant les changements

## 2. Audit système (auditd)
- [x] `auditd` installé, service actif au boot
- [x] Règles dans `/etc/audit/rules.d/50-hardening.rules` : passwd, shadow, sudoers, sshd_config, cron, ufw, modules, time
- [x] **Test** : `useradd testaudit` → événement `key=identity` visible via `ausearch -k identity -i`
- [ ] Règles immuables (`-e 2`) : non activé (phase de mise au point)

## 3. Antivirus (ClamAV)
- [x] `clamav` installé, `clamav-freshclam` actif
- [x] Script `/usr/local/bin/clamav-weekly-scan` (journal : `/var/log/clamav/weekly-scan.log`)
- [x] Cron `/etc/cron.d/clamav-weekly` : dimanche 03h00
- [x] **Test** : fichier EICAR détecté, scan complet terminé avec code 0

## 4. Mises à jour automatiques
- [x] `unattended-upgrades` activé (`20auto-upgrades` valeurs à 1)
- [x] Origines : `-security` uniquement
- [x] Redémarrage automatique : désactivé
- [x] **Test** : `--dry-run --debug` OK, minuteurs `apt-daily*` actifs

## 5. Services
- [x] Inventaire avant/après sauvegardé
- [x] Désactivés + masqués : bluetooth, ModemManager, multipathd, apport
- [x] Désinstallés : avahi-daemon, cups-browsed
- [x] **Contrôle** : `systemctl --failed` vide, SSH/nginx/MariaDB fonctionnels

## 6. SUID / SGID
- [x] Référence créée : `/root/suid_baseline.txt`
- [x] Aucun SUID dans `/tmp`, `/var/tmp`, `/dev/shm`, `/home`
- [x] Aucun binaire hors paquet, `debsums -s` OK
- [x] **Test** : faux SUID dans `/tmp` détecté par comparaison, supprimé

## 7. Mesures déjà en place (cours précédents)
- [x] UFW : `deny incoming`, ports 2222/80/443 uniquement
- [x] SSH sur port 2222
- [x] fail2ban actif (cours 04)

## 8. Vérification finale
- [x] Score Lynis après hardening : 72
- [x] Redémarrage de contrôle : tous les services actifs
- [x] Ports conformes (`ss -tulpn`)

## 9. Points restants / risques acceptés
- [ ] SSH par clé uniquement (`PasswordAuthentication no`)
- [ ] Politique de mots de passe (`libpam-pwquality`)
- [ ] `nosuid,nodev,noexec` sur `/dev/shm` et `/tmp`
- [ ] Logs d'audit vers machine distante
- Risque accepté : reboot manuel après mise à jour du noyau

## 10. Maintenance

| Fréquence | Action |
|---|---|
| Quotidien | `unattended-upgrades` (automatique) |
| Hebdomadaire | Scan ClamAV (cron), lire `weekly-scan.log` |
| Hebdomadaire | `aureport --summary`, `aureport -au --failed` |
| Mensuel | Comparaison SUID, `lynis audit system`, `/var/run/reboot-required` |
| Après modification | Mettre à jour cette checklist |
```

---

### Tableau de bord des résultats attendus

| Contrôle | Commande | Résultat attendu |
|---|---|---|
| auditd actif | `systemctl is-active auditd` | `active` |
| Règles chargées | `sudo auditctl -l \| grep -c identity` | ≥ 5 |
| Événement détecté | `ausearch -k identity -ts recent` | trace de `useradd` |
| Signatures à jour | `systemctl is-active clamav-freshclam` | `active` |
| Cron en place | `ls -l /etc/cron.d/clamav-weekly` | `-rw-r--r-- root root` |
| MAJ auto | `apt-config dump \| grep Unattended-Upgrade "1"` | `"1"` |
| Services masqués | `systemctl is-enabled bluetooth` | `masked` |
| Aucun échec | `systemctl --failed` | `0 loaded units listed` |
| SUID inattendus | `find /tmp /var/tmp /dev/shm /home -perm /6000 -type f` | vide |
| Score Lynis | `grep hardening_index /var/log/lynis-report.dat` | supérieur à l'initial |

---

## 8. Dépannage

| Symptôme | Cause probable | Solution |
|---|---|---|
| `augenrules --load` : "No rules" | Faute de syntaxe dans un `.rules` | `sudo auditctl -R /etc/audit/rules.d/50-hardening.rules` pour voir la ligne |
| "The audit system is in immutable mode" | `-e 2` actif | Redémarrer la machine |
| `auditctl -s` : `lost` augmente | Règles trop bruyantes ou backlog trop petit | Augmenter `-b`, retirer les règles `execve` |
| Disque plein dans `/var/log/audit` | Pas de rotation | Configurer `max_log_file`, `num_logs`, `ROTATE` |
| `freshclam` : "log file is locked" | `clamav-freshclam` tourne déjà | Stopper le service, lancer `freshclam`, relancer |
| Le cron ne se déclenche jamais | Nom avec un point, droits en écriture, pas de newline | Renommer, `chmod 644`, vérifier `journalctl -u cron` |
| `unattended-upgrade` n'installe rien | Aucune MAJ de sécurité disponible, origine non autorisée | `--dry-run --debug`, lire `Allowed origins` |
| Service désactivé qui redémarre | Le `.socket` ou `.path` est resté actif | `disable --now` sur le `.socket`, ou `mask` |
| `Failed to enable unit: Unit is masked` | Tentative d'activer un service masqué | `systemctl unmask` d'abord |
| Plus de SSH après nettoyage | `ssh.socket` ou `ssh` masqué | Console VMware → `systemctl unmask ssh && systemctl enable --now ssh` |
| `unknown predicate -perm +4000` | Ancienne syntaxe supprimée | Utiliser `-perm /4000` |
| SUID retiré revient après `apt upgrade` | Le paquet rétablit ses permissions | `dpkg-statoverride --update --add ...` |

---

## Commandes clés apprises

```bash
# auditd
sudo apt install auditd audispd-plugins
sudo systemctl enable --now auditd
sudo augenrules --load
sudo auditctl -l
sudo auditctl -s
sudo ausearch -k identity -ts recent -i
sudo ausearch -f /etc/shadow -i
sudo aureport --summary
sudo aureport -k --summary
sudo aureport -au --failed

# ClamAV
sudo apt install clamav
sudo freshclam
sudo clamscan -r -i --exclude-dir='^/proc' /
sudo chmod 750 /usr/local/bin/clamav-weekly-scan

# unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
sudo unattended-upgrade --dry-run --debug
systemctl list-timers 'apt-daily*'
cat /etc/apt/apt.conf.d/20auto-upgrades
ls /var/run/reboot-required

# Lynis
sudo apt install lynis
sudo lynis audit system --quick
sudo grep hardening_index /var/log/lynis-report.dat

# Services
systemctl list-unit-files --type=service --state=enabled
systemctl list-units --type=service --state=running
systemd-analyze security
sudo systemctl disable --now SERVICE
sudo systemctl mask SERVICE
systemctl is-enabled SERVICE

# SUID/SGID
find / -perm /4000 -ls 2>/dev/null
find / -xdev -type f -perm /6000 2>/dev/null | sort
find /tmp /var/tmp /dev/shm /home -type f -perm /6000 -ls 2>/dev/null
dpkg -S /usr/bin/passwd
sudo debsums -s
getcap -r / 2>/dev/null
sudo chmod u-s /usr/bin/chfn
sudo dpkg-statoverride --update --add root root 0755 /usr/bin/chfn
```

---

## Livrables & preuves

- [ ] `lynis_avant.txt` et `lynis_apres.txt` — score amélioré
- [ ] `suid_avant.txt` et `suid_apres.txt` — aucun SUID suspect
- [ ] `ports_avant.txt` et `ports_apres.txt` — diff propre
- [ ] `services_avant.txt` et `services_apres.txt` — services désactivés visibles
- [ ] Capture de `ausearch -k identity -ts recent -i` après `useradd testaudit`
- [ ] Capture de `clamscan` avec le fichier EICAR détecté
- [ ] Capture de `systemctl is-enabled bluetooth` → `masked`
- [ ] Capture de `systemctl --failed` → `0 loaded units listed`
- [ ] `SECURITY_CHECKLIST.md` complété avec cases cochées sur GitHub

---

## Difficultés rencontrées & solutions

| Difficulté rencontrée | Solution appliquée |
|---|---|
| `augenrules --load` silencieux — règles non chargées | Faute de syntaxe dans le `.rules` — `auditctl -R fichier` pour identifier la ligne |
| `freshclam` échoue avec "log file is locked" | Stopper `clamav-freshclam` avant de lancer `freshclam` manuellement |
| Cron ignoré silencieusement | Fichier nommé `clamav.weekly` avec un point — renommé en `clamav-weekly` |
| Service masqué qui refuse `enable` | `systemctl unmask` avant `enable` |
| SUID retiré revient après `apt upgrade` | `dpkg-statoverride` utilisé pour rendre la modification persistante |
| `find -perm +4000` erreur | Ancienne syntaxe — remplacée par `-perm /4000` |

---

*Semaine 10 terminée · Prochaine étape → [Semaine 11 — Docker & conteneurisation](../11-docker/README.md)*