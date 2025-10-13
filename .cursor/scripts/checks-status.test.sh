#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUT="$SCRIPT_DIR/checks-status.sh"

echo "[TEST] checks-status.sh"

# Test: script sources .lib-net.sh (network seam)
test_uses_network_seam() {
  if ! grep -q "source.*\.lib-net\.sh" "$SUT"; then
    echo "[FAIL] script should source .lib-net.sh" >&2
    return 1
  fi
  echo "[PASS] uses network seam"
}

# Test: script uses net_guidance (not curl)
test_uses_net_guidance() {
  if ! grep -q "net_guidance" "$SUT"; then
    echo "[FAIL] script should use net_guidance" >&2
    return 1
  fi
  
  # Should NOT have direct curl calls to GitHub API
  if grep -E "^[^#]*curl.*api\.github\.com" "$SUT" >/dev/null 2>&1; then
    echo "[FAIL] script should not make direct curl calls" >&2
    return 1
  fi
  
  echo "[PASS] uses net_guidance instead of curl"
}

# Test: help works
test_help() {
  set +e
  output=$("$SUT" --help 2>&1)
  status=$?
  set -e
  
  if [ "$status" -ne 0 ]; then
    echo "[FAIL] --help should exit 0" >&2
    return 1
  fi
  
  echo "[PASS] help works"
}

# Test: dry-run shows check info
test_dry_run() {
  set +e
  output=$("$SUT" --dry-run 2>&1)
  status=$?
  set -e
  
  if [ "$status" -ne 0 ]; then
    echo "[FAIL] dry-run should exit 0" >&2
    echo "$output" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -qi "check"; then
    echo "[FAIL] dry-run should mention checks" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] dry-run shows check info"
}

# Run all tests
test_uses_network_seam
test_uses_net_guidance
test_help
test_dry_run

echo "[TEST] checks-status.sh: All tests passed"
exit 0


