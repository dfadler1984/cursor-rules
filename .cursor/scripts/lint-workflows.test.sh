#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/lint-workflows.sh"

# 1) No workflows directory -> no-op
rm -rf "$ROOT_DIR/.github" || true
out="$(bash "$SCRIPT" 2>&1)"
printf '%s' "$out" | grep -qi "nothing to lint" || { echo "expected no-op message"; exit 1; }

# 2) With workflows but missing actionlint -> exit 1
mkdir -p "$ROOT_DIR/.github/workflows"
if bash "$SCRIPT" >/dev/null 2>&1; then
  echo "expected missing actionlint to fail"; exit 1
fi

exit 0
