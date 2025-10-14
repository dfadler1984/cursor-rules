#!/usr/bin/env bash
set -euo pipefail

# Rules validator orchestrator — calls focused validation scripts
# Maintains backward compatibility with original rules-validate.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source shared library
# shellcheck source=.cursor/scripts/.lib.sh
. "$SCRIPT_DIR/.lib.sh"

enable_strict_mode

# Logging function that writes to both stderr and console file if set
log_with_console() {
  local msg="$1"
  log_info "$msg"
  if [ -n "${CONSOLE_OUT:-}" ] && [ -f "${CONSOLE_OUT:-}" ]; then
    printf "%s\n" "$msg" >> "$CONSOLE_OUT"
  fi
}

# Default values
RULES_DIR="$ROOT_DIR/.cursor/rules"
OUTPUT_FORMAT="text"
FAIL_ON_MISSING_REFS=0
FAIL_ON_STALE=0
STALE_DAYS=90
AUTO_FIX=0
REPORT_FLAG=0
REPORT_OUT=""
CONSOLE_OUT=""
MODE=""
REVIEWS_DIR="$ROOT_DIR/docs/reviews"
LIST_ONLY=0

print_help() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Orchestrator that validates rule files by calling focused validation scripts.

Validates rule files under .cursor/rules/*.mdc for:
  - Required front matter fields and formats
  - CSV spacing and brace expansion in globs/overrides
  - Boolean casing for alwaysApply
  - Deprecated references
  - Missing markdown references
  - Staleness (lastReviewed age)

Options:
  --list                    List all rule files and exit
  --dir <path>              Rules directory (default: .cursor/rules)
  --format text|json        Output format (default: text)
  --fail-on-missing-refs    Fail on unresolved references
  --fail-on-stale           Fail on stale rules (> ${STALE_DAYS}d)
  --stale-days <n>          Staleness threshold in days (default: 90)
  --autofix                 Auto-fix issues where possible
  --report                  Generate report file
  --report-out <path>       Report output path
  --write-console-out <path> Console output path
  --mode report|console|both Output mode
  --reviews-dir <path>      Reviews directory path
  -h, --help                Show this help

Examples:
  # Validate all rules
  rules-validate.sh
  
  # List all rule files
  rules-validate.sh --list
  
  # Validate with JSON output
  rules-validate.sh --format json
  
  # Autofix issues
  rules-validate.sh --autofix
  
  # Strict validation
  rules-validate.sh --fail-on-missing-refs --fail-on-stale

Exit Codes:
  0   Success
  2   Usage error
  20  Internal error

For more details, see docs/projects/_archived/2025/shell-and-script-tooling/erd.md
EOF
}

list_rule_files() {
  find "$RULES_DIR" -type f -name "*.mdc" | sort
}

main() {
  # Parse arguments
  while [ $# -gt 0 ]; do
    case "$1" in
      --list)
        LIST_ONLY=1
        shift
        ;;
      --dir)
        RULES_DIR="$2"
        shift 2
        ;;
      --format)
        OUTPUT_FORMAT="$2"
        shift 2
        ;;
      --fail-on-missing-refs)
        FAIL_ON_MISSING_REFS=1
        shift
        ;;
      --fail-on-stale)
        FAIL_ON_STALE=1
        shift
        ;;
      --stale-days)
        STALE_DAYS="$2"
        shift 2
        ;;
      --autofix)
        AUTO_FIX=1
        shift
        ;;
      --report)
        REPORT_FLAG=1
        shift
        ;;
      --report-out)
        REPORT_OUT="$2"
        shift 2
        ;;
      --write-console-out)
        CONSOLE_OUT="$2"
        shift 2
        ;;
      --mode)
        MODE="$2"
        shift 2
        ;;
      --reviews-dir)
        REVIEWS_DIR="$2"
        shift 2
        ;;
      -h|--help)
        print_help
        exit 0
        ;;
      *)
        die "$EXIT_USAGE" "Unknown option: $1"
        ;;
    esac
  done

  # List mode
  if [ "$LIST_ONLY" -eq 1 ]; then
    list_rule_files
    exit 0
  fi

  # Verify rules directory exists
  if [ ! -d "$RULES_DIR" ]; then
    die "$EXIT_CONFIG" "No rules directory found at $RULES_DIR"
  fi

  # Setup console output file if needed
  if [ -n "$MODE" ]; then
    case "$MODE" in
      console|both)
        if [ -z "$CONSOLE_OUT" ]; then
          CONSOLE_OUT="$ROOT_DIR/docs/rules-validate-$(date -u +"%Y-%m-%dT%H-%M-%SZ").txt"
        fi
        mkdir -p "$(dirname "$CONSOLE_OUT")" || true
        : > "$CONSOLE_OUT" || true
        ;;
      report)
        # Report-only mode
        ;;
    esac
  elif [ -n "$CONSOLE_OUT" ]; then
    # --write-console-out was specified without --mode
    mkdir -p "$(dirname "$CONSOLE_OUT")" || true
    : > "$CONSOLE_OUT" || true
  fi

  # Get list of rule files
  local files=()
  while IFS= read -r file; do
    files+=("$file")
  done < <(list_rule_files)

  if [ "${#files[@]}" -eq 0 ]; then
    if [ "$OUTPUT_FORMAT" = "json" ]; then
      printf '{"totalIssues": 0}\n'
    else
      log_info "No rule files found in $RULES_DIR"
    fi
    exit 0
  fi

  # Track aggregated exit code
  local exit_code=0

  # Step 1: Auto-fix if requested
  if [ "$AUTO_FIX" -eq 1 ]; then
    if [ "$OUTPUT_FORMAT" != "json" ]; then
      log_with_console "Running autofix..."
    fi
    if ! bash "$SCRIPT_DIR/rules-autofix.sh" "${files[@]}"; then
      exit_code=1
    fi
  fi

  # Step 2: Validate front matter
  if [ "$OUTPUT_FORMAT" != "json" ]; then
    log_with_console "Validating front matter..."
  fi
  if ! bash "$SCRIPT_DIR/rules-validate-frontmatter.sh" --format "$OUTPUT_FORMAT" "${files[@]}" 2>&1 | tee -a "${CONSOLE_OUT:-/dev/null}"; then
    exit_code=1
  fi

  # Step 3: Validate format (CSV, booleans, deprecated refs, structure)
  if [ "$OUTPUT_FORMAT" != "json" ]; then
    log_with_console "Validating format..."
  fi
  if ! bash "$SCRIPT_DIR/rules-validate-format.sh" --format "$OUTPUT_FORMAT" "${files[@]}" 2>&1 | tee -a "${CONSOLE_OUT:-/dev/null}"; then
    exit_code=1
  fi

  # Step 4: Validate references
  if [ "$OUTPUT_FORMAT" != "json" ]; then
    log_with_console "Validating references..."
  fi
  local refs_flags=("--format" "$OUTPUT_FORMAT")
  if [ "$FAIL_ON_MISSING_REFS" -eq 1 ]; then
    refs_flags+=("--fail-on-missing")
  fi
  if ! bash "$SCRIPT_DIR/rules-validate-refs.sh" "${refs_flags[@]}" "${files[@]}" 2>&1 | tee -a "${CONSOLE_OUT:-/dev/null}"; then
    exit_code=1
  fi

  # Step 5: Check staleness
  if [ "$OUTPUT_FORMAT" != "json" ]; then
    log_with_console "Checking staleness..."
  fi
  local staleness_flags=("--format" "$OUTPUT_FORMAT" "--stale-days" "$STALE_DAYS")
  if [ "$FAIL_ON_STALE" -eq 1 ]; then
    staleness_flags+=("--fail-on-stale")
  fi
  if ! bash "$SCRIPT_DIR/rules-validate-staleness.sh" "${staleness_flags[@]}" "${files[@]}" 2>&1 | tee -a "${CONSOLE_OUT:-/dev/null}"; then
    exit_code=1
  fi

  # Step 6: Generate report if requested
  if [ "$REPORT_FLAG" -eq 1 ] || [ -n "$REPORT_OUT" ] || [ "$MODE" = "report" ] || [ "$MODE" = "both" ]; then
    local report_path
    if [ -z "$REPORT_OUT" ]; then
      mkdir -p "$REVIEWS_DIR"
      report_path="$REVIEWS_DIR/review-$(date -u +"%Y-%m-%d").md"
    else
      mkdir -p "$(dirname "$REPORT_OUT")"
      report_path="$REPORT_OUT"
    fi

    {
      printf '# Rules Review — %s\n\n' "$(date -u +"%Y-%m-%d")"
      printf '## Summary\n\n'
      printf 'Orchestrator validation complete.\n\n'
      printf 'See individual validator outputs for details:\n'
      printf '%s\n' '- rules-validate-frontmatter.sh'
      printf '%s\n' '- rules-validate-format.sh'
      printf '%s\n' '- rules-validate-refs.sh'
      printf '%s\n' '- rules-validate-staleness.sh'
    } > "$report_path"

    log_with_console "Report written to: $report_path"
  fi

  # Final result
  if [ "$exit_code" -eq 0 ]; then
    if [ "$OUTPUT_FORMAT" = "json" ]; then
      printf '{"totalIssues": 0}\n'
    else
      log_with_console "rules-validate: OK"
    fi
    exit 0
  else
    if [ "$OUTPUT_FORMAT" = "json" ]; then
      printf '{"totalIssues": 1}\n'
    else
      log_with_console "rules-validate: validation failed (see focused validator outputs above)"
    fi
    exit 1
  fi
}

main "$@"
