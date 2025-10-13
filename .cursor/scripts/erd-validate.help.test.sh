#!/usr/bin/env bash
# Test: erd-validate.sh help migration
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUT="$SCRIPT_DIR/erd-validate.sh"

echo "[TEST] erd-validate.sh (help migration)"

# Test: --help flag exists and works
test_help_exists() {
  set +e
  output=$("$SUT" --help 2>&1)
  status=$?
  set -e
  
  if [ "$status" -ne 0 ]; then
    echo "[FAIL] --help should exit 0" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -q "Usage:"; then
    echo "[FAIL] help should contain Usage" >&2
    return 1
  fi
  
  echo "[PASS] --help flag exists"
}

# Test: help includes all required sections
test_help_complete() {
  set +e
  output=$("$SUT" --help 2>&1)
  status=$?
  set -e
  
  local missing=()
  
  echo "$output" | grep -qE "^Options?:" || missing+=("Options")
  echo "$output" | grep -qE "^Examples?:" || missing+=("Examples")
  echo "$output" | grep -qE "^Exit Codes?:" || missing+=("Exit Codes")
  
  if [ "${#missing[@]}" -gt 0 ]; then
    echo "[FAIL] help missing sections: ${missing[*]}" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] help includes all sections"
}

test_help_exists
test_help_complete

echo "[TEST] erd-validate.sh (help): All tests passed"
exit 0

