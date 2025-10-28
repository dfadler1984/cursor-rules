#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

usage() {
  cat <<'USAGE'
Usage: changelog-backfill.sh --project <slug> --year <YYYY> [--mode auto|interactive|dry-run]

Generate changelogs for archived projects.

Wrapper for changelog-update.sh that handles archived project paths.

Options:
  --project <slug>    Project slug under docs/projects/_archived/<YYYY>/ (required)
  --year <YYYY>       Archive year (required)
  --mode <mode>       Mode: auto, interactive, dry-run (default: dry-run)
  --root <path>       Repository root (default: auto-detected)
  -h, --help          Show this help

Examples:
  # Preview changelog for archived project
  changelog-backfill.sh --project shell-and-script-tooling --year 2025

  # Generate and review interactively
  changelog-backfill.sh --project shell-and-script-tooling --year 2025 --mode interactive

  # Auto-generate
  changelog-backfill.sh --project shell-and-script-tooling --year 2025 --mode auto
USAGE

  print_exit_codes
}

PROJECT=""
YEAR=""
MODE="dry-run"
ROOT="$ROOT_DIR"

while [ $# -gt 0 ]; do
  case "$1" in
    --project) PROJECT="${2-}"; shift 2 ;;
    --year) YEAR="${2-}"; shift 2 ;;
    --mode) MODE="${2-}"; shift 2 ;;
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

if [ -z "$YEAR" ]; then
  echo "--year is required for archived projects" >&2
  usage
  exit 2
fi

# Validate mode
if [ "$MODE" != "auto" ] && [ "$MODE" != "interactive" ] && [ "$MODE" != "dry-run" ]; then
  echo "Error: --mode must be 'auto', 'interactive', or 'dry-run', got: $MODE" >&2
  exit 1
fi

ARCHIVED_DIR="$ROOT/docs/projects/_archived/$YEAR/$PROJECT"
TASKS="$ARCHIVED_DIR/tasks.md"
CHANGELOG="$ARCHIVED_DIR/CHANGELOG.md"

# Validate archived project exists
if [ ! -d "$ARCHIVED_DIR" ]; then
  echo "Error: archived project not found: $ARCHIVED_DIR" >&2
  exit 1
fi

if [ ! -f "$TASKS" ]; then
  echo "Error: tasks.md not found at: $TASKS" >&2
  exit 1
fi

# Check if changelog already exists
if [ -f "$CHANGELOG" ]; then
  echo "Note: CHANGELOG.md already exists at: $CHANGELOG"
  echo "This script will detect changes not yet documented."
  echo ""
fi

# Create CHANGELOG.md from template if it doesn't exist
if [ ! -f "$CHANGELOG" ]; then
  TEMPLATE="$ROOT/.cursor/templates/project-lifecycle/CHANGELOG.template.md"
  
  if [ -f "$TEMPLATE" ]; then
    # Generate display name
    DISPLAY_NAME=$(echo "$PROJECT" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) tolower(substr($i,2)) }}1')
    
    # Get creation date from ERD if available
    CREATED_DATE="$YEAR-01-01"
    ERD="$ARCHIVED_DIR/erd.md"
    if [ -f "$ERD" ]; then
      CREATED_FROM_ERD=$(grep "^created:" "$ERD" | head -1 | cut -d: -f2 | tr -d ' ' || true)
      if [ -n "$CREATED_FROM_ERD" ]; then
        CREATED_DATE="$CREATED_FROM_ERD"
      fi
    fi
    
    sed -e "s/{{PROJECT_TITLE}}/$DISPLAY_NAME/g" \
        -e "s/YYYY-MM-DD/$CREATED_DATE/g" \
        "$TEMPLATE" > "$CHANGELOG"
    
    if [ "$MODE" = "dry-run" ]; then
      echo "Created CHANGELOG.md from template (for preview)"
      echo "  Note: Will show generated entries, file will remain after dry-run"
      echo ""
    else
      echo "Created CHANGELOG.md from template"
    fi
  else
    echo "Warning: template not found, skipping CHANGELOG creation" >&2
  fi
fi

# Temporarily symlink archived project into active location for changelog-update.sh
TEMP_LINK="$ROOT/docs/projects/__backfill-temp-$$"
ln -s "$ARCHIVED_DIR" "$TEMP_LINK"

# Run changelog-update.sh
bash "$SCRIPT_DIR/changelog-update.sh" --project "$(basename "$TEMP_LINK")" --mode "$MODE" --root "$ROOT"
RESULT=$?

# Clean up symlink
rm "$TEMP_LINK"

exit $RESULT

