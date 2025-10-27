#!/usr/bin/env bash
# Assign a task to a worker (move pending → assigned, update JSON)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../.lib.sh
source "$SCRIPT_DIR/../.lib.sh"

usage() {
  print_help_header "task-assign.sh" "Assign a task to a worker"
  print_usage "task-assign.sh <task-id> <worker-id>"
  
  cat <<'HELP'
Arguments:
  task-id    Task identifier (e.g., task-001)
  worker-id  Worker identifier (e.g., worker-A)

What it does:
  - Moves task JSON from pending/ to assigned/
  - Updates JSON: status="assigned", assignedTo="<worker-id>"
  - Atomic operation (no per-file consent needed)

Options:
  -h, --help    Show this help and exit
HELP
  
  print_exit_codes
  
  cat <<'EXAMPLES'
Examples:
  # Assign task-001 to worker-A
  bash task-assign.sh task-001 worker-A
EXAMPLES
}

# Parse args
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    *) break ;;
  esac
done

TASK_ID="${1:-}"
WORKER_ID="${2:-}"

# Error handling
if [[ -z "$TASK_ID" ]]; then
  echo "Error: Task ID required" >&2
  usage >&2
  exit 2
fi

if [[ -z "$WORKER_ID" ]]; then
  echo "Error: Worker ID required" >&2
  usage >&2
  exit 2
fi

# Paths
COORD_DIR="tmp/coordination"
PENDING_DIR="$COORD_DIR/tasks/pending"
ASSIGNED_DIR="$COORD_DIR/tasks/assigned"
TASK_FILE="$TASK_ID.json"

# Validate task exists in pending
if [[ ! -f "$PENDING_DIR/$TASK_FILE" ]]; then
  echo "Error: Task not found in pending: $TASK_FILE" >&2
  exit 1
fi

# Update JSON with worker assignment
TEMP_FILE=$(mktemp)
jq --arg worker "$WORKER_ID" \
   '.assignedTo = $worker | .status = "assigned"' \
   "$PENDING_DIR/$TASK_FILE" > "$TEMP_FILE"

# Move to assigned directory
mv "$TEMP_FILE" "$ASSIGNED_DIR/$TASK_FILE"
rm -f "$PENDING_DIR/$TASK_FILE"

echo "✓ Task $TASK_ID assigned to $WORKER_ID"
exit 0

