#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/git-commit.sh"

# 1) Help exists
out="$({ bash "$SCRIPT" --help || true; } 2>&1)"
printf '%s' "$out" | grep -q "Usage:" || { echo "help missing Usage"; exit 1; }

# 2) Valid dry-run prints expected header
out="$(bash "$SCRIPT" --type feat --scope core --description "add thing" --dry-run)"
first_line="$(printf '%s' "$out" | head -n 1)"
[ "$first_line" = "feat(core): add thing" ] || { echo "bad header: $first_line"; exit 1; }

# 3) Invalid type fails
if bash "$SCRIPT" --type unknown --description "x" --dry-run >/dev/null 2>&1; then
  echo "expected invalid type to fail"; exit 1
fi

# 4) Header length guard
# 64 chars desc + 'feat: ' (6) = 70, ok; + 3 more -> 73, should fail
ok_desc="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
ok_desc="${ok_desc:0:64}"

bash "$SCRIPT" --type feat --description "$ok_desc" --dry-run >/dev/null

too_long="${ok_desc}aaa"
if bash "$SCRIPT" --type feat --description "$too_long" --dry-run >/dev/null 2>&1; then
  echo "expected header length to fail"; exit 1
fi

# 5) Breaking change adds '!' and footer in dry-run
out="$(bash "$SCRIPT" --type fix --description "bug" --breaking "api" --dry-run)"
first_line="$(printf '%s' "$out" | head -n 1)"
printf '%s' "$first_line" | grep -q '^fix!: bug$' || { echo "missing ! in header"; exit 1; }
printf '%s' "$out" | grep -q '^BREAKING CHANGE: api$' || { echo "missing breaking footer"; exit 1; }

exit 0
