#!/usr/bin/env bash
# Validate multi-chat coordination task JSON schema
# Usage: task-schema-validate.sh <task-file.json>
# Exit 0 if valid, 1 if invalid

set -euo pipefail

TASK_FILE="${1:-}"

if [[ -z "$TASK_FILE" ]]; then
  echo "Error: Task file required" >&2
  echo "Usage: task-schema-validate.sh <task-file.json>" >&2
  exit 1
fi

if [[ ! -f "$TASK_FILE" ]]; then
  echo "Error: File not found: $TASK_FILE" >&2
  exit 1
fi

# Check if valid JSON
if ! jq empty "$TASK_FILE" 2>/dev/null; then
  echo "Error: Invalid JSON in $TASK_FILE" >&2
  exit 1
fi

# Validate required fields
REQUIRED_FIELDS=(
  "id"
  "type"
  "description"
  "context"
  "acceptance"
  "status"
  "createdAt"
)

for field in "${REQUIRED_FIELDS[@]}"; do
  if ! jq -e ".$field" "$TASK_FILE" >/dev/null 2>&1; then
    echo "Error: Missing required field: $field" >&2
    exit 1
  fi
done

# Validate context subfields
CONTEXT_FIELDS=("targetFiles" "outputFiles" "requirements")
for field in "${CONTEXT_FIELDS[@]}"; do
  if ! jq -e ".context.$field" "$TASK_FILE" >/dev/null 2>&1; then
    echo "Error: Missing context field: $field" >&2
    exit 1
  fi
done

# Validate acceptance subfields
if ! jq -e ".acceptance.criteria" "$TASK_FILE" >/dev/null 2>&1; then
  echo "Error: Missing acceptance.criteria" >&2
  exit 1
fi

# Validate status is valid value
STATUS=$(jq -r '.status' "$TASK_FILE")
VALID_STATUSES=("pending" "assigned" "in-progress" "completed" "failed")

if [[ ! " ${VALID_STATUSES[*]} " =~ ${STATUS} ]]; then
  echo "Error: Invalid status: $STATUS" >&2
  echo "Valid statuses: ${VALID_STATUSES[*]}" >&2
  exit 1
fi

# Validate arrays are actually arrays
if ! jq -e '.context.targetFiles | type == "array"' "$TASK_FILE" >/dev/null 2>&1; then
  echo "Error: context.targetFiles must be an array" >&2
  exit 1
fi

if ! jq -e '.context.outputFiles | type == "array"' "$TASK_FILE" >/dev/null 2>&1; then
  echo "Error: context.outputFiles must be an array" >&2
  exit 1
fi

if ! jq -e '.acceptance.criteria | type == "array"' "$TASK_FILE" >/dev/null 2>&1; then
  echo "Error: acceptance.criteria must be an array" >&2
  exit 1
fi

# Success
echo "✓ Valid task schema: $TASK_FILE"
exit 0


