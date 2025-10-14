#!/usr/bin/env bash
# Test: shellcheck-run.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"
SUT="$SCRIPT_DIR/shellcheck-run.sh"

echo "[TEST] shellcheck-run.sh"

# Test: --help flag shows usage
test_help_flag() {
  local output
  set +e
  output=$("$SUT" --help 2>&1)
  local status=$?
  set -e
  
  if [ "$status" -ne 0 ]; then
    echo "[FAIL] --help should exit 0, got $status" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -q "Usage:"; then
    echo "[FAIL] help should contain Usage section" >&2
    echo "$output" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -q "Exit Codes:"; then
    echo "[FAIL] help should contain Exit Codes section" >&2
    echo "$output" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -q "Examples:"; then
    echo "[FAIL] help should contain Examples section" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] --help shows complete usage"
}

# Test: --version flag shows version
test_version_flag() {
  local output
  set +e
  output=$("$SUT" --version 2>&1)
  local status=$?
  set -e
  
  if [ "$status" -ne 0 ]; then
    echo "[FAIL] --version should exit 0, got $status" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -qE '[0-9]+\.[0-9]+\.[0-9]+'; then
    echo "[FAIL] version should match semver format" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] --version shows version"
}

# Test: graceful degradation when shellcheck missing (portability guarantee)
test_missing_shellcheck_exits_zero() {
  # Create a temp PATH that has essential tools but not shellcheck
  # Keep /usr/bin and /bin for basic tools, but exclude shellcheck location
  local safe_path="/usr/bin:/bin"
  local output
  set +e
  output=$(PATH="$safe_path" "$SUT" --paths /tmp 2>&1)
  local status=$?
  set -e
  
  if [ "$status" -ne 0 ]; then
    echo "[FAIL] should exit 0 when shellcheck missing (portability), got $status" >&2
    echo "$output" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -qi "shellcheck not found"; then
    echo "[FAIL] should warn when shellcheck missing" >&2
    echo "$output" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -qi "install"; then
    echo "[FAIL] should provide install guidance" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] exits 0 when shellcheck missing (portability guarantee)"
}

# Test: handles no scripts found gracefully
test_no_scripts_found() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  trap_cleanup "$tmpdir"
  
  local safe_path="/usr/bin:/bin"
  local output
  set +e
  output=$(PATH="$safe_path" "$SUT" --paths "$tmpdir" 2>&1)
  local status=$?
  set -e
  
  if [ "$status" -ne 0 ]; then
    echo "[FAIL] should exit 0 when no scripts found, got $status" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] handles no scripts gracefully"
}

# Test: invalid argument handling
test_invalid_argument() {
  local output
  set +e
  output=$("$SUT" --invalid-flag 2>&1)
  local status=$?
  set -e
  
  if [ "$status" -eq 0 ]; then
    echo "[FAIL] should exit non-zero for invalid argument" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -qi "unknown"; then
    echo "[FAIL] should report unknown argument" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] rejects invalid arguments"
}

# Run all tests
test_help_flag
test_version_flag
test_missing_shellcheck_exits_zero
test_no_scripts_found
test_invalid_argument

echo "[TEST] shellcheck-run.sh: All tests passed"
exit 0

