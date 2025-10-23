#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/project-complete.sh"

# Arrange: temp workspace with test project
WORKDIR="$(mktemp -d 2>/dev/null || mktemp -d -t project-complete)"
mkdir -p "$WORKDIR/docs/projects/test-project"
mkdir -p "$WORKDIR/.cursor/templates/project-lifecycle"

# Create final summary template
cat > "$WORKDIR/.cursor/templates/project-lifecycle/final-summary.template.md" <<'TPL'
---
template: project-lifecycle/final-summary
version: 1.0.0
last-updated: <date>
---

# Final Summary — <Project Name>

## Summary

<project> outcomes

## Links

- ERD: `docs/projects/<project>/erd.md`
- Tasks: `docs/projects/<project>/tasks.md`
TPL

# Create complete project (all tasks done)
cat > "$WORKDIR/docs/projects/test-project/erd.md" <<'EOF'
---
status: active
owner: test-team
created: 2025-10-01
lastUpdated: 2025-10-15
---

# Engineering Requirements Document — Test Project
EOF

cat > "$WORKDIR/docs/projects/test-project/tasks.md" <<'EOF'
# Tasks — Test Project

## Phase 1: Setup

- [x] 1.0 Initial setup
  - [x] 1.1 Create repo
  - [x] 1.2 Configure CI
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

# Test 3: incomplete tasks should require --force
cat > "$WORKDIR/docs/projects/test-project/tasks.md" <<'EOF'
# Tasks — Test Project

- [x] 1.0 Done
- [ ] 2.0 Not done
EOF

set +e
out3=$(bash "$SCRIPT" test-project --root "$WORKDIR" 2>&1)
status3=$?
set -e
[ $status3 -eq 1 ] || { echo "Test 3 failed: expected exit 1 for incomplete tasks, got $status3"; echo "$out3"; exit 1; }
echo "$out3" | grep -q "not all tasks are complete" || { echo "Test 3 failed: expected incomplete tasks message"; echo "$out3"; exit 1; }
echo "$out3" | grep -q -- "--force" || { echo "Test 3 failed: expected --force hint"; echo "$out3"; exit 1; }

# Test 4: --force allows incomplete completion
set +e
out4=$(bash "$SCRIPT" test-project --force --root "$WORKDIR" 2>&1)
status4=$?
set -e
[ $status4 -eq 0 ] || { echo "Test 4 failed: --force should succeed, got exit $status4"; echo "$out4"; exit 1; }
grep -q "status: completed" "$WORKDIR/docs/projects/test-project/erd.md" || { echo "Test 4 failed: status not updated to completed"; cat "$WORKDIR/docs/projects/test-project/erd.md"; exit 1; }
grep -q "^completedDate: " "$WORKDIR/docs/projects/test-project/erd.md" || { echo "Test 4 failed: completedDate not added"; exit 1; }

# Test 5: successful completion (100% tasks)
# Create new project for this test
mkdir -p "$WORKDIR/docs/projects/complete-proj"
cat > "$WORKDIR/docs/projects/complete-proj/erd.md" <<'EOF'
---
status: active
owner: test-team
created: 2025-10-01
lastUpdated: 2025-10-15
---

# Engineering Requirements Document — Complete Proj
EOF

cat > "$WORKDIR/docs/projects/complete-proj/tasks.md" <<'EOF'
# Tasks — Complete Proj

- [x] 1.0 Done
- [x] 2.0 Also done
EOF

set +e
out5=$(bash "$SCRIPT" complete-proj --root "$WORKDIR" --date 2025-10-20 2>&1)
status5=$?
set -e
[ $status5 -eq 0 ] || { echo "Test 5 failed: expected exit 0, got $status5"; echo "$out5"; exit 1; }

# Verify status updated
grep -q "status: completed" "$WORKDIR/docs/projects/complete-proj/erd.md" || { echo "Test 5 failed: status not updated"; cat "$WORKDIR/docs/projects/complete-proj/erd.md"; exit 1; }
grep -q "completedDate: 2025-10-20" "$WORKDIR/docs/projects/complete-proj/erd.md" || { echo "Test 5 failed: completedDate not set correctly"; exit 1; }

# Verify final summary created
[ -f "$WORKDIR/docs/projects/complete-proj/final-summary.md" ] || { echo "Test 5 failed: final-summary.md not created"; exit 1; }
grep -q "# Final Summary — Complete Proj" "$WORKDIR/docs/projects/complete-proj/final-summary.md" || { echo "Test 5 failed: final summary title incorrect"; exit 1; }

# Test 6: dry-run mode doesn't modify files
mkdir -p "$WORKDIR/docs/projects/dryrun-proj"
cat > "$WORKDIR/docs/projects/dryrun-proj/erd.md" <<'EOF'
---
status: active
owner: test-team
created: 2025-10-01
lastUpdated: 2025-10-15
---

# ERD — Dryrun Proj
EOF

cat > "$WORKDIR/docs/projects/dryrun-proj/tasks.md" <<'EOF'
- [x] Done
EOF

set +e
out6=$(bash "$SCRIPT" dryrun-proj --dry-run --root "$WORKDIR" 2>&1)
status6=$?
set -e
[ $status6 -eq 0 ] || { echo "Test 6 failed: dry-run should exit 0, got $status6"; echo "$out6"; exit 1; }
echo "$out6" | grep -q "Plan:" || { echo "Test 6 failed: dry-run should show plan"; echo "$out6"; exit 1; }

# Verify no changes made
grep -q "status: active" "$WORKDIR/docs/projects/dryrun-proj/erd.md" || { echo "Test 6 failed: dry-run modified status"; exit 1; }
if grep -q "completedDate:" "$WORKDIR/docs/projects/dryrun-proj/erd.md"; then
  echo "Test 6 failed: dry-run added completedDate"
  exit 1
fi
[ ! -f "$WORKDIR/docs/projects/dryrun-proj/final-summary.md" ] || { echo "Test 6 failed: dry-run created final-summary.md"; exit 1; }

# Test 7: help flag
set +e
out7=$(bash "$SCRIPT" --help 2>&1)
status7=$?
set -e
[ $status7 -eq 0 ] || { echo "Test 7 failed: --help should exit 0, got $status7"; exit 1; }
echo "$out7" | grep -q "Usage:" || { echo "Test 7 failed: Usage message missing"; exit 1; }
echo "$out7" | grep -q -- "--force" || { echo "Test 7 failed: --force option not documented"; exit 1; }
echo "$out7" | grep -q -- "--dry-run" || { echo "Test 7 failed: --dry-run option not documented"; exit 1; }

# Cleanup
rm -rf "$WORKDIR"

echo "All tests passed"
exit 0

