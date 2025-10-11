#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../" && pwd)"
TRIGGERS_SCRIPT="$ROOT_DIR/docs/projects/assistant-self-improvement/legacy/scripts/alp-triggers.sh"

if [ ! -x "$TRIGGERS_SCRIPT" ]; then
  echo "alp-triggers.sh not executable" >&2
  exit 1
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

export ASSISTANT_LOG_DIR="$tmpdir/logs"
mkdir -p "$ASSISTANT_LOG_DIR"

out="$($TRIGGERS_SCRIPT task-completion "tester" "did a thing" "completed" "note")"

[ -n "$out" ] || { echo "expected output path"; exit 1; }
[ -f "$out" ] || { echo "expected log file to exist"; exit 1; }

exit 0


