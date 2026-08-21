#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Installer for UCM (now uses shared utilities)
# ==============================================================================

# Load shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Ensure we have root privileges
require_root

# Destination (weekly cron) and source script path
DEST="$UCM_CRON"
SOURCE="${SCRIPT_DIR}/ucm.sh"

# Install using helper from common.sh
install_ucm "$SOURCE" "$DEST"
