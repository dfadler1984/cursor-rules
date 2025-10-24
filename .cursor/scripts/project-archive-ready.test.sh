#!/usr/bin/env bash
# project-archive-ready.test.sh — Tests for project-archive-ready.sh
#
# Test owner: project-archive-ready.sh
# Test scope: Validate pre-archival checks, auto-fix capabilities, and archival workflow

set -euo pipefail

# Test setup
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly TEST_SCRIPT="${SCRIPT_DIR}/project-archive-ready.sh"

# Test utilities
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

declare -i TESTS_RUN=0
declare -i TESTS_PASSED=0
declare -i TESTS_FAILED=0

# Test fixture setup
setup_test_project() {
  local project_name="$1"
  local project_dir="${REPO_ROOT}/docs/projects/${project_name}"
  
  mkdir -p "$project_dir"
  
  # Create minimal valid project
  cat > "${project_dir}/erd.md" <<EOF
---
status: active
owner: test
lastUpdated: $(date +%Y-%m-%d)
---

# Test Project ERD
EOF

  cat > "${project_dir}/tasks.md" <<EOF
# Tasks

## Phase 1: Test

- [x] Task 1

## Related Files

- None
EOF

  cat > "${project_dir}/README.md" <<EOF
# Test Project

Status: Complete
EOF

  echo "$project_dir"
}

cleanup_test_project() {
  local project_name="$1"
  rm -rf "${REPO_ROOT}/docs/projects/${project_name}"
  rm -rf "${REPO_ROOT}/docs/projects/_archived/2025/${project_name}"
}

assert_exit_code() {
  local expected="$1"
  local actual="$2"
  local test_name="$3"
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ "$actual" -eq "$expected" ]]; then
    echo -e "${GREEN}✓${NC} $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    echo -e "${RED}✗${NC} $test_name (expected exit $expected, got $actual)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

assert_file_exists() {
  local file="$1"
  local test_name="$2"
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ -f "$file" ]]; then
    echo -e "${GREEN}✓${NC} $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    echo -e "${RED}✗${NC} $test_name (file not found: $file)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

assert_file_contains() {
  local file="$1"
  local pattern="$2"
  local test_name="$3"
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if grep -q "$pattern" "$file" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    echo -e "${RED}✗${NC} $test_name (pattern not found: $pattern)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

# Test: Script exists and is executable
test_script_exists() {
  assert_file_exists "$TEST_SCRIPT" "Script file exists"
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ -x "$TEST_SCRIPT" ]]; then
    echo -e "${GREEN}✓${NC} Script is executable"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "${RED}✗${NC} Script is not executable"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

# Test: Help flag works
test_help_flag() {
  local exit_code=0
  "$TEST_SCRIPT" --help >/dev/null 2>&1 || exit_code=$?
  assert_exit_code 0 "$exit_code" "Help flag returns exit 0"
}

# Test: Missing required arguments
test_missing_project_arg() {
  local exit_code=0
  "$TEST_SCRIPT" --year 2025 2>/dev/null || exit_code=$?
  assert_exit_code 2 "$exit_code" "Missing --project returns exit 2"
}

test_missing_year_arg() {
  local exit_code=0
  "$TEST_SCRIPT" --project test 2>/dev/null || exit_code=$?
  assert_exit_code 2 "$exit_code" "Missing --year returns exit 2"
}

# Test: Invalid year format
test_invalid_year() {
  local exit_code=0
  "$TEST_SCRIPT" --project test --year 25 2>/dev/null || exit_code=$?
  assert_exit_code 2 "$exit_code" "Invalid year format returns exit 2"
}

# Test: Non-existent project
test_nonexistent_project() {
  local exit_code=0
  "$TEST_SCRIPT" --project nonexistent-project-12345 --year 2025 2>/dev/null || exit_code=$?
  assert_exit_code 2 "$exit_code" "Non-existent project returns exit 2"
}

