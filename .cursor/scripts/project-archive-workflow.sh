#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"

usage() {
  cat <<'USAGE'
Usage: project-archive-workflow.sh --project <slug> --year <YYYY> [--root <path>] [--date <YYYY-MM-DD>] [--dry-run]

Performs the policy-compliant archive workflow with guardrails:
  1) Validate ERD completion metadata and tasks
  2) Generate pre-move final summary (default)
  3) Single full-folder move
  4) Validators (rules/project-lifecycle/links)
  5) Print Completed index entry

Defaults:
  - Summary generation is pre-move (adds --pre-move flag)
  - Year defaults to current year if omitted

Examples:
  ./.cursor/scripts/project-archive-workflow.sh --project my-proj --year 2025 --dry-run
USAGE
}

PROJECT=""
YEAR="$(date +%Y)"
ROOT="$ROOT_DIR"
DATE="$(date +%Y-%m-%d)"
DRY_RUN=0

while [ $# -gt 0 ]; do
  case "$1" in
    --project) PROJECT="${2-}"; shift 2 ;;
    --year) YEAR="${2-}"; shift 2 ;;
    --root) ROOT="${2-}"; shift 2 ;;
    --date) DATE="${2-}"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift 1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 2 ;;
  esac
done

if [ -z "$PROJECT" ]; then
  echo "--project is required" >&2
  usage
  exit 2
fi

SRC="$ROOT/docs/projects/$PROJECT"
ERD="$SRC/erd.md"
TASKS="$SRC/tasks.md"

if [ ! -d "$SRC" ]; then
  echo "Source project directory does not exist: $SRC" >&2
  exit 1
fi
if [ ! -f "$ERD" ]; then
  echo "Missing ERD: $ERD" >&2
  exit 1
fi
if [ ! -f "$TASKS" ]; then
  echo "Missing tasks: $TASKS" >&2
  exit 1
fi

# Commands we will run (pre-move summary is default)
GEN_CMD=".cursor/scripts/final-summary-generate.sh --project $PROJECT --year $YEAR --root $ROOT --date $DATE --pre-move"
MOVE_CMD=".cursor/scripts/project-archive.sh --project $PROJECT --year $YEAR --root $ROOT"
RULES_VALIDATE_CMD=".cursor/scripts/rules-validate.sh"
LIFECYCLE_VALIDATE_CMD=".cursor/scripts/project-lifecycle-validate.sh"
LINKS_CHECK_CMD=".cursor/scripts/links-check.sh"

INDEX_LINE="- [$PROJECT](../_archived/$YEAR/$PROJECT/erd.md) — Completed."

if [ $DRY_RUN -eq 1 ]; then
  echo "Plan:"
  echo "  1) Generate final summary (pre-move): $GEN_CMD"
  echo "  2) Archive project via single full-folder move: $MOVE_CMD"
  echo "  3) Run validators: $RULES_VALIDATE_CMD; $LIFECYCLE_VALIDATE_CMD; $LINKS_CHECK_CMD"
  echo "  4) Update projects index (Completed):"
  echo "     $INDEX_LINE"
  exit 0
fi

# 1) Pre-move summary
bash -c "$GEN_CMD"

# 2) Single full-folder move
bash -c "$MOVE_CMD"

# 3) Validators (best-effort; report failures)
set +e
bash -c "$RULES_VALIDATE_CMD"
rv1=$?
bash -c "$LIFECYCLE_VALIDATE_CMD"
rv2=$?
bash -c "$LINKS_CHECK_CMD"
rv3=$?
set -e

echo "Validators exit codes: rules=$rv1 lifecycle=$rv2 links=$rv3"

# 4) Print index update line
echo "Completed index entry (paste into docs/projects/README.md under Completed):"
echo "$INDEX_LINE"

exit 0


