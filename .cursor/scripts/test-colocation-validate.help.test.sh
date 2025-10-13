#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUT="$SCRIPT_DIR/test-colocation-validate.sh"

echo "[TEST] test-colocation-validate.sh (help migration)"

test_help_complete() {
  output=$("$SUT" --help 2>&1)
  echo "$output" | grep -qE "^Examples?:" || { echo "[FAIL] missing Examples"; return 1; }
  echo "$output" | grep -qE "^Exit Codes?:" || { echo "[FAIL] missing Exit Codes"; return 1; }
  echo "[PASS] help complete"
}

test_help_complete
echo "[TEST] test-colocation-validate.sh (help): All tests passed"
exit 0

