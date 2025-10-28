#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

usage() {
  cat <<'USAGE'
Usage: changelog-update.sh --project <slug> [--mode auto|interactive|dry-run] [--since <date>]

Automatically detect and generate changelog entries from project changes.

Detects:
  - Phase completions from tasks.md
  - Completed parent tasks (1.0, 2.0, etc.)
  - Decision markers (D1:, Decision:, etc.)
  - Scope changes (Migrated, Superseded, Deferred, Carryovers)
  - Conventional commits since last entry
  - ERD status changes

Options:
  --project <slug>    Project slug under docs/projects (required)
  --mode <mode>       Mode: auto (append), interactive (review), dry-run (show only)
                      Default: interactive
  --since <date>      Detect changes since this date (YYYY-MM-DD)
                      Default: date of last changelog entry or project creation
  --root <path>       Repository root (default: auto-detected)
  -h, --help          Show this help

Examples:
  # Interactive mode (default): review before appending
  changelog-update.sh --project my-project

  # Dry-run: show what would be generated
  changelog-update.sh --project my-project --mode dry-run

  # Auto mode: append without prompts
  changelog-update.sh --project my-project --mode auto

  # Specify date range
  changelog-update.sh --project my-project --since 2025-10-20
USAGE

  print_exit_codes
}

PROJECT=""
MODE="interactive"
SINCE=""
ROOT="$ROOT_DIR"

while [ $# -gt 0 ]; do
  case "$1" in
    --project) PROJECT="${2-}"; shift 2 ;;
    --mode) MODE="${2-}"; shift 2 ;;
    --since) SINCE="${2-}"; shift 2 ;;
    --root) ROOT="${2-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 2 ;;
  esac
done

if [ -z "$PROJECT" ]; then
  echo "--project is required" >&2
  usage
  exit 2
fi

# Validate mode
if [ "$MODE" != "auto" ] && [ "$MODE" != "interactive" ] && [ "$MODE" != "dry-run" ]; then
  echo "Error: --mode must be 'auto', 'interactive', or 'dry-run', got: $MODE" >&2
  exit 1
fi

PROJECT_DIR="$ROOT/docs/projects/$PROJECT"
CHANGELOG="$PROJECT_DIR/CHANGELOG.md"
TASKS="$PROJECT_DIR/tasks.md"
ERD="$PROJECT_DIR/erd.md"

# Validate project exists
if [ ! -d "$PROJECT_DIR" ]; then
  echo "Error: project directory not found: $PROJECT_DIR" >&2
  exit 1
fi

# Check for changelog
if [ ! -f "$CHANGELOG" ]; then
  echo "Error: CHANGELOG.md not found at: $CHANGELOG" >&2
  echo "Create one first using project-create.sh --with-changelog or manually" >&2
  exit 1
fi

# Parse tasks.md for patterns
parse_tasks_md() {
  local tasks_file="$1"
  local output=""
  
  if [ ! -f "$tasks_file" ]; then
    return 0
  fi
  
  # Detect completed phases (matches both "(COMPLETE)" and "✅ COMPLETE")
  local phases
  phases=$(grep -E "^## Phase [0-9]+:.*COMPLETE" "$tasks_file" | sed 's/^## //' | sed -E 's/\s*\([^)]*\).*//' | sed 's/\s*$//' || true)
  
  # Detect completed parent tasks (X.0 format)
  local completed_tasks
  completed_tasks=$(grep -E "^- \[x\] [0-9]+\.0 " "$tasks_file" | sed 's/^- \[x\] //' || true)
  
  # Detect decision markers (D1:, D2:, etc.)
  local decisions
  decisions=$(grep -E "D[0-9]+:" "$tasks_file" | sed 's/^- //' || true)
  
  # Detect scope changes (Migrated, Superseded, Deferred)
  local scope_changes
  scope_changes=$(grep -iE "(Migrated|Superseded|Deferred)" "$tasks_file" || true)
  
  # Output results
  if [ -n "$phases" ]; then
    echo "COMPLETED_PHASES:"
    echo "$phases"
    echo ""
  fi
  
  if [ -n "$completed_tasks" ]; then
    echo "COMPLETED_TASKS:"
    echo "$completed_tasks"
    echo ""
  fi
  
  if [ -n "$decisions" ]; then
    echo "DECISIONS:"
    echo "$decisions"
    echo ""
  fi
  
  if [ -n "$scope_changes" ]; then
    echo "SCOPE_CHANGES:"
    echo "$scope_changes"
    echo ""
  fi
}

# Detect changes and generate output
echo "Detecting changes for project: $PROJECT"
echo "Mode: $MODE"
echo "Since: ${SINCE:-<auto-detect>}"
echo ""

