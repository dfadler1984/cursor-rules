#!/usr/bin/env bash
# Test: project-archive.sh help migration
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUT="$SCRIPT_DIR/project-archive.sh"

echo "[TEST] project-archive.sh (help migration)"

# Test: help includes Exit Codes and Examples sections
test_help_complete() {
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
    return 1
  fi
  
  if ! echo "$output" | grep -qE "^Examples?:"; then
    echo "[FAIL] help should contain Examples section" >&2
    return 1
  fi
  
  echo "[PASS] help includes Exit Codes and Examples"
}

test_help_complete
echo "[TEST] project-archive.sh (help): All tests passed"
exit 0

