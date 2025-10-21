#!/usr/bin/env bash
# Tests for validate-investigation-structure.sh
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/validate-investigation-structure.sh"

# Test: requires project path argument
set +e
out=$("$SCRIPT" 2>&1)
status=$?
set -e

[ $status -ne 0 ] || { echo "FAIL: should fail without project path"; exit 1; }
echo "$out" | grep -qE "Error.*project.*required" || { echo "FAIL: should show error for missing path"; exit 1; }

# Test: validates actual project structure
set +e
out=$("$SCRIPT" docs/projects/rules-enforcement-investigation 2>&1)
status=$?
set -e

# Should pass (structure was reorganized)
[ $status -eq 0 ] || { echo "FAIL: reorganized project should pass validation"; echo "$out"; exit 1; }
echo "$out" | grep -q "Structure valid" || { echo "FAIL: should report structure valid"; exit 1; }

echo "All tests passed"
exit 0