# Test: Dry run mode
test_dry_run_mode() {
  local project="test-dry-run-$$"
  local project_dir
  project_dir=$(setup_test_project "$project")
  
  # Add final-summary.md to make it valid
  cat > "${project_dir}/final-summary.md" <<EOF
---
project: $project
status: complete
dateCompleted: $(date +%Y-%m-%d)
owner: test
template: project-lifecycle/final-summary
version: 1.0.0
last-updated: $(date +%Y-%m-%d)
---

# Test Summary
EOF

  # Add Carryovers section
  cat >> "${project_dir}/tasks.md" <<EOF

## Carryovers

None.
EOF

  local exit_code=0
  "$TEST_SCRIPT" --project "$project" --year 2025 --dry-run >/dev/null 2>&1 || exit_code=$?
  
  # Dry run should succeed but not actually archive
  assert_exit_code 0 "$exit_code" "Dry run mode succeeds"
  
  # Verify project not actually archived
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ ! -d "${REPO_ROOT}/docs/projects/_archived/2025/${project}" ]]; then
    echo -e "${GREEN}✓${NC} Dry run does not archive project"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "${RED}✗${NC} Dry run should not archive project"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
  
  cleanup_test_project "$project"
}

# Test: Missing final-summary.md detection
test_missing_final_summary_detection() {
  local project="test-no-summary-$$"
  setup_test_project "$project" >/dev/null
  
  local output
  output=$("$TEST_SCRIPT" --project "$project" --year 2025 --dry-run 2>&1) || true
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if echo "$output" | grep -q "Missing: final-summary.md"; then
    echo -e "${GREEN}✓${NC} Detects missing final-summary.md"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "${RED}✗${NC} Should detect missing final-summary.md"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
  
  cleanup_test_project "$project"
}

# Test: Missing Carryovers section detection
test_missing_carryovers_detection() {
  local project="test-no-carryovers-$$"
  local project_dir
  project_dir=$(setup_test_project "$project")
  
  # Add final-summary.md but no Carryovers
  cat > "${project_dir}/final-summary.md" <<EOF
---
project: $project
status: complete
dateCompleted: $(date +%Y-%m-%d)
owner: test
template: project-lifecycle/final-summary
version: 1.0.0
last-updated: $(date +%Y-%m-%d)
---

# Test Summary
EOF

  local output
  output=$("$TEST_SCRIPT" --project "$project" --year 2025 --dry-run 2>&1) || true
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if echo "$output" | grep -q "Missing: Carryovers section"; then
    echo -e "${GREEN}✓${NC} Detects missing Carryovers section"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "${RED}✗${NC} Should detect missing Carryovers section"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
  
  cleanup_test_project "$project"
}

# Test: Detects active artifacts
test_detects_active_artifacts() {
  local project="test-active-artifacts-$$"
  local project_dir
  project_dir=$(setup_test_project "$project")
  
  # Create a file that looks like an active artifact
  cat > "${project_dir}/test-suite.md" <<EOF
# Test Suite

Test cases for validation.
EOF

  local output
  output=$("$TEST_SCRIPT" --project "$project" --year 2025 --dry-run 2>&1) || true
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if echo "$output" | grep -q "active artifacts"; then
    echo -e "${GREEN}✓${NC} Detects active artifacts"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "${RED}✗${NC} Should detect active artifacts"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
  
  cleanup_test_project "$project"
}

# Test: Auto-fix adds Carryovers section
test_autofix_carryovers() {
  local project="test-autofix-carryovers-$$"
  local project_dir
  project_dir=$(setup_test_project "$project")
  
  # Add final-summary.md
  cat > "${project_dir}/final-summary.md" <<EOF
---
project: $project
status: complete
dateCompleted: $(date +%Y-%m-%d)
owner: test
template: project-lifecycle/final-summary
version: 1.0.0
last-updated: $(date +%Y-%m-%d)
---

# Test Summary

## Retrospective

Test retrospective.
EOF

  # Run with auto-fix (no dry-run to actually make changes)
  # Use validation failure to stop before archival
  "$TEST_SCRIPT" --project "$project" --year 2025 --auto-fix --no-interactive >/dev/null 2>&1 || true
  
  # Check if Carryovers section was added
  assert_file_contains "${project_dir}/tasks.md" "## Carryovers" "Auto-fix adds Carryovers section"
  
  cleanup_test_project "$project"
}

# Main test runner
main() {
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Testing: project-archive-ready.sh"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  
  # Run tests
  test_script_exists
  test_help_flag
  test_missing_project_arg
  test_missing_year_arg
  test_invalid_year
  test_nonexistent_project
  test_dry_run_mode
  test_missing_final_summary_detection
  test_missing_carryovers_detection
  test_detects_active_artifacts
  test_autofix_carryovers
  
  # Summary
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Test Results"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Tests run:    $TESTS_RUN"
  echo "Tests passed: $TESTS_PASSED"
  echo "Tests failed: $TESTS_FAILED"
  echo ""
  
  if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed${NC}"
    exit 0
  else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
  fi
}

main "$@"

