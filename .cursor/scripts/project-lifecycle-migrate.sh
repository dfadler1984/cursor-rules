#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

usage() {
  cat <<'USAGE'
Usage: project-lifecycle-migrate.sh --project <slug> [--root <projectsRoot>]

Backfills lifecycle artifacts for a project:
 - Ensures final-summary.md has required front matter and sections
 - Adds a Retrospective file if missing (when not present in final summary)
 - Leaves existing content intact; only adds missing structure

Options:
  --project <slug>  Project slug (required)
  --root <path>     Projects root directory (default: docs/projects)
  -h, --help        Show this help and exit

Examples:
  # Backfill artifacts for a project
  project-lifecycle-migrate.sh --project rules-validate-script
  
  # Backfill with custom projects root
  project-lifecycle-migrate.sh --project my-proj --root /tmp/docs/projects
USAGE
  
  print_exit_codes
}

project=""
root_dir=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) project="$2"; shift 2 ;;
    --root) root_dir="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
done

[[ -n "$project" ]] || { echo "--project is required" >&2; exit 2; }

repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
projects_root="${root_dir:-$repo_root/docs/projects}"
proj_dir="$projects_root/$project"

[[ -d "$proj_dir" ]] || { echo "Project directory not found: $proj_dir" >&2; exit 2; }

final="$proj_dir/final-summary.md"
retro="$proj_dir/retrospective.md"
tasks="$proj_dir/tasks.md"

# Ensure final-summary.md exists
if [[ ! -f "$final" ]]; then
  .cursor/scripts/template-fill.sh --template final-summary --project "$project" --out "$final" --vars projectName="$project"
else
  # Ensure front matter fields
  if ! grep -q '^---$' "$final"; then
    tmp="$(mktemp)"
    {
      printf '%s\n' '---'
      printf '%s\n' 'template: project-lifecycle/final-summary'
      printf '%s\n' 'version: 1.0.0'
      printf '%s\n' "last-updated: $(date -u +%Y-%m-%d)"
      printf '%s\n' '---'
      cat "$final"
    } >"$tmp"
    mv "$tmp" "$final"
  else
    if ! grep -q '^template:\s*project-lifecycle/final-summary' "$final"; then
      sed -i.bak '1,10{/^template:/s/.*/template: project-lifecycle\/final-summary/;}' "$final" || true
      rm -f "$final.bak" || true
    fi
    if ! grep -q '^version:\s*[0-9]\+\.[0-9]\+\.[0-9]\+' "$final"; then
      awk 'BEGIN{p=1} {print} END{if(p)print "version: 1.0.0"}' "$final" >"$final.tmp" && mv "$final.tmp" "$final"
    fi
    if ! grep -q '^last-updated:' "$final"; then
      awk -v d="$(date -u +%Y-%m-%d)" 'BEGIN{p=1} {print} END{if(p)print "last-updated: " d}' "$final" >"$final.tmp" && mv "$final.tmp" "$final"
    fi
  fi
  # Ensure Impact section exists
  if ! grep -q '^##\s\+Impact' "$final"; then
    printf '\n## Impact\n\n- Baseline → Outcome: <metric> — <before> → <after>\n' >>"$final"
  fi
fi

# Ensure retrospective file exists (always create file if missing)
if [[ ! -f "$retro" ]]; then
  .cursor/scripts/template-fill.sh --template retrospective --project "$project" --out "$retro" --vars projectName="$project"
fi

# Ensure tasks.md exists (create minimal stub)
if [[ ! -f "$tasks" ]]; then
  {
    printf '%s\n' '# Tasks'
    printf '%s\n' ''
  } > "$tasks"
fi

echo "Migrated: $project"

