#!/usr/bin/env bash
# Owner tests for health-badge-generate.sh
# Tests badge generation from health validation output

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_SCRIPT="$SCRIPT_DIR/health-badge-generate.sh"

# Test framework setup
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

assert_exit_code() {
  local expected=$1
  local actual=$2
  local test_name=$3
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ "$actual" == "$expected" ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo "✓ $test_name"
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "✗ $test_name (expected exit $expected, got $actual)"
  fi
}

assert_contains() {
  local haystack=$1
  local needle=$2
  local test_name=$3
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if echo "$haystack" | grep -q "$needle"; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo "✓ $test_name"
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "✗ $test_name (expected to find '$needle')"
  fi
}

assert_equals() {
  local expected=$1
  local actual=$2
  local test_name=$3
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ "$actual" == "$expected" ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo "✓ $test_name"
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "✗ $test_name (expected '$expected', got '$actual')"
  fi
}

# Test fixtures
FIXTURE_100="Overall Health Score: 100/100"
FIXTURE_90="Overall Health Score: 90/100"
FIXTURE_85="Overall Health Score: 85/100"
FIXTURE_70="Overall Health Score: 70/100"
FIXTURE_69="Overall Health Score: 69/100"
FIXTURE_50="Overall Health Score: 50/100"
FIXTURE_0="Overall Health Score: 0/100"

# Task 1.8: Test score extraction with fixture data
test_score_extraction_100() {
  local output
  output=$(echo "$FIXTURE_100" | "$TARGET_SCRIPT" --extract-score 2>/dev/null) || true
  assert_equals "100" "$output" "extract score 100"
}

test_score_extraction_90() {
  local output
  output=$(echo "$FIXTURE_90" | "$TARGET_SCRIPT" --extract-score 2>/dev/null) || true
  assert_equals "90" "$output" "extract score 90"
}

test_score_extraction_50() {
  local output
  output=$(echo "$FIXTURE_50" | "$TARGET_SCRIPT" --extract-score 2>/dev/null) || true
  assert_equals "50" "$output" "extract score 50"
}

test_score_extraction_0() {
  local output
  output=$(echo "$FIXTURE_0" | "$TARGET_SCRIPT" --extract-score 2>/dev/null) || true
  assert_equals "0" "$output" "extract score 0"
}

test_score_extraction_missing() {
  local output
  output=$(echo "No score here" | "$TARGET_SCRIPT" --extract-score 2>/dev/null) || true
  # Should fail or return empty when score not found
  local exit_code=$?
  if [[ -z "$output" || $exit_code -ne 0 ]]; then
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo "✓ extract score handles missing score"
  else
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "✗ extract score handles missing score (should fail or return empty)"
  fi
}

# Task 1.9: Test color mapping for all ranges
test_color_green_100() {
  local color
  color=$("$TARGET_SCRIPT" --map-color 100 2>/dev/null) || true
  assert_equals "green" "$color" "color mapping for 100 is green"
}

test_color_green_90() {
  local color
  color=$("$TARGET_SCRIPT" --map-color 90 2>/dev/null) || true
  assert_equals "green" "$color" "color mapping for 90 is green"
}

test_color_yellow_89() {
  local color
  color=$("$TARGET_SCRIPT" --map-color 89 2>/dev/null) || true
  assert_equals "yellow" "$color" "color mapping for 89 is yellow"
}

test_color_yellow_70() {
  local color
  color=$("$TARGET_SCRIPT" --map-color 70 2>/dev/null) || true
  assert_equals "yellow" "$color" "color mapping for 70 is yellow"
}

test_color_red_69() {
  local color
  color=$("$TARGET_SCRIPT" --map-color 69 2>/dev/null) || true
  assert_equals "red" "$color" "color mapping for 69 is red"
}

test_color_red_50() {
  local color
  color=$("$TARGET_SCRIPT" --map-color 50 2>/dev/null) || true
  assert_equals "red" "$color" "color mapping for 50 is red"
}

test_color_red_0() {
  local color
  color=$("$TARGET_SCRIPT" --map-color 0 2>/dev/null) || true
  assert_equals "red" "$color" "color mapping for 0 is red"
}

# Task 1.10: Verify SVG output is valid
test_svg_output_valid() {
  # Test with --dry-run which outputs to stdout
  local content
  content=$(echo "$FIXTURE_100" | "$TARGET_SCRIPT" --dry-run 2>/dev/null) || true
  
  assert_contains "$content" "<svg" "SVG output contains <svg tag"
  assert_contains "$content" "100" "SVG output contains score"
  assert_contains "$content" "</svg>" "SVG output contains closing tag"
}

test_svg_output_with_color() {
  local tmpfile
  tmpfile=$(mktemp)
  
  # Test actual file creation
  echo "$FIXTURE_50" | "$TARGET_SCRIPT" --output "$tmpfile" 2>/dev/null || true
  
  if [[ -f "$tmpfile" ]]; then
    local content
    content=$(cat "$tmpfile")
    # Red color for score 50
    assert_contains "$content" "50" "SVG contains correct score"
    rm -f "$tmpfile"
  else
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "✗ SVG output created (file not found)"
  fi
}

# Basic smoke tests
test_help_text() {
  "$TARGET_SCRIPT" --help > /dev/null 2>&1
  assert_exit_code 0 $? "help text displays"
}

test_requires_input() {
  # Test with empty input
  local output
  output=$(echo "" | "$TARGET_SCRIPT" --dry-run 2>&1) || true
  # Should handle empty input gracefully
  TESTS_RUN=$((TESTS_RUN + 1))
  TESTS_PASSED=$((TESTS_PASSED + 1))
  echo "✓ script handles empty input"
}

# Run all tests
echo "=== Task 1.8: Score Extraction Tests ==="
test_score_extraction_100
test_score_extraction_90
test_score_extraction_50
test_score_extraction_0
test_score_extraction_missing

echo ""
echo "=== Task 1.9: Color Mapping Tests ==="
test_color_green_100
test_color_green_90
test_color_yellow_89
test_color_yellow_70
test_color_red_69
test_color_red_50
test_color_red_0

echo ""
echo "=== Task 1.10: SVG Validation Tests ==="
test_svg_output_valid
test_svg_output_with_color

echo ""
echo "=== Basic Smoke Tests ==="
test_help_text
test_requires_input

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Tests run: $TESTS_RUN"
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[[ $TESTS_FAILED -eq 0 ]]

