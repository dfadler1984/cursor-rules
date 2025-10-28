#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/project-create.sh"

# Arrange: temp workspace
WORKDIR="$(mktemp -d 2>/dev/null || mktemp -d -t project-create)"
mkdir -p "$WORKDIR/docs/projects"

# Test 1: missing --name argument should exit 2
set +e
out1=$(bash "$SCRIPT" --root "$WORKDIR" 2>&1)
status1=$?
set -e
[ $status1 -eq 2 ] || { echo "Test 1 failed: expected exit 2, got $status1"; echo "$out1"; exit 1; }
echo "$out1" | grep -q -- "--name is required" || { echo "Test 1 failed: expected '--name is required' in output"; exit 1; }

# Test 2: invalid slug (non-kebab-case) should exit 1
set +e
out2=$(bash "$SCRIPT" --name "Invalid_Slug" --root "$WORKDIR" 2>&1)
status2=$?
set -e
[ $status2 -eq 1 ] || { echo "Test 2 failed: expected exit 1, got $status2"; echo "$out2"; exit 1; }
echo "$out2" | grep -q "slug must be kebab-case" || { echo "Test 2 failed: expected slug validation message"; echo "$out2"; exit 1; }

# Test 3: project directory already exists should exit 1
mkdir -p "$WORKDIR/docs/projects/existing-project"
set +e
out3=$(bash "$SCRIPT" --name "existing-project" --root "$WORKDIR" 2>&1)
status3=$?
set -e
[ $status3 -eq 1 ] || { echo "Test 3 failed: expected exit 1 for existing dir, got $status3"; echo "$out3"; exit 1; }
echo "$out3" | grep -q "already exists" || { echo "Test 3 failed: expected 'already exists' message"; echo "$out3"; exit 1; }

# Test 4: successful project creation (full mode)
set +e
out4=$(bash "$SCRIPT" --name "test-project" --mode full --owner "test-team" --root "$WORKDIR" 2>&1)
status4=$?
set -e
[ $status4 -eq 0 ] || { echo "Test 4 failed: expected exit 0, got $status4"; echo "$out4"; exit 1; }

# Verify files created
[ -f "$WORKDIR/docs/projects/test-project/erd.md" ] || { echo "Test 4 failed: erd.md not created"; exit 1; }
[ -f "$WORKDIR/docs/projects/test-project/tasks.md" ] || { echo "Test 4 failed: tasks.md not created"; exit 1; }
[ -f "$WORKDIR/docs/projects/test-project/README.md" ] || { echo "Test 4 failed: README.md not created"; exit 1; }

# Verify ERD front matter
grep -q "status: planning" "$WORKDIR/docs/projects/test-project/erd.md" || { echo "Test 4 failed: status not set"; cat "$WORKDIR/docs/projects/test-project/erd.md"; exit 1; }
grep -q "owner: test-team" "$WORKDIR/docs/projects/test-project/erd.md" || { echo "Test 4 failed: owner not set"; exit 1; }
grep -q "^created: " "$WORKDIR/docs/projects/test-project/erd.md" || { echo "Test 4 failed: created date not set"; exit 1; }

# Verify ERD structure (Full mode)
grep -q "## 1. Introduction/Overview" "$WORKDIR/docs/projects/test-project/erd.md" || { echo "Test 4 failed: section 1 missing"; exit 1; }
grep -q "## 14. Open Questions" "$WORKDIR/docs/projects/test-project/erd.md" || { echo "Test 4 failed: section 14 missing (full mode)"; exit 1; }

# Test 5: lite mode has fewer sections
set +e
out5=$(bash "$SCRIPT" --name "lite-project" --mode lite --owner "test-team" --root "$WORKDIR" 2>&1)
status5=$?
set -e
[ $status5 -eq 0 ] || { echo "Test 5 failed: expected exit 0, got $status5"; echo "$out5"; exit 1; }
grep -q "## 1. Introduction/Overview" "$WORKDIR/docs/projects/lite-project/erd.md" || { echo "Test 5 failed: lite section 1 missing"; exit 1; }
grep -q "## 6. Rollout" "$WORKDIR/docs/projects/lite-project/erd.md" || { echo "Test 5 failed: lite section 6 missing"; exit 1; }
if grep -q "## 14. Open Questions" "$WORKDIR/docs/projects/lite-project/erd.md"; then
  echo "Test 5 failed: lite mode should not have section 14"
  exit 1
fi

# Test 6: default mode is full
set +e
out6=$(bash "$SCRIPT" --name "default-project" --owner "test-team" --root "$WORKDIR" 2>&1)
status6=$?
set -e
[ $status6 -eq 0 ] || { echo "Test 6 failed: expected exit 0, got $status6"; exit 1; }
grep -q "## 14. Open Questions" "$WORKDIR/docs/projects/default-project/erd.md" || { echo "Test 6 failed: default should be full mode"; exit 1; }

