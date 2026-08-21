#!/usr/bin/env bash

# gpu_cache.sh – Clean GPU shader caches (Mesa, AMD/RADV, NVIDIA)

clean_gpu_cache() {
    local user_home="$1"
    local gpu_msg="--- Cleaning GPU Shader Caches ---"
    if [[ -n "${MSG[gpu_clean]+set}" ]]; then gpu_msg="${MSG[gpu_clean]}"; fi

    echo "$gpu_msg"

    # Mesa / OpenGL shader cache
    local mesa_cache="$user_home/.cache/mesa_shader_cache"
    if [[ -d "$mesa_cache" ]]; then
        run_cmd find "$mesa_cache" -mindepth 1 -exec rm -rf -- {} +
    fi

    # AMD / RADV Vulkan shader cache
    local radv_cache="$user_home/.cache/radv_builtin_shaders"
    if [[ -d "$radv_cache" ]]; then
        run_cmd find "$radv_cache" -mindepth 1 -exec rm -rf -- {} +
    fi

    # NVIDIA shader caches
    local nv_gl="$user_home/.nv/GLCache"
    if [[ -d "$nv_gl" ]]; then
        run_cmd find "$nv_gl" -mindepth 1 -exec rm -rf -- {} +
    fi
    local nv_cache="$user_home/.cache/nvidia"
    if [[ -d "$nv_cache" ]]; then
        run_cmd find "$nv_cache" -mindepth 1 -exec rm -rf -- {} +
    fi
}
