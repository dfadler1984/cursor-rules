#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# alp-archive.sh — mark and archive reviewed assistant-learning logs
#
# Subcommands:
#   mark <file> [--date YYYY-MM-DD]
#     - Idempotently appends a Reviewed: <date> line to the log file
#   archive [--source <dir>] [--dest <dir>] [--dry-run]
#     - Moves files containing a line starting with "Reviewed:" to an archive folder
#       under <dest> (defaults to <source>/_archived/YYYY/MM/)
#
# Source resolution for --source (in order):
#   1) --source flag
#   2) $ASSISTANT_LOG_DIR
#   3) .cursor/config.json .logDir (via jq if available)
#   4) ./assistant-logs

here() { cd "$(dirname "$0")" && pwd; }
root() { cd "$(here)/../.." && pwd; }
timestamp_iso() { date -u +%Y-%m-%dT%H-%M-%SZ; }

resolve_source_dir() {
  local src=""
  if [[ -n "${SOURCE_DIR:-}" ]]; then
    src="$SOURCE_DIR"
  elif [[ -n "${ASSISTANT_LOG_DIR:-}" ]]; then
    src="$ASSISTANT_LOG_DIR"
  elif [[ -f "$(root)/.cursor/config.json" ]] && command -v jq >/dev/null 2>&1; then
    src="$(jq -r '.logDir // "assistant-logs"' <"$(root)/.cursor/config.json")"
  else
    src="assistant-logs"
  fi
  # Normalize to absolute path
  if [[ "$src" != /* ]]; then
    src="$(root)/$src"
  fi
  printf "%s" "$src"
}

usage() {
  cat <<'USAGE'
Usage:
  .cursor/scripts/alp-archive.sh mark <file> [--date YYYY-MM-DD]
  .cursor/scripts/alp-archive.sh archive [--source <dir>] [--dest <dir>] [--dry-run]

Marks logs as reviewed and archives reviewed logs to <source>/_archived/YYYY/MM/.
USAGE
}

cmd_mark() {
  local file="${1:-}"; shift || true
  local date_arg=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --date)
        date_arg="${2:-}"; shift 2 || true ;;
      *)
        echo "Unknown arg: $1" >&2; exit 2 ;;
    esac
  done
  [[ -n "$file" ]] || { echo "mark: missing <file>" >&2; exit 2; }
  [[ -f "$file" ]] || { echo "mark: not a file: $file" >&2; exit 2; }
  local when
  if [[ -n "$date_arg" ]]; then
    when="$date_arg"
  else
    when="$(date -u +%Y-%m-%d)"
  fi
  if grep -q '^Reviewed:' "$file" 2>/dev/null; then
    # Already marked; no-op
    printf "%s\n" "$file"
    return 0
  fi
  printf "Reviewed: %s\n" "$when" >>"$file"
  printf "%s\n" "$file"
}

cmd_archive() {
  # Parse flags
  local dry_run=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --source)
        SOURCE_DIR="${2:-}"; shift 2 || true ;;
      --dest)
        DEST_DIR="${2:-}"; shift 2 || true ;;
      --dry-run)
        dry_run=1; shift ;; 
      *)
        echo "Unknown arg: $1" >&2; exit 2 ;;
    esac
  done

  local source_dir dest_dir
  source_dir="$(resolve_source_dir)"
  if [[ -n "${DEST_DIR:-}" ]]; then
    dest_dir="$DEST_DIR"
    if [[ "$dest_dir" != /* ]]; then dest_dir="$(root)/$dest_dir"; fi
  else
    dest_dir="$source_dir/_archived"
  fi

  mkdir -p "$dest_dir"
  # Find reviewed logs
  local archived_list=""
  while IFS= read -r -d '' f; do
    if grep -q '^Reviewed:' "$f" 2>/dev/null; then
      # Determine archive subdir by timestamp in filename if present, else today
      # Filename pattern: log-<ISO>-<short>.md
      base="$(basename "$f")"
      # Extract YYYY and MM from filename pattern: log-YYYY-MM-DDT...
      local y m
      local date_part
      date_part="${base#log-}"
      date_part="${date_part%%T*}"
      if [[ "$date_part" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})$ ]]; then
        y="${BASH_REMATCH[1]}"; m="${BASH_REMATCH[2]}"
      else
        y="$(date -u +%Y)"; m="$(date -u +%m)"
      fi
      target_dir="$dest_dir/$y/$m"
      mkdir -p "$target_dir"
      if [[ $dry_run -eq 1 ]]; then
        echo "DRY: mv \"$f\" \"$target_dir/$base\""
        archived_list+="$target_dir/$base\n"
      else
        mv "$f" "$target_dir/$base"
        # Append archived stamp
        printf "Archived: %s\n" "$(timestamp_iso)" >>"$target_dir/$base"
        echo "$target_dir/$base"
        archived_list+="$target_dir/$base\n"
      fi
    fi
  done < <(find "$source_dir" -maxdepth 1 -type f -name 'log-*.md' -print0 2>/dev/null)

  # Emit a summary for this archive operation
  if [[ -n "$archived_list" ]]; then
    if [[ $dry_run -eq 1 ]]; then
      echo "DRY: would write archive summary for $(printf "%s" "$archived_list" | wc -l | tr -d ' ') files"
    else
      local docs_dir
      docs_dir="$(root)/docs/assistant-learning-logs"
      mkdir -p "$docs_dir"
      local ts out
      ts="$(timestamp_iso)"
      out="$docs_dir/summary-archived-$ts.md"
      # Collect learnings from each archived file: lines starting with Learning: or Lesson:
      local learnings
      learnings="$(
        printf "%s" "$archived_list" | sed '/^$/d' | while IFS= read -r p; do
          if [[ -f "$p" ]]; then
            grep -E '^(Learning|Lesson):' "$p" 2>/dev/null | sed -E 's/^(Learning|Lesson):[[:space:]]*/- /'
          fi
        done
      )"
      {
        printf '%s\n' '# Archived Assistant Learning Logs'
        printf '\n'
        printf '%s\n' "- Timestamp: $ts"
        # Count lines in archived_list; trim trailing newline for accurate count
        local cnt
        cnt=$(printf "%s" "$archived_list" | sed '/^$/d' | wc -l | tr -d ' ')
        printf '%s\n' "- Archived count: $cnt"
        printf '\n'
        printf '%s\n' '## Highlights'
        printf '\n'
        printf '%s\n' '- Archiving performed successfully; see archived count above.'
        printf '\n'
        printf '%s\n' '## Learnings'
        printf '\n'
        if [[ -n "$learnings" ]]; then
          printf '%s\n' "$learnings"
        else
          printf '%s\n' '- (none captured)'
        fi
      } >"$out"
      echo "$out"
    fi
  fi
}

main() {
  local cmd="${1:-}"; [[ -n "$cmd" ]] || { usage; exit 2; }
  shift || true
  case "$cmd" in
    mark) cmd_mark "$@" ;;
    archive) cmd_archive "$@" ;;
    -h|--help) usage ;;
    *) usage; exit 2 ;;
  esac
}

main "$@"


