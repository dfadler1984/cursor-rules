#!/usr/bin/env bash
set -euo pipefail

# Legacy copy of .cursor/scripts/alp-smoke.sh

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../../../../" && pwd)"
cd "$root"

export TEST_ARTIFACTS_DIR="${TEST_ARTIFACTS_DIR:-$root/.test-artifacts}"
export ALP_LOG_DIR="$TEST_ARTIFACTS_DIR/alp"
export ASSISTANT_LOG_DIR="$ALP_LOG_DIR"
rm -rf "$ALP_LOG_DIR" 2>/dev/null || true
mkdir -p "$ALP_LOG_DIR"

destDir="$ASSISTANT_LOG_DIR"

last_path=""
for i in $(seq -w 01 11); do
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  short="alp-smoke-$i"
  body="Timestamp: $ts
Event: Smoke Test
Owner: assistant-learning/protocol
What Changed: Smoke test write $i to verify logging pipeline.
Next Step: Verify archive + summaries
Links: docs/projects/assistant-self-improvement/legacy/scripts/alp-smoke.sh
Learning: Smoke $i"
  path_out=$(printf "%s" "$body" | docs/projects/assistant-self-improvement/legacy/scripts/alp-logger.sh --log-dir "$destDir" write-with-fallback "$destDir" "$short" 2>/dev/null || true)
  last_path="$path_out"
  sleep 0.05
done

docs/projects/assistant-self-improvement/legacy/scripts/alp-threshold.sh >/dev/null 2>&1 || true

top_count=$(find "$ALP_LOG_DIR" -maxdepth 1 -type f -name 'log-*.md' 2>/dev/null | wc -l | tr -d ' ')
arch_count=$(find "$ALP_LOG_DIR/_archived" -type f -name 'log-*.md' 2>/dev/null | wc -l | tr -d ' ')
sum_count=$(find "$ALP_LOG_DIR" -maxdepth 1 -type f -name 'summary-*.md' 2>/dev/null | wc -l | tr -d ' ')

printf 'top-level logs=%s archived=%s summaries=%s\n' "$top_count" "$arch_count" "$sum_count"
printf '%s\n' "$last_path"


