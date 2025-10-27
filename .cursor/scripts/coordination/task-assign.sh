#!/usr/bin/env bash
# Assign a task to a worker (move pending → assigned, update JSON)
# Usage: coordination-task-assign.sh <task-id> <worker-id>

set -euo pipefail

TASK_ID="${1:-}"
WORKER_ID="${2:-}"

# Error handling
if [[ -z "$TASK_ID" ]]; then
  echo "Error: Task ID required" >&2
  echo "Usage: coordination-task-assign.sh <task-id> <worker-id>" >&2
  exit 1
fi

if [[ -z "$WORKER_ID" ]]; then
  echo "Error: Worker ID required" >&2
  echo "Usage: coordination-task-assign.sh <task-id> <worker-id>" >&2
  exit 1
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

