#!/usr/bin/env bash
# Owner tests for project-lifecycle-validate-scoped.sh
# Tests scoped project validation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_SCRIPT="$SCRIPT_DIR/project-lifecycle-validate-scoped.sh"

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

test_missing_slug_arg() {
  set +e
  "$TARGET_SCRIPT" 2>/dev/null
  local exit_code=$?
  set -e
  # Should fail when slug argument is missing (any non-zero is acceptable)
  if [[ $exit_code -ne 0 ]]; then
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo "✓ fails without slug argument"
  else
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "✗ should fail without slug"
  fi
}

# TODO: Add tests with project fixtures
# - Test validation of valid project structure
# - Test detection of missing erd.md
# - Test detection of missing tasks.md
# - Test detection of incomplete tasks
# - Test detection of missing final-summary.md

# Run tests
test_help_text
test_missing_slug_arg

# Summary
echo ""
echo "Tests run: $TESTS_RUN"
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"

[[ $TESTS_FAILED -eq 0 ]]

