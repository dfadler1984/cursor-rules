#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Fix broken links after archiving a project
# Updates all markdown references from old path to new archived path

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1090
source "$SCRIPT_DIR/.lib.sh"

VERSION="0.1.0"

usage() {
  cat <<'USAGE'
Usage: archive-fix-links.sh --old-path PATH --new-path PATH [OPTIONS]

Fix broken links after archiving a project.

Searches all .md files in docs/ and .cursor/rules/ for references to the
old project path and updates them to point to the archived location.

Required:
  --old-path PATH     Original path (e.g., docs/projects/my-proj)
  --new-path PATH     New archived path (e.g., docs/projects/_archived/2025/my-proj)

Options:
  --search-dir DIR    Root directory to search (default: repo root)
  --dry-run           Show changes without modifying files
  --version           Print version and exit
  -h, --help          Show this help and exit

Examples:
  # Fix links after archiving a project
  archive-fix-links.sh \
    --old-path docs/projects/my-feature \
    --new-path docs/projects/_archived/2025/my-feature

  # Preview changes
  archive-fix-links.sh \
    --old-path docs/projects/my-feature \
    --new-path docs/projects/_archived/2025/my-feature \
    --dry-run
USAGE
  
  print_exit_codes
}

# Defaults
OLD_PATH=""
NEW_PATH=""
SEARCH_DIR="$(repo_root)"
DRY_RUN=false

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --version) printf '%s\n' "$VERSION"; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    --old-path) OLD_PATH="$2"; shift 2 ;;
    --new-path) NEW_PATH="$2"; shift 2 ;;
    --search-dir) SEARCH_DIR="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    -*) die "$EXIT_USAGE" "Unknown option: $1" ;;
    *) die "$EXIT_USAGE" "Unexpected argument: $1" ;;
  esac
done

if [ -z "$OLD_PATH" ]; then
  die "$EXIT_USAGE" "--old-path required"
fi

if [ -z "$NEW_PATH" ]; then
  die "$EXIT_USAGE" "--new-path required"
fi

if [ ! -d "$SEARCH_DIR" ]; then
  die 1 "Search directory not found: $SEARCH_DIR"
fi

# Normalize paths (remove trailing slashes)
OLD_PATH="${OLD_PATH%/}"
NEW_PATH="${NEW_PATH%/}"

# Extract components from old and new paths
OLD_PROJECT_SLUG="${OLD_PATH##*/}"
# Extract year from new path (e.g., docs/projects/_archived/2025/slug → 2025)
YEAR=$(echo "$NEW_PATH" | grep -oE '_archived/[0-9]{4}' | grep -oE '[0-9]{4}' || date +%Y)

# Find all markdown files that might contain references
# Search in docs/ and .cursor/rules/ if they exist, otherwise search entire search dir
MD_FILES=()
search_paths=()
if [ -d "$SEARCH_DIR/docs" ]; then
  search_paths+=("$SEARCH_DIR/docs")
fi
if [ -d "$SEARCH_DIR/.cursor/rules" ]; then
  search_paths+=("$SEARCH_DIR/.cursor/rules")
fi
if [ ${#search_paths[@]} -eq 0 ]; then
  search_paths=("$SEARCH_DIR")
fi

while IFS= read -r -d '' file; do
  MD_FILES+=("$file")
done < <(find "${search_paths[@]}" -type f \( -name "*.md" -o -name "*.mdc" \) 2>/dev/null -print0 | sort -z || true)

if [ ${#MD_FILES[@]} -eq 0 ]; then
  log_info "No markdown files found in search directories"
  exit 0
fi

# Track modifications
files_modified=0
links_fixed=0

# Extract just the project slug from paths for pattern matching
# e.g., "docs/projects/my-proj" → "my-proj"
PROJECT_SLUG="${OLD_PATH##*/}"

# Process each file
for file in "${MD_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    continue
  fi
  
  # Check if file contains references to the project (any format)
  if ! grep -q "$OLD_PROJECT_SLUG" "$file" 2>/dev/null; then
    continue
  fi
  
  # Check for actual references to old path (absolute or relative)
  if ! grep -qE "(\./|docs/)projects/$OLD_PROJECT_SLUG" "$file" 2>/dev/null; then
    continue
  fi
  
  if [ "$DRY_RUN" = true ]; then
    # Dry-run: show what would change
    echo "Would fix links in: $file"
    grep -nE "(\./|docs/)projects/$OLD_PROJECT_SLUG" "$file" | head -3
    files_modified=$((files_modified + 1))
  else
    # Actually fix the links
    # Handle both relative (./projects/) and absolute (docs/projects/) paths
    sed -i.bak \
      -e "s|\./projects/$OLD_PROJECT_SLUG|./_archived/$YEAR/$OLD_PROJECT_SLUG|g" \
      -e "s|docs/projects/$OLD_PROJECT_SLUG|docs/projects/_archived/$YEAR/$OLD_PROJECT_SLUG|g" \
      "$file"
    rm -f "$file.bak"
    
    # Count how many links were fixed
    link_count=$(grep -c "_archived" "$file" 2>/dev/null || echo "0")
    links_fixed=$((links_fixed + link_count))
    files_modified=$((files_modified + 1))
    
    log_info "Fixed links in: $file"
  fi
done

# Summary
if [ "$DRY_RUN" = true ]; then
  echo ""
  echo "Would fix $files_modified file(s)"
else
  log_info "Fixed $links_fixed link(s) in $files_modified file(s)"
fi

exit 0

