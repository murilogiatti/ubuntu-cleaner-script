#!/bin/bash

# ==============================================================================
# Title:        Ubuntu Cleaner & Maintainer (UCM)
# Description:  A dynamic script to keep Ubuntu systems updated and clean.
# Author:       Murilo Giatti
# License:      MIT
# ==============================================================================

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root / Este script deve ser executado como root"
   exit 1
fi

# Detect system language
LANG_CODE=$(echo $LANG | cut -d'_' -f1)

# Detection for dynamic user
REAL_USER=$(who | awk 'NR==1{print $1}')
if [ -z "$REAL_USER" ]; then
    REAL_USER=$SUDO_USER
fi

LOG_FILE="/var/log/ucm_maintenance.log"
exec > >(tee -a $LOG_FILE)
exec 2>&1

if [ "$LANG_CODE" = "pt" ]; then
    MSG_START="Iniciando manutenção do sistema"
    MSG_USER="Usuário alvo"
    MSG_APT_UP="--- Atualizando pacotes APT ---"
    MSG_APT_CLN="--- Limpando caches e órfãos APT ---"
    MSG_RC="--- Purgando configurações residuais (status rc) ---"
    MSG_SNAP_UP="--- Atualizando Snaps ---"
    MSG_SNAP_CLN="--- Removendo revisões antigas do Snap ---"
    MSG_LOGS="--- Limpando logs do Journalctl (mantendo 3 dias) ---"
    MSG_CRASH="--- Limpando relatórios de erro (crash) ---"
    MSG_USER_LVL="--- Executando manutenção de nível de usuário para"
    MSG_NPM="--- Atualizando pacotes NPM globais ---"
    MSG_UV="--- Atualizando UV e ferramentas ---"
    MSG_BROWSER="--- Limpando caches de navegadores ---"
    MSG_CHROME="Cache do Chrome limpo."
    MSG_BRAVE="Cache do Brave limpo."
    MSG_THUMB="--- Limpando cache de miniaturas ---"
    MSG_END="Manutenção concluída"
    MSG_LOG_SAVE="Log salvo em"
else
    MSG_START="Starting system maintenance"
    MSG_USER="Targeting User"
    MSG_APT_UP="--- Updating APT Packages ---"
    MSG_APT_CLN="--- Cleaning APT Caches & Orphans ---"
    MSG_RC="--- Purging Residual Configs (rc status) ---"
    MSG_SNAP_UP="--- Updating Snaps ---"
    MSG_SNAP_CLN="--- Removing Old Snap Revisions ---"
    MSG_LOGS="--- Cleaning Journalctl Logs (keeping 3 days) ---"
    MSG_CRASH="--- Cleaning Crash Reports ---"
    MSG_USER_LVL="--- Executing User-Level Maintenance for"
    MSG_NPM="--- Updating Global NPM Packages ---"
    MSG_UV="--- Updating UV & Tools ---"
    MSG_BROWSER="--- Cleaning Browser Caches ---"
    MSG_CHROME="Chrome cache cleaned."
    MSG_BRAVE="Brave cache cleaned."
    MSG_THUMB="--- Cleaning Thumbnail Cache ---"
    MSG_END="Maintenance completed"
    MSG_LOG_SAVE="Log saved at"
fi

echo "========================================"
echo "$MSG_START: $(date)"
echo "$MSG_USER: $REAL_USER"
echo "========================================"

# 1. APT Maintenance
echo "$MSG_APT_UP"
export DEBIAN_FRONTEND=noninteractive
apt-get update -q
apt-get upgrade -yq

echo "$MSG_APT_CLN"
apt-get autoremove --purge -yq
apt-get clean -q
apt-get autoclean -q

echo "$MSG_RC"
dpkg -l | awk '/^rc/ { print $2 }' | xargs -r apt-get purge -yq

# 2. Snap Maintenance
if command -v snap &> /dev/null; then
    echo "$MSG_SNAP_UP"
    snap refresh
    echo "$MSG_SNAP_CLN"
    LANG=C snap list --all | awk '/disabled/{print $1, $3}' | while read snapname revision; do
        snap remove "$snapname" --revision="$revision"
    done
fi

# 3. System Logs & Crashes
echo "$MSG_LOGS"
journalctl --vacuum-time=3d
echo "$MSG_CRASH"
rm -rf /var/crash/*

# 4. User-Level Maintenance
if [ -n "$REAL_USER" ]; then
    echo "$MSG_USER_LVL '$REAL_USER' ---"
    
    su - "$REAL_USER" -c "
    export PATH=\"\$HOME/.npm-global/bin:\$HOME/.local/bin:\$PATH\"

    if command -v npm &> /dev/null; then
        echo \"$MSG_NPM\"
        npm update -g
    fi

    if command -v uv &> /dev/null; then
        echo \"$MSG_UV\"
        uv self update &> /dev/null
        uv tool upgrade --all
    fi

    echo \"$MSG_BROWSER\"
    [ -d \"\$HOME/.cache/google-chrome/Default/Cache\" ] && rm -rf \"\$HOME/.cache/google-chrome/Default/Cache/*\" && echo \"$MSG_CHROME\"
    [ -d \"\$HOME/.cache/BraveSoftware/Brave-Browser/Default/Cache\" ] && rm -rf \"\$HOME/.cache/BraveSoftware/Brave-Browser/Default/Cache/*\" && echo \"$MSG_BRAVE\"

    echo \"$MSG_THUMB\"
    rm -rf \"\$HOME/.cache/thumbnails/*\"
    "
fi

echo "========================================"
echo "$MSG_END: $(date)"
echo "$MSG_LOG_SAVE: $LOG_FILE"
echo "========================================"
