#!/usr/bin/env bash
# Test: deep-rule-and-command-validate.sh
# Owner: .cursor/scripts/deep-rule-and-command-validate.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_UNDER_TEST="$SCRIPT_DIR/deep-rule-and-command-validate.sh"

echo "[TEST] deep-rule-and-command-validate.sh — Deep validation orchestrator"

# Test 1: Script exists and is executable
test_script_exists() {
  if [ ! -f "$SCRIPT_UNDER_TEST" ]; then
    echo "[FAIL] Script should exist at $SCRIPT_UNDER_TEST" >&2
    return 1
  fi
  
  if [ ! -x "$SCRIPT_UNDER_TEST" ]; then
    echo "[FAIL] Script should be executable" >&2
    return 1
  fi
  
  echo "[PASS] Script exists and is executable"
}

# Test 2: --help flag works
test_help_flag() {
  local output
  output=$("$SCRIPT_UNDER_TEST" --help 2>&1 || true)
  
  if ! echo "$output" | grep -q "Usage:"; then
    echo "[FAIL] Help should show usage" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -q "deep-rule-and-command-validate"; then
    echo "[FAIL] Help should mention script name" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -q "\-\-fix"; then
    echo "[FAIL] Help should document --fix flag" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -q "\-\-report"; then
    echo "[FAIL] Help should document --report flag" >&2
    return 1
  fi
  
  echo "[PASS] --help flag works"
}

# Test 3: Exits 0 when validation completes
test_exit_code_success() {
  # Even with validation warnings/failures, should exit 0
  # (only exit non-zero if validation itself cannot run)
  local output
  output=$("$SCRIPT_UNDER_TEST" 2>&1)
  local exit_code=$?
  
  if [ "$exit_code" -ne 0 ]; then
    echo "[FAIL] Should exit 0 when validation completes (got exit code $exit_code)" >&2
    echo "Output: $output" >&2
    return 1
  fi
  
  echo "[PASS] Exits 0 on completed validation"
}

# Test 4: Runs multiple validators
test_orchestrates_validators() {
  local output
  output=$("$SCRIPT_UNDER_TEST" 2>&1)
  
  if ! echo "$output" | grep -q "Rules validation"; then
    echo "[FAIL] Should run rules validator" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -q "Capabilities sync"; then
    echo "[FAIL] Should check capabilities" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -q "Health Score"; then
    echo "[FAIL] Should calculate health score" >&2
    return 1
  fi
  
  echo "[PASS] Orchestrates multiple validators"
}

# Test 5: Displays health score
test_displays_health_score() {
  local output
  output=$("$SCRIPT_UNDER_TEST" 2>&1)
  
  if ! echo "$output" | grep -q "Overall Health Score:"; then
    echo "[FAIL] Should show overall score" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -q "/100"; then
    echo "[FAIL] Score should be out of 100" >&2
    return 1
  fi
  
  echo "[PASS] Displays health score"
}

# Run tests
test_script_exists
test_help_flag
test_exit_code_success
test_orchestrates_validators
test_displays_health_score

echo "✓ All tests passed"

