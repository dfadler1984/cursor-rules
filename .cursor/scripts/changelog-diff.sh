#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

usage() {
  cat <<'USAGE'
Usage: changelog-diff.sh --project <slug> --from <phase> --to <phase> [--format text|markdown]

Show differences between two changelog phases.

Options:
  --project <slug>    Project slug under docs/projects (required)
  --from <phase>      Starting phase number or name (required)
  --to <phase>        Ending phase number or name (required)
  --format <fmt>      Output format: text (default) or markdown
  --root <path>       Repository root (default: auto-detected)
  -h, --help          Show this help

Examples:
  # Compare Phase 1 to Phase 3
  changelog-diff.sh --project my-project --from 1 --to 3

  # Compare by phase names
  changelog-diff.sh --project my-project --from "Setup" --to "Implementation"

  # Markdown output
  changelog-diff.sh --project my-project --from 1 --to 3 --format markdown
USAGE

  print_exit_codes
}

PROJECT=""
FROM=""
TO=""
FORMAT="text"
ROOT="$ROOT_DIR"

while [ $# -gt 0 ]; do
  case "$1" in
    --project) PROJECT="${2-}"; shift 2 ;;
    --from) FROM="${2-}"; shift 2 ;;
    --to) TO="${2-}"; shift 2 ;;
    --format) FORMAT="${2-}"; shift 2 ;;
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

if [ -z "$FROM" ] || [ -z "$TO" ]; then
  echo "--from and --to are required" >&2
  usage
  exit 2
fi

# Validate format
if [ "$FORMAT" != "text" ] && [ "$FORMAT" != "markdown" ]; then
  echo "Error: --format must be 'text' or 'markdown', got: $FORMAT" >&2
  exit 1
fi

PROJECT_DIR="$ROOT/docs/projects/$PROJECT"
CHANGELOG="$PROJECT_DIR/CHANGELOG.md"

# Validate project and changelog exist
if [ ! -d "$PROJECT_DIR" ]; then
  echo "Error: project directory not found: $PROJECT_DIR" >&2
  exit 1
fi

if [ ! -f "$CHANGELOG" ]; then
  echo "Error: CHANGELOG.md not found at: $CHANGELOG" >&2
  exit 1
fi

echo "Changelog diff: Phase $FROM → Phase $TO"
echo "Project: $PROJECT"
echo "Format: $FORMAT"
echo ""
echo "[Task 16.0: Implementation pending]"
echo ""
echo "Would extract and compare:"
echo "  - Entries from Phase $FROM"
echo "  - Entries from Phase $TO"
echo "  - Show additions, changes, decisions made between phases"

exit 0

