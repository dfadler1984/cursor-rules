#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1090
source "$(dirname "$0")/.lib.sh"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
# When running tests, route artifacts to a dedicated dir
if [[ -n "${TEST_ARTIFACTS_DIR-}" ]]; then
  PRIMARY_DIR="$TEST_ARTIFACTS_DIR/alp"
  FALLBACK_DIR="$TEST_ARTIFACTS_DIR/alp"
else
  PRIMARY_DIR="$ROOT_DIR/assistant-logs"
  FALLBACK_DIR="$ROOT_DIR/docs/assistant-learning-logs"
fi

OUT_FILE="$FALLBACK_DIR/summary-$(date -u +"%Y-%m-%dT%H-%M-%SZ").md"

mkdir -p "$PRIMARY_DIR" "$FALLBACK_DIR"

count=0
# Portable accumulation file for rule candidates (avoids associative arrays for wider shell compatibility)
CANDIDATES_FILE="$(mktemp)"
trap 'rm -f "$CANDIDATES_FILE"' EXIT

scan_dir() {
  local d="$1"
  [ -d "$d" ] || return 0
  while IFS= read -r -d '' f; do
    count=$((count+1))
    # Extract rule candidates
    while IFS= read -r line; do
      if echo "$line" | grep -q "\[rule-candidate\]"; then
        name="$(printf '%s' "$line" | sed -E 's/^Rule candidate: ([^[]+).*/\1/' | sed 's/[[:space:]]*$//')"
        printf '%s\n' "$name" >>"$CANDIDATES_FILE"
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
  if [ ! -s "$CANDIDATES_FILE" ]; then
    printf '%s\n' '(none)'
    printf '\n'
  else
    sort "$CANDIDATES_FILE" | uniq -c | sed -E 's/^ *([0-9]+) +(.*)$/- \2 (\1)/'
    printf '\n'
  fi
} >"$OUT_FILE"

printf '%s\n' "$OUT_FILE"


