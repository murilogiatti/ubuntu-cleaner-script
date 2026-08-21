#!/usr/bin/env bash

# Common utilities for Ubuntu Cleaner & Maintainer (UCM)

# Script version – keep in sync with README
UCM_VERSION="1.4.0"

# Default installation paths. Keep the full project together so ucm.sh can
# source lib/*.sh and the report template after installation.
UCM_LIB_DIR="${UCM_LIB_DIR:-/usr/local/lib/ucm}"
UCM_BIN="${UCM_BIN:-/usr/local/sbin/ucm.sh}"
UCM_CRON="${UCM_CRON:-/etc/cron.weekly/ucm}"
UCM_LOGROTATE="${UCM_LOGROTATE:-/etc/logrotate.d/ucm}"

# ---------------------------------------------------------------------------
# require_root: ensure script runs with root privileges.
# Prints bilingual message and exits with status 1 if not root.
# ---------------------------------------------------------------------------
require_root() {
    local current_euid="${UCM_TEST_EUID:-$EUID}"
    if [[ "$current_euid" -ne 0 ]]; then
        echo "This script must be run as root / Este script deve ser executado como root"
        exit 1
    fi
}

# ---------------------------------------------------------------------------
# set_locale_messages: populate associative array MSG[] with bilingual strings.
# Simple implementation – only en and pt for the messages used in the main script.
# ---------------------------------------------------------------------------
set_locale_messages() {
    declare -gA MSG
    local lang_code=$(echo "$LANG" | cut -d'_' -f1)
    if [[ "$lang_code" == "pt" ]]; then
        MSG[start]="Iniciando manutenção do sistema"
        MSG[user]="Usuário alvo"
        MSG[apt_up]="--- Atualizando pacotes APT ---"
        MSG[apt_cln]="--- Limpando caches e órfãos APT ---"
        MSG[rc]="--- Purgando configurações residuais (status rc) ---"
        MSG[snap_up]="--- Atualizando Snaps ---"
        MSG[snap_cln]="--- Removendo revisões antigas do Snap ---"
        MSG[flatpak_up]="--- Atualizando pacotes Flatpak ---"
        MSG[flatpak_cln]="--- Removendo runtimes Flatpak órfãos ---"
        MSG[logs]="--- Limpando logs do Journalctl (mantendo 3 dias) ---"
        MSG[crash]="--- Limpando relatórios de erro (crash) ---"
        MSG[user_lvl]="--- Executando manutenção de nível de usuário para"
        MSG[npm]="--- Atualizando pacotes NPM globais ---"
        MSG[uv]="--- Atualizando UV e ferramentas ---"
        MSG[browser]="--- Limpando caches de navegadores ---"
        MSG[chrome]="Cache do Chrome limpo."
        MSG[brave]="Cache do Brave limpo."
        MSG[edge]="Cache do Edge limpo."
        MSG[firefox]="Cache do Firefox limpo."
        MSG[dev_clean]="--- Limpando caches de desenvolvimento (UV, Pip, Node, VS Code) ---"
        MSG[docker_clean]="--- Limpando objetos não utilizados do Docker ---"
        MSG[gpu_clean]="--- Limpando caches de Shaders de GPU (Mesa, RADV, NVIDIA) ---"
        MSG[thumb]="--- Limpando cache de miniaturas ---"
        MSG[trash]="--- Esvaziando lixeira do usuário ---"
        MSG[end]="Manutenção concluída"
        MSG[log_save]="Log salvo em"
    else
        MSG[start]="Starting system maintenance"
        MSG[user]="Targeting User"
        MSG[apt_up]="--- Updating APT Packages ---"
        MSG[apt_cln]="--- Cleaning APT Caches & Orphans ---"
        MSG[rc]="--- Purging Residual Configs (rc status) ---"
        MSG[snap_up]="--- Updating Snaps ---"
        MSG[snap_cln]="--- Removing Old Snap Revisions ---"
        MSG[flatpak_up]="--- Updating Flatpak Packages ---"
        MSG[flatpak_cln]="--- Removing Unused Flatpak Runtimes ---"
        MSG[logs]="--- Cleaning Journalctl Logs (keeping 3 days) ---"
        MSG[crash]="--- Cleaning Crash Reports ---"
        MSG[user_lvl]="--- Executing User-Level Maintenance for"
        MSG[npm]="--- Updating Global NPM Packages ---"
        MSG[uv]="--- Updating UV & Tools ---"
        MSG[browser]="--- Cleaning Browser Caches ---"
        MSG[chrome]="Chrome cache cleaned."
        MSG[brave]="Brave cache cleaned."
        MSG[edge]="Edge cache cleaned."
        MSG[firefox]="Firefox cache cleaned."
        MSG[dev_clean]="--- Cleaning Developer Caches (UV, Pip, Node, VS Code) ---"
        MSG[docker_clean]="--- Cleaning Docker unused objects ---"
        MSG[gpu_clean]="--- Cleaning GPU Shader Caches (Mesa, RADV, NVIDIA) ---"
        MSG[thumb]="--- Cleaning Thumbnail Cache ---"
        MSG[trash]="--- Emptying User Trash ---"
        MSG[end]="Maintenance completed"
        MSG[log_save]="Log saved at"
    fi
}

