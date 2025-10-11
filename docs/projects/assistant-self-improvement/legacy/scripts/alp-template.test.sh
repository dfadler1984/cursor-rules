#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../" && pwd)"
SCRIPT="$ROOT_DIR/docs/projects/assistant-self-improvement/legacy/scripts/alp-template.sh"

OUT=$(bash "$SCRIPT" format \
  --timestamp "2025-10-01T17:03:00Z" \
  --persona "senior-engineer" \
  --problem "Owner spec missed bracketed globs edge case." \
  --solution "Added validation and a failing test first; then implemented minimal fix." \
  --lesson "Validate input format early; prefer declarative checks." \
  --rule "deterministic-outputs.mdc - add glob validation note." \
  --context "docs/specs/glob-parse-spec.md#rejects-bracketed-globs | commit abc123")

EXPECTED='[2025-10-01T17:03, senior-engineer] Problem: Owner spec missed bracketed globs edge case.
Solution: Added validation and a failing test first; then implemented minimal fix.
Lesson: Validate input format early; prefer declarative checks.
Rule candidate: deterministic-outputs.mdc - add glob validation note. [rule-candidate]
Context: docs/specs/glob-parse-spec.md#rejects-bracketed-globs | commit abc123'

if [ "$OUT" != "$EXPECTED" ]; then
  echo "Template mismatch"
  echo "Got:"; echo "$OUT"
  echo "Expected:"; echo "$EXPECTED"
  exit 1
fi

exit 0