# Collect all detected data
DETECTED_PHASES=""
DETECTED_TASKS=""
DETECTED_DECISIONS=""
DETECTED_SCOPE_CHANGES=""
DETECTED_COMMITS=""

# Parse tasks.md and capture output
if [ -f "$TASKS" ]; then
  TASK_OUTPUT=$(parse_tasks_md "$TASKS")
  
  # Extract different sections from output
  DETECTED_PHASES=$(echo "$TASK_OUTPUT" | sed -n '/^COMPLETED_PHASES:/,/^$/p' | grep -v "^COMPLETED_PHASES:" | grep -v "^$" || true)
  DETECTED_TASKS=$(echo "$TASK_OUTPUT" | sed -n '/^COMPLETED_TASKS:/,/^$/p' | grep -v "^COMPLETED_TASKS:" | grep -v "^$" || true)
  DETECTED_DECISIONS=$(echo "$TASK_OUTPUT" | sed -n '/^DECISIONS:/,/^$/p' | grep -v "^DECISIONS:" | grep -v "^$" || true)
  DETECTED_SCOPE_CHANGES=$(echo "$TASK_OUTPUT" | sed -n '/^SCOPE_CHANGES:/,/^$/p' | grep -v "^SCOPE_CHANGES:" | grep -v "^$" || true)
else
  echo "Warning: tasks.md not found at: $TASKS" >&2
fi

# Parse git log for conventional commits
parse_git_log() {
  local since_date="$1"
  local project_dir="$2"
  
  # If no since date, skip git log parsing for now
  if [ -z "$since_date" ]; then
    return 0
  fi
  
  # Get commits for project files since date
  local commits
  commits=$(cd "$ROOT" && git log --since="$since_date" --pretty=format:"%s" -- "docs/projects/$(basename "$project_dir")/**" 2>/dev/null || true)
  
  if [ -n "$commits" ]; then
    echo "GIT_COMMITS:"
    echo "$commits"
    echo ""
  fi
}

# Parse git log if we have a since date
if [ -n "$SINCE" ]; then
  echo "=== Detected from git log ===" 
  parse_git_log "$SINCE" "$PROJECT_DIR"
fi

# Categorize task by description keywords
categorize_task() {
  local task_desc="$1"
  
  # Added keywords
  if echo "$task_desc" | grep -iE "(Create|Add|Implement|Build|Generate|Initialize|Introduce)" >/dev/null; then
    echo "added"
    return
  fi
  
  # Changed keywords
  if echo "$task_desc" | grep -iE "(Update|Modify|Refactor|Convert|Migrate|Reorganize|Enhance)" >/dev/null; then
    echo "changed"
    return
  fi
  
  # Fixed keywords
  if echo "$task_desc" | grep -iE "(Fix|Correct|Resolve|Repair)" >/dev/null; then
    echo "fixed"
    return
  fi
  
  # Removed keywords
  if echo "$task_desc" | grep -iE "(Remove|Delete|Deprecate|Archive)" >/dev/null; then
    echo "removed"
    return
  fi
  
  # Default to Added for ambiguous cases
  echo "added"
}

# Format detected changes into changelog entries
generate_changelog_entries() {
  local phases_data="$1"
  local tasks_data="$2"
  local decisions_data="$3"
  local scope_data="$4"
  
  local phase_name="Phase X"
  local entry_date
  entry_date=$(date +%Y-%m-%d)
  
  # Use first completed phase as entry name if available
  if [ -n "$phases_data" ]; then
    phase_name=$(echo "$phases_data" | head -1)
  fi
  
  echo "## [$phase_name] - $entry_date"
  echo ""
  echo "### Summary"
  echo ""
  echo "TODO: Add phase summary"
  echo ""
  
  # Categorize and format completed tasks
  local added_items=""
  local changed_items=""
  local fixed_items=""
  local removed_items=""
  
  while IFS= read -r task; do
    [ -z "$task" ] && continue
    category=$(categorize_task "$task")
    case "$category" in
      added) added_items="${added_items}- ${task}\n" ;;
      changed) changed_items="${changed_items}- ${task}\n" ;;
      fixed) fixed_items="${fixed_items}- ${task}\n" ;;
      removed) removed_items="${removed_items}- ${task}\n" ;;
    esac
  done <<< "$tasks_data"
  
  # Output Added section
  if [ -n "$added_items" ]; then
    echo "### Added"
    echo ""
    echo -e "$added_items"
  fi
  
  # Output Changed section
  if [ -n "$changed_items" ]; then
    echo "### Changed"
    echo ""
    echo -e "$changed_items"
  fi
  
  # Output Fixed section
  if [ -n "$fixed_items" ]; then
    echo "### Fixed"
    echo ""
    echo -e "$fixed_items"
  fi
  
  # Output Removed section
  if [ -n "$removed_items" ]; then
    echo "### Removed"
    echo ""
    echo -e "$removed_items"
  fi
  
  # Output Decisions section
  if [ -n "$decisions_data" ]; then
    echo "### Decisions"
    echo ""
    while IFS= read -r decision; do
      [ -z "$decision" ] && continue
      echo "- $decision"
    done <<< "$decisions_data"
    echo ""
  fi
}

