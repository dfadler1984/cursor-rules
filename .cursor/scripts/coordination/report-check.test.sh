#!/usr/bin/env bash
# Tests for coordination-report-check.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/report-check.sh"

# Test fixtures
setup() {
  TEST_DIR=$(mktemp -d)
  mkdir -p "$TEST_DIR/tmp/coordination/reports"
}

teardown() {
  rm -rf "$TEST_DIR"
}

# Test: No reports directory
test_no_reports_dir() {
  TEST_DIR=$(mktemp -d)
  cd "$TEST_DIR"
  
  if bash "$SCRIPT" 2>/dev/null; then
    echo "FAIL: Should error when reports dir missing"
    rm -rf "$TEST_DIR"
    return 1
  fi
  
  rm -rf "$TEST_DIR"
  echo "PASS: No reports directory"
}

# Test: Empty reports directory
test_empty_reports() {
  setup
  cd "$TEST_DIR"
  
  OUTPUT=$(bash "$SCRIPT")
  if [[ "$OUTPUT" != "No reports found" ]]; then
    echo "FAIL: Should report no reports found"
    teardown
    return 1
  fi
  
  teardown
  echo "PASS: Empty reports directory"
}

# Test: Single report found
test_single_report() {
  setup
  cd "$TEST_DIR"
  
  # Create sample report
  cat > "tmp/coordination/reports/task-001-report.json" <<'EOF'
{
  "taskId": "task-001",
  "workerId": "worker-A",
  "status": "completed",
  "deliverables": ["output.md"],
  "contextEfficiencyScore": 5,
  "completedAt": "2025-01-26T12:00:00Z"
}
EOF
  
  OUTPUT=$(bash "$SCRIPT")
  if [[ "$OUTPUT" != *"Found 1 report(s)"* ]]; then
    echo "FAIL: Should report 1 report found (got: $OUTPUT)"
    teardown
    return 1
  fi
  
  if [[ "$OUTPUT" != *"task-001"* ]]; then
    echo "FAIL: Should include task-001 in output"
    teardown
    return 1
  fi
  
  teardown
  echo "PASS: Single report found"
}

# Test: Multiple reports found
test_multiple_reports() {
  setup
  cd "$TEST_DIR"
  
  # Create multiple reports
  for i in 1 2 3; do
    cat > "tmp/coordination/reports/task-00$i-report.json" <<EOF
{
  "taskId": "task-00$i",
  "workerId": "worker-A",
  "status": "completed",
  "deliverables": ["output$i.md"],
  "contextEfficiencyScore": 5,
  "completedAt": "2025-01-26T12:00:00Z"
}
EOF
  done
  
  OUTPUT=$(bash "$SCRIPT")
  if [[ "$OUTPUT" != *"Found 3 report(s)"* ]]; then
    echo "FAIL: Should report 3 reports found (got: $OUTPUT)"
    teardown
    return 1
  fi
  
  teardown
  echo "PASS: Multiple reports found"
}

# Test: JSON format output
test_json_format() {
  setup
  cd "$TEST_DIR"
  
  cat > "tmp/coordination/reports/task-001-report.json" <<'EOF'
{
  "taskId": "task-001",
  "workerId": "worker-A",
  "status": "completed",
  "deliverables": ["output.md"],
  "contextEfficiencyScore": 5,
  "completedAt": "2025-01-26T12:00:00Z"
}
EOF
  
  OUTPUT=$(bash "$SCRIPT" --format json)
  if ! echo "$OUTPUT" | jq empty 2>/dev/null; then
    echo "FAIL: Output should be valid JSON"
    teardown
    return 1
  fi
  
  COUNT=$(echo "$OUTPUT" | jq '.count')
  if [[ "$COUNT" != "1" ]]; then
    echo "FAIL: JSON count should be 1 (got: $COUNT)"
    teardown
    return 1
  fi
  
  teardown
  echo "PASS: JSON format output"
}

# Run tests
echo "Running coordination-report-check.sh tests..."
test_no_reports_dir
test_empty_reports
test_single_report
test_multiple_reports
test_json_format
echo "All tests passed!"

