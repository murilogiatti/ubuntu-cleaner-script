#!/usr/bin/env bash

# ==============================================================================
# Title:        Ubuntu Cleaner & Maintainer (UCM)
# Description:  A dynamic script to keep Ubuntu systems updated and clean.
# Author:       Murilo Giatti
# License:      MIT
# ==============================================================================

# Load common utilities and modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/apt_maint.sh"
source "$SCRIPT_DIR/lib/snap_clean.sh"
source "$SCRIPT_DIR/lib/log_vacuum.sh"
source "$SCRIPT_DIR/lib/run_as_user.sh"
source "$SCRIPT_DIR/lib/browser_cache.sh"
source "$SCRIPT_DIR/lib/thumbnail.sh"
source "$SCRIPT_DIR/lib/dev_clean.sh"
source "$SCRIPT_DIR/lib/gpu_cache.sh"
source "$SCRIPT_DIR/lib/system_extra.sh"

# ---------------------------------------------------------------------------
# Global defaults (can be overridden by command‑line flags)
# ---------------------------------------------------------------------------
DRY_RUN=false
VERBOSE=false
SKIP_APT=false
SKIP_SNAP=false
SKIP_FLATPAK=false
SKIP_USER=false
SKIP_DEV=false
SKIP_GPU=false
SKIP_TRASH=false
ASSUME_YES=false
TARGET_USER=""
LOG_FILE="/var/log/ucm_maintenance.log"
REPORT_PATH=""

# ---------------------------------------------------------------------------
# Helper: print usage
# ---------------------------------------------------------------------------
usage() {
    cat <<'EOF'
Usage: ucm.sh [options]
Options:
  -d, --dry-run          Show what would be done without executing actions.
  -v, --verbose          Enable bash tracing (set -x).
  -u, --user USER        Specify the non‑root user for user‑level maintenance.
  --log FILE             Write log to FILE (default /var/log/ucm_maintenance.log).
  --skip-apt             Skip APT maintenance.
  --skip-snap            Skip Snap maintenance.
  --skip-flatpak         Skip Flatpak maintenance.
  --skip-user            Skip user‑level maintenance entirely.
  --skip-dev             Skip developer caches cleanup (UV, Pip, Node, VS Code, Docker).
  --skip-gpu             Skip GPU shader caches cleanup (Mesa, RADV, NVIDIA).
  --skip-trash           Skip emptying user trash.
  -y, --yes              Run non-interactively, assuming yes for confirmations.
  --report FILE          Generate a summary report at FILE (.md or .txt).
  -h, --help             Show this help message.
EOF
}

# ---------------------------------------------------------------------------
# Parse command‑line options
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--dry-run) DRY_RUN=true; shift;;
        -v|--verbose) VERBOSE=true; shift;;
        -u|--user)
            [[ $# -ge 2 && "$2" != -* ]] || { echo "Missing value for $1"; usage; exit 1; }
            TARGET_USER="$2"; shift 2;;
        --log)
            [[ $# -ge 2 && "$2" != -* ]] || { echo "Missing value for $1"; usage; exit 1; }
            LOG_FILE="$2"; shift 2;;
        --skip-apt) SKIP_APT=true; shift;;
        --skip-snap) SKIP_SNAP=true; shift;;
        --skip-flatpak) SKIP_FLATPAK=true; shift;;
        --skip-user) SKIP_USER=true; shift;;
        --skip-dev) SKIP_DEV=true; shift;;
        --skip-gpu) SKIP_GPU=true; shift;;
        --skip-trash) SKIP_TRASH=true; shift;;
        -y|--yes|--non-interactive) ASSUME_YES=true; shift;;
        --report)
            [[ $# -ge 2 && "$2" != -* ]] || { echo "Missing value for $1"; usage; exit 1; }
            REPORT_PATH="$2"; shift 2;;
        -h|--help) usage; exit 0;;
        *) echo "Unknown option: $1"; usage; exit 1;;
    esac
done

# Enable verbose mode if requested
if [[ "$VERBOSE" == true ]]; then
    set -x
fi

# Ensure we are root for operations that need it
require_root

# Prepare locale messages (populate associative array MSG)
set_locale_messages

# Set up logging (tee to file while preserving console output)
tee_to_log

# Set up a trap for errors
trap 'echo "Error on line $LINENO. Exiting."' ERR

