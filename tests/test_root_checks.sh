#!/bin/bash

# Test that scripts exit if not run as root
EXPECTED_MSG="This script must be run as root / Este script deve ser executado como root"

test_root_check() {
    local script=$1
    echo "Testing $script root check..."
    output=$(./$script 2>&1)
    status=$?
    
    if [ $status -ne 1 ]; then
        echo "FAIL: $script did not exit with status 1 (got $status)"
        return 1
    fi
    
    if [[ "$output" != *"$EXPECTED_MSG"* ]]; then
        echo "FAIL: $script did not print expected error message"
        echo "Expected: $EXPECTED_MSG"
        echo "Got: $output"
        return 1
    fi
    
    echo "PASS: $script root check verified"
    return 0
}

errors=0
test_root_check "install.sh" || ((errors++))
test_root_check "ucm.sh" || ((errors++))
test_root_check "uninstall.sh" || ((errors++))

if [ $errors -eq 0 ]; then
    echo "All root check tests passed!"
    exit 0
else
    echo "$errors tests failed."
    exit 1
fi
