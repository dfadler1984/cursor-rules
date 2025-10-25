#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Test suite for generate-projects-readme.sh
# Owner tests for projects README generation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT="$SCRIPT_DIR/generate-projects-readme.sh"

# Test 1: Help flag works
echo "Test 1: Help flag..."
set +e
output=$(bash "$SCRIPT" --help 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: --help should exit 0"
  echo "Output: $output"
  exit 1
fi

if ! [[ "$output" =~ "Usage:" ]]; then
  echo "FAIL: --help should show usage"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 1 - Help flag works"

# Test 2: Dry-run flag outputs to stdout, doesn't write file
echo "Test 2: Dry-run flag..."
set +e
output=$(bash "$SCRIPT" --projects-dir "$ROOT_DIR/docs/projects" --dry-run 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: --dry-run should exit 0"
  echo "Output: $output"
  exit 1
fi

if ! [[ "$output" =~ "# Projects" ]]; then
  echo "FAIL: --dry-run should output README content"
  echo "Output: $output"
  exit 1
fi

if ! [[ "$output" =~ "Project" ]] || ! [[ "$output" =~ "Status" ]]; then
  echo "FAIL: --dry-run should include table headers"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 2 - Dry-run outputs to stdout"

# Test 3: Discovers projects and excludes _archived, _examples
echo "Test 3: Project discovery..."
set +e
output=$(bash "$SCRIPT" --projects-dir "$ROOT_DIR/docs/projects" --dry-run 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Should successfully discover projects"
  exit 1
fi

# Should include active projects
if ! [[ "$output" =~ "projects-readme-generator" ]]; then
  echo "FAIL: Should include projects-readme-generator"
  echo "Output: $output"
  exit 1
fi

# Should NOT include _examples projects
if echo "$output" | grep -q "\](./_examples/"; then
  echo "FAIL: Should exclude _examples projects from table"
  echo "Output: $output"
  exit 1
fi

# Should include _archived projects in Archived Projects section only
if ! echo "$output" | awk '/## Archived Projects/,/## Regenerating/' | grep -q "\](./_archived/"; then
  echo "FAIL: Should include _archived projects in Archived Projects section"
  echo "Output: $output"
  exit 1
fi

# Should NOT include _archived projects in Active or Pending sections
if echo "$output" | awk '/## Active Projects/,/## Pending Projects/' | grep -q "\](./_archived/"; then
  echo "FAIL: Should not include _archived projects in Active Projects section"
  exit 1
fi

if echo "$output" | awk '/## Pending Projects/,/## Archived Projects/' | grep -q "\](./_archived/"; then
  echo "FAIL: Should not include _archived projects in Pending Projects section"
  exit 1
fi

echo "PASS: Test 3 - Discovers projects correctly"

# Test 4: Generates three separate tables (Active, Pending, Archived)
echo "Test 4: Three-table structure..."
set +e
output=$(bash "$SCRIPT" --projects-dir "$ROOT_DIR/docs/projects" --dry-run 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Should generate tables"
  exit 1
fi

# Check for three section headers
if ! echo "$output" | grep -q "## Active Projects"; then
  echo "FAIL: Should have 'Active Projects' section"
  echo "Output: $output"
  exit 1
fi

if ! echo "$output" | grep -q "## Pending Projects"; then
  echo "FAIL: Should have 'Pending Projects' section"
  echo "Output: $output"
  exit 1
fi

if ! echo "$output" | grep -q "## Archived Projects"; then
  echo "FAIL: Should have 'Archived Projects' section"
  echo "Output: $output"
  exit 1
fi

# Check for table headers in each section
table_headers=$(echo "$output" | grep -c "| Project | Status | ERD | Tasks |")
if [ "$table_headers" -lt 3 ]; then
  echo "FAIL: Should have 3 table headers (one per section)"
  echo "Found: $table_headers"
  exit 1
fi

# Check for at least one table row with ERD link
if ! echo "$output" | grep -q "\[.*\](.*erd.md)"; then
  echo "FAIL: Should have ERD links in tables"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 4 - Generates three-table structure"

# Test 5: Test with fixture directory
echo "Test 5: Fixture directory..."
FIXTURE_DIR="$ROOT_DIR/tmp/test-projects-$$"
mkdir -p "$FIXTURE_DIR"

# Create test projects
mkdir -p "$FIXTURE_DIR/test-project-1"
cat > "$FIXTURE_DIR/test-project-1/erd.md" <<'EOF'
---
status: active
owner: test-owner
---

# Test Project One

Test project for README generation.
EOF

mkdir -p "$FIXTURE_DIR/test-project-1"
touch "$FIXTURE_DIR/test-project-1/tasks.md"

mkdir -p "$FIXTURE_DIR/test-project-2"
cat > "$FIXTURE_DIR/test-project-2/erd.md" <<'EOF'
---
status: completed
---

# Test Project Two
EOF

mkdir -p "$FIXTURE_DIR/_archived"
mkdir -p "$FIXTURE_DIR/_examples"

set +e
output=$(bash "$SCRIPT" --projects-dir "$FIXTURE_DIR" --dry-run 2>&1)
status=$?
set -e

# Cleanup
rm -rf "$FIXTURE_DIR"

if [ $status -ne 0 ]; then
  echo "FAIL: Should work with fixture directory"
  echo "Output: $output"
  exit 1
fi

# Should include both test projects
if ! [[ "$output" =~ "test-project-1" ]] || ! [[ "$output" =~ "test-project-2" ]]; then
  echo "FAIL: Should include both test projects"
  echo "Output: $output"
  exit 1
fi

# test-project-1 (active) should be in Active Projects section
if ! echo "$output" | awk '/## Active Projects/,/## Pending Projects/' | grep -q "test-project-1"; then
  echo "FAIL: test-project-1 (active) should be in Active Projects section"
  echo "Output: $output"
  exit 1
fi

# test-project-2 (completed) should be in Archived Projects section
if ! echo "$output" | awk '/## Archived Projects/,/## Regenerating/' | grep -q "test-project-2"; then
  echo "FAIL: test-project-2 (completed) should be in Archived Projects section"
  echo "Output: $output"
  exit 1
fi

# test-project-1 should have tasks link (✅)
if ! echo "$output" | grep -q "test-project-1.*✅"; then
  echo "FAIL: test-project-1 should have tasks checkmark"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 5 - Works with fixture directory"

# Test 6: Handles missing erd.md gracefully
echo "Test 6: Missing erd.md..."
FIXTURE_DIR="$ROOT_DIR/tmp/test-projects-missing-$$"
mkdir -p "$FIXTURE_DIR/no-erd-project"

set +e
output=$(bash "$SCRIPT" --projects-dir "$FIXTURE_DIR" --dry-run 2>&1)
status=$?
set -e

# Cleanup
rm -rf "$FIXTURE_DIR"

if [ $status -ne 0 ]; then
  echo "FAIL: Should handle missing erd.md"
  echo "Output: $output"
  exit 1
fi

# Should include project with fallback title (folder name)
if ! [[ "$output" =~ "no-erd-project" ]]; then
  echo "FAIL: Should include project without erd.md"
  echo "Output: $output"
  exit 1
fi

# Project with unknown status should be in Pending Projects section
if ! echo "$output" | awk '/## Pending Projects/,/## Archived Projects/' | grep -q "no-erd-project"; then
  echo "FAIL: Project with unknown status should be in Pending Projects section"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 6 - Handles missing erd.md"

echo ""
echo "All tests passed!"

