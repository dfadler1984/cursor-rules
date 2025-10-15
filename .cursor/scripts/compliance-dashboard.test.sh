#!/usr/bin/env bash
# Test: compliance-dashboard.sh
# Owner spec for compliance dashboard aggregator

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUT="$SCRIPT_DIR/compliance-dashboard.sh"

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
  assert_output_contains "compliance-dashboard" "$output" "Help shows script name"
  assert_output_contains "Usage:" "$output" "Help shows usage"
}

# Test: Outputs dashboard header
test_outputs_dashboard() {
  local output
  output=$("$SUT" --limit 10 2>&1 || true)
  assert_output_contains "COMPLIANCE DASHBOARD" "$output" "Shows dashboard header"
  assert_output_contains "Generated:" "$output" "Shows generation timestamp"
}

# Test: Includes all metrics
test_includes_all_metrics() {
  local output
  output=$("$SUT" --limit 10 2>&1 || true)
  assert_output_contains "Script Usage" "$output" "Includes script usage metric"
  assert_output_contains "TDD Compliance" "$output" "Includes TDD metric"
  assert_output_contains "Branch Naming" "$output" "Includes branch naming metric"
}

# Test: Shows overall compliance score
test_overall_score() {
  local output
  output=$("$SUT" --limit 10 2>&1 || true)
  assert_output_contains "Overall Compliance Score:" "$output" "Shows overall score"
  assert_output_contains "%" "$output" "Score shown as percentage"
}

# Test: Exits 0 on success
test_exits_zero_on_success() {
  "$SUT" --limit 10 >/dev/null 2>&1
  assert_exit_code 0 $? "Exits 0 on successful dashboard generation"
}

# Run all tests
echo "Testing compliance-dashboard.sh..."
echo

test_script_exists
test_help_output
test_outputs_dashboard
test_includes_all_metrics
test_overall_score
test_exits_zero_on_success

echo
echo "All tests passed!"

