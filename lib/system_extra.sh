#!/usr/bin/env bash

# system_extra.sh – Clean user trash and manage Flatpak packages

clean_user_trash() {
    local user_home="$1"
    declare -gA MSG 2>/dev/null || true

    local trash_msg="--- Emptying User Trash ---"
    if [[ -v MSG[trash] ]]; then trash_msg="${MSG[trash]}"; fi

    local trash_dir="$user_home/.local/share/Trash"
    if [[ -d "$trash_dir" ]]; then
        echo "$trash_msg"
        if [[ -d "$trash_dir/files" || -d "$trash_dir/info" || -d "$trash_dir/expunged" ]]; then
            if [[ -d "$trash_dir/files" ]]; then
                run_cmd find "$trash_dir/files" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
            fi
            if [[ -d "$trash_dir/info" ]]; then
                run_cmd find "$trash_dir/info" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
            fi
            if [[ -d "$trash_dir/expunged" ]]; then
                run_cmd find "$trash_dir/expunged" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
            fi
        else
            run_cmd find "$trash_dir" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
        fi
    fi
}

flatpak_maintenance() {
    if ! command -v flatpak &>/dev/null; then
        return 0
    fi
    declare -gA MSG 2>/dev/null || true

    local flatpak_up="--- Updating Flatpak Packages ---"
    local flatpak_cln="--- Removing Unused Flatpak Runtimes ---"
    if [[ -v MSG[flatpak_up] ]]; then flatpak_up="${MSG[flatpak_up]}"; fi
    if [[ -v MSG[flatpak_cln] ]]; then flatpak_cln="${MSG[flatpak_cln]}"; fi

    echo "$flatpak_up"
    run_cmd flatpak update -y --noninteractive 2>/dev/null || true

    echo "$flatpak_cln"
    run_cmd flatpak uninstall --unused -y --noninteractive 2>/dev/null || true
}
