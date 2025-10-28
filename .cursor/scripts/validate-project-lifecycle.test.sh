#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

root_dir="$(cd "$(dirname "$0")/../.." && pwd)"
script="$root_dir/.cursor/scripts/validate-project-lifecycle.sh"

echo "[TEST] Running validator smoke tests"

if [[ ! -f "$script" ]]; then
  echo "[TEST] MISSING: validator script not found at $script" >&2
  exit 1
fi

# Expect the script to print usage or fail when no args are provided
set +e
"$script" >/dev/null 2>&1
status=$?
set -e

if [[ $status -eq 0 ]]; then
  echo "[TEST] Expected non-zero exit when no projects are provided" >&2
  exit 1
fi

echo "[TEST] OK: validator presence and no-args behavior"

# Basic behavior checks: Impact missing, carryovers, retrospective as section, and --pr-title flag
workdir="$(mktemp -d 2>/dev/null || mktemp -d -t vproj)"
trap 'rm -rf "$workdir"' EXIT

mkdir -p "$workdir/docs/projects/sample"
cat > "$workdir/docs/projects/sample/final-summary.md" <<'MD'
---
template: project-lifecycle/final-summary
version: 1.0.0
last-updated: 2025-10-10
---

# Final Summary — Sample

## Summary

MD

cat > "$workdir/docs/projects/sample/tasks.md" <<'MD'
# Tasks

- [ ] one
MD

# Run: expect errors for missing Impact and Carryovers
set +e
out_err=$(PROJECTS_ROOT="$workdir/docs/projects" "$script" --pr-title "docs: finalize" sample 2>&1)
rc=$?
set -e
[ $rc -ne 0 ] || { echo "expected non-zero exit" >&2; echo "$out_err" >&2; exit 1; }
echo "$out_err" | grep -q "missing ## Impact" || { echo "expected Impact error" >&2; echo "$out_err" >&2; exit 1; }
echo "$out_err" | grep -q "Carryovers" || { echo "expected Carryovers error" >&2; echo "$out_err" >&2; exit 1; }
echo "$out_err" | grep -q "\[WARN\] PR title" || { echo "expected advisory PR title warning" >&2; echo "$out_err" >&2; exit 1; }

# Fix Impact and carryovers; add retrospective as section
cat >> "$workdir/docs/projects/sample/final-summary.md" <<'MD'

## Impact

- Baseline → Outcome: X → Y

## Retrospective

What worked...
MD

cat >> "$workdir/docs/projects/sample/tasks.md" <<'MD'

## Carryovers

- follow-up
MD

set +e
out_ok=$(PROJECTS_ROOT="$workdir/docs/projects" "$script" sample 2>&1)
rc2=$?
set -e
[ $rc2 -eq 0 ] || { echo "expected success after fixes" >&2; echo "$out_ok" >&2; exit 1; }
echo "[TEST] OK: validator behavior checks"

# Test: CHANGELOG advisory check for complex projects
echo "[TEST] CHANGELOG advisory check for complex projects"
mkdir -p "$workdir/docs/projects/complex"

# Create minimal valid project
cat > "$workdir/docs/projects/complex/final-summary.md" <<'MD'
---
template: project-lifecycle/final-summary
version: 1.0.0
---

# Final Summary

## Impact
- Done

## Retrospective
- Learned
MD

cat > "$workdir/docs/projects/complex/tasks.md" <<'MD'
## Tasks
- [x] All done

## Carryovers
- None
MD

# Create 20 markdown files to exceed threshold
for i in {1..20}; do
  echo "# File $i" > "$workdir/docs/projects/complex/file-$i.md"
done

# Run validator - should warn about missing CHANGELOG
set +e
out_complex=$(PROJECTS_ROOT="$workdir/docs/projects" "$script" complex 2>&1)
rc_complex=$?
set -e

# Should succeed (warning only, not error)
[ $rc_complex -eq 0 ] || { echo "should succeed with warning" >&2; echo "$out_complex" >&2; exit 1; }

# Should warn about missing CHANGELOG
echo "$out_complex" | grep -qi "CHANGELOG.md" || { echo "should warn about missing CHANGELOG for complex project" >&2; echo "$out_complex" >&2; exit 1; }

echo "[TEST] OK: CHANGELOG advisory check"

