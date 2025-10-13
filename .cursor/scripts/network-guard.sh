#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Network guard validator — ensures scripts never perform direct network requests
# Validates D4/D5 portability policy: network must go through .lib-net.sh seam

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

VERSION="0.1.0"

# Default values
PATHS="${PATHS:-.cursor/scripts}"

usage() {
  print_help_header "network-guard.sh" "$VERSION" "Validate no direct network tool usage"
  print_usage "network-guard.sh [OPTIONS]"
  
  print_options
  print_option "--paths CSV" "Comma-separated paths to validate" "$PATHS"
  print_option "--version" "Print version and exit"
  print_option "-h, --help" "Show this help and exit"
  
  cat <<'DETAILS'

Validation Rules:
  - Scripts MUST NOT invoke curl, wget, gh, http directly
  - Network operations MUST use .lib-net.sh seam (net_request, net_fixture, net_guidance)
  - Comments and strings containing tool names are allowed
  - Validates D4 (Networkless Effects Seam) and D5 (Dependency Portability Policy)

DETAILS
  
  print_examples
  print_example "Validate default paths" "network-guard.sh"
  print_example "Validate specific directory" "network-guard.sh --paths .cursor/scripts"
  
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

# Gather shell scripts (excluding .lib-net.sh itself and test files)
IFS=',' read -ra path_array <<< "$PATHS"
scripts=()

for path in "${path_array[@]}"; do
  if [ -f "$path" ]; then
    # Single file
    scripts+=("$path")
  elif [ -d "$path" ]; then
    # Directory: find *.sh excluding .lib-net.sh and *.test.sh
    while IFS= read -r -d '' script; do
      case "$(basename "$script")" in
        .lib-net.sh|*.test.sh) ;;
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

# Network tools that must not be invoked directly
# Note: these should go through .lib-net.sh
BANNED_TOOLS=("curl" "wget" "gh" "http")

violations=0
violation_details=()

for script in "${scripts[@]}"; do
  # Skip this validator itself (contains tool names in help/definitions)
  if [ "$(basename "$script")" = "network-guard.sh" ]; then
    continue
  fi
  
  # Skip if file sources .lib-net.sh (approved usage)
  if grep -qE '^\s*source\s+.*\.lib-net\.sh' "$script" 2>/dev/null; then
    continue
  fi
  
  for tool in "${BANNED_TOOLS[@]}"; do
    # Look for tool invocation outside comments
    # Use word boundaries to catch all forms: curl ..., $(curl ...), `curl ...`, etc.
    # Exclude: require_cmd/have_cmd checks (just testing if tool exists)
    # Exclude: explicit suppressions (network-guard: disable=<tool>)
    
    # Check for suppression comment
    if grep -qE "network-guard:\s*disable=${tool}\b" "$script" 2>/dev/null; then
      continue  # Explicitly suppressed
    fi
    
    # Match: tool as word boundary (outside comments)
    if ! grep -qE "^[^#]*\b${tool}\b" "$script" 2>/dev/null; then
      continue  # Tool name not found, skip to next tool
    fi
    
    # Count actual invocations vs dependency checks
    total_occurrences=$(grep -cE "^[^#]*\b${tool}\b" "$script" 2>/dev/null || echo "0")
    total_occurrences=$(echo "$total_occurrences" | tr -d '\n' | head -c 10)
    dep_check_occurrences=$(grep -cE "^[^#]*(require_cmd|have_cmd)\s+${tool}\b" "$script" 2>/dev/null || echo "0")
    dep_check_occurrences=$(echo "$dep_check_occurrences" | tr -d '\n' | head -c 10)
    
    # If ALL occurrences are dependency checks, allow it
    if [ "$total_occurrences" -eq "$dep_check_occurrences" ]; then
      continue  # Only dependency checks, allowed
    fi
    
    # Real invocation found
    violations=$((violations + 1))
    violation_details+=("$script: direct '$tool' usage detected")
    break  # One violation per script is enough
  done
done

if [ "$violations" -gt 0 ]; then
  log_error "Network guard: $violations violation(s) found"
  for detail in "${violation_details[@]}"; do
    printf '  - %s\n' "$detail" >&2
  done
  printf '\n' >&2
  printf 'Scripts MUST use .lib-net.sh seam:\n' >&2
  printf '  source "$(dirname "$0")/.lib-net.sh"\n' >&2
  printf '  net_fixture "github/pr-123.json"  # Use fixtures\n' >&2
  printf '  net_guidance "Create PR" "https://..."  # Or print guidance\n' >&2
  printf '\n' >&2
  printf 'See: docs/projects/shell-and-script-tooling/erd.md D4/D5\n' >&2
  exit 1
fi

log_info "Network guard: OK (${#scripts[@]} scripts validated)"
exit 0

