#!/usr/bin/env bash

# apt_maint.sh – APT maintenance functions for UCM

apt_maintenance() {
    echo "${MSG[apt_up]}"
    export DEBIAN_FRONTEND=noninteractive
    run_cmd apt-get update -q
    run_cmd apt-get upgrade -yq

    echo "${MSG[apt_cln]}"
    run_cmd apt-get autoremove --purge -yq
    run_cmd apt-get clean -q
    run_cmd apt-get autoclean -q

    echo "${MSG[rc]}"
    run_shell "dpkg -l | awk '/^rc/ { print \$2 }' | xargs -r apt-get purge -yq"
}
