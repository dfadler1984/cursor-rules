#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

usage() {
  cat <<'USAGE'
Usage: project-status.sh <slug> [--format json|text] [--root <path>]

Query project status, completion percentage, and suggested next action.

Arguments:
  <slug>           Project slug under docs/projects (required)

Options:
  --format <fmt>   Output format: text (default) or json
  --root <path>    Repository root override (defaults to detected root)
  -h, --help       Show this help

Examples:
  # Show status (text)
  project-status.sh my-project
  
  # Show status (JSON)
  project-status.sh my-project --format json
USAGE
  
  print_exit_codes
}

SLUG=""
FORMAT="text"
ROOT="$ROOT_DIR"

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --format) FORMAT="${2-}"; shift 2 ;;
    --root) ROOT="${2-}"; shift 2 ;;
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

# Validate format
if [ "$FORMAT" != "text" ] && [ "$FORMAT" != "json" ]; then
  echo "Error: --format must be 'text' or 'json', got: $FORMAT" >&2
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

# Parse status from ERD front matter
# Skip first --- and capture until second ---
STATUS=$(awk '
  BEGIN { in_fm=0; count=0 }
  /^---$/ { count++; if (count==1) in_fm=1; if (count==2) exit }
  in_fm && /^status:/ { sub(/^status:[[:space:]]*/, ""); print; exit }
' "$ERD_FILE")
if [ -z "$STATUS" ]; then
  STATUS="unknown"
fi

# Count tasks (checkbox pattern: - [ ] or - [x])
# grep -c always outputs a count (0 or more), so no need for || echo "0"
TOTAL_TASKS=$(grep -cE '^\s*-\s+\[[ x]\]' "$TASKS_FILE" || true)
COMPLETED_TASKS=$(grep -cE '^\s*-\s+\[x\]' "$TASKS_FILE" || true)
# Handle empty output (when grep finds nothing)
[ -z "$TOTAL_TASKS" ] && TOTAL_TASKS=0
[ -z "$COMPLETED_TASKS" ] && COMPLETED_TASKS=0

# Calculate completion percentage
if [ "$TOTAL_TASKS" -eq 0 ]; then
  COMPLETION_PCT=0
  # If no tasks, suggest next action is to add tasks
  NEXT_ACTION_OVERRIDE="add tasks to tasks.md"
else
  COMPLETION_PCT=$(( (COMPLETED_TASKS * 100) / TOTAL_TASKS ))
fi

# Determine next action
NEXT_ACTION=""
if [ -n "${NEXT_ACTION_OVERRIDE:-}" ]; then
  NEXT_ACTION="$NEXT_ACTION_OVERRIDE"
elif [ "$STATUS" = "completed" ]; then
  NEXT_ACTION="project complete; consider archiving"
elif [ "$STATUS" = "paused" ]; then
  NEXT_ACTION="project paused; resume or close"
elif [ "$COMPLETION_PCT" -eq 100 ] && [ "$STATUS" = "active" ]; then
  NEXT_ACTION="run project-complete.sh"
else
  NEXT_ACTION="continue work"
fi

# Output in requested format
if [ "$FORMAT" = "json" ]; then
  cat <<JSON
{"slug":"$SLUG","status":"$STATUS","tasksTotal":$TOTAL_TASKS,"tasksCompleted":$COMPLETED_TASKS,"completionPct":$COMPLETION_PCT,"nextAction":"$NEXT_ACTION"}
JSON
else
  # Text format
  cat <<TEXT
Project: $SLUG
Status: $STATUS
Tasks: $COMPLETED_TASKS/$TOTAL_TASKS complete ($COMPLETION_PCT%)
Next action: $NEXT_ACTION
TEXT

  # Add suggestion if mismatch detected
  if [ "$COMPLETION_PCT" -eq 100 ] && [ "$STATUS" = "active" ]; then
    echo ""
    echo "Suggestion: All tasks complete. Consider running: project-complete.sh $SLUG"
  fi
fi

exit 0

