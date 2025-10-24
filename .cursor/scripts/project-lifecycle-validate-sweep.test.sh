#!/usr/bin/env bash
# Owner tests for project-lifecycle-validate-sweep.sh
# Tests validation sweep across all completed projects

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_SCRIPT="$SCRIPT_DIR/project-lifecycle-validate-sweep.sh"

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

# TODO: Add tests with fixtures
# - Test sweep finds all completed projects
# - Test validation runs for each project
# - Test error aggregation
# - Test report generation

# Run tests
test_help_text

# Summary
echo ""
echo "Tests run: $TESTS_RUN"
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"

[[ $TESTS_FAILED -eq 0 ]]

