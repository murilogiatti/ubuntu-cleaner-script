#!/bin/bash

# ==============================================================================
# Updater for UCM
# ==============================================================================

echo "Checking for updates..."
echo "Verificando por atualizações..."

if [ -d .git ]; then
    git pull
    
    if [ $EUID -eq 0 ] || [ -n "$SUDO_USER" ]; then
        echo "Re-installing updated script..."
        echo "Re-instalando script atualizado..."
        sudo ./install.sh
    fi
else
    echo "Not a git repository. Please update manually."
    echo "Não é um repositório git. Por favor, atualize manualmente."
fi

echo "Update process finished."
echo "Processo de atualização finalizado."
