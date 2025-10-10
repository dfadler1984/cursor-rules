#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/project-archive-workflow.sh"

# Arrange: isolated workspace
WORKDIR="$(mktemp -d 2>/dev/null || mktemp -d -t proj-archive-wf)"
mkdir -p "$WORKDIR/docs/projects/my-proj"

# Minimal ERD with completion metadata
cat > "$WORKDIR/docs/projects/my-proj/erd.md" <<'ERD'
---
status: completed
completed: 2025-10-08
owner: test-owner
---

# ERD — My Proj
This is a minimal ERD body for testing.
ERD

cat > "$WORKDIR/docs/projects/my-proj/tasks.md" <<'TASKS'
# Tasks — My Proj

- [x] close out open items
- [x] verify links
TASKS

# Act: DRY-RUN (default should be post-move summary)
set +e
out="$(bash "$SCRIPT" --project my-proj --year 2025 --root "$WORKDIR" --dry-run 2>&1)"
status=$?
set -e

# Assert: dry-run succeeds and prints planned steps/commands in order
[ $status -eq 0 ] || { echo "dry-run should succeed"; echo "$out"; exit 1; }
echo "$out" | grep -qi "final-summary-generate.sh" || { echo "should mention final-summary generation"; echo "$out"; exit 1; }
echo "$out" | grep -Fvq -- "--pre-move" || { echo "should default to post-move summary (no --pre-move)"; echo "$out"; exit 1; }
echo "$out" | grep -qi "project-archive.sh" || { echo "should mention single full-folder move"; echo "$out"; exit 1; }
echo "$out" | grep -qi "rules-validate.sh" || { echo "should run rules validator"; echo "$out"; exit 1; }
echo "$out" | grep -qi "project-lifecycle-validate-sweep.sh\|project-lifecycle-validate.sh" || { echo "should run lifecycle validator"; echo "$out"; exit 1; }
echo "$out" | grep -qi "links-check.sh" || { echo "should run links check"; echo "$out"; exit 1; }
echo "$out" | grep -q "_archived/2025/my-proj/final-summary.md" || { echo "should print Completed index entry pointing to final-summary.md"; echo "$out"; exit 1; }

exit 0


