#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Generate docs/projects/README.md by scanning project directories
# Excludes _archived/ and _examples/; extracts metadata from erd.md

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Defaults
PROJECTS_DIR="${PROJECTS_DIR:-$ROOT_DIR/docs/projects}"
OUT_FILE="${OUT_FILE:-$ROOT_DIR/docs/projects/README.md}"
DRY_RUN=false

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Generate docs/projects/README.md by scanning project directories.

OPTIONS:
  --projects-dir DIR   Directory to scan for projects (default: docs/projects)
  --out FILE          Output file (default: docs/projects/README.md)
  --dry-run           Print to stdout instead of writing file
  --help              Show this help message

EXAMPLES:
  $(basename "$0")
  $(basename "$0") --dry-run
  $(basename "$0") --projects-dir docs/projects --out docs/projects/README.md

EXIT CODES:
  0  Success
  1  General error
  2  Usage error (invalid arguments)

EOF
  exit 0
}

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --projects-dir)
      PROJECTS_DIR="$2"
      shift 2
      ;;
    --out)
      OUT_FILE="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Error: Unknown option: $1" >&2
      echo "Run with --help for usage information" >&2
      exit 2
      ;;
  esac
done

# Clean title by removing repetitive prefixes
clean_title() {
  local title="$1"
  
  # Strip common prefixes (in order of specificity)
  title="${title#(Archived) Engineering Requirements Document — }"
  title="${title#Engineering Requirements Document — }"
  title="${title#Engineering Requirements Document: }"
  title="${title#Engineering Requirements Document —}"
  title="${title#Rules Validation Script Enhancements — }"
  title="${title#ERD — }"
  
  echo "$title"
}

