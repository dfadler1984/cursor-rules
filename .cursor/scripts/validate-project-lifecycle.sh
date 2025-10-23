#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

usage() {
  cat <<'EOF'
Usage: validate-project-lifecycle.sh [--pr-title "..."] <project-dir> [<project-dir> ...]

Checks for required closeout artifacts in each project directory under docs/projects/.

Options:
  --pr-title <title>  PR title for advisory checks
  -h, --help          Show this help and exit

Required artifacts:
  - final-summary.md exists, has front matter with template+version, and includes an "## Impact" section
  - tasks.md exists and either has all tasks checked or a "Carryovers" section
  - retrospective.md exists OR Final Summary has a "## Retrospective" section
  - No *.template.md files live in the project directory

Examples:
  # Validate single project
  validate-project-lifecycle.sh docs/projects/my-project
  
  # Validate multiple projects
  validate-project-lifecycle.sh docs/projects/proj1 docs/projects/proj2
  
  # Validate with PR title check
  validate-project-lifecycle.sh --pr-title "feat: complete project" docs/projects/my-project

Advisory:
  - Warn if closing PR title does not start with "feat:" (pass via --pr-title or env PR_TITLE)
EOF
  
  print_exit_codes
}

PR_TITLE_FLAG=""

# Parse optional flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --pr-title)
      PR_TITLE_FLAG="${2:-}"
      shift 2
      ;;
    --help|-h)
      usage >&2
      exit 0
      ;;
    --*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      break
      ;;
  esac
done

if [[ $# -lt 1 ]]; then
  usage >&2
  exit 2
fi

root_dir="$(cd "$(dirname "$0")/../.." && pwd)"
projects_root="${PROJECTS_ROOT:-$root_dir/docs/projects}"

failures=0

for proj in "$@"; do
  proj_dir="$projects_root/$proj"
  echo "[validate] Project: $proj"
  if [[ ! -d "$proj_dir" ]]; then
    echo "  [ERROR] Missing project directory: $proj_dir" >&2
    ((failures++)) || true
    continue
  fi

  final="$proj_dir/final-summary.md"
  tasks="$proj_dir/tasks.md"
  retro="$proj_dir/retrospective.md"

  # final-summary.md checks
  if [[ ! -s "$final" ]]; then
    echo "  [ERROR] Missing or empty: $final" >&2
    ((failures++)) || true
  else
    # Strict front-matter block: opening fence on first non-empty line and a closing fence
    first_nonempty=$(awk 'NF{print; exit}' "$final" || true)
    if [[ "$first_nonempty" != "---" ]]; then
      echo "  [ERROR] $final: front matter must start at top (---) — ensure the first non-empty line is '---'" >&2
      ((failures++)) || true
    fi
    fm_end_line=$(awk 'NR==1 && $0=="---"{inside=1; next} inside && $0=="---"{print NR; exit}' "$final" || true)
    if [[ -z "${fm_end_line:-}" ]]; then
      echo "  [ERROR] $final: missing closing front matter fence (---)" >&2
      ((failures++)) || true
    else
      # Validate fields within the front-matter block only
      fm_block=$(awk 'NR==1 && $0=="---"{inside=1; next} inside && $0=="---"{exit} inside{print}' "$final" || true)
      if ! printf '%s' "$fm_block" | grep -qE '^[[:space:]]*template:\s*project-lifecycle/'; then
        echo "  [ERROR] $final: missing template front matter — add 'template: project-lifecycle/final-summary' inside the front matter" >&2
        ((failures++)) || true
      fi
      if ! printf '%s' "$fm_block" | grep -qE '^[[:space:]]*version:\s*[0-9]+\.[0-9]+\.[0-9]+'; then
        echo "  [ERROR] $final: missing version in front matter — add 'version: 1.0.0' (semantic version)" >&2
        ((failures++)) || true
      fi
      if ! printf '%s' "$fm_block" | grep -qE '^[[:space:]]*last-updated:\s*[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
        echo "  [WARN] $final: 'last-updated' missing or not YYYY-MM-DD — add 'last-updated: $(date +%Y-%m-%d)'" >&2
      fi
    fi
    if ! grep -qE '^##\s+Impact' "$final"; then
      echo "  [ERROR] $final: missing ## Impact section — add a '## Impact' section with brief before/after metrics" >&2
      ((failures++)) || true
    fi
    
    # Check for unfilled template placeholders
    if grep -qE '<[^>]+>' "$final"; then
      placeholders=$(grep -E '<[^>]+>' "$final" | head -3 || true)
      echo "  [ERROR] $final: contains unfilled template placeholders — replace placeholders with project-specific content" >&2
      echo "  Example placeholders found:" >&2
      printf '%s\n' "$placeholders" | sed 's/^/    /' >&2
      ((failures++)) || true
    fi
  fi

  # tasks.md checks
  if [[ ! -f "$tasks" ]]; then
    echo "  [ERROR] Missing: $tasks" >&2
    ((failures++)) || true
  else
    unchecked=$(grep -E "^- \[ \]" "$tasks" || true)
    has_carry=$(grep -E "^##\s+Carryovers" "$tasks" || true)
    if [[ -n "$unchecked" && -z "$has_carry" ]]; then
      echo "  [ERROR] $tasks: has unchecked items without a Carryovers section" >&2
      ((failures++)) || true
    fi
  fi

  # retrospective presence (file or section)
  if [[ -f "$retro" ]]; then
    :
  else
    if [[ -f "$final" ]] && grep -qE '^##\s+Retrospective' "$final"; then
      :
    else
      echo "  [ERROR] $proj_dir: missing retrospective (file or section in final-summary.md)" >&2
      ((failures++)) || true
    fi
  fi

  # ensure no templates exist under project dir
  if find "$proj_dir" -maxdepth 1 -type f -name "*.template.md" | grep -q .; then
    echo "  [ERROR] $proj_dir: template files should not live under project directory" >&2
    ((failures++)) || true
  fi

  # advisory PR title check
  pr_title_effective="${PR_TITLE_FLAG:-${PR_TITLE:-}}"
  if [[ -n "$pr_title_effective" ]]; then
    if [[ ! "$pr_title_effective" =~ ^feat: ]]; then
      echo "  [WARN] PR title does not start with 'feat:' — advisory only" >&2
    fi
  fi
done

if [[ $failures -gt 0 ]]; then
  echo "[validate] FAIL: $failures issue(s) found" >&2
  exit 1
fi

echo "[validate] OK: all checks passed"

