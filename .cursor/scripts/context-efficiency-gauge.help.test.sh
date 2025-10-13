#!/usr/bin/env bash
# Test: context-efficiency-gauge.sh help migration
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUT="$SCRIPT_DIR/context-efficiency-gauge.sh"

echo "[TEST] context-efficiency-gauge.sh (help migration)"

# Test: help includes Exit Codes section
test_help_has_exit_codes() {
  set +e
  output=$("$SUT" --help 2>&1)
  status=$?
  set -e
  
  if [ "$status" -ne 0 ]; then
    echo "[FAIL] --help should exit 0" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -qE "^Exit Codes?:"; then
    echo "[FAIL] help should contain Exit Codes section" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] help includes Exit Codes section"
}

# Test: help includes all standard sections
test_help_complete() {
  set +e
  output=$("$SUT" --help 2>&1)
  status=$?
  set -e
  
  local missing=()
  
  echo "$output" | grep -q "Usage:" || missing+=("Usage")
  echo "$output" | grep -qi "Options:" || missing+=("Options")
  echo "$output" | grep -qi "Examples:" || missing+=("Examples")
  echo "$output" | grep -qE "Exit Codes?:" || missing+=("Exit Codes")
  
  if [ "${#missing[@]}" -gt 0 ]; then
    echo "[FAIL] help missing sections: ${missing[*]}" >&2
    return 1
  fi
  
  echo "[PASS] help includes all required sections"
}

# Test: help uses print_exit_codes from .lib.sh
test_uses_print_exit_codes() {
  if ! grep -q "print_exit_codes" "$SUT"; then
    echo "[FAIL] script should use print_exit_codes helper" >&2
    return 1
  fi
  
  echo "[PASS] uses print_exit_codes helper"
}

# Run all tests
test_help_has_exit_codes
test_help_complete
test_uses_print_exit_codes

echo "[TEST] context-efficiency-gauge.sh (help): All tests passed"
exit 0

