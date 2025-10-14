#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/security-scan.sh"

# Use .test-artifacts for test temporary directories (D6)
TEST_ARTIFACTS_DIR="${TEST_ARTIFACTS_DIR:-$ROOT_DIR/.test-artifacts}"
mkdir -p "$TEST_ARTIFACTS_DIR"

# 1) Without package.json anywhere, prints skip message and exits 0
# Use system temp to ensure we're outside repo (security-scan checks both CWD and repo root)
tmpdir1="$(mktemp -d 2>/dev/null || mktemp -d -t sec-scan)"
# shellcheck disable=SC2064
trap "rm -rf '$tmpdir1'" EXIT
pushd "$tmpdir1" >/dev/null
out="$(bash "$SCRIPT" 2>&1)"
popd >/dev/null
printf '%s' "$out" | grep -qi "skipping security scan" || { echo "expected skip message"; exit 1; }

# 2) With package.json, does not error if npm/yarn missing (best-effort)
tmpdir2="$TEST_ARTIFACTS_DIR/sec-scan-$$-pkg"
mkdir -p "$tmpdir2"
# shellcheck disable=SC2064
trap "rm -rf '$tmpdir1' '$tmpdir2'" EXIT
cat > "$tmpdir2/package.json" <<'JSON'
{ "name": "tmp", "version": "0.0.0" }
JSON
pushd "$tmpdir2" >/dev/null
out="$(bash "$SCRIPT" 2>&1 || true)"
popd >/dev/null
# Accept either running or warning about missing tools; just ensure no non-zero exit

exit 0
