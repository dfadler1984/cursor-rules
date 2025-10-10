#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "$0")/../.." && pwd)"
migrate="$root_dir/.cursor/scripts/project-lifecycle-migrate.sh"
validate="$root_dir/.cursor/scripts/validate-project-lifecycle.sh"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

proj="migrate-proj-$$"
projdir="$tmpdir/docs/projects/$proj"
mkdir -p "$projdir"

# Case 1: No files present → migration should create required files
PROJECTS_ROOT="$tmpdir/docs/projects" "$migrate" --project "$proj" --root "$tmpdir/docs/projects"

[[ -s "$projdir/final-summary.md" ]] || { echo "missing final-summary" >&2; exit 1; }
[[ -f "$projdir/retrospective.md" ]] || { echo "missing retrospective" >&2; exit 1; }
grep -q '^template: project-lifecycle/final-summary' "$projdir/final-summary.md" || { echo "missing template fm" >&2; exit 1; }
grep -q '^##\s\+Impact' "$projdir/final-summary.md" || { echo "missing Impact section" >&2; exit 1; }

PROJECTS_ROOT="$tmpdir/docs/projects" "$validate" "$proj"

# Case 2: Existing final-summary without Impact → add section
proj2="migrate-proj2-$$"
projdir2="$tmpdir/docs/projects/$proj2"
mkdir -p "$projdir2"
cat > "$projdir2/final-summary.md" <<'MD'
---
template: project-lifecycle/final-summary
version: 1.0.0
last-updated: 2025-10-10
---

# Final Summary — No Impact
MD
echo "- [x] t" > "$projdir2/tasks.md"
PROJECTS_ROOT="$tmpdir/docs/projects" "$migrate" --project "$proj2" --root "$tmpdir/docs/projects"
grep -q '^##\s\+Impact' "$projdir2/final-summary.md" || { echo "expected Impact added" >&2; exit 1; }

echo OK

