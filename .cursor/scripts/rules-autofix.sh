#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Autofix tool for .cursor/rules/*.mdc files
# Fixes: CSV spacing in globs/overrides, alwaysApply casing
#
# Extracted from rules-validate.sh for Unix Philosophy compliance:
# - Do one thing: autofix formatting issues only
# - Small & focused: ~100 lines vs 497 in monolithic validator
# - Composable: in-place edits with optional dry-run

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

VERSION="1.0.0"

# Default values
DRY_RUN=0
fixed_count=0

usage() {
  print_help_header "rules-autofix.sh" "$VERSION" "Auto-fix formatting issues in rule files"
  print_usage "rules-autofix.sh [OPTIONS] <file>..."
  
  print_options
  print_option "--dry-run" "Show what would be fixed without modifying files"
  print_option "--version" "Print version and exit"
  print_option "-h, --help" "Show this help and exit"
  
  cat <<'DETAILS'

Fixes Applied:
  - CSV spacing: Remove spaces after commas in globs and overrides
    Example: "globs: *.ts, *.tsx" → "globs: *.ts,*.tsx"
  
  - Boolean casing: Normalize alwaysApply to lowercase unquoted
    Example: "alwaysApply: True" → "alwaysApply: true"
    Example: "alwaysApply: \"False\"" → "alwaysApply: false"

Note: Edits files in-place. Use --dry-run to preview changes.

DETAILS
  
  print_examples
  print_example "Fix single file" "rules-autofix.sh .cursor/rules/testing.mdc"
  print_example "Preview changes" "rules-autofix.sh --dry-run file.mdc"
  print_example "Fix all rules" "rules-autofix.sh .cursor/rules/*.mdc"
  
  print_exit_codes
}

# Autofix a single file
autofix_file() {
  local file="$1"
  
  if [ $DRY_RUN -eq 1 ]; then
    # Dry-run: check if fixes would be applied
    local has_csv_spaces has_wrong_casing
    has_csv_spaces=$(grep -E '^(globs|overrides):.*,\s+' "$file" || true)
    has_wrong_casing=$(grep -E '^alwaysApply:[[:space:]]*("?True"?|"?False"?)' "$file" | grep -vE 'alwaysApply: (true|false)$' || true)
    
    if [ -n "$has_csv_spaces" ] || [ -n "$has_wrong_casing" ]; then
      printf "%s: Would fix\n" "$file"
      [ -n "$has_csv_spaces" ] && echo "  - CSV spacing in globs/overrides"
      [ -n "$has_wrong_casing" ] && echo "  - alwaysApply casing"
      fixed_count=$((fixed_count + 1))
    fi
  else
    # Apply fixes in-place (macOS BSD sed requires backup suffix, use .bak then remove)
    sed -E -i .bak \
      -e '/^(globs|overrides):/ s/, */,/g' \
      -e 's/^alwaysApply:[[:space:]]*"?True"?[[:space:]]*$/alwaysApply: true/' \
      -e 's/^alwaysApply:[[:space:]]*"?False"?[[:space:]]*$/alwaysApply: false/' \
      "$file"
    
    # Remove backup file
    rm -f "${file}.bak"
    
    fixed_count=$((fixed_count + 1))
    log_info "Fixed: $file"
  fi
}

# Parse arguments
FILES=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
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

# Process each file
for file in "${FILES[@]}"; do
  if [ ! -f "$file" ]; then
    log_warn "File not found: $file"
    continue
  fi
  
  autofix_file "$file"
done

# Summary
if [ $DRY_RUN -eq 1 ]; then
  if [ $fixed_count -eq 0 ]; then
    log_info "Dry-run: No fixes needed (${#FILES[@]} file(s))"
  else
    log_info "Dry-run: Would fix $fixed_count of ${#FILES[@]} file(s)"
  fi
else
  if [ $fixed_count -gt 0 ]; then
    log_info "Autofix complete: Fixed $fixed_count of ${#FILES[@]} file(s)"
  else
    log_info "Autofix: No changes needed (${#FILES[@]} file(s))"
  fi
fi

exit 0

