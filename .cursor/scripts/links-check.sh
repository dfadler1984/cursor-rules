#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# links-check.sh — Validate Markdown links (external HTTP(S) and relative paths)
# Usage: links-check.sh [--path <file-or-dir>]

usage() {
  cat <<'USAGE'
Usage: links-check.sh [--path <file-or-dir>]

Scans Markdown (.md, .mdc) for links and validates:
- External http(s): HEAD request (follow redirects, short timeout)
- Relative paths: file existence on disk

Skips: mailto:, anchors (#...), localhost, 127.0.0.1
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

curl_cmd="${CURL_CMD-curl}"

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

is_skipped_url() {
  local u="$1"
  [[ "$u" =~ ^mailto: ]] && return 0
  [[ "$u" =~ ^# ]] && return 0
  [[ "$u" =~ ^https?://(localhost|127\.0\.0\.1)[:/].* ]] && return 0
  return 1
}

check_external() {
  local url="$1"
  if is_skipped_url "$url"; then return 0; fi
  if [[ "$url" =~ ^https?:// ]]; then
    if ! $curl_cmd -sSIL --max-redirs 3 --connect-timeout 5 --retry 1 "$url" >/dev/null 2>&1; then
      echo "external failed: $url"
      return 1
    fi
  fi
  return 0
}

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
  # External links (http/https) – use grep to find them robustly
  while IFS= read -r url; do
    [ -n "$url" ] || continue
    check_external "$url" || errors=$((errors+1))
  done < <(grep -Eo 'https?://[^)\s]+' "$f" || true)

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


