#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "$0")/../.." && pwd)"
fill="$root_dir/.cursor/scripts/template-fill.sh"
validate="$root_dir/.cursor/scripts/validate-project-lifecycle.sh"

if [[ ! -x "$fill" ]]; then chmod +x "$fill"; fi
if [[ ! -x "$validate" ]]; then chmod +x "$validate"; fi

tmpdir="$(mktemp -d)"
export TMPDIR="$tmpdir"
projslug="tmp-proj-$$"
projdir="$tmpdir/docs/projects/$projslug"
mkdir -p "$projdir"

# Positive case: instantiate templates and validate OK
"$fill" --template final-summary --project "$projslug" --out "$projdir/final-summary.md" --vars projectName="Tmp Proj"
"$fill" --template retrospective --project "$projslug" --out "$projdir/retrospective.md" --vars projectName="Tmp Proj"
cat > "$projdir/tasks.md" <<'MD'
- [x] Task 1
- [x] Task 2
MD

PROJECTS_ROOT="$tmpdir/docs/projects" PR_TITLE="feat: close tmp project" "$validate" "$projslug"

# Negative cases
negdir="$tmpdir/docs/projects/${projslug}-neg"
mkdir -p "$negdir"

# Missing Impact in final-summary
cat > "$negdir/final-summary.md" <<'MD'
---
template: project-lifecycle/final-summary
version: 1.0.0
last-updated: 2025-10-10
---

# Final Summary — Bad Project

## Summary
No impact section here
MD
echo "- [x] Task" > "$negdir/tasks.md"
set +e
PROJECTS_ROOT="$tmpdir/docs/projects" "$validate" "${projslug}-neg" >/dev/null 2>&1
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "[TEST] Expected failure for missing Impact section" >&2
  exit 1
fi

# Missing front matter (no template/version)
negdir2="$tmpdir/docs/projects/${projslug}-neg2"
mkdir -p "$negdir2"
cat > "$negdir2/final-summary.md" <<'MD'
# Final Summary — No Front Matter

## Impact
Has impact but no front matter
MD
echo "- [x] Task" > "$negdir2/tasks.md"
set +e
PROJECTS_ROOT="$tmpdir/docs/projects" "$validate" "${projslug}-neg2" >/dev/null 2>&1
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "[TEST] Expected failure for missing front matter" >&2
  exit 1
fi

# Unchecked tasks without Carryovers
negdir3="$tmpdir/docs/projects/${projslug}-neg3"
mkdir -p "$negdir3"
cat > "$negdir3/final-summary.md" <<'MD'
---
template: project-lifecycle/final-summary
version: 1.0.0
last-updated: 2025-10-10
---

# Final Summary — Incomplete Tasks

## Impact
ok
MD
cat > "$negdir3/tasks.md" <<'MD'
- [x] Done
- [ ] Not done
MD
set +e
PROJECTS_ROOT="$tmpdir/docs/projects" "$validate" "${projslug}-neg3" >/dev/null 2>&1
status=$?
set -e
if [[ $status -eq 1 ]]; then :; else
  echo "[TEST] Expected failure for unchecked tasks without Carryovers" >&2
  exit 1
fi

# Missing retrospective (neither file nor section)
negdir4="$tmpdir/docs/projects/${projslug}-neg4"
mkdir -p "$negdir4"
cat > "$negdir4/final-summary.md" <<'MD'
---
template: project-lifecycle/final-summary
version: 1.0.0
last-updated: 2025-10-10
---

# Final Summary — No Retro

## Impact
ok
MD
echo "- [x] Done" > "$negdir4/tasks.md"
set +e
PROJECTS_ROOT="$tmpdir/docs/projects" "$validate" "${projslug}-neg4" >/dev/null 2>&1
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "[TEST] Expected failure for missing retrospective" >&2
  exit 1
fi

# Stray template file under project
negdir5="$tmpdir/docs/projects/${projslug}-neg5"
mkdir -p "$negdir5"
cat > "$negdir5/final-summary.md" <<'MD'
---
template: project-lifecycle/final-summary
version: 1.0.0
last-updated: 2025-10-10
---

# Final Summary — Stray Template

## Impact
ok
MD
echo "- [x] Done" > "$negdir5/tasks.md"
touch "$negdir5/should-not-be-here.template.md"
set +e
PROJECTS_ROOT="$tmpdir/docs/projects" "$validate" "${projslug}-neg5" >/dev/null 2>&1
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "[TEST] Expected failure for stray template file" >&2
  exit 1
fi

echo "[TEST] OK"

