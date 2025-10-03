#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1090
source "$(dirname "$0")/.lib.sh"

usage() {
  cat <<'USAGE'
Usage: alp-template.sh format --timestamp <ISO> --persona <persona> --problem <text> --solution <text> --lesson <text> [--rule <text>] [--context <text>]
USAGE
}

format_entry() {
  local timestamp persona problem solution lesson rule context
  while [ $# -gt 0 ]; do
    case "$1" in
      --timestamp) timestamp="$2"; shift 2 ;;
      --persona) persona="$2"; shift 2 ;;
      --problem) problem="$2"; shift 2 ;;
      --solution) solution="$2"; shift 2 ;;
      --lesson) lesson="$2"; shift 2 ;;
      --rule) rule="$2"; shift 2 ;;
      --context) context="$2"; shift 2 ;;
      *) die 2 "Unknown arg: $1" ;;
    esac
  done
  [ -n "${timestamp:-}" ] && [ -n "${persona:-}" ] && [ -n "${problem:-}" ] && [ -n "${solution:-}" ] && [ -n "${lesson:-}" ] || die 2 "missing required args"
  # Convert ISO to YYYY-MM-DDTHH:MM UTC
  local d
  d="$(date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$timestamp" "+%Y-%m-%dT%H:%M" 2>/dev/null || true)"
  if [ -z "$d" ]; then
    d="$(date -u -d "$timestamp" "+%Y-%m-%dT%H:%M" 2>/dev/null || true)"
  fi
  [ -n "$d" ] || die 2 "invalid timestamp"
  printf '[%s, %s] Problem: %s\n' "$d" "$persona" "$problem"
  printf 'Solution: %s\n' "$solution"
  printf 'Lesson: %s\n' "$lesson"
  if [ -n "${rule:-}" ]; then
    printf 'Rule candidate: %s [rule-candidate]\n' "$rule"
  fi
  if [ -n "${context:-}" ]; then
    printf 'Context: %s\n' "$context"
  fi
}

case "${1:-}" in
  format) shift; format_entry "$@" ;;
  -h|--help|*) usage ;;
esac
