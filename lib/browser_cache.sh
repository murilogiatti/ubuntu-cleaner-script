#!/usr/bin/env bash

# browser_cache.sh – Clean Chromium-based and Firefox volatile caches for a given user.
# SAFETY GUARANTEE: This module ONLY targets volatile network and shader caches under ~/.cache/.
# It NEVER touches user profile data such as History, Cookies, Bookmarks, Passwords, or Sessions (which reside under ~/.config/ and ~/.mozilla/).

clean_browser_cache() {
    local user_home="$1"
    declare -gA MSG 2>/dev/null || true

    local chrome_msg="Chrome cache cleaned."
    local brave_msg="Brave cache cleaned."
    local edge_msg="Edge cache cleaned."
    local firefox_msg="Firefox cache cleaned."

    if [[ -v MSG[chrome] ]]; then chrome_msg="${MSG[chrome]}"; fi
    if [[ -v MSG[brave] ]]; then brave_msg="${MSG[brave]}"; fi
    if [[ -v MSG[edge] ]]; then edge_msg="${MSG[edge]}"; fi
    if [[ -v MSG[firefox] ]]; then firefox_msg="${MSG[firefox]}"; fi

    # Strictly volatile HTTP/Shader cache directories under ~/.cache/
    local chromium_subdirs=(
        "Cache"
        "Code Cache"
        "GPUCache"
        "DawnWebGPUCache"
        "DawnGraphiteCache"
        "component_crx_cache"
    )

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
        if [[ "$found" == true ]]; then
            return 0
        else
            return 1
        fi
    }

    # Google Chrome (~/.cache/google-chrome)
    if _clean_chromium_dir "$user_home/.cache/google-chrome"; then
        echo "$chrome_msg"
    fi

    # Brave Browser (~/.cache/BraveSoftware/Brave-Browser)
    if _clean_chromium_dir "$user_home/.cache/BraveSoftware/Brave-Browser"; then
        echo "$brave_msg"
    fi

    # Microsoft Edge (~/.cache/microsoft-edge)
    if _clean_chromium_dir "$user_home/.cache/microsoft-edge"; then
        echo "$edge_msg"
    fi

    # Chromium (~/.cache/chromium)
    _clean_chromium_dir "$user_home/.cache/chromium" || true

    # Mozilla Firefox / LibreWolf (Strictly ~/.cache/mozilla/firefox, NEVER ~/.mozilla)
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
    if [[ "$ff_found" == true ]]; then
        echo "$firefox_msg"
    fi
}
