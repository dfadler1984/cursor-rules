#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ShellCheck runner with graceful degradation
# Lints shell scripts with consistent defaults

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

VERSION="0.1.0"

# Default values
PATHS="${PATHS:-.cursor/scripts}"
EXCLUDE=""
SEVERITY="warning"
FORMAT="tty"

usage() {
  print_help_header "shellcheck-run.sh" "$VERSION" "Lint shell scripts with ShellCheck"
  print_usage "shellcheck-run.sh [OPTIONS]"
  
  print_options
  print_option "--paths CSV" "Comma-separated paths to lint" "$PATHS"
  print_option "--exclude CSV" "ShellCheck codes to exclude (e.g., SC2086,SC2015)"
  print_option "--severity LEVEL" "Minimum severity: error, warning, info, style" "$SEVERITY"
  print_option "--format FMT" "Output format: tty, json, checkstyle, gcc" "$FORMAT"
  print_option "--version" "Print version and exit"
  print_option "-h, --help" "Show this help and exit"
  
  print_examples
  print_example "Lint default paths" "shellcheck-run.sh"
  print_example "Lint specific script with relaxed severity" "shellcheck-run.sh --paths .cursor/scripts/pr-create.sh --severity info"
  print_example "Exclude specific rules" "shellcheck-run.sh --exclude SC2086,SC2015"
  
  print_exit_codes
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --paths) PATHS="${2:-}"; shift 2 ;;
    --exclude) EXCLUDE="${2:-}"; shift 2 ;;
    --severity) SEVERITY="${2:-}"; shift 2 ;;
    --format) FORMAT="${2:-}"; shift 2 ;;
    --version) printf '%s\n' "$VERSION"; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    *) die "$EXIT_USAGE" "Unknown argument: $1" ;;
  esac
done

# Check if shellcheck is available
if ! have_cmd shellcheck; then
  log_warn "shellcheck not found; skipping lint"
  log_warn "Install: brew install shellcheck  (macOS)"
  log_warn "         apt install shellcheck   (Debian/Ubuntu)"
  log_warn "         snap install shellcheck  (Linux)"
  exit 0  # Exit successfully for portability
fi

# Gather shell scripts
IFS=',' read -ra path_array <<< "$PATHS"
scripts=()

for path in "${path_array[@]}"; do
  if [ -f "$path" ]; then
    # Single file
    scripts+=("$path")
  elif [ -d "$path" ]; then
    # Directory: find *.sh excluding *.test.sh for now
    while IFS= read -r -d '' script; do
      scripts+=("$script")
    done < <(find "$path" -type f -name "*.sh" -print0)
  else
    log_warn "Path not found: $path"
  fi
done

if [ "${#scripts[@]}" -eq 0 ]; then
  log_warn "No shell scripts found in: $PATHS"
  exit 0
fi

# Build shellcheck command
cmd=(shellcheck --severity="$SEVERITY" --format="$FORMAT")

if [ -n "$EXCLUDE" ]; then
  cmd+=(--exclude="$EXCLUDE")
fi

cmd+=("${scripts[@]}")

# Run shellcheck
log_info "Linting ${#scripts[@]} shell scripts with shellcheck"
set +e
"${cmd[@]}"
status=$?
set -e

if [ "$status" -ne 0 ]; then
  log_error "shellcheck found issues (exit $status)"
  exit 1
fi

log_info "shellcheck: OK"
exit 0

