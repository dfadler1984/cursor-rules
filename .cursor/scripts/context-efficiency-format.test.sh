#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/context-efficiency-format.sh"

# Test 1: Format line output
output=$(bash "$SCRIPT" --score 5 --label lean --scope-concrete true --rules 2 --loops 0 --format line)
[[ "$output" =~ "5/5 (lean)" ]] || { echo "Test 1 failed: line format"; exit 1; }
[[ "$output" =~ "narrow scope" ]] || { echo "Test 1 failed: missing scope in rationale"; exit 1; }

# Test 2: Format dashboard output
output=$(bash "$SCRIPT" --score 3 --label ok --scope-concrete true --rules 7 --loops 2 --format dashboard)
[[ "$output" =~ "CONTEXT EFFICIENCY" ]] || { echo "Test 2 failed: dashboard header"; exit 1; }
[[ "$output" =~ "3/5" ]] || { echo "Test 2 failed: score in dashboard"; exit 1; }
[[ "$output" =~ "Rules: 7" ]] || { echo "Test 2 failed: rules count"; exit 1; }

# Test 3: Format JSON output
output=$(bash "$SCRIPT" --score 4 --label ok --scope-concrete true --rules 3 --loops 1 --format json)
[[ "$output" =~ '"score": 4' ]] || { echo "Test 3 failed: JSON score"; exit 1; }
[[ "$output" =~ '"label": "ok"' ]] || { echo "Test 3 failed: JSON label"; exit 1; }
[[ "$output" =~ '"recommendation"' ]] || { echo "Test 3 failed: JSON recommendation"; exit 1; }

# Test 4: Format decision-flow (static output, no inputs needed)
output=$(bash "$SCRIPT" --format decision-flow)
[[ "$output" =~ "SHOULD I START A NEW CHAT" ]] || { echo "Test 4 failed: decision-flow header"; exit 1; }
[[ "$output" =~ "scope narrow and concrete" ]] || { echo "Test 4 failed: decision-flow content"; exit 1; }

# Test 5: Default format is line
output=$(bash "$SCRIPT" --score 5 --label lean --scope-concrete true --rules 0 --loops 0)
[[ "$output" =~ "5/5 (lean)" ]] || { echo "Test 5 failed: default format should be line"; exit 1; }

# Test 6: Help flag works
bash "$SCRIPT" --help >/dev/null || { echo "Test 6 failed: --help"; exit 1; }

exit 0

