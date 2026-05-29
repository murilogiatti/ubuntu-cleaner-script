#!/bin/bash

# ==============================================================================
# Uninstaller for UCM
# ==============================================================================

if [[ "$EUID" -ne 0 ]]; then
   echo "This script must be run as root / Este script deve ser executado como root"
   exit 1
fi

DEST="/etc/cron.weekly/ucm"
LOG="/var/log/ucm_maintenance.log"

echo "Uninstalling UCM..."
echo "Desinstalando UCM..."

rm -f "$DEST"
rm -f "$LOG"

# Remove legacy scripts if they exist
rm -f "/etc/cron.weekly/manutencao-semanal"

echo "Uninstallation complete. Logs and cron scripts removed."
echo "Desinstalação concluída. Logs e scripts do cron removidos."
