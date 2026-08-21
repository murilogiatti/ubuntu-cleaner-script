#!/bin/bash

# Simple test runner for UCM
echo "Running tests..."
echo "----------------"

errors=0
for test_file in tests/test_*.sh; do
    if [ -f "$test_file" ]; then
        echo "Executing $test_file..."
        bash "$test_file"
        if [ $? -ne 0 ]; then
            ((errors++))
        fi
        echo "----------------"
    fi
done

if command -v bats >/dev/null 2>&1; then
    echo "Executing Bats tests..."
    (cd tests/bats && bats .)
    if [ $? -ne 0 ]; then
        ((errors++))
    fi
    echo "----------------"
else
    echo "Bats not installed; skipping tests/bats."
    echo "----------------"
fi

if [ $errors -eq 0 ]; then
    echo "All test suites passed!"
    exit 0
else
    echo "$errors test suite(s) failed."
    exit 1
fi
