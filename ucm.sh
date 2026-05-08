#!/bin/bash

# ==============================================================================
# Title:        Ubuntu Cleaner & Maintainer (UCM)
# Description:  A dynamic script to keep Ubuntu systems updated and clean.
# Author:       Murilo Giatti
# License:      MIT
# ==============================================================================

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Detect current logged-in user (excluding root)
REAL_USER=$(who | awk 'NR==1{print $1}')
if [ -z "$REAL_USER" ]; then
    REAL_USER=$SUDO_USER
fi

LOG_FILE="/var/log/ucm_maintenance.log"
exec > >(tee -a $LOG_FILE)
exec 2>&1

echo "========================================"
echo "Starting system maintenance: $(date)"
echo "Targeting User: $REAL_USER"
echo "========================================"

# 1. APT Maintenance
echo "--- Updating APT Packages ---"
export DEBIAN_FRONTEND=noninteractive
apt-get update -q
apt-get upgrade -yq

echo "--- Cleaning APT Caches & Orphans ---"
apt-get autoremove --purge -yq
apt-get clean -q
apt-get autoclean -q

echo "--- Purging Residual Configs (rc status) ---"
dpkg -l | awk '/^rc/ { print $2 }' | xargs -r apt-get purge -yq

# 2. Snap Maintenance
if command -v snap &> /dev/null; then
    echo "--- Updating Snaps ---"
    snap refresh
    echo "--- Removing Old Snap Revisions ---"
    LANG=C snap list --all | awk '/disabled/{print $1, $3}' | while read snapname revision; do
        snap remove "$snapname" --revision="$revision"
    done
fi

# 3. System Logs & Crashes
echo "--- Cleaning Journalctl Logs (keeping last 3 days) ---"
journalctl --vacuum-time=3d
echo "--- Cleaning Crash Reports ---"
rm -rf /var/crash/*

# 4. User-Level Maintenance
if [ ! -z "$REAL_USER" ]; then
    echo "--- Executing User-Level Maintenance for '$REAL_USER' ---"
    
    su - "$REAL_USER" -c "
    # Setup PATH for common dev tools
    export PATH=\"\$HOME/.npm-global/bin:\$HOME/.local/bin:\$PATH\"

    # NPM Update
    if command -v npm &> /dev/null; then
        echo \"--- Updating Global NPM Packages ---\"
        npm update -g || echo \"Warning: NPM update failed\"
    fi

    # UV Update
    if command -v uv &> /dev/null; then
        echo \"--- Updating UV & Tools ---\"
        uv self update &> /dev/null
        uv tool upgrade --all || echo \"Warning: UV tools update failed\"
    fi

    # Browser Caches
    echo \"--- Cleaning Browser Caches ---\"
    [ -d \"\$HOME/.cache/google-chrome/Default/Cache\" ] && rm -rf \"\$HOME/.cache/google-chrome/Default/Cache/*\" && echo \"Chrome cache cleaned.\"
    [ -d \"\$HOME/.cache/BraveSoftware/Brave-Browser/Default/Cache\" ] && rm -rf \"\$HOME/.cache/BraveSoftware/Brave-Browser/Default/Cache/*\" && echo \"Brave cache cleaned.\"

    # Thumbnails
    echo \"--- Cleaning Thumbnail Cache ---\"
    rm -rf \"\$HOME/.cache/thumbnails/*\"
    "
fi

echo "========================================"
echo "Maintenance completed: $(date)"
echo "Log saved at: $LOG_FILE"
echo "========================================"
