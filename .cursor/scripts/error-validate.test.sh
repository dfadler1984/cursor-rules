#!/usr/bin/env bash
# Test: error-validate.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"
SUT="$SCRIPT_DIR/error-validate.sh"

echo "[TEST] error-validate.sh"

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

# Test: detects missing strict mode
test_detects_missing_strict_mode() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  trap_cleanup "$tmpdir"
  
  # Create script without strict mode
  cat > "$tmpdir/bad-script.sh" <<'SCRIPT'
#!/usr/bin/env bash
echo "Hello"
SCRIPT
  
  local output
  set +e
  output=$("$SUT" --paths "$tmpdir" 2>&1)
  local status=$?
  set -e
  
  if [ "$status" -eq 0 ]; then
    echo "[FAIL] should detect missing strict mode" >&2
    echo "$output" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -qi "strict"; then
    echo "[FAIL] should report missing strict mode" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] detects missing strict mode"
}

# Test: allows scripts with proper strict mode
test_allows_strict_mode() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  trap_cleanup "$tmpdir"
  
  # Create script with strict mode
  cat > "$tmpdir/good-script.sh" <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
echo "Hello"
SCRIPT
  
  local output
  set +e
  output=$("$SUT" --paths "$tmpdir" 2>&1)
  local status=$?
  set -e
  
  if [ "$status" -ne 0 ]; then
    echo "[FAIL] should allow proper strict mode" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] allows scripts with proper strict mode"
}

# Test: allows scripts that source .lib.sh
test_allows_lib_sh() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  trap_cleanup "$tmpdir"
  
  # Create script that sources .lib.sh
  cat > "$tmpdir/good-script.sh" <<'SCRIPT'
#!/usr/bin/env bash
source "$(dirname "$0")/.lib.sh"
enable_strict_mode
echo "Hello"
SCRIPT
  
  local output
  set +e
  output=$("$SUT" --paths "$tmpdir" 2>&1)
  local status=$?
  set -e
  
  if [ "$status" -ne 0 ]; then
    echo "[FAIL] should allow scripts that source .lib.sh" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] allows scripts that source .lib.sh"
}

# Test: detects non-standard exit codes
test_detects_nonstandard_exit() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  trap_cleanup "$tmpdir"
  
  # Create script with non-standard exit code
  cat > "$tmpdir/bad-script.sh" <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
if [ "$1" = "bad" ]; then
  echo "Error" >&2
  exit 99
fi
SCRIPT
  
  local output
  set +e
  output=$("$SUT" --paths "$tmpdir" --strict-exit-codes 2>&1)
  local status=$?
  set -e
  
  if [ "$status" -eq 0 ]; then
    echo "[FAIL] should detect non-standard exit code" >&2
    echo "$output" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -qi "exit"; then
    echo "[FAIL] should report non-standard exit" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] detects non-standard exit codes"
}

# Test: excludes test files
test_excludes_test_files() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  trap_cleanup "$tmpdir"
  
  # Create test file without strict mode (should be ignored)
  cat > "$tmpdir/script.test.sh" <<'SCRIPT'
#!/usr/bin/env bash
echo "test"
SCRIPT
  
  local output
  set +e
  output=$("$SUT" --paths "$tmpdir" 2>&1)
  local status=$?
  set -e
  
  if [ "$status" -ne 0 ]; then
    echo "[FAIL] should exclude test files" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] excludes test files"
}

# Run all tests
test_help_flag
test_detects_missing_strict_mode
test_allows_strict_mode
test_allows_lib_sh
test_detects_nonstandard_exit
test_excludes_test_files

echo "[TEST] error-validate.sh: All tests passed"
exit 0

