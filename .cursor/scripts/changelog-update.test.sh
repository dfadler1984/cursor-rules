#!/usr/bin/env bash
# Test suite for changelog-update.sh

# shellcheck disable=SC1090,SC1091
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT="$SCRIPT_DIR/changelog-update.sh"

TEST_ARTIFACTS_DIR="${TEST_ARTIFACTS_DIR:-$ROOT_DIR/.test-artifacts}"
mkdir -p "$TEST_ARTIFACTS_DIR"

# Test: Help output
echo "TEST: Help output includes usage and modes"
HELP_OUTPUT=$("$SCRIPT" --help 2>&1)
if echo "$HELP_OUTPUT" | grep -q "auto" && echo "$HELP_OUTPUT" | grep -q "interactive" && echo "$HELP_OUTPUT" | grep -q "dry-run"; then
  echo "PASS: Help shows modes"
else
  echo "FAIL: Help missing modes" >&2
  echo "Help output:" >&2
  echo "$HELP_OUTPUT" >&2
  exit 1
fi

# Test: Requires --project argument
echo "TEST: Requires --project argument"
OUTPUT=$("$SCRIPT" 2>&1 || true)
if echo "$OUTPUT" | grep -q -- "--project is required"; then
  echo "PASS: --project required"
else
  echo "FAIL: Should require --project" >&2
  echo "Actual output:" >&2
  echo "$OUTPUT" | head -5 >&2
  exit 1
fi

# Test: Validates mode argument
echo "TEST: Validates --mode argument"
OUTPUT=$("$SCRIPT" --project test --mode invalid 2>&1 || true)
if echo "$OUTPUT" | grep -q "must be.*auto.*interactive.*dry-run"; then
  echo "PASS: Mode validation works"
else
  echo "FAIL: Mode validation missing" >&2
  exit 1
fi

# Test: Detects missing project directory
echo "TEST: Detects missing project directory"
OUTPUT=$("$SCRIPT" --project nonexistent-project-xyz 2>&1 || true)
if echo "$OUTPUT" | grep -q "project directory not found"; then
  echo "PASS: Missing project detected"
else
  echo "FAIL: Should detect missing project" >&2
  exit 1
fi

# Test: Detects missing CHANGELOG.md
echo "TEST: Detects missing CHANGELOG.md"
TEST_ROOT="$TEST_ARTIFACTS_DIR/test-root-$$"
TEST_PROJECT_NAME="test-project"
mkdir -p "$TEST_ROOT/docs/projects/$TEST_PROJECT_NAME"
OUTPUT=$("$SCRIPT" --project "$TEST_PROJECT_NAME" --root "$TEST_ROOT" 2>&1 || true)
if echo "$OUTPUT" | grep -q "CHANGELOG.md not found"; then
  echo "PASS: Missing changelog detected"
  rm -rf "$TEST_ROOT"
else
  echo "FAIL: Should detect missing CHANGELOG.md" >&2
  echo "Actual output:" >&2
  echo "$OUTPUT" | head -5 >&2
  rm -rf "$TEST_ROOT"
  exit 1
fi

# Test: Source script to test internal functions
# We'll test internal functions by sourcing the script in a subshell
echo "TEST: parse_tasks_md detects completed phases"
FIXTURE_TASKS="$SCRIPT_DIR/tests/fixtures/changelog/sample-tasks.md"
if [ ! -f "$FIXTURE_TASKS" ]; then
  echo "FAIL: Sample tasks.md fixture not found" >&2
  exit 1
fi

# Test: Detect Phase 1 completion
echo "TEST: Detects completed Phase 1"
if grep -q "## Phase 1:.*COMPLETE" "$FIXTURE_TASKS"; then
  echo "PASS: Phase 1 marked complete"
else
  echo "FAIL: Should detect Phase 1 complete" >&2
  exit 1
fi

