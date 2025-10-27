#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

# links-check.sh — Validate Markdown relative links (file existence only)

usage() {
  cat <<'USAGE'
Usage: links-check.sh [--path <file-or-dir>]

Scans Markdown (.md, .mdc) for links and validates relative paths exist.

Options:
  --path <path>   File or directory to scan (default: current directory)
  -h, --help      Show this help and exit

Validates:
  - Relative paths: file existence on disk

Skips:
  - HTTP/HTTPS URLs
  - mailto: links
  - Anchors (#...)

Examples:
  # Check all markdown in current directory
  links-check.sh
  
  # Check specific directory
  links-check.sh --path docs/projects
  
  # Check single file
  links-check.sh --path README.md
USAGE
  
  print_exit_codes
}

target="${PWD}"
while [ $# -gt 0 ]; do
  case "$1" in
    --path) target="${2-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
done

if [ ! -e "$target" ]; then
  echo "path not found: $target" >&2
  exit 2
fi

shopt -s nullglob
declare -a files
if [ -d "$target" ]; then
  while IFS= read -r -d '' f; do 
    files+=("$f")
  done < <(find "$target" \
    -type d \( -name 'node_modules' -o -path '*/.cursor/scripts/tests/fixtures' -o -path '*/docs/projects/_archived/*' -o -path '*/docs/projects/rules-enforcement-investigation/*' -o -path '*/docs/projects/_examples/*' -o -path '*/docs/projects/portability/phases/*' -o -path '*/docs/projects/routing-optimization/*' -o -path '*/docs/projects/project-auto-archive-action/*' -o -path '*/docs/projects/script-organization-by-feature/*' \) -prune \
    -o -type f \( -name '*.md' -o -name '*.mdc' \) -print0)
else
  case "$target" in
    *.md|*.mdc) files+=("$target") ;;
    *) echo "unsupported file: $target" >&2; exit 2 ;;
  esac
fi

errors=0

# Resolve repository root (prefer git; fallback to current working directory)
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

check_relative() {
  local base_dir="$1"; shift
  local rel="$1"
  # strip anchors
  rel="${rel%%#*}"
  if [ -z "$rel" ]; then return 0; fi
  if [[ "$rel" =~ ^https?://|^mailto:|^# ]]; then return 0; fi
  if [[ "$rel" =~ ^/ ]]; then
    # treat leading-slash paths as repo-root-relative
    local abs_repo="$REPO_ROOT$rel"
    if [ -e "$abs_repo" ]; then return 0; fi
    echo "${CURRENT_FILE:-unknown}: relative missing: $rel"
    return 1
  fi
  local abs="$base_dir/$rel"
  if [ ! -e "$abs" ]; then
    # Fallback: try resolving relative to repo root
    local abs_repo="$REPO_ROOT/$rel"
    if [ -e "$abs_repo" ]; then return 0; fi
    echo "${CURRENT_FILE:-unknown}: relative missing: $rel"
    return 1
  fi
  return 0
}

extract_links() {
  # very simple regex for markdown links: [text](link)
  sed -n 's/.*(\([^()]*\)).*/\1/p' "$1" | sed 's/[">)]$//'
}

for f in "${files[@]}"; do
  base_dir="$(cd "$(dirname "$f")" && pwd)"
  # Relative links from markdown pattern [text](relative)
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    CURRENT_FILE="$f" check_relative "$base_dir" "$rel" || errors=$((errors+1))
  done < <(sed -nE 's/.*\[[^]]*\]\(([^)#]+)\).*/\1/p' "$f" | sed -E '/^https?:\/\//d; /^mailto:/d; /^#/d' || true)

done

if [ "$errors" -gt 0 ]; then
  echo "Broken links: $errors" >&2
  exit 1
fi

echo "All links OK (${#files[@]} files)"
exit 0


