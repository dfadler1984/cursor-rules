#!/usr/bin/env bash
set -euo pipefail

# Test suite for git-context.sh
# Owner tests for git context derivation extraction

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT="$SCRIPT_DIR/git-context.sh"

# Test 1: Derive from git remote
# This test runs in the actual repo
set +e
output=$(bash "$SCRIPT" 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Should derive context from git remote"
  echo "Output: $output"
  exit 1
fi

# Should output owner, repo, head, base
if ! [[ "$output" =~ "owner=" ]] || ! [[ "$output" =~ "repo=" ]]; then
  echo "FAIL: Should output owner and repo"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 1 - Derive from git remote"

# Test 2: JSON output format
set +e
output=$(bash "$SCRIPT" --format json 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: JSON format should work"
  exit 1
fi

if ! echo "$output" | grep -q '"owner"' || ! echo "$output" | grep -q '"repo"'; then
  echo "FAIL: JSON should contain owner and repo"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 2 - JSON output format"

# Test 3: Shell-eval format
set +e
output=$(bash "$SCRIPT" --format eval 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Eval format should work"
  exit 1
fi

# Should be valid bash variable assignments
if ! [[ "$output" =~ ^OWNER= ]] || ! [[ "$output" =~ REPO= ]]; then
  echo "FAIL: Eval format should output OWNER= and REPO="
  echo "Output: $output"
  exit 1
fi

# Should be sourceable
eval "$output"
if [ -z "$OWNER" ] || [ -z "$REPO" ]; then
  echo "FAIL: Eval output should set OWNER and REPO"
  exit 1
fi

echo "PASS: Test 3 - Eval format is sourceable"

# Test 4: Help and version flags
set +e
output=$(bash "$SCRIPT" --help 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: --help should exit 0"
  exit 1
fi

if ! [[ "$output" =~ "Usage" ]]; then
  echo "FAIL: --help should show usage"
  exit 1
fi

set +e
output=$(bash "$SCRIPT" --version 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: --version should exit 0"
  exit 1
fi

echo "PASS: Test 4 - Help and version flags"

echo ""
echo "All tests passed!"

