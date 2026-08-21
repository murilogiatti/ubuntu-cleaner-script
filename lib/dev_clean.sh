#!/usr/bin/env bash

# dev_clean.sh – Clean developer tools caches (UV, Pip, NPM, Yarn, Bun, VS Code, Docker)

clean_dev_cache() {
    local user_home="$1"
    local dev_msg="--- Cleaning Developer Caches ---"
    local docker_msg="--- Cleaning Docker unused objects ---"
    if [[ -n "${MSG[dev_clean]+set}" ]]; then dev_msg="${MSG[dev_clean]}"; fi
    if [[ -n "${MSG[docker_clean]+set}" ]]; then docker_msg="${MSG[docker_clean]}"; fi

    echo "$dev_msg"

    # 1. Python UV Cache
    if command -v uv &>/dev/null; then
        run_cmd uv cache clean &>/dev/null || true
    elif [[ -d "$user_home/.cache/uv" ]]; then
        run_cmd find "$user_home/.cache/uv" -mindepth 1 -exec rm -rf -- {} +
    fi

    # 2. Python Pip Cache
    if command -v pip &>/dev/null; then
        run_cmd pip cache purge &>/dev/null || true
    elif [[ -d "$user_home/.cache/pip" ]]; then
        run_cmd find "$user_home/.cache/pip" -mindepth 1 -exec rm -rf -- {} +
    fi

    # 3. Node / NPM / Yarn / Bun / PNPM caches
    if command -v npm &>/dev/null; then
        run_cmd npm cache clean --force &>/dev/null || true
    fi
    if [[ -d "$user_home/.npm/_cacache" ]]; then
        run_cmd find "$user_home/.npm/_cacache" -mindepth 1 -exec rm -rf -- {} +
    fi
    if [[ -d "$user_home/.cache/yarn" ]]; then
        run_cmd find "$user_home/.cache/yarn" -mindepth 1 -exec rm -rf -- {} +
    fi
    if [[ -d "$user_home/.bun/install/cache" ]]; then
        run_cmd find "$user_home/.bun/install/cache" -mindepth 1 -exec rm -rf -- {} +
    fi

    # 4. VS Code / VSCodium Caches
    for vscode_dir in "$user_home/.config/Code" "$user_home/.config/VSCodium"; do
        if [[ -d "$vscode_dir/Cache" ]]; then
            run_cmd find "$vscode_dir/Cache" -mindepth 1 -exec rm -rf -- {} +
        fi
        if [[ -d "$vscode_dir/CachedData" ]]; then
            run_cmd find "$vscode_dir/CachedData" -mindepth 1 -exec rm -rf -- {} +
        fi
    done
    if [[ -d "$user_home/.cache/vscode-ripgrep" ]]; then
        run_cmd find "$user_home/.cache/vscode-ripgrep" -mindepth 1 -exec rm -rf -- {} +
    fi

    # 5. Docker Prune (if docker is active)
    if command -v docker &>/dev/null && docker info &>/dev/null; then
        echo "$docker_msg"
        run_cmd docker system prune -f
    fi
}
