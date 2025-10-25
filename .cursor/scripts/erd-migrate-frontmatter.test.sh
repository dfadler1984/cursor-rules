#!/usr/bin/env bash
set -euo pipefail

# Test suite for erd-migrate-frontmatter.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT="$SCRIPT_DIR/erd-migrate-frontmatter.sh"

TEMP_DIR="$ROOT_DIR/tmp/erd-migrate-test-$$"
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

# Test 2: Migrates markdown fields to YAML
echo "Test 2: Markdown to YAML migration..."
cat > "$TEMP_DIR/test.md" <<'EOF'
# Test ERD

**Status**: ACTIVE
**Owner**: test-team
**Created**: 2025-10-24

## Content
EOF

bash "$SCRIPT" "$TEMP_DIR/test.md" >/dev/null 2>&1

if ! grep -q "^status: active$" "$TEMP_DIR/test.md"; then
  echo "FAIL: Should convert Status to status in YAML"
  exit 1
fi

if ! grep -q "^owner: test-team$" "$TEMP_DIR/test.md"; then
  echo "FAIL: Should add owner to YAML"
  exit 1
fi

if grep -q "\*\*Status\*\*:" "$TEMP_DIR/test.md"; then
  echo "FAIL: Should remove markdown Status field"
  exit 1
fi

echo "PASS"

# Test 3: Dry-run mode
echo "Test 3: Dry-run..."
cat > "$TEMP_DIR/dryrun.md" <<'EOF'
# Test

**Status**: ACTIVE
EOF

ORIGINAL=$(cat "$TEMP_DIR/dryrun.md")
bash "$SCRIPT" "$TEMP_DIR/dryrun.md" --dry-run >/dev/null 2>&1

if [ "$(cat "$TEMP_DIR/dryrun.md")" != "$ORIGINAL" ]; then
  echo "FAIL: Dry-run should not modify file"
  exit 1
fi

echo "PASS"

echo ""
echo "All tests passed!"

