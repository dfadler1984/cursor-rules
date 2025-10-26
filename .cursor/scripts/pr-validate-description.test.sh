#!/usr/bin/env bash
# Test: pr-validate-description.sh

# shellcheck disable=SC1091
source "$(dirname "$0")/.lib.sh"
source "$(dirname "$0")/tests/.lib-test.sh"

readonly TARGET_SCRIPT="$(dirname "$0")/pr-validate-description.sh"

test_help_flag() {
  set +e
  bash "$TARGET_SCRIPT" --help >/dev/null 2>&1
  local exit_code=$?
  set -e
  if [[ $exit_code -eq 0 ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo "✓ help flag works"
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "✗ help flag should succeed"
  fi
}

test_version_flag() {
  set +e
  local output
  output=$(bash "$TARGET_SCRIPT" --version 2>&1)
  local exit_code=$?
  set -e
  if [[ $exit_code -eq 0 ]] && [[ "$output" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo "✓ version flag works"
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "✗ version flag should show version"
  fi
}

test_requires_pr_number() {
  assert_cmd_fails bash "$TARGET_SCRIPT"
  assert_stderr_contains "--pr is required"
}

test_validates_proper_description() {
  # Mock API response with proper body
  setup_test_env
  
  local mock_response
  mock_response=$(cat <<'JSON'
{
  "number": 197,
  "title": "Test PR",
  "body": "## Summary\n\nActual content here.\n\n## Changes\n\n- Real change 1\n- Real change 2",
  "html_url": "https://github.com/test/repo/pull/197"
}
JSON
)
  
  # Create mock API response file
  local tmpfile
  tmpfile=$(mktemp)
  echo "$mock_response" > "$tmpfile"
  
  # Mock curl to return our response
  curl() {
    if [ "$1" = "-sS" ]; then
      cat "$tmpfile"
      echo "200"
    fi
  }
  export -f curl
  
  export GH_TOKEN="mock-token"
  assert_cmd_succeeds bash "$TARGET_SCRIPT" --pr 197 --owner test --repo repo
  assert_stdout_contains "Validation PASSED"
  
  rm "$tmpfile"
}

test_fails_on_null_body() {
  setup_test_env
  
  local mock_response
  mock_response=$(cat <<'JSON'
{
  "number": 197,
  "title": "Test PR",
  "body": null,
  "html_url": "https://github.com/test/repo/pull/197"
}
JSON
)
  
  local tmpfile
  tmpfile=$(mktemp)
  echo "$mock_response" > "$tmpfile"
  
  curl() {
    if [ "$1" = "-sS" ]; then
      cat "$tmpfile"
      echo "200"
    fi
  }
  export -f curl
  
  export GH_TOKEN="mock-token"
  assert_cmd_fails bash "$TARGET_SCRIPT" --pr 197 --owner test --repo repo
  assert_stderr_contains "PR body is null"
  
  rm "$tmpfile"
}

test_fails_on_template_body() {
  setup_test_env
  
  # Body with 2+ actual placeholder texts (not just section headers)
  local mock_response
  mock_response=$(cat <<'JSON'
{
  "number": 197,
  "title": "Test PR",
  "body": "## Summary\n\nBriefly describe what this PR changes and why.\n\n## Changes\n\nHigh-level bullets of what changed\n\n## Why\n\nWhat problem does this solve? Any alternatives considered?",
  "html_url": "https://github.com/test/repo/pull/197"
}
JSON
)
  
  local tmpfile
  tmpfile=$(mktemp)
  echo "$mock_response" > "$tmpfile"
  
  curl() {
    if [ "$1" = "-sS" ]; then
      cat "$tmpfile"
      echo "200"
    fi
  }
  export -f curl
  
  export GH_TOKEN="mock-token"
  assert_cmd_fails bash "$TARGET_SCRIPT" --pr 197 --owner test --repo repo
  assert_stderr_contains "template placeholders"
  
  rm "$tmpfile"
}

test_passes_with_standard_structure() {
  setup_test_env
  
  # Body with section headers but real content (not placeholders)
  local mock_response
  mock_response=$(cat <<'JSON'
{
  "number": 200,
  "title": "Test PR",
  "body": "## Summary\n\nAdds three project directories.\n\n## Changes\n\n- orphaned-files project\n- rules-condensation project\n\n## Why\n\nThese were created earlier but not committed.",
  "html_url": "https://github.com/test/repo/pull/200"
}
JSON
)
  
  local tmpfile
  tmpfile=$(mktemp)
  echo "$mock_response" > "$tmpfile"
  
  curl() {
    if [ "$1" = "-sS" ]; then
      cat "$tmpfile"
      echo "200"
    fi
  }
  export -f curl
  
  export GH_TOKEN="mock-token"
  assert_cmd_succeeds bash "$TARGET_SCRIPT" --pr 200 --owner test --repo repo
  assert_stdout_contains "Validation PASSED"
  
  rm "$tmpfile"
}

run_tests \
  test_help_flag \
  test_version_flag \
  test_requires_pr_number
# Integration tests commented out - require mocking framework
# test_validates_proper_description \
# test_fails_on_null_body \
# test_fails_on_template_body

