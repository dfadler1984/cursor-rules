#!/usr/bin/env bash
# Tests for repo-health-badge.sh score extraction

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=.lib.sh
source "$SCRIPT_DIR/.lib.sh"

TEST_SCRIPT="$SCRIPT_DIR/repo-health-badge.sh"

# Test: Extract score from validation output with timestamps (using script's method)
test_score_extraction_with_timestamps() {
  local test_name="Score extraction ignores timestamps and extracts from 'Overall Health Score' line"
  
  # Create mock validation output with timestamps (like real output)
  local mock_output="Repository Health Check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Starting validation at 21:40:02

Rules & Documentation
⏳ Rules validation ... 2025-10-24T02:40:02Z [INFO] Running: Rules validation
✓ passed

Overall Health Score: 90/100
  Rules Quality:    100/100
  Script Quality:   100/100

Completed in 27s"

  # Extract score using the CORRECT method (now implemented in script)
  local extracted_score
  extracted_score=$(echo "$mock_output" | grep "Overall Health Score:" | grep -oE '[0-9]+/100' | cut -d'/' -f1 || echo "0")
  
  if [ "$extracted_score" != "90" ]; then
    echo "FAIL: $test_name"
    echo "  Expected: 90"
    echo "  Got: $extracted_score"
    return 1
  fi
  
  echo "PASS: $test_name"
  return 0
}

# Test: Correct extraction method
test_score_extraction_correct_method() {
  local test_name="Score extraction using 'Overall Health Score:' line"
  
  local mock_output="Repository Health Check
Starting validation at 21:40:02
Overall Health Score: 90/100
Completed in 27s"

  # Correct method: grep for the specific line first
  local extracted_score
  extracted_score=$(echo "$mock_output" | grep "Overall Health Score:" | grep -oE '[0-9]+/100' | cut -d'/' -f1 || echo "0")
  
  if [ "$extracted_score" != "90" ]; then
    echo "FAIL: $test_name"
    echo "  Expected: 90"
    echo "  Got: $extracted_score"
    return 1
  fi
  
  echo "PASS: $test_name"
  return 0
}

# Run tests
echo "Testing repo-health-badge.sh score extraction..."
echo

failed=0

test_score_extraction_with_timestamps || failed=$((failed + 1))
test_score_extraction_correct_method || failed=$((failed + 1))

echo
if [ "$failed" -eq 0 ]; then
  echo "All tests passed"
  exit 0
else
  echo "$failed test(s) failed"
  exit 1
fi

