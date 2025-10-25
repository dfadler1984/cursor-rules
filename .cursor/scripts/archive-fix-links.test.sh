#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Test suite for archive-fix-links.sh
# Owner tests for link fixing after project archival

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT="$SCRIPT_DIR/archive-fix-links.sh"

# Create temp directory for test fixtures
TEMP_DIR="$ROOT_DIR/tmp/archive-links-test-$$"
mkdir -p "$TEMP_DIR/docs/projects/test-proj"
mkdir -p "$TEMP_DIR/docs/_archived/2025/test-proj"
mkdir -p "$TEMP_DIR/.cursor/rules"
trap 'rm -rf "$TEMP_DIR"' EXIT

# Test 1: Help flag works
echo "Test 1: Help flag..."
set +e
output=$(bash "$SCRIPT" --help 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: --help should exit 0"
  exit 1
fi

if ! [[ "$output" =~ "Usage:" ]]; then
  echo "FAIL: --help should show usage"
  exit 1
fi

echo "PASS: Test 1 - Help flag works"

# Test 2: Fixes relative links in markdown files
echo "Test 2: Fixes relative links..."
cat > "$TEMP_DIR/docs/reference.md" <<'EOF'
# Reference Doc

See [test project](./projects/test-proj/erd.md) for details.

Also check [tasks](./projects/test-proj/tasks.md).
EOF

set +e
output=$(bash "$SCRIPT" --old-path "docs/projects/test-proj" --new-path "docs/projects/_archived/2025/test-proj" --search-dir "$TEMP_DIR" 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Should fix links successfully"
  echo "Output: $output"
  exit 1
fi

# Check if links were updated (relative path from docs/ becomes ./_archived/)
if ! grep -q "_archived/2025/test-proj/erd.md" "$TEMP_DIR/docs/reference.md"; then
  echo "FAIL: Should update link to archived location"
  cat "$TEMP_DIR/docs/reference.md"
  exit 1
fi

echo "PASS: Test 2 - Fixes relative links"

# Test 3: Preserves anchor links
echo "Test 3: Preserves anchor links..."
cat > "$TEMP_DIR/docs/with-anchor.md" <<'EOF'
# Doc

See [section](./projects/test-proj/erd.md#introduction).
EOF

set +e
bash "$SCRIPT" --old-path "docs/projects/test-proj" --new-path "docs/projects/_archived/2025/test-proj" --search-dir "$TEMP_DIR" >/dev/null 2>&1
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Should handle anchor links"
  exit 1
fi

if ! grep -q "_archived/2025/test-proj/erd.md#introduction" "$TEMP_DIR/docs/with-anchor.md"; then
  echo "FAIL: Should preserve anchor link"
  cat "$TEMP_DIR/docs/with-anchor.md"
  exit 1
fi

echo "PASS: Test 3 - Preserves anchor links"

# Test 4: Handles multiple files
echo "Test 4: Multiple file references..."
cat > "$TEMP_DIR/docs/doc1.md" <<'EOF'
[link](./projects/test-proj/file.md)
EOF

cat > "$TEMP_DIR/docs/doc2.md" <<'EOF'
[another](./projects/test-proj/other.md)
EOF

cat > "$TEMP_DIR/.cursor/rules/rule.mdc" <<'EOF'
See docs/projects/test-proj/erd.md
EOF

set +e
output=$(bash "$SCRIPT" --old-path "docs/projects/test-proj" --new-path "docs/projects/_archived/2025/test-proj" --search-dir "$TEMP_DIR" 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Should update multiple files"
  exit 1
fi

# Check all files were updated
if ! grep -q "_archived/2025/test-proj" "$TEMP_DIR/docs/doc1.md"; then
  echo "FAIL: Should update doc1.md"
  exit 1
fi

if ! grep -q "_archived/2025/test-proj" "$TEMP_DIR/docs/doc2.md"; then
  echo "FAIL: Should update doc2.md"
  exit 1
fi

if ! grep -q "_archived/2025/test-proj" "$TEMP_DIR/.cursor/rules/rule.mdc"; then
  echo "FAIL: Should update rules file"
  exit 1
fi

echo "PASS: Test 4 - Updates multiple files"

# Test 5: Dry-run mode
echo "Test 5: Dry-run mode..."
cat > "$TEMP_DIR/docs/dryrun.md" <<'EOF'
[link](./projects/test-proj/file.md)
EOF

ORIGINAL_CONTENT=$(cat "$TEMP_DIR/docs/dryrun.md")

set +e
output=$(bash "$SCRIPT" --old-path "docs/projects/test-proj" --new-path "docs/projects/_archived/2025/test-proj" --search-dir "$TEMP_DIR" --dry-run 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Dry-run should exit 0"
  exit 1
fi

# File should not be modified
if [ "$(cat "$TEMP_DIR/docs/dryrun.md")" != "$ORIGINAL_CONTENT" ]; then
  echo "FAIL: Dry-run should not modify files"
  exit 1
fi

# But should report what would change
if ! echo "$output" | grep -q "Would fix"; then
  echo "FAIL: Dry-run should report changes"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 5 - Dry-run doesn't modify files"

# Test 6: No references found
echo "Test 6: No references..."
EMPTY_SEARCH="$TEMP_DIR/empty-search"
mkdir -p "$EMPTY_SEARCH"

cat > "$EMPTY_SEARCH/doc.md" <<'EOF'
# No references to test-proj
EOF

set +e
output=$(bash "$SCRIPT" --old-path "docs/projects/test-proj" --new-path "docs/projects/_archived/2025/test-proj" --search-dir "$EMPTY_SEARCH" 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Should exit 0 when no references"
  exit 1
fi

echo "PASS: Test 6 - Handles no references gracefully"

echo ""
echo "All tests passed!"

