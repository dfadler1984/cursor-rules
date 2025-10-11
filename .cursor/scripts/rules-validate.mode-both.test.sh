#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

TS="$(date -u +%Y-%m-%dT%H-%M-%SZ)"
OUT_FILE=".test-artifacts/rules-validate-$TS.txt"
REV_DIR=".test-artifacts/reviews-$TS"

"$ROOT_DIR/.cursor/scripts/rules-validate.sh" --mode both --reviews-dir "$REV_DIR" --write-console-out "$OUT_FILE" || true

rep="$REV_DIR/review-$(date -u +%Y-%m-%d).md"

[[ -f "$rep" ]] || { echo "Missing review report: $rep" >&2; exit 1; }
[[ -f "$OUT_FILE" ]] || { echo "Missing console output: $OUT_FILE" >&2; exit 1; }

echo "OK: both report and console output created"

