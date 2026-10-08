# Processus, Surveillance système & systemd

> **Phase 1 — Administration Linux & Système**
> Statut : ✅ Terminé

---

## Objectif

Maîtriser la gestion des processus Linux, la surveillance des ressources système (RAM, disque, CPU) et l'administration complète des services via `systemd`. À la fin, tu es capable de diagnostiquer un serveur, tuer un processus bloqué, créer un service custom et analyser les logs système.

---

## Sommaire

- [Module 1 — Processus & Surveillance](#module-1--processus--surveillance)
  - [1. Gestion des processus](#1-gestion-des-processus)
  - [2. Signaux Unix](#2-signaux-unix)
  - [3. Priorité des processus](#3-priorité-des-processus)
  - [4. nohup](#4-nohup)
  - [5. Mémoire](#5-mémoire)
  - [6. Disque & Stockage](#6-disque--stockage)
  - [7. Variables d'environnement](#7-variables-denvironnement)
  - [8. Exercice 1 — Top 5 processus par RAM](#8-exercice-1--top-5-processus-par-ram)
- [Module 2 — systemd & Services](#module-2--systemd--services)
  - [9. Concepts systemd](#9-concepts-systemd)
  - [10. Commandes systemctl](#10-commandes-systemctl)
  - [11. Anatomie d'un fichier .service](#11-anatomie-dun-fichier-service)
  - [12. journalctl](#12-journalctl)
  - [13. Exercice 2 — Service systemd health-check](#13-exercice-2--service-systemd-health-check)
- [Commandes clés apprises](#commandes-clés-apprises)
- [Difficultés rencontrées & solutions](#difficultés-rencontrées--solutions)

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

#### `ps` — photographier les processus

```bash
ps aux                    # Tous les processus de tous les utilisateurs
ps aux | grep nginx       # Filtrer un processus précis
ps -ef --forest           # Arborescence parent → enfant
ps aux --sort=-%mem       # Trier par consommation mémoire décroissante
ps aux --sort=-%cpu       # Trier par consommation CPU décroissante
```

#### `top` et `htop` — surveillance dynamique

```bash
top                       # Lancer top
htop                      # Lancer htop (interactif)
```

**Dans `top` :**

| Touche | Action |
|---|---|
| `M` | Trier par mémoire |
| `P` | Trier par CPU |
| `1` | Afficher tous les cœurs |
| `k` | Tuer un processus |

#### `pgrep` et `pkill`

```bash
pgrep -l nginx            # Obtenir le PID de nginx
pkill nginx               # Envoyer SIGTERM à tous les processus nginx
pkill -9 -u slimane       # Forcer l'arrêt de tous les processus de slimane
```

---

### 2. Signaux Unix

| Signal | Numéro | Comportement |
|---|---|---|
| `SIGHUP` | 1 | Rechargement de configuration sans redémarrage |
| `SIGINT` | 2 | Interruption clavier (Ctrl+C) |
| `SIGTERM` | 15 | Demande d'arrêt propre (le processus peut nettoyer) |
| `SIGKILL` | 9 | Arrêt forcé immédiat et inévitable |
| `SIGSTOP` | 19 | Mise en pause (Ctrl+Z) |
| `SIGCONT` | 18 | Reprise après SIGSTOP |

**Bonnes pratiques pour tuer un processus :**

```bash
kill 1234                 # 1. Essayer SIGTERM d'abord
sleep 5                   # 2. Attendre 5 secondes
kill -9 1234              # 3. Forcer seulement si nécessaire
```

> **⚠️ Important :** SIGKILL ne peut pas être intercepté ni ignoré par le processus, ce qui l'empêche de nettoyer ses fichiers temporaires. À utiliser en dernier recours.

---

### 3. Priorité des processus

```plaintext
-20  →  Priorité maximale (root uniquement)
  0  →  Priorité normale (défaut)
+19  →  Priorité minimale
```

```bash
nice -n 15 tar -czf backup.tar.gz /home/    # Lancer avec priorité basse
renice -n 10 -p 1234                        # Changer la priorité du PID 1234
```

- `nice` : définit la priorité **au lancement** d'un processus.
- `renice` : modifie la priorité d'un processus **déjà en cours**.
- Les valeurs négatives (priorité haute) sont réservées à root.

---

### 4. nohup

Lance un processus **insensible au hangup** (déconnexion, fermeture du terminal). Le processus continue de tourner après la fermeture du terminal.

```bash
nohup ./mon-script.sh > /var/log/script.log 2>&1 &
```

| Élément | Signification |
|---|---|
| `nohup` | Ignore le signal SIGHUP à la déconnexion |
| `> /var/log/script.log` | Redirige la sortie standard vers un fichier |
| `2>&1` | Redirige aussi les erreurs (stderr) vers le même fichier |
| `&` | Lance en arrière-plan (background) |

---

### 5. Mémoire

```bash
free -h            # Affichage lisible de la RAM et du Swap
vmstat 2 5         # Statistiques système (CPU, mémoire, I/O) — toutes les 2s, 5 fois
```

> **💡 Astuce :** la colonne `available` de `free -h` indique la réelle quantité de RAM utilisable pour de nouveaux programmes (inclut le cache libérable).

---

### 6. Disque & Stockage

```bash
df -h                                # Espace disponible sur les partitions
du -h /var | sort -rh | head -10     # Top 10 des plus gros dossiers dans /var
lsblk -f                             # Arborescence des disques et systèmes de fichiers
sudo fdisk -l                        # Table de partitions
```

#### `/etc/fstab` — montage automatique

```plaintext
UUID=a1b2c3d4   /mnt/data   ext4   defaults,noatime   0   2
```

| Champ | Signification |
|---|---|
| `UUID=a1b2c3d4` | Identifiant unique du disque (stable, contrairement à /dev/sdX) |
| `/mnt/data` | Point de montage |
| `ext4` | Système de fichiers |
| `defaults,noatime` | Options de montage |
| `0` | Dump (sauvegarde — 0 = désactivé) |
| `2` | Ordre de vérification fsck au boot (0 = jamais, 1 = racine, 2 = autres) |

```bash
sudo blkid /dev/sdb1                 # Récupérer l'UUID
sudo mount -a                         # Tester la configuration fstab sans redémarrer
```

> **✅ Bonne pratique :** toujours tester avec `sudo mount -a` avant de redémarrer, pour éviter un boot bloqué en mode rescue.

---

### 7. Variables d'environnement

```bash
export MON_API_KEY="abc123"           # Définir une variable d'environnement
export PATH=$PATH:/opt/mon-outil/bin  # Ajouter un dossier au PATH
source ~/.bashrc                      # Recharger la configuration du shell
```

| Commande | Usage |
|---|---|
| `env` | Afficher toutes les variables d'environnement |
| `echo $PATH` | Afficher une variable précise |
| `source` ou `.` | Recharger un fichier de configuration dans le shell courant |

---

### 8. Exercice 1 — Top 5 processus par RAM

```bash
ps aux --sort=-%mem | awk 'NR>1 {print $4"% - "$11" (PID:"$2")"}' | head -5
```

**Explication :**

| Élément | Rôle |
|---|---|
| `ps aux --sort=-%mem` | Liste tous les processus triés par mémoire décroissante |
| `awk 'NR>1 {...}'` | Ignore la ligne d'en-tête (`NR>1`) et reformate chaque ligne |
| `$4` | Colonne %MEM (consommation RAM) |
| `$2` | Colonne PID |
| `$11` | Colonne COMMAND (la commande lancée) |
| `head -5` | Garde seulement le top 5 |

---

## Module 2 — systemd & Services

### 9. Concepts systemd

`systemd` remplace `SysVinit` en démarrant les services **en parallèle** et en utilisant des fichiers déclaratifs `.service`.

| Concept | Description |
|---|---|
| **Unit** | Toute ressource gérée par systemd (service, timer, socket, mount...) |
| **Service** | Un type d'unit représentant un processus à lancer |
| **Target** | Point de synchronisation du boot (équivalent des runlevels) — ex : `multi-user.target` |
| **Journal** | Logs centralisés binaires (`journald`) consultés via `journalctl` |

---

### 10. Commandes systemctl

```bash
sudo systemctl start nginx            # Démarrer le service
sudo systemctl stop nginx             # Arrêter le service
sudo systemctl restart nginx          # Redémarrer (stop + start)
sudo systemctl reload nginx           # Rechargement à chaud (SIGHUP, sans coupure)
systemctl status nginx                # Afficher l'état détaillé du service
sudo systemctl enable --now nginx     # Activer au démarrage ET lancer immédiatement
sudo systemctl disable nginx          # Désactiver au démarrage
sudo systemctl daemon-reload          # À exécuter après toute modification d'un .service
```

> **⚠️ Important :** après chaque modification d'un fichier `.service`, il faut impérativement lancer `sudo systemctl daemon-reload` pour que systemd relise sa configuration.

---

### 11. Anatomie d'un fichier .service

**Exemple d'emplacement :** `/etc/systemd/system/health-check.service`

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

| Section | Directive | Rôle |
|---|---|---|
| `[Unit]` | `Description` | Description humaine du service |
| `[Unit]` | `After` | Ordre de démarrage : après cette unit |
| `[Unit]` | `Wants` | Dépendance souple (démarre si possible, sans bloquer) |
| `[Service]` | `Type=oneshot` | S'exécute une fois puis s'arrête (vs `simple` / `forking`) |
| `[Service]` | `ExecStart` | Commande à exécuter |
| `[Service]` | `User` | Utilisateur sous lequel tourne le service |
| `[Service]` | `StandardOutput/StandardError` | Redirection des logs vers journald |
| `[Install]` | `WantedBy=multi-user.target` | Cible dans laquelle le service sera activé (`systemctl enable`) |

---

### 12. journalctl

```bash
journalctl -u nginx                    # Logs du service nginx
journalctl -u nginx -f                 # Suivre les logs en temps réel
journalctl --since "1 hour ago" -p err # Logs d'erreur de la dernière heure
journalctl -b                          # Logs du démarrage courant (boot)
```

| Option | Rôle |
|---|---|
| `-u <service>` | Filtrer par unit systemd |
| `-f` | Suivi en temps réel (comme `tail -f`) |
| `-p err` | Filtrer par priorité (emerg, alert, crit, err, warning, notice, info, debug) |
| `--since` / `--until` | Filtrer par période |
| `-b` | Logs du boot courant (`-b -1` = boot précédent) |
| `-n 50` | Les 50 dernières lignes |

---

### 13. Exercice 2 — Service systemd health-check

#### Étape 1 — Script `/opt/scripts/health_check.sh`

```bash
#!/bin/bash
set -euo pipefail

LOG_FILE="/var/log/health_check.log"
SEUIL_DISQUE=80
SERVICES=("ssh" "cron" "rsyslog")

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "===== Debut du health check ====="

usage=$(df -h / | awk 'NR==2 {gsub(/%/,"",$5); print $5}')
if [ "$usage" -gt "$SEUIL_DISQUE" ]; then
    log "ALERTE  Disque / utilise a ${usage}%"
else
    log "OK      Disque / : ${usage}%"
fi

for service in "${SERVICES[@]}"; do
    if systemctl is-active --quiet "$service"; then
        log "OK      Service ${service} : actif"
    else
        log "ALERTE  Service ${service} : INACTIF"
    fi
done

log "===== Fin du health check ====="
```

**Points clés du script :**

| Élément | Rôle |
|---|---|
| `set -euo pipefail` | Arrêt immédiat en cas d'erreur, variables non définies interdites |
| `df -h / | awk 'NR==2 ...'` | Extrait le % d'utilisation de la partition racine |
| `gsub(/%/,"",$5)` | Supprime le symbole % pour pouvoir comparer numériquement |
| `systemctl is-active --quiet` | Teste un service sans afficher de sortie |
| `tee -a` | Écrit dans le fichier ET affiche à l'écran |

#### Étape 2 — Activation du service

```bash
sudo chmod +x /opt/scripts/health_check.sh
sudo systemctl daemon-reload
sudo systemctl enable --now health-check.service
```

---

## Commandes clés apprises

```bash
# Processus & Signaux
ps aux --sort=-%mem; top; htop; pgrep -l; pkill -9; kill -15; nice; renice; nohup

# Mémoire & Disque
free -h; vmstat 2 5; df -hT; du -sh; lsblk -f; mount -a; blkid

# systemd & journalctl
systemctl start/stop/restart/reload/enable/disable; systemctl daemon-reload; journalctl -u -f -p err
```

---

## Difficultés rencontrées & solutions

| Difficulté rencontrée | Solution appliquée |
|----------------------|--------------------|
| `free` montre peu de RAM disponible | Consulter la colonne `available` qui prend en compte le cache libérable |
| Montage fstab échoue au boot | Utiliser l'UUID fixe du disque (`blkid`) au lieu du nom de périphérique `/dev/sdX` |
| Modifications d'un fichier `.service` non prises en compte | Toujours lancer `sudo systemctl daemon-reload` après modification |

---

## Fiche mémo — Signaux & bonnes pratiques

| Situation | Commande |
|-----------|----------|
| Tuer proprement un processus | `kill <PID>` (SIGTERM 15) |
| Tuer en dernier recours | `kill -9 <PID>` (SIGKILL) |
| Suspendre un processus | `kill -19 <PID>` ou `Ctrl+Z` |
| Reprendre un processus suspendu | `kill -18 <PID>` |
| Continuer après fermeture du terminal | `nohup cmd > log 2>&1 &` |
| Rendre un service permanent | `systemctl enable --now <service>` |
| Tester fstab sans reboot | `mount -a` |

| Bonne pratique | Raison |
|----------------|--------|
| SIGTERM avant SIGKILL | Permet au processus de nettoyer ses ressources |
| `daemon-reload` après chaque `.service` | systemd ne relit pas sa config automatiquement |
| UUID dans fstab | Le nom `/dev/sdX` peut changer selon l'ordre de détection des disques |
| `Type=oneshot` pour les scripts | Le service se termine proprement au lieu de rester "actif" |

---

*Document généré pour la Phase 1 — Module 2 : Processus, Surveillance système & systemd*