# Test 7: default owner is repo-maintainers
set +e
out7=$(bash "$SCRIPT" --name "owner-test" --root "$WORKDIR" 2>&1)
status7=$?
set -e
[ $status7 -eq 0 ] || { echo "Test 7 failed: expected exit 0, got $status7"; exit 1; }
grep -q "owner: repo-maintainers" "$WORKDIR/docs/projects/owner-test/erd.md" || { echo "Test 7 failed: default owner not set"; exit 1; }

# Test 8: tasks.md structure
grep -q "# Tasks — Test Project" "$WORKDIR/docs/projects/test-project/tasks.md" || { echo "Test 8 failed: tasks title incorrect"; exit 1; }
grep -q "## Relevant Files" "$WORKDIR/docs/projects/test-project/tasks.md" || { echo "Test 8 failed: Relevant Files section missing"; exit 1; }
grep -q "## Phase 1:" "$WORKDIR/docs/projects/test-project/tasks.md" || { echo "Test 8 failed: Phase 1 section missing"; exit 1; }

# Test 9: README structure
grep -q "# Test Project" "$WORKDIR/docs/projects/test-project/README.md" || { echo "Test 9 failed: README title incorrect"; exit 1; }
grep -q "\*\*Status\*\*: Planning" "$WORKDIR/docs/projects/test-project/README.md" || { echo "Test 9 failed: Status line missing"; exit 1; }
grep -q "\[ERD\](./erd.md)" "$WORKDIR/docs/projects/test-project/README.md" || { echo "Test 9 failed: ERD link missing"; exit 1; }
grep -q "\[Tasks\](./tasks.md)" "$WORKDIR/docs/projects/test-project/README.md" || { echo "Test 9 failed: Tasks link missing"; exit 1; }

# Test 10: help flag
set +e
out10=$(bash "$SCRIPT" --help 2>&1)
status10=$?
set -e
[ $status10 -eq 0 ] || { echo "Test 10 failed: --help should exit 0, got $status10"; exit 1; }
echo "$out10" | grep -q "Usage:" || { echo "Test 10 failed: Usage message missing"; exit 1; }
echo "$out10" | grep -q -- "--name" || { echo "Test 10 failed: --name option not documented"; exit 1; }
echo "$out10" | grep -q -- "--mode" || { echo "Test 10 failed: --mode option not documented"; exit 1; }

# Test 11: --with-changelog flag creates CHANGELOG.md
# Setup: Copy template to test workspace
mkdir -p "$WORKDIR/.cursor/templates/project-lifecycle"
cp "$ROOT_DIR/.cursor/templates/project-lifecycle/CHANGELOG.template.md" "$WORKDIR/.cursor/templates/project-lifecycle/"

set +e
out11=$(bash "$SCRIPT" --name "changelog-project" --with-changelog --root "$WORKDIR" 2>&1)
status11=$?
set -e
[ $status11 -eq 0 ] || { echo "Test 11 failed: expected exit 0, got $status11"; echo "$out11"; exit 1; }

# Verify CHANGELOG.md created
[ -f "$WORKDIR/docs/projects/changelog-project/CHANGELOG.md" ] || { echo "Test 11 failed: CHANGELOG.md not created"; ls -la "$WORKDIR/docs/projects/changelog-project/"; exit 1; }

# Verify template placeholders replaced
grep -q "# Changelog — Changelog Project" "$WORKDIR/docs/projects/changelog-project/CHANGELOG.md" || { echo "Test 11 failed: title placeholder not replaced"; exit 1; }

# Verify date replaced
grep -qE "[0-9]{4}-[0-9]{2}-[0-9]{2}" "$WORKDIR/docs/projects/changelog-project/CHANGELOG.md" || { echo "Test 11 failed: date placeholder not replaced"; exit 1; }

# Test 12: without --with-changelog flag, no CHANGELOG.md created
set +e
out12=$(bash "$SCRIPT" --name "no-changelog-project" --root "$WORKDIR" 2>&1)
status12=$?
set -e
[ $status12 -eq 0 ] || { echo "Test 12 failed: expected exit 0, got $status12"; echo "$out12"; exit 1; }

# Verify CHANGELOG.md NOT created
if [ -f "$WORKDIR/docs/projects/no-changelog-project/CHANGELOG.md" ]; then
  echo "Test 12 failed: CHANGELOG.md should not be created without flag"
  exit 1
fi

# Cleanup
rm -rf "$WORKDIR"

echo "All tests passed"
exit 0

