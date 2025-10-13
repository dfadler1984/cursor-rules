#!/usr/bin/env bash
# Test: git-branch-name.sh help migration
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUT="$SCRIPT_DIR/git-branch-name.sh"

echo "[TEST] git-branch-name.sh (help migration)"

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

# Test: help includes Examples section
test_help_has_examples() {
  set +e
  output=$("$SUT" --help 2>&1)
  status=$?
  set -e
  
  if ! echo "$output" | grep -qE "^Examples?:"; then
    echo "[FAIL] help should contain Examples section" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] help includes Examples section"
}

# Run all tests
test_help_has_exit_codes
test_help_has_examples

echo "[TEST] git-branch-name.sh (help): All tests passed"
exit 0

