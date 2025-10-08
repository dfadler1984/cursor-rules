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

# Create 11 deterministic logs (oldest .. newest)
for i in $(seq -w 01 11); do
  ts="2025-10-08T00-00-${i}Z"
  f="$ASSISTANT_LOG_DIR/log-${ts}-sim.md"
  printf 'Timestamp: %s\nEvent: Sim\nLearning: test\n' "$ts" >"$f"
done

# Act: run with threshold 10
set +e
out="$("$THRESHOLD_SCRIPT" --threshold 10 2>&1)"
rc=$?
set -e

[ $rc -eq 0 ] || { echo "threshold script returned non-zero"; echo "$out"; exit 1; }
echo "$out" | grep -q "ALP threshold reached" || { echo "expected threshold message missing"; echo "$out"; exit 1; }

# Assert: exactly 10 archived under _archived/2025/10 and 1 remains (newest)
archived_dir="$ASSISTANT_LOG_DIR/_archived/2025/10"
[ -d "$archived_dir" ] || { echo "archived dir missing: $archived_dir"; exit 1; }
archived_count="$(find "$archived_dir" -type f -name 'log-*.md' 2>/dev/null | wc -l | tr -d ' ')"
[ "$archived_count" = "10" ] || { echo "expected 10 archived, got $archived_count"; exit 1; }

remaining_count="$(find "$ASSISTANT_LOG_DIR" -maxdepth 1 -type f -name 'log-*.md' 2>/dev/null | wc -l | tr -d ' ')"
[ "$remaining_count" = "1" ] || { echo "expected 1 remaining top-level log, got $remaining_count"; exit 1; }

remaining_file="$(ls -1 "$ASSISTANT_LOG_DIR"/log-*.md | sort | tail -n1)"
echo "$remaining_file" | grep -q "11Z" || { echo "remaining file is not the newest (..11Z): $remaining_file"; exit 1; }

# Assert: an aggregate summary was written to TEST_ARTIFACTS_DIR/alp
[ -d "$TEST_ARTIFACTS_DIR/alp" ] || { echo "aggregate out dir missing: $TEST_ARTIFACTS_DIR/alp"; exit 1; }
summary_count="$(find "$TEST_ARTIFACTS_DIR/alp" -maxdepth 1 -type f -name 'summary-*.md' | wc -l | tr -d ' ')"
[ "$summary_count" -ge 1 ] || { echo "expected at least 1 aggregate summary"; exit 1; }

exit 0


