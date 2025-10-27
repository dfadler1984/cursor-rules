#!/usr/bin/env bash
# Mark a task as complete (move in-progress → completed)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../.lib.sh
source "$SCRIPT_DIR/../.lib.sh"

usage() {
  print_help_header "task-complete.sh" "Mark a task as complete"
  print_usage "task-complete.sh <task-id>"
  echo ""
  echo "Arguments:"
  echo "  task-id    Task identifier (e.g., task-001)"
  echo ""
  echo "Options:"
  echo "  -h, --help    Show this help and exit"
  print_exit_codes
  echo ""
  echo "Examples:"
  echo "  bash task-complete.sh task-001"
}

# Parse args
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    *) break ;;
  esac
done

TASK_ID="${1:-}"

# Error handling
if [[ -z "$TASK_ID" ]]; then
  echo "Error: Task ID required" >&2
  usage >&2
  exit 2
fi

# Paths
COORD_DIR="tmp/coordination"
IN_PROGRESS_DIR="$COORD_DIR/tasks/in-progress"
COMPLETED_DIR="$COORD_DIR/tasks/completed"
TASK_FILE="$TASK_ID.json"

# Check in-progress directory first
if [[ -f "$IN_PROGRESS_DIR/$TASK_FILE" ]]; then
  mv "$IN_PROGRESS_DIR/$TASK_FILE" "$COMPLETED_DIR/$TASK_FILE"
  echo "✓ Task $TASK_ID marked as complete"
  exit 0
fi

# Check if already in completed (not an error, just report)
if [[ -f "$COMPLETED_DIR/$TASK_FILE" ]]; then
  echo "✓ Task $TASK_ID already complete"
  exit 0
fi

# Task not found in either location
echo "Error: Task not found: $TASK_FILE" >&2
echo "  Checked: $IN_PROGRESS_DIR" >&2
echo "  Checked: $COMPLETED_DIR" >&2
exit 1

