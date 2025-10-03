#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/alp-triggers.sh"

OUT="$($SCRIPT tdd-fix senior-engineer "Fixed failing owner spec" "Added spec then fix" "Prefer declarative checks" "deterministic-outputs.mdc" "docs/specs/example.md#case")"

# Normalize to absolute path
if [[ "$OUT" = /* ]]; then
  ABS="$OUT"
else
  STRIPPED="${OUT#./}"
  ABS="$ROOT_DIR/$STRIPPED"
fi

[ -f "$ABS" ] || { echo "expected a file to be written at $ABS"; exit 1; }

grep -q "Problem: Fixed failing owner spec" "$ABS" || { echo "missing problem"; exit 1; }
grep -q "Rule candidate: deterministic-outputs.mdc" "$ABS" || { echo "missing rule"; exit 1; }

exit 0


