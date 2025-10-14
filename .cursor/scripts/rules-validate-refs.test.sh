#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

# Test suite for rules-validate-refs.sh
# Owner tests for reference validation extraction

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT="$SCRIPT_DIR/rules-validate-refs.sh"

# Create temp directory for test fixtures
tmpdir="$ROOT_DIR/.test-artifacts/rules-validate-refs-$$"
mkdir -p "$tmpdir/docs"
trap_cleanup "$tmpdir"

# Test 1: Valid local references pass
cat > "$tmpdir/target.md" <<'EOF'
# Target File
This is the target.
EOF

cat > "$tmpdir/valid-refs.mdc" <<'EOF'
---
description: Test rule
---
# Test Rule

See [target file](./target.md) for details.
Also [another link](../target.md) works.
EOF

set +e
output=$(bash "$SCRIPT" "$tmpdir/valid-refs.mdc" 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Valid references should pass (exit 0)"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 1 - Valid references pass"

# Test 2: Missing reference detected
cat > "$tmpdir/missing-ref.mdc" <<'EOF'
---
description: Test rule
---
# Test Rule

See [missing file](./does-not-exist.md) for details.
EOF

set +e
output=$(bash "$SCRIPT" --fail-on-missing "$tmpdir/missing-ref.mdc" 2>&1)
status=$?
set -e

if [ $status -eq 0 ]; then
  echo "FAIL: Missing reference should fail with --fail-on-missing"
  exit 1
fi

if ! [[ "$output" =~ "unresolved reference" ]]; then
  echo "FAIL: Should report unresolved reference"
  echo "Output: $output"
  exit 1
fi

if ! [[ "$output" =~ "does-not-exist.md" ]]; then
  echo "FAIL: Should mention the missing file"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 2 - Missing reference detected"

# Test 3: HTTP links are ignored
cat > "$tmpdir/http-links.mdc" <<'EOF'
---
description: Test rule
---
# Test Rule

See [external](https://example.com/page.html) and [mailto](mailto:test@example.com).
EOF

set +e
output=$(bash "$SCRIPT" "$tmpdir/http-links.mdc" 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: HTTP/mailto links should be ignored"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 3 - HTTP/mailto links ignored"

# Test 4: Multiple files batch mode
cat > "$tmpdir/file1.mdc" <<'EOF'
---
description: Rule 1
---
# Rule 1
See [target](./target.md).
EOF

cat > "$tmpdir/file2.mdc" <<'EOF'
---
description: Rule 2
---
# Rule 2
See [missing](./missing.md).
EOF

set +e
output=$(bash "$SCRIPT" --fail-on-missing "$tmpdir/file1.mdc" "$tmpdir/file2.mdc" 2>&1)
status=$?
set -e

if [ $status -eq 0 ]; then
  echo "FAIL: Batch with missing refs should fail"
  exit 1
fi

if ! [[ "$output" =~ "file2.mdc" ]]; then
  echo "FAIL: Should report file2.mdc"
  echo "Output: $output"
  exit 1
fi

# file1 should not have errors
if [[ "$output" =~ "file1.mdc.*unresolved" ]]; then
  echo "FAIL: file1.mdc should not have errors"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 4 - Batch validation works"

# Test 5: JSON output format
set +e
output=$(bash "$SCRIPT" --format json "$tmpdir/valid-refs.mdc" 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: JSON format should work with valid file"
  exit 1
fi

# Should be valid JSON
if ! echo "$output" | grep -q '"files"'; then
  echo "FAIL: JSON output should contain 'files' key"
  echo "Output: $output"
  exit 1
fi

if ! echo "$output" | grep -q '"missing_refs"'; then
  echo "FAIL: JSON output should contain 'missing_refs' key"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 5 - JSON output format"

# Test 6: Anchors are stripped
cat > "$tmpdir/anchors.mdc" <<'EOF'
---
description: Test rule
---
# Test Rule

See [section](./target.md#section-name).
EOF

set +e
output=$(bash "$SCRIPT" "$tmpdir/anchors.mdc" 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Anchors should be stripped and file validated"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 6 - Anchors stripped correctly"

echo ""
echo "All tests passed!"

