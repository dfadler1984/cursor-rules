#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
cd "$ROOT_DIR"

SMOKE="$ROOT_DIR/.cursor/scripts/alp-smoke.sh"

if [ ! -x "$SMOKE" ]; then
  echo "alp-smoke.sh not executable" >&2
  exit 1
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

# Arrange: confine all artifacts to the test artifacts dir
export TEST_ARTIFACTS_DIR="$tmpdir"
export ALP_LOG_DIR="$TEST_ARTIFACTS_DIR/alp"
export ASSISTANT_LOG_DIR="$ALP_LOG_DIR"
rm -rf "$ALP_LOG_DIR" 2>/dev/null || true
mkdir -p "$ALP_LOG_DIR"

# Baseline: count existing docs summaries to detect leakage
DOCS_DIR="$ROOT_DIR/docs/assistant-learning-logs"
before_docs_sum=$(find "$DOCS_DIR" -maxdepth 1 -type f -name 'summary-*.md' 2>/dev/null | wc -l | tr -d ' ')

# Act: run smoke (logger-driven 11 logs → threshold behavior)
out="$(bash "$SMOKE")"

# Parse smoke output counts
top=$(printf "%s" "$out" | sed -n 's/.*top-level logs=\([0-9][0-9]*\).*/\1/p')
arch=$(printf "%s" "$out" | sed -n 's/.*archived=\([0-9][0-9]*\).*/\1/p')
sum=$(printf "%s" "$out" | sed -n 's/.*summaries=\([0-9][0-9]*\).*/\1/p')

# Assert: expected counts inside test artifacts
[ "$top" = "1" ] || { echo "expected top-level=1, got $top"; echo "$out"; exit 1; }
[ "$arch" = "10" ] || { echo "expected archived=10, got $arch"; echo "$out"; exit 1; }
[ "${sum:-0}" -ge 1 ] || { echo "expected summaries>=1, got ${sum:-0}"; echo "$out"; exit 1; }

# Assert: no new summaries were written under repo docs (artifacts must not leak)
after_docs_sum=$(find "$DOCS_DIR" -maxdepth 1 -type f -name 'summary-*.md' 2>/dev/null | wc -l | tr -d ' ')
[ "$after_docs_sum" = "$before_docs_sum" ] || { echo "unexpected summaries written to docs/assistant-learning-logs"; exit 1; }

exit 0


