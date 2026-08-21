#!/usr/bin/env bash

# thumbnail.sh – Clean thumbnail cache for a given user.

clean_thumbnail() {
    local user_home="$1"
    local thumb_msg="--- Cleaning Thumbnail Cache ---"
    if [[ -n "${MSG[thumb]+set}" ]]; then
        thumb_msg="${MSG[thumb]}"
    fi
    local thumb_dir="$user_home/.cache/thumbnails"
    if [[ -d "$thumb_dir" ]]; then
        run_cmd find "$thumb_dir" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
        echo "$thumb_msg"
    fi
}
