#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Legacy copy of .cursor/scripts/.lib.sh

# Common helpers for shell scripts in this repository.
# Source with: source "$(dirname "$0")/.lib.sh"  (adjust path as needed)

script_name="${0##*/}"

timestamp() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

log() {
  local level="$1"; shift
  printf '%s [%s] %s\n' "$(timestamp)" "$level" "$*" >&2
}

log_info()  { log INFO  "$@"; }
log_warn()  { log WARN  "$@"; }
log_error() { log ERROR "$@"; }

die() {
  local code="${1:-1}"; shift || true
  if [ "$#" -gt 0 ]; then log_error "$*"; fi
  exit "$code"
}

have_cmd()    { command -v "$1" >/dev/null 2>&1; }
require_cmd() { have_cmd "$1" || die 127 "Required command not found: $1"; }

ensure_dir_exists()  { [ -d "$1" ] || die 1 "Directory not found: $1"; }

repo_root() {
  if git rev-parse --show-toplevel >/dev/null 2>&1; then
    git rev-parse --show-toplevel
  else
    pwd
  fi
}

# Minimal JSON helpers without external deps
json_escape() {
  local s="$1"
  s=${s//\\/\\\\}
  s=${s//\"/\\"}
  s=${s//$'\n'/\\n}
  s=${s//$'\r'/\\r}
  s=${s//$'\t'/\\t}
  printf '%s' "$s"
}

print_kv_json() {
  # Usage: print_kv_json key value [key value]...
  if [ "$#" -eq 0 ] || [ $(( $# % 2 )) -ne 0 ]; then
    die 2 "print_kv_json requires even number of args: key value ..."
  fi
  printf '{'
  local sep=""
  while [ "$#" -gt 0 ]; do
    local k="$1"; shift
    local v="$1"; shift
    printf '%s"%s":"%s"' "$sep" "$(json_escape "$k")" "$(json_escape "$v")"
    sep=','
  done
  printf '}\n'
}

# Simple table printer: expects tab-separated input; uses 'column' when available
print_table() {
  if have_cmd column; then
    column -t -s $'\t'
  else
    cat
  fi
}


