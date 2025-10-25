#!/usr/bin/env bash
set -euo pipefail

# Fix empty YAML front matter by adding minimal required fields

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1090
source "$SCRIPT_DIR/.lib.sh"

VERSION="0.1.0"

usage() {
  cat <<'USAGE'
Usage: erd-fix-empty-frontmatter.sh <erd-file> [--status STATUS] [--owner OWNER] [--dry-run] [-h|--help]

Fix empty YAML front matter by adding required fields.

Arguments:
  <erd-file>      Path to ERD markdown file

Options:
  --status STATUS Status value (default: active)
  --owner OWNER   Owner value (default: repo-maintainers)
  --dry-run       Show changes without modifying file
  -h, --help      Show this help and exit

Examples:
  # Fix with defaults
  erd-fix-empty-frontmatter.sh docs/projects/my-project/erd.md

  # Custom values
  erd-fix-empty-frontmatter.sh docs/projects/my-project/erd.md --status planning --owner team-name
USAGE
  
  print_exit_codes
}

# Parse arguments
file=""
status="active"
owner="repo-maintainers"
dry_run=false

while [ $# -gt 0 ]; do
  case "$1" in
    --version) printf '%s\n' "$VERSION"; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    --status) status="$2"; shift 2 ;;
    --owner) owner="$2"; shift 2 ;;
    --dry-run) dry_run=true; shift ;;
    -*) die "$EXIT_USAGE" "Unknown option: $1" ;;
    *) file="$1"; shift ;;
  esac
done

if [ -z "$file" ] || [ ! -f "$file" ]; then
  die "$EXIT_USAGE" "ERD file required"
fi

# Check if file has empty front matter (---\n---\n with no content between)
has_empty_fm=false
if head -5 "$file" | grep -q "^---$"; then
  # Has front matter markers, check if empty
  fm_content=$(awk '/^---$/,/^---$/{if(NR>1 && !/^---$/) print}' "$file" | head -n 10)
  if [ -z "$fm_content" ] || [[ "$fm_content" =~ ^[[:space:]]*$ ]]; then
    has_empty_fm=true
  fi
fi

if [ "$has_empty_fm" = false ]; then
  echo "File does not have empty front matter: $file"
  exit 0
fi

# Create temp file
temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT

# Get today's date
today=$(date +%Y-%m-%d)

# Replace empty front matter with populated one
awk -v status="$status" -v owner="$owner" -v today="$today" '
  BEGIN { in_empty_fm=0; sep_count=0 }
  /^---$/ {
    sep_count++
    if (sep_count == 1) {
      # Opening separator
      print "---"
      in_empty_fm=1
      next
    } else if (sep_count == 2 && in_empty_fm) {
      # Closing separator of empty front matter - inject content
      print "status: " status
      print "owner: " owner
      print "created: " today
      print "lastUpdated: " today
      print "---"
      in_empty_fm=0
      next
    }
  }
  in_empty_fm { next }  # Skip empty lines between separators
  { print }
' "$file" > "$temp_file"

if [ "$dry_run" = true ]; then
  echo "=== Dry-run: Would add to $file ==="
  echo ""
  head -10 "$temp_file"
else
  cp "$temp_file" "$file"
  echo "Fixed empty front matter: $file"
fi

exit 0

