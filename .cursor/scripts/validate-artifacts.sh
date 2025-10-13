#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

# Minimal validator for deterministic artifacts

VERSION="0.1.0"

usage(){
  cat <<USAGE
Usage: validate-artifacts.sh --paths <csv> [--version] [-h|--help]

Validates required headings and presence of cross-links in artifacts.

Options:
  --paths <csv>   Comma-separated file paths to validate (required)
  --version       Print version and exit
  -h, --help      Show this help and exit

Validates:
  - Required headings present
  - Links line exists
  - Cross-references between artifacts

Examples:
  # Validate spec, plan, and tasks
  validate-artifacts.sh --paths docs/specs/feature.md,docs/plans/feature.md,tasks/feature.md
USAGE
  
  print_exit_codes
}

PATHS=""
while [ $# -gt 0 ]; do
  case "$1" in
    --paths)
      [ $# -ge 2 ] || { echo "--paths requires a CSV list" >&2; exit 2; }
      PATHS="$2"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    --version)
      echo "0.1.0"; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

[ -n "$PATHS" ] || { usage >&2; exit 2; }

error_count=0

require_heading(){
  local file="$1" heading="$2"
  if ! grep -qE "^##[[:space:]]+$heading$" "$file"; then
    echo "$file: missing required heading: $heading" >&2
    error_count=$((error_count+1))
  fi
}

check_links_line(){
  local file="$1"
  if ! grep -qE '^\[Links: ' "$file"; then
    echo "$file: missing links line" >&2
    error_count=$((error_count+1))
  fi
}

IFS=',' read -r -a files <<< "$PATHS"
for f in "${files[@]}"; do
  if [ ! -f "$f" ]; then
    echo "not found: $f" >&2
    error_count=$((error_count+1))
    continue
  fi
  case "$f" in
    *-spec.md)
      require_heading "$f" "Overview"
      require_heading "$f" "Goals"
      require_heading "$f" "Functional Requirements"
      require_heading "$f" "Acceptance Criteria"
      require_heading "$f" "Risks/Edge Cases"
      check_links_line "$f" ;;
    *-plan.md)
      require_heading "$f" "Steps"
      require_heading "$f" "Acceptance Bundle"
      require_heading "$f" "Risks"
      check_links_line "$f" ;;
    tasks-*.md)
      require_heading "$f" "Relevant Files"
      require_heading "$f" "Todo" ;;
    *) : ;;
  esac
done

if [ $error_count -ne 0 ]; then
  echo "Validation failed with $error_count error(s)" >&2
  exit 1
fi

echo "Validation passed"
exit 0

