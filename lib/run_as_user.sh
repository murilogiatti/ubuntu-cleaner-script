#!/usr/bin/env bash

# run_as_user.sh – Helper to execute a block of commands as a given non‑root user.

run_as_user() {
    local username="$1"
    shift
    local commands="$*"
    if [[ "${DRY_RUN:-false}" == true ]]; then
        echo "[DRY-RUN] su - $username -c $commands"
        return 0
    fi
    su - "$username" -s /bin/bash -c "$commands"
}
