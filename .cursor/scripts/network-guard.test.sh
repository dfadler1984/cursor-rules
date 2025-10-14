#!/usr/bin/env bash
# Test: network-guard.sh validator
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"
SUT="$SCRIPT_DIR/network-guard.sh"

echo "[TEST] network-guard.sh"

# Test: --help flag shows usage
test_help_flag() {
  local output
  set +e
  output=$("$SUT" --help 2>&1)
  local status=$?
  set -e
  
  if [ "$status" -ne 0 ]; then
    echo "[FAIL] --help should exit 0" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -q "Usage:"; then
    echo "[FAIL] help should contain Usage" >&2
    return 1
  fi
  
  echo "[PASS] --help shows usage"
}

# Test: detects and reports direct curl usage (informational)
test_detects_curl() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  trap_cleanup "$tmpdir"
  
  # Create script with direct curl
  cat > "$tmpdir/bad-script.sh" <<'SCRIPT'
#!/usr/bin/env bash
curl -X POST https://api.github.com/repos/user/repo/pulls
SCRIPT
  
  local output
  set +e
  output=$("$SUT" --paths "$tmpdir" 2>&1)
  local status=$?
  set -e
  
  # Network-guard is now informational (exits 0)
  if [ "$status" -ne 0 ]; then
    echo "[FAIL] network-guard should exit 0 (informational)" >&2
    echo "$output" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -qi "curl"; then
    echo "[FAIL] should report curl in output" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] detects and reports curl usage"
}

# Test: detects and reports direct gh CLI usage (informational)
test_detects_gh() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  trap_cleanup "$tmpdir"
  
  # Create script with gh CLI
  cat > "$tmpdir/bad-script.sh" <<'SCRIPT'
#!/usr/bin/env bash
gh pr create --title "Test"
SCRIPT
  
  local output
  set +e
  output=$("$SUT" --paths "$tmpdir" 2>&1)
  local status=$?
  set -e
  
  # Network-guard is now informational (exits 0)
  if [ "$status" -ne 0 ]; then
    echo "[FAIL] network-guard should exit 0 (informational)" >&2
    echo "$output" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -qi "gh"; then
    echo "[FAIL] should report gh in output" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] detects and reports gh usage"
}

# Test: allows .lib-net.sh usage
test_allows_lib_net() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  trap_cleanup "$tmpdir"
  
  # Create script using approved seam
  cat > "$tmpdir/good-script.sh" <<'SCRIPT'
#!/usr/bin/env bash
source "$(dirname "$0")/.lib-net.sh"
net_fixture "github/pr-123.json"
SCRIPT
  
  local output
  set +e
  output=$("$SUT" --paths "$tmpdir" 2>&1)
  local status=$?
  set -e
  
  if [ "$status" -ne 0 ]; then
    echo "[FAIL] should allow .lib-net.sh usage" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] allows .lib-net.sh usage"
}

# Test: allows curl in comments
test_allows_comments() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  trap_cleanup "$tmpdir"
  
  # Create script with curl in comment
  cat > "$tmpdir/good-script.sh" <<'SCRIPT'
#!/usr/bin/env bash
# Example: curl -X GET https://example.com
echo "no actual network calls"
SCRIPT
  
  local output
  set +e
  output=$("$SUT" --paths "$tmpdir" 2>&1)
  local status=$?
  set -e
  
  if [ "$status" -ne 0 ]; then
    echo "[FAIL] should allow curl in comments" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] allows curl in comments"
}

# Run all tests
test_help_flag
test_detects_curl
test_detects_gh
test_allows_lib_net
test_allows_comments

echo "[TEST] network-guard.sh: All tests passed"
exit 0

