#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

# Test suite for rules-autofix.sh
# Owner tests for autofix extraction

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT="$SCRIPT_DIR/rules-autofix.sh"

# Create temp directory for test fixtures
tmpdir="$ROOT_DIR/.test-artifacts/rules-autofix-$$"
mkdir -p "$tmpdir"
trap_cleanup "$tmpdir"

# Test 1: Fix CSV spaces after commas
cat > "$tmpdir/csv-spaces.mdc" <<'EOF'
---
description: Test rule
globs: **/*.ts, **/*.tsx, **/*.js
overrides: ../foo/**, ../../bar/**
---
# Test Rule
EOF

bash "$SCRIPT" "$tmpdir/csv-spaces.mdc" 2>&1

# Verify fix was applied
if ! grep -q "globs: \*\*/\*.ts,\*\*/\*.tsx,\*\*/\*.js" "$tmpdir/csv-spaces.mdc"; then
  echo "FAIL: CSV spaces should be removed from globs"
  cat "$tmpdir/csv-spaces.mdc"
  exit 1
fi

if ! grep -q "overrides: \.\./foo/\*\*,\.\./\.\./bar/\*\*" "$tmpdir/csv-spaces.mdc"; then
  echo "FAIL: CSV spaces should be removed from overrides"
  cat "$tmpdir/csv-spaces.mdc"
  exit 1
fi

echo "PASS: Test 1 - CSV spaces removed"

# Test 2: Normalize alwaysApply True to true
cat > "$tmpdir/always-true.mdc" <<'EOF'
---
description: Test rule
alwaysApply: True
---
# Test Rule
EOF

bash "$SCRIPT" "$tmpdir/always-true.mdc" 2>&1

if ! grep -q "alwaysApply: true" "$tmpdir/always-true.mdc"; then
  echo "FAIL: alwaysApply: True should be normalized to true"
  cat "$tmpdir/always-true.mdc"
  exit 1
fi

echo "PASS: Test 2 - alwaysApply True → true"

# Test 3: Normalize alwaysApply False to false
cat > "$tmpdir/always-false.mdc" <<'EOF'
---
description: Test rule
alwaysApply: "False"
---
# Test Rule
EOF

bash "$SCRIPT" "$tmpdir/always-false.mdc" 2>&1

if ! grep -q "alwaysApply: false" "$tmpdir/always-false.mdc"; then
  echo "FAIL: alwaysApply: \"False\" should be normalized to false"
  cat "$tmpdir/always-false.mdc"
  exit 1
fi

echo "PASS: Test 3 - alwaysApply \"False\" → false"

# Test 4: Already correct file unchanged
cat > "$tmpdir/correct.mdc" <<'EOF'
---
description: Test rule
globs: **/*.ts,**/*.tsx
alwaysApply: true
lastReviewed: 2025-10-13
---
# Test Rule
Content here
EOF

# Copy to compare
cp "$tmpdir/correct.mdc" "$tmpdir/correct-backup.mdc"

bash "$SCRIPT" "$tmpdir/correct.mdc" 2>&1

# Files should be identical
if ! diff -q "$tmpdir/correct.mdc" "$tmpdir/correct-backup.mdc" >/dev/null 2>&1; then
  echo "FAIL: Already correct file should not be modified"
  diff "$tmpdir/correct.mdc" "$tmpdir/correct-backup.mdc"
  exit 1
fi

echo "PASS: Test 4 - Correct file unchanged"

# Test 5: Multiple files batch mode
cat > "$tmpdir/batch1.mdc" <<'EOF'
---
description: Rule 1
globs: **/*.ts, **/*.js
alwaysApply: True
---
# Rule 1
EOF

cat > "$tmpdir/batch2.mdc" <<'EOF'
---
description: Rule 2
overrides: ../foo/**, ../../bar/**
alwaysApply: False
---
# Rule 2
EOF

bash "$SCRIPT" "$tmpdir/batch1.mdc" "$tmpdir/batch2.mdc" 2>&1

# Verify both fixed
if ! grep -q "globs: \*\*/\*.ts,\*\*/\*.js" "$tmpdir/batch1.mdc"; then
  echo "FAIL: batch1.mdc should be fixed"
  exit 1
fi

if ! grep -q "alwaysApply: true" "$tmpdir/batch1.mdc"; then
  echo "FAIL: batch1.mdc alwaysApply should be normalized"
  exit 1
fi

if ! grep -q "overrides: \.\./foo/\*\*,\.\./\.\./bar/\*\*" "$tmpdir/batch2.mdc"; then
  echo "FAIL: batch2.mdc should be fixed"
  exit 1
fi

if ! grep -q "alwaysApply: false" "$tmpdir/batch2.mdc"; then
  echo "FAIL: batch2.mdc alwaysApply should be normalized"
  exit 1
fi

echo "PASS: Test 5 - Batch autofix works"

# Test 6: Dry-run mode (if implemented)
cat > "$tmpdir/dry-run.mdc" <<'EOF'
---
description: Test rule
globs: **/*.ts, **/*.tsx
---
# Test Rule
EOF

cp "$tmpdir/dry-run.mdc" "$tmpdir/dry-run-backup.mdc"

set +e
output=$(bash "$SCRIPT" --dry-run "$tmpdir/dry-run.mdc" 2>&1)
status=$?
set -e

# File should not be modified in dry-run
if ! diff -q "$tmpdir/dry-run.mdc" "$tmpdir/dry-run-backup.mdc" >/dev/null 2>&1; then
  echo "FAIL: Dry-run should not modify file"
  exit 1
fi

# But should report what would be fixed
if ! [[ "$output" =~ "Would fix" ]] && ! [[ "$output" =~ "dry" ]]; then
  echo "WARN: Dry-run should indicate what would be fixed (optional feature)"
fi

echo "PASS: Test 6 - Dry-run preserves file"

echo ""
echo "All tests passed!"

