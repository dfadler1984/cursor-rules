#!/usr/bin/env bash
# Test: .lib-net.sh network effects seam
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the library under test
# shellcheck disable=SC1090
source "$SCRIPT_DIR/.lib-net.sh"

echo "[TEST] .lib-net.sh — Network effects seam"

# Test: net_request always dies with EXIT_NETWORK (never performs HTTP)
test_net_request_dies() {
  # Run in subshell to capture exit without killing test
  set +e
  (net_request GET "https://example.com") >/dev/null 2>&1
  local status=$?
  set -e
  
  if [ "$status" -ne "$EXIT_NETWORK" ]; then
    echo "[FAIL] net_request should exit with EXIT_NETWORK ($EXIT_NETWORK), got $status" >&2
    return 1
  fi
  echo "[PASS] net_request dies with EXIT_NETWORK"
}

# Test: net_fixture loads fixture files correctly
test_net_fixture_loads() {
  local output
  output=$(net_fixture "github/pr-123.json")
  
  if ! echo "$output" | grep -q '"number": 123'; then
    echo "[FAIL] fixture should contain PR number" >&2
    echo "$output" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -q '"state": "open"'; then
    echo "[FAIL] fixture should contain PR state" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] net_fixture loads fixtures correctly"
}

# Test: net_fixture fails on missing fixture
test_net_fixture_missing() {
  # Run in subshell to capture exit without killing test
  set +e
  (net_fixture "nonexistent/fixture.json") >/dev/null 2>&1
  local status=$?
  set -e
  
  if [ "$status" -ne "$EXIT_CONFIG" ]; then
    echo "[FAIL] missing fixture should exit with EXIT_CONFIG ($EXIT_CONFIG), got $status" >&2
    return 1
  fi
  echo "[PASS] net_fixture fails on missing fixture"
}

# Test: net_guidance prints without side effects
test_net_guidance() {
  local output
  output=$(net_guidance "Create PR" "https://github.com/user/repo/compare" 2>&1)
  
  if ! echo "$output" | grep -q "Create PR"; then
    echo "[FAIL] guidance should contain description" >&2
    echo "$output" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -q "https://github.com/user/repo/compare"; then
    echo "[FAIL] guidance should contain URL" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] net_guidance prints actionable guidance"
}

# Test: is_dry_run detects DRY_RUN flag
test_is_dry_run() {
  # Test when not set
  if is_dry_run; then
    echo "[FAIL] is_dry_run should return false when DRY_RUN not set" >&2
    return 1
  fi
  
  # Test when set to 1
  DRY_RUN=1
  if ! is_dry_run; then
    echo "[FAIL] is_dry_run should return true when DRY_RUN=1" >&2
    return 1
  fi
  unset DRY_RUN
  
  echo "[PASS] is_dry_run detects dry-run mode"
}

# Run all tests
test_net_request_dies
test_net_fixture_loads
test_net_fixture_missing
test_net_guidance
test_is_dry_run

echo "[TEST] .lib-net.sh: All tests passed"
exit 0

