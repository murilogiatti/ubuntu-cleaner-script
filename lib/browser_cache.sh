#!/usr/bin/env bash

# browser_cache.sh – Clean Chromium-based and Firefox caches for a given user.

clean_browser_cache() {
    local user_home="$1"
    local chrome_msg="Chrome cache cleaned."
    local brave_msg="Brave cache cleaned."
    local edge_msg="Edge cache cleaned."
    local firefox_msg="Firefox cache cleaned."
    
    if [[ -n "${MSG[chrome]+set}" ]]; then chrome_msg="${MSG[chrome]}"; fi
    if [[ -n "${MSG[brave]+set}" ]]; then brave_msg="${MSG[brave]}"; fi
    if [[ -n "${MSG[edge]+set}" ]]; then edge_msg="${MSG[edge]}"; fi
    if [[ -n "${MSG[firefox]+set}" ]]; then firefox_msg="${MSG[firefox]}"; fi

    local chromium_subdirs=(
        "Cache"
        "Code Cache"
        "GPUCache"
        "DawnWebGPUCache"
        "DawnGraphiteCache"
        "Service Worker/CacheStorage"
        "component_crx_cache"
    )

    # Helper function to clean chromium profiles
    _clean_chromium_dir() {
        local base_dir="$1"
        local found=false
        if [[ -d "$base_dir" ]]; then
            for profile in "$base_dir"/*; do
                if [[ -d "$profile" ]]; then
                    for subdir in "${chromium_subdirs[@]}"; do
                        local target="$profile/$subdir"
                        if [[ -d "$target" ]]; then
                            found=true
                            run_cmd find "$target" -mindepth 1 -exec rm -rf -- {} +
                        fi
                    done
                fi
            done
        fi
        [[ "$found" == true ]] && return 0 || return 1
    }

    # Google Chrome
    if _clean_chromium_dir "$user_home/.cache/google-chrome"; then
        echo "$chrome_msg"
    fi

    # Brave Browser
    if _clean_chromium_dir "$user_home/.cache/BraveSoftware/Brave-Browser"; then
        echo "$brave_msg"
    fi

    # Microsoft Edge
    if _clean_chromium_dir "$user_home/.cache/microsoft-edge"; then
        echo "$edge_msg"
    fi

    # Chromium
    _clean_chromium_dir "$user_home/.cache/chromium" || true

    # Mozilla Firefox / LibreWolf
    local ff_found=false
    for ff_base in "$user_home/.cache/mozilla/firefox" "$user_home/.cache/librewolf"; do
        if [[ -d "$ff_base" ]]; then
            for prof in "$ff_base"/*; do
                if [[ -d "$prof/cache2" ]]; then
                    ff_found=true
                    run_cmd find "$prof/cache2" -mindepth 1 -exec rm -rf -- {} +
                fi
                if [[ -d "$prof/startupCache" ]]; then
                    ff_found=true
                    run_cmd find "$prof/startupCache" -mindepth 1 -exec rm -rf -- {} +
                fi
            done
        fi
    done
    [[ "$ff_found" == true ]] && echo "$firefox_msg"
}
