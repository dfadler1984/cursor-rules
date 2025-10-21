#!/usr/bin/env bash
# validate-investigation-structure.sh
# Validate investigation project documentation structure

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=.lib.sh
source "$SCRIPT_DIR/.lib.sh"

VERSION="0.1.0"

usage() {
  print_help_header "validate-investigation-structure.sh" "$VERSION" "Validate investigation project structure per investigation-structure.mdc"
  print_usage "validate-investigation-structure.sh <project-path> [OPTIONS]"
  
  cat <<'DESC'

Arguments:
  <project-path>    Path to investigation project (e.g., docs/projects/rules-enforcement-investigation)

DESC
  
  print_options
  print_option "--warn-threshold N" "Warn if root has >N files" "7"
  print_option "--fail-threshold N" "Fail if root has >N files" "10"
  print_option "-h, --help" "Show this help and exit"
  
  print_examples
  print_example "Validate project structure" "validate-investigation-structure.sh docs/projects/my-investigation"
  print_example "Custom thresholds" "validate-investigation-structure.sh docs/projects/my-investigation --warn-threshold 5 --fail-threshold 8"
  
  print_exit_codes
  cat <<'CODES'
  0  Structure valid
  1  Structure violations detected (exceeds fail threshold)
  2  Usage error or project path invalid
CODES
  exit 0
}

# Defaults
WARN_THRESHOLD=7
FAIL_THRESHOLD=10

# Parse args
if [ $# -eq 0 ]; then
  echo "Error: project path required" >&2
  echo "Usage: validate-investigation-structure.sh <project-path>" >&2
  exit 2
fi

PROJECT_PATH=""

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      usage
      ;;
    --warn-threshold)
      WARN_THRESHOLD="${2:-}"
      shift 2
      ;;
    --fail-threshold)
      FAIL_THRESHOLD="${2:-}"
      shift 2
      ;;
    -*)
      die 2 "Unknown option: $1"
      ;;
    *)
      if [ -z "$PROJECT_PATH" ]; then
        PROJECT_PATH="$1"
        shift
      else
        die 2 "Multiple project paths provided: $PROJECT_PATH and $1"
      fi
      ;;
  esac
done

# Validate project path
if [ ! -d "$PROJECT_PATH" ]; then
  echo "Error: Project path does not exist: $PROJECT_PATH" >&2
  exit 2
fi

# Count root files
root_files=$(find "$PROJECT_PATH" -maxdepth 1 -type f -name "*.md" | wc -l | tr -d ' ')

# Check thresholds
violations=0

if [ "$root_files" -gt "$FAIL_THRESHOLD" ]; then
  echo "❌ FAIL: Root has $root_files files (threshold: $FAIL_THRESHOLD)"
  echo "   Per investigation-structure.mdc, root should have ≤7 files"
  echo "   Reorganize into folders: analysis/, findings/, sessions/, etc."
  violations=1
elif [ "$root_files" -gt "$WARN_THRESHOLD" ]; then
  echo "⚠️  WARNING: Root has $root_files files (threshold: $WARN_THRESHOLD)"
  echo "   Consider reorganizing into folders"
fi

# Check for expected folders if project is large
total_files=$(find "$PROJECT_PATH" -type f -name "*.md" | wc -l | tr -d ' ')

if [ "$total_files" -gt 15 ]; then
  # Large project should have organized structure
  expected_folders=("analysis" "findings" "sessions" "test-results")
  
  for folder in "${expected_folders[@]}"; do
    if [ ! -d "$PROJECT_PATH/$folder" ]; then
      # Check if there are files that should be in this folder
      case "$folder" in
        analysis)
          # Check for analysis-like files in root
          if find "$PROJECT_PATH" -maxdepth 1 -name "*-analysis.md" -o -name "*-investigation.md" -o -name "*-review.md" | grep -q .; then
            echo "⚠️  WARNING: Analysis files in root, but no analysis/ folder"
          fi
          ;;
        sessions)
          # Check for session summaries in root
          if find "$PROJECT_PATH" -maxdepth 1 -name "session-*.md" -o -name "20[0-9][0-9]-*.md" -o -name "*ACCOMPLISHMENTS*.md" | grep -q .; then
            echo "⚠️  WARNING: Session files in root, but no sessions/ folder"
          fi
          ;;
      esac
    fi
  done
fi

if [ $violations -eq 0 ]; then
  echo "✅ Structure valid: $root_files root files (threshold: $WARN_THRESHOLD warn, $FAIL_THRESHOLD fail)"
  exit 0
else
  echo ""
  echo "Run with --help for guidance on investigation structure"
  exit 1
fi

