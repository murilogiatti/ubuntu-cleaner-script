#!/usr/bin/env bash

# log_vacuum.sh – System log and crash cleanup for UCM

log_vacuum() {
    echo "${MSG[logs]}"
    run_cmd journalctl --vacuum-time=3d

    echo "${MSG[crash]}"
    run_cmd find /var/crash -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
}
