#!/usr/bin/env bash
set -euo pipefail

# Test suite for pr-label.sh
# Owner tests for PR labeling extraction

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT="$SCRIPT_DIR/pr-label.sh"

# shellcheck disable=SC1090
source "$SCRIPT_DIR/.lib.sh"

# Create temp directory
tmpdir="$ROOT_DIR/.test-artifacts/pr-label-$$"
mkdir -p "$tmpdir"
trap_cleanup "$tmpdir"

# Test 1: Add single label (dry-run)
set +e
output=$(bash "$SCRIPT" --pr 123 --label bug --dry-run 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Dry-run should succeed"
  echo "Output: $output"
  exit 1
fi

if ! [[ "$output" =~ "bug" ]] || ! [[ "$output" =~ "123" ]]; then
  echo "FAIL: Should show PR and label"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 1 - Single label dry-run"

# Test 2: Add multiple labels (dry-run)
set +e
output=$(bash "$SCRIPT" --pr 456 --label bug --label enhancement --dry-run 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Multiple labels dry-run should succeed"
  exit 1
fi

if ! [[ "$output" =~ "bug" ]] || ! [[ "$output" =~ "enhancement" ]]; then
  echo "FAIL: Should show both labels"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 2 - Multiple labels dry-run"

# Test 3: Missing PR number fails
set +e
output=$(bash "$SCRIPT" --label bug 2>&1)
status=$?
set -e

if [ $status -eq 0 ]; then
  echo "FAIL: Missing --pr should fail"
  exit 1
fi

if ! [[ "$output" =~ "--pr is required" ]]; then
  echo "FAIL: Should report missing --pr"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 3 - Missing PR number fails"

# Test 4: Missing label fails
set +e
output=$(bash "$SCRIPT" --pr 123 2>&1)
status=$?
set -e

if [ $status -eq 0 ]; then
  echo "FAIL: Missing --label should fail"
  exit 1
fi

if ! [[ "$output" =~ "--label is required" ]]; then
  echo "FAIL: Should report missing --label"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 4 - Missing label fails"

# Test 5: JSON output format (dry-run)
set +e
output=$(bash "$SCRIPT" --pr 789 --label test --format json --dry-run 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: JSON format should work"
  exit 1
fi

if ! echo "$output" | grep -q '"pr"'; then
  echo "FAIL: JSON should contain 'pr' key"
  echo "Output: $output"
  exit 1
fi

if ! echo "$output" | grep -q '"labels"'; then
  echo "FAIL: JSON should contain 'labels' key"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 5 - JSON output format"

# Test 6: Help and version flags
set +e
output=$(bash "$SCRIPT" --help 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: --help should exit 0"
  exit 1
fi

echo "PASS: Test 6 - Help flag works"

echo ""
echo "All tests passed!"

