#!/usr/bin/env bats

@test "require_root exits when not root" {
    run bash -c 'UCM_TEST_EUID=1000 source ../../lib/common.sh; require_root'
    [ "$status" -eq 1 ]
    [[ "$output" == *"must be run as root"* ]]
}

@test "confirm_action auto-confirms with ASSUME_YES" {
    run bash -c 'source ../../lib/common.sh; DRY_RUN=false; ASSUME_YES=true; confirm_action "Proceed?"'
    [ "$status" -eq 0 ]
    [[ "$output" == *"Proceed? yes"* ]]
}

@test "run_cmd does not execute commands during dry-run" {
    run bash -c 'source ../../lib/common.sh; DRY_RUN=true; run_cmd false'
    [ "$status" -eq 0 ]
    [[ "$output" == *"[DRY-RUN]"* ]]
}

@test "set_locale_messages sets MSG array for en" {
    LANG=en_US.UTF-8 bash -c 'source ../../lib/common.sh; set_locale_messages; [[ ${MSG[start]} == "Starting system maintenance" ]]'
}

@test "set_locale_messages sets MSG array for pt" {
    LANG=pt_BR.UTF-8 bash -c 'source ../../lib/common.sh; set_locale_messages; [[ ${MSG[start]} == "Iniciando manutenção do sistema" ]]'
}