# Extract title from erd.md (from YAML front matter or first heading)
extract_title() {
  local erd_file="$1"
  if [ ! -f "$erd_file" ]; then
    return
  fi
  
  # First try YAML front matter title field
  local in_frontmatter=false
  local title=""
  
  while IFS= read -r line; do
    if [[ "$line" == "---" ]]; then
      if [ "$in_frontmatter" = false ]; then
        in_frontmatter=true
      else
        break
      fi
    elif [ "$in_frontmatter" = true ] && [[ "$line" =~ ^title:[[:space:]]* ]]; then
      title="${line#*:}"
      title="${title#"${title%%[![:space:]]*}"}" # trim leading whitespace
      title="${title%"${title##*[![:space:]]}"}" # trim trailing whitespace
      clean_title "$title"
      return
    fi
  done < "$erd_file"
  
  # Fallback to first H1 heading
  title="$(grep -m 1 '^# ' "$erd_file" | sed 's/^# //')"
  if [ -n "$title" ]; then
    clean_title "$title"
  fi
}

# Extract status from erd.md YAML front matter or markdown fields
extract_status() {
  local erd_file="$1"
  if [ ! -f "$erd_file" ]; then
    echo "unknown"
    return
  fi
  
  # First try: Look for status in YAML front matter (between --- markers)
  local in_frontmatter=false
  local status=""
  local found_frontmatter_content=false
  
  while IFS= read -r line; do
    if [[ "$line" == "---" ]]; then
      if [ "$in_frontmatter" = false ]; then
        in_frontmatter=true
      else
        # Closing --- found
        if [ "$found_frontmatter_content" = true ] && [ -n "$status" ]; then
          echo "$status" | tr '[:upper:]' '[:lower:]'
          return
        fi
        break
      fi
    elif [ "$in_frontmatter" = true ]; then
      # Mark that we found some content between the --- markers
      if [ -n "$line" ] && [[ ! "$line" =~ ^[[:space:]]*$ ]]; then
        found_frontmatter_content=true
      fi
      if [[ "$line" =~ ^status:[[:space:]]* ]]; then
        status="${line#*:}"
        status="${status#"${status%%[![:space:]]*}"}" # trim leading whitespace
        status="${status%"${status##*[![:space:]]}"}" # trim trailing whitespace
      fi
    fi
  done < "$erd_file"
  
  # Second try: Look for markdown field **Status**: VALUE
  status="$(grep -i '^\*\*Status\*\*:' "$erd_file" | head -n 1 | sed 's/^\*\*Status\*\*:[[:space:]]*//' | tr '[:upper:]' '[:lower:]')"
  if [ -n "$status" ]; then
    echo "$status"
    return
  fi
  
  # Third try: Check for archived: true (used in _archived/ projects)
  if grep -q "^archived: true" "$erd_file"; then
    echo "archived"
    return
  fi
  
  echo "unknown"
}

# Generate README content
generate_readme() {
  local projects_dir="$1"
  
  cat <<'EOF'
# Projects

This directory contains active and completed projects in this repository.

## Overview

Each project follows a standard structure:

- **ERD** (Engineering Requirements Document) - Defines scope, goals, and requirements
- **Tasks** - Tracks implementation progress with dependencies and priorities

Projects are automatically indexed by scanning project directories (excluding `_archived/` and `_examples/`).

EOF

  # Collect projects
  if [ ! -d "$projects_dir" ]; then
    echo "Warning: Projects directory not found: $projects_dir" >&2
    return
  fi
  
  # Arrays to hold project data by status (initialize as empty)
  active_projects=()
  pending_projects=()
  archived_projects=()
  
  # Scan for active/pending projects in main directory
  for dir in "$projects_dir"/*; do
    if [ ! -d "$dir" ]; then
      continue
    fi
    
    local basename="${dir##*/}"
    
    # Skip _examples but handle _archived separately
    if [[ "$basename" == "_examples" ]]; then
      continue
    fi
    
    # Skip _archived in main scan (will handle separately)
    if [[ "$basename" == "_archived" ]]; then
      continue
    fi
    
    # Skip README.md and other files
    if [ ! -d "$dir" ]; then
      continue
    fi
    
    local erd_file="$dir/erd.md"
    local tasks_file="$dir/tasks.md"
    
    # Extract title
    local title=""
    if [ -f "$erd_file" ]; then
      title="$(extract_title "$erd_file")"
    fi
    if [ -z "$title" ]; then
      title="$basename"
    fi
    
    # Extract status
    local status="$(extract_status "$erd_file")"
    
    # ERD link
    local erd_link="—"
    if [ -f "$erd_file" ]; then
      erd_link="[📄](./$basename/erd.md)"
    fi
    
    # Tasks indicator
    local tasks_link="—"
    if [ -f "$tasks_file" ]; then
      tasks_link="✅"
    fi
    
    # Create project data line (lowercase basename for sort key)
    local project_line="$(echo "$basename" | tr '[:upper:]' '[:lower:]')|$basename|$title|$status|$erd_link|$tasks_link"
    
    # Categorize by status
    case "$status" in
      active)
        active_projects+=("$project_line")
        ;;
      completed|archived)
        archived_projects+=("$project_line")
        ;;
      *)
        # planning, proposed, unknown, etc. go to pending
        pending_projects+=("$project_line")
        ;;
    esac
  done
  
  # Scan archived projects in _archived/ directory
  if [ -d "$projects_dir/_archived" ]; then
    # Scan year subdirectories (e.g., _archived/2025/)
    for year_dir in "$projects_dir/_archived"/*; do
      if [ ! -d "$year_dir" ]; then
        continue
      fi
      
      local year_basename="${year_dir##*/}"
      
      # Scan projects within year directory
      for archived_dir in "$year_dir"/*; do
        if [ ! -d "$archived_dir" ]; then
          continue
        fi
        
        local archived_basename="${archived_dir##*/}"
        
        # Skip non-project files
        if [[ "$archived_basename" == *.md ]]; then
          continue
        fi
        
        local erd_file="$archived_dir/erd.md"
        local tasks_file="$archived_dir/tasks.md"
        
        # Extract title
        local title=""
        if [ -f "$erd_file" ]; then
          title="$(extract_title "$erd_file")"
        fi
        if [ -z "$title" ]; then
          title="$archived_basename"
        fi
        
        # Extract status
        local status="$(extract_status "$erd_file")"
        
        # ERD link (relative to docs/projects/)
        local erd_link="—"
        if [ -f "$erd_file" ]; then
          erd_link="[📄](./_archived/$year_basename/$archived_basename/erd.md)"
        fi
        
        # Tasks indicator
        local tasks_link="—"
        if [ -f "$tasks_file" ]; then
          tasks_link="✅"
        fi
        
        # All archived projects go to archived section regardless of status
        local project_line="$(echo "$archived_basename" | tr '[:upper:]' '[:lower:]')|$archived_basename|$title|$status|$erd_link|$tasks_link"
        archived_projects+=("$project_line")
      done
    done
  fi
  
  # Output Active projects
  echo ""
  echo "## Active Projects"
  echo ""
  echo "| Project | Status | ERD | Tasks |"
  echo "| --- | --- | --- | --- |"
  if [ ${#active_projects[@]} -gt 0 ]; then
    printf '%s\n' "${active_projects[@]}" | sort | while IFS='|' read -r sortkey basename title status erd_link tasks_link; do
      echo "| $title | $status | $erd_link | $tasks_link |"
    done
  else
    echo "| *(No active projects)* | | | |"
  fi
  
  # Output Pending projects
  echo ""
  echo "## Pending Projects"
  echo ""
  echo "| Project | Status | ERD | Tasks |"
  echo "| --- | --- | --- | --- |"
  if [ ${#pending_projects[@]} -gt 0 ]; then
    printf '%s\n' "${pending_projects[@]}" | sort | while IFS='|' read -r sortkey basename title status erd_link tasks_link; do
      echo "| $title | $status | $erd_link | $tasks_link |"
    done
  else
    echo "| *(No pending projects)* | | | |"
  fi
  
  # Output Archived projects
  echo ""
  echo "## Archived Projects"
  echo ""
  echo "| Project | Status | ERD | Tasks |"
  echo "| --- | --- | --- | --- |"
  if [ ${#archived_projects[@]} -gt 0 ]; then
    printf '%s\n' "${archived_projects[@]}" | sort | while IFS='|' read -r sortkey basename title status erd_link tasks_link; do
      echo "| $title | $status | $erd_link | $tasks_link |"
    done
  else
    echo "| *(No archived projects)* | | | |"
  fi
  
  cat <<'EOF'

## Regenerating This File

This file is automatically generated. To update it:

```bash
./.cursor/scripts/generate-projects-readme.sh
```

Or use the npm script:

```bash
npm run generate:projects-readme
```

EOF
}

# Main
if [ "$DRY_RUN" = true ]; then
  generate_readme "$PROJECTS_DIR"
else
  generate_readme "$PROJECTS_DIR" > "$OUT_FILE"
  echo "Generated: $OUT_FILE" >&2
fi

