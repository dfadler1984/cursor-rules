#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Network seam validator — ensures scripts provide test seams for network calls
# Validates D4: test isolation via network seams (CURL_CMD, JQ_CMD, etc.)

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

VERSION="0.1.0"

# Default values
PATHS="${PATHS:-.cursor/scripts}"

usage() {
  print_help_header "network-guard.sh" "$VERSION" "Validate network test seams are available"
  print_usage "network-guard.sh [OPTIONS]"
  
  print_options
  print_option "--paths CSV" "Comma-separated paths to validate" "$PATHS"
  print_option "--version" "Print version and exit"
  print_option "-h, --help" "Show this help and exit"
  
  cat <<'DETAILS'

Validation Rules (D4 - Test Isolation):
  - Scripts that use curl/network tools SHOULD provide test seams (CURL_CMD, JQ_CMD)
  - Production code CAN make API calls (e.g., pr-create.sh, checks-status.sh)
  - Tests MUST use seams to inject fixtures (never live API calls)
  - Currently: informational only (logs scripts with network usage)

Note: This validator is being refined. Currently it identifies scripts with network
      usage but does not fail. Future: validate test files use seams.

DETAILS
  
  print_examples
  print_example "Check which scripts use network tools" "network-guard.sh"
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
  log_info "Network usage found in $violations script(s) (informational):"
  for detail in "${violation_details[@]}"; do
    printf '  - %s\n' "$detail" >&2
  done
  printf '\n' >&2
  printf 'Note: Production scripts CAN make network calls (D4 allows this).\n' >&2
  printf 'Ensure tests for these scripts use seams:\n' >&2
  printf '  CURL_CMD=cat  # Inject fixtures\n' >&2
  printf '  JQ_CMD=jq     # Use real jq for parsing\n' >&2
  printf '\n' >&2
  printf 'See: docs/projects/networkless-scripts/erd.md (test isolation)\n' >&2
  # Exit 0 - this is informational, not a hard failure
  exit 0
fi

log_info "Network guard: OK — no network usage found in ${#scripts[@]} scripts"
exit 0

