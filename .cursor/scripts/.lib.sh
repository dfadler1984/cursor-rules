#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Common helpers for shell scripts in this repository.
# Source with: source "$(dirname "$0")/.lib.sh"  (adjust path as needed)

# Guard against double-sourcing
if [ -n "${_LIB_SH_LOADED:-}" ]; then
  return 0
fi
readonly _LIB_SH_LOADED=1

script_name="${0##*/}"

# Exit code catalog (see docs/projects/shell-and-script-tooling/erd.md D3)
readonly EXIT_USAGE=2
readonly EXIT_CONFIG=3
readonly EXIT_DEPENDENCY=4
readonly EXIT_NETWORK=5
readonly EXIT_TIMEOUT=6
readonly EXIT_INTERNAL=20

# Enable strict mode with error traps for better debugging
enable_strict_mode() {
  set -euo pipefail
  IFS=$'\n\t'
  # Trap errors and print script:line context
  trap 'log_error "Failed at ${BASH_SOURCE[0]:-script}:${LINENO}"' ERR
}

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
  s=${s//\"/\\\"}
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

# Execute a command with a temporary directory that's cleaned up on exit
# Usage: with_tempdir my_function [args...]
# The function receives the temp directory path as its last argument
with_tempdir() {
  if [ "$#" -eq 0 ]; then
    die "$EXIT_USAGE" "with_tempdir requires at least one argument (function to call)"
  fi
  
  local tmpdir
  tmpdir="$(mktemp -d 2>/dev/null || mktemp -d -t "${script_name%.sh}")"
  
  # Set up cleanup trap
  # shellcheck disable=SC2064 -- we want tmpdir expanded now
  trap "rm -rf '$tmpdir'" EXIT ERR INT TERM
  
  # Call the function with all args plus tmpdir as last arg
  "$@" "$tmpdir"
}

# Print standardized help header
# Usage: print_help_header <script-name> <version> <one-line-description>
print_help_header() {
  local name="${1:-$script_name}"
  local version="${2:-}"
  local description="${3:-}"
  
  printf '%s' "$name"
  [ -n "$version" ] && printf ' (v%s)' "$version"
  printf '\n'
  [ -n "$description" ] && printf '%s\n' "$description"
  printf '\n'
}

# Print standardized usage section
# Usage: print_usage <usage-pattern>
# Example: print_usage "script.sh [OPTIONS] <arg>"
print_usage() {
  printf 'Usage: %s\n\n' "$1"
}

# Print standardized options section
# Usage: print_options
# Call this before using print_option for each flag
print_options() {
  printf 'Options:\n'
}

# Print a single option line
# Usage: print_option <flag> <description> [default]
# Example: print_option "--verbose" "Enable verbose output"
# Example: print_option "--format FMT" "Output format" "json"
print_option() {
  local flag="$1"
  local desc="$2"
  local default="${3:-}"
  
  if [ -n "$default" ]; then
    printf '  %-20s %s (default: %s)\n' "$flag" "$desc" "$default"
  else
    printf '  %-20s %s\n' "$flag" "$desc"
  fi
}

# Print standardized exit codes section
# Usage: print_exit_codes
print_exit_codes() {
  cat <<'EXIT_CODES'

Exit Codes:
  0   Success
  1   General error
  2   Usage error (invalid arguments)
  3   Configuration error
  4   Dependency missing
  5   Network error
  6   Timeout
  20  Internal error

For more details, see docs/projects/shell-and-script-tooling/erd.md
EXIT_CODES
}

# Print standardized examples section
# Usage: print_examples
# Call this before using print_example for each example
print_examples() {
  printf '\nExamples:\n'
}

# Print a single example
# Usage: print_example <description> <command>
print_example() {
  local desc="$1"
  local cmd="$2"
  
  printf '  # %s\n' "$desc"
  printf '  $ %s\n\n' "$cmd"
}
