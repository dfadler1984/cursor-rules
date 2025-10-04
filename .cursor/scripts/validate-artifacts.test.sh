#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/validate-artifacts.sh"

INVALID_SPEC="$ROOT_DIR/.cursor/scripts/tests/fixtures/validator-spec/invalid-feature-spec.md"

set +e
out="$($SCRIPT --paths "$INVALID_SPEC" 2>&1)"
status=$?
set -e

[ $status -ne 0 ] || { echo "expected non-zero exit for missing headings"; echo "$out"; exit 1; }
echo "$out" | grep -q "missing required heading: Acceptance Criteria" || { echo "missing expected error message"; echo "$out"; exit 1; }

exit 0

