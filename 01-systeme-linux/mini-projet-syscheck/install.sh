#!/usr/bin/env bash
#
# install.sh - Installe syscheck (script binaire, service/timer systemd, logrotate)
#

set -Eu0 pipefail

if (( EUID != 0 )); then
    echo "Erreur : Ce script doit être exécuté en tant que root (ex: sudo ./install.sh)" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installation des fichiers binaires et de configuration..."
install -m 755 "$SCRIPT_DIR/bin/syscheck.sh" /usr/local/bin/syscheck.sh
install -m 644 "$SCRIPT_DIR/systemd/syscheck.service" /etc/systemd/system/syscheck.service
install -m 644 "$SCRIPT_DIR/systemd/syscheck.timer" /etc/systemd/system/syscheck.timer

if [[ -d "$SCRIPT_DIR/logrotate" && -f "$SCRIPT_DIR/logrotate/syscheck" ]]; then
    install -m 644 "$SCRIPT_DIR/logrotate/syscheck" /etc/logrotate.d/syscheck
fi

echo "==> Rechargement de la configuration systemd..."
systemctl daemon-reload

echo "==> Activation et démarrage du timer systemd..."
systemctl enable --now syscheck.timer

echo "==> Vérification du statut du timer :"
systemctl list-timers syscheck.timer --no-pager

echo ""
echo "✅ Installation de syscheck terminée avec succès !"
echo "📌 Fichier de log : /var/log/syscheck.log"