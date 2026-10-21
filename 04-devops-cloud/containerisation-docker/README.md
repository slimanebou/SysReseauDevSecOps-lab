# 🐳 Docker — Cours complet & Aide-mémoire

> **Auteur :** Slimane BOUAROUA
> **Formation :** Master 2 Ingénierie Réseaux & Systèmes
> **Orientation :** Systèmes & Réseaux · Cloud · DevOps · DevSecOps

---

## 🎯 À propos

Ce dépôt rassemble une documentation complète sur Docker, de l'architecture interne jusqu'aux bonnes pratiques de sécurité en production. Il sert de référence technique personnelle et de support de révision.

### Compétences couvertes

| Domaine | Compétences |
|---------|-------------|
| **Virtualisation** | VM vs conteneurs, hyperviseurs (KVM, VirtualBox, VMware), namespaces, cgroups |
| **Conteneurisation** | Cycle de vie des conteneurs, images en couches, Copy-on-Write |
| **Build** | Dockerfile, cache, multi-stage build, `.dockerignore`, publication sur registry |
| **Stockage** | Volumes nommés, bind mounts, tmpfs, sauvegarde et restauration PostgreSQL |
| **Réseau** | Bridge personnalisé, DNS interne, isolation front/back, publication de ports, reverse proxy |
| **Orchestration** | Docker Compose, healthchecks, variables d'environnement, fichiers override dev/prod |
| **Sécurité** | Scan CVE (Trivy), utilisateur non-root, limites de ressources, read-only, gestion des secrets |
| **Exploitation** | Diagnostic, dépannage, nettoyage, gestion des logs |

---

## 📋 Table des matières

