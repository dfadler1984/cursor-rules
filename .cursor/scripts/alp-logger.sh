#!/usr/bin/env bash
set -euo pipefail

# alp-logger.sh — learning logs helpers
#
# Examples (with explicit log dir):
#   .cursor/scripts/alp-logger.sh --log-dir .test-artifacts/alp write-with-fallback assistant-logs "smoke" <<<'body'
#   .cursor/scripts/alp-logger.sh --log-dir ./assistant-logs build-filename example
# Commands:
#   build-filename <short> [--at <ISO>]
#   write-local <path> <content>
#   is-writable <dir>
#   write-with-fallback <primaryPath> <content> <fallbackDir>
#   write-with-fallback-file <primaryPath> <tmpFile> <fallbackDir>

CLI_LOG_DIR=""

usage() {
  cat >&2 <<USAGE
Usage: $0 [--log-dir <dir>] <command> [args]

Commands:
  build-filename <short> [--at <ISO>]
  write-local <path> <content>
  is-writable <dir>
  write-with-fallback <destDir> <short> [reads body from stdin] (back-compat)
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
    if redacted="$(printf "%s" "$body" | .cursor/scripts/alp-redaction.sh redact 2>/dev/null)"; then
      printf '%s' "$redacted"
      return 0
    fi
  fi
  printf '%s' "$body"
}

write_with_fallback_cmd() {
  # Back-compat form: write-with-fallback <destDir> <short>, body from stdin
  if [[ $# -eq 2 ]]; then
    local destDir="$1"; local short="$2"
    local primaryDir="${CLI_LOG_DIR:-${ALP_LOG_DIR-}}"
    if [[ -z "${primaryDir:-}" ]]; then
      primaryDir="$destDir"
    fi
    local fileName
    fileName="$(build_filename "$short")"
    local target="$primaryDir/$fileName"
    mkdir -p -- "$primaryDir" || true
    # Read body from stdin and redact if possible
    local body
    body="$(cat -)"
    body="$(redact_if_possible "$body")"
    if printf '%s' "$body" > "$target" 2>/dev/null; then
      printf '%s\n' "$target"; return 0
    fi
    local fallbackDir="docs/assistant-learning-logs"
    mkdir -p -- "$fallbackDir"
    target="$fallbackDir/$fileName"
    printf '%s' "$body" > "$target"
    printf '%s\n' "$target"
    return 0
  fi

  # Modern form: write-with-fallback <primaryPath> <content> <fallbackDir>
  local primaryPath="$1"; local content="$2"; local fallbackDir="${3-}"
  local primaryDir="${CLI_LOG_DIR:-${ALP_LOG_DIR-}}"
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
  if [[ -z "${fallbackDir:-}" ]]; then
    fallbackDir="docs/assistant-learning-logs"
  fi
  mkdir -p -- "$fallbackDir"
  target="$fallbackDir/$fileName"
  printf '%s' "$content" > "$target"
  printf '%s\n' "$target"
}

write_with_fallback_file_cmd() {
  local primaryPath="$1"; local tmpFile="$2"; local fallbackDir="${3-}"
  local primaryDir="${CLI_LOG_DIR:-${ALP_LOG_DIR-}}"
  if [[ -z "${primaryDir:-}" ]]; then
    primaryDir="$(dirname "$primaryPath")"
  fi
  local fileName="$(basename "$primaryPath")"
  mkdir -p -- "$primaryDir" || true
  local target="$primaryDir/$fileName"
  if cp "$tmpFile" "$target" 2>/dev/null; then
    printf '%s\n' "$target"; return 0
  fi
  if [[ -z "${fallbackDir:-}" ]]; then
    fallbackDir="docs/assistant-learning-logs"
  fi
  mkdir -p -- "$fallbackDir"
  target="$fallbackDir/$fileName"
  cp "$tmpFile" "$target"
  printf '%s\n' "$target"
}

parse_global_flags() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --log-dir)
        CLI_LOG_DIR="$2"; shift 2 ;;
      build-filename|write-local|is-writable|write-with-fallback|write-with-fallback-file|-h|--help)
        # push back for main dispatch
        break ;;
      *)
        break ;;
    esac
  done
  # return remaining args via echo
  printf '%s\n' "$@"
}

main() {
  # Parse optional global flags
  readarray -t REM_ARGS < <(parse_global_flags "$@")
  set -- "${REM_ARGS[@]}"
  local cmd="${1-}"; shift || true
  case "$cmd" in
    build-filename) build_filename "$@" ;;
    write-local) write_local "$@" ;;
    is-writable) is_writable_cmd "$@" ;;
    write-with-fallback) write_with_fallback_cmd "$@" ;;
    write-with-fallback-file) write_with_fallback_file_cmd "$@" ;;
    *) usage ;;
  esac
  # Run threshold check (best-effort, non-blocking)
  if [[ -x ".cursor/scripts/alp-threshold.sh" ]]; then
    if [[ -n "${ALP_TEST_THRESHOLD-}" ]]; then
      .cursor/scripts/alp-threshold.sh --threshold "$ALP_TEST_THRESHOLD" >/dev/null 2>&1 || true
    else
      .cursor/scripts/alp-threshold.sh >/dev/null 2>&1 || true
    fi
  fi
}

main "$@"
