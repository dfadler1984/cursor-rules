#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1090
source "$(dirname "$0")/.lib.sh"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
PRIMARY_DIR="$ROOT_DIR/assistant-logs"
FALLBACK_DIR="$ROOT_DIR/docs/assistant-learning-logs"

OUT_FILE="$FALLBACK_DIR/summary-$(date -u +"%Y-%m-%dT%H-%M-%SZ").md"

mkdir -p "$PRIMARY_DIR" "$FALLBACK_DIR"

count=0
declare -A candidate_count
declare -a themes

scan_dir() {
  local d="$1"
  [ -d "$d" ] || return 0
  while IFS= read -r -d '' f; do
    count=$((count+1))
    # Extract rule candidates
    while IFS= read -r line; do
      if echo "$line" | grep -q "\[rule-candidate\]"; then
        name="$(printf '%s' "$line" | sed -E 's/^Rule candidate: ([^[]+).*/\1/' | sed 's/[[:space:]]*$//')"
        candidate_count["$name"]=$(( ${candidate_count["$name"]:-0} + 1 ))
      fi
    done <"$f"
  done < <(find "$d" -type f -name 'log-*.md' -print0 2>/dev/null)
}

scan_dir "$PRIMARY_DIR"
scan_dir "$FALLBACK_DIR"

{
  printf '%s\n' '# Assistant Learning Summary'
  printf '\n'
  printf '%s\n' "- Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  printf '%s\n' "- Entries scanned: $count"
  printf '\n'
  printf '%s\n' '## Rule Candidates'
  printf '\n'
  if [ ${#candidate_count[@]} -eq 0 ]; then
    printf '%s\n' '(none)'
    printf '\n'
  else
    for k in "${!candidate_count[@]}"; do
      printf '%s\n' "- $k (${candidate_count[$k]})"
    done
    printf '\n'
  fi
} >"$OUT_FILE"

printf '%s\n' "$OUT_FILE"


