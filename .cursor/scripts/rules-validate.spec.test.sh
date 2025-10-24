#!/usr/bin/env bash
# Owner tests for rules-validate.spec.sh
# Tests spec helper functions for rules validation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_SCRIPT="$SCRIPT_DIR/rules-validate.spec.sh"

# Test framework setup
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

assert_exit_code() {
  local expected=$1
  local actual=$2
  local test_name=$3
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ "$actual" == "$expected" ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo "✓ $test_name"
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "✗ $test_name (expected exit $expected, got $actual)"
  fi
}

# Basic smoke test
test_script_exists() {
  if [[ -f "$TARGET_SCRIPT" && -x "$TARGET_SCRIPT" ]]; then
    assert_exit_code 0 0 "script exists and is executable"
  else
    assert_exit_code 0 1 "script exists and is executable"
  fi
}

# TODO: Add tests for spec helper functions
# - Test rule file fixture creation
# - Test validation scenario setup
# - Test assertion helpers

# Run tests
test_script_exists

# Summary
echo ""
echo "Tests run: $TESTS_RUN"
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"

[[ $TESTS_FAILED -eq 0 ]]