# Determine target user if not provided
if [[ -z "$TARGET_USER" ]]; then
    TARGET_USER="$(who am i 2>/dev/null | awk '{print $1}')"
    if [[ -z "$TARGET_USER" && -n "${SUDO_USER:-}" ]]; then
        TARGET_USER="$SUDO_USER"
    fi
    if [[ -z "$TARGET_USER" ]]; then
        TARGET_USER="$(awk -F: '$3 >= 1000 && $3 < 60000 && $1 != "nobody" { print $1; exit }' /etc/passwd 2>/dev/null)"
    fi
fi

# If target user was provided as a numeric UID, resolve to login name
if [[ "$TARGET_USER" =~ ^[0-9]+$ ]]; then
    RESOLVED_USER="$(id -nu "$TARGET_USER" 2>/dev/null || true)"
    if [[ -n "$RESOLVED_USER" ]]; then
        TARGET_USER="$RESOLVED_USER"
    fi
fi

# Begin report summary collection
REPORT_SUMMARY=()

# ---------------------------------------------------------------------------
# Header output
# ---------------------------------------------------------------------------
echo "========================================"
echo "${MSG[start]}: $(date)"
echo "${MSG[user]}: ${TARGET_USER:-<none>}"
echo "========================================"

# ---------------------------------------------------------------------------
# 1. APT maintenance (skip if requested)
# ---------------------------------------------------------------------------
if [[ "$SKIP_APT" != true ]]; then
    if confirm_action "Proceed with APT maintenance?"; then
        apt_maintenance
        if [[ "$DRY_RUN" == true ]]; then
            REPORT_SUMMARY+=("APT maintenance simulated")
        else
            REPORT_SUMMARY+=("APT maintenance completed")
        fi
    else
        echo "APT maintenance skipped by user."
        REPORT_SUMMARY+=("APT maintenance skipped")
    fi
else
    echo "--skip-apt flag provided – APT maintenance omitted."
    REPORT_SUMMARY+=("APT maintenance omitted via flag")
fi

# ---------------------------------------------------------------------------
# 2. Snap maintenance (skip if requested)
# ---------------------------------------------------------------------------
if [[ "$SKIP_SNAP" != true ]]; then
    if confirm_action "Proceed with Snap maintenance?"; then
        snap_maintenance
        if [[ "$DRY_RUN" == true ]]; then
            REPORT_SUMMARY+=("Snap maintenance simulated")
        else
            REPORT_SUMMARY+=("Snap maintenance completed")
        fi
    else
        echo "Snap maintenance skipped by user."
        REPORT_SUMMARY+=("Snap maintenance skipped")
    fi
else
    echo "--skip-snap flag provided – Snap maintenance omitted."
    REPORT_SUMMARY+=("Snap maintenance omitted via flag")
fi

# ---------------------------------------------------------------------------
# 3. Flatpak maintenance (skip if requested)
# ---------------------------------------------------------------------------
if [[ "$SKIP_FLATPAK" != true ]]; then
    if command -v flatpak &>/dev/null; then
        if confirm_action "Proceed with Flatpak maintenance?"; then
            flatpak_maintenance
            if [[ "$DRY_RUN" == true ]]; then
                REPORT_SUMMARY+=("Flatpak maintenance simulated")
            else
                REPORT_SUMMARY+=("Flatpak maintenance completed")
            fi
        else
            echo "Flatpak maintenance skipped by user."
            REPORT_SUMMARY+=("Flatpak maintenance skipped")
        fi
    fi
else
    echo "--skip-flatpak flag provided – Flatpak maintenance omitted."
    REPORT_SUMMARY+=("Flatpak maintenance omitted via flag")
fi

# ---------------------------------------------------------------------------
# 4. System logs & crash cleanup
# ---------------------------------------------------------------------------
log_vacuum
if [[ "$DRY_RUN" == true ]]; then
    REPORT_SUMMARY+=("System logs and crash cleanup simulated")
else
    REPORT_SUMMARY+=("System logs and crash reports cleaned")
fi

