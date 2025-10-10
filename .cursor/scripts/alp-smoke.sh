#!/usr/bin/env bash
set -euo pipefail

# Smoke test: simulate rule-driven logging via the official tooling, scoped to .test-artifacts only

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
cd "$root"

# Ensure all artifacts are contained under .test-artifacts
export TEST_ARTIFACTS_DIR="${TEST_ARTIFACTS_DIR:-$root/.test-artifacts}"
export ALP_LOG_DIR="$TEST_ARTIFACTS_DIR/alp"
export ASSISTANT_LOG_DIR="$ALP_LOG_DIR"
rm -rf "$ALP_LOG_DIR" 2>/dev/null || true
mkdir -p "$ALP_LOG_DIR"

destDir="$ASSISTANT_LOG_DIR"

# Write 11 logs via the logger to trigger threshold behavior, capture last path
last_path=""
for i in $(seq -w 01 11); do
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  short="alp-smoke-$i"
  body="Timestamp: $ts
Event: Smoke Test
Owner: assistant-learning/protocol
What Changed: Smoke test write $i to verify logging pipeline.
Next Step: Verify archive + summaries
Links: .cursor/scripts/alp-smoke.sh
Learning: Smoke $i"
  path_out=$(printf "%s" "$body" | .cursor/scripts/alp-logger.sh --log-dir "$destDir" write-with-fallback "$destDir" "$short" 2>/dev/null || true)
  last_path="$path_out"
  # Small delay to ensure monotonic filenames
  sleep 0.05
done

# Trigger threshold behavior (the logger already attempts it, but run explicitly to be sure)
.cursor/scripts/alp-threshold.sh >/dev/null 2>&1 || true

# Compute counts within the test artifacts dir
top_count=$(find "$ALP_LOG_DIR" -maxdepth 1 -type f -name 'log-*.md' 2>/dev/null | wc -l | tr -d ' ')
arch_count=$(find "$ALP_LOG_DIR/_archived" -type f -name 'log-*.md' 2>/dev/null | wc -l | tr -d ' ')
sum_count=$(find "$ALP_LOG_DIR" -maxdepth 1 -type f -name 'summary-*.md' 2>/dev/null | wc -l | tr -d ' ')

# Emit a summary line that tests can parse, then the last path for debugging
printf 'top-level logs=%s archived=%s summaries=%s\n' "$top_count" "$arch_count" "$sum_count"
printf '%s\n' "$last_path"


