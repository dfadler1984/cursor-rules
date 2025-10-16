#!/usr/bin/env bash
# project-docs-organize.test.sh — Tests for project document organizer

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/project-docs-organize.sh"

# Test helpers
setup_test_project() {
  local project_name="$1"
  local test_dir="docs/projects/$project_name"
  
  mkdir -p "$test_dir"
  
  # Create sample files
  touch "$test_dir/README.md"
  touch "$test_dir/erd.md"
  touch "$test_dir/tasks.md"
  touch "$test_dir/findings.md"
  touch "$test_dir/discovery.md"
  touch "$test_dir/SESSION-SUMMARY-2025-10-15.md"
  touch "$test_dir/INTERIM-FINDINGS-2025-10-15.md"
  touch "$test_dir/h1-validation-protocol.md"
  touch "$test_dir/scalability-analysis.md"
  
  # Initialize as git repo if not already
  if [[ ! -d ".git" ]]; then
    git init
    git add "$test_dir"
    git commit -m "test: setup" || true
  fi
}

cleanup_test_project() {
  local project_name="$1"
  rm -rf "docs/projects/$project_name"
}

# Test: Help message
test_help() {
  echo "TEST: --help shows usage"
  
  if bash "$SCRIPT" --help | grep -q "Usage:"; then
    echo "  ✓ Help message displayed"
    return 0
  else
    echo "  ✗ Help message missing"
    return 1
  fi
}

# Test: Missing required argument
test_missing_project() {
  echo "TEST: Missing --project argument fails"
  
  if bash "$SCRIPT" 2>&1 | grep -q "Missing required --project"; then
    echo "  ✓ Error message shown"
    return 0
  else
    echo "  ✗ Should fail with missing argument"
    return 1
  fi
}

# Test: Invalid pattern
test_invalid_pattern() {
  echo "TEST: Invalid pattern fails"
  
  setup_test_project "test-invalid-pattern"
  
  if bash "$SCRIPT" --project test-invalid-pattern --pattern invalid 2>&1 | grep -q "Unknown pattern"; then
    echo "  ✓ Invalid pattern rejected"
    cleanup_test_project "test-invalid-pattern"
    return 0
  else
    echo "  ✗ Should reject invalid pattern"
    cleanup_test_project "test-invalid-pattern"
    return 1
  fi
}

# Test: Dry-run mode
test_dry_run() {
  echo "TEST: Dry-run doesn't modify files"
  
  setup_test_project "test-dry-run"
  
  # Count files before
  local before_count
  before_count=$(find docs/projects/test-dry-run -type f | wc -l | tr -d ' ')
  
  # Run in dry-run mode
  bash "$SCRIPT" --project test-dry-run --dry-run > /dev/null 2>&1 || true
  
  # Count files after
  local after_count
  after_count=$(find docs/projects/test-dry-run -type f | wc -l | tr -d ' ')
  
  if [[ "$before_count" -eq "$after_count" ]]; then
    echo "  ✓ No files modified in dry-run"
    cleanup_test_project "test-dry-run"
    return 0
  else
    echo "  ✗ Files were modified (before: $before_count, after: $after_count)"
    cleanup_test_project "test-dry-run"
    return 1
  fi
}

# Test: Subdirectories created
test_subdirs_created() {
  echo "TEST: Subdirectories created for pattern"
  
  setup_test_project "test-subdirs"
  
  # Run organizer (minimal pattern to avoid confirmation prompt)
  bash "$SCRIPT" --project test-subdirs --pattern minimal --dry-run > /dev/null 2>&1 || true
  
  # Check output mentions subdirectory
  if bash "$SCRIPT" --project test-subdirs --pattern minimal --dry-run 2>&1 | grep -q "archived-summaries"; then
    echo "  ✓ Subdirectory creation mentioned"
    cleanup_test_project "test-subdirs"
    return 0
  else
    echo "  ✗ Subdirectory not mentioned"
    cleanup_test_project "test-subdirs"
    return 1
  fi
}

# Test: Files categorized correctly
test_file_categorization() {
  echo "TEST: Files categorized by pattern"
  
  setup_test_project "test-categorization"
  
  # Check that session summaries are categorized as archived
  if bash "$SCRIPT" --project test-categorization --pattern minimal --dry-run 2>&1 | grep -q "SESSION-SUMMARY.*archived-summaries"; then
    echo "  ✓ Session summary categorized correctly"
    cleanup_test_project "test-categorization"
    return 0
  else
    echo "  ✗ File categorization incorrect"
    cleanup_test_project "test-categorization"
    return 1
  fi
}

# Test: Keep files in root
test_keep_in_root() {
  echo "TEST: Core files stay in root"
  
  setup_test_project "test-keep-root"
  
  # Verify README.md, erd.md, tasks.md, findings.md not moved
  output=$(bash "$SCRIPT" --project test-keep-root --dry-run 2>&1 || true)
  
  if echo "$output" | grep -q "README.md.*→" || \
     echo "$output" | grep -q "erd.md.*→" || \
     echo "$output" | grep -q "tasks.md.*→" || \
     echo "$output" | grep -q "findings.md.*→"; then
    echo "  ✗ Core files should stay in root"
    cleanup_test_project "test-keep-root"
    return 1
  else
    echo "  ✓ Core files kept in root"
    cleanup_test_project "test-keep-root"
    return 0
  fi
}

# Test: Pattern differences
test_patterns_differ() {
  echo "TEST: investigation vs minimal patterns differ"
  
  setup_test_project "test-patterns"
  
  local investigation_output
  local minimal_output
  
  investigation_output=$(bash "$SCRIPT" --project test-patterns --pattern investigation --dry-run 2>&1 || true)
  minimal_output=$(bash "$SCRIPT" --project test-patterns --pattern minimal --dry-run 2>&1 || true)
  
  # Investigation should mention analysis/ subdirectory
  if echo "$investigation_output" | grep -q "analysis/" && \
     ! echo "$minimal_output" | grep -q "analysis/"; then
    echo "  ✓ Patterns create different structures"
    cleanup_test_project "test-patterns"
    return 0
  else
    echo "  ✗ Patterns should differ"
    cleanup_test_project "test-patterns"
    return 1
  fi
}

# Run all tests
main() {
  echo "Running project-docs-organize.sh tests..."
  echo
  
  local passed=0
  local failed=0
  
  for test_func in \
    test_help \
    test_missing_project \
    test_invalid_pattern \
    test_dry_run \
    test_subdirs_created \
    test_file_categorization \
    test_keep_in_root \
    test_patterns_differ; do
    
    if $test_func; then
      ((passed++))
    else
      ((failed++))
    fi
    echo
  done
  
  echo "Results: $passed passed, $failed failed"
  
  if [[ $failed -eq 0 ]]; then
    echo "✅ All tests passed"
    return 0
  else
    echo "❌ Some tests failed"
    return 1
  fi
}

main "$@"

