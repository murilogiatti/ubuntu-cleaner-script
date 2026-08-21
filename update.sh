#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Updater for UCM – now checks version after pulling changes
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

echo "Checking for updates..."
echo "Verificando por atualizações..."

if [[ -d "$SCRIPT_DIR/.git" ]]; then
    # Pull latest changes
    git -C "$SCRIPT_DIR" pull
    # Source the new version from the updated script (if present)
    if [[ -f "$SCRIPT_DIR/ucm.sh" ]]; then
        # Extract version variable from the script (UCM_VERSION defined in common.sh)
        source "$SCRIPT_DIR/lib/common.sh"
        echo "Current UCM version after update: $UCM_VERSION"
    fi
    # Re‑install if we are root or sudo
    if [[ "$EUID" -eq 0 ]] || [[ -n "$SUDO_USER" ]]; then
        echo "Re‑installing updated script..."
        echo "Re‑instalando script atualizado..."
        "$SCRIPT_DIR/install.sh"
    fi
else
    echo "Not a git repository. Please update manually."
    echo "Não é um repositório git. Por favor, atualize manualmente."
fi

echo "Update process finished."
echo "Processo de atualização finalizado."
