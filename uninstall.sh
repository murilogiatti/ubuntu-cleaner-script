#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Uninstaller for UCM (now uses shared utilities)
# ==============================================================================

# Load shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Ensure we have root privileges
require_root

# Uninstall using helper from common.sh
uninstall_ucm "$UCM_CRON"
