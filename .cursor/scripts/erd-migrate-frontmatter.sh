#!/usr/bin/env bash
set -euo pipefail

# Migrate ERD markdown fields to YAML front matter
# Converts **Field**: Value format to YAML front matter

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1090
source "$SCRIPT_DIR/.lib.sh"

VERSION="0.1.0"

usage() {
  cat <<'USAGE'
Usage: erd-migrate-frontmatter.sh <erd-file> [--dry-run] [--version] [-h|--help]

Migrate ERD markdown fields to YAML front matter format.

Converts:
  **Status**: ACTIVE
  **Owner**: team-name
  **Created**: 2025-10-23

To:
  ---
  status: active
  owner: team-name
  created: 2025-10-23
  lastUpdated: 2025-10-23
  ---

Arguments:
  <erd-file>      Path to ERD markdown file to migrate

Options:
  --dry-run       Show changes without modifying file
  --version       Print version and exit
  -h, --help      Show this help and exit

Examples:
  # Migrate a single ERD
  erd-migrate-frontmatter.sh docs/projects/my-feature/erd.md

  # Dry-run to preview changes
  erd-migrate-frontmatter.sh docs/projects/my-feature/erd.md --dry-run

  # Migrate all non-compliant ERDs
  for f in docs/projects/*/erd.md; do
    bash .cursor/scripts/erd-validate.sh "$f" 2>&1 | grep -q "front matter: status" && \
      erd-migrate-frontmatter.sh "$f"
  done
USAGE
  
  print_exit_codes
}

# Parse arguments
file=""
dry_run=false
while [ $# -gt 0 ]; do
  case "$1" in
    --version) printf '%s\n' "$VERSION"; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    --dry-run) dry_run=true; shift ;;
    -*) die "$EXIT_USAGE" "Unknown option: $1" ;;
    *) file="$1"; shift ;;
  esac
done

if [ -z "$file" ] || [ ! -f "$file" ]; then
  die "$EXIT_USAGE" "ERD file required"
fi

# Extract markdown fields
status=$(grep -i '^\*\*Status\*\*:' "$file" | head -n 1 | sed 's/^\*\*Status\*\*:[[:space:]]*//' | tr '[:upper:]' '[:lower:]' || true)
owner=$(grep -i '^\*\*Owner\*\*:' "$file" | head -n 1 | sed 's/^\*\*Owner\*\*:[[:space:]]*//' || true)
created=$(grep -i '^\*\*Created\*\*:' "$file" | head -n 1 | sed 's/^\*\*Created\*\*:[[:space:]]*//' || true)
project=$(grep -i '^\*\*Project\*\*:' "$file" | head -n 1 | sed 's/^\*\*Project\*\*:[[:space:]]*//' || true)

# If no markdown fields found, check if already has front matter
if [ -z "$status" ] && head -n 1 "$file" | grep -q '^---'; then
  echo "File already has YAML front matter: $file"
  exit 0
fi

if [ -z "$status" ]; then
  die 1 "No markdown Status field found in $file"
fi

# Default lastUpdated to today
last_updated=$(date +%Y-%m-%d)

# Create temporary file
temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT

# Build front matter
{
  echo "---"
  echo "status: $status"
  [ -n "$owner" ] && echo "owner: $owner"
  [ -n "$created" ] && echo "created: $created"
  echo "lastUpdated: $last_updated"
  echo "---"
  echo ""
} > "$temp_file"

# Remove markdown fields and add content
grep -ivE '^\*\*(Status|Owner|Created|Project)\*\*:' "$file" | \
  sed '/^---$/d' | \
  sed '/^$/{ N; /^\n$/d; }' >> "$temp_file"

if [ "$dry_run" = true ]; then
  echo "=== Dry-run: Changes for $file ==="
  echo ""
  echo "Front matter to be added:"
  head -n 6 "$temp_file"
  echo ""
  echo "Lines to be removed:"
  grep -iE '^\*\*(Status|Owner|Created|Project)\*\*:' "$file" || echo "(none)"
else
  cp "$temp_file" "$file"
  echo "Migrated: $file"
fi

exit 0