# ---------------------------------------------------------------------------
# 5. User‑level maintenance (skip if requested)
# ---------------------------------------------------------------------------
if [[ "$SKIP_USER" != true && -n "$TARGET_USER" ]]; then
    if confirm_action "Proceed with user‑level maintenance for $TARGET_USER?"; then
        TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
        if [[ -z "$TARGET_HOME" || ! -d "$TARGET_HOME" ]]; then
            TARGET_HOME="/home/$TARGET_USER"
        fi

        # NPM update (only if prefix is writable by user)
        if [[ "$DRY_RUN" == true ]]; then
            echo "[DRY-RUN] npm update -g"
        else
            run_as_user "$TARGET_USER" "if command -v npm &>/dev/null; then npm_p=\$(npm config get prefix 2>/dev/null || echo '/usr'); if [ -w \"\$npm_p\" ] || [ -w \"\$npm_p/lib\" ]; then echo \"${MSG[npm]}\"; npm update -g; fi; fi"
        fi

        # UV update
        if [[ "$DRY_RUN" == true ]]; then
            echo "[DRY-RUN] uv self update && uv tool upgrade --all"
        else
            run_as_user "$TARGET_USER" "if command -v uv &>/dev/null; then echo \"${MSG[uv]}\"; uv self update &>/dev/null; uv tool upgrade --all; fi"
        fi

        # Developer Caches (UV, Pip, NPM, Rust, Go, VS Code, Docker)
        if [[ "$SKIP_DEV" != true ]]; then
            run_as_user "$TARGET_USER" "declare -A MSG; $(declare -f run_cmd clean_dev_cache); DRY_RUN=$DRY_RUN; MSG[dev_clean]='${MSG[dev_clean]}'; MSG[docker_clean]='${MSG[docker_clean]}'; clean_dev_cache \"$TARGET_HOME\""
        fi

        # Browser caches (Deep Chromium + Firefox)
        run_as_user "$TARGET_USER" "declare -A MSG; $(declare -f run_cmd clean_browser_cache); DRY_RUN=$DRY_RUN; MSG[chrome]='${MSG[chrome]}'; MSG[brave]='${MSG[brave]}'; MSG[edge]='${MSG[edge]}'; MSG[firefox]='${MSG[firefox]}'; clean_browser_cache \"$TARGET_HOME\""

        # GPU Shader Caches (Mesa, RADV, NVIDIA)
        if [[ "$SKIP_GPU" != true ]]; then
            run_as_user "$TARGET_USER" "declare -A MSG; $(declare -f run_cmd clean_gpu_cache); DRY_RUN=$DRY_RUN; MSG[gpu_clean]='${MSG[gpu_clean]}'; clean_gpu_cache \"$TARGET_HOME\""
        fi

        # Flatpak User App Caches
        run_as_user "$TARGET_USER" "declare -A MSG; $(declare -f run_cmd clean_flatpak_user_cache); DRY_RUN=$DRY_RUN; clean_flatpak_user_cache \"$TARGET_HOME\""

        # Thumbnail cache
        run_as_user "$TARGET_USER" "declare -A MSG; $(declare -f run_cmd clean_thumbnail); DRY_RUN=$DRY_RUN; MSG[thumb]='${MSG[thumb]}'; clean_thumbnail \"$TARGET_HOME\""

        # User Trash
        if [[ "$SKIP_TRASH" != true ]]; then
            run_as_user "$TARGET_USER" "declare -A MSG; $(declare -f run_cmd clean_user_trash); DRY_RUN=$DRY_RUN; MSG[trash]='${MSG[trash]}'; clean_user_trash \"$TARGET_HOME\""
        fi

        if [[ "$DRY_RUN" == true ]]; then
            REPORT_SUMMARY+=("User‑level maintenance for $TARGET_USER simulated")
        else
            REPORT_SUMMARY+=("User‑level maintenance for $TARGET_USER completed")
        fi
    else
        echo "User‑level maintenance skipped by user."
        REPORT_SUMMARY+=("User‑level maintenance skipped")
    fi
else
    echo "--skip-user flag provided or no target user – user‑level maintenance omitted."
    REPORT_SUMMARY+=("User‑level maintenance omitted via flag or missing user")
fi

# ---------------------------------------------------------------------------
# Footer output
# ---------------------------------------------------------------------------
echo "========================================"
echo "${MSG[end]}: $(date)"
echo "${MSG[log_save]}: $LOG_FILE"
if [[ -n "$REPORT_PATH" ]]; then
    echo "Generating report at $REPORT_PATH"
    mkdir -p "$(dirname "$REPORT_PATH")"
    sync 2>/dev/null || true

    {
        echo "# UCM Maintenance Report"
        echo ""
        echo "- **Date:** $(date)"
        echo "- **Version:** ${UCM_VERSION:-1.5.0}"
        echo "- **User:** ${TARGET_USER:-<none>}"
        echo "- **Log Path:** $LOG_FILE"
        echo ""
        echo "## Summary"
        echo ""
        for item in "${REPORT_SUMMARY[@]}"; do
            echo "- $item"
        done
        echo ""
        echo "## Execution Log"
        echo ""
        echo '```text'
        if [[ -f "$LOG_FILE" ]]; then
            cat "$LOG_FILE"
        fi
        echo '```'
    } > "$REPORT_PATH"
    echo "Report generated."
    REPORT_SUMMARY+=("Report generated at $REPORT_PATH")
fi

echo "========================================"
