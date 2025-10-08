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

# Write 11 logs via the logger to trigger threshold behavior
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
  printf "%s" "$body" | .cursor/scripts/alp-logger.sh write-with-fallback "$destDir" "$short" >/dev/null 2>&1 || true
  # Small delay to ensure monotonic filenames
  sleep 0.05
done

# Emit a concise summary constrained to .test-artifacts
top_count=$(find "$ALP_LOG_DIR" -maxdepth 1 -type f -name 'log-*.md' 2>/dev/null | wc -l | tr -d ' ')
archived_count=$(find "$ALP_LOG_DIR/_archived" -type f -name 'log-*.md' 2>/dev/null | wc -l | tr -d ' ')
summaries=$(find "$ALP_LOG_DIR" -maxdepth 1 -type f -name 'summary-*.md' 2>/dev/null | wc -l | tr -d ' ')
echo "SMOKE: top-level logs=$top_count archived=$archived_count summaries=$summaries dir=$ALP_LOG_DIR"


