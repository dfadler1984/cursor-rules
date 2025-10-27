#!/usr/bin/env bash
# Tests for coordination-task-assign.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/task-assign.sh"

# Test fixtures
setup() {
  TEST_DIR=$(mktemp -d)
  mkdir -p "$TEST_DIR/tmp/coordination/tasks/"{pending,assigned}
  
  # Create sample task
  cat > "$TEST_DIR/tmp/coordination/tasks/pending/task-001.json" <<'EOF'
{
  "id": "task-001",
  "type": "test",
  "description": "Test task",
  "context": {
    "targetFiles": ["test.md"],
    "outputFiles": ["output.md"],
    "requirements": []
  },
  "acceptance": {
    "criteria": []
  },
  "status": "pending",
  "assignedTo": null,
  "createdAt": "2025-01-26T12:00:00Z",
  "dependencies": []
}
EOF
}

teardown() {
  rm -rf "$TEST_DIR"
}

# Test: Missing task ID
test_missing_task_id() {
  setup
  cd "$TEST_DIR"
  
  if bash "$SCRIPT" 2>/dev/null; then
    echo "FAIL: Should error on missing task ID"
    teardown
    return 1
  fi
  
  teardown
  echo "PASS: Missing task ID"
}

# Test: Missing worker ID
test_missing_worker_id() {
  setup
  cd "$TEST_DIR"
  
  if bash "$SCRIPT" task-001 2>/dev/null; then
    echo "FAIL: Should error on missing worker ID"
    teardown
    return 1
  fi
  
  teardown
  echo "PASS: Missing worker ID"
}

# Test: Task not found
test_task_not_found() {
  setup
  cd "$TEST_DIR"
  
  if bash "$SCRIPT" task-999 worker-A 2>/dev/null; then
    echo "FAIL: Should error on missing task"
    teardown
    return 1
  fi
  
  teardown
  echo "PASS: Task not found"
}

# Test: Successful assignment
test_successful_assignment() {
  setup
  cd "$TEST_DIR"
  
  if ! bash "$SCRIPT" task-001 worker-A >/dev/null 2>&1; then
    echo "FAIL: Assignment should succeed"
    teardown
    return 1
  fi
  
  # Verify task moved to assigned
  if [[ ! -f "tmp/coordination/tasks/assigned/task-001.json" ]]; then
    echo "FAIL: Task not in assigned directory"
    teardown
    return 1
  fi
  
  # Verify task removed from pending
  if [[ -f "tmp/coordination/tasks/pending/task-001.json" ]]; then
    echo "FAIL: Task still in pending directory"
    teardown
    return 1
  fi
  
  # Verify JSON updated
  WORKER=$(jq -r '.assignedTo' "tmp/coordination/tasks/assigned/task-001.json")
  STATUS=$(jq -r '.status' "tmp/coordination/tasks/assigned/task-001.json")
  
  if [[ "$WORKER" != "worker-A" ]]; then
    echo "FAIL: Worker not set correctly (got: $WORKER)"
    teardown
    return 1
  fi
  
  if [[ "$STATUS" != "assigned" ]]; then
    echo "FAIL: Status not updated (got: $STATUS)"
    teardown
    return 1
  fi
  
  teardown
  echo "PASS: Successful assignment"
}

# Run tests
echo "Running coordination-task-assign.sh tests..."
test_missing_task_id
test_missing_worker_id
test_task_not_found
test_successful_assignment
echo "All tests passed!"

