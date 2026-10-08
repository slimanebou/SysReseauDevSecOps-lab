#!/usr/bin/env bash
#
# uninstall.sh - Désinstalle syscheck et supprime ses unités systemd
#

set -Eu0 pipefail

if (( EUID != 0 )); then
    echo "Erreur : Ce script doit être exécuté en tant que root (ex: sudo ./uninstall.sh)" >&2
    exit 1
fi

echo "==> Arrêt et désactivation du timer systemd..."
systemctl disable --now syscheck.timer 2>/dev/null || true

echo "==> Suppression des fichiers installés..."
rm -f /usr/local/bin/syscheck.sh
rm -f /etc/systemd/system/syscheck.service
rm -f /etc/systemd/system/syscheck.timer
rm -f /etc/logrotate.d/syscheck

echo "==> Rechargement de la configuration systemd..."
systemctl daemon-reload

echo ""
echo "✅ Désinstallation de syscheck terminée avec succès."
echo "ℹ️ Note : Le fichier /var/log/syscheck.log a été conservé par sécurité."