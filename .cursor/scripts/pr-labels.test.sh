#!/usr/bin/env bash
# Tests for pr-labels.sh
#
# Owner spec for pr-labels.sh
# Tests label management operations via GitHub API

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/pr-labels.sh"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0

# Test helpers
assert_exit_code() {
  local expected=$1
  local actual=$2
  local description=$3
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ "$actual" -eq "$expected" ]]; then
    echo "✓ $description"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo "✗ $description (expected exit $expected, got $actual)"
  fi
}

assert_contains() {
  local haystack=$1
  local needle=$2
  local description=$3
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if echo "$haystack" | grep -qF "$needle"; then
    echo "✓ $description"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo "✗ $description (output did not contain '$needle')"
  fi
}

assert_not_contains() {
  local haystack=$1
  local needle=$2
  local description=$3
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if ! echo "$haystack" | grep -qF "$needle"; then
    echo "✓ $description"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo "✗ $description (output should not contain '$needle')"
  fi
}

echo "Testing pr-labels.sh"
echo "===================="
echo

# Test 1: Missing --pr flag
echo "Test: Missing --pr flag"
set +e
OUTPUT=$(bash "$SCRIPT" --add test-label 2>&1)
EXIT_CODE=$?
set -e
assert_exit_code 1 $EXIT_CODE "Should fail without --pr"
assert_contains "$OUTPUT" "ERROR: --pr <number> required" "Should show error message"
echo

# Test 2: Missing action
echo "Test: Missing action"
set +e
OUTPUT=$(bash "$SCRIPT" --pr 123 2>&1)
EXIT_CODE=$?
set -e
assert_exit_code 1 $EXIT_CODE "Should fail without action"
assert_contains "$OUTPUT" "Action required" "Should show error message"
echo

# Test 3: Missing label for --add
echo "Test: Missing label for --add"
set +e
OUTPUT=$(bash "$SCRIPT" --pr 123 --add 2>&1)
EXIT_CODE=$?
set -e
assert_exit_code 1 $EXIT_CODE "Should fail without label"
echo

# Test 4: Missing label for --remove
echo "Test: Missing label for --remove"
set +e
OUTPUT=$(bash "$SCRIPT" --pr 123 --remove 2>&1)
EXIT_CODE=$?
set -e
assert_exit_code 1 $EXIT_CODE "Should fail without label"
echo

# Test 5: Missing label for --has
echo "Test: Missing label for --has"
set +e
OUTPUT=$(bash "$SCRIPT" --pr 123 --has 2>&1)
EXIT_CODE=$?
set -e
assert_exit_code 1 $EXIT_CODE "Should fail without label"
echo

# Test 6: Missing GITHUB_TOKEN
echo "Test: Missing GITHUB_TOKEN"
unset GITHUB_TOKEN GH_TOKEN || true
set +e
OUTPUT=$(GITHUB_TOKEN="" GH_TOKEN="" bash "$SCRIPT" --pr 123 --list 2>&1)
EXIT_CODE=$?
set -e
assert_exit_code 1 $EXIT_CODE "Should fail without token"
assert_contains "$OUTPUT" "GITHUB_TOKEN or GH_TOKEN" "Should show token error"
echo

# Integration tests (require GITHUB_TOKEN and network)
if [[ -n "${GITHUB_TOKEN:-${GH_TOKEN:-}}" ]]; then
  echo "Integration Tests (with GITHUB_TOKEN)"
  echo "======================================"
  echo
  
  # Test 7: List labels (read-only, safe to run)
  echo "Test: List labels on current PR"
  # Use PR #147 as test subject (current PR)
  set +e
  OUTPUT=$(bash "$SCRIPT" --pr 147 --list 2>&1)
  EXIT_CODE=$?
  set -e
  assert_exit_code 0 $EXIT_CODE "Should list labels successfully"
  echo "  Labels found: ${OUTPUT:-none}"
  echo
  
  # Test 8: Check if label exists (read-only)
  echo "Test: Check if skip-changeset label exists"
  set +e
  OUTPUT=$(bash "$SCRIPT" --pr 147 --has skip-changeset 2>&1)
  HAS_EXIT=$?
  set -e
  echo "  Has skip-changeset: $([ $HAS_EXIT -eq 0 ] && echo 'true' || echo 'false')"
  # Note: This will be "false" since we just removed it
  assert_exit_code 1 $HAS_EXIT "Should return false (label was removed)"
  echo
  
  # Test 9: Invalid PR number
  echo "Test: Invalid PR number"
  set +e
  OUTPUT=$(bash "$SCRIPT" --pr 999999 --list 2>&1)
  EXIT_CODE=$?
  set -e
  assert_exit_code 1 $EXIT_CODE "Should fail with invalid PR"
  echo
  
  echo "Note: Skipping add/remove tests to avoid side effects on real PRs"
  echo "Run manual integration tests if needed:"
  echo "  bash $SCRIPT --pr <test-pr> --add test-label"
  echo "  bash $SCRIPT --pr <test-pr> --remove test-label"
  echo
else
  echo "Skipping integration tests (GITHUB_TOKEN not set)"
  echo
fi

# Summary
echo "===================="
echo "Tests: $TESTS_PASSED / $TESTS_RUN passed"

if [[ "$TESTS_PASSED" -eq "$TESTS_RUN" ]]; then
  echo "✓ All tests passed"
  exit 0
else
  echo "✗ Some tests failed"
  exit 1
fi

