#!/usr/bin/env bash
set -euo pipefail

# alp-logger.sh — learning logs helpers
# Commands:
#   build-filename <short> [--at <ISO>]
#   write-local <path> <content>
#   is-writable <dir>
#   write-with-fallback <primaryPath> <content> <fallbackDir>
#   write-with-fallback-file <primaryPath> <tmpFile> <fallbackDir>

usage() {
  cat >&2 <<USAGE
Usage: $0 <command> [args]

Commands:
  build-filename <short> [--at <ISO>]
  write-local <path> <content>
  is-writable <dir>
  write-with-fallback <primaryPath> <content> <fallbackDir>
  write-with-fallback-file <primaryPath> <tmpFile> <fallbackDir>
USAGE
  exit 1
}

timestamp_iso() { date -u +%Y-%m-%dT%H-%M-%SZ; }

slugify() {
  local input="$1"
  echo "$input" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

build_filename() {
  local short="$1"; shift || true
  local at=""
  if [[ "${1-}" == "--at" ]]; then at="$2"; fi
  local ts
  if [[ -n "$at" ]]; then
    ts="${at//:/-}"
  else
    ts="$(timestamp_iso)"
  fi
  printf 'log-%s-%s.md' "$ts" "$(slugify "$short")"
}

write_local() {
  local path="$1"; local content="$2"
  mkdir -p -- "$(dirname "$path")"
  printf '%s' "$content" > "$path"
}

is_writable_cmd() {
  local dir="$1"
  mkdir -p -- "$dir" || return 1
  local probe="$dir/.writable-$(timestamp_iso)"
  if printf '%s' ok > "$probe" 2>/dev/null; then
    rm -f "$probe" || true
    return 0
  fi
  return 1
}

redact_if_possible() {
  local body="$1"
  if [[ -x ".cursor/scripts/alp-redaction.sh" ]]; then
    if redacted="$(printf "%s" "$body" | .cursor/scripts/alp-redaction.sh 2>/dev/null)"; then
      printf '%s' "$redacted"
      return 0
    fi
  fi
  printf '%s' "$body"
}

write_with_fallback_cmd() {
  local primaryPath="$1"; local content="$2"; local fallbackDir="$3"
  local primaryDir="$ALP_LOG_DIR"
  if [[ -z "${primaryDir:-}" ]]; then
    primaryDir="$(dirname "$primaryPath")"
  fi
  local fileName="$(basename "$primaryPath")"
  mkdir -p -- "$primaryDir" || true
  content="$(redact_if_possible "$content")"
  local target="$primaryDir/$fileName"
  if printf '%s' "$content" > "$target" 2>/dev/null; then
    printf '%s\n' "$target"; return 0
  fi
  mkdir -p -- "$fallbackDir"
  target="$fallbackDir/$fileName"
  printf '%s' "$content" > "$target"
  printf '%s\n' "$target"
}

write_with_fallback_file_cmd() {
  local primaryPath="$1"; local tmpFile="$2"; local fallbackDir="$3"
  local primaryDir="$ALP_LOG_DIR"
  if [[ -z "${primaryDir:-}" ]]; then
    primaryDir="$(dirname "$primaryPath")"
  fi
  local fileName="$(basename "$primaryPath")"
  mkdir -p -- "$primaryDir" || true
  local target="$primaryDir/$fileName"
  if cp "$tmpFile" "$target" 2>/dev/null; then
    printf '%s\n' "$target"; return 0
  fi
  mkdir -p -- "$fallbackDir"
  target="$fallbackDir/$fileName"
  cp "$tmpFile" "$target"
  printf '%s\n' "$target"
}

main() {
  local cmd="${1-}"; shift || true
  case "$cmd" in
    build-filename) build_filename "$@" ;;
    write-local) write_local "$@" ;;
    is-writable) is_writable_cmd "$@" ;;
    write-with-fallback) write_with_fallback_cmd "$@" ;;
    write-with-fallback-file) write_with_fallback_file_cmd "$@" ;;
    *) usage ;;
  esac
}

main "$@"
