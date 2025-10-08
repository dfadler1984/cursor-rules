#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT="$(cd "$(dirname "$BASH_SOURCE[0]")/../.." && pwd)"
SCRIPT="$ROOT/.cursor/scripts/rules-attach-validate.sh"

set +e
out="$("$SCRIPT" 2>&1)"
status=$?
set -e

[ $status -eq 0 ] || { echo "expected OK"; echo "$out"; exit 1; }
echo "$out" | grep -q "OK" || { echo "missing OK line"; echo "$out"; exit 1; }

exit 0