if [ "$MODE" = "dry-run" ]; then
  echo "=== Generated Changelog Entry (Preview) ==="
  echo ""
  generate_changelog_entries "$DETECTED_PHASES" "$DETECTED_TASKS" "$DETECTED_DECISIONS" "$DETECTED_SCOPE_CHANGES"
  echo ""
  echo "[Dry-run mode: no files modified]"
elif [ "$MODE" = "interactive" ]; then
  echo ""
  echo "=== Generated Changelog Entry ==="
  echo ""
  ENTRY=$(generate_changelog_entries "$DETECTED_PHASES" "$DETECTED_TASKS" "$DETECTED_DECISIONS" "$DETECTED_SCOPE_CHANGES")
  echo "$ENTRY"
  echo ""
  echo "Append this entry to CHANGELOG.md? (y/N)"
  read -r response
  case "$response" in
    [yY][eE][sS]|[yY])
      # Find the line number of [Unreleased] section
      UNRELEASED_LINE=$(grep -n "^## \[Unreleased\]" "$CHANGELOG" | cut -d: -f1 | head -1)
      
      if [ -z "$UNRELEASED_LINE" ]; then
        echo "Error: Could not find [Unreleased] section in $CHANGELOG" >&2
        exit 1
      fi
      
      # Calculate insert position (after the Unreleased section and its content)
      # Find the next ## heading after Unreleased
      NEXT_SECTION_LINE=$(tail -n +"$((UNRELEASED_LINE + 1))" "$CHANGELOG" | grep -n "^## \[" | head -1 | cut -d: -f1)
      
      if [ -n "$NEXT_SECTION_LINE" ]; then
        INSERT_LINE=$((UNRELEASED_LINE + NEXT_SECTION_LINE))
      else
        # No next section, append at end
        INSERT_LINE=$(($(wc -l < "$CHANGELOG") + 1))
      fi
      
      # Create backup
      cp "$CHANGELOG" "$CHANGELOG.bak"
      
      # Insert entry
      {
        head -n "$((INSERT_LINE - 1))" "$CHANGELOG"
        echo ""
        echo "---"
        echo ""
        echo "$ENTRY"
        tail -n +"$INSERT_LINE" "$CHANGELOG"
      } > "$CHANGELOG.tmp"
      
      mv "$CHANGELOG.tmp" "$CHANGELOG"
      echo "✓ Entry appended to $CHANGELOG"
      echo "  Backup saved to $CHANGELOG.bak"
      ;;
    *)
      echo "Cancelled"
      ;;
  esac
elif [ "$MODE" = "auto" ]; then
  echo "Auto mode: appending to $CHANGELOG"
  ENTRY=$(generate_changelog_entries "$DETECTED_PHASES" "$DETECTED_TASKS" "$DETECTED_DECISIONS" "$DETECTED_SCOPE_CHANGES")
  
  # Same insertion logic as interactive
  UNRELEASED_LINE=$(grep -n "^## \[Unreleased\]" "$CHANGELOG" | cut -d: -f1 | head -1)
  
  if [ -z "$UNRELEASED_LINE" ]; then
    echo "Error: Could not find [Unreleased] section in $CHANGELOG" >&2
    exit 1
  fi
  
  NEXT_SECTION_LINE=$(tail -n +"$((UNRELEASED_LINE + 1))" "$CHANGELOG" | grep -n "^## \[" | head -1 | cut -d: -f1)
  
  if [ -n "$NEXT_SECTION_LINE" ]; then
    INSERT_LINE=$((UNRELEASED_LINE + NEXT_SECTION_LINE))
  else
    INSERT_LINE=$(($(wc -l < "$CHANGELOG") + 1))
  fi
  
  # Create backup
  cp "$CHANGELOG" "$CHANGELOG.bak"
  
  # Insert entry
  {
    head -n "$((INSERT_LINE - 1))" "$CHANGELOG"
    echo ""
    echo "---"
    echo ""
    echo "$ENTRY"
    tail -n +"$INSERT_LINE" "$CHANGELOG"
  } > "$CHANGELOG.tmp"
  
  mv "$CHANGELOG.tmp" "$CHANGELOG"
  echo "✓ Entry appended to $CHANGELOG"
  echo "  Backup saved to $CHANGELOG.bak"
fi

exit 0

