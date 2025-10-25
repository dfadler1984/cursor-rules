#!/usr/bin/env bash
set -euo pipefail

# Test suite for erd-add-mode-line.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT="$SCRIPT_DIR/erd-add-mode-line.sh"

TEMP_DIR="$ROOT_DIR/tmp/erd-mode-test-$$"
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

# Test 2: Adds Mode line after H1
echo "Test 2: Add Mode line..."
cat > "$TEMP_DIR/test.md" <<'EOF'
# Engineering Requirements Document — Test

## Section
EOF

bash "$SCRIPT" "$TEMP_DIR/test.md" >/dev/null 2>&1

if ! grep -q "^Mode: Lite$" "$TEMP_DIR/test.md"; then
  echo "FAIL: Should add Mode: Lite"
  exit 1
fi

# Mode should appear after the H1 (not necessarily immediately after)
h1_line=$(grep -n "^# Engineering" "$TEMP_DIR/test.md" | cut -d: -f1)
mode_line=$(grep -n "^Mode: Lite" "$TEMP_DIR/test.md" | cut -d: -f1)

if [ "$mode_line" -le "$h1_line" ]; then
  echo "FAIL: Mode should be after H1"
  exit 1
fi

echo "PASS"

# Test 3: Skips if Mode already exists
echo "Test 3: Skip if exists..."
cat > "$TEMP_DIR/hasmode.md" <<'EOF'
# Test

Mode: Full
EOF

output=$(bash "$SCRIPT" "$TEMP_DIR/hasmode.md" 2>&1)
if ! [[ "$output" =~ "already has Mode" ]]; then
  echo "FAIL: Should skip if Mode exists"
  exit 1
fi

echo "PASS"

echo ""
echo "All tests passed!"

