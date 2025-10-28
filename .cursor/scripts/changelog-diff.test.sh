#!/usr/bin/env bash
# Test suite for changelog-diff.sh

# shellcheck disable=SC1090,SC1091
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT="$SCRIPT_DIR/changelog-diff.sh"

TEST_ARTIFACTS_DIR="${TEST_ARTIFACTS_DIR:-$ROOT_DIR/.test-artifacts}"
mkdir -p "$TEST_ARTIFACTS_DIR"

# Test: Help output
echo "TEST: Help shows usage"
HELP_OUTPUT=$("$SCRIPT" --help 2>&1)
if echo "$HELP_OUTPUT" | grep -q "Usage:"; then
  echo "PASS: Help available"
else
  echo "FAIL: Help missing" >&2
  exit 1
fi

# Test: Requires --project argument
echo "TEST: Requires --project"
OUTPUT=$("$SCRIPT" 2>&1 || true)
if echo "$OUTPUT" | grep -q -- "--project is required"; then
  echo "PASS: --project required"
else
  echo "FAIL: Should require --project" >&2
  exit 1
fi

# Test: Requires --from and --to arguments
echo "TEST: Requires phase arguments"
OUTPUT=$("$SCRIPT" --project test 2>&1 || true)
if echo "$OUTPUT" | grep -qE "(--from|--to).*required"; then
  echo "PASS: Phase arguments required"
else
  echo "FAIL: Should require phase arguments" >&2
  exit 1
fi

echo ""
echo "All tests: PASS"

