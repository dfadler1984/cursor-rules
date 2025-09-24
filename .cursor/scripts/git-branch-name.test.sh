#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/git-branch-name.sh"

export GIT_LOGIN="tester"

# 1) Suggest default feat without feature
out="$(bash "$SCRIPT" --task "add-thing")"
[ "$out" = "tester/feat-add-thing" ] || { echo "bad suggest: $out"; exit 1; }

# 2) Suggest with feature and type
out="$(bash "$SCRIPT" --task "bug" --feature "accounts" --type fix)"
[ "$out" = "tester/fix-accounts-bug" ] || { echo "bad suggest with feature: $out"; exit 1; }

# 3) Invalid type fails
if bash "$SCRIPT" --task x --type unknown >/dev/null 2>&1; then
  echo "expected invalid type to fail"; exit 1
fi

# 4) Non-kebab task fails
if bash "$SCRIPT" --task "NotKebab" >/dev/null 2>&1; then
  echo "expected non-kebab task to fail"; exit 1
fi

# 5) Non-kebab feature fails
if bash "$SCRIPT" --task a --feature "NotKebab" >/dev/null 2>&1; then
  echo "expected non-kebab feature to fail"; exit 1
fi

exit 0
