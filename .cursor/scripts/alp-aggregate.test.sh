#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/alp-aggregate.sh"

OUT="$($SCRIPT)"

[ -f "$OUT" ] || { echo "expected summary file"; exit 1; }
grep -q "# Assistant Learning Summary" "$OUT" || { echo "missing header"; exit 1; }

exit 0


