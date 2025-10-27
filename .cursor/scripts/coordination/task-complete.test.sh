#!/usr/bin/env bash
# Tests for coordination-task-complete.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/task-complete.sh"

# Test fixtures
setup() {
  TEST_DIR=$(mktemp -d)
  mkdir -p "$TEST_DIR/tmp/coordination/tasks/"{in-progress,completed}
  
  # Create sample task in in-progress
  cat > "$TEST_DIR/tmp/coordination/tasks/in-progress/task-001.json" <<'EOF'
{
  "id": "task-001",
  "type": "test",
  "status": "in-progress",
  "assignedTo": "worker-A"
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

# Test: Task not found
test_task_not_found() {
  setup
  cd "$TEST_DIR"
  
  if bash "$SCRIPT" task-999 2>/dev/null; then
    echo "FAIL: Should error on missing task"
    teardown
    return 1
  fi
  
  teardown
  echo "PASS: Task not found"
}

# Test: Successful completion
test_successful_completion() {
  setup
  cd "$TEST_DIR"
  
  if ! bash "$SCRIPT" task-001 >/dev/null 2>&1; then
    echo "FAIL: Completion should succeed"
    teardown
    return 1
  fi
  
  # Verify task moved to completed
  if [[ ! -f "tmp/coordination/tasks/completed/task-001.json" ]]; then
    echo "FAIL: Task not in completed directory"
    teardown
    return 1
  fi
  
  # Verify task removed from in-progress
  if [[ -f "tmp/coordination/tasks/in-progress/task-001.json" ]]; then
    echo "FAIL: Task still in in-progress directory"
    teardown
    return 1
  fi
  
  teardown
  echo "PASS: Successful completion"
}

# Test: Already completed (idempotent)
test_already_completed() {
  setup
  cd "$TEST_DIR"
  
  # Move task to completed first
  mv "tmp/coordination/tasks/in-progress/task-001.json" \
     "tmp/coordination/tasks/completed/task-001.json"
  
  # Should succeed (idempotent)
  if ! bash "$SCRIPT" task-001 >/dev/null 2>&1; then
    echo "FAIL: Should succeed when already complete"
    teardown
    return 1
  fi
  
  OUTPUT=$(bash "$SCRIPT" task-001 2>&1)
  if [[ "$OUTPUT" != *"already complete"* ]]; then
    echo "FAIL: Should report already complete"
    teardown
    return 1
  fi
  
  teardown
  echo "PASS: Already completed (idempotent)"
}

# Run tests
echo "Running coordination-task-complete.sh tests..."
test_missing_task_id
test_task_not_found
test_successful_completion
test_already_completed
echo "All tests passed!"

