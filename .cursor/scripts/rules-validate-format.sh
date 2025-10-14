#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Format validator for .cursor/rules/*.mdc files
# Validates: CSV spacing, boolean casing, deprecated refs, embedded front matter, duplicate headers
#
# Extracted from rules-validate.sh for Unix Philosophy compliance:
# - Do one thing: validate formatting and structure only
# - Small & focused: ~150 lines vs 497 in monolithic validator
# - Composable: outputs to stdout, logs to stderr

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

VERSION="1.0.0"

# Default values
OUTPUT_FORMAT="text"  # text|json
fail_count=0

usage() {
  print_help_header "rules-validate-format.sh" "$VERSION" "Validate formatting and structure in rule files"
  print_usage "rules-validate-format.sh [OPTIONS] <file>..."
  
  print_options
  print_option "--format FORMAT" "Output format: text|json" "text"
  print_option "--version" "Print version and exit"
  print_option "-h, --help" "Show this help and exit"
  
  cat <<'DETAILS'

Validates:
  - CSV fields (globs, overrides): no spaces after commas, no brace expansion {}
  - Boolean fields (alwaysApply): unquoted lowercase true|false
  - Deprecated references: warns about assistant-learning-log.mdc
  - Embedded front matter: only one --- pair allowed
  - Duplicate headers: only one top-level # header allowed

DETAILS
  
  print_examples
  print_example "Validate single file" "rules-validate-format.sh file.mdc"
  print_example "Validate all rules" "rules-validate-format.sh .cursor/rules/*.mdc"
  print_example "JSON output" "rules-validate-format.sh --format json file.mdc"
  
  print_exit_codes
}

# Report validation issue
report_issue() {
  local file="$1"
  local line="$2"
  local message="$3"
  
  if [ "$OUTPUT_FORMAT" != "json" ]; then
    printf "%s:%s: %s\n" "$file" "$line" "$message"
  fi
  
  fail_count=$((fail_count + 1))
}

# Check CSV and boolean formatting
check_csv_and_boolean() {
  local file="$1"
  
  # Use awk to validate CSV fields and boolean casing
  local issues
  issues="$(awk -v file="$file" '
    function report(ln,msg){ printf "%s:%d: %s\n", file, ln, msg }
    {
      if ($0 ~ /^(globs|overrides):/) {
        if ($0 ~ /,[[:space:]]+/) report(NR, "spaces around commas in CSV (globs/overrides)")
        if ($0 ~ /[{}]/) report(NR, "brace expansion {} not allowed in CSV (globs/overrides)")
      }
      if ($0 ~ /^alwaysApply:[[:space:]]*/) {
        line=$0
        sub(/^alwaysApply:[[:space:]]*/, "", line)
        if (line !~ /^(true|false)$/) report(NR, "alwaysApply must be unquoted lowercase true|false")
      }
    }
  ' "$file")"
  
  if [ -n "$issues" ]; then
    if [ "$OUTPUT_FORMAT" != "json" ]; then
      printf "%s\n" "$issues"
    fi
    local issue_count
    issue_count=$(printf "%s" "$issues" | awk 'END{print NR}')
    fail_count=$((fail_count + issue_count))
  fi
}

# Check for deprecated references
check_deprecated() {
  local file="$1"
  
  if grep -qE 'assistant-learning-log\.mdc' "$file" 2>/dev/null; then
    local line_nums
    line_nums=$(grep -nE 'assistant-learning-log\.mdc' "$file" | cut -d: -f1)
    
    while IFS= read -r ln; do
      [ -n "$ln" ] || continue
      report_issue "$file" "$ln" "deprecated reference: assistant-learning-log.mdc (use logging-protocol.mdc)"
    done <<< "$line_nums"
  fi
}

# Check for embedded front matter and duplicate headers
check_structure() {
  local file="$1"
  
  # Detect embedded front matter blocks beyond the first pair of ---
  local fm_issues
  fm_issues=$(awk -v file="$file" '
    BEGIN{sepCount=0; inCode=0}
    /^```/ { inCode = 1 - inCode; next }
    /^---[ \t]*$/ {
      if (!inCode) {
        sepCount++
        if (sepCount>2) { printf "%s:%d: embedded front matter block detected\n", file, NR }
      }
    }
  ' "$file")
  
  if [ -n "$fm_issues" ]; then
    if [ "$OUTPUT_FORMAT" != "json" ]; then
      printf "%s\n" "$fm_issues"
    fi
    local count
    count=$(printf "%s" "$fm_issues" | awk 'END{print NR}')
    fail_count=$((fail_count + count))
  fi
  
  # Detect duplicate top-level headers (# ...)
  local hdr_issues
  hdr_issues=$(awk -v file="$file" '
    BEGIN{firstSeen=0; inCode=0}
    /^```/ { inCode = 1 - inCode; next }
    /^# [^#]/ {
      if (!inCode) {
        if (firstSeen==0) { firstSeen=1 }
        else { printf "%s:%d: duplicate top-level header\n", file, NR }
      }
    }
  ' "$file")
  
  if [ -n "$hdr_issues" ]; then
    if [ "$OUTPUT_FORMAT" != "json" ]; then
      printf "%s\n" "$hdr_issues"
    fi
    local count
    count=$(printf "%s" "$hdr_issues" | awk 'END{print NR}')
    fail_count=$((fail_count + count))
  fi
}

# Parse arguments
FILES=()

while [ "$#" -gt 0 ]; do
  case "$1" in
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
  
  check_csv_and_boolean "$file"
  check_deprecated "$file"
  check_structure "$file"
done

# Output results
if [ "$OUTPUT_FORMAT" = "json" ]; then
  # JSON output format
  cat <<EOF
{
  "files": ${#FILES[@]},
  "issues": $fail_count,
  "status": "$([ $fail_count -eq 0 ] && echo "ok" || echo "format_errors")"
}
EOF
elif [ $fail_count -eq 0 ]; then
  log_info "Format validation: OK (${#FILES[@]} file(s))"
fi

# Exit with appropriate code
if [ $fail_count -gt 0 ]; then
  exit 1
fi

exit 0

