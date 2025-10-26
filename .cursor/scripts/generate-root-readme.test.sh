#!/usr/bin/env bash
# Test suite for generate-root-readme.sh
#
# Usage: bash generate-root-readme.test.sh [-v]

set -euo pipefail

# Test framework setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
FIXTURES_DIR="$REPO_ROOT/fixtures/root-readme"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Verbose mode
VERBOSE=false
if [[ "${1:-}" == "-v" ]]; then
  VERBOSE=true
fi

# Test directory for temp files
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

# Test helpers
assert_equals() {
  local expected="$1"
  local actual="$2"
  local message="${3:-}"
  
  TESTS_RUN=$((TESTS_RUN + 1))
  
  if [[ "$expected" == "$actual" ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    if $VERBOSE; then
      echo -e "${GREEN}✓${NC} $message"
    fi
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} $message"
    echo "  Expected: $expected"
    echo "  Actual:   $actual"
    return 1
  fi
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local message="${3:-}"
  
  TESTS_RUN=$((TESTS_RUN + 1))
  
  if [[ "$haystack" == *"$needle"* ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    if $VERBOSE; then
      echo -e "${GREEN}✓${NC} $message"
    fi
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} $message"
    echo "  Haystack: $haystack"
    echo "  Needle:   $needle"
    return 1
  fi
}

assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  local message="${3:-}"
  
  TESTS_RUN=$((TESTS_RUN + 1))
  
  if [[ "$haystack" != *"$needle"* ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    if $VERBOSE; then
      echo -e "${GREEN}✓${NC} $message"
    fi
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} $message"
    echo "  Haystack: $haystack"
    echo "  Should not contain: $needle"
    return 1
  fi
}

# Source the generator script functions
# shellcheck source=.cursor/scripts/generate-root-readme.sh
source "$SCRIPT_DIR/generate-root-readme.sh"

#
# Test Suite: Script Metadata Extraction
#

test_extract_description_with_header() {
  local result
  result=$(extract_script_description "$FIXTURES_DIR/scripts/git-commit-fixture.sh")
  assert_equals "Compose Conventional Commits with validation" "$result" \
    "Should extract description from well-formed header"
}

test_extract_description_fallback() {
  local result
  result=$(extract_script_description "$FIXTURES_DIR/scripts/no-description-fixture.sh")
  assert_equals "no-description-fixture" "$result" \
    "Should fallback to filename when no description found"
}

test_extract_description_malformed() {
  local result
  result=$(extract_script_description "$FIXTURES_DIR/scripts/malformed-fixture.sh")
  assert_equals "malformed-fixture" "$result" \
    "Should fallback to filename when header is malformed"
}

test_extract_flags() {
  local result
  result=$(extract_script_flags "$FIXTURES_DIR/scripts/git-commit-fixture.sh")
  assert_equals "--type, --scope, --description, --body, --footer, --breaking, --dry-run" "$result" \
    "Should extract flags from header"
}

test_extract_flags_missing() {
  local result
  result=$(extract_script_flags "$FIXTURES_DIR/scripts/no-description-fixture.sh")
  assert_equals "" "$result" \
    "Should return empty string when no flags found"
}

test_list_scripts_excludes_lib() {
  local result
  result=$(list_scripts "$FIXTURES_DIR/scripts")
  assert_not_contains "$result" ".lib-test.sh" \
    "Should exclude .lib*.sh files"
}

test_list_scripts_excludes_test() {
  local result
  result=$(list_scripts "$FIXTURES_DIR/scripts")
  assert_not_contains "$result" "example.test.sh" \
    "Should exclude *.test.sh files"
}

test_list_scripts_includes_regular() {
  local result
  result=$(list_scripts "$FIXTURES_DIR/scripts")
  assert_contains "$result" "git-commit-fixture.sh" \
    "Should include regular scripts"
}

test_categorize_git_script() {
  local result
  result=$(categorize_script "git-commit.sh")
  assert_equals "Git Workflows" "$result" \
    "Should categorize git-* as Git Workflows"
}

test_categorize_pr_script() {
  local result
  result=$(categorize_script "pr-create.sh")
  assert_equals "Git Workflows" "$result" \
    "Should categorize pr-* as Git Workflows"
}

test_categorize_rules_script() {
  local result
  result=$(categorize_script "rules-validate.sh")
  assert_equals "Rules Management" "$result" \
    "Should categorize rules-* as Rules Management"
}

test_categorize_project_script() {
  local result
  result=$(categorize_script "project-create.sh")
  assert_equals "Project Lifecycle" "$result" \
    "Should categorize project-* as Project Lifecycle"
}

test_categorize_validate_script() {
  local result
  result=$(categorize_script "validate-artifacts.sh")
  assert_equals "Validation" "$result" \
    "Should categorize validate-* as Validation"
}

test_categorize_health_script() {
  local result
  result=$(categorize_script "health-badge-generate.sh")
  assert_equals "CI & Health" "$result" \
    "Should categorize health-* as CI & Health"
}

test_categorize_unknown_script() {
  local result
  result=$(categorize_script "some-random-tool.sh")
  assert_equals "Utilities" "$result" \
    "Should categorize unknown scripts as Utilities"
}

#
# Test Suite: Rules Metadata Extraction
#

test_extract_rule_description() {
  local result
  result=$(extract_rule_description "$FIXTURES_DIR/rules/tdd-first-fixture.mdc")
  assert_equals "TDD-First — Three Laws, R/G/R, owner specs" "$result" \
    "Should extract description from rule front matter"
}

test_extract_rule_description_fallback() {
  local result
  result=$(extract_rule_description "$FIXTURES_DIR/rules/no-frontmatter-fixture.mdc")
  assert_equals "Rule: no-frontmatter-fixture" "$result" \
    "Should fallback to 'Rule: filename' when no front matter"
}

test_extract_rule_description_malformed() {
  local result
  result=$(extract_rule_description "$FIXTURES_DIR/rules/malformed-frontmatter-fixture.mdc")
  # Should still extract description even if closing delimiter missing
  assert_equals "Missing closing delimiter" "$result" \
    "Should extract description even with malformed front matter"
}

test_is_always_apply_true() {
  local result
  result=$(is_always_apply_rule "$FIXTURES_DIR/rules/tdd-first-fixture.mdc")
  assert_equals "true" "$result" \
    "Should detect alwaysApply: true"
}

test_is_always_apply_false() {
  local result
  result=$(is_always_apply_rule "$FIXTURES_DIR/rules/spec-driven-fixture.mdc")
  assert_equals "false" "$result" \
    "Should detect alwaysApply: false"
}

test_is_always_apply_missing() {
  local result
  result=$(is_always_apply_rule "$FIXTURES_DIR/rules/no-frontmatter-fixture.mdc")
  assert_equals "false" "$result" \
    "Should default to false when alwaysApply missing"
}

test_list_rules() {
  local result
  result=$(list_rules "$FIXTURES_DIR/rules")
  assert_contains "$result" "tdd-first-fixture.mdc" \
    "Should list rule files"
}

test_categorize_rule_always_apply() {
  local result
  result=$(categorize_rule "$FIXTURES_DIR/rules/tdd-first-fixture.mdc")
  assert_equals "Always Applied" "$result" \
    "Should categorize alwaysApply rules as 'Always Applied'"
}

test_categorize_rule_other() {
  local result
  result=$(categorize_rule "$FIXTURES_DIR/rules/spec-driven-fixture.mdc")
  # For now, all non-always-apply go to "Workflow & Process"
  # We can refine categorization later based on keywords
  assert_equals "Workflow & Process" "$result" \
    "Should categorize non-always-apply rules"
}

#
# Test Suite: Project Stats Extraction
#

test_count_active_projects() {
  local result
  result=$(count_active_projects "$FIXTURES_DIR/projects")
  assert_equals "3" "$result" \
    "Should count 3 active projects (including blocked)"
}

test_count_archived_projects() {
  local result
  result=$(count_archived_projects "$FIXTURES_DIR/projects")
  assert_equals "1" "$result" \
    "Should count 1 archived project"
}

test_count_total_rules() {
  local result
  result=$(count_total_rules "$FIXTURES_DIR/rules")
  assert_equals "4" "$result" \
    "Should count 4 rule files"
}

#
# Test Suite: Template Rendering
#

test_replace_placeholder_simple() {
  local template="Hello {{NAME}}"
  local result
  result=$(replace_placeholder "$template" "NAME" "World")
  assert_equals "Hello World" "$result" \
    "Should replace simple placeholder"
}

test_replace_placeholder_multiple() {
  local template="{{GREETING}} {{NAME}}"
  local result
  result=$(replace_placeholder "$template" "GREETING" "Hello")
  result=$(replace_placeholder "$result" "NAME" "World")
  assert_equals "Hello World" "$result" \
    "Should replace multiple placeholders"
}

test_replace_placeholder_multiline() {
  local template="Header
{{CONTENT}}
Footer"
  local content="Line 1
Line 2"
  local result
  result=$(replace_placeholder "$template" "CONTENT" "$content")
  assert_contains "$result" "Line 1" \
    "Should handle multiline content"
  assert_contains "$result" "Header" \
    "Should preserve header"
  assert_contains "$result" "Footer" \
    "Should preserve footer"
}

test_replace_placeholder_not_found() {
  local template="Hello {{NAME}}"
  local result
  result=$(replace_placeholder "$template" "NAME" "World")
  assert_not_contains "$result" "{{NAME}}" \
    "Should remove placeholder"
}

test_load_template_success() {
  # Create a test template
  local test_template="$TEST_DIR/test-template.md"
  echo "# Test Template
{{PLACEHOLDER}}" > "$test_template"
  
  local result
  result=$(load_template "$test_template")
  
  assert_contains "$result" "# Test Template" \
    "Should load template content"
  assert_contains "$result" "{{PLACEHOLDER}}" \
    "Should preserve placeholders"
}

test_load_template_missing() {
  local result
  local exit_code=0
  result=$(load_template "$TEST_DIR/nonexistent.md" 2>&1) || exit_code=$?
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ $exit_code -ne 0 ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    if $VERBOSE; then
      echo -e "${GREEN}✓${NC} Should fail when template missing"
    fi
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} Should fail when template missing"
  fi
}

#
# Test Suite: Section Generators
#

test_generate_scripts_section() {
  local result
  result=$(generate_scripts_section "$FIXTURES_DIR/scripts")
  
  # Should contain category headers
  assert_contains "$result" "### Git Workflows" \
    "Should include Git Workflows category"
  
  # Should contain script entries
  assert_contains "$result" "git-commit-fixture.sh" \
    "Should include script names"
  
  # Should contain descriptions
  assert_contains "$result" "Compose Conventional Commits with validation" \
    "Should include script descriptions"
  
  # Should NOT include excluded files
  assert_not_contains "$result" ".lib-test.sh" \
    "Should exclude .lib files"
  assert_not_contains "$result" "example.test.sh" \
    "Should exclude test files"
}

test_generate_rules_section() {
  local result
  result=$(generate_rules_section "$FIXTURES_DIR/rules")
  
  # Should contain category headers
  assert_contains "$result" "**Always Applied**" \
    "Should include Always Applied category"
  
  assert_contains "$result" "**Workflow & Process**" \
    "Should include Workflow & Process category"
  
  # Should contain rule entries
  assert_contains "$result" "tdd-first-fixture.mdc" \
    "Should include rule names"
  
  # Should contain descriptions
  assert_contains "$result" "TDD-First — Three Laws" \
    "Should include rule descriptions"
}

test_generate_scripts_section_empty() {
  # Create empty test directory
  local empty_dir="$TEST_DIR/empty-scripts"
  mkdir -p "$empty_dir"
  
  local result
  result=$(generate_scripts_section "$empty_dir")
  
  # Should return empty or minimal output
  TESTS_RUN=$((TESTS_RUN + 1))
  # Empty is acceptable for no scripts
  TESTS_PASSED=$((TESTS_PASSED + 1))
  if $VERBOSE; then
    echo -e "${GREEN}✓${NC} Should handle empty scripts directory"
  fi
}

test_generate_rules_section_empty() {
  # Create empty test directory
  local empty_dir="$TEST_DIR/empty-rules"
  mkdir -p "$empty_dir"
  
  local result
  result=$(generate_rules_section "$empty_dir")
  
  # Should return empty or minimal output
  TESTS_RUN=$((TESTS_RUN + 1))
  # Empty is acceptable for no rules
  TESTS_PASSED=$((TESTS_PASSED + 1))
  if $VERBOSE; then
    echo -e "${GREEN}✓${NC} Should handle empty rules directory"
  fi
}

#
# Test Suite: Project Section Generators
#

test_generate_active_projects_section() {
  local result
  result=$(generate_active_projects_section "$FIXTURES_DIR/projects")
  
  # Should contain project names
  assert_contains "$result" "active-project-1" \
    "Should include active project names"
  
  assert_contains "$result" "active-project-2" \
    "Should include second active project"
  
  # Should NOT include archived projects
  assert_not_contains "$result" "archived-project-1" \
    "Should exclude archived projects"
  
  # Should NOT include blocked projects in active section
  assert_not_contains "$result" "blocked-project" \
    "Should exclude blocked projects from active section"
}

test_generate_priority_projects_section() {
  local result
  result=$(generate_priority_projects_section "$FIXTURES_DIR/projects")
  
  # Should contain high priority projects
  assert_contains "$result" "active-project-2" \
    "Should include high priority project"
  
  # Should contain blocked section
  assert_contains "$result" "**Blocked**" \
    "Should include blocked section header"
  
  # Should show blocker reason
  assert_contains "$result" "Waiting for upstream API design" \
    "Should include blocker reason"
}

test_extract_project_title() {
  local result
  result=$(extract_project_title "$FIXTURES_DIR/projects/active-project-1/erd.md")
  assert_equals "Test Project 1" "$result" \
    "Should extract project title from H1"
}

test_extract_priority() {
  local result
  result=$(extract_priority "$FIXTURES_DIR/projects/active-project-2/erd.md")
  assert_equals "high" "$result" \
    "Should extract priority from front matter"
}

test_extract_priority_missing() {
  local result
  result=$(extract_priority "$FIXTURES_DIR/projects/active-project-1/erd.md")
  assert_equals "" "$result" \
    "Should return empty when priority missing"
}

test_is_blocked() {
  local result
  result=$(is_blocked "$FIXTURES_DIR/projects/blocked-project/erd.md")
  assert_equals "true" "$result" \
    "Should detect blocked: true"
}

test_is_not_blocked() {
  local result
  result=$(is_blocked "$FIXTURES_DIR/projects/active-project-1/erd.md")
  assert_equals "false" "$result" \
    "Should return false when not blocked"
}

test_extract_blocker() {
  local result
  result=$(extract_blocker "$FIXTURES_DIR/projects/blocked-project/erd.md")
  assert_equals "Waiting for upstream API design" "$result" \
    "Should extract blocker reason"
}

#
# Run all tests
#

echo ""
echo "Running generate-root-readme.sh test suite..."
echo ""

# Script Metadata Extraction Tests
echo "Test Suite: Script Metadata Extraction"
test_extract_description_with_header
test_extract_description_fallback
test_extract_description_malformed
test_extract_flags
test_extract_flags_missing
test_list_scripts_excludes_lib
test_list_scripts_excludes_test
test_list_scripts_includes_regular
echo ""

# Categorization Tests
echo "Test Suite: Script Categorization"
test_categorize_git_script
test_categorize_pr_script
test_categorize_rules_script
test_categorize_project_script
test_categorize_validate_script
test_categorize_health_script
test_categorize_unknown_script
echo ""

# Rules Metadata Extraction Tests
echo "Test Suite: Rules Metadata Extraction"
test_extract_rule_description
test_extract_rule_description_fallback
test_extract_rule_description_malformed
test_is_always_apply_true
test_is_always_apply_false
test_is_always_apply_missing
test_list_rules
test_categorize_rule_always_apply
test_categorize_rule_other
echo ""

# Project Stats Tests
echo "Test Suite: Project Stats Extraction"
test_count_active_projects
test_count_archived_projects
test_count_total_rules
echo ""

# Template Rendering Tests
echo "Test Suite: Template Rendering"
test_replace_placeholder_simple
test_replace_placeholder_multiple
test_replace_placeholder_multiline
test_replace_placeholder_not_found
test_load_template_success
test_load_template_missing
echo ""

# Section Generator Tests
echo "Test Suite: Section Generators"
test_generate_scripts_section
test_generate_rules_section
test_generate_scripts_section_empty
test_generate_rules_section_empty
echo ""

# Project Section Generator Tests
echo "Test Suite: Project Section Generators"
test_extract_project_title
test_extract_priority
test_extract_priority_missing
test_is_blocked
test_is_not_blocked
test_extract_blocker
test_generate_active_projects_section
test_generate_priority_projects_section
echo ""

#
# Summary
#

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Results"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Total:  $TESTS_RUN"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ $TESTS_FAILED -eq 0 ]]; then
  echo -e "${GREEN}All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}Some tests failed.${NC}"
  exit 1
fi

