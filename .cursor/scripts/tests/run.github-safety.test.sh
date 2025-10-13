#!/usr/bin/env bash
# Test: verify .github directory safety (D6 / tests-github-deletion)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[TEST] .github directory safety"

# Test: .github directory exists before and after running tests
test_github_not_deleted() {
  if [ ! -d "$ROOT_DIR/.github" ]; then
    echo "[FAIL] .github directory missing before test" >&2
    return 1
  fi
  
  local workflows_before
  workflows_before=$(find "$ROOT_DIR/.github/workflows" -name "*.yml" 2>/dev/null | wc -l)
  
  if [ "$workflows_before" -eq 0 ]; then
    echo "[FAIL] No workflows found before test" >&2
    return 1
  fi
  
  # Run a sample test (not full suite to keep this fast)
  "$SCRIPT_DIR/run.sh" -k ".lib.test" >/dev/null 2>&1 || true
  
  if [ ! -d "$ROOT_DIR/.github" ]; then
    echo "[FAIL] .github directory was deleted by test run" >&2
    return 1
  fi
  
  local workflows_after
  workflows_after=$(find "$ROOT_DIR/.github/workflows" -name "*.yml" 2>/dev/null | wc -l)
  
  if [ "$workflows_after" -ne "$workflows_before" ]; then
    echo "[FAIL] Workflow count changed: $workflows_before → $workflows_after" >&2
    return 1
  fi
  
  echo "[PASS] .github directory preserved ($workflows_after workflows)"
}

test_github_not_deleted
echo "[TEST] .github safety: All tests passed"
exit 0

