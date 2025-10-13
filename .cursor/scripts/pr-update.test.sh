#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUT="$SCRIPT_DIR/pr-update.sh"

echo "[TEST] pr-update.sh"

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
    echo "[FAIL] script should use net_guidance for network operations" >&2
    return 1
  fi
  
  # Should NOT have direct curl calls to GitHub API (excluding comments)
  if grep -E "^[^#]*curl.*api\.github\.com" "$SUT" >/dev/null 2>&1; then
    echo "[FAIL] script should not make direct curl calls to GitHub API" >&2
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

# Test: dry-run shows what would be updated
test_dry_run() {
  set +e
  output=$("$SUT" --pr 123 --title "New Title" --dry-run 2>&1)
  status=$?
  set -e
  
  if [ "$status" -ne 0 ]; then
    echo "[FAIL] dry-run should exit 0" >&2
    echo "$output" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -q "123"; then
    echo "[FAIL] dry-run should mention PR number" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] dry-run shows update info"
}

# Test: requires at least title or body
test_validates_args() {
  set +e
  output=$("$SUT" --pr 1 --dry-run 2>&1)
  status=$?
  set -e
  
  if [ "$status" -eq 0 ]; then
    echo "[FAIL] should fail when no fields provided" >&2
    return 1
  fi
  
  echo "[PASS] validates required arguments"
}

# Run all tests
test_uses_network_seam
test_uses_net_guidance
test_help
test_dry_run
test_validates_args

echo "[TEST] pr-update.sh: All tests passed"
exit 0


