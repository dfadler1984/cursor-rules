#!/usr/bin/env bash
# Test suite for validate-root-readme.sh
#
# Usage: bash validate-root-readme.test.sh [-v]

set -euo pipefail

# Test framework setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Verbose mode
VERBOSE=false
if [[ "${1:-}" == "-v" ]]; then
  VERBOSE=true
fi

# Test helpers
assert_equals() {
  local expected="$1"
  local actual="$2"
  local message="${3:-}"
  
  TESTS_RUN=$((TESTS_RUN + 1))
  
  if [[ "$expected" == "$actual" ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    if $VERBOSE; then
      echo -e "${GREEN}✓${NC} $message"
    fi
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} $message"
    echo "  Expected: $expected"
    echo "  Actual:   $actual"
    return 1
  fi
}

assert_exit_code() {
  local expected="$1"
  local actual="$2"
  local message="${3:-}"
  
  TESTS_RUN=$((TESTS_RUN + 1))
  
  if [[ "$expected" == "$actual" ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    if $VERBOSE; then
      echo -e "${GREEN}✓${NC} $message"
    fi
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} $message"
    echo "  Expected exit code: $expected"
    echo "  Actual exit code:   $actual"
    return 1
  fi
}

# Setup test environment
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

#
# Test Suite: Validation Script
#

test_validator_help() {
  local output
  output=$("$SCRIPT_DIR/validate-root-readme.sh" --help 2>&1)
  local exit_code=$?
  
  assert_exit_code "0" "$exit_code" \
    "Should exit 0 for --help"
  
  if echo "$output" | grep -q "Validate root README.md freshness"; then
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
    if $VERBOSE; then
      echo -e "${GREEN}✓${NC} Help text should contain description"
    fi
  else
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} Help text should contain description"
  fi
}

test_validator_version() {
  local output
  output=$("$SCRIPT_DIR/validate-root-readme.sh" --version 2>&1)
  local exit_code=$?
  
  assert_exit_code "0" "$exit_code" \
    "Should exit 0 for --version"
  
  if echo "$output" | grep -q "validate-root-readme.sh version"; then
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
    if $VERBOSE; then
      echo -e "${GREEN}✓${NC} Version output should contain version string"
    fi
  else
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} Version output should contain version string"
  fi
}

test_validator_integration() {
  # Integration test: validate against real repository
  # This tests that the validator can actually run against our repo
  local exit_code=0
  "$SCRIPT_DIR/validate-root-readme.sh" >/dev/null 2>&1 || exit_code=$?
  
  # Should return 0 or 1 (not 2 which is error)
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ $exit_code -eq 0 ]] || [[ $exit_code -eq 1 ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    if $VERBOSE; then
      echo -e "${GREEN}✓${NC} Should run against real repository (exit: $exit_code)"
    fi
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} Should not error against real repository"
    echo "  Exit code: $exit_code (expected 0 or 1)"
  fi
}

test_validator_unknown_flag() {
  local exit_code=0
  "$SCRIPT_DIR/validate-root-readme.sh" --unknown-flag >/dev/null 2>&1 || exit_code=$?
  
  assert_exit_code "2" "$exit_code" \
    "Should exit 2 for unknown flag"
}

#
# Run all tests
#

echo ""
echo "Running validate-root-readme.sh test suite..."
echo ""

echo "Test Suite: Validation Script"
test_validator_help
test_validator_version
test_validator_integration
test_validator_unknown_flag
echo ""

#
# Summary
#

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Results"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Total:  $TESTS_RUN"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ $TESTS_FAILED -eq 0 ]]; then
  echo -e "${GREEN}All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}Some tests failed.${NC}"
  exit 1
fi

