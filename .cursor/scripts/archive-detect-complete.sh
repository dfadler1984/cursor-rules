#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Detect completed projects ready for archival
# Checks: all tasks complete, no pending carryovers, final-summary exists

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1090
source "$SCRIPT_DIR/.lib.sh"

VERSION="0.1.0"

usage() {
  cat <<'USAGE'
Usage: archive-detect-complete.sh [OPTIONS]

Detect projects ready for auto-archival.

A project is ready when ALL criteria are met:
  1. All tasks checked (no unchecked items in main sections)
  2. Carryovers resolved (no section OR section exists but is empty)
  3. Final summary exists (final-summary.md file present)

Options:
  --projects-dir DIR  Directory to scan (default: docs/projects)
  --version           Print version and exit
  -h, --help          Show this help and exit

Output:
  JSON array of completed projects with metadata

Examples:
  # Detect completed projects
  archive-detect-complete.sh

  # Custom projects directory
  archive-detect-complete.sh --projects-dir ./docs/projects

  # Parse output in GitHub Actions
  COMPLETED=$(archive-detect-complete.sh)
  if [ "$COMPLETED" != "[]" ]; then
    echo "Found completed projects"
  fi
USAGE
  
  print_exit_codes
}

# Defaults
ROOT_DIR="$(repo_root)"
PROJECTS_DIR="${ROOT_DIR}/docs/projects"

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --version) printf '%s\n' "$VERSION"; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    --projects-dir) PROJECTS_DIR="$2"; shift 2 ;;
    -*) die "$EXIT_USAGE" "Unknown option: $1" ;;
    *) die "$EXIT_USAGE" "Unexpected argument: $1" ;;
  esac
done

# Check if tasks file has unchecked items in main sections
# Returns 0 if all checked, 1 if any unchecked (excluding Carryovers section)
tasks_all_checked() {
  local tasks_file="$1"
  
  if [ ! -f "$tasks_file" ]; then
    return 1
  fi
  
  # Extract content before Carryovers section (if it exists)
  local main_tasks
  if grep -q "^## Carryovers" "$tasks_file"; then
    main_tasks=$(awk '/^## Carryovers/{exit} {print}' "$tasks_file")
  else
    main_tasks=$(cat "$tasks_file")
  fi
  
  # Check for unchecked items in main sections
  if echo "$main_tasks" | grep -q "^- \[ \]"; then
    return 1
  fi
  
  return 0
}

# Check if Carryovers section has unchecked items
# Returns 0 if resolved (no section OR section with no unchecked items), 1 otherwise
carryovers_resolved() {
  local tasks_file="$1"
  
  if [ ! -f "$tasks_file" ]; then
    return 0  # No tasks file = no carryovers
  fi
  
  # Check if Carryovers section exists
  if ! grep -q "^## Carryovers" "$tasks_file"; then
    return 0  # No Carryovers section = resolved
  fi
  
  # Extract Carryovers section (from ## Carryovers to EOF)
  local carryovers
  carryovers=$(sed -n '/^## Carryovers/,$p' "$tasks_file")
  
  # Check for unchecked items in Carryovers section
  if echo "$carryovers" | grep -q "^- \[ \]"; then
    return 1
  fi
  
  return 0
}

# Check if final-summary.md exists
final_summary_exists() {
  local project_dir="$1"
  
  if [ -f "$project_dir/final-summary.md" ]; then
    return 0
  fi
  
  return 1
}

# Extract project title from ERD
get_project_title() {
  local erd_file="$1"
  
  if [ ! -f "$erd_file" ]; then
    echo ""
    return
  fi
  
  # Try YAML title field first
  local title
  title=$(awk '/^---$/,/^---$/ {if(/^title:/) {sub(/^title:[[:space:]]*/, ""); print; exit}}' "$erd_file")
  
  if [ -n "$title" ]; then
    echo "$title"
    return
  fi
  
  # Fallback to first H1
  title=$(grep -m 1 "^# " "$erd_file" | sed 's/^# //')
  echo "$title"
}

# Main logic
if [ ! -d "$PROJECTS_DIR" ]; then
  die 1 "Projects directory not found: $PROJECTS_DIR"
fi

# Collect completed projects
completed_projects=()

for project_dir in "$PROJECTS_DIR"/*; do
  if [ ! -d "$project_dir" ]; then
    continue
  fi
  
  basename="${project_dir##*/}"
  
  # Skip special directories
  if [[ "$basename" == _* ]]; then
    continue
  fi
  
  tasks_file="$project_dir/tasks.md"
  erd_file="$project_dir/erd.md"
  
  # Check all three criteria
  if ! tasks_all_checked "$tasks_file"; then
    continue
  fi
  
  if ! carryovers_resolved "$tasks_file"; then
    continue
  fi
  
  if ! final_summary_exists "$project_dir"; then
    continue
  fi
  
  # All criteria met - add to results
  title=$(get_project_title "$erd_file")
  if [ -z "$title" ]; then
    title="$basename"
  fi
  
  # Build JSON object
  json_obj=$(cat <<EOF
{
  "slug": "$(json_escape "$basename")",
  "title": "$(json_escape "$title")",
  "tasksComplete": true,
  "carryoversResolved": true,
  "finalSummaryExists": true
}
EOF
)
  
  completed_projects+=("$json_obj")
done

# Output JSON array
printf '['
if [ ${#completed_projects[@]} -gt 0 ]; then
  first=true
  for project in "${completed_projects[@]}"; do
    if [ "$first" = true ]; then
      first=false
    else
      printf ','
    fi
    printf '\n%s' "$project"
  done
  printf '\n'
fi
printf ']\n'

exit 0

