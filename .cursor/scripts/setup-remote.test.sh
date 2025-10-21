#!/usr/bin/env bash
# Tests for setup-remote.sh
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/setup-remote.sh"

# Test: --help flag
set +e
out=$("$SCRIPT" --help 2>&1)
status=$?
set -e

[ $status -eq 0 ] || { echo "FAIL: --help should exit 0"; exit 1; }
echo "$out" | grep -q "setup-remote.sh" || { echo "FAIL: help should mention script name"; exit 1; }
echo "$out" | grep -q "OPTIONS" || { echo "FAIL: help should have OPTIONS section"; exit 1; }

# Test: --version flag
set +e
out=$("$SCRIPT" --version 2>&1)
status=$?
set -e

[ $status -eq 0 ] || { echo "FAIL: --version should exit 0"; exit 1; }
echo "$out" | grep -q "1.0.0" || { echo "FAIL: version should be 1.0.0"; exit 1; }

# Test: unknown flag
set +e
out=$("$SCRIPT" --invalid-flag 2>&1)
status=$?
set -e

[ $status -ne 0 ] || { echo "FAIL: unknown flag should exit non-zero"; exit 1; }
echo "$out" | grep -q "Unknown argument" || { echo "FAIL: should show error for unknown flag"; exit 1; }

echo "All tests passed"
exit 0

