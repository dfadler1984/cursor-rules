#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Legacy copy of .cursor/scripts/alp-aggregate.test.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../" && pwd)"
SCRIPT="$ROOT_DIR/docs/projects/assistant-self-improvement/legacy/scripts/alp-aggregate.sh"

OUT="$($SCRIPT)"

[ -f "$OUT" ] || { echo "expected summary file"; exit 1; }
grep -q "# Assistant Learning Summary" "$OUT" || { echo "missing header"; exit 1; }

exit 0


