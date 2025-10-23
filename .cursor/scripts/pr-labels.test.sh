#!/usr/bin/env bash
# Owner tests for pr-labels.sh
# Tests label management operations (add, remove, list, has)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_SCRIPT="$SCRIPT_DIR/pr-labels.sh"

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

assert_contains() {
  local output=$1
  local expected=$2
  local test_name=$3
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if echo "$output" | grep -q "$expected"; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo "✓ $test_name"
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "✗ $test_name (output doesn't contain '$expected')"
    echo "  Output: $output"
  fi
}

# Test: --help shows usage
test_help() {
  local output
  output=$("$TARGET_SCRIPT" --help 2>&1) || true
  assert_contains "$output" "pr-labels.sh --pr" "help shows usage"
  assert_contains "$output" "remove LABEL" "help documents --remove"
}

# Test: Missing --pr fails with exit 1
test_missing_pr() {
  local exit_code=0
  "$TARGET_SCRIPT" --add test-label 2>/dev/null || exit_code=$?
  assert_exit_code 1 "$exit_code" "missing --pr fails"
}

# Test: Missing action fails
test_missing_action() {
  local exit_code=0
  "$TARGET_SCRIPT" --pr 123 2>/dev/null || exit_code=$?
  assert_exit_code 1 "$exit_code" "missing action fails"
}

# Test: --has with missing token (should fail gracefully)
test_missing_token() {
  local exit_code=0
  local output
  output=$(GITHUB_TOKEN="" GH_TOKEN="" "$TARGET_SCRIPT" --pr 123 --has test 2>&1) || exit_code=$?
  assert_exit_code 1 "$exit_code" "missing token fails gracefully"
  assert_contains "$output" "GITHUB_TOKEN" "error mentions token"
}

# Test: --list parses GitHub API response with spaces (unit test of parsing logic)
test_list_parsing_with_spaces() {
  # Simulate the --list code path with real GitHub API response format
  local mock_response='[
  {
    "id": 9404546873,
    "name": "skip-changeset",
    "color": "ededed"
  }
]'
  
  # Extract label name using same logic as pr-labels.sh line 199
  local parsed
  parsed=$(echo "$mock_response" | grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/' || true)
  
  assert_contains "$parsed" "skip-changeset" "--list parses labels with spaces in JSON"
}

# Note: Live API tests require valid GITHUB_TOKEN and may affect real PRs
# These are smoke tests for argument parsing and basic validation
# Full API integration tests should use mock server or test repo

echo "Running pr-labels.sh owner tests..."
echo

test_help
test_missing_pr
test_missing_action
test_missing_token
test_list_parsing_with_spaces

echo
echo "Results: $TESTS_PASSED/$TESTS_RUN passed"

if [[ $TESTS_FAILED -gt 0 ]]; then
  echo "FAILED: $TESTS_FAILED tests failed"
  exit 1
else
  echo "SUCCESS: All tests passed"
  exit 0
fi
