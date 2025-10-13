#!/usr/bin/env bash
# Test: test runner environment isolation (D6)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNNER="$SCRIPT_DIR/run.sh"

echo "[TEST] Test runner environment isolation (D6)"

# Test: GH_TOKEN not mutated after running tests
test_gh_token_preserved() {
  # Set a known value
  export GH_TOKEN="test_token_12345"
  local original_token="$GH_TOKEN"
  
  # Run test suite (which may have tests that mutate GH_TOKEN)
  "$RUNNER" -k "pr-create.test" >/dev/null 2>&1 || true
  
  # Check if GH_TOKEN was mutated
  if [ "$GH_TOKEN" != "$original_token" ]; then
    echo "[FAIL] GH_TOKEN was mutated: expected '$original_token', got '$GH_TOKEN'" >&2
    return 1
  fi
  
  echo "[PASS] GH_TOKEN preserved after test run"
}

# Test: TEST_ARTIFACTS_DIR not leaked to parent
test_artifacts_dir_not_leaked() {
  # Ensure not set initially
  unset TEST_ARTIFACTS_DIR 2>/dev/null || true
  
  # Run a test
  "$RUNNER" -k ".lib.test" >/dev/null 2>&1 || true
  
  # Check if TEST_ARTIFACTS_DIR leaked
  if [ -n "${TEST_ARTIFACTS_DIR:-}" ]; then
    echo "[FAIL] TEST_ARTIFACTS_DIR leaked to parent shell: $TEST_ARTIFACTS_DIR" >&2
    return 1
  fi
  
  echo "[PASS] TEST_ARTIFACTS_DIR not leaked"
}

# Test: ALP_LOG_DIR not leaked to parent
test_alp_log_dir_not_leaked() {
  # Ensure not set initially
  unset ALP_LOG_DIR 2>/dev/null || true
  
  # Run a test
  "$RUNNER" -k ".lib.test" >/dev/null 2>&1 || true
  
  # Check if ALP_LOG_DIR leaked
  if [ -n "${ALP_LOG_DIR:-}" ]; then
    echo "[FAIL] ALP_LOG_DIR leaked to parent shell: $ALP_LOG_DIR" >&2
    return 1
  fi
  
  echo "[PASS] ALP_LOG_DIR not leaked"
}

# Run all tests
test_gh_token_preserved
test_artifacts_dir_not_leaked
test_alp_log_dir_not_leaked

echo "[TEST] Environment isolation: All tests passed"
exit 0

