#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../" && pwd)"
LOGGER_SCRIPT="$ROOT_DIR/docs/projects/assistant-self-improvement/legacy/scripts/alp-logger.sh"

if [ ! -x "$LOGGER_SCRIPT" ]; then
  echo "alp-logger.sh not executable" >&2
  exit 1
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

export ASSISTANT_LOG_DIR="$tmpdir/logs"
mkdir -p "$ASSISTANT_LOG_DIR"

file_path="$($LOGGER_SCRIPT write-with-fallback "$ASSISTANT_LOG_DIR" "logger-test" <<<'Timestamp: now')"

[ -f "$file_path" ] || { echo "expected log file to be created"; exit 1; }

exit 0


