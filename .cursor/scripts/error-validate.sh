#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Error handling validator — ensures scripts follow strict mode conventions
# Validates D2 (Strict Mode) and D3 (Exit Code Semantics)

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

VERSION="0.1.0"

# Default values
PATHS="${PATHS:-.cursor/scripts}"
STRICT_EXIT_CODES=0

usage() {
  print_help_header "error-validate.sh" "$VERSION" "Validate error handling and strict mode"
  print_usage "error-validate.sh [OPTIONS]"
  
  print_options
  print_option "--paths CSV" "Comma-separated paths to validate" "$PATHS"
  print_option "--strict-exit-codes" "Check for non-standard exit codes (warns only)"
  print_option "--version" "Print version and exit"
  print_option "-h, --help" "Show this help and exit"
  
  cat <<'DETAILS'

Required Strict Mode (D2):
  - set -euo pipefail (or set -Eeuo pipefail)
  - IFS=$'\n\t' (recommended)
  OR
  - source .lib.sh + enable_strict_mode() call

Standard Exit Codes (D3):
  0   = success
  1   = general error
  2   = usage error
  3   = config error
  4   = dependency missing
  5   = network error
  6   = timeout
  20  = internal error

DETAILS
  
  print_examples
  print_example "Validate default paths" "error-validate.sh"
  print_example "Check exit codes strictly" "error-validate.sh --strict-exit-codes"
  
  print_exit_codes
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --paths) PATHS="${2:-}"; shift 2 ;;
    --strict-exit-codes) STRICT_EXIT_CODES=1; shift ;;
    --version) printf '%s\n' "$VERSION"; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    *) die "$EXIT_USAGE" "Unknown argument: $1" ;;
  esac
done

# Standard exit codes per D3
STANDARD_EXITS=(0 1 2 3 4 5 6 20)

# Gather shell scripts (excluding test files and libraries)
IFS=',' read -ra path_array <<< "$PATHS"
scripts=()

for path in "${path_array[@]}"; do
  if [ -f "$path" ]; then
    scripts+=("$path")
  elif [ -d "$path" ]; then
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
warnings=0
violation_details=()
warning_details=()

for script in "${scripts[@]}"; do
  script_name="$(basename "$script")"
  
  # Check for strict mode
  has_strict_mode=0
  
  # Pattern 1: Inline strict mode (set -euo pipefail or set -Eeuo pipefail)
  if grep -qE '^set -[Ee]?uo pipefail' "$script" 2>/dev/null; then
    has_strict_mode=1
  fi
  
  # Pattern 2: Sources .lib.sh and calls enable_strict_mode
  if grep -qE 'source.*\.lib\.sh' "$script" 2>/dev/null; then
    # Check if enable_strict_mode is called or if inline strict mode exists
    if grep -qE '(enable_strict_mode|^set -[Ee]?uo pipefail)' "$script" 2>/dev/null; then
      has_strict_mode=1
    fi
  fi
  
  if [ "$has_strict_mode" -eq 0 ]; then
    violations=$((violations + 1))
    violation_details+=("$script_name: missing strict mode (set -euo pipefail)")
    continue
  fi
  
  # Optional: Check for non-standard exit codes
  if [ "$STRICT_EXIT_CODES" -eq 1 ]; then
    # Look for exit statements with non-standard codes
    while IFS= read -r line; do
      # Extract exit code from 'exit N' statements
      if echo "$line" | grep -qE '^\s*exit [0-9]+'; then
        exit_code=$(echo "$line" | grep -oE 'exit [0-9]+' | grep -oE '[0-9]+')
        
        # Check if it's a standard code
        is_standard=0
        for std_code in "${STANDARD_EXITS[@]}"; do
          if [ "$exit_code" -eq "$std_code" ]; then
            is_standard=1
            break
          fi
        done
        
        if [ "$is_standard" -eq 0 ]; then
          warnings=$((warnings + 1))
          warning_details+=("$script_name: non-standard exit code $exit_code (consider using EXIT_* constants)")
          break  # One warning per script
        fi
      fi
    done < <(grep -E '^\s*exit [0-9]+' "$script" 2>/dev/null || true)
  fi
done

if [ "$violations" -gt 0 ]; then
  log_error "Error validation: $violations violation(s) found"
  for detail in "${violation_details[@]}"; do
    printf '  - %s\n' "$detail" >&2
  done
  printf '\n' >&2
  printf 'Required strict mode per D2:\n' >&2
  printf '  set -euo pipefail\n' >&2
  printf '  IFS=$'"'"'\n\t'"'"'\n' >&2
  printf 'OR:\n' >&2
  printf '  source "$(dirname "$0")/.lib.sh"\n' >&2
  printf '  enable_strict_mode\n' >&2
  printf '\n' >&2
  exit 1
fi

if [ "$warnings" -gt 0 ]; then
  if [ "$STRICT_EXIT_CODES" -eq 1 ]; then
    # With --strict-exit-codes, non-standard codes are violations
    log_error "Error validation: $warnings exit code violation(s) found"
    for detail in "${warning_details[@]}"; do
      printf '  - %s\n' "$detail" >&2
    done
    printf '\n' >&2
    printf 'Use EXIT_* constants from .lib.sh (D3):\n' >&2
    printf '  EXIT_USAGE=2, EXIT_CONFIG=3, EXIT_DEPENDENCY=4,\n' >&2
    printf '  EXIT_NETWORK=5, EXIT_TIMEOUT=6, EXIT_INTERNAL=20\n' >&2
    printf '\n' >&2
    printf 'See: docs/projects/_archived/2025/shell-and-script-tooling/erd.md D3\n' >&2
    exit 1
  else
    # Without flag, just warn
    log_warn "Error validation: $warnings warning(s)"
    for detail in "${warning_details[@]}"; do
      printf '  - %s\n' "$detail" >&2
    done
    printf '\n' >&2
    printf 'Consider using EXIT_* constants from .lib.sh (D3):\n' >&2
    printf '  EXIT_USAGE=2, EXIT_CONFIG=3, EXIT_DEPENDENCY=4,\n' >&2
    printf '  EXIT_NETWORK=5, EXIT_TIMEOUT=6, EXIT_INTERNAL=20\n' >&2
    printf '\n' >&2
  fi
fi

log_info "Error validation: OK (${#scripts[@]} scripts validated, $warnings warnings)"
exit 0

