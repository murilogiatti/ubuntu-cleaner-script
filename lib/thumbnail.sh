#!/usr/bin/env bash

# thumbnail.sh – Clean thumbnail cache for a given user.

clean_thumbnail() {
    local user_home="$1"
    declare -gA MSG 2>/dev/null || true

    local thumb_msg="--- Cleaning Thumbnail Cache ---"
    if [[ -v MSG[thumb] ]]; then
        thumb_msg="${MSG[thumb]}"
    fi
    local thumb_dir="$user_home/.cache/thumbnails"
    if [[ -d "$thumb_dir" ]]; then
        echo "$thumb_msg"
        run_cmd find "$thumb_dir" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
    fi
}
