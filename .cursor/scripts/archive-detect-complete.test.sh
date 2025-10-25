#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Test suite for archive-detect-complete.sh
# Owner tests for project completion detection

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT="$SCRIPT_DIR/archive-detect-complete.sh"

# Create temp directory for test fixtures
TEMP_DIR="$ROOT_DIR/tmp/archive-detect-test-$$"
mkdir -p "$TEMP_DIR/projects"
trap 'rm -rf "$TEMP_DIR"' EXIT

# Test 1: Help flag works
echo "Test 1: Help flag..."
set +e
output=$(bash "$SCRIPT" --help 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: --help should exit 0"
  exit 1
fi

if ! [[ "$output" =~ "Usage:" ]]; then
  echo "FAIL: --help should show usage"
  exit 1
fi

echo "PASS: Test 1 - Help flag works"

# Test 2: All criteria met → returns project
echo "Test 2: All criteria met..."
PROJECT_DIR="$TEMP_DIR/projects/complete-project"
mkdir -p "$PROJECT_DIR"

cat > "$PROJECT_DIR/erd.md" <<'EOF'
---
status: active
---

# Engineering Requirements Document — Complete Project

Mode: Lite
EOF

cat > "$PROJECT_DIR/tasks.md" <<'EOF'
## Tasks

- [x] 1.0 Task one
  - [x] 1.1 Subtask
- [x] 2.0 Task two
EOF

cat > "$PROJECT_DIR/final-summary.md" <<'EOF'
# Final Summary
Project complete
EOF

set +e
output=$(bash "$SCRIPT" --projects-dir "$TEMP_DIR/projects" 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Should detect complete project"
  echo "Output: $output"
  exit 1
fi

if ! echo "$output" | grep -q "complete-project"; then
  echo "FAIL: Should include complete-project in output"
  echo "Output: $output"
  exit 1
fi

if ! echo "$output" | grep -q '"tasksComplete": true'; then
  echo "FAIL: Should report tasksComplete: true"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 2 - Detects complete project"

# Test 3: Missing task checkmarks → skips project
echo "Test 3: Unchecked tasks..."
PROJECT_DIR="$TEMP_DIR/projects/incomplete-tasks"
mkdir -p "$PROJECT_DIR"

cat > "$PROJECT_DIR/erd.md" <<'EOF'
---
status: active
---

# Test Project

Mode: Lite
EOF

cat > "$PROJECT_DIR/tasks.md" <<'EOF'
## Tasks

- [x] 1.0 Task one
- [ ] 2.0 Task two (not done)
EOF

cat > "$PROJECT_DIR/final-summary.md" <<'EOF'
# Final Summary
EOF

set +e
output=$(bash "$SCRIPT" --projects-dir "$TEMP_DIR/projects" 2>&1)
status=$?
set -e

if echo "$output" | grep -q "incomplete-tasks"; then
  echo "FAIL: Should skip project with unchecked tasks"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 3 - Skips project with unchecked tasks"

# Test 4: Carryovers with unchecked items → skips
echo "Test 4: Carryovers with unchecked items..."
PROJECT_DIR="$TEMP_DIR/projects/has-carryovers"
mkdir -p "$PROJECT_DIR"

cat > "$PROJECT_DIR/erd.md" <<'EOF'
---
status: active
---

# Test Project

Mode: Lite
EOF

cat > "$PROJECT_DIR/tasks.md" <<'EOF'
## Tasks

- [x] 1.0 Task one
- [x] 2.0 Task two

## Carryovers

- [ ] 3.0 Future task (deferred)
EOF

cat > "$PROJECT_DIR/final-summary.md" <<'EOF'
# Final Summary
EOF

set +e
output=$(bash "$SCRIPT" --projects-dir "$TEMP_DIR/projects" 2>&1)
status=$?
set -e

if echo "$output" | grep -q "has-carryovers"; then
  echo "FAIL: Should skip project with unchecked carryovers"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 4 - Skips project with unchecked carryovers"

# Test 5: Missing final-summary → skips
echo "Test 5: Missing final-summary..."
PROJECT_DIR="$TEMP_DIR/projects/no-summary"
mkdir -p "$PROJECT_DIR"

cat > "$PROJECT_DIR/erd.md" <<'EOF'
---
status: active
---

# Test Project

Mode: Lite
EOF

cat > "$PROJECT_DIR/tasks.md" <<'EOF'
## Tasks

- [x] 1.0 Task one
- [x] 2.0 Task two
EOF

# No final-summary.md created

set +e
output=$(bash "$SCRIPT" --projects-dir "$TEMP_DIR/projects" 2>&1)
status=$?
set -e

if echo "$output" | grep -q "no-summary"; then
  echo "FAIL: Should skip project without final-summary"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 5 - Skips project without final-summary"

# Test 6: Empty carryovers section → allowed
echo "Test 6: Empty carryovers section..."
PROJECT_DIR="$TEMP_DIR/projects/empty-carryovers"
mkdir -p "$PROJECT_DIR"

cat > "$PROJECT_DIR/erd.md" <<'EOF'
---
status: active
---

# Test Project

Mode: Lite
EOF

cat > "$PROJECT_DIR/tasks.md" <<'EOF'
## Tasks

- [x] 1.0 Task one
- [x] 2.0 Task two

## Carryovers

(All resolved - moved to new projects)
EOF

cat > "$PROJECT_DIR/final-summary.md" <<'EOF'
# Final Summary
EOF

set +e
output=$(bash "$SCRIPT" --projects-dir "$TEMP_DIR/projects" 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Should accept empty carryovers section"
  echo "Output: $output"
  exit 1
fi

if ! echo "$output" | grep -q "empty-carryovers"; then
  echo "FAIL: Should include project with empty carryovers"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 6 - Accepts empty carryovers section"

# Test 7: JSON output format
echo "Test 7: JSON output format..."
set +e
output=$(bash "$SCRIPT" --projects-dir "$TEMP_DIR/projects" 2>&1)
status=$?
set -e

if ! [[ "$output" =~ ^\[.*\]$ ]]; then
  echo "FAIL: Output should be JSON array"
  echo "Output: $output"
  exit 1
fi

if ! echo "$output" | grep -q '"slug"'; then
  echo "FAIL: JSON should contain slug field"
  exit 1
fi

echo "PASS: Test 7 - Outputs valid JSON"

# Test 8: Zero completed projects
echo "Test 8: Zero completed projects..."
EMPTY_DIR="$TEMP_DIR/empty-projects"
mkdir -p "$EMPTY_DIR"

set +e
output=$(bash "$SCRIPT" --projects-dir "$EMPTY_DIR" 2>&1)
status=$?
set -e

if [ $status -ne 0 ]; then
  echo "FAIL: Should exit 0 when no completed projects"
  exit 1
fi

if ! [[ "$output" == "[]" ]]; then
  echo "FAIL: Should return empty JSON array"
  echo "Output: $output"
  exit 1
fi

echo "PASS: Test 8 - Returns empty array when no projects"

echo ""
echo "All tests passed!"

