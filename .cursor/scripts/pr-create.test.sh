#!/usr/bin/env bash
# Test: pr-create.sh (networkless version)
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUT="$SCRIPT_DIR/pr-create.sh"
TEMPLATE_FILE="$SCRIPT_DIR/../../.github/pull_request_template.md"

echo "[TEST] pr-create.sh"

# Test: script sources .lib-net.sh
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
    echo "[FAIL] script should not make direct curl calls to GitHub API" >&2
    return 1
  fi
  
  echo "[PASS] uses net_guidance instead of curl"
}

# Test: dry-run works without token
test_dry_run_no_token() {
  set +e
  output=$("$SUT" --title "Test PR" --owner test --repo repo --base main --head feat --dry-run 2>&1)
  status=$?
  set -e
  
  if [ "$status" -ne 0 ]; then
    echo "[FAIL] dry-run should work without token" >&2
    echo "$output" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -q "Test PR"; then
    echo "[FAIL] dry-run should include title" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] dry-run works without token"
}

# Test: non-dry-run provides guidance (no token required)
test_provides_guidance() {
  set +e
  output=$("$SUT" --title "Test PR" --owner test --repo repo --base main --head feat 2>&1)
  status=$?
  set -e
  
  if [ "$status" -ne 0 ]; then
    echo "[FAIL] should exit 0 and provide guidance" >&2
    echo "$output" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -qi "compare"; then
    echo "[FAIL] should provide compare URL" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] provides guidance without requiring token"
}

# Test: --no-template bypasses template injection in dry-run
test_no_template() {
  if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "[SKIP] no template file to test"
    return 0
  fi
  
  set +e
  output=$("$SUT" --title "No Template" --owner o --repo r --base main --head feat --no-template --body "Plain" --dry-run 2>&1)
  status=$?
  set -e
  
  if [ "$status" -ne 0 ]; then
    echo "[FAIL] --no-template dry-run should work" >&2
    echo "$output" >&2
    return 1
  fi
  
  if echo "$output" | grep -q "## Summary"; then
    echo "[FAIL] --no-template should skip template" >&2
    return 1
  fi
  
  echo "[PASS] --no-template bypasses injection"
}

# Test: labels are noted in guidance
test_labels_noted() {
  set +e
  output=$("$SUT" --title "With Labels" --owner o --repo r --base main --head feat --label "test-label" --docs-only 2>&1)
  status=$?
  set -e
  
  if [ "$status" -ne 0 ]; then
    echo "[FAIL] labels should be accepted" >&2
    echo "$output" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -q "test-label"; then
    echo "[FAIL] guidance should mention labels" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] labels noted in guidance"
}

# Run all tests
test_uses_network_seam
test_uses_net_guidance
test_dry_run_no_token
test_provides_guidance
test_no_template
test_labels_noted

echo "[TEST] pr-create.sh: All tests passed"
exit 0
