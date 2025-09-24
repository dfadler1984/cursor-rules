#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/pr-create.sh"

# 1) Dry-run prints JSON with required keys
export GITHUB_TOKEN="dummy"
# Fake git environment by running outside a git repo? We rely on origin; skip derivation by setting owner/repo/head.
out="$(bash "$SCRIPT" --title "Add feature" --body "Body" --owner o --repo r --base main --head feat --dry-run)"
printf '%s' "$out" | grep -q '"title"' || { echo "payload missing title"; exit 1; }
printf '%s' "$out" | grep -q '"base"' || { echo "payload missing base"; exit 1; }
printf '%s' "$out" | grep -q '"head"' || { echo "payload missing head"; exit 1; }

# 2) Missing token when not dry-run should error before curl
unset GITHUB_TOKEN || true
if bash "$SCRIPT" --title t --owner o --repo r --base b --head h >/dev/null 2>&1; then
  echo "expected missing token to fail"; exit 1
fi

exit 0
