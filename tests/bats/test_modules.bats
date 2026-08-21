#!/usr/bin/env bats

setup() {
    export TMP_SANDBOX
    TMP_SANDBOX=$(mktemp -d /tmp/ucm_bats_XXXXXX)
    mkdir -p "$TMP_SANDBOX/.cache/google-chrome/Default/Cache"
    mkdir -p "$TMP_SANDBOX/.cache/google-chrome/Default/Code Cache"
    mkdir -p "$TMP_SANDBOX/.cache/uv"
    mkdir -p "$TMP_SANDBOX/.cache/mesa_shader_cache"
    mkdir -p "$TMP_SANDBOX/.cache/thumbnails"
    mkdir -p "$TMP_SANDBOX/.local/share/Trash/files"

    touch "$TMP_SANDBOX/.cache/google-chrome/Default/Cache/item1"
    touch "$TMP_SANDBOX/.cache/google-chrome/Default/Code Cache/item2"
    touch "$TMP_SANDBOX/.cache/uv/item3"
    touch "$TMP_SANDBOX/.cache/mesa_shader_cache/item4"
    touch "$TMP_SANDBOX/.cache/thumbnails/item5"
    touch "$TMP_SANDBOX/.local/share/Trash/files/item6"
}

teardown() {
    rm -rf "$TMP_SANDBOX"
}

@test "clean_browser_cache cleans deep chromium cache" {
    run bash -c "source ../../lib/common.sh; source ../../lib/browser_cache.sh; DRY_RUN=false; clean_browser_cache '$TMP_SANDBOX'"
    [ "$status" -eq 0 ]
    [ ! -f "$TMP_SANDBOX/.cache/google-chrome/Default/Cache/item1" ]
    [ ! -f "$TMP_SANDBOX/.cache/google-chrome/Default/Code Cache/item2" ]
}

@test "clean_dev_cache cleans uv and developer caches" {
    run bash -c "source ../../lib/common.sh; source ../../lib/dev_clean.sh; DRY_RUN=false; clean_dev_cache '$TMP_SANDBOX'"
    [ "$status" -eq 0 ]
    [ ! -f "$TMP_SANDBOX/.cache/uv/item3" ]
}

@test "clean_gpu_cache cleans mesa shader cache" {
    run bash -c "source ../../lib/common.sh; source ../../lib/gpu_cache.sh; DRY_RUN=false; clean_gpu_cache '$TMP_SANDBOX'"
    [ "$status" -eq 0 ]
    [ ! -f "$TMP_SANDBOX/.cache/mesa_shader_cache/item4" ]
}

@test "clean_thumbnail cleans thumbnails directory" {
    run bash -c "source ../../lib/common.sh; source ../../lib/thumbnail.sh; DRY_RUN=false; clean_thumbnail '$TMP_SANDBOX'"
    [ "$status" -eq 0 ]
    [ ! -f "$TMP_SANDBOX/.cache/thumbnails/item5" ]
}

@test "clean_user_trash cleans trash files" {
    run bash -c "source ../../lib/common.sh; source ../../lib/system_extra.sh; DRY_RUN=false; clean_user_trash '$TMP_SANDBOX'"
    [ "$status" -eq 0 ]
    [ ! -f "$TMP_SANDBOX/.local/share/Trash/files/item6" ]
}

@test "clean_browser_cache NEVER removes history or cookies" {
    mkdir -p "$TMP_SANDBOX/.config/google-chrome/Default/Network"
    mkdir -p "$TMP_SANDBOX/.mozilla/firefox/test.default"
    touch "$TMP_SANDBOX/.config/google-chrome/Default/History"
    touch "$TMP_SANDBOX/.config/google-chrome/Default/Network/Cookies"
    touch "$TMP_SANDBOX/.mozilla/firefox/test.default/places.sqlite"
    touch "$TMP_SANDBOX/.mozilla/firefox/test.default/cookies.sqlite"

    run bash -c "source ../../lib/common.sh; source ../../lib/browser_cache.sh; DRY_RUN=false; clean_browser_cache '$TMP_SANDBOX'"
    [ "$status" -eq 0 ]
    [ -f "$TMP_SANDBOX/.config/google-chrome/Default/History" ]
    [ -f "$TMP_SANDBOX/.config/google-chrome/Default/Network/Cookies" ]
    [ -f "$TMP_SANDBOX/.mozilla/firefox/test.default/places.sqlite" ]
    [ -f "$TMP_SANDBOX/.mozilla/firefox/test.default/cookies.sqlite" ]
}
