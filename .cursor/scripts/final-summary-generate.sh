#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"

usage() {
  cat <<'USAGE'
Usage: final-summary-generate.sh --project <slug> --year <YYYY> [--root <path>] [--date <YYYY-MM-DD>] [--force] [--pre-move]

Creates or updates the project final-summary.md by filling the template with project name, links,
and date.

By default, writes to docs/projects/_archived/<YYYY>/<slug>/final-summary.md.
With --pre-move, writes to docs/projects/<slug>/final-summary.md while still pointing links to the
archived path (docs/projects/_archived/<YYYY>/<slug>/...).

Options:
  --project   Project slug under docs/projects/_archived/<year> (required)
  --year      Archive year directory (required)
  --root      Repository root override (defaults to repo root inferred from script location)
  --date      Date for last-updated (defaults to today, YYYY-MM-DD)
  --force     Overwrite existing final-summary.md if present
  --pre-move  Write summary into source directory (pre-archive); links still target archived path
  -h, --help  Show this help
USAGE
}

PROJECT=""
YEAR=""
ROOT="$ROOT_DIR"
DATE="$(date +%Y-%m-%d)"
FORCE=0
PRE_MOVE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --project) PROJECT="${2-}"; shift 2 ;;
    --year) YEAR="${2-}"; shift 2 ;;
    --root) ROOT="${2-}"; shift 2 ;;
    --date) DATE="${2-}"; shift 2 ;;
    --force) FORCE=1; shift 1 ;;
    --pre-move) PRE_MOVE=1; shift 1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 2 ;;
  esac
done

if [ -z "$PROJECT" ] || [ -z "$YEAR" ]; then
  echo "--project and --year are required" >&2
  usage
  exit 2
fi

ARCHIVED_DIR="$ROOT/docs/projects/_archived/$YEAR/$PROJECT"
SRC_DIR="$ROOT/docs/projects/$PROJECT"
TEMPLATE="$ROOT/.cursor/templates/project-lifecycle/final-summary.template.md"

if [ $PRE_MOVE -eq 1 ]; then
  if [ ! -d "$SRC_DIR" ]; then
    echo "Source project directory does not exist: $SRC_DIR" >&2
    exit 1
  fi
  FSUM="$SRC_DIR/final-summary.md"
else
  if [ ! -d "$ARCHIVED_DIR" ]; then
    echo "Archived project directory does not exist: $ARCHIVED_DIR" >&2
    exit 1
  fi
  FSUM="$ARCHIVED_DIR/final-summary.md"
fi

if [ ! -f "$TEMPLATE" ]; then
  echo "Template not found: $TEMPLATE" >&2
  exit 1
fi

if [ -f "$FSUM" ] && [ $FORCE -ne 1 ]; then
  echo "final-summary.md already exists; use --force to overwrite: $FSUM" >&2
  exit 1
fi

# Title-cased name for display (best-effort): replace dashes with spaces and capitalize words
display_name=$(echo "$PROJECT" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2) }}1')

# Build links (relative to destination file location)
if [ $PRE_MOVE -eq 1 ]; then
  # Writing into docs/projects/<project>/final-summary.md while targeting archived paths
  erd_link="../_archived/$YEAR/$PROJECT/erd.md"
  tasks_link="../_archived/$YEAR/$PROJECT/tasks.md"
  erd_source="$SRC_DIR/erd.md"
else
  # Writing into docs/projects/_archived/<year>/<project>/final-summary.md
  erd_link="./erd.md"
  tasks_link="./tasks.md"
  erd_source="$ARCHIVED_DIR/erd.md"
fi

# Generate content by transforming the template and filling minimal, guaranteed substitutions
content=$(cat "$TEMPLATE" \
  | sed "s#<project>#$PROJECT#g" \
  | sed "s/^# Final Summary — .*/# Final Summary — $display_name/" \
  | sed "s/^last-updated: .*/last-updated: $DATE/" \
  | sed "s#ERD: .*#ERD: \`$erd_link\`#" \
  | sed "s#Tasks: .*#Tasks: \`$tasks_link\`#")

printf "%s\n" "$content" > "$FSUM"
echo "Final summary generated at $FSUM"

exit 0

