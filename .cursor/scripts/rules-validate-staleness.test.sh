#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

# Test suite for rules-validate-staleness.sh
# Owner tests for staleness checking extraction

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT="$SCRIPT_DIR/rules-validate-staleness.sh"

# Create temp directory for test fixtures
tmpdir="$ROOT_DIR/.test-artifacts/rules-validate-staleness-$$"
mkdir -p "$tmpdir"
trap_cleanup "$tmpdir"

# Test 1: Recent date passes
cat > "$tmpdir/recent.mdc" <<EOF
---
description: Test rule
lastReviewed: $(date -u +%Y-%m-%d)
---
# Test Rule
EOF

set +e
output=$(bash "$SCRIPT" "$tmpdir/recent.mdc" 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Recent lastReviewed should pass"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 1 - Recent date passes"

# Test 2: Stale date detected (default 90 days)
# Create a date 100 days ago
old_date=$(date -u -v-100d +%Y-%m-%d 2>/dev/null || date -u -d '100 days ago' +%Y-%m-%d 2>/dev/null)

cat > "$tmpdir/stale.mdc" <<EOF
---
description: Test rule
lastReviewed: $old_date
---
# Test Rule
EOF

set +e
output=$(bash "$SCRIPT" "$tmpdir/stale.mdc" 2>&1)
status=$?
set -e

# Should report staleness but not fail by default
if [ $status -ne 0 ]; then
  echo "FAIL: Stale check should not fail by default"
  echo "Output: $output"
  exit 1
fi

if ! [[ "$output" =~ "stale lastReviewed" ]]; then
  echo "FAIL: Should report stale lastReviewed"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 2 - Stale date detected (informational)"

# Test 3: Fail on stale when --fail-on-stale is set
set +e
output=$(bash "$SCRIPT" --fail-on-stale "$tmpdir/stale.mdc" 2>&1)
status=$?
set -e

if [ $status -eq 0 ]; then
  echo "FAIL: --fail-on-stale should exit non-zero for stale dates"
  exit 1
fi

if ! [[ "$output" =~ "stale lastReviewed" ]]; then
  echo "FAIL: Should report stale lastReviewed"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 3 - Fail on stale with flag"

# Test 4: Custom staleness threshold (--stale-days)
# Create a date 50 days ago
mid_date=$(date -u -v-50d +%Y-%m-%d 2>/dev/null || date -u -d '50 days ago' +%Y-%m-%d 2>/dev/null)

cat > "$tmpdir/mid.mdc" <<EOF
---
description: Test rule
lastReviewed: $mid_date
---
# Test Rule
EOF

# Should pass with 90-day threshold
set +e
output=$(bash "$SCRIPT" "$tmpdir/mid.mdc" 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: 50-day-old date should pass with default 90-day threshold"
  exit 1
fi

# Should fail with 30-day threshold
set +e
output=$(bash "$SCRIPT" --stale-days 30 "$tmpdir/mid.mdc" 2>&1)
status=$?
set -e

if ! [[ "$output" =~ "stale" ]]; then
  echo "FAIL: 50-day-old date should be stale with 30-day threshold"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 4 - Custom staleness threshold"

# Test 5: Missing lastReviewed is silently skipped
cat > "$tmpdir/no-date.mdc" <<'EOF'
---
description: Test rule
---
# Test Rule
EOF

set +e
output=$(bash "$SCRIPT" "$tmpdir/no-date.mdc" 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Missing lastReviewed should not fail"
  exit 1
fi

echo "PASS: Test 5 - Missing lastReviewed silently skipped"

# Test 6: JSON output format
set +e
output=$(bash "$SCRIPT" --format json "$tmpdir/stale.mdc" 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: JSON format should work"
  exit 1
fi

if ! echo "$output" | grep -q '"files"'; then
  echo "FAIL: JSON output should contain 'files' key"
  echo "Output: $output"
  exit 1
fi

if ! echo "$output" | grep -q '"stale_files"'; then
  echo "FAIL: JSON output should contain 'stale_files' key"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 6 - JSON output format"

echo ""
echo "All tests passed!"

