#!/bin/bash

# ==============================================================================
# Installer for UCM
# ==============================================================================

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root / Este script deve ser executado como root"
   exit 1
fi

DEST="/etc/cron.weekly/ucm"
SOURCE="$(pwd)/ucm.sh"

echo "Installing UCM to $DEST..."
echo "Instalando UCM em $DEST..."

cp "$SOURCE" "$DEST"
chown root:root "$DEST"
chmod 755 "$DEST"

echo "Installation complete! The script will run automatically every week."
echo "Instalação concluída! O script será executado automaticamente toda semana."
