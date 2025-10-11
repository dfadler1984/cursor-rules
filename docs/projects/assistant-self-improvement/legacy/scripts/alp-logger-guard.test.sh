#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Legacy copy of .cursor/scripts/alp-logger-guard.test.sh

if [[ "${ALP_GUARD:-0}" != "1" ]]; then
  echo "SKIP: logger guard (set ALP_GUARD=1 to enable)"
  exit 0
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../" && pwd)"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

LOG_DIR="$tmpdir/assistant-logs"
mkdir -p "$LOG_DIR"

bad_file="$LOG_DIR/log-2025-10-08T00-00-00Z-bad-direct.md"
printf '%s\n' "Timestamp: 2025-10-08T00:00:00Z" >"$bad_file"

echo "Direct write detected: $bad_file"
exit 1


