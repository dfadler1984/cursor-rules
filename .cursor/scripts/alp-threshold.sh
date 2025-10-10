#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# alp-threshold.sh — Summarize + archive when unarchived logs reach a threshold
#
# Example:
#   .cursor/scripts/alp-threshold.sh --log-dir .test-artifacts/alp --threshold 5
# Usage: alp-threshold.sh [--threshold N] [--log-dir DIR]
# Env:
#   ALP_ARCHIVE_THRESHOLD — default 10
#   ALP_AUTO_ARCHIVE     — set to 0 to disable automatic aggregate/archive (default 1)

usage() {
  cat <<'USAGE'
Usage: alp-threshold.sh [--threshold N] [--log-dir DIR]

Checks the current logDir for unarchived logs. If count >= threshold,
runs the aggregator to produce a summary and archives reviewed logs.

Env:
  ALP_ARCHIVE_THRESHOLD — default 10
  ALP_AUTO_ARCHIVE     — set to 0 to disable (default 1)
USAGE
}

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT_DIR"

threshold="${ALP_ARCHIVE_THRESHOLD:-10}"
auto="${ALP_AUTO_ARCHIVE:-1}"
LOG_DIR_CLI=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --threshold)
      threshold="${2:-}"; shift 2 || true ;;
    --log-dir)
      LOG_DIR_CLI="${2:-}"; shift 2 || true ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
done

# Resolve destination directory with precedence: env override -> .cursor/config.json -> default
resolve_log_dir() {
  if [[ -n "${ASSISTANT_LOG_DIR:-}" ]]; then
    printf "%s" "$ASSISTANT_LOG_DIR"; return
  fi
  if [[ -f ".cursor/config.json" ]] && command -v jq >/dev/null 2>&1; then
    jq -r '.logDir // "assistant-logs"' < .cursor/config.json
    return
  fi
  printf "%s" "assistant-logs"
}

if [[ -n "$LOG_DIR_CLI" ]]; then
  LOG_DIR="$LOG_DIR_CLI"
else
  LOG_DIR="$(resolve_log_dir)"
fi
if [[ "$LOG_DIR" != /* ]]; then LOG_DIR="$ROOT_DIR/$LOG_DIR"; fi

mkdir -p "$LOG_DIR"

# Count unarchived logs at top level (exclude _archived/*)
count=$(find "$LOG_DIR" -maxdepth 1 -type f -name 'log-*.md' 2>/dev/null | wc -l | tr -d ' ')

if [[ "$auto" != "0" && "$count" -ge "$threshold" ]]; then
  # Produce an aggregate summary (path printed to stdout by script)
  summary_path="$(.cursor/scripts/alp-aggregate.sh 2>/dev/null || true)"
  # Select the oldest N (=threshold) top-level logs deterministically by filename (ISO-style)
  # and mark only those as Reviewed so that archive moves exactly N, leaving the newest unarchived.
  # Collect list into an array to avoid subshell issues
  mapfile -t oldest_list < <(ls -1 "$LOG_DIR"/log-*.md 2>/dev/null | sort | head -n "$threshold")
  for f in "${oldest_list[@]}"; do
    [[ -f "$f" ]] || continue
    .cursor/scripts/alp-archive.sh mark "$f" >/dev/null 2>&1 || true
  done
  # Archive reviewed logs and emit archive summary
  archive_out="$(.cursor/scripts/alp-archive.sh archive 2>/dev/null || true)"
  printf '%s\n' "ALP threshold reached: $count >= $threshold"
  if [[ -n "${summary_path:-}" ]]; then printf '%s\n' "Aggregate: $summary_path"; fi
  if [[ -n "${archive_out:-}" ]]; then printf '%s\n' "Archive: $archive_out"; fi
fi

exit 0


