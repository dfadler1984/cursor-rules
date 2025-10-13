#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUT="$SCRIPT_DIR/project-lifecycle-migrate.sh"

echo "[TEST] project-lifecycle-migrate.sh (help migration)"

test_help_complete() {
  output=$("$SUT" --help 2>&1)
  echo "$output" | grep -qE "^Options?:" || { echo "[FAIL] missing Options"; return 1; }
  echo "$output" | grep -qE "^Exit Codes?:" || { echo "[FAIL] missing Exit Codes"; return 1; }
  echo "[PASS] help complete"
}

test_help_complete
echo "[TEST] project-lifecycle-migrate.sh (help): All tests passed"
exit 0

