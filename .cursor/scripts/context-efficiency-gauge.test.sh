#!/usr/bin/env bash
# Test: context-efficiency-gauge.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/.lib.sh"

SUT="$SCRIPT_DIR/context-efficiency-gauge.sh"

# Test counter
tests_run=0
tests_passed=0

assert_eq() {
  tests_run=$((tests_run + 1))
  local expected="$1"
  local actual="$2"
  local msg="${3:-}"
  
  if [ "$expected" = "$actual" ]; then
    tests_passed=$((tests_passed + 1))
    echo "✓ $msg"
  else
    echo "✗ $msg"
    echo "  Expected: $expected"
    echo "  Actual:   $actual"
    return 1
  fi
}

assert_contains() {
  tests_run=$((tests_run + 1))
  local haystack="$1"
  local needle="$2"
  local msg="${3:-}"
  
  if [[ "$haystack" == *"$needle"* ]]; then
    tests_passed=$((tests_passed + 1))
    echo "✓ $msg"
  else
    echo "✗ $msg"
    echo "  Expected to contain: $needle"
    echo "  Actual: $haystack"
    return 1
  fi
}

# Test: score 5 for lean context
echo "Test: score 5 for lean context"
output=$(bash "$SUT" --scope-concrete true --rules 2 --loops 0 --format line 2>&1) || true
assert_contains "$output" "5/5" "Should show score 5/5"
assert_contains "$output" "lean" "Should show lean label"
assert_contains "$output" "narrow scope" "Should show narrow scope"

# Test: score 4 for focused context
echo "Test: score 4 for focused context"
output=$(bash "$SUT" --scope-concrete true --rules 4 --loops 1 --format line 2>&1) || true
assert_contains "$output" "4/5" "Should show score 4/5"
assert_contains "$output" "lean" "Should show lean label"

# Test: score 3 for moderate context
echo "Test: score 3 for moderate context"
output=$(bash "$SUT" --scope-concrete true --rules 7 --loops 2 --issues "minor latency" --format line 2>&1) || true
assert_contains "$output" "3/5" "Should show score 3/5"
assert_contains "$output" "ok" "Should show ok label"

# Test: score 2 for bloated context
echo "Test: score 2 for bloated context"
output=$(bash "$SUT" --scope-concrete false --rules 10 --loops 4 --issues "latency,quality" --format line 2>&1) || true
assert_contains "$output" "2/5" "Should show score 2/5"
assert_contains "$output" "bloated" "Should show bloated label"

# Test: score 1 for severely bloated context
echo "Test: score 1 for severely bloated context"
output=$(bash "$SUT" --scope-concrete false --rules 15 --loops 6 --issues "latency,truncated,quality" --format line 2>&1) || true
assert_contains "$output" "1/5" "Should show score 1/5"
assert_contains "$output" "bloated" "Should show bloated label"

# Test: dashboard format
echo "Test: dashboard format"
output=$(bash "$SUT" --scope-concrete true --rules 3 --loops 1 --format dashboard 2>&1) || true
assert_contains "$output" "CONTEXT EFFICIENCY" "Should show dashboard header"
assert_contains "$output" "Gauge:" "Should show gauge line"
assert_contains "$output" "Scope:" "Should show scope line"
assert_contains "$output" "Rules:" "Should show rules line"
assert_contains "$output" "Loops:" "Should show loops line"
assert_contains "$output" "Issues:" "Should show issues line"

# Test: decision flow format
echo "Test: decision flow format"
output=$(bash "$SUT" --format decision-flow 2>&1) || true
assert_contains "$output" "SHOULD I START A NEW CHAT?" "Should show decision flow header"
assert_contains "$output" "task scope narrow and concrete" "Should show scope question"
assert_contains "$output" "clarification loops" "Should show loops question"

# Test: recommendation for score 3 with signals
echo "Test: recommendation for score 3 with >=2 signals"
output=$(bash "$SUT" --scope-concrete true --rules 7 --loops 4 --issues "severe latency,quality" --format json 2>&1) || true
assert_contains "$output" "\"score\": 3" "Should have score 3"
assert_contains "$output" "consider-new-chat" "Should suggest considering new chat"

# Summary
echo ""
echo "Tests run: $tests_run"
echo "Tests passed: $tests_passed"

if [ "$tests_run" -eq "$tests_passed" ]; then
  echo "All tests passed!"
  exit 0
else
  echo "Some tests failed."
  exit 1
fi

