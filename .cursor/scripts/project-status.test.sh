#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/project-status.sh"

# Arrange: temp workspace with test project
WORKDIR="$(mktemp -d 2>/dev/null || mktemp -d -t project-status)"
mkdir -p "$WORKDIR/docs/projects/test-project"

# Create ERD with front matter
cat > "$WORKDIR/docs/projects/test-project/erd.md" <<'EOF'
---
status: active
owner: test-team
created: 2025-10-01
lastUpdated: 2025-10-15
---

# Engineering Requirements Document — Test Project

## 1. Introduction/Overview

Test project for validation.
EOF

# Create tasks.md with partial completion
cat > "$WORKDIR/docs/projects/test-project/tasks.md" <<'EOF'
# Tasks — Test Project

## Relevant Files

- `docs/projects/test-project/erd.md`

## Phase 1: Setup

- [x] 1.0 Initial setup
  - [x] 1.1 Create repo
  - [ ] 1.2 Configure CI

## Phase 2: Implementation

- [ ] 2.0 Implement feature
  - [ ] 2.1 Add tests
  - [ ] 2.2 Add logic

## Notes

Total: 6 tasks (2 completed, 4 pending) = 33%
EOF

# Test 1: missing slug argument should exit 2
set +e
out1=$(bash "$SCRIPT" --root "$WORKDIR" 2>&1)
status1=$?
set -e
[ $status1 -eq 2 ] || { echo "Test 1 failed: expected exit 2, got $status1"; echo "$out1"; exit 1; }
echo "$out1" | grep -q "slug is required" || { echo "Test 1 failed: expected slug message"; echo "$out1"; exit 1; }

# Test 2: non-existent project should exit 1
set +e
out2=$(bash "$SCRIPT" nonexistent --root "$WORKDIR" 2>&1)
status2=$?
set -e
[ $status2 -eq 1 ] || { echo "Test 2 failed: expected exit 1, got $status2"; echo "$out2"; exit 1; }
echo "$out2" | grep -q "does not exist" || { echo "Test 2 failed: expected existence check"; echo "$out2"; exit 1; }

# Test 3: successful status query (text format, default)
set +e
out3=$(bash "$SCRIPT" test-project --root "$WORKDIR" 2>&1)
status3=$?
set -e
[ $status3 -eq 0 ] || { echo "Test 3 failed: expected exit 0, got $status3"; echo "$out3"; exit 1; }
echo "$out3" | grep -q "Project: test-project" || { echo "Test 3 failed: project name missing"; echo "$out3"; exit 1; }
echo "$out3" | grep -q "Status: active" || { echo "Test 3 failed: status missing"; echo "$out3"; exit 1; }
echo "$out3" | grep -q "Tasks: 2/6 complete (33%)" || { echo "Test 3 failed: task count incorrect"; echo "$out3"; exit 1; }
echo "$out3" | grep -q "Next action: continue work" || { echo "Test 3 failed: next action incorrect"; echo "$out3"; exit 1; }

# Test 4: JSON format output
set +e
out4=$(bash "$SCRIPT" test-project --format json --root "$WORKDIR" 2>&1)
status4=$?
set -e
[ $status4 -eq 0 ] || { echo "Test 4 failed: expected exit 0, got $status4"; echo "$out4"; exit 1; }
echo "$out4" | grep -q '"slug":"test-project"' || { echo "Test 4 failed: JSON slug missing"; echo "$out4"; exit 1; }
echo "$out4" | grep -q '"status":"active"' || { echo "Test 4 failed: JSON status missing"; echo "$out4"; exit 1; }
echo "$out4" | grep -q '"tasksTotal":6' || { echo "Test 4 failed: JSON total tasks incorrect"; echo "$out4"; exit 1; }
echo "$out4" | grep -q '"tasksCompleted":2' || { echo "Test 4 failed: JSON completed tasks incorrect"; echo "$out4"; exit 1; }
echo "$out4" | grep -q '"completionPct":33' || { echo "Test 4 failed: JSON completion % incorrect"; echo "$out4"; exit 1; }
echo "$out4" | grep -q '"nextAction":"continue work"' || { echo "Test 4 failed: JSON next action incorrect"; echo "$out4"; exit 1; }

# Test 5: completed project should suggest completion
cat > "$WORKDIR/docs/projects/test-project/tasks.md" <<'EOF'
# Tasks — Test Project

## Phase 1: Setup

- [x] 1.0 Initial setup
  - [x] 1.1 Create repo
  - [x] 1.2 Configure CI
EOF

set +e
out5=$(bash "$SCRIPT" test-project --root "$WORKDIR" 2>&1)
status5=$?
set -e
[ $status5 -eq 0 ] || { echo "Test 5 failed: expected exit 0, got $status5"; echo "$out5"; exit 1; }
echo "$out5" | grep -q "Tasks: 3/3 complete (100%)" || { echo "Test 5 failed: 100% not detected"; echo "$out5"; exit 1; }
echo "$out5" | grep -q "Next action: run project-complete.sh" || { echo "Test 5 failed: completion suggestion missing"; echo "$out5"; exit 1; }

# Test 6: status=completed should suggest archival
cat > "$WORKDIR/docs/projects/test-project/erd.md" <<'EOF'
---
status: completed
owner: test-team
created: 2025-10-01
lastUpdated: 2025-10-15
completedDate: 2025-10-20
---

# Engineering Requirements Document — Test Project
EOF

set +e
out6=$(bash "$SCRIPT" test-project --root "$WORKDIR" 2>&1)
status6=$?
set -e
[ $status6 -eq 0 ] || { echo "Test 6 failed: expected exit 0, got $status6"; echo "$out6"; exit 1; }
echo "$out6" | grep -q "Status: completed" || { echo "Test 6 failed: completed status not shown"; echo "$out6"; exit 1; }
echo "$out6" | grep -q "Next action: project complete; consider archiving" || { echo "Test 6 failed: archival suggestion missing"; echo "$out6"; exit 1; }

# Test 7: status=paused should suggest resume
cat > "$WORKDIR/docs/projects/test-project/erd.md" <<'EOF'
---
status: paused
owner: test-team
created: 2025-10-01
lastUpdated: 2025-10-15
---

# Engineering Requirements Document — Test Project
EOF

set +e
out7=$(bash "$SCRIPT" test-project --root "$WORKDIR" 2>&1)
status7=$?
set -e
[ $status7 -eq 0 ] || { echo "Test 7 failed: expected exit 0, got $status7"; echo "$out7"; exit 1; }
echo "$out7" | grep -q "Status: paused" || { echo "Test 7 failed: paused status not shown"; echo "$out7"; exit 1; }
echo "$out7" | grep -q "Next action: project paused; resume or close" || { echo "Test 7 failed: resume suggestion missing"; echo "$out7"; exit 1; }

# Test 8: help flag
set +e
out8=$(bash "$SCRIPT" --help 2>&1)
status8=$?
set -e
[ $status8 -eq 0 ] || { echo "Test 8 failed: --help should exit 0, got $status8"; exit 1; }
echo "$out8" | grep -q "Usage:" || { echo "Test 8 failed: Usage message missing"; exit 1; }
echo "$out8" | grep -q -- "--format" || { echo "Test 8 failed: --format option not documented"; exit 1; }

# Cleanup
rm -rf "$WORKDIR"

echo "All tests passed"
exit 0

