#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUT="$SCRIPT_DIR/changesets-automerge-dispatch.sh"

echo "[TEST] changesets-automerge-dispatch.sh"

# Test: help flag works
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

# Test: dry-run prints guidance without network
test_dry_run() {
  set +e
  output=$("$SUT" --repo owner/repo --pr 123 --ref main --dry-run 2>&1)
  status=$?
  set -e
  
  if [ "$status" -ne 0 ]; then
    echo "[FAIL] dry-run should exit 0" >&2
    echo "$output" >&2
    return 1
  fi
  
  # Should mention the workflow and PR
  if ! echo "$output" | grep -qi "changesets"; then
    echo "[FAIL] dry-run should mention changesets workflow" >&2
    echo "$output" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -q "123"; then
    echo "[FAIL] dry-run should include PR number" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] dry-run provides guidance"
}

# Test: missing required arguments fails
test_missing_args() {
  set +e
  output=$("$SUT" --repo owner/repo 2>&1)
  status=$?
  set -e
  
  if [ "$status" -eq 0 ]; then
    echo "[FAIL] should fail when PR is missing" >&2
    return 1
  fi
  
  echo "[PASS] validates required arguments"
}

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
  
  # Should NOT have direct curl calls (except in comments/examples)
  if grep -E "^[^#]*\bcurl\s" "$SUT" >/dev/null 2>&1; then
    echo "[FAIL] script should not make direct curl calls" >&2
    return 1
  fi
  
  echo "[PASS] uses net_guidance instead of curl"
}

# Run all tests
test_help
test_dry_run
test_missing_args
test_uses_network_seam
test_uses_net_guidance

echo "[TEST] changesets-automerge-dispatch.sh: All tests passed"
exit 0

