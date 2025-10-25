#!/usr/bin/env bash
set -euo pipefail

# Test for empty YAML front matter detection in erd-validate.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT="$SCRIPT_DIR/erd-validate.sh"

# Create temp directory for test fixtures
TEMP_DIR="$ROOT_DIR/tmp/erd-validate-test-$$"
mkdir -p "$TEMP_DIR"
trap 'rm -rf "$TEMP_DIR"' EXIT

# Test 1: Empty YAML front matter should fail
echo "Test 1: Empty YAML front matter..."
cat > "$TEMP_DIR/empty-frontmatter.md" <<'EOF'
---
---

# Engineering Requirements Document — Test Project

Mode: Lite

## 1. Introduction/Overview
Test content
EOF

set +e
output=$(bash "$SCRIPT" "$TEMP_DIR/empty-frontmatter.md" 2>&1)
status=$?
set -e

if [ $status -eq 0 ]; then
  echo "FAIL: Should reject empty YAML front matter"
  echo "Output: $output"
  exit 1
fi

if ! echo "$output" | grep -q "empty front matter"; then
  echo "FAIL: Should report empty front matter issue"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 1 - Detects empty YAML front matter"

# Test 2: Front matter with only whitespace should fail
echo "Test 2: Front matter with only whitespace..."
cat > "$TEMP_DIR/whitespace-frontmatter.md" <<'EOF'
---

---

# Engineering Requirements Document — Test Project

Mode: Lite
EOF

set +e
output=$(bash "$SCRIPT" "$TEMP_DIR/whitespace-frontmatter.md" 2>&1)
status=$?
set -e

if [ $status -eq 0 ]; then
  echo "FAIL: Should reject whitespace-only front matter"
  echo "Output: $output"
  exit 1
fi

if ! echo "$output" | grep -q "empty front matter"; then
  echo "FAIL: Should report empty front matter issue"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 2 - Detects whitespace-only front matter"

# Test 3: Valid front matter with status should not trigger empty check
echo "Test 3: Valid front matter passes empty check..."
cat > "$TEMP_DIR/valid-nonempty.md" <<'EOF'
---
status: active
owner: test-team
created: 2025-10-24
lastUpdated: 2025-10-24
---

# Engineering Requirements Document — Test Project

Mode: Lite

## 1. Introduction/Overview
Test content
EOF

set +e
output=$(bash "$SCRIPT" "$TEMP_DIR/valid-nonempty.md" 2>&1)
status=$?
set -e

# Should pass - has all required fields
if [ $status -ne 0 ]; then
  if echo "$output" | grep -q "empty front matter"; then
    echo "FAIL: Should not report empty front matter when content exists"
    echo "Output: $output"
    exit 1
  fi
  # Other failures are OK (not testing full validation here)
fi

echo "PASS: Test 3 - Valid non-empty front matter accepted"

echo ""
echo "All tests passed!"

