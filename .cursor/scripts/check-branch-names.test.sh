#!/usr/bin/env bash
# Test: check-branch-names.sh
# Owner spec for branch naming compliance checker

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUT="$SCRIPT_DIR/check-branch-names.sh"

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
  assert_output_contains "check-branch-names" "$output" "Help shows script name"
  assert_output_contains "Usage:" "$output" "Help shows usage"
}

# Test: Outputs branch naming compliance rate
test_outputs_compliance_rate() {
  local output
  output=$("$SUT" 2>&1 || true)
  assert_output_contains "Branch naming compliance:" "$output" "Outputs compliance rate"
  assert_output_contains "%" "$output" "Rate shown as percentage"
}

# Test: Outputs branch counts
test_outputs_branch_counts() {
  local output
  output=$("$SUT" 2>&1 || true)
  assert_output_contains "Compliant branches:" "$output" "Shows compliant count"
  assert_output_contains "Total branches:" "$output" "Shows total branches"
}

# Test: Exits 0 on success
test_exits_zero_on_success() {
  "$SUT" >/dev/null 2>&1
  assert_exit_code 0 $? "Exits 0 on successful analysis"
}

# Run all tests
echo "Testing check-branch-names.sh..."
echo

test_script_exists
test_help_output
test_outputs_compliance_rate
test_outputs_branch_counts
test_exits_zero_on_success

echo
echo "All tests passed!"

