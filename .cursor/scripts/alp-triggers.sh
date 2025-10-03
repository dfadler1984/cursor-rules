#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1090
source "$(dirname "$0")/.lib.sh"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"

LOG_DIR_CONFIG="./assistant-logs/"
ALP_FLAG=1

# Config placeholders: in a fuller impl, read from .cursor/config.json

now_iso() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

build_filename() {
  local short="$1"
  local iso="$(now_iso)"
  local safe="${iso//:/-}"
  printf '%s/log-%s-%s.md\n' "$LOG_DIR_CONFIG" "$safe" "$short"
}

emit_entry() {
  local short="$1"; shift
  local persona="$1"; shift
  local problem="$1"; shift
  local solution="$1"; shift
  local lesson="$1"; shift
  local rule="${1:-}"; shift || true
  local context="${1:-}" || true

  [ "$ALP_FLAG" -eq 1 ] || die 0 "ALP disabled; skipping"

  local ts="$(now_iso)"
  local tmp
  tmp="$(mktemp)"
  local args=(
    --timestamp "$ts"
    --persona "$persona"
    --problem "$problem"
    --solution "$solution"
    --lesson "$lesson"
  )
  if [ -n "$rule" ]; then args+=( --rule "$rule" ); fi
  if [ -n "${context:-}" ]; then args+=( --context "$context" ); fi
  bash "$ROOT_DIR/.cursor/scripts/alp-template.sh" format "${args[@]}" >"$tmp"

  local target
  target="$(build_filename "$short")"
  bash "$ROOT_DIR/.cursor/scripts/alp-logger.sh" write-with-fallback-file "$target" "$tmp" "$ROOT_DIR/docs/assistant-learning-logs" >/dev/null
  rm -f "$tmp"
  printf '%s\n' "$target"
}

usage() {
  cat <<'USAGE'
Usage: alp-triggers.sh <command> [args]

Commands (all require 5-7 args):
  tdd-fix <persona> <problem> <solution> <lesson> [rule] [context]
  intent-resolution <persona> <problem> <solution> <lesson> [rule] [context]
  rule-fix <persona> <problem> <solution> <lesson> [rule] [context]
  task-completion <persona> <problem> <solution> <lesson> [rule] [context]
  mcp-recovery <persona> <problem> <solution> <lesson> [rule] [context]
USAGE
}

cmd="${1:-}"; shift || true
case "$cmd" in
  tdd-fix) emit_entry "tdd-fix" "$@" ;;
  intent-resolution) emit_entry "intent-resolution" "$@" ;;
  rule-fix) emit_entry "rule-fix" "$@" ;;
  task-completion) emit_entry "task-completion" "$@" ;;
  mcp-recovery) emit_entry "mcp-recovery" "$@" ;;
  -h|--help|*) usage ;;
esac


