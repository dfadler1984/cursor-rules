#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Staleness validator for .cursor/rules/*.mdc files
# Validates: lastReviewed date is within threshold
#
# Extracted from rules-validate.sh for Unix Philosophy compliance:
# - Do one thing: check date staleness only
# - Small & focused: ~130 lines vs 497 in monolithic validator
# - Composable: outputs to stdout, logs to stderr

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

VERSION="1.0.0"

# Default values
OUTPUT_FORMAT="text"  # text|json
FAIL_ON_STALE=0
STALE_DAYS=90
stale_count=0

usage() {
  print_help_header "rules-validate-staleness.sh" "$VERSION" "Validate lastReviewed staleness in rule files"
  print_usage "rules-validate-staleness.sh [OPTIONS] <file>..."
  
  print_options
  print_option "--stale-days DAYS" "Staleness threshold in days" "$STALE_DAYS"
  print_option "--fail-on-stale" "Exit non-zero if stale files found"
  print_option "--format FORMAT" "Output format: text|json" "text"
  print_option "--version" "Print version and exit"
  print_option "-h, --help" "Show this help and exit"
  
  cat <<'DETAILS'

Staleness Check:
  - Compares lastReviewed date to current date
  - Reports if difference exceeds threshold (default: 90 days)
  - Missing lastReviewed field is silently skipped
  - Invalid date format is silently skipped

DETAILS
  
  print_examples
  print_example "Check with default threshold" "rules-validate-staleness.sh file.mdc"
  print_example "Check with 30-day threshold" "rules-validate-staleness.sh --stale-days 30 file.mdc"
  print_example "Fail on stale files" "rules-validate-staleness.sh --fail-on-stale file.mdc"
  print_example "JSON output" "rules-validate-staleness.sh --format json file.mdc"
  
  print_exit_codes
}

# Extract front matter (first YAML block between ---)
extract_front_matter() {
  local file="$1"
  awk 'BEGIN{inside=0} /^---[ \t]*$/{ if(inside==0){inside=1; next}else{ exit } } inside==1{ print }' "$file"
}

# Check staleness of a file
check_staleness() {
  local file="$1"
  local fm last ln
  
  fm="$(extract_front_matter "$file")"
  last="$(printf '%s\n' "$fm" | awk '$1=="lastReviewed:"{sub(/^lastReviewed:[ \t]*/, ""); print; exit}')"
  
  # Skip if no lastReviewed field
  [ -z "$last" ] && return 0
  
  # Get line number for reporting
  ln=$(awk 'BEGIN{inside=0} \
    /^---[ \t]*$/{ if(inside==0){inside=1; next}else{ exit } } \
    inside==1 && $1=="lastReviewed:"{ print NR; exit }' "$file")
  
  # Parse date (macOS BSD date compatible)
  local now ts days
  now=$(date -u +%s)
  
  # Try to parse date; skip if invalid format
  ts=$(date -u -j -f "%Y-%m-%d" "$last" +%s 2>/dev/null || true)
  [ -z "$ts" ] && return 0
  
  # Calculate age in days
  days=$(( (now - ts) / 86400 ))
  
  # Report if stale
  if [ "$days" -gt "$STALE_DAYS" ]; then
    stale_count=$((stale_count + 1))
    
    if [ "$OUTPUT_FORMAT" != "json" ]; then
      printf "%s:%s: stale lastReviewed (> %dd old, last reviewed %dd ago)\n" \
        "$file" "${ln:-1}" "$STALE_DAYS" "$days"
    fi
  fi
}

# Parse arguments
FILES=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --stale-days)
      STALE_DAYS="${2:-}"
      if ! [[ "$STALE_DAYS" =~ ^[0-9]+$ ]]; then
        die "$EXIT_USAGE" "--stale-days must be a positive integer"
      fi
      shift 2
      ;;
    --fail-on-stale)
      FAIL_ON_STALE=1
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

# Check each file
for file in "${FILES[@]}"; do
  if [ ! -f "$file" ]; then
    log_warn "File not found: $file"
    continue
  fi
  
  check_staleness "$file"
done

# Output results
if [ "$OUTPUT_FORMAT" = "json" ]; then
  # JSON output format
  cat <<EOF
{
  "files": ${#FILES[@]},
  "stale_files": $stale_count,
  "threshold_days": $STALE_DAYS,
  "status": "$([ $stale_count -eq 0 ] && echo "ok" || echo "stale")"
}
EOF
elif [ $stale_count -eq 0 ]; then
  log_info "Staleness check: OK (${#FILES[@]} file(s), threshold: ${STALE_DAYS}d)"
fi

# Exit with appropriate code
if [ $FAIL_ON_STALE -eq 1 ] && [ $stale_count -gt 0 ]; then
  exit 1
fi

exit 0