# ---------------------------------------------------------------------------
# tee_to_log: redirect stdout/stderr to a log file while still printing to console.
# If LOG_FILE is not set, defaults to /var/log/ucm_maintenance.log.
# ---------------------------------------------------------------------------
tee_to_log() {
    LOG_FILE="${LOG_FILE:-/var/log/ucm_maintenance.log}"
    mkdir -p "$(dirname "$LOG_FILE")"
    exec > >(tee -a "$LOG_FILE")
    exec 2>&1
}

# ---------------------------------------------------------------------------
# run_cmd: execute a command, or only print it when DRY_RUN=true.
# ---------------------------------------------------------------------------
run_cmd() {
    if [[ "${DRY_RUN:-false}" == true ]]; then
        printf '[DRY-RUN] '
        printf '%q ' "$@"
        printf '\n'
        return 0
    fi
    "$@"
}

# ---------------------------------------------------------------------------
# run_shell: execute a shell snippet, or only print it when DRY_RUN=true.
# ---------------------------------------------------------------------------
run_shell() {
    local command="$1"
    if [[ "${DRY_RUN:-false}" == true ]]; then
        echo "[DRY-RUN] bash -c $command"
        return 0
    fi
    bash -c "$command"
}

ucm_chown_root() {
    if [[ -n "${UCM_TEST_EUID:-}" ]]; then
        return 0
    fi
    chown "$@"
}

# ---------------------------------------------------------------------------
# install_ucm: copy the main script to the weekly cron directory.
# Parameters: $1 = source script path, $2 = destination (default /etc/cron.weekly/ucm).
# ---------------------------------------------------------------------------
install_ucm() {
    local src="$1"
    local cron_dest="${2:-$UCM_CRON}"
    local project_dir
    project_dir="$(cd "$(dirname "$src")" && pwd)"

    echo "Installing UCM application to $UCM_LIB_DIR..."
    install -d -m 755 "$UCM_LIB_DIR/lib" "$(dirname "$UCM_BIN")" "$(dirname "$cron_dest")" "$(dirname "$UCM_LOGROTATE")"
    install -m 755 "$project_dir/ucm.sh" "$UCM_LIB_DIR/ucm.sh"
    install -m 644 "$project_dir/report_template.html" "$UCM_LIB_DIR/report_template.html"
    install -m 644 "$project_dir"/lib/*.sh "$UCM_LIB_DIR/lib/"
    if [[ -f "$project_dir/logrotate_ucm" ]]; then
        install -m 644 "$project_dir/logrotate_ucm" "$UCM_LOGROTATE"
        ucm_chown_root root:root "$UCM_LOGROTATE"
    fi
    ucm_chown_root -R root:root "$UCM_LIB_DIR"

    cat > "$UCM_BIN" <<EOF
#!/usr/bin/env bash
exec "$UCM_LIB_DIR/ucm.sh" "\$@"
EOF
    ucm_chown_root root:root "$UCM_BIN"
    chmod 755 "$UCM_BIN"

    cat > "$cron_dest" <<EOF
#!/usr/bin/env bash
exec "$UCM_BIN" --yes --log /var/log/ucm_maintenance.log
EOF
    ucm_chown_root root:root "$cron_dest"
    chmod 755 "$cron_dest"
    echo "Installation complete! The script will run automatically every week."
}

# ---------------------------------------------------------------------------
# uninstall_ucm: remove the installed script and associated log file.
# ---------------------------------------------------------------------------
uninstall_ucm() {
    local dest="${1:-$UCM_CRON}"
    echo "Uninstalling UCM..."
    rm -f "$dest"
    rm -f "$UCM_BIN"
    rm -f "$UCM_LOGROTATE"
    if [[ -n "$UCM_LIB_DIR" && "$UCM_LIB_DIR" != "/" ]]; then
        rm -rf "$UCM_LIB_DIR"
    fi
    rm -f "${LOG_FILE:-/var/log/ucm_maintenance.log}" 2>/dev/null || true
    # Remove any legacy scripts that might still exist
    rm -f "/etc/cron.weekly/manutencao-semanal" 2>/dev/null || true
    echo "Uninstallation complete. Logs and cron script removed."
}

# ---------------------------------------------------------------------------
# confirm_action: prompt the user for confirmation unless in dry‑run mode.
# Returns 0 if user confirms or dry‑run; 1 otherwise.
# ---------------------------------------------------------------------------
confirm_action() {
    local prompt_msg="$1"
    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY-RUN] $prompt_msg"
        return 0
    fi
    if [[ "${ASSUME_YES:-false}" == true ]]; then
        echo "$prompt_msg yes"
        return 0
    fi
    read -rp "$prompt_msg (y/N): " answer
    [[ "$answer" == "y" || "$answer" == "Y" ]]
}

# Export functions for subscripts that source this file
export -f require_root set_locale_messages tee_to_log run_cmd run_shell ucm_chown_root install_ucm uninstall_ucm confirm_action
