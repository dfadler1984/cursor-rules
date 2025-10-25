#!/usr/bin/env bash
set -euo pipefail

# Add Mode line to ERD files missing it

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1090
source "$SCRIPT_DIR/.lib.sh"

VERSION="0.1.0"

usage() {
  cat <<'USAGE'
Usage: erd-add-mode-line.sh <erd-file> [--mode lite|full] [--dry-run] [--version] [-h|--help]

Add Mode line to ERD files that are missing it.

Inserts "Mode: Lite" (or Full) after the first H1 heading.

Arguments:
  <erd-file>      Path to ERD markdown file

Options:
  --mode MODE     Specify "lite" or "full" (default: lite)
  --dry-run       Show changes without modifying file
  --version       Print version and exit
  -h, --help      Show this help and exit

Examples:
  # Add Mode: Lite
  erd-add-mode-line.sh docs/projects/my-project/erd.md

  # Add Mode: Full
  erd-add-mode-line.sh docs/projects/my-project/erd.md --mode full

  # Preview changes
  erd-add-mode-line.sh docs/projects/my-project/erd.md --dry-run
USAGE
  
  print_exit_codes
}

# Parse arguments
file=""
mode="Lite"
dry_run=false

while [ $# -gt 0 ]; do
  case "$1" in
    --version) printf '%s\n' "$VERSION"; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    --mode)
      case "${2,,}" in
        lite) mode="Lite" ;;
        full) mode="Full" ;;
        *) die "$EXIT_USAGE" "Mode must be 'lite' or 'full'" ;;
      esac
      shift 2
      ;;
    --dry-run) dry_run=true; shift ;;
    -*) die "$EXIT_USAGE" "Unknown option: $1" ;;
    *) file="$1"; shift ;;
  esac
done

if [ -z "$file" ] || [ ! -f "$file" ]; then
  die "$EXIT_USAGE" "ERD file required"
fi

# Check if Mode line already exists
if grep -qE '^Mode:[[:space:]]*(Lite|Full)' "$file"; then
  echo "File already has Mode line: $file"
  exit 0
fi

# Create temp file
temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT

# Process file: add Mode line after first H1
awk -v mode="$mode" '
  /^# / && !mode_added {
    print $0
    print ""
    print "Mode: " mode
    print ""
    mode_added=1
    next
  }
  { print }
' "$file" > "$temp_file"

if [ "$dry_run" = true ]; then
  echo "=== Dry-run: Would add to $file ==="
  echo ""
  echo "Mode: $mode"
  echo ""
  echo "After line:"
  grep -m 1 '^# ' "$file"
else
  cp "$temp_file" "$file"
  echo "Added Mode: $mode to $file"
fi

exit 0

