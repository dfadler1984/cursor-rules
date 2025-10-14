#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

# Test suite for rules-validate-frontmatter.sh
# Owner tests for front matter validation extraction

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT="$SCRIPT_DIR/rules-validate-frontmatter.sh"

# Create temp directory for test fixtures
tmpdir="$ROOT_DIR/.test-artifacts/rules-validate-frontmatter-$$"
mkdir -p "$tmpdir"
trap_cleanup "$tmpdir"

# Test 1: Valid front matter passes
cat > "$tmpdir/valid.mdc" <<'EOF'
---
description: Test rule
lastReviewed: 2025-10-13
healthScore:
  content: green
  usability: green
  maintenance: green
---
# Test Rule
EOF

output=$(bash "$SCRIPT" "$tmpdir/valid.mdc" 2>&1)
status=$?

if [ $status -ne 0 ]; then
  echo "FAIL: Valid front matter should pass (exit 0)"
  exit 1
fi

if [[ "$output" =~ "missing" ]] || [[ "$output" =~ "invalid" ]]; then
  echo "FAIL: Valid front matter should not report issues"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 1 - Valid front matter"

# Test 2: Missing description field
cat > "$tmpdir/missing-description.mdc" <<'EOF'
---
lastReviewed: 2025-10-13
healthScore:
  content: green
  usability: green
  maintenance: green
---
# Test Rule
EOF

set +e
output=$(bash "$SCRIPT" "$tmpdir/missing-description.mdc" 2>&1)
status=$?
set -e

if [ $status -eq 0 ]; then
  echo "FAIL: Missing description should fail (exit non-zero)"
  exit 1
fi

if ! [[ "$output" =~ "missing required field: description" ]]; then
  echo "FAIL: Should report missing description"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 2 - Missing description detected"

# Test 3: Invalid lastReviewed format
cat > "$tmpdir/invalid-date.mdc" <<'EOF'
---
description: Test rule
lastReviewed: Oct 13, 2025
healthScore:
  content: green
  usability: green
  maintenance: green
---
# Test Rule
EOF

set +e
output=$(bash "$SCRIPT" "$tmpdir/invalid-date.mdc" 2>&1)
status=$?
set -e

if [ $status -eq 0 ]; then
  echo "FAIL: Invalid lastReviewed format should fail"
  exit 1
fi

if ! [[ "$output" =~ "invalid lastReviewed" ]]; then
  echo "FAIL: Should report invalid lastReviewed format"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 3 - Invalid date format detected"

# Test 4: Missing healthScore fields
cat > "$tmpdir/missing-healthscore.mdc" <<'EOF'
---
description: Test rule
lastReviewed: 2025-10-13
healthScore:
  content: green
---
# Test Rule
EOF

set +e
output=$(bash "$SCRIPT" "$tmpdir/missing-healthscore.mdc" 2>&1)
status=$?
set -e

if [ $status -eq 0 ]; then
  echo "FAIL: Missing healthScore fields should fail"
  exit 1
fi

if ! [[ "$output" =~ "missing healthScore" ]]; then
  echo "FAIL: Should report missing healthScore fields"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 4 - Missing healthScore fields detected"

# Test 5: Multiple files (batch mode)
cat > "$tmpdir/file1.mdc" <<'EOF'
---
description: Rule 1
lastReviewed: 2025-10-13
healthScore:
  content: green
  usability: green
  maintenance: green
---
# Rule 1
EOF

cat > "$tmpdir/file2.mdc" <<'EOF'
---
lastReviewed: 2025-10-13
healthScore:
  content: green
  usability: green
  maintenance: green
---
# Rule 2 (missing description)
EOF

set +e
output=$(bash "$SCRIPT" "$tmpdir/file1.mdc" "$tmpdir/file2.mdc" 2>&1)
status=$?
set -e

if [ $status -eq 0 ]; then
  echo "FAIL: Batch with errors should fail"
  exit 1
fi

if ! [[ "$output" =~ "file2.mdc" ]] || ! [[ "$output" =~ "missing required field: description" ]]; then
  echo "FAIL: Should report file2.mdc error"
  echo "Output: $output"
  exit 1
fi

# file1 should not have errors
if [[ "$output" =~ "file1.mdc" ]]; then
  echo "FAIL: file1.mdc should not have errors"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 5 - Batch validation works"

# Test 6: JSON output format
output=$(bash "$SCRIPT" --format json "$tmpdir/valid.mdc" 2>&1)
status=$?

if [ $status -ne 0 ]; then
  echo "FAIL: JSON format should work with valid file"
  exit 1
fi

# Should be valid JSON (basic check)
if ! echo "$output" | grep -q '"files"'; then
  echo "FAIL: JSON output should contain 'files' key"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 6 - JSON output format"

echo ""
echo "All tests passed!"

