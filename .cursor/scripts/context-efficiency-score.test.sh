#!/usr/bin/env bash
set -euo pipefail

# Test suite for context-efficiency-score.sh
# Owner tests for score computation extraction

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT="$SCRIPT_DIR/context-efficiency-score.sh"

# Test 1: Lean context (score 5)
set +e
output=$(bash "$SCRIPT" --scope-concrete true --rules 2 --loops 0 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Lean context should succeed"
  echo "Output: $output"
  exit 1
fi

# Should output score 5
if ! [[ "$output" =~ "score=5" ]] && ! [[ "$output" =~ "^5$" ]]; then
  echo "FAIL: Lean context should be score 5"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 1 - Lean context (score 5)"

# Test 2: OK context (score 4)
set +e
output=$(bash "$SCRIPT" --scope-concrete true --rules 4 --loops 1 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: OK context should succeed"
  exit 1
fi

if ! [[ "$output" =~ "score=4" ]] && ! [[ "$output" =~ "^4$" ]]; then
  echo "FAIL: Should be score 4"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 2 - OK context (score 4)"

# Test 3: Moderate context (score 3)
set +e
output=$(bash "$SCRIPT" --scope-concrete true --rules 7 --loops 2 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Moderate context should succeed"
  exit 1
fi

if ! [[ "$output" =~ "score=3" ]] && ! [[ "$output" =~ "^3$" ]]; then
  echo "FAIL: Should be score 3"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 3 - Moderate context (score 3)"

# Test 4: Bloated context (score 2)
set +e
output=$(bash "$SCRIPT" --scope-concrete false --rules 10 --loops 4 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Bloated context should succeed"
  exit 1
fi

if ! [[ "$output" =~ "score=2" ]] && ! [[ "$output" =~ "^2$" ]]; then
  echo "FAIL: Should be score 2"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 4 - Bloated context (score 2)"

# Test 5: Severely bloated (score 1)
set +e
output=$(bash "$SCRIPT" --scope-concrete false --rules 15 --loops 6 --issues "severe,truncated,cut off" 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Severely bloated should succeed"
  exit 1
fi

if ! [[ "$output" =~ "score=1" ]] && ! [[ "$output" =~ "^1$" ]]; then
  echo "FAIL: Should be score 1"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 5 - Severely bloated (score 1)"

# Test 6: JSON output
set +e
output=$(bash "$SCRIPT" --scope-concrete true --rules 3 --loops 1 --format json 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: JSON format should work"
  exit 1
fi

if ! echo "$output" | grep -q '"score"'; then
  echo "FAIL: JSON should contain score"
  echo "Output: $output"
  exit 1
fi

if ! echo "$output" | grep -q '"label"'; then
  echo "FAIL: JSON should contain label"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 6 - JSON output"

echo ""
echo "All tests passed!"

