#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

usage() {
  cat <<'USAGE'
Usage: project-complete.sh <slug> [--force] [--dry-run] [--root <path>] [--date <YYYY-MM-DD>]

Orchestrate project completion workflow: validate → summary → status update.

Arguments:
  <slug>           Project slug under docs/projects (required)

Options:
  --force          Complete even if tasks are incomplete
  --dry-run        Preview actions without executing
  --root <path>    Repository root override (defaults to detected root)
  --date <date>    Completion date (default: today, YYYY-MM-DD)
  -h, --help       Show this help

Examples:
  # Complete project (all tasks must be done)
  project-complete.sh my-project
  
  # Force completion with incomplete tasks
  project-complete.sh my-project --force
  
  # Preview completion
  project-complete.sh my-project --dry-run
USAGE
  
  print_exit_codes
}

SLUG=""
FORCE=0
DRY_RUN=0
ROOT="$ROOT_DIR"
DATE="$(date +%Y-%m-%d)"

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --force) FORCE=1; shift 1 ;;
    --dry-run) DRY_RUN=1; shift 1 ;;
    --root) ROOT="${2-}"; shift 2 ;;
    --date) DATE="${2-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "Unknown option: $1" >&2; usage; exit 2 ;;
    *) SLUG="$1"; shift 1 ;;
  esac
done

if [ -z "$SLUG" ]; then
  echo "Error: slug is required" >&2
  usage
  exit 2
fi

PROJECT_DIR="$ROOT/docs/projects/$SLUG"
ERD_FILE="$PROJECT_DIR/erd.md"
TASKS_FILE="$PROJECT_DIR/tasks.md"

# Check if project exists
if [ ! -d "$PROJECT_DIR" ]; then
  echo "Error: project directory does not exist: $PROJECT_DIR" >&2
  exit 1
fi

if [ ! -f "$ERD_FILE" ]; then
  echo "Error: ERD not found: $ERD_FILE" >&2
  exit 1
fi

if [ ! -f "$TASKS_FILE" ]; then
  echo "Error: tasks file not found: $TASKS_FILE" >&2
  exit 1
fi

# Count tasks
TOTAL_TASKS=$(grep -cE '^\s*-\s+\[[ x]\]' "$TASKS_FILE" || echo "0")
COMPLETED_TASKS=$(grep -cE '^\s*-\s+\[x\]' "$TASKS_FILE" || echo "0")

# Calculate completion
if [ "$TOTAL_TASKS" -eq 0 ]; then
  COMPLETION_PCT=0
else
  COMPLETION_PCT=$(( (COMPLETED_TASKS * 100) / TOTAL_TASKS ))
fi

# Validate task completion
if [ "$COMPLETION_PCT" -lt 100 ] && [ $FORCE -ne 1 ]; then
  echo "Error: not all tasks are complete ($COMPLETED_TASKS/$TOTAL_TASKS)" >&2
  echo "Use --force to complete anyway" >&2
  exit 1
fi

if [ $DRY_RUN -eq 1 ]; then
  YEAR=$(date +%Y)
  echo "Plan:"
  echo "  1. Generate final summary: final-summary-generate.sh --project $SLUG --year $YEAR --pre-move"
  echo "  2. Update ERD front matter: status → completed, add completedDate: $DATE"
  echo "  3. Next steps:"
  echo "     - Update docs/projects/README.md (move to Completed section)"
  echo "     - Consider: project-archive-workflow.sh --project $SLUG --year $YEAR"
  exit 0
fi

# 1. Generate final summary (pre-move mode)
YEAR=$(date +%Y)
FSUM_CMD="$SCRIPT_DIR/final-summary-generate.sh --project $SLUG --year $YEAR --root $ROOT --date $DATE --pre-move"

set +e
bash -c "$FSUM_CMD"
fsum_status=$?
set -e

if [ $fsum_status -ne 0 ]; then
  echo "Warning: final summary generation failed (exit $fsum_status)" >&2
  echo "Continuing with status update..." >&2
fi

# 2. Update ERD front matter
# Add completedDate if not present, update status to completed
if grep -q "^completedDate:" "$ERD_FILE"; then
  # Update existing completedDate
  sed -i.bak "s/^completedDate: .*/completedDate: $DATE/" "$ERD_FILE"
else
  # Add completedDate after lastUpdated (or after owner if lastUpdated missing)
  if grep -q "^lastUpdated:" "$ERD_FILE"; then
    sed -i.bak "/^lastUpdated:/a\\
completedDate: $DATE
" "$ERD_FILE"
  else
    sed -i.bak "/^owner:/a\\
completedDate: $DATE
" "$ERD_FILE"
  fi
fi

# Update status to completed
sed -i.bak "s/^status: .*/status: completed/" "$ERD_FILE"

# Update lastUpdated
sed -i.bak "s/^lastUpdated: .*/lastUpdated: $DATE/" "$ERD_FILE"

# Remove backup file
rm -f "$ERD_FILE.bak"

# 3. Print next steps
echo "Project marked as completed: $SLUG"
echo ""
echo "Next steps:"
echo "  1. Update docs/projects/README.md"
echo "     - Move project from 'Active Projects' to 'Completed Projects'"
echo "     - Link to: docs/projects/$SLUG/final-summary.md"
echo "  2. Consider archiving:"
echo "     project-archive-workflow.sh --project $SLUG --year $YEAR"

exit 0

