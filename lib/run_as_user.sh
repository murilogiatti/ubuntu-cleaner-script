#!/usr/bin/env bash

# run_as_user.sh – Helper to execute a block of commands as a given non‑root user.

run_as_user() {
    local username="$1"
    shift
    local commands="$*"
    if [[ "$EUID" -ne 0 ]]; then
        bash -c "$commands"
        return $?
    fi
    su - "$username" -s /bin/bash -c "$commands"
}
