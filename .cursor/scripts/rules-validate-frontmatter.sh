#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Front matter validator for .cursor/rules/*.mdc files
# Validates: description, lastReviewed (YYYY-MM-DD), healthScore (content/usability/maintenance)
#
# Extracted from rules-validate.sh for Unix Philosophy compliance:
# - Do one thing: validate front matter fields only
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
  print_help_header "rules-validate-frontmatter.sh" "$VERSION" "Validate front matter in rule files"
  print_usage "rules-validate-frontmatter.sh [OPTIONS] <file>..."
  
  print_options
  print_option "--format FORMAT" "Output format: text|json" "text"
  print_option "--version" "Print version and exit"
  print_option "-h, --help" "Show this help and exit"
  
  cat <<'DETAILS'

Required Front Matter Fields:
  - description: Brief description of rule's purpose
  - lastReviewed: Date in YYYY-MM-DD format
  - healthScore:
      content: green|yellow|red
      usability: green|yellow|red
      maintenance: green|yellow|red

DETAILS
  
  print_examples
  print_example "Validate single file" "rules-validate-frontmatter.sh .cursor/rules/testing.mdc"
  print_example "Validate multiple files" "rules-validate-frontmatter.sh .cursor/rules/*.mdc"
  print_example "JSON output" "rules-validate-frontmatter.sh --format json file.mdc"
  
  print_exit_codes
}

# Extract front matter (first YAML block between ---)
extract_front_matter() {
  local file="$1"
  awk 'BEGIN{inside=0} /^---[ \t]*$/{ if(inside==0){inside=1; next}else{ exit } } inside==1{ print }' "$file"
}

# Report validation issue
report_issue() {
  local file="$1"
  local line="${2:-1}"
  local message="$3"
  
  if [ "$OUTPUT_FORMAT" != "json" ]; then
    printf "%s:%s: %s\n" "$file" "$line" "$message"
  fi
  
  fail_count=$((fail_count + 1))
}

# Validate required fields in front matter
validate_front_matter() {
  local file="$1"
  local fm
  fm="$(extract_front_matter "$file")"
  
  # Check description field
  if ! printf "%s\n" "$fm" | grep -qE '^description:'; then
    report_issue "$file" 1 'missing required field: description'
  fi
  
  # Check lastReviewed format (YYYY-MM-DD)
  if ! printf "%s\n" "$fm" | grep -qE '^lastReviewed:[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
    # Try to locate line number
    local ln
    ln="$(awk 'BEGIN{inside=0} /^---[ \t]*$/{ if(inside==0){inside=1; next}else{ exit } } inside==1 && $1=="lastReviewed:"{ print NR; exit }' "$file")"
    [ -z "$ln" ] && ln=1
    report_issue "$file" "$ln" 'missing or invalid lastReviewed (YYYY-MM-DD)'
  fi
  
  # Check healthScore structure
  if ! printf "%s\n" "$fm" | grep -qE '^healthScore:'; then
    report_issue "$file" 1 'missing healthScore'
  else
    # Check required healthScore dimensions
    for dimension in content usability maintenance; do
      if ! printf "%s\n" "$fm" | grep -qE "^[[:space:]]{2}$dimension:[[:space:]]*(green|yellow|red)"; then
        report_issue "$file" 1 "missing healthScore.$dimension"
      fi
    done
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
  
  validate_front_matter "$file"
done

# Output results
if [ "$OUTPUT_FORMAT" = "json" ]; then
  # JSON output format
  cat <<EOF
{
  "files": ${#FILES[@]},
  "issues": $fail_count,
  "status": "$([ $fail_count -eq 0 ] && echo "ok" || echo "failed")"
}
EOF
elif [ $fail_count -eq 0 ]; then
  log_info "Front matter validation: OK (${#FILES[@]} file(s))"
fi

# Exit with appropriate code
if [ $fail_count -gt 0 ]; then
  exit 1
fi

exit 0

