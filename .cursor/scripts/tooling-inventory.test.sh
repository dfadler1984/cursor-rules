#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/tooling-inventory.sh"

if [ ! -x "$SCRIPT" ]; then
  echo "expected script to exist: $SCRIPT" >&2
  exit 1
fi

# Run in read-only mode; expect a table header and at least one row mentioning ALP
set +e
out="$(bash "$SCRIPT" 2>&1)"
status=$?
set -e

echo "$out" | grep -qi "Category" || { echo "missing table header"; exit 1; }
echo "$out" | grep -qi "Logging (ALP)" || { echo "missing ALP row"; exit 1; }

if [ $status -ne 0 ]; then
  echo "unexpected non-zero status: $status"; exit 1
fi

# Detect mode should report present/missing without network
set +e
detect_out="$(bash "$SCRIPT" --detect 2>&1)"
detect_status=$?
set -e

echo "$detect_out" | grep -qi "Category" || { echo "detect: missing table header"; exit 1; }
# Expect computed presence for Security scans when security-scan.sh exists in repo
if [ -f "$ROOT_DIR/.cursor/scripts/security-scan.sh" ]; then
  echo "$detect_out" | grep -qi "^Security scans | Yes " || { echo "detect: expected 'Security scans | Yes'"; exit 1; }
else
  echo "$detect_out" | grep -qi "^Security scans | No " || { echo "detect: expected 'Security scans | No'"; exit 1; }
fi
if [ $detect_status -ne 0 ]; then
  echo "detect: unexpected non-zero status: $detect_status"; exit 1
fi

exit 0

