# Module 01 — Administration Système Linux & Scripting

## 🎯 Objectifs
Ce module regroupe l'ensemble des compétences fondamentales et avancées en administration de systèmes Linux (Debian / Ubuntu) :
* Maîtrise du système de fichiers (FHS), gestion des utilisateurs et des permissions (chmod, ACL, sudoers).
* Gestion fine des processus, surveillance des ressources système (RAM, CPU, Disque) et administration des services via `systemd`.
* Collecte, analyse approfondie des journaux d'événements (`rsyslog`, `journald`, `logrotate`) et filtrage avancé.
* Hardening et sécurisation du démon SSH (`sshd`) ainsi que la prévention contre le brute-force avec `fail2ban`.
* Automatisation d'outils d'administration via du scripting **Bash avancé** (fonctions, gestion d'arguments, gestion d'erreurs, regex).

---

## 📂 Structure du module

| Dossier | Sujet / Compétence | Statut |
| :--- | :--- | :---: |
| [01-fondations-permissions](./fondations-permissions/) | FHS, navigation, identités, permissions Unix (chmod/chown), ACL & `sudoers` | ✅ Terminé |
| [02-processus-systemd](./processus-systemd/) | Gestion des processus, signaux Unix, surveillance système & services `systemd` | ✅ Terminé |
| [03-logs-surveillance](./logs-surveillance/) | Architecture des logs (`rsyslog`/`journald`), rotation `logrotate` & outils d'analyse (`awk`, `sed`, `grep`) | ✅ Terminé |
| [04-ssh-hardening](./ssh-hardening/) | Authentification ED25519, sécurisation `sshd`, alias SSH & protection contre les intrusions avec `fail2ban` | ✅ Terminé |
| [05-bash-avance](./bash-avance/) | Scripting Bash robuste, gestion d'erreurs (`set -Eeuo pipefail`), `trap`, `getopts` & tableaux associatifs | ✅ Terminé |
| [06-mini-projet-syscheck](./mini-projet-syscheck/) | **Mini-projet concret** : Outil d'audit système automatique intégrant service `systemd` & rotation de logs | ✅ Terminé |

---

## 🛠️ Outils & Technologies maîtrisés
* **Systèmes :** Debian, Ubuntu Server.
* **Administration & Surveillance :** `systemctl`, `journalctl`, `htop`, `vmstat`, `free`, `df`, `du`, `logrotate`.
* **Analyse & Scripting :** Bash, `grep -E`, `awk`, `sed`, `cut`, `sort`, `uniq`, `find`.
* **Sécurité & Contrôle d'accès :** ACL (`getfacl`/`setfacl`), `visudo`, SSH (ED25519), `fail2ban`.