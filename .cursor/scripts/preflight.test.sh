#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/preflight.sh"

# Run in current repo; expect warnings for missing optional items (depending on repo)
set +e
out="$(bash "$SCRIPT" 2>&1)"
status=$?
set -e

# Should print Preflight checks
printf '%s' "$out" | grep -qi "Preflight checks" || { echo "preflight header missing"; exit 1; }

# Allow either OK or warnings; status may be 0 or 1 depending on repo state
if [ $status -ne 0 ] && [ $status -ne 1 ]; then
  echo "unexpected exit status: $status"; exit 1
fi

exit 0
