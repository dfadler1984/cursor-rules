#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

# Test suite for pr-create-simple.sh
# Owner tests for simplified PR creation (Unix Philosophy compliant)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT="$SCRIPT_DIR/pr-create-simple.sh"

# Create temp directory
tmpdir="$ROOT_DIR/.test-artifacts/pr-create-simple-$$"
mkdir -p "$tmpdir"
trap_cleanup "$tmpdir"

# Test 1: Basic PR creation (dry-run)
set +e
output=$(bash "$SCRIPT" --title "Test PR" --body "Test body" --dry-run 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Dry-run should succeed"
  echo "Output: $output"
  exit 1
fi

if ! [[ "$output" =~ "Test PR" ]] || ! [[ "$output" =~ "Test body" ]]; then
  echo "FAIL: Should show title and body"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 1 - Basic dry-run"

# Test 2: Auto-detect base and head from git
set +e
output=$(bash "$SCRIPT" --title "Test" --body "Body" --dry-run 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Should auto-detect base/head"
  echo "Output: $output"
  exit 1
fi

# Should show base and head
if ! [[ "$output" =~ "base" ]] || ! [[ "$output" =~ "head" ]]; then
  echo "FAIL: Should derive base and head from git"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 2 - Auto-detect base/head"

# Test 3: Missing title fails
set +e
output=$(bash "$SCRIPT" --body "Body" 2>&1)
status=$?
set -e

if [ $status -eq 0 ]; then
  echo "FAIL: Missing title should fail"
  exit 1
fi

if ! [[ "$output" =~ "--title is required" ]]; then
  echo "FAIL: Should report missing title"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 3 - Missing title fails"

# Test 4: Explicit base and head override
set +e
output=$(bash "$SCRIPT" --title "Test" --body "Body" --base develop --head feature/test --dry-run 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Explicit base/head should work"
  exit 1
fi

if ! [[ "$output" =~ "develop" ]] || ! [[ "$output" =~ "feature/test" ]]; then
  echo "FAIL: Should use explicit base/head"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 4 - Explicit base/head"

# Test 5: JSON output
set +e
output=$(bash "$SCRIPT" --title "Test" --body "Body" --format json --dry-run 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: JSON format should work"
  exit 1
fi

if ! echo "$output" | grep -q '"title"'; then
  echo "FAIL: JSON should contain title"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 5 - JSON output"

# Test 6: Help and version
set +e
output=$(bash "$SCRIPT" --help 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: --help should exit 0"
  exit 1
fi

if ! [[ "$output" =~ "Usage" ]]; then
  echo "FAIL: Should show usage"
  exit 1
fi

echo "PASS: Test 6 - Help works"

echo ""
echo "All tests passed!"

