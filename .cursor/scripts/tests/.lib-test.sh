#!/usr/bin/env bash
# Test framework library for script tests
# Provides assertion helpers and test utilities
#
# Usage: source "$(dirname "$0")/tests/.lib-test.sh"

# Test state
TESTS_PASSED=0
TESTS_FAILED=0

# Assertion helpers
assert_cmd_succeeds() {
  local exit_code=0
  "$@" >/dev/null 2>&1 || exit_code=$?
  
  if [[ $exit_code -eq 0 ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "FAIL: Command should succeed but exited with $exit_code: $*" >&2
    return 1
  fi
}

assert_cmd_fails() {
  local exit_code=0
  "$@" >/dev/null 2>&1 || exit_code=$?
  
  if [[ $exit_code -ne 0 ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "FAIL: Command should fail but succeeded: $*" >&2
    return 1
  fi
}

assert_stdout_contains() {
  local expected="$1"
  shift
  local output
  output=$("$@" 2>&1)
  
  if echo "$output" | grep -q "$expected"; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "FAIL: Output should contain '$expected'" >&2
    echo "Actual output: $output" >&2
    return 1
  fi
}

assert_stdout_matches() {
  local pattern="$1"
  shift
  local output
  output=$("$@" 2>&1)
  
  if echo "$output" | grep -E -q "$pattern"; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "FAIL: Output should match pattern '$pattern'" >&2
    echo "Actual output: $output" >&2
    return 1
  fi
}

assert_exit_code() {
  local expected="$1"
  shift
  local exit_code=0
  "$@" >/dev/null 2>&1 || exit_code=$?
  
  if [[ $exit_code -eq $expected ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "FAIL: Expected exit code $expected but got $exit_code: $*" >&2
    return 1
  fi
}

# Test runner
run_tests() {
  # Execute all functions starting with "test_"
  local test_functions
  test_functions=$(declare -F | grep "declare -f test_" | awk '{print $3}')
  
  for test_func in $test_functions; do
    $test_func || true
  done
  
  # Report results
  local total=$((TESTS_PASSED + TESTS_FAILED))
  echo ""
  echo "Tests: $TESTS_PASSED passed, $TESTS_FAILED failed, $total total"
  
  if [[ $TESTS_FAILED -gt 0 ]]; then
    exit 1
  fi
  
  exit 0
}

# Test utilities
create_temp_repo() {
  mktemp -d
}

cleanup_temp_repo() {
  local repo_dir="$1"
  rm -rf "$repo_dir"
}

# Mock GitHub API for testing
mock_gh_api() {
  # Placeholder for GitHub API mocking
  # Can be implemented if needed
  :
}

