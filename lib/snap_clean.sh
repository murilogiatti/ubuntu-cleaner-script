#!/usr/bin/env bash

# snap_clean.sh – Snap maintenance functions for UCM

snap_maintenance() {
    if ! command -v snap &>/dev/null; then
        return 0
    fi
    echo "${MSG[snap_up]}"
    run_cmd snap refresh

    echo "${MSG[snap_cln]}"
    LANG=C snap list --all | awk '/disabled/{print $1, $3}' | while read -r snapname revision; do
        run_cmd snap remove "$snapname" --revision="$revision"
    done
}
