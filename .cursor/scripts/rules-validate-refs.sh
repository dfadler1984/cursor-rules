#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Reference validator for .cursor/rules/*.mdc files
# Validates: markdown links point to existing files
#
# Extracted from rules-validate.sh for Unix Philosophy compliance:
# - Do one thing: validate references only
# - Small & focused: ~120 lines vs 497 in monolithic validator
# - Composable: outputs to stdout, logs to stderr

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/.lib.sh"

VERSION="1.0.0"

# Default values
OUTPUT_FORMAT="text"  # text|json
FAIL_ON_MISSING=0
missing_refs_count=0

usage() {
  print_help_header "rules-validate-refs.sh" "$VERSION" "Validate references in rule files"
  print_usage "rules-validate-refs.sh [OPTIONS] <file>..."
  
  print_options
  print_option "--fail-on-missing" "Exit non-zero if references are missing"
  print_option "--format FORMAT" "Output format: text|json" "text"
  print_option "--version" "Print version and exit"
  print_option "-h, --help" "Show this help and exit"
  
  cat <<'DETAILS'

Validation:
  - Checks markdown links [text](path) point to existing files
  - Ignores http://, https://, mailto:, and # anchors
  - Strips anchors (#section) before validating file existence
  - Resolves paths relative to the rule file location

DETAILS
  
  print_examples
  print_example "Validate single file" "rules-validate-refs.sh .cursor/rules/testing.mdc"
  print_example "Fail on missing refs" "rules-validate-refs.sh --fail-on-missing file.mdc"
  print_example "JSON output" "rules-validate-refs.sh --format json file.mdc"
  
  print_exit_codes
}

# Check references in a file
check_references() {
  local file="$1"
  local base_dir
  base_dir="$(cd "$(dirname "$file")" && pwd)"
  
  # Extract markdown links [text](path), excluding http/mailto/anchors
  local candidates
  candidates=$(sed -nE 's/.*\[[^]]*\]\(([^)#]+)\).*/\1/p' "$file" | \
               sed -E '/^https?:\/\//d; /^mailto:/d; /^#/d' || true)
  
  # Get unique references
  local all
  all="$(printf '%s\n' "$candidates" | sed '/^\s*$/d' | sort -u)"
  
  # Validate each reference
  local rel abs trimmed
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    
    # Strip anchors
    rel="${rel%%#*}"
    
    # Ignore external references
    case "$rel" in
      http://*|https://*|mailto:*|\#*) continue;;
    esac
    
    # Trim spaces and trailing punctuation
    trimmed="$(printf '%s' "$rel" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//; s/[)>]+$//')"
    [ -n "$trimmed" ] || continue
    
    # Resolve absolute path
    if [[ "$trimmed" = /* ]]; then
      abs="$trimmed"
    elif [[ "$trimmed" == ./* || "$trimmed" == ../* ]]; then
      abs="$base_dir/$trimmed"
    else
      abs="$ROOT_DIR/$trimmed"
    fi
    
    # Check if file exists
    if [ ! -e "$abs" ]; then
      missing_refs_count=$((missing_refs_count + 1))
      
      if [ "$FAIL_ON_MISSING" -eq 1 ] || [ "$OUTPUT_FORMAT" != "json" ]; then
        printf "%s:1: unresolved reference: %s\n" "$file" "$trimmed"
      fi
    fi
  done <<< "$all"
}

# Parse arguments
FILES=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --fail-on-missing)
      FAIL_ON_MISSING=1
      shift
      ;;
    --format)
      OUTPUT_FORMAT="${2:-}"
      if [ "$OUTPUT_FORMAT" != "text" ] && [ "$OUTPUT_FORMAT" != "json" ]; then
        die "$EXIT_USAGE" "--format must be 'text' or 'json'"
      fi
      shift 2
      ;;
    --version)
      printf '%s\n' "$VERSION"
      exit 0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      die "$EXIT_USAGE" "Unknown argument: $1"
      ;;
    *)
      FILES+=("$1")
      shift
      ;;
  esac
done

# Validate input
if [ "${#FILES[@]}" -eq 0 ]; then
  die "$EXIT_USAGE" "No files specified. Usage: $(basename "$0") <file>..."
fi

# Validate each file
for file in "${FILES[@]}"; do
  if [ ! -f "$file" ]; then
    log_warn "File not found: $file"
    continue
  fi
  
  check_references "$file"
done

# Output results
if [ "$OUTPUT_FORMAT" = "json" ]; then
  # JSON output format
  cat <<EOF
{
  "files": ${#FILES[@]},
  "missing_refs": $missing_refs_count,
  "status": "$([ $missing_refs_count -eq 0 ] && echo "ok" || echo "missing_references")"
}
EOF
elif [ $missing_refs_count -eq 0 ]; then
  log_info "Reference validation: OK (${#FILES[@]} file(s))"
fi

# Exit with appropriate code
if [ $FAIL_ON_MISSING -eq 1 ] && [ $missing_refs_count -gt 0 ]; then
  exit 1
fi

exit 0

