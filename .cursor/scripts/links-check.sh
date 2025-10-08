#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# links-check.sh — Validate Markdown relative links (file existence only)
# Usage: links-check.sh [--path <file-or-dir>]

usage() {
  cat <<'USAGE'
Usage: links-check.sh [--path <file-or-dir>]

Scans Markdown (.md, .mdc) for links and validates:
- Relative paths: file existence on disk

Skips: mailto:, anchors (#...)
USAGE
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
  while IFS= read -r -d '' f; do files+=("$f"); done < <(find "$target" -type f \( -name '*.md' -o -name '*.mdc' \) -print0)
else
  case "$target" in
    *.md|*.mdc) files+=("$target") ;;
    *) echo "unsupported file: $target" >&2; exit 2 ;;
  esac
fi

errors=0

check_relative() {
  local base_dir="$1"; shift
  local rel="$1"
  # strip anchors
  rel="${rel%%#*}"
  if [ -z "$rel" ]; then return 0; fi
  if [[ "$rel" =~ ^https?://|^mailto:|^# ]]; then return 0; fi
  if [[ "$rel" =~ ^/ ]]; then
    # treat absolute repo path as missing (avoid guessing repo root)
    if [ ! -e "$rel" ]; then
      echo "relative missing: $rel"
      return 1
    fi
    return 0
  fi
  local abs="$base_dir/$rel"
  if [ ! -e "$abs" ]; then
    echo "relative missing: $rel"
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
    check_relative "$base_dir" "$rel" || errors=$((errors+1))
  done < <(sed -nE 's/.*\[[^]]*\]\(([^)#]+)\).*/\1/p' "$f" | sed -E '/^https?:\/\//d; /^mailto:/d; /^#/d' || true)

done

if [ "$errors" -gt 0 ]; then
  echo "Broken links: $errors" >&2
  exit 1
fi

echo "All links OK (${#files[@]} files)"
exit 0


