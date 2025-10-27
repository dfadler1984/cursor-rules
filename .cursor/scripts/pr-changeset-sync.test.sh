#!/usr/bin/env bash
# Owner tests for pr-changeset-sync.sh
# Tests PR changeset label synchronization

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_SCRIPT="$SCRIPT_DIR/pr-changeset-sync.sh"

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
test_help_text() {
  "$TARGET_SCRIPT" --help > /dev/null 2>&1
  assert_exit_code 0 $? "help text displays"
}

test_missing_pr_flag() {
  set +e
  "$TARGET_SCRIPT" 2>/dev/null
  local exit_code=$?
  set -e
  # Should fail when --pr is missing
  if [[ $exit_code -ne 0 ]]; then
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo "✓ fails without --pr flag"
  else
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "✗ should fail without --pr flag"
  fi
}

# TODO: Add tests with mocked GitHub API
# - Test with changeset present → removes skip-changeset label
# - Test without changeset → adds skip-changeset label
# - Test with no labels → handles gracefully
# - Test API errors

# Run tests
test_help_text
test_missing_pr_flag

# Summary
echo ""
echo "Tests run: $TESTS_RUN"
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"

[[ $TESTS_FAILED -eq 0 ]]

