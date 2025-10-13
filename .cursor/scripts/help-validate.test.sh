#!/usr/bin/env bash
# Test: help-validate.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUT="$SCRIPT_DIR/help-validate.sh"

echo "[TEST] help-validate.sh"

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

# Test: detects missing --help flag
test_detects_missing_help() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  trap "rm -rf '$tmpdir'" EXIT
  
  # Create script without --help
  cat > "$tmpdir/bad-script.sh" <<'SCRIPT'
#!/usr/bin/env bash
echo "Hello"
SCRIPT
  chmod +x "$tmpdir/bad-script.sh"
  
  local output
  set +e
  output=$("$SUT" --paths "$tmpdir" 2>&1)
  local status=$?
  set -e
  
  if [ "$status" -eq 0 ]; then
    echo "[FAIL] should detect missing --help" >&2
    echo "$output" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -qi "help"; then
    echo "[FAIL] should report missing help" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] detects missing --help flag"
}

# Test: detects missing exit codes section
test_detects_missing_exit_codes() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  trap "rm -rf '$tmpdir'" EXIT
  
  # Create script with help but no exit codes
  cat > "$tmpdir/bad-script.sh" <<'SCRIPT'
#!/usr/bin/env bash
usage() {
  cat <<EOF
Usage: bad-script.sh [OPTIONS]

Options:
  -h, --help    Show help
EOF
}

case "$1" in
  -h|--help) usage; exit 0 ;;
  *) echo "Hello" ;;
esac
SCRIPT
  chmod +x "$tmpdir/bad-script.sh"
  
  local output
  set +e
  output=$("$SUT" --paths "$tmpdir" 2>&1)
  local status=$?
  set -e
  
  if [ "$status" -eq 0 ]; then
    echo "[FAIL] should detect missing Exit Codes section" >&2
    echo "$output" >&2
    return 1
  fi
  
  if ! echo "$output" | grep -qi "exit.*code"; then
    echo "[FAIL] should report missing exit codes" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] detects missing Exit Codes section"
}

# Test: validates complete help passes
test_complete_help_passes() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  trap "rm -rf '$tmpdir'" EXIT
  
  # Create script with complete help
  cat > "$tmpdir/good-script.sh" <<'SCRIPT'
#!/usr/bin/env bash
usage() {
  cat <<EOF
good-script.sh (v1.0.0)

Usage: good-script.sh [OPTIONS]

Options:
  -h, --help    Show help
  --version     Show version

Examples:
  $ good-script.sh

Exit Codes:
  0   Success
  1   Error
EOF
}

case "$1" in
  -h|--help) usage; exit 0 ;;
  --version) echo "1.0.0"; exit 0 ;;
  *) echo "Hello" ;;
esac
SCRIPT
  chmod +x "$tmpdir/good-script.sh"
  
  local output
  set +e
  output=$("$SUT" --paths "$tmpdir" 2>&1)
  local status=$?
  set -e
  
  if [ "$status" -ne 0 ]; then
    echo "[FAIL] complete help should pass validation" >&2
    echo "$output" >&2
    return 1
  fi
  
  echo "[PASS] complete help passes validation"
}

# Test: excludes test files
test_excludes_test_files() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  trap "rm -rf '$tmpdir'" EXIT
  
  # Create test file without help (should be ignored)
  cat > "$tmpdir/script.test.sh" <<'SCRIPT'
#!/usr/bin/env bash
echo "test"
SCRIPT
  chmod +x "$tmpdir/script.test.sh"
  
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
test_detects_missing_help
test_detects_missing_exit_codes
test_complete_help_passes
test_excludes_test_files

echo "[TEST] help-validate.sh: All tests passed"
exit 0