1. [Virtualisation : VM vs Conteneurs](#1-virtualisation--vm-vs-conteneurs)
2. [Virtualisation avec KVM](#2-virtualisation-avec-kvm)
3. [Architecture Docker](#3-architecture-docker)
4. [Installation et configuration](#4-installation-et-configuration)
5. [Images Docker](#5-images-docker)
6. [Conteneurs : cycle de vie et commandes](#6-conteneurs--cycle-de-vie-et-commandes)
7. [Dockerfile et construction d'images](#7-dockerfile-et-construction-dimages)
8. [Publication sur un registry](#8-publication-sur-un-registry)
9. [Volumes et persistance des données](#9-volumes-et-persistance-des-données)
10. [Réseau Docker](#10-réseau-docker)
11. [Docker Compose](#11-docker-compose)
12. [Sécurité des conteneurs](#12-sécurité-des-conteneurs)
13. [Nettoyage](#13-nettoyage)
14. [Diagnostic et dépannage](#14-diagnostic-et-dépannage)
15. [Questions d'entretien](#15-questions-dentretien)
16. [Aide-mémoire](#16-aide-mémoire)
17. [Ressources](#17-ressources)
18. [Projet : secure-docker-stack](#18-projet--secure-docker-stack)

---

## 1. Virtualisation : VM vs Conteneurs

### Qu'est-ce que virtualiser ?

Virtualiser consiste à créer une version simulée d'un ordinateur complet (VM) ou d'un environnement d'exécution (conteneur). Le système fait croire au programme qu'il dispose de sa propre machine, alors que plusieurs systèmes partagent en réalité le même matériel physique.

### Comparatif

| Élément | Machine virtuelle | Conteneur Docker |
|---------|-------------------|------------------|
| Ce qui est virtualisé | Un ordinateur complet | L'application et ses dépendances |
| Système d'exploitation | OS complet par VM | Partage le noyau de l'hôte |
| Noyau | Propre noyau | Noyau de l'hôte |
| RAM | Réservée par VM | Partagée dynamiquement |
| Démarrage | Minutes | Secondes |
| Isolation | Complète (hyperviseur) | Namespaces + cgroups Linux |
| Taille | Go | Mo |

```
   Machine virtuelle                 Conteneur
┌──────────┬──────────┐      ┌──────────┬──────────┐
│   APP1   │   APP2   │      │   APP1   │   APP2   │
├──────────┼──────────┤      ├──────────┴──────────┤
│   OS1    │   OS2    │      │    Docker Engine    │
├──────────┴──────────┤      ├─────────────────────┤
│     Hyperviseur     │      │      OS (noyau)     │
├─────────────────────┤      ├─────────────────────┤
│         OS          │      │      Matériel       │
├─────────────────────┤      └─────────────────────┘
│      Matériel       │
└─────────────────────┘
```

### Les hyperviseurs

| Solution | Type | Usage |
|----------|------|-------|
| **KVM** | Intégré au noyau Linux, transforme Linux en hyperviseur | Production, cloud |
| **VirtualBox** | Logiciel installé sur un OS | Apprentissage (gratuit, simple) |
| **VMware** | Logiciel installé sur un OS | Entreprise, très robuste |

### Les deux mécanismes Linux de Docker

| Mécanisme | Rôle | En résumé |
|-----------|------|-----------|
| **Namespaces** | Donnent au processus son propre environnement isolé (PID, réseau, système de fichiers…) | Ce que le conteneur **voit** |
| **cgroups** | Contrôlent les ressources utilisables (CPU, RAM, nombre de processus) | Ce que le conteneur peut **consommer** |

Grâce aux namespaces PID, deux conteneurs différents peuvent chacun avoir un processus avec le PID 1.

```
Machine Linux
├── Conteneur A
│   ├── PID 1
│   ├── réseau
│   └── fichiers
└── Conteneur B
    ├── PID 1
    ├── réseau
    └── fichiers
```

---

## 2. Virtualisation avec KVM

KVM permet d'exécuter des systèmes d'exploitation complets (Windows, autres distributions Linux) avec leur propre noyau.

```bash
# Vérifier le support matériel de la virtualisation (résultat > 0)
egrep -c '(vmx|svm)' /proc/cpuinfo

# Installer KVM et ses outils
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst

# Vérifier que le service est actif
sudo systemctl status libvirtd

# Autoriser l'utilisateur courant
sudo adduser $USER libvirt
sudo adduser $USER kvm

# Lister toutes les VM (actives ou éteintes)
virsh list --all
```

| Paquet | Rôle |
|--------|------|
| `qemu-kvm` | Hyperviseur |
| `libvirt-daemon-system` / `libvirt-clients` | Gestion des VM |
| `bridge-utils` | Gestion du réseau (bridges) |
| `virtinst` | Création de VM en ligne de commande |

| Groupe | Effet |
|--------|-------|
| `libvirt` | Créer et gérer des VM sans `sudo` |
| `kvm` | Accès direct au module de virtualisation du processeur |

---

## 3. Architecture Docker

```
Utilisateur
    │  docker run nginx
    ▼
Docker CLI ──(API)──▶ dockerd (Docker Engine)
                         │
                         ├── Images      modèles en couches, lecture seule
                         ├── Containers  instances en cours d'exécution
                         ├── Networks    communication entre conteneurs
                         ├── Volumes     persistance des données
                         │
                         ▼
                     containerd   cycle de vie des conteneurs
                         │
                         ▼
                       runc       crée l'isolation (namespaces + cgroups)
                         │
                         ▼
                     Conteneur
```

| Composant | Rôle |
|-----------|------|
| **Docker CLI** | Client : transmet les commandes au moteur via l'API. Il ne fait pas le travail lui-même |
| **dockerd** | Moteur (daemon) en arrière-plan : crée, démarre, arrête les conteneurs, télécharge les images, gère réseau, isolation et ressources |
| **containerd** | Gère le cycle de vie des conteneurs : création, démarrage, arrêt, suppression |
| **runc** | Crée concrètement le processus isolé avec les namespaces et les cgroups |
| **Image** | Modèle en couches, en lecture seule (équivalent d'une classe) |
| **Conteneur** | Instance active d'une image avec une couche inscriptible (équivalent d'un objet) |
| **Registry** | Stockage et distribution des images (Docker Hub, GHCR, registries privés AWS, Red Hat…), en accès public ou privé |

> **Analogie :** image = classe, conteneur = objet. Une même image peut lancer plusieurs conteneurs, l'inverse est impossible.

```bash
docker pull nginx   # contacte Docker Hub, télécharge l'image, la stocke localement
docker run nginx    # crée un conteneur à partir de l'image
```

---

## 4. Installation et configuration

### Installation depuis le dépôt officiel (Ubuntu)

```bash
# Outils nécessaires pour récupérer la clé de sécurité
sudo apt install -y ca-certificates curl gnupg

# Dossier sécurisé pour les clés
sudo install -m 0755 -d /etc/apt/keyrings

# Clé GPG officielle Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Ajout du dépôt officiel
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list

# Installation
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin
```

| Paquet | Rôle |
|--------|------|
| `docker-ce` | Moteur Docker (daemon) |
| `docker-ce-cli` | Commande `docker` |
| `containerd.io` | Runtime des conteneurs |
| `docker-buildx-plugin` | Construction moderne des images |
| `docker-compose-plugin` | Docker Compose V2 |

### Vérification

```bash
sudo systemctl status docker   # état du daemon
docker version                 # versions client et serveur
docker info                    # conteneurs, images, stockage, runtime, paramètres du moteur
docker run --rm hello-world    # test, conteneur supprimé à la fin
```

### Utiliser Docker sans sudo

```bash
sudo usermod -aG docker $USER
newgrp docker   # applique le groupe immédiatement, sans fermer la session
```

### ⚠️ Sécurité du groupe docker

Le daemon est piloté via le socket `/var/run/docker.sock`. Être membre du groupe `docker` revient pratiquement à avoir les **droits root** sur la machine :

```bash
docker run --rm -v /:/host alpine cat /host/etc/shadow
```

`-v /:/host` monte toute la racine de l'hôte dans le conteneur : celui-ci peut alors lire les fichiers sensibles de l'hôte.

**Alternatives plus sûres :** Docker rootless, Podman.

### Limiter la taille des logs

Objectif : empêcher les logs des conteneurs de remplir le disque.

Fichier : `/etc/docker/daemon.json`

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

| Paramètre | Signification |
|-----------|---------------|
| `log-driver: json-file` | Logs stockés dans des fichiers JSON |
| `max-size: 10m` | Taille maximale d'un fichier de log |
| `max-file: 3` | Nombre maximal de fichiers en rotation |

```bash
sudo systemctl restart docker
```

---

## 5. Images Docker

### Définition

Une image est un modèle immuable, construit par un éditeur ou par soi-même, stocké localement et distribué par les registries. Elle est composée d'une ou plusieurs couches et contient l'application, ses bibliothèques, ses dépendances et sa configuration. Elle est bien plus complète qu'un simple binaire.

### Nommage

```
registry / namespace / image : tag
docker.io / library  / nginx : 1.27
```

| Élément | Signification |
|---------|---------------|
| `docker.io` | Registry (Docker Hub par défaut) |
| `library` | Namespace (images officielles) |
| `nginx` | Nom de l'image |
| `1.27` | Tag (version) |

> **Registry = magasin → Namespace = rayon → Image = produit → Tag = étiquette**

```bash
docker pull docker.io/library/nginx:1.27   # nom complet
docker pull nginx:1.27                     # version précise
docker pull nginx                          # équivaut à nginx:latest
docker pull nginx@sha256:...               # digest : contenu immuable
```

> ⚠️ `latest` ne signifie pas forcément « dernière version » : c'est simplement un tag. Toujours fixer une version en production.

### Architecture en couches

```
┌──────────────────────────────┐
│ Couche inscriptible          │  ← modifications du conteneur
├──────────────────────────────┤
│ CMD                          │  ← commande de démarrage (métadonnée)
├──────────────────────────────┤
│ COPY                         │  ← fichiers de l'application
├──────────────────────────────┤
│ RUN                          │  ← logiciels installés
├──────────────────────────────┤
│ Image de base                │  ← fondations (ubuntu, alpine…)
└──────────────────────────────┘
```

- `RUN` et `COPY` créent des couches de fichiers ; `CMD` définit une métadonnée et ne crée pas de couche de fichiers.
- **Copy-on-Write :** les couches de l'image ne sont jamais modifiées. Lorsqu'un conteneur modifie un fichier, celui-ci est copié dans sa couche inscriptible.
- L'image reste intacte ; `docker rm` supprime la couche inscriptible et ses modifications.
- Pour conserver des données : utiliser un **volume**.

---

## 6. Conteneurs : cycle de vie et commandes

### `docker run`

Crée et démarre un **nouveau** conteneur à partir d'une image.

```
docker run [OPTIONS] IMAGE[:TAG] [COMMANDE]

pull (si nécessaire) → create → start
```

| Option | Signification |
|--------|---------------|
| `-d` | Exécution en arrière-plan |
| `-it` | Terminal interactif |
| `--name web` | Nom du conteneur |
| `-p 8080:80` | Port hôte → port conteneur |
| `-e VAR=val` | Variable d'environnement |
| `-v volume:/path` | Montage d'un volume |
| `--rm` | Suppression automatique à l'arrêt |
| `--restart unless-stopped` | Redémarrage automatique sauf arrêt volontaire |
| `--network lab` | Connexion à un réseau |
| `-m 256m` | Limite mémoire |
| `--cpus 0.5` | Limite CPU |

```bash
docker run --rm alpine echo "Bonjour"          # conteneur temporaire
docker run -it --rm ubuntu:24.04 bash          # shell temporaire (exit pour sortir)
docker run -d --name web -p 8080:80 nginx:1.27 # serveur en arrière-plan
```

### `run` vs `start`

| Commande | Effet |
|----------|-------|
| `docker run` | Crée **un nouveau** conteneur et le démarre |
| `docker start` | Redémarre un conteneur **existant** |

Relancer `docker run --name web nginx` alors que `web` existe déjà provoque l'erreur `name already in use`.

### Gestion des conteneurs

```bash
docker ps              # conteneurs actifs
docker ps -a           # tous les conteneurs
docker stop web        # arrêt propre (SIGTERM)
docker start web       # redémarre un conteneur existant
docker restart web     # arrêt puis redémarrage
docker kill web        # arrêt immédiat (SIGKILL)
docker rm web          # supprime un conteneur arrêté
docker rm -f web       # force la suppression
docker stats           # consommation en temps réel
```

### Gestion des images

```bash
docker images                     # images locales
docker pull nginx:1.27            # téléchargement
docker rmi nginx:1.27             # suppression (si inutilisée)
docker image inspect nginx:1.27   # détails
docker history nginx:1.27         # couches de l'image
```

### Logs

```bash
docker logs web            # logs disponibles
docker logs -f web         # suivi en temps réel
docker logs --tail 20 web  # 20 dernières lignes
```

### Entrer dans un conteneur

```bash
docker exec -it web bash   # si bash est présent
docker exec -it web sh     # images minimales
```

| Élément | Rôle |
|---------|------|
| `exec` | Lance un **nouveau processus** dans un conteneur démarré |
| `-i` | Garde l'entrée standard ouverte |
| `-t` | Alloue un terminal |

`exit` quitte le shell sans arrêter le conteneur.

### Inspection

`docker inspect` affiche la configuration réelle au format JSON : état, IP, ports, variables, volumes, réseau, commande, limites, `OOMKilled`.

```bash
docker inspect web
docker inspect -f '{{.State.Status}}' web      # état
docker inspect -f '{{.State.ExitCode}}' web    # code de sortie
docker inspect -f '{{.State.OOMKilled}}' web   # tué par manque de mémoire ?
```

### Codes de sortie

| Code | Signification |
|------|---------------|
| `0` | Exécution réussie |
| `1` | Erreur applicative générale |
| `137` | Tué par SIGKILL (signal 9), souvent OOM mais pas obligatoirement |
| `143` | Arrêté par SIGTERM (signal 15), demande d'arrêt normale |

---

## 7. Dockerfile et construction d'images

### Principe

Un Dockerfile est un fichier texte décrivant les étapes de construction d'une image.

```bash
docker build -t monapp:1.0 .   # construit l'image
docker run --rm monapp:1.0     # lance un conteneur
```

| Élément | Rôle |
|---------|------|
| `docker build` | Construit l'image |
| `-t monapp:1.0` | Nom et tag |
| `.` | **Contexte de build** : dossier envoyé au moteur, contenant le Dockerfile |
| `-f Dockerfile-v2` | Utilise un Dockerfile portant un autre nom |

### Instructions

| Instruction | Rôle | Exemple |
|-------------|------|---------|
| `FROM` | Image de base | `FROM python:3.12-slim` |
| `WORKDIR` | Répertoire de travail (créé si absent) | `WORKDIR /app` |
| `COPY` | Copie des fichiers de l'hôte | `COPY . .` |
| `ADD` | Comme COPY avec fonctions en plus (préférer COPY) | — |
| `RUN` | Commande exécutée pendant le build | `RUN pip install flask` |
| `ARG` | Variable disponible uniquement pendant le build | `ARG APP_VERSION=1.0` |
| `ENV` | Variable conservée dans l'image et au runtime | `ENV PORT=5000` |
| `EXPOSE` | Documente le port, **ne le publie pas** | `EXPOSE 5000` |
| `USER` | Utilisateur des instructions suivantes et de l'application | `USER appuser` |
| `CMD` | Commande ou arguments par défaut (remplaçables) | `CMD ["python", "app.py"]` |
| `ENTRYPOINT` | Programme principal du conteneur | `ENTRYPOINT ["python"]` |
| `LABEL` | Métadonnées | `LABEL version="1.0"` |
| `HEALTHCHECK` | Vérifie l'état de santé du conteneur | — |

> `EXPOSE 3000` ne rend pas l'application accessible : il faut `docker run -p 8080:3000 monapp:1.0`.

### RUN : nettoyer dans la même couche

```dockerfile
RUN apk add --no-cache curl

RUN apt-get update && apt-get install -y curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
```

Un nettoyage effectué dans une instruction `RUN` séparée ne réduit pas la taille : les fichiers restent dans la couche précédente.

### ARG vs ENV

| | ARG | ENV |
|-|-----|-----|
| Disponible pendant le build | ✅ | ✅ |
| Disponible à l'exécution | ❌ | ✅ |
| Usage | Version, paramètre de build modifiable sans toucher au Dockerfile | Configuration runtime |

> ⚠️ Ne jamais placer de mot de passe ou de token dans `ARG` ou `ENV` : ils restent visibles dans les métadonnées ou les couches.

### CMD vs ENTRYPOINT

> **Analogie :** ENTRYPOINT = lecteur DVD, CMD = film par défaut. On change le film sans changer de lecteur.

```dockerfile
FROM alpine:3.20
ENTRYPOINT ["ping"]
CMD ["-c", "3", "localhost"]
```

```bash
docker run monping                 # ping -c 3 localhost
docker run monping -c 1 8.8.8.8    # remplace uniquement les arguments de CMD
```

- **CMD** : valeurs par défaut.
- **ENTRYPOINT** : impose le programme principal, adapté aux outils CLI.

### Forme exec vs forme shell

| Forme | Syntaxe | Comportement |
|-------|---------|--------------|
| Exec ✅ | `CMD ["node", "server.js"]` | Programme lancé directement, reçoit correctement SIGTERM |
| Shell | `CMD node server.js` | Passe par `/bin/sh`, transmission des signaux compliquée |

### Cache de build

Docker réutilise les couches déjà construites. Dès qu'une couche change, toutes les suivantes sont reconstruites.

```dockerfile
# ❌ Chaque modification du code réinstalle les dépendances
COPY . .
RUN pip install -r requirements.txt

# ✅ Les dépendances restent en cache
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
```

> **Règle :** du plus stable au plus changeant. Essentiel pour accélérer les pipelines CI/CD.

### .dockerignore

Placé dans le contexte de build, il exclut des fichiers de ce contexte.

```
.git
.env
node_modules
__pycache__
*.pyc
.venv
*.pem
*.key
```

**Intérêts :** build plus rapide, contexte plus petit, cache plus stable, moins de risque d'inclure des secrets.

> `.dockerignore` ne remplace pas une vraie gestion des secrets.

### Secrets

Ne jamais faire :

```dockerfile
COPY password.txt .
RUN echo "PASSWORD=123" > config
```

Même supprimé ensuite, le secret reste présent dans une ancienne couche.

| Solution | Usage | Exemple |
|----------|-------|---------|
| Build secrets | Secret temporaire pendant le build | Token pour une dépendance privée |
| Docker secrets | Secret fourni à un service (Swarm) | Mot de passe de base de données |
| Variables au runtime | Configuration au démarrage | `DATABASE_HOST=db` |
| Convention `_FILE` | L'application lit le secret dans un fichier | `POSTGRES_PASSWORD_FILE=/run/secrets/db_password` |

### Multi-stage build

Plusieurs `FROM` dans un même Dockerfile : on sépare la construction de l'exécution.

```dockerfile
# Stage 1 : construction
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2 : image finale
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
```

| Élément | Rôle |
|---------|------|
| `AS builder` | Nomme l'étape |
| `COPY --from=builder` | Récupère uniquement les artefacts produits |
| `docker build --target builder .` | Construit seulement jusqu'à l'étape nommée |

**Avantages :** image finale sans outils de build, taille réduite, surface d'attaque réduite.

### Dockerfile de référence (Node.js, multi-stage, non-root)

```dockerfile
# Stage 1 : préparation
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY server.js ./

# Stage 2 : image finale
FROM node:22-alpine
WORKDIR /app
ENV NODE_ENV=production PORT=3000
COPY --from=builder --chown=node:node /app /app
USER node
EXPOSE 3000
CMD ["node", "server.js"]
```

- L'utilisateur `node` existe déjà dans l'image officielle.
- `--chown` lui attribue les fichiers copiés.
- `npm ci` nécessite un `package-lock.json`.

### Bonnes pratiques

1. Image de base légère et versionnée (`node:22-alpine`, pas `node:latest`).
2. Utilisateur non-root (il doit exister dans l'image et avoir les droits nécessaires).
3. Fichiers de dépendances copiés avant le code.
4. Nettoyage dans la même couche que l'installation.
5. Forme exec pour `CMD` et `ENTRYPOINT`.
6. Aucun secret dans l'image.
7. `LABEL` pour documenter l'image.
8. `HEALTHCHECK` lorsque pertinent.
9. Un service par conteneur (application, base de données et proxy séparés).

### Checklist Dockerfile

- [ ] Image de base légère et versionnée
- [ ] `.dockerignore` présent
- [ ] Multi-stage build si pertinent
- [ ] Utilisateur non-root
- [ ] `CMD` en forme exec
- [ ] `LABEL` renseignés
- [ ] Aucun secret intégré
- [ ] Taille vérifiée avec `docker images`
- [ ] Conteneur testé
- [ ] Image publiée et lien ajouté au README du projet

---

## 8. Publication sur un registry

```bash
docker login
docker tag mon-api:1.0 utilisateur/mon-api:1.0
docker push utilisateur/mon-api:1.0
```

Remplacer `utilisateur` par son identifiant Docker Hub.

### Vérifier l'image

```bash
docker images mon-api          # taille locale
docker history mon-api:1.0     # couches
docker run --rm mon-api:1.0 whoami   # utilisateur effectif
```

| Mesure | Valeur |
|--------|--------|
| `docker images` | Taille locale **décompressée** |
| Docker Hub | Taille **compressée** (souvent plus petite) |

La taille dépend de l'image de base, des dépendances et des fichiers copiés. Toujours préciser quelle mesure est utilisée.

---

## 9. Volumes et persistance des données

### Pourquoi ?

Un conteneur est éphémère : les données de sa couche inscriptible disparaissent avec `docker rm`. Bases de données, fichiers et uploads doivent être stockés hors du cycle de vie du conteneur.

> Le conteneur peut être supprimé et recréé ; les données doivent rester disponibles.

### Les trois types de stockage

| Type | Emplacement | Usage |
|------|-------------|-------|
| **Volume nommé** | Géré par Docker | Bases de données, données persistantes |
| **Bind mount** | Dossier précis de l'hôte | Développement, code, configuration |
| **tmpfs** | Mémoire RAM | Cache, fichiers temporaires ou sensibles |

### Volume nommé

```bash
docker volume create pgdata
docker volume ls
docker volume inspect pgdata
docker volume rm pgdata
```

Démonstration de la persistance :

```bash
docker run --rm -v mes-donnees:/data alpine sh -c "echo important > /data/data.txt"
docker run --rm -v mes-donnees:/data alpine cat /data/data.txt
# → important (le premier conteneur a pourtant été supprimé)
```

### Bind mount

```bash
# Site statique en lecture seule
docker run -d --name web \
  -p 127.0.0.1:8080:80 \
  -v "$PWD/site":/usr/share/nginx/html:ro \
  nginx:alpine

# Développement Node.js avec rechargement automatique
docker run --rm -it \
  -p 127.0.0.1:3000:3000 \
  -v "$PWD":/app -w /app \
  node:22-alpine node --watch server.js
```

Toute modification sur l'hôte est visible immédiatement, sans reconstruire l'image. `:ro` empêche le conteneur de modifier les fichiers.

**Points d'attention :**
- Un bind mount **masque** le contenu déjà présent dans le dossier cible de l'image.
- Des problèmes de permissions peuvent apparaître sous Linux.
- En production, le code est intégré à l'image plutôt que monté.

### tmpfs

```bash
docker run --tmpfs /tmp/cache alpine
```

Les données disparaissent à l'arrêt du conteneur.

### `-v` vs `--mount`

```bash
# Volume nommé
docker run -v pgdata:/data alpine
docker run --mount type=volume,source=pgdata,target=/data alpine

# Bind mount
docker run -v "$PWD/site":/app:ro nginx:alpine
docker run --mount type=bind,source="$PWD/site",target=/app,readonly nginx:alpine
```

| | `-v` | `--mount` |
|-|------|-----------|
| Syntaxe | Courte | Explicite |
| Bind mount, source absente | Crée le dossier | **Échoue** (plus sûr) |
| Lecture seule | `:ro` | `readonly` |

> Éviter les volumes anonymes (`-v /data`) : ils sont difficiles à identifier.

### PostgreSQL avec volume

```bash
docker volume create pgdata

docker run -d --name db \
  -e POSTGRES_USER=app \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_DB=appdb \
  -v pgdata:/var/lib/postgresql/data \
  -p 127.0.0.1:5432:5432 \
  postgres:16-alpine

docker exec db pg_isready -U app -d appdb          # base prête ?
docker exec db psql -U app -d appdb -c "\l"         # lister les bases (commande psql)
```

```
Sans volume : conteneur → docker rm → ❌ données perdues
Avec volume : conteneur → pgdata → docker rm → ✅ données conservées
```

> Les variables `POSTGRES_*` ne servent qu'à **l'initialisation**. Si le volume contient déjà une base, les modifier ne réinitialise rien.

### Sauvegarde et restauration

#### Sauvegarde logique (`pg_dump`) — à chaud

```bash
mkdir -p backups
docker exec db pg_dump -U app appdb | gzip > backups/appdb.sql.gz
```

Restauration :

```bash
gunzip -c backups/appdb.sql.gz | docker exec -i db psql -U app -d appdb
```

> La restauration rejoue le SQL sans vider la base : si les tables existent déjà, des conflits peuvent apparaître.

#### Sauvegarde physique du volume (`tar`) — à froid

```bash
mkdir -p backups
docker run --rm \
  -v pgdata:/data:ro \
  -v "$PWD/backups":/backup \
  alpine tar czf /backup/pgdata.tar.gz -C /data .
```

Restauration dans un nouveau volume (sans toucher l'original) :

```bash
docker volume create pgdata-restore
docker run --rm \
  -v pgdata-restore:/data \
  -v "$PWD/backups":/backup \
  alpine tar xzf /backup/pgdata.tar.gz -C /data
```

> Pour PostgreSQL, arrêter la base avant une copie physique : copier des fichiers en cours d'écriture produit une sauvegarde incohérente.

| | Logique | Physique |
|-|---------|----------|
| Contenu | Tables et données (SQL) | Fichiers de stockage |
| Outil | `pg_dump` | `tar` |
| Restauration | `psql` rejoue le SQL | Extraction dans un volume, puis démarrage d'un PostgreSQL compatible |
| Arrêt de la base | Non | Oui |
| Avantage | Portable, base en ligne | Complet, rapide |

#### Automatisation

Un script `backup.sh` peut proposer deux modes :

| Mode | Action |
|------|--------|
| `dump` | Sauvegarde logique avec `pg_dump` |
| `volume` | Arrêt temporaire du conteneur, archive `tar`, redémarrage |

Fonctions attendues : création du dossier `backups/`, horodatage des fichiers, rotation conservant les **7 sauvegardes les plus récentes** par type.

```bash
chmod +x backup.sh
./backup.sh dump
./backup.sh volume
ls -lh backups/
```

> **Règle essentielle :** une sauvegarde n'est fiable que si sa restauration a été testée.

### Pièges à connaître

- Publier une base sur `127.0.0.1:5432` limite l'accès à l'hôte.
- Ne jamais versionner un vrai mot de passe.
- Ne jamais écrire directement dans `/var/lib/docker/volumes/`.
- `docker volume prune` supprime les volumes anonymes inutilisés ; `docker volume prune -a` supprime **aussi les volumes nommés** non attachés.
- Un volume ne remplace pas une sauvegarde.
- Fixer la version de l'image (`postgres:16-alpine`).

> Pour une base en production : volume persistant + exposition réseau limitée + identifiants protégés + sauvegardes régulières + tests de restauration.

---

## 10. Réseau Docker

### Types de réseaux

```bash
docker network ls
```

| Réseau | Rôle | Usage |
|--------|------|-------|
| `bridge` | Réseau privé par défaut, NAT vers l'extérieur | Communication entre conteneurs |
| `host` | Partage la pile réseau de l'hôte | Besoins spécifiques, pas d'isolation réseau |
| `none` | Aucun réseau externe, seulement `lo` | Conteneur isolé |
| `overlay` | Réseau entre plusieurs hôtes Docker | Cluster Swarm |
| `macvlan` | Adresse MAC et IP propres sur le LAN | Besoins réseau avancés |

### Bridge par défaut vs bridge personnalisé

| | Bridge par défaut | Bridge personnalisé |
|-|-------------------|---------------------|
| Communication | Par IP (`172.17.0.x`) | Par nom de conteneur |
| DNS intégré (`127.0.0.11`) | ❌ | ✅ |
| Isolation | Partielle | Par réseau |
| Connexion à chaud | — | `connect` / `disconnect` sans recréer |
| Recommandé | Non | **Oui** |

```bash
docker network create lab
docker run -d --name db --network lab postgres:16-alpine
docker run -d --name web --network lab nginx:alpine

docker exec web getent hosts db   # résolution DNS du nom db
```

`web` joint PostgreSQL via `db:5432` : nom du conteneur + port du service.

### Commandes réseau

```bash
docker network ls                       # lister
docker network inspect lab              # sous-réseau, IP, conteneurs connectés
docker network connect lab api          # connecter un conteneur existant
docker network disconnect lab api       # le déconnecter
docker network rm lab                   # supprimer
docker network prune                    # supprimer les réseaux inutilisés
```

### Isolation par réseaux (architecture 3 tiers)

```
Internet → [web] ──front── [api] ──back── [db]
```

| Service | Réseaux | Peut joindre |
|---------|---------|--------------|
| `web` | front | api |
| `api` | front + back | web, db |
| `db` | back | api |

`web` ne peut pas atteindre `db` directement.

> **Principe :** chaque service n'est accessible que par les composants qui en ont besoin.

### Publication des ports

Un conteneur sur un bridge n'est pas accessible depuis l'extérieur sans `-p`.

```
-p PORT_HOTE:PORT_CONTENEUR
```

| Syntaxe | Effet |
|---------|-------|
| `-p 8080:80` | Toutes les interfaces de l'hôte (`0.0.0.0`) |
| `-p 127.0.0.1:8080:80` | Accès local uniquement ✅ |
| `-p 192.168.1.10:8080:80` | Une adresse précise de l'hôte |
| `-p 8080:80/udp` | Publication en UDP |
| `-p 80` | Port hôte attribué automatiquement |
| `-P` | Publie tous les ports `EXPOSE` sur des ports aléatoires |

```bash
docker port web
docker ps --format 'table {{.Names}}\t{{.Ports}}'
```

### Règles essentielles

- `-p` expose un service vers l'hôte ou l'extérieur.
- Deux conteneurs d'un même réseau personnalisé communiquent **sans `-p`**, sur le port du conteneur.
- `EXPOSE` documente, il ne publie pas.
- L'application doit écouter sur `0.0.0.0` **dans** le conteneur ; liée à `127.0.0.1`, elle reste injoignable même avec `-p`.
- PostgreSQL n'a pas besoin d'être publié si seule l'application l'utilise.

### ⚠️ Docker et UFW

Docker écrit ses propres règles iptables : `ufw deny 8080` peut **ne pas bloquer** un port publié par Docker.

**Réflexe :** `-p 127.0.0.1:PORT:PORT` pour un service local.

### Reverse proxy Nginx

Objectif : n'exposer que Nginx ; l'API reste interne.

```
Navigateur → 127.0.0.1:8080 → Nginx (web) → api:3000 (non publié)
```

`nginx.conf` :

```nginx
server {
    listen 80;

    location / {
        proxy_pass http://api:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

> Démarrer l'API avant Nginx : avec cette configuration, Nginx résout le nom `api` à son démarrage.

---

## 11. Docker Compose

### Pourquoi ?

Décrire et piloter plusieurs conteneurs depuis un seul fichier YAML, au lieu de longues commandes `docker run`. Compose centralise services, images ou build, ports, réseaux, volumes, variables et dépendances.

- Commande V2 : `docker compose` (avec un espace), et non l'ancien `docker-compose`.
- Fichier recommandé : `compose.yaml` (`docker-compose.yml` fonctionne aussi).
- La clé `version:` est **obsolète** : ne pas l'ajouter.

### Clés principales

| Clé | Rôle |
|-----|------|
| `services` | Définition des conteneurs |
| `image` | Utilise une image existante |
| `build` | Construit une image depuis un Dockerfile |
| `ports` | Publie des ports |
| `volumes` | Persistance ou montage de fichiers |
| `networks` | Réseaux du service |
| `environment` | Variables du conteneur |
| `env_file` | Variables chargées depuis un fichier |
| `depends_on` | Dépendances de démarrage |
| `restart` | Politique de redémarrage |
| `healthcheck` | Vérification de l'état réel |

`image` et `build` peuvent être combinés : l'image construite reçoit alors ce nom.

### Exemple de référence (Nginx → Backend → PostgreSQL)

```yaml
services:
  web:
    image: nginx:alpine
    ports:
      - "127.0.0.1:${WEB_PORT:-8080}:80"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
    networks:
      - front
    depends_on:
      backend:
        condition: service_healthy
    restart: unless-stopped

  backend:
    build: ./backend
    environment:
      DB_HOST: db
    env_file:
      - ./backend.env
    networks:
      - front
      - back
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: ${DB_NAME}
    volumes:
      - pgdata:/var/lib/postgresql/data
    networks:
      - back
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $${POSTGRES_USER} -d $${POSTGRES_DB}"]
      interval: 5s
      timeout: 3s
      retries: 5
      start_period: 10s
    restart: unless-stopped

volumes:
  pgdata:

networks:
  front:
  back:
```

> Le healthcheck du `backend` doit être défini dans son Dockerfile ou dans le YAML pour que `service_healthy` fonctionne.

```
Navigateur → 127.0.0.1:8080 → Nginx ─front─ Backend ─back─ PostgreSQL → volume pgdata
```

- Seul Nginx publie un port, lié à `127.0.0.1`.
- Le backend utilise `DB_HOST=db`, nom du service Compose.

### Réseaux

Compose crée automatiquement un réseau `<projet>_default` : les services se joignent par leur nom, jamais par IP (qui peut changer). Des réseaux personnalisés (`front`, `back`) permettent d'isoler les services.

> Ne publier que les ports nécessaires : un service qui n'a pas besoin d'être joint depuis l'hôte n'a pas de `ports`.

### Volumes

| Commande | Effet |
|----------|-------|
| `docker compose down` | Supprime conteneurs et réseaux, **conserve** les volumes nommés |
| `docker compose down -v` | Supprime **aussi** les volumes : données perdues |

### depends_on et healthcheck

| Mécanisme | Garantit |
|-----------|----------|
| `depends_on` simple | L'**ordre** de démarrage |
| `depends_on` + `condition: service_healthy` | Que la dépendance est **réellement prête** |

| Paramètre | Signification |
|-----------|---------------|
| `test` | Commande de vérification (`pg_isready` : PostgreSQL accepte-t-il les connexions ?) |
| `interval: 5s` | Fréquence des tests |
| `timeout: 3s` | Durée maximale d'un test |
| `retries: 5` | Échecs consécutifs avant l'état `unhealthy` |
| `start_period: 10s` | Délai de démarrage toléré |

**`$${VAR}`** : le `$$` empêche Compose de substituer la variable sur l'hôte ; elle est interprétée **dans le conteneur**.

Séquence : PostgreSQL démarre → healthcheck `healthy` → backend démarre et devient `healthy` → Nginx démarre.

### Variables d'environnement

| Mécanisme | Rôle | Injecté dans le conteneur ? |
|-----------|------|-----------------------------|
| `.env` | Substitution dans `compose.yaml` | ❌ Non |
| `environment:` | Variables définies dans le YAML | ✅ Oui |
| `env_file:` | Variables chargées depuis un fichier | ✅ Oui |

```bash
# .env
WEB_PORT=8080
```

```yaml
ports:
  - "127.0.0.1:${WEB_PORT}:80"
```

| Syntaxe | Effet |
|---------|-------|
| `${VAR}` | Valeur de la variable |
| `${VAR:-8080}` | Valeur par défaut si absente ou vide |
| `${VAR:?message}` | Erreur si absente ou vide |

- Si une variable existe dans `environment` et `env_file`, **`environment` est prioritaire**.
- `docker compose exec api printenv` affiche les variables réellement présentes dans le conteneur.

**Bonnes pratiques :**
- `.env` dans `.gitignore`.
- `.env.example` versionné avec des valeurs factices.
- Aucun vrai mot de passe versionné.
- `docker compose config` pour vérifier la configuration finale (attention : affiche les secrets en clair).

### Commandes

| Commande | Rôle |
|----------|------|
| `docker compose up -d` | Crée et démarre la stack |
| `docker compose up -d --build` | Reconstruit les images avant |
| `docker compose down` | Supprime conteneurs et réseaux |
| `docker compose down -v` | Supprime aussi les volumes |
| `docker compose ps` | État des services |
| `docker compose logs -f` | Suivi de tous les logs |
| `docker compose logs -f backend` | Logs d'un service |
| `docker compose exec db sh` | Shell dans un conteneur actif |
| `docker compose exec db psql -U app -d appdb` | Accès PostgreSQL |
| `docker compose run --rm backend sh` | Conteneur ponctuel |
| `docker compose build` | Construit sans démarrer |
| `docker compose pull` | Télécharge les images |
| `docker compose stop` / `start` | Arrête / redémarre sans supprimer |
| `docker compose restart` | Redémarre les services |
| `docker compose config` | Configuration finale après substitution et fusion |

| Après une modification de… | Commande |
|----------------------------|----------|
| Code de l'application | `docker compose up -d --build` |
| `compose.yaml` | `docker compose up -d` (recrée les services concernés) |

### Développement vs production : fichiers override

| Fichier | Rôle |
|---------|------|
| `docker-compose.yml` | Configuration commune |
| `docker-compose.override.yml` | Développement, **chargé automatiquement** (code monté, ports de debug) |
| `docker-compose.prod.yml` | Production, chargé explicitement (code dans l'image, ports limités, restart, logs) |

```bash
# Développement
docker compose up -d

# Production
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

> Avec `-f`, l'override automatique n'est **plus chargé** : lister explicitement tous les fichiers voulus.

**Règles de fusion :**
- Valeurs simples : le dernier fichier l'emporte.
- Listes (`ports`, `volumes`) : généralement additionnées.
- `environment` : fusion clé par clé.

### Checklist d'un projet Compose

- [ ] Tous les services démarrent avec `docker compose up -d --build`
- [ ] États vérifiés avec `docker compose ps`
- [ ] Réseaux `front` / `back` isolant les communications
- [ ] Seul le reverse proxy publie un port
- [ ] Données conservées après `down` puis `up`
- [ ] `.env` ignoré par Git, `.env.example` versionné
- [ ] `service_healthy` utilisé lorsque nécessaire
- [ ] Configurations dev et prod séparées
- [ ] README : prérequis, commandes, architecture, preuves de fonctionnement

---

## 12. Sécurité des conteneurs

### Scanner les images avec Trivy

Installation (dépôt officiel Aqua Security) :

```bash
sudo apt-get install -y wget gnupg
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key \
  | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" \
  | sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install -y trivy
```

Utilisation :

```bash
trivy image nginx:1.27
trivy image --severity HIGH,CRITICAL monapp:v1
trivy image --format table --output rapport.txt monapp:v1
```

| Champ | Signification |
|-------|---------------|
| Library | Paquet ou bibliothèque concerné |
| Vulnerability | Identifiant (CVE) |
| Severity | Gravité |
| Fixed Version | Version corrigée, si disponible |

### Corriger les vulnérabilités

1. Image de base légère et maintenue (`python:3.12-slim`, `python:3.12-alpine`).
2. Mise à jour des paquets système.
3. Mise à jour des dépendances applicatives.
4. Reconstruction de l'image puis nouveau scan.

```dockerfile
FROM python:3.12-slim
RUN apt-get update && apt-get upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
```

> Une image légère n'est pas automatiquement sécurisée : toujours vérifier le résultat du scan. Un scan mesure l'évolution des vulnérabilités sans garantir leur disparition totale.

### Utilisateur non-root

Par défaut, l'application peut tourner en root (UID 0) ; en cas de compromission, ces privilèges facilitent l'évasion du conteneur.

```dockerfile
FROM python:3.12-slim
WORKDIR /app

RUN groupadd --gid 1001 appgroup && \
    useradd --uid 1001 --gid appgroup \
      --no-create-home --shell /bin/false appuser

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
RUN chown -R appuser:appgroup /app

USER appuser
EXPOSE 5000
CMD ["python", "app.py"]
```

```bash
docker run --rm monapp:secure whoami   # → appuser
```

### Limiter les ressources

Objectif : empêcher un conteneur de monopoliser la machine hôte.

```bash
docker run -d --name web --memory 256m nginx     # RAM
docker run -d --name web --cpus 0.5 nginx        # CPU
docker run -d --name web --pids-limit 100 nginx  # nombre de processus
docker stats                                     # observation
docker inspect -f '{{.State.OOMKilled}}' web     # tué par OOM ?
```

| Option | Rôle |
|--------|------|
| `--memory` | Limite la RAM ; au-delà, le conteneur peut être tué (OOM) |
| `--memory-swap` | Limite RAM + swap |
| `--cpus` | Limite la capacité CPU |
| `--pids-limit` | Limite le nombre de processus (protection fork bomb) |

### Système de fichiers en lecture seule

```bash
docker run -d --name web \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=64m \
  nginx
```

| Option | Signification |
|--------|---------------|
| `--read-only` | Système de fichiers principal en lecture seule |
| `--tmpfs /tmp` | Espace temporaire en RAM |
| `rw` | Lecture et écriture dans ce montage |
| `noexec` | Interdit l'exécution de fichiers |
| `nosuid` | Neutralise les bits SUID/SGID |
| `size=64m` | Taille maximale |

> Certaines applications (Nginx notamment) ont besoin de plusieurs répertoires inscriptibles (cache, PID). Tester et consulter les logs avant d'activer `--read-only` en production.

### Lancement durci complet

```bash
docker run -d --name app \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=32m \
  --memory 128m \
  --cpus 0.5 \
  --pids-limit 50 \
  -p 127.0.0.1:5000:5000 \
  monapp:v2
```

### Variables d'environnement ≠ secrets

Les variables passées avec `-e` sont visibles via `docker inspect`. En environnement réel, préférer `POSTGRES_PASSWORD_FILE` ou un mécanisme de secrets.

### Récapitulatif

| Objectif | Pratique |
|----------|----------|
| Détecter les CVE | Scanner avec Trivy |
| Réduire la surface d'attaque | Image de base légère, maintenue, multi-stage |
| Réduire les privilèges | `USER appuser` |
| Contrôler la RAM | `--memory` |
| Contrôler le CPU | `--cpus` |
| Limiter les processus | `--pids-limit` |
| Réduire les écritures | `--read-only` + `--tmpfs` |
| Restreindre l'exposition réseau | `-p 127.0.0.1:PORT:PORT`, réseaux isolés |
| Protéger les secrets | Build secrets, Docker secrets, `_FILE` |
| Limiter l'accès au daemon | Groupe `docker` restreint, mode rootless, Podman |

> Sécuriser un conteneur : réduire les vulnérabilités de l'image, limiter les privilèges, contrôler les ressources, réduire les écritures et exposer uniquement le nécessaire.

---

## 13. Nettoyage

```bash
docker system df             # espace disque utilisé
docker container prune       # conteneurs arrêtés
docker image prune           # images dangling (sans tag)
docker image prune -a        # toutes les images non utilisées
docker volume prune          # volumes anonymes inutilisés
docker volume prune -a       # inclut les volumes nommés non attachés
docker network prune         # réseaux inutilisés
docker system prune -a       # nettoyage global
```

> ⚠️ `docker volume prune -a` et `docker system prune -a --volumes` peuvent supprimer des données importantes. Vérifier avant d'exécuter.

---

## 14. Diagnostic et dépannage

### Méthode

```
1. docker ps -a        → état du conteneur
2. docker logs NOM     → cause de l'erreur
3. docker exec -it NOM sh → examen de l'intérieur
4. docker inspect NOM  → configuration réelle
```

### Erreurs Docker

| Erreur | Cause probable / solution |
|--------|---------------------------|
| `Cannot connect to the Docker daemon` | Daemon arrêté → `sudo systemctl start docker` |
| `permission denied ... docker.sock` | Utilisateur hors du groupe `docker` |
| `name already in use` | Conteneur du même nom → `docker rm NOM` |
| `port is already allocated` | Port de l'hôte déjà utilisé |
| `Exited (0)` | Processus principal terminé normalement |
| `Exited (1)` | Erreur applicative → `docker logs` |
| `Exited (137)` | SIGKILL / OOM possible → vérifier `--memory` et `OOMKilled` |
| `bash: not found` | Image minimale → utiliser `sh` |
| Données perdues | Aucun volume monté |
| `pull access denied` | Image privée, inexistante ou nom erroné |
| `no space left on device` | Images, volumes, logs ou cache → `docker system df` puis `prune` |

### Erreurs réseau

| Erreur | Cause probable |
|--------|----------------|
| `could not resolve host` | Réseau par défaut sans DNS, ou conteneurs sur des réseaux différents |
| `host not found in upstream` | Nom non résolu au démarrage de Nginx (service absent ou mal nommé) |
| `connection refused` | Mauvais port ou application non démarrée |
| Port publié mais injoignable | Application liée à `127.0.0.1` dans le conteneur au lieu de `0.0.0.0` |
| `network has active endpoints` | Conteneurs encore connectés au réseau |

### Erreurs Docker Compose

| Erreur | Cause / solution |
|--------|------------------|
| `connection refused` | Base pas encore prête → `healthcheck` + `service_healthy` |
| `variable is not set` / valeur vide | `.env` absent ou mal placé → `docker compose config` |
| `password authentication failed` après changement de mot de passe | Le volume conserve la configuration initiale ; vérifier les identifiants avant toute réinitialisation |
| `502 Bad Gateway` | Backend arrêté, ou mauvais nom/port dans `proxy_pass` |
| `port is already allocated` | Changer `WEB_PORT` dans `.env` |
| Code modifié non pris en compte | `docker compose up -d --build` (sauf code monté) |
| `the attribute version is obsolete` | Supprimer la clé `version:` |
| Override de dev appliqué en prod | Utiliser `-f` avec les fichiers explicites |

---

## 15. Questions d'entretien

### Concepts

**Différence entre VM et conteneur ?**
Une VM virtualise un ordinateur complet avec son propre noyau. Un conteneur partage le noyau de l'hôte et isole l'application via namespaces et cgroups : plus léger, démarrage en secondes.

**Namespaces vs cgroups ?**
Les namespaces limitent ce que le conteneur voit, les cgroups ce qu'il consomme.

**Qu'est-ce qu'une image ?**
Un modèle immuable composé de couches en lecture seule. Un conteneur est une image plus une couche inscriptible.

**Qu'est-ce que le Copy-on-Write ?**
Un fichier de l'image n'est copié dans la couche du conteneur qu'au moment où il est modifié ; l'image reste intacte.

**`docker run` vs `docker start` ?**
`run` crée et démarre un nouveau conteneur ; `start` redémarre un conteneur existant.

**Pourquoi le groupe `docker` est-il sensible ?**
Il donne un accès au daemon équivalent à root : un membre peut monter `/` de l'hôte dans un conteneur.

### Dockerfile

**CMD vs ENTRYPOINT ?**
ENTRYPOINT fixe le programme principal ; CMD fournit des arguments par défaut remplaçables au `docker run`.

**Pourquoi la forme exec ?**
Le processus reçoit directement les signaux comme SIGTERM et s'arrête proprement.

**ARG vs ENV ?**
ARG n'existe que pendant le build ; ENV est conservée dans l'image et au runtime.

**Comment optimiser le cache ?**
Ordonner du plus stable au plus changeant : dépendances avant code.

**Qu'est-ce qu'un multi-stage build ?**
Plusieurs `FROM` : la construction se fait dans une étape, seuls les artefacts sont copiés dans une image finale légère.

**Pourquoi `.dockerignore` ?**
Réduire le contexte de build, accélérer le build et éviter d'inclure `.git`, `.env` ou des clés.

**Pourquoi un secret supprimé reste-t-il dans l'image ?**
Il subsiste dans la couche où il a été ajouté.

### Volumes

**À quoi sert un volume ?**
À conserver les données indépendamment du cycle de vie du conteneur.

**Volume nommé vs bind mount ?**
Volume nommé : géré par Docker, pour les données persistantes. Bind mount : dossier précis de l'hôte, pour le code et la configuration en développement.

**Un volume remplace-t-il une sauvegarde ?**
Non. Il protège contre la suppression du conteneur, pas contre la corruption ou la suppression du volume.

**Sauvegarde logique vs physique ?**
Logique (`pg_dump`) : SQL portable, base en ligne. Physique (`tar`) : fichiers bruts, base arrêtée.

### Réseau

**Pourquoi un réseau personnalisé ?**
Pour la résolution DNS par nom de conteneur et l'isolation entre réseaux.

**Pourquoi ne pas publier le port PostgreSQL ?**
Seuls les services internes y accèdent via le réseau Docker ; ne pas l'exposer réduit la surface d'attaque.

**Pourquoi séparer front et back ?**
Pour que le proxy ne puisse pas joindre directement la base.

**`EXPOSE` publie-t-il un port ?**
Non, il documente seulement ; la publication se fait avec `-p`.

**Docker respecte-t-il UFW ?**
Pas toujours : Docker écrit ses propres règles iptables. On limite l'écoute à `127.0.0.1`.

### Docker Compose

**Pourquoi Compose ?**
Décrire et piloter plusieurs services depuis un seul fichier YAML.

**`image` vs `build` ?**
`image` utilise une image existante ; `build` en construit une depuis un Dockerfile.

**`down` vs `down -v` ?**
`down` conserve les volumes ; `down -v` les supprime avec leurs données.

**Pourquoi un healthcheck ?**
Vérifier qu'un service est réellement prêt, pas seulement démarré.

**Pourquoi utiliser `db` plutôt qu'une IP ?**
Compose fournit un DNS interne par nom de service ; les IP changent.

**`.env` vs `env_file` ?**
`.env` sert à la substitution dans le YAML ; `env_file` injecte les variables dans le conteneur.

### Sécurité

**Pourquoi un utilisateur non-root ?**
Limiter les dégâts en cas de compromission et compliquer l'évasion du conteneur.

**Qu'est-ce que Trivy ?**
Un scanner qui détecte les CVE connues dans les paquets et bibliothèques d'une image, avec gravité et version corrigée.

**Comment durcir un conteneur au lancement ?**
`--read-only`, `--tmpfs`, `--memory`, `--cpus`, `--pids-limit`, publication sur `127.0.0.1`, utilisateur non-root.

---

## 16. Aide-mémoire

### Les 15 réflexes Docker

1. Conteneur ≠ VM : processus isolé par namespaces + cgroups.
2. Les conteneurs partagent le noyau de l'hôte.
3. Image = modèle, conteneur = instance.
4. `docker run` = pull si nécessaire + création + démarrage.
5. `docker ps -a` → connaître l'état.
6. `docker logs` → comprendre l'erreur.
7. `docker exec -it` → entrer dans le conteneur.
8. `docker inspect` → voir la configuration réelle.
9. La couche du conteneur est éphémère.
10. Données importantes → volume.
11. Plusieurs conteneurs → réseau personnalisé.
12. Ne publier que les ports nécessaires.
13. Accès local uniquement → `127.0.0.1:PORT:PORT`.
14. Dockerfile → étapes stables avant étapes changeantes.
15. Aucun secret dans une image ; les variables d'environnement ne sont pas un mécanisme de secret.

### Commandes à connaître par cœur

```bash
docker ps -a
docker run
docker start / stop / rm
docker images
docker pull
docker build
docker logs
docker exec -it
docker inspect
docker stats
docker network create
docker volume create
docker system df
docker compose up -d / down / ps / logs -f
```

### Vue d'ensemble DevOps

| Brique | Rôle |
|--------|------|
| **Images** | Packaging de l'application |
| **Containers** | Exécution |
| **Dockerfile** | Construction reproductible |
| **Volumes** | Persistance |
| **Networks** | Communication et isolation |
| **Registry** | Stockage et partage des images |
| **Compose** | Orchestration multi-conteneurs |

> **En une phrase :** Compose automatise une application multi-conteneurs ; les réseaux assurent communication et isolation, les volumes la persistance, et les healthchecks la fiabilité du démarrage.

---

## 17. Ressources

- [Documentation officielle Docker](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/)
- [Référence Compose](https://docs.docker.com/compose/compose-file/)
- [Bonnes pratiques Dockerfile](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker rootless](https://docs.docker.com/engine/security/rootless/)
- [Trivy](https://trivy.dev/)
- [Image officielle PostgreSQL](https://hub.docker.com/_/postgres)

---

## 18. Projet : secure-docker-stack

> 🔗 **Dépôt :** [github.com/slimanebou/secure-docker-stack](https://github.com/slimanebou/secure-docker-stack) · 📁 **Dans ce lab :** [`secure-docker-stack/`](./secure-docker-stack)

Mise en pratique de l'ensemble de ce cours dans une stack multi-conteneurs sécurisée.

| Notion du cours | Mise en œuvre dans le projet |
|-----------------|------------------------------|
| Dockerfile | Build multi-stage, utilisateur non-root |
| Réseau | Réseaux `front` / `back` isolés, seul Nginx publie un port |
| Volumes | Persistance PostgreSQL |
| Docker Compose | Orchestration des 4 services, `depends_on` + `healthcheck` |
| Sécurité | Scan Trivy, secrets hors du dépôt |
