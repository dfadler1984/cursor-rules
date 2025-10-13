#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

usage() {
  cat <<'USAGE'
Usage: project-archive.sh --project <slug> [--year <YYYY>] [--root <path>] [--dry-run]

Moves docs/projects/<slug> to docs/projects/_archived/<YYYY>/<slug>.

Options:
  --project   Project slug under docs/projects (required)
  --year      Archive year (defaults to current year)
  --root      Repository root override (defaults to repo root inferred from script location)
  --dry-run   Print the planned move without changing files
  -h, --help  Show this help

Examples:
  # Archive project for current year (dry-run first)
  project-archive.sh --project my-project --dry-run
  project-archive.sh --project my-project
  
  # Archive for specific year
  project-archive.sh --project old-project --year 2024
  
  # Archive with custom root
  project-archive.sh --project test-project --root /path/to/repo
USAGE
  
  print_exit_codes
}

PROJECT=""
YEAR="$(date +%Y)"
ROOT="$ROOT_DIR"
DRY_RUN=0

while [ $# -gt 0 ]; do
  case "$1" in
    --project)
      PROJECT="${2-}"
      shift 2
      ;;
    --year)
      YEAR="${2-}"
      shift 2
      ;;
    --root)
      ROOT="${2-}"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift 1
      ;;
    -h|--help)
      usage; exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
done

if [ -z "$PROJECT" ]; then
  echo "--project is required" >&2
  usage
  exit 2
fi

SRC="$ROOT/docs/projects/$PROJECT"
DEST_PARENT="$ROOT/docs/projects/_archived/$YEAR"
DEST="$DEST_PARENT/$PROJECT"

if [ ! -d "$SRC" ]; then
  echo "Source project directory does not exist: $SRC" >&2
  exit 1
fi

if [ -e "$DEST" ]; then
  echo "Destination already exists: $DEST" >&2
  exit 1
fi

if [ $DRY_RUN -eq 1 ]; then
  echo "Would move $SRC -> $DEST"
  exit 0
fi

mkdir -p "$DEST_PARENT"
mv "$SRC" "$DEST"
echo "Project archived to $DEST"

exit 0


