#!/usr/bin/env bash

# system_extra.sh – Clean user trash and manage Flatpak packages

clean_user_trash() {
    local user_home="$1"
    local trash_msg="--- Emptying User Trash ---"
    if [[ -n "${MSG[trash]+set}" ]]; then trash_msg="${MSG[trash]}"; fi

    local trash_dir="$user_home/.local/share/Trash"
    if [[ -d "$trash_dir" ]]; then
        echo "$trash_msg"
        run_cmd find "$trash_dir" -mindepth 1 -exec rm -rf -- {} +
    fi
}

flatpak_maintenance() {
    if ! command -v flatpak &>/dev/null; then
        return 0
    fi
    local flatpak_up="--- Updating Flatpak Packages ---"
    local flatpak_cln="--- Removing Unused Flatpak Runtimes ---"
    if [[ -n "${MSG[flatpak_up]+set}" ]]; then flatpak_up="${MSG[flatpak_up]}"; fi
    if [[ -n "${MSG[flatpak_cln]+set}" ]]; then flatpak_cln="${MSG[flatpak_cln]}"; fi

    echo "$flatpak_up"
    run_cmd flatpak update -y --noninteractive 2>/dev/null || true

    echo "$flatpak_cln"
    run_cmd flatpak uninstall --unused -y --noninteractive 2>/dev/null || true
}
