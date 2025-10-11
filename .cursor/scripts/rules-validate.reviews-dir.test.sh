#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

# Use a temp reviews dir under .test-artifacts
TS="$(date -u +%Y-%m-%dT%H-%M-%SZ)"
REV_DIR=".test-artifacts/reviews-$TS"
mkdir -p "$REV_DIR"

"$ROOT_DIR/.cursor/scripts/rules-validate.sh" --mode report --reviews-dir "$REV_DIR"

expected="$REV_DIR/review-$(date -u +%Y-%m-%d).md"

if [[ ! -f "$expected" ]]; then
  echo "Expected report not found: $expected" >&2
  exit 1
fi

echo "OK: report created at $expected"

