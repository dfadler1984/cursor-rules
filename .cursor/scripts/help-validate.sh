#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Help validator — ensures scripts have complete help documentation
# Validates D1: Help/Version Minimums and Section Schema

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

VERSION="0.1.0"

# Default values
PATHS="${PATHS:-.cursor/scripts}"

usage() {
  print_help_header "help-validate.sh" "$VERSION" "Validate script help documentation"
  print_usage "help-validate.sh [OPTIONS]"
  
  print_options
  print_option "--paths CSV" "Comma-separated paths to validate" "$PATHS"
  print_option "--version" "Print version and exit"
  print_option "-h, --help" "Show this help and exit"
  
  cat <<'DETAILS'

Required Help Sections (D1):
  - Usage: command syntax
  - Options: flag descriptions
  - Examples: at least one usage example
  - Exit Codes: standard codes documented

Required Flags:
  - -h, --help: show help and exit 0
  - --version: show version and exit 0 (recommended)

DETAILS
  
  print_examples
  print_example "Validate default paths" "help-validate.sh"
  print_example "Validate specific script" "help-validate.sh --paths .cursor/scripts/pr-create.sh"
  
  print_exit_codes
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --paths) PATHS="${2:-}"; shift 2 ;;
    --version) printf '%s\n' "$VERSION"; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    *) die "$EXIT_USAGE" "Unknown argument: $1" ;;
  esac
done

# Gather shell scripts (excluding test files and libraries)
IFS=',' read -ra path_array <<< "$PATHS"
scripts=()

for path in "${path_array[@]}"; do
  if [ -f "$path" ]; then
    # Single file
    scripts+=("$path")
  elif [ -d "$path" ]; then
    # Directory: find *.sh excluding *.test.sh and .lib*.sh
    while IFS= read -r -d '' script; do
      case "$(basename "$script")" in
        *.test.sh|.lib*.sh) ;;
        *) scripts+=("$script") ;;
      esac
    done < <(find "$path" -type f -name "*.sh" -print0)
  else
    log_warn "Path not found: $path"
  fi
done

if [ "${#scripts[@]}" -eq 0 ]; then
  log_warn "No shell scripts found in: $PATHS"
  exit 0
fi

violations=0
violation_details=()

for script in "${scripts[@]}"; do
  script_name="$(basename "$script")"
  
  # Check if script supports --help flag
  if ! grep -qE '(-h\|--help|--help\|-h)' "$script" 2>/dev/null; then
    violations=$((violations + 1))
    violation_details+=("$script_name: missing --help flag")
    continue
  fi
  
  # Try to run --help and capture output
  set +e
  help_output=$("$script" --help 2>&1 || true)
  set -e
  
  if [ -z "$help_output" ]; then
    violations=$((violations + 1))
    violation_details+=("$script_name: --help produces no output")
    continue
  fi
  
  # Check for required sections
  missing_sections=()
  
  if ! echo "$help_output" | grep -qi "^Usage:"; then
    missing_sections+=("Usage")
  fi
  
  if ! echo "$help_output" | grep -qi "^Options:"; then
    missing_sections+=("Options")
  fi
  
  if ! echo "$help_output" | grep -qi "^Examples:"; then
    missing_sections+=("Examples")
  fi
  
  if ! echo "$help_output" | grep -qiE "^Exit Codes?:"; then
    missing_sections+=("Exit Codes")
  fi
  
  if [ "${#missing_sections[@]}" -gt 0 ]; then
    violations=$((violations + 1))
    violation_details+=("$script_name: missing sections: ${missing_sections[*]}")
  fi
done

if [ "$violations" -gt 0 ]; then
  log_error "Help validation: $violations violation(s) found"
  for detail in "${violation_details[@]}"; do
    printf '  - %s\n' "$detail" >&2
  done
  printf '\n' >&2
  printf 'Required sections per D1:\n' >&2
  printf '  - Usage: command syntax\n' >&2
  printf '  - Options: flag descriptions\n' >&2
  printf '  - Examples: at least one usage example\n' >&2
  printf '  - Exit Codes: standard codes documented\n' >&2
  printf '\n' >&2
  printf 'Use .lib.sh help functions:\n' >&2
  printf '  print_help_header, print_usage, print_options, print_exit_codes, print_examples\n' >&2
  printf '\n' >&2
  printf 'See: docs/projects/_archived/2025/shell-and-script-tooling/erd.md D1\n' >&2
  exit 1
fi

log_info "Help validation: OK (${#scripts[@]} scripts validated)"
exit 0

