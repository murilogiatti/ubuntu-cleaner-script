#!/usr/bin/env bats

@test "apt_maintenance runs without error (dry‑run)" {
    # Use a stub for apt-get that just echoes commands
    mkdir -p stub_bin
    printf '%s\n' '#!/usr/bin/env bash' 'echo "apt-get $*"' > stub_bin/apt-get
    chmod +x stub_bin/apt-get
    run bash -c 'PATH="$PWD/stub_bin:$PATH"; source ../../lib/common.sh; source ../../lib/apt_maint.sh; set_locale_messages; DRY_RUN=true; apt_maintenance'
    [ "$status" -eq 0 ]
    [[ "$output" == *"[DRY-RUN]"* ]]
}
