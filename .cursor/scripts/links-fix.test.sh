#!/usr/bin/env bash
# Tests for links-fix.sh
# TDD: Red → Green → Refactor

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/links-fix.sh"

setup() {
  TEST_DIR=$(mktemp -d)
  cd "$TEST_DIR"
}

teardown() {
  rm -rf "$TEST_DIR"
}

# Test: Fix wrong depth for .cursor/ paths
test_fix_cursor_paths() {
  setup
  
  # Create test file with wrong .cursor/ path depth
  cat > test.md <<'EOF'
See [context-efficiency](../../.cursor/rules/context-efficiency.mdc) for details.
EOF

  bash "$SCRIPT" --file test.md --dry-run > /tmp/fix-output.txt 2>&1
  
  if ! grep -q "../../.cursor/" /tmp/fix-output.txt; then
    echo "FAIL: Should detect wrong path depth"
    teardown
    return 1
  fi
  
  teardown
  echo "PASS: Fix wrong depth for .cursor/ paths"
}

# Test: Remove non-existent placeholder links
test_remove_placeholders() {
  setup
  
  cat > test.md <<'EOF'
See [placeholder](./path.md) and [badge](badge-url) for details.
EOF

  bash "$SCRIPT" --file test.md --dry-run > /tmp/fix-output.txt 2>&1
  
  if ! grep -q "Remove.*placeholder" /tmp/fix-output.txt; then
    echo "FAIL: Should detect placeholder links"
    teardown
    return 1
  fi
  
  teardown
  echo "PASS: Remove non-existent placeholder links"
}

# Test: Dry run doesn't modify files
test_dry_run() {
  setup
  
  cat > test.md <<'EOF'
[broken](./nonexistent.md)
EOF

  local original_hash=$(md5 -q test.md)
  bash "$SCRIPT" --file test.md --dry-run > /dev/null 2>&1
  local after_hash=$(md5 -q test.md)
  
  if [[ "$original_hash" != "$after_hash" ]]; then
    echo "FAIL: Dry run should not modify files"
    teardown
    return 1
  fi
  
  teardown
  echo "PASS: Dry run doesn't modify files"
}

# Test: Apply mode modifies files
test_apply_mode() {
  setup
  
  cat > test.md <<'EOF'
[placeholder](path.md)
EOF

  bash "$SCRIPT" --file test.md --apply > /dev/null 2>&1
  
  if grep -q "path.md" test.md; then
    echo "FAIL: Apply should remove placeholder"
    teardown
    return 1
  fi
  
  teardown
  echo "PASS: Apply mode modifies files"
}

# Run tests
echo "Running links-fix.sh tests..."
test_fix_cursor_paths
test_remove_placeholders  
test_dry_run
test_apply_mode
echo "All tests passed!"

