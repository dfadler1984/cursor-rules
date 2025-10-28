#!/usr/bin/env bash
# Test suite for changelog-backfill.sh

# shellcheck disable=SC1090,SC1091
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT="$SCRIPT_DIR/changelog-backfill.sh"

# Test: Help output
echo "TEST: Help shows usage"
HELP_OUTPUT=$("$SCRIPT" --help 2>&1)
if echo "$HELP_OUTPUT" | grep -q "Usage:" || echo "$HELP_OUTPUT" | grep -q "changelog-backfill"; then
  echo "PASS: Help available"
else
  echo "FAIL: Help missing" >&2
  echo "Help output:" >&2
  echo "$HELP_OUTPUT" | head -5 >&2
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

# Test: Requires --year for archived projects
echo "TEST: Requires --year for archived projects"
OUTPUT=$("$SCRIPT" --project test-proj 2>&1 || true)
if echo "$OUTPUT" | grep -q -- "--year is required"; then
  echo "PASS: --year required for archived"
else
  echo "FAIL: Should require --year" >&2
  exit 1
fi

echo ""
echo "All tests: PASS"

