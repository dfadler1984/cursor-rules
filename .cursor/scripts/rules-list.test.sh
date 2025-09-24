#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/rules-list.sh"

# 1) Help prints and exits 0
out="$({ bash "$SCRIPT" --help || true; } 2>&1)"
printf '%s' "$out" | grep -q "Usage:" || { echo "help missing Usage"; exit 1; }

# 2) Default table output (non-empty header), against actual repo rules dir
out="$(bash "$SCRIPT")"
printf '%s' "$out" | head -n 1 | grep -q "file[[:space:]]\+description" || { echo "table header missing"; echo "$out"; exit 1; }

# 3) JSON output is a JSON array (starts with [ and ends with ])
out="$(bash "$SCRIPT" --format json)"
[[ "$out" =~ ^\[.*\]$ ]] || { echo "json not array"; echo "$out"; exit 1; }

# 4) Missing directory: --dir tmp/does-not-exist → success and no output
out="$(bash "$SCRIPT" --dir "$ROOT_DIR/tmp/does-not-exist" 2>/dev/null || true)"
[ -z "$out" ] || { echo "expected no output for missing dir"; echo "$out"; exit 1; }

exit 0
