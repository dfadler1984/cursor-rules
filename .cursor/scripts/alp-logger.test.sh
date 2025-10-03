#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/alp-logger.sh"

# 1) build-filename with fixed time
out="$($SCRIPT build-filename summary --at "2025-10-01T17:03:00Z")"
[ "$out" = "log-2025-10-01T17-03-00Z-summary.md" ] || { echo "bad filename: $out"; exit 1; }

# 2) write-local creates file atomically
TMP_DIR="$ROOT_DIR/docs/assistant-learning-logs/spec-sh"
rm -rf "$TMP_DIR" || true
PATH_FILE="$TMP_DIR/log-TEST.md"
$SCRIPT write-local "$PATH_FILE" "hello"
[ -f "$PATH_FILE" ] || { echo "file not created"; exit 1; }
[ "$(cat "$PATH_FILE")" = "hello" ] || { echo "bad content"; exit 1; }

# 3) is-writable check
$SCRIPT is-writable "$TMP_DIR"

# 4) write-with-fallback when primary dir is not writable
PRIMARY="/root/deny/log-test.md" # likely unwritable on macOS too
FALLBACK_DIR="$ROOT_DIR/docs/assistant-learning-logs"
DEST="$($SCRIPT write-with-fallback "$PRIMARY" "content" "$FALLBACK_DIR")"
[ -f "$DEST" ] || { echo "fallback not written: $DEST"; exit 1; }

exit 0


