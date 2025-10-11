#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../" && pwd)"
cd "$ROOT_DIR"

export TEST_ARTIFACTS_DIR="$ROOT_DIR/.test-artifacts"
export ALP_LOG_DIR="$TEST_ARTIFACTS_DIR/alp"
export ASSISTANT_LOG_DIR="$ALP_LOG_DIR"

rm -rf "$ALP_LOG_DIR" 2>/dev/null || true
mkdir -p "$ALP_LOG_DIR"

out="$(bash docs/projects/assistant-self-improvement/legacy/scripts/alp-smoke.sh)"
echo "$out"

top=$(printf "%s" "$out" | sed -n 's/.*top-level logs=\([0-9][0-9]*\).*/\1/p')
arch=$(printf "%s" "$out" | sed -n 's/.*archived=\([0-9][0-9]*\).*/\1/p')
sum=$(printf "%s" "$out" | sed -n 's/.*summaries=\([0-9][0-9]*\).*/\1/p')

fail=0
[[ "$top" = "1" ]] || { echo "EXPECT top-level=1, got $top"; fail=1; }
[[ "$arch" = "10" ]] || { echo "EXPECT archived=10, got $arch"; fail=1; }
[[ "${sum:-0}" -ge 1 ]] || { echo "EXPECT summaries>=1, got ${sum:-0}"; fail=1; }

exit "$fail"


