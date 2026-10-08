# Mini-Projet : Outil de Supervision Automatisé `syscheck`

Bienvenue dans le mini-projet **syscheck**, une solution légère de monitoring système sous Linux (Debian / Ubuntu). Il surveille l'espace disque, la charge CPU, la mémoire disponible et les services critiques, puis consigne les métriques de façon horodatée.

---

## 🏗️ Architecture du projet

```text
mini-projet-syscheck/
├── bin/
│   └── syscheck.sh           ← Script principal de monitoring Bash
├── systemd/
│   ├── syscheck.service      ← Unité de service systemd (oneshot)
│   └── syscheck.timer        ← Déclencheur automatique (toutes les 5 min)
├── logrotate/
│   └── syscheck              ← Règle de rotation des journaux
├── install.sh                ← Script d'installation automatique
├── uninstall.sh              ← Script de désinstallation propre
└── README.md                 ← Documentation du projet
```

---

## 🛠️ Fonctionnalités clés

| Fonctionnalité | Description |
|----------------|-------------|
| **Analyse Disque** | Vérifie tous les systèmes de fichiers réels (exclut `tmpfs`, `overlay`, `squashfs`). |
| **Charge CPU** | Compare le Load Average à 1 minute au nombre de cœurs CPU disponibles (`nproc`). |
| **Mémoire RAM** | Évalue la mémoire réellement disponible (`MemAvailable` via `/proc/meminfo`). |
| **Services systemd** | Vérifie l'état d'activité des services (`ssh`, `cron`, etc.). |
| **Robustesse** | Mode strict Bash (`set -Eeuo pipefail`), verrous anti-double exécution (`flock`), parsing d'arguments et validation des entrées. |
| **Automatisation** | Exécution récurrente via `systemd.timer` et rétention des journaux gérée par `logrotate`. |

---

## 🚀 Installation & Utilisation

### 1. Installation automatique

```bash
git clone https://github.com/SlimaneBOUAROUA/SysReseauDevSecOps-lab.git
cd SysReseauDevSecOps-lab/01-systeme-linux/mini-projet-syscheck
sudo ./install.sh
```

### 2. Exécution manuelle

```bash
# Utilisation standard (en root)
sudo /usr/local/bin/syscheck.sh

# Personnalisation des seuils et services
sudo /usr/local/bin/syscheck.sh --disk 85 --mem 15 -s ssh -s nginx -s mariadb

# Mode silencieux (n'affiche que les alertes sur stdout)
sudo /usr/local/bin/syscheck.sh -q
```

### 3. Inspection des journaux & statut

```bash
# Lire les derniers relevés
sudo tail -n 20 /var/log/syscheck.log

# Consulter le statut du timer systemd
systemctl list-timers syscheck.timer

# Vérifier les logs du service systemd
sudo journalctl -u syscheck.service -n 50 --no-pager
```

### 4. Désinstallation

```bash
sudo ./uninstall.sh
```

---

## 📊 Codes de retour (Exit Codes)

| Code | Signification |
|------|---------------|
| `0` | **OK** — Toutes les métriques et services sont sous les seuils d'alerte. |
| `1` | **ALERT** — Au moins un seuil a été dépassé ou un service est inactif. |
| `2` | **USAGE** — Erreur dans les arguments transmis au script. |
| `3` | **SOFTWARE** — Commande requise manquante ou verrou déjà actif. |

---
