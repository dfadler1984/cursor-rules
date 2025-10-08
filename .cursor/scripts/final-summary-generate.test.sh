#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/final-summary-generate.sh"

# Arrange: temp workspace mimicking repo structure
WORKDIR="$(mktemp -d 2>/dev/null || mktemp -d -t fsum-gen)"

# Provide a custom template under --root to verify template resolution and generic <project> replacement
mkdir -p "$WORKDIR/.cursor/templates/project-lifecycle"
cat > "$WORKDIR/.cursor/templates/project-lifecycle/final-summary.template.md" <<'TPL'
---
template: project-lifecycle/final-summary
version: 1.0.0
last-updated: 2025-01-01
---

# Final Summary — <Project Name>

## Outcome

<What shipped and why it matters>

## Impact (Metrics)

- Baseline → After: <metric>
- Quality/Reliability: <signal>
- Developer Experience: <signal>

## Retrospective

- What worked
- What to improve
- Follow-ups (owners, dates)

## Links

- ERD: `docs/projects/<project>/erd.md`
- Tasks: `docs/projects/<project>/tasks.md`

# TEMPLATE_ID: CUSTOM
Extra: docs/projects/<project>/README.md
TPL

# Pre-move scenario: source folder exists; generator should write to source path
mkdir -p "$WORKDIR/docs/projects/pre-move-proj"
cat > "$WORKDIR/docs/projects/pre-move-proj/erd.md" <<'ERD'
# Rules Validation Script Enhancements — Lite ERD

## Introduction/Overview

Add a repository-local validator that checks rule front matter and common pitfalls.

## Goals/Objectives

- Automate validation of rule files
- Exit non-zero on violations
ERD

echo "# Tasks" > "$WORKDIR/docs/projects/pre-move-proj/tasks.md"

# Act (pre-move): generate final-summary in source dir with links pointing to archived path
set +e
out_pre="$(bash "$SCRIPT" --project pre-move-proj --year 2025 --root "$WORKDIR" --date 2025-10-08 --pre-move 2>&1)"
status_pre=$?
set -e
[ $status_pre -eq 0 ] || { echo "pre-move mode should succeed"; echo "$out_pre"; exit 1; }

FSUM_PRE="$WORKDIR/docs/projects/pre-move-proj/final-summary.md"
[ -f "$FSUM_PRE" ] || { echo "pre-move final-summary.md was not created"; exit 1; }
grep -q "^# Final Summary — Pre Move Proj$" "$FSUM_PRE" || { echo "pre-move title not substituted"; cat "$FSUM_PRE"; exit 1; }
grep -q "^last-updated: 2025-10-08$" "$FSUM_PRE" || { echo "pre-move date not substituted"; grep -n "last-updated" "$FSUM_PRE"; exit 1; }
# Links should be relative to source -> archived
grep -q "ERD: \`../_archived/2025/pre-move-proj/erd.md\`" "$FSUM_PRE" || { echo "pre-move ERD link not substituted (expected relative path)"; grep -n "ERD:" "$FSUM_PRE"; exit 1; }
grep -q "Tasks: \`../_archived/2025/pre-move-proj/tasks.md\`" "$FSUM_PRE" || { echo "pre-move Tasks link not substituted (expected relative path)"; grep -n "Tasks:" "$FSUM_PRE"; exit 1; }
# Outcome placeholder should be replaced using ERD Introduction/Overview
! grep -q "<What shipped and why it matters>" "$FSUM_PRE" || { echo "pre-move outcome placeholder not replaced"; exit 1; }
grep -q "Add a repository-local validator" "$FSUM_PRE" || { echo "pre-move outcome not derived from ERD"; exit 1; }
# Impact placeholders should be replaced
! grep -q "<metric>" "$FSUM_PRE" || { echo "pre-move impact metric placeholder not replaced"; exit 1; }
! grep -q "<signal>" "$FSUM_PRE" || { echo "pre-move impact signal placeholder not replaced"; exit 1; }
# Retrospective bullets should be expanded summaries
grep -q "What worked: POSIX-only approach" "$FSUM_PRE" || { echo "pre-move retrospective not summarized"; exit 1; }

# Archived scenario: archived folder exists; generator writes into archived path
mkdir -p "$WORKDIR/docs/projects/_archived/2025/my-project"
# Provide ERD without Introduction/Overview to test Goals fallback
cat > "$WORKDIR/docs/projects/_archived/2025/my-project/erd.md" <<'ERD2'
# ERD

## Goals/Objectives

- Do X
- Do Y
ERD2

echo "# Tasks" > "$WORKDIR/docs/projects/_archived/2025/my-project/tasks.md"

# Act: generate final-summary with a fixed date for deterministic assertions
set +e
out1="$(bash "$SCRIPT" --project my-project --year 2025 --root "$WORKDIR" --date 2025-10-08 2>&1)"
status1=$?
set -e
[ $status1 -eq 0 ] || { echo "generator should exit 0 on creation"; echo "$out1"; exit 1; }

FSUM="$WORKDIR/docs/projects/_archived/2025/my-project/final-summary.md"
[ -f "$FSUM" ] || { echo "final-summary.md was not created"; exit 1; }

# Assert: content substitutions
grep -q "^# Final Summary — My Project$" "$FSUM" || { echo "title not substituted"; cat "$FSUM"; exit 1; }
grep -q "^last-updated: 2025-10-08$" "$FSUM" || { echo "date not substituted"; grep -n "last-updated" "$FSUM"; exit 1; }
# Links should be local in archived directory
grep -q "ERD: \`./erd.md\`" "$FSUM" || { echo "ERD link not substituted (expected ./erd.md)"; grep -n "ERD:" "$FSUM"; exit 1; }
grep -q "Tasks: \`./tasks.md\`" "$FSUM" || { echo "Tasks link not substituted (expected ./tasks.md)"; grep -n "Tasks:" "$FSUM"; exit 1; }
# Outcome placeholder should be replaced using Goals fallback
! grep -q "<What shipped and why it matters>" "$FSUM" || { echo "outcome placeholder not replaced"; exit 1; }
grep -q "Delivered:" "$FSUM" || { echo "outcome not derived from Goals"; exit 1; }
# Impact placeholders should be replaced
! grep -q "<metric>" "$FSUM" || { echo "impact metric placeholder not replaced"; exit 1; }
! grep -q "<signal>" "$FSUM" || { echo "impact signal placeholder not replaced"; exit 1; }
# Retrospective bullets should be expanded summaries
grep -q "What worked: POSIX-only approach" "$FSUM" || { echo "retrospective not summarized"; exit 1; }

# Act 2: re-run without --force should fail to avoid accidental overwrite
set +e
out2="$(bash "$SCRIPT" --project my-project --year 2025 --root "$WORKDIR" --date 2025-10-08 2>&1)"
status2=$?
set -e
[ $status2 -ne 0 ] || { echo "expected non-zero when file exists without --force"; echo "$out2"; exit 1; }

# Act 3: re-run with --force should succeed and keep substitutions intact
out3="$(bash "$SCRIPT" --project my-project --year 2025 --root "$WORKDIR" --date 2025-10-08 --force 2>&1)"
echo "$out3" | grep -qi "Final summary" || { echo "expected confirmation output"; echo "$out3"; exit 1; }
grep -q "^# Final Summary — My Project$" "$FSUM" || { echo "title lost after force"; exit 1; }

echo "OK"
exit 0

