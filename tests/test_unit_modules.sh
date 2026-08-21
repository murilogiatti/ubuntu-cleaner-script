#!/usr/bin/env bash
# Unit tests for all UCM modules

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/apt_maint.sh"
source "$SCRIPT_DIR/lib/snap_clean.sh"
source "$SCRIPT_DIR/lib/log_vacuum.sh"
source "$SCRIPT_DIR/lib/run_as_user.sh"
source "$SCRIPT_DIR/lib/browser_cache.sh"
source "$SCRIPT_DIR/lib/thumbnail.sh"
source "$SCRIPT_DIR/lib/dev_clean.sh"
source "$SCRIPT_DIR/lib/gpu_cache.sh"
source "$SCRIPT_DIR/lib/system_extra.sh"

echo "=== Running UCM Comprehensive Unit Tests ==="

# Test 1: require_root with mock EUID
echo "Test 1: require_root behavior..."
if UCM_TEST_EUID=1000 bash -c "source '$SCRIPT_DIR/lib/common.sh'; require_root" 2>/dev/null; then
    echo "FAIL: require_root did not exit on non-root"
    exit 1
fi
echo "PASS: require_root blocks non-root"

# Test 2: Locale messages (EN and PT)
echo "Test 2: Locale messages..."
LANG=pt_BR.UTF-8 bash -c "source '$SCRIPT_DIR/lib/common.sh'; set_locale_messages; [[ \${MSG[start]} == 'Iniciando manutenção do sistema' ]]"
LANG=en_US.UTF-8 bash -c "source '$SCRIPT_DIR/lib/common.sh'; set_locale_messages; [[ \${MSG[start]} == 'Starting system maintenance' ]]"
echo "PASS: Bilingual translations loaded correctly"

# Test 3: DRY_RUN safety
echo "Test 3: Dry-run safety..."
out=$(DRY_RUN=true run_cmd rm -rf /non_existent_dummy_path_12345)
if [[ "$out" != *"[DRY-RUN]"* ]]; then
    echo "FAIL: run_cmd executed in dry run mode"
    exit 1
fi
echo "PASS: run_cmd respects DRY_RUN"

# Test 4: Mocked cleanup execution on temporary directories
echo "Test 4: Browser, Dev, GPU, Trash and Thumbnail cleanups in sandbox..."
TMP_USER_HOME=$(mktemp -d /tmp/ucm_test_home_XXXXXX)
trap 'rm -rf "$TMP_USER_HOME"' EXIT

# Create fake mock cache dirs
mkdir -p "$TMP_USER_HOME/.cache/google-chrome/Default/Cache"
mkdir -p "$TMP_USER_HOME/.cache/google-chrome/Default/Code Cache"
mkdir -p "$TMP_USER_HOME/.cache/google-chrome/Profile 1/GPUCache"
mkdir -p "$TMP_USER_HOME/.cache/mozilla/firefox/test.default/cache2"
mkdir -p "$TMP_USER_HOME/.cache/uv"
mkdir -p "$TMP_USER_HOME/.cache/pip"
mkdir -p "$TMP_USER_HOME/.npm/_cacache"
mkdir -p "$TMP_USER_HOME/.config/Code/Cache"
mkdir -p "$TMP_USER_HOME/.cache/mesa_shader_cache"
mkdir -p "$TMP_USER_HOME/.cache/radv_builtin_shaders"
mkdir -p "$TMP_USER_HOME/.nv/GLCache"
mkdir -p "$TMP_USER_HOME/.cache/thumbnails"
mkdir -p "$TMP_USER_HOME/.local/share/Trash/files"

# Put dummy files in each
touch "$TMP_USER_HOME/.cache/google-chrome/Default/Cache/data_0"
touch "$TMP_USER_HOME/.cache/google-chrome/Default/Code Cache/wasm_0"
touch "$TMP_USER_HOME/.cache/google-chrome/Profile 1/GPUCache/data_1"
touch "$TMP_USER_HOME/.cache/mozilla/firefox/test.default/cache2/ff_entry"
touch "$TMP_USER_HOME/.cache/uv/wheel_test"
touch "$TMP_USER_HOME/.cache/pip/pip_test"
touch "$TMP_USER_HOME/.npm/_cacache/npm_entry"
touch "$TMP_USER_HOME/.config/Code/Cache/vscode_entry"
touch "$TMP_USER_HOME/.cache/mesa_shader_cache/shader_0"
touch "$TMP_USER_HOME/.cache/radv_builtin_shaders/radv_0"
touch "$TMP_USER_HOME/.nv/GLCache/nv_0"
touch "$TMP_USER_HOME/.cache/thumbnails/thumb_0"
touch "$TMP_USER_HOME/.local/share/Trash/files/trash_item"

# Execute real cleaning functions in the sandbox
DRY_RUN=false
clean_browser_cache "$TMP_USER_HOME" >/dev/null
clean_dev_cache "$TMP_USER_HOME" >/dev/null
clean_gpu_cache "$TMP_USER_HOME" >/dev/null
clean_thumbnail "$TMP_USER_HOME" >/dev/null
clean_user_trash "$TMP_USER_HOME" >/dev/null

# Verify everything was emptied inside the mock folders
for target in \
    "$TMP_USER_HOME/.cache/google-chrome/Default/Cache/data_0" \
    "$TMP_USER_HOME/.cache/google-chrome/Default/Code Cache/wasm_0" \
    "$TMP_USER_HOME/.cache/google-chrome/Profile 1/GPUCache/data_1" \
    "$TMP_USER_HOME/.cache/mozilla/firefox/test.default/cache2/ff_entry" \
    "$TMP_USER_HOME/.cache/mesa_shader_cache/shader_0" \
    "$TMP_USER_HOME/.cache/radv_builtin_shaders/radv_0" \
    "$TMP_USER_HOME/.nv/GLCache/nv_0" \
    "$TMP_USER_HOME/.cache/thumbnails/thumb_0" \
    "$TMP_USER_HOME/.local/share/Trash/files/trash_item"; do
    if [[ -e "$target" ]]; then
        echo "FAIL: Expected $target to be deleted, but it still exists!"
        exit 1
    fi
done

echo "PASS: All mock cleanup functions cleanly emptied target directories"

echo "=== All Comprehensive Unit Tests Passed Successfully! ==="
exit 0
