#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

# Test suite for rules-validate-format.sh
# Owner tests for format/structure validation extraction
# Checks: CSV spacing, boolean casing, deprecated refs, embedded FM, duplicate headers

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT="$SCRIPT_DIR/rules-validate-format.sh"

# Create temp directory for test fixtures
tmpdir="$ROOT_DIR/.test-artifacts/rules-validate-format-$$"
mkdir -p "$tmpdir"
trap_cleanup "$tmpdir"

# Test 1: Valid formatting passes
cat > "$tmpdir/valid.mdc" <<'EOF'
---
description: Test rule
globs: **/*.ts,**/*.tsx
alwaysApply: true
---
# Test Rule

Content here.
EOF

set +e
output=$(bash "$SCRIPT" "$tmpdir/valid.mdc" 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Valid formatting should pass"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 1 - Valid formatting passes"

# Test 2: CSV spacing detected
cat > "$tmpdir/csv-spaces.mdc" <<'EOF'
---
description: Test rule
globs: **/*.ts, **/*.tsx
---
# Test Rule
EOF

set +e
output=$(bash "$SCRIPT" "$tmpdir/csv-spaces.mdc" 2>&1)
status=$?
set -e

if [ $status -eq 0 ]; then
  echo "FAIL: CSV spaces should fail"
  exit 1
fi

if ! [[ "$output" =~ "spaces around commas" ]]; then
  echo "FAIL: Should report CSV spacing issue"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 2 - CSV spacing detected"

# Test 3: Brace expansion detected
cat > "$tmpdir/braces.mdc" <<'EOF'
---
description: Test rule
globs: **/*.{ts,tsx}
---
# Test Rule
EOF

set +e
output=$(bash "$SCRIPT" "$tmpdir/braces.mdc" 2>&1)
status=$?
set -e

if [ $status -eq 0 ]; then
  echo "FAIL: Brace expansion should fail"
  exit 1
fi

if ! [[ "$output" =~ "brace expansion" ]]; then
  echo "FAIL: Should report brace expansion issue"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 3 - Brace expansion detected"

# Test 4: Incorrect boolean casing detected
cat > "$tmpdir/wrong-boolean.mdc" <<'EOF'
---
description: Test rule
alwaysApply: True
---
# Test Rule
EOF

set +e
output=$(bash "$SCRIPT" "$tmpdir/wrong-boolean.mdc" 2>&1)
status=$?
set -e

if [ $status -eq 0 ]; then
  echo "FAIL: Wrong boolean casing should fail"
  exit 1
fi

if ! [[ "$output" =~ "alwaysApply must be unquoted lowercase" ]]; then
  echo "FAIL: Should report boolean casing issue"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 4 - Boolean casing detected"

# Test 5: Embedded front matter detected
cat > "$tmpdir/embedded.mdc" <<'EOF'
---
description: Test rule
---
# Test Rule

Some content

---
unexpected: second block
---

More content
EOF

set +e
output=$(bash "$SCRIPT" "$tmpdir/embedded.mdc" 2>&1)
status=$?
set -e

if [ $status -eq 0 ]; then
  echo "FAIL: Embedded front matter should fail"
  exit 1
fi

if ! [[ "$output" =~ "embedded front matter" ]]; then
  echo "FAIL: Should report embedded front matter"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 5 - Embedded front matter detected"

# Test 6: Duplicate top-level headers detected
cat > "$tmpdir/duplicate-headers.mdc" <<'EOF'
---
description: Test rule
---
# First Header

Content

# Second Header

More content
EOF

set +e
output=$(bash "$SCRIPT" "$tmpdir/duplicate-headers.mdc" 2>&1)
status=$?
set -e

if [ $status -eq 0 ]; then
  echo "FAIL: Duplicate headers should fail"
  exit 1
fi

if ! [[ "$output" =~ "duplicate top-level header" ]]; then
  echo "FAIL: Should report duplicate header"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 6 - Duplicate headers detected"

# Test 7: JSON output format
set +e
output=$(bash "$SCRIPT" --format json "$tmpdir/csv-spaces.mdc" 2>&1)
status=$?
set -e

if ! echo "$output" | grep -q '"files"'; then
  echo "FAIL: JSON output should contain 'files' key"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 7 - JSON output format"

echo ""
echo "All tests passed!"

