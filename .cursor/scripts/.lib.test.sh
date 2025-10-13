#!/usr/bin/env bash
# Test: .lib.sh core library functions
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the library under test
# shellcheck disable=SC1090
source "$SCRIPT_DIR/.lib.sh"

echo "[TEST] .lib.sh — Core library"

# Test: Exit code constants are defined correctly
test_exit_code_constants() {
  local errors=0
  
  if [ "$EXIT_USAGE" -ne 2 ]; then
    echo "[FAIL] EXIT_USAGE should be 2, got $EXIT_USAGE" >&2
    errors=$((errors + 1))
  fi
  
  if [ "$EXIT_CONFIG" -ne 3 ]; then
    echo "[FAIL] EXIT_CONFIG should be 3, got $EXIT_CONFIG" >&2
    errors=$((errors + 1))
  fi
  
  if [ "$EXIT_DEPENDENCY" -ne 4 ]; then
    echo "[FAIL] EXIT_DEPENDENCY should be 4, got $EXIT_DEPENDENCY" >&2
    errors=$((errors + 1))
  fi
  
  if [ "$EXIT_NETWORK" -ne 5 ]; then
    echo "[FAIL] EXIT_NETWORK should be 5, got $EXIT_NETWORK" >&2
    errors=$((errors + 1))
  fi
  
  if [ "$EXIT_TIMEOUT" -ne 6 ]; then
    echo "[FAIL] EXIT_TIMEOUT should be 6, got $EXIT_TIMEOUT" >&2
    errors=$((errors + 1))
  fi
  
  if [ "$EXIT_INTERNAL" -ne 20 ]; then
    echo "[FAIL] EXIT_INTERNAL should be 20, got $EXIT_INTERNAL" >&2
    errors=$((errors + 1))
  fi
  
  if [ "$errors" -gt 0 ]; then
    return 1
  fi
  
  echo "[PASS] Exit code constants defined correctly"
}

# Test: have_cmd detects available commands
test_have_cmd() {
  if ! have_cmd bash; then
    echo "[FAIL] have_cmd should find bash" >&2
    return 1
  fi
  
  if have_cmd nonexistent_command_xyz; then
    echo "[FAIL] have_cmd should not find nonexistent command" >&2
    return 1
  fi
  
  echo "[PASS] have_cmd detects commands"
}

# Test: print_help_header formats correctly
test_print_help_header() {
  local output
  
  # Test with all args
  output=$(print_help_header "test-script.sh" "1.0.0" "Test description")
  if ! echo "$output" | grep -q "test-script.sh (v1.0.0)"; then
    echo "[FAIL] header should include name and version" >&2
    echo "$output" >&2
    return 1
  fi
  if ! echo "$output" | grep -q "Test description"; then
    echo "[FAIL] header should include description" >&2
    echo "$output" >&2
    return 1
  fi
  
  # Test with no version
  output=$(print_help_header "test-script.sh" "" "Description")
  if echo "$output" | grep -q "(v)"; then
    echo "[FAIL] header should not show empty version" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] print_help_header formats correctly"
}

# Test: print_option formats flag descriptions
test_print_option() {
  local output
  
  # Test without default
  output=$(print_option "--verbose" "Enable verbose output")
  if ! echo "$output" | grep -q "verbose"; then
    echo "[FAIL] option should contain flag" >&2
    echo "$output" >&2
    return 1
  fi
  if ! echo "$output" | grep -q "Enable verbose output"; then
    echo "[FAIL] option should contain description" >&2
    echo "$output" >&2
    return 1
  fi
  
  # Test with default
  output=$(print_option "--format FMT" "Output format" "json")
  if ! echo "$output" | grep -q "default: json"; then
    echo "[FAIL] option should show default value" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] print_option formats correctly"
}

# Test: print_exit_codes includes all standard codes
test_print_exit_codes() {
  local output
  output=$(print_exit_codes)
  
  local required_codes=("0" "1" "2" "3" "4" "5" "6" "20")
  for code in "${required_codes[@]}"; do
    if ! echo "$output" | grep -q "^  $code"; then
      echo "[FAIL] exit codes should include $code" >&2
      echo "$output" >&2
      return 1
    fi
  done
  
  echo "[PASS] print_exit_codes includes all codes"
}

# Test: json_escape handles special characters
test_json_escape() {
  local output
  
  # Test backslash
  output=$(json_escape 'path\to\file')
  if [ "$output" != 'path\\to\\file' ]; then
    echo "[FAIL] should escape backslashes, got: $output" >&2
    return 1
  fi
  
  # Test quotes
  output=$(json_escape 'say "hello"')
  if [ "$output" != 'say \"hello\"' ]; then
    echo "[FAIL] should escape quotes, got: $output" >&2
    return 1
  fi
  
  echo "[PASS] json_escape handles special characters"
}

# Run all tests
test_exit_code_constants
test_have_cmd
test_print_help_header
test_print_option
test_print_exit_codes
test_json_escape

echo "[TEST] .lib.sh: All tests passed"
exit 0

