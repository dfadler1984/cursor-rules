#!/usr/bin/env bash
# routing-validate.test.sh — Tests for routing-validate.sh
#
# Test owner: routing-validate.sh
# Test scope: Validate routing validation script behavior

set -euo pipefail

# Test setup
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly TEST_SCRIPT="${SCRIPT_DIR}/routing-validate.sh"

# Test utilities
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

declare -i TESTS_RUN=0
declare -i TESTS_PASSED=0
declare -i TESTS_FAILED=0

# Assertions
assert_exit_code() {
  local expected="$1"
  local actual="$2"
  local test_name="$3"
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ "$actual" -eq "$expected" ]]; then
    echo -e "${GREEN}✓${NC} $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    echo -e "${RED}✗${NC} $test_name (expected exit $expected, got $actual)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

assert_file_exists() {
  local file="$1"
  local test_name="$2"
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ -f "$file" ]]; then
    echo -e "${GREEN}✓${NC} $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    echo -e "${RED}✗${NC} $test_name (file not found: $file)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

assert_output_contains() {
  local output="$1"
  local pattern="$2"
  local test_name="$3"
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if echo "$output" | grep -q "$pattern"; then
    echo -e "${GREEN}✓${NC} $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    echo -e "${RED}✗${NC} $test_name (pattern not found: $pattern)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

# Test: Script exists and is executable
test_script_exists() {
  assert_file_exists "$TEST_SCRIPT" "Script file exists"
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ -x "$TEST_SCRIPT" ]]; then
    echo -e "${GREEN}✓${NC} Script is executable"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "${RED}✗${NC} Script is not executable"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

# Test: Help flag works
test_help_flag() {
  local exit_code=0
  "$TEST_SCRIPT" --help >/dev/null 2>&1 || exit_code=$?
  assert_exit_code 0 "$exit_code" "Help flag returns exit 0"
}

# Test: Help output contains usage
test_help_contains_usage() {
  local output
  output=$("$TEST_SCRIPT" --help 2>&1)
  assert_output_contains "$output" "Usage:" "Help contains usage information"
}

# Test: Invalid format option
test_invalid_format() {
  local exit_code=0
  "$TEST_SCRIPT" --format invalid 2>/dev/null || exit_code=$?
  assert_exit_code 2 "$exit_code" "Invalid format returns exit 2"
}

# Test: Finds test suite
test_finds_test_suite() {
  local output
  local exit_code=0
  output=$("$TEST_SCRIPT" --format text 2>&1) || exit_code=$?
  
  # Should find the test suite (or warn about proof-of-concept)
  assert_output_contains "$output" "test" "Output mentions test suite or proof-of-concept"
}

# Test: JSON format option
test_json_format() {
  local output
  output=$("$TEST_SCRIPT" --format json 2>&1) || true
  
  # Should produce JSON output (or note it's proof-of-concept)
  TESTS_RUN=$((TESTS_RUN + 1))
  if echo "$output" | grep -qE '\{|\}|proof-of-concept'; then
    echo -e "${GREEN}✓${NC} JSON format option accepted"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "${RED}✗${NC} JSON format should produce JSON or note"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

# Test: Text format option (default)
test_text_format() {
  local output
  output=$("$TEST_SCRIPT" --format text 2>&1) || true
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if echo "$output" | grep -qE 'Routing|validation|proof-of-concept'; then
    echo -e "${GREEN}✓${NC} Text format produces output"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "${RED}✗${NC} Text format should produce readable output"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

# Test: Verbose flag accepted
test_verbose_flag() {
  local exit_code=0
  "$TEST_SCRIPT" --verbose 2>/dev/null || exit_code=$?
  
  # Should accept flag (exits 0 or 1, not 2 for usage error)
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ "$exit_code" -ne 2 ]]; then
    echo -e "${GREEN}✓${NC} Verbose flag accepted"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "${RED}✗${NC} Verbose flag should be accepted"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

# Main test runner
main() {
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Testing: routing-validate.sh"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  
  # Run tests
  test_script_exists
  test_help_flag
  test_help_contains_usage
  test_invalid_format
  test_finds_test_suite
  test_json_format
  test_text_format
  test_verbose_flag
  
  # Summary
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Test Results"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Tests run:    $TESTS_RUN"
  echo "Tests passed: $TESTS_PASSED"
  echo "Tests failed: $TESTS_FAILED"
  echo ""
  
  if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed${NC}"
    exit 0
  else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
  fi
}

main "$@"

