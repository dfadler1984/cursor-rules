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
  path_out=$(printf "%s" "$body" | .cursor/scripts/alp-logger.sh write-with-fallback "$destDir" "$short" 2>/dev/null || true)
  last_path="$path_out"
  # Small delay to ensure monotonic filenames
  sleep 0.05
done

# Print a markdown path for the workflow to assert
printf '%s\n' "$last_path"