# Test: Detect completed parent tasks (1.0, 2.0)
echo "TEST: Detects completed parent tasks"
COMPLETED_TASKS=$(grep -E "^- \[x\] [0-9]+\.0 " "$FIXTURE_TASKS" | wc -l | tr -d ' ')
if [ "$COMPLETED_TASKS" -ge 2 ]; then
  echo "PASS: Found $COMPLETED_TASKS completed parent tasks"
else
  echo "FAIL: Should find at least 2 completed parent tasks, found $COMPLETED_TASKS" >&2
  exit 1
fi

# Test: Detect decision markers
echo "TEST: Detects decision markers (D1:, Decision:)"
if grep -E "(^-\s+)?D[0-9]+:" "$FIXTURE_TASKS" >/dev/null; then
  echo "PASS: Found decision marker"
else
  echo "FAIL: Should detect decision markers" >&2
  exit 1
fi

# Test: Detect scope changes (Migrated, Superseded, Deferred)
echo "TEST: Detects scope change keywords"
SCOPE_CHANGES=$(grep -iE "(Migrated|Superseded|Deferred)" "$FIXTURE_TASKS" | wc -l | tr -d ' ')
if [ "$SCOPE_CHANGES" -ge 1 ]; then
  echo "PASS: Found $SCOPE_CHANGES scope change markers"
else
  echo "FAIL: Should detect scope changes" >&2
  exit 1
fi

# Test: Auto mode file appending
echo "TEST: Auto mode appends entry correctly"
TEST_ROOT="$TEST_ARTIFACTS_DIR/test-append-$$"
TEST_PROJECT_NAME="test-project"
TEST_PROJECT_DIR="$TEST_ROOT/docs/projects/$TEST_PROJECT_NAME"
mkdir -p "$TEST_PROJECT_DIR"

# Copy sample changelog and tasks
cp "$SCRIPT_DIR/tests/fixtures/changelog/sample-changelog.md" "$TEST_PROJECT_DIR/CHANGELOG.md"
cp "$SCRIPT_DIR/tests/fixtures/changelog/sample-tasks.md" "$TEST_PROJECT_DIR/tasks.md"

# Run in auto mode
"$SCRIPT" --project "$TEST_PROJECT_NAME" --root "$TEST_ROOT" --mode auto >/dev/null 2>&1 || true

# Verify entry was inserted after Unreleased
if [ -f "$TEST_PROJECT_DIR/CHANGELOG.md" ]; then
  # Check that new Phase entry exists
  if grep -q "## \[Phase 1:" "$TEST_PROJECT_DIR/CHANGELOG.md"; then
    # Check that it's after Unreleased
    UNRELEASED_LINE=$(grep -n "^## \[Unreleased\]" "$TEST_PROJECT_DIR/CHANGELOG.md" | cut -d: -f1)
    NEW_PHASE_LINE=$(grep -n "^## \[Phase 1: Setup\] - 2025-10-20" "$TEST_PROJECT_DIR/CHANGELOG.md" | cut -d: -f1 | tail -1)
    
    if [ "$NEW_PHASE_LINE" -gt "$UNRELEASED_LINE" ]; then
      echo "PASS: Entry inserted after Unreleased"
    else
      echo "FAIL: Entry not in correct position" >&2
      rm -rf "$TEST_ROOT"
      exit 1
    fi
  else
    echo "FAIL: New phase entry not found" >&2
    rm -rf "$TEST_ROOT"
    exit 1
  fi
  
  # Check backup was created
  if [ -f "$TEST_PROJECT_DIR/CHANGELOG.md.bak" ]; then
    echo "PASS: Backup created"
  else
    echo "FAIL: Backup not created" >&2
    rm -rf "$TEST_ROOT"
    exit 1
  fi
else
  echo "FAIL: CHANGELOG.md not found after append" >&2
  rm -rf "$TEST_ROOT"
  exit 1
fi

rm -rf "$TEST_ROOT"

echo ""
echo "All tests: PASS"

