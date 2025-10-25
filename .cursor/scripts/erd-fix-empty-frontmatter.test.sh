#!/usr/bin/env bash
set -euo pipefail

# Test suite for erd-fix-empty-frontmatter.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT="$SCRIPT_DIR/erd-fix-empty-frontmatter.sh"

TEMP_DIR="$ROOT_DIR/tmp/erd-fixfm-test-$$"
mkdir -p "$TEMP_DIR"
trap 'rm -rf "$TEMP_DIR"' EXIT

# Test 1: Help flag
echo "Test 1: Help flag..."
output=$(bash "$SCRIPT" --help 2>&1)
if [ $? -ne 0 ] || ! [[ "$output" =~ "Usage:" ]]; then
  echo "FAIL: Help should work"
  exit 1
fi
echo "PASS"

# Test 2: Fixes empty front matter
echo "Test 2: Fix empty FM..."
cat > "$TEMP_DIR/test.md" <<'EOF'
---
---

# Test ERD

Content
EOF

bash "$SCRIPT" "$TEMP_DIR/test.md" >/dev/null 2>&1

if ! grep -q "^status:" "$TEMP_DIR/test.md"; then
  echo "FAIL: Should add status field"
  exit 1
fi

if ! grep -q "^owner:" "$TEMP_DIR/test.md"; then
  echo "FAIL: Should add owner field"
  exit 1
fi

echo "PASS"

# Test 3: Custom status and owner
echo "Test 3: Custom values..."
cat > "$TEMP_DIR/custom.md" <<'EOF'
---
---

# Test
EOF

bash "$SCRIPT" "$TEMP_DIR/custom.md" --status planning --owner custom-team >/dev/null 2>&1

if ! grep -q "^status: planning$" "$TEMP_DIR/custom.md"; then
  echo "FAIL: Should use custom status"
  exit 1
fi

if ! grep -q "^owner: custom-team$" "$TEMP_DIR/custom.md"; then
  echo "FAIL: Should use custom owner"
  exit 1
fi

echo "PASS"

echo ""
echo "All tests passed!"

