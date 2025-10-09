#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
THRESHOLD_SCRIPT="$ROOT_DIR/.cursor/scripts/alp-threshold.sh"

if [ ! -x "$THRESHOLD_SCRIPT" ]; then
  echo "alp-threshold.sh not executable" >&2
  exit 1
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

# Arrange: isolated log dir and artifacts dir
export ASSISTANT_LOG_DIR="$tmpdir/logs"
export TEST_ARTIFACTS_DIR="$tmpdir"
mkdir -p "$ASSISTANT_LOG_DIR"

# Create a single log (below threshold)
echo "Timestamp: now" >"$ASSISTANT_LOG_DIR/log-2025-10-08T00-00-00Z-test.md"

# Act: run with threshold 2 (should be no-op)
set +e
out="$("$THRESHOLD_SCRIPT" --threshold 2 2>&1)"
rc=$?
set -e

[ $rc -eq 0 ] || { echo "threshold script returned non-zero"; echo "$out"; exit 1; }

# Assert: did not report threshold reached
echo "$out" | grep -q "ALP threshold reached" && { echo "unexpected threshold aggregate/archive"; echo "$out"; exit 1; }

exit 0


