#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/lint-workflows.sh"

# CRITICAL FIX (D6): DO NOT delete .github from repo!
# Previous version had: rm -rf "$ROOT_DIR/.github"
# This destroyed the actual .github directory every test run.

# Test: --help works
out="$("$SCRIPT" --help 2>&1)"
printf '%s' "$out" | grep -qi "usage" || { echo "expected usage in help"; exit 1; }

# Test: script handles missing .github/workflows gracefully
# Use a temp directory instead of destroying repo .github
tmpdir="$(mktemp -d 2>/dev/null || mktemp -d -t lint-wf-test)"
trap "rm -rf '$tmpdir'" EXIT

pushd "$tmpdir" >/dev/null
out="$(bash "$SCRIPT" 2>&1)"
popd >/dev/null
printf '%s' "$out" | grep -qi "nothing to lint" || { echo "expected no-op message when no workflows"; exit 1; }

exit 0
