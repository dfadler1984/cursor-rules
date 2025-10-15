#!/usr/bin/env bash
# Test: check-script-usage.sh
# Owner spec for script usage compliance checker

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUT="$SCRIPT_DIR/check-script-usage.sh"

# Test helper
assert_exit_code() {
  local expected=$1
  local actual=$2
  local desc=$3
  if [[ "$actual" -ne "$expected" ]]; then
    echo "FAIL: $desc (expected exit $expected, got $actual)"
    return 1
  fi
  echo "PASS: $desc"
}

assert_output_contains() {
  local pattern=$1
  local output=$2
  local desc=$3
  if ! echo "$output" | grep -q "$pattern"; then
    echo "FAIL: $desc (pattern '$pattern' not found)"
    return 1
  fi
  echo "PASS: $desc"
}

# Test: Script exists and is executable
test_script_exists() {
  if [[ ! -f "$SUT" ]]; then
    echo "FAIL: Script does not exist: $SUT"
    return 1
  fi
  if [[ ! -x "$SUT" ]]; then
    echo "FAIL: Script is not executable: $SUT"
    return 1
  fi
  echo "PASS: Script exists and is executable"
}

# Test: Help output
test_help_output() {
  local output
  output=$("$SUT" --help 2>&1 || true)
  assert_output_contains "check-script-usage" "$output" "Help shows script name"
  assert_output_contains "Usage:" "$output" "Help shows usage"
}

# Test: Outputs script usage rate
test_outputs_usage_rate() {
  local output
  output=$("$SUT" --limit 10 2>&1 || true)
  assert_output_contains "Script usage rate:" "$output" "Outputs usage rate"
  assert_output_contains "%" "$output" "Rate shown as percentage"
}

# Test: Outputs conventional commit counts
test_outputs_commit_counts() {
  local output
  output=$("$SUT" --limit 10 2>&1 || true)
  assert_output_contains "Conventional commits:" "$output" "Shows conventional count"
  assert_output_contains "Non-conventional commits:" "$output" "Shows non-conventional count"
}

# Test: Exits 0 on success
test_exits_zero_on_success() {
  "$SUT" --limit 10 >/dev/null 2>&1
  assert_exit_code 0 $? "Exits 0 on successful analysis"
}

# Test: Handles --limit flag
test_limit_flag() {
  local output
  output=$("$SUT" --limit 5 2>&1 || true)
  # Should analyze 5 commits max
  assert_output_contains "Script usage rate:" "$output" "Works with --limit flag"
}

# Run all tests
echo "Testing check-script-usage.sh..."
echo

test_script_exists
test_help_output
test_outputs_usage_rate
test_outputs_commit_counts
test_exits_zero_on_success
test_limit_flag

echo
echo "All tests passed!"

