#!/usr/bin/env bash
# Tests for tdd-scope-check.sh

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SUT="$SCRIPT_DIR/tdd-scope-check.sh"
readonly REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Test helpers
TESTS_RUN=0
TESTS_PASSED=0

assert_exit_code() {
  local expected="$1"
  local actual="$2"
  local test_name="$3"
  
  TESTS_RUN=$((TESTS_RUN + 1))
  
  if [[ "$actual" -eq "$expected" ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    printf '✓ %s\n' "$test_name"
  else
    printf '✗ %s (expected exit %d, got %d)\n' "$test_name" "$expected" "$actual" >&2
  fi
}

assert_output_contains() {
  local expected="$1"
  local actual="$2"
  local test_name="$3"
  
  TESTS_RUN=$((TESTS_RUN + 1))
  
  if [[ "$actual" == *"$expected"* ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    printf '✓ %s\n' "$test_name"
  else
    printf '✗ %s (output does not contain "%s")\n' "$test_name" "$expected" >&2
  fi
}

# Test cases

test_typescript_file_in_scope() {
  # Create a temp .ts file for testing
  local temp_ts
  temp_ts=$(mktemp "${TMPDIR:-/tmp}/test.XXXXXX.ts")
  echo "export const foo = 1;" > "$temp_ts"
  
  local output exit_code
  set +e
  output=$("$SUT" "$temp_ts" 2>&1)
  exit_code=$?
  set -e
  
  rm -f "$temp_ts"
  
  assert_exit_code 0 "$exit_code" "TypeScript file should be in TDD scope"
  assert_output_contains "TDD: in-scope" "$output" "TypeScript output should indicate in-scope"
}

test_shell_script_in_scope() {
  local output exit_code
  set +e
  output=$("$SUT" "$REPO_ROOT/.cursor/scripts/tdd-scope-check.sh" 2>&1)
  exit_code=$?
  set -e
  
  assert_exit_code 0 "$exit_code" "Shell script should be in TDD scope"
  assert_output_contains "TDD: in-scope" "$output" "Shell script output should indicate in-scope"
}

test_markdown_file_exempt() {
  local output exit_code
  set +e
  output=$("$SUT" "$REPO_ROOT/README.md" 2>&1)
  exit_code=$?
  set -e
  
  assert_exit_code 1 "$exit_code" "Markdown file should be exempt from TDD"
  assert_output_contains "TDD: exempt" "$output" "Markdown output should indicate exempt"
}

test_erd_file_exempt() {
  local output exit_code
  set +e
  output=$("$SUT" "$REPO_ROOT/docs/projects/tdd-scope-boundaries/erd.md" 2>&1)
  exit_code=$?
  set -e
  
  assert_exit_code 1 "$exit_code" "ERD file should be exempt from TDD"
  assert_output_contains "TDD: exempt" "$output" "ERD output should indicate exempt"
}

test_json_config_exempt() {
  local output exit_code
  set +e
  output=$("$SUT" "$REPO_ROOT/package.json" 2>&1)
  exit_code=$?
  set -e
  
  assert_exit_code 1 "$exit_code" "JSON config should be exempt from TDD"
  assert_output_contains "TDD: exempt" "$output" "JSON output should indicate exempt"
}

test_yaml_workflow_exempt() {
  # Create a temp YAML file for testing
  local temp_yaml
  temp_yaml=$(mktemp "${TMPDIR:-/tmp}/test-workflow.XXXXXX.yml")
  echo "name: test" > "$temp_yaml"
  
  local output exit_code
  set +e
  output=$("$SUT" "$temp_yaml" 2>&1)
  exit_code=$?
  set -e
  
  rm -f "$temp_yaml"
  
  assert_exit_code 1 "$exit_code" "YAML file should be exempt from TDD"
  assert_output_contains "TDD: exempt" "$output" "YAML output should indicate exempt"
}

test_mdc_rule_file_exempt() {
  local output exit_code
  set +e
  output=$("$SUT" "$REPO_ROOT/.cursor/rules/tdd-first.mdc" 2>&1)
  exit_code=$?
  set -e
  
  assert_exit_code 1 "$exit_code" "Rule file should be exempt from TDD"
  assert_output_contains "TDD: exempt" "$output" "Rule file output should indicate exempt"
}

test_type_definition_file_exempt() {
  # Create a temp .d.ts file for testing
  local temp_dts
  temp_dts=$(mktemp "${TMPDIR:-/tmp}/types.XXXXXX.d.ts")
  echo "export type Test = string;" > "$temp_dts"
  
  local output exit_code
  set +e
  output=$("$SUT" "$temp_dts" 2>&1)
  exit_code=$?
  set -e
  
  rm -f "$temp_dts"
  
  assert_exit_code 1 "$exit_code" "Type definition file should be exempt from TDD"
  assert_output_contains "TDD: exempt" "$output" "Type definition output should indicate exempt"
}

test_node_modules_excluded() {
  # Create a temp file simulating node_modules
  local temp_dir
  temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/node_modules.XXXXXX")
  local temp_file="$temp_dir/index.js"
  echo "module.exports = {}" > "$temp_file"
  
  local output exit_code
  set +e
  output=$("$SUT" "$temp_file" 2>&1)
  exit_code=$?
  set -e
  
  rm -rf "$temp_dir"
  
  assert_exit_code 1 "$exit_code" "Files in node_modules should be excluded"
  assert_output_contains "TDD: exempt" "$output" "node_modules output should indicate exempt"
}

test_dist_excluded() {
  # Create a temp file simulating dist directory
  local temp_dir
  temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/dist.XXXXXX")
  local temp_file="$temp_dir/bundle.js"
  echo "// compiled" > "$temp_file"
  
  local output exit_code
  set +e
  output=$("$SUT" "$temp_file" 2>&1)
  exit_code=$?
  set -e
  
  rm -rf "$temp_dir"
  
  assert_exit_code 1 "$exit_code" "Files in dist should be excluded"
  assert_output_contains "TDD: exempt" "$output" "dist output should indicate exempt"
}

test_nonexistent_file_error() {
  local output exit_code
  set +e
  output=$("$SUT" "/nonexistent/file.ts" 2>&1)
  exit_code=$?
  set -e
  
  assert_exit_code 2 "$exit_code" "Nonexistent file should return error code"
  assert_output_contains "Error: file not found" "$output" "Should show file not found error"
}

test_help_flag() {
  local output exit_code
  set +e
  output=$("$SUT" --help 2>&1)
  exit_code=$?
  set -e
  
  assert_exit_code 0 "$exit_code" "Help flag should exit successfully"
  assert_output_contains "Usage:" "$output" "Help should show usage"
}

# Run all tests
main() {
  printf '=== TDD Scope Check Tests ===\n\n'
  
  test_typescript_file_in_scope
  test_shell_script_in_scope
  test_markdown_file_exempt
  test_erd_file_exempt
  test_json_config_exempt
  test_yaml_workflow_exempt
  test_mdc_rule_file_exempt
  test_type_definition_file_exempt
  test_node_modules_excluded
  test_dist_excluded
  test_nonexistent_file_error
  test_help_flag
  
  printf '\n=== Results ===\n'
  printf 'Tests run: %d\n' "$TESTS_RUN"
  printf 'Tests passed: %d\n' "$TESTS_PASSED"
  
  if [[ "$TESTS_PASSED" -eq "$TESTS_RUN" ]]; then
    printf '\n✓ All tests passed\n'
    exit 0
  else
    printf '\n✗ %d tests failed\n' $((TESTS_RUN - TESTS_PASSED))
    exit 1
  fi
}

main "$@"

