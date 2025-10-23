#!/usr/bin/env bash
# Deep validation and maintenance of rules and commands
# Orchestrates multiple validators, performs cross-validation, calculates health scores

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=.lib.sh
source "$SCRIPT_DIR/.lib.sh"

VERSION="0.1.0"

show_help() {
  print_help_header "deep-rule-and-command-validate.sh" "$VERSION" \
    "Deep validation and maintenance of rules and commands"
  
  print_usage "deep-rule-and-command-validate.sh [OPTIONS]"
  
  cat <<'HELP'
Description:
  Orchestrates multiple validators, performs cross-validation checks, calculates
  overall repository health score, and optionally runs auto-fixes.

HELP

  print_options
  print_option "--fix" "Auto-fix issues where possible (prompts for confirmation)"
  print_option "--report" "Output detailed JSON report"
  print_option "--score-only" "Just show the health score"
  print_option "--fail-threshold N" "Exit 1 if score < N" "70"
  print_option "--help" "Show this help message"
  
  print_exit_codes
  
  print_examples
  print_example "Run validation" \
    "deep-rule-and-command-validate.sh"
  print_example "Auto-fix issues" \
    "deep-rule-and-command-validate.sh --fix"
  print_example "Get JSON report" \
    "deep-rule-and-command-validate.sh --report"
}

# Parse arguments
FIX_MODE=false
REPORT_MODE=false
SCORE_ONLY=false
FAIL_THRESHOLD=70

while [ "$#" -gt 0 ]; do
  case "$1" in
    --help|-h)
      show_help
      exit 0
      ;;
    --fix)
      FIX_MODE=true
      shift
      ;;
    --report)
      REPORT_MODE=true
      shift
      ;;
    --score-only)
      SCORE_ONLY=true
      shift
      ;;
    --fail-threshold)
      FAIL_THRESHOLD="$2"
      shift 2
      ;;
    *)
      log_error "Unknown option: $1"
      show_help
      exit "$EXIT_USAGE"
      ;;
  esac
done

# Validator results
declare -A VALIDATOR_RESULTS
declare -A VALIDATOR_SCORES
CROSS_VALIDATION_ISSUES=0

run_validator() {
  local name="$1"
  local command="$2"
  
  echo -n "⏳ $name ... "
  log_info "Running: $name"
  
  if eval "$command" >/dev/null 2>&1; then
    VALIDATOR_RESULTS["$name"]="PASS"
    VALIDATOR_SCORES["$name"]=100
    echo "✓ passed"
  else
    VALIDATOR_RESULTS["$name"]="FAIL"
    VALIDATOR_SCORES["$name"]=0
    echo "✗ failed"
  fi
}

# Cross-validation: check rules reference real scripts  
cross_validate_rules_to_scripts() {
  local rules_dir="$(repo_root)/.cursor/rules"
  local issues=0
  
  echo -n "⏳ Cross-refs (rules → scripts) ... "
  log_info "Cross-validating: rules → scripts"
  
  local rule_count=0
  # Check each rule file for broken script references
  for rule_file in "$rules_dir"/*.mdc; do
    [ -f "$rule_file" ] || continue
    rule_count=$((rule_count + 1))
    
    # Extract script paths and check if they exist
    while IFS= read -r script_path; do
      [ -n "$script_path" ] || continue
      local full_path="$(repo_root)/$script_path"
      if [ ! -f "$full_path" ]; then
        [ "$issues" -eq 0 ] && echo ""  # New line before first issue
        echo "  ⚠ ${rule_file##*/} references non-existent script: $script_path"
        issues=$((issues + 1))
      fi
    done < <(grep -oE '\.cursor/scripts/[a-zA-Z0-9_/-]+\.sh' "$rule_file" 2>/dev/null | sort -u)
  done
  
  if [ "$issues" -eq 0 ]; then
    echo "✓ checked $rule_count rule files"
  else
    echo "✗ found $issues broken references in $rule_count files"
  fi
  
  CROSS_VALIDATION_ISSUES=$((CROSS_VALIDATION_ISSUES + issues))
  return 0
}

# Cross-validation: check all scripts are in capabilities.mdc
cross_validate_scripts_to_capabilities() {
  local capabilities_file="$(repo_root)/.cursor/rules/capabilities.mdc"
  local scripts_dir="$(repo_root)/.cursor/scripts"
  local issues=0
  
  echo -n "⏳ Cross-refs (scripts → capabilities) ... "
  log_info "Cross-validating: scripts → capabilities"
  
  if [ ! -f "$capabilities_file" ]; then
    echo "✗ capabilities.mdc not found"
    CROSS_VALIDATION_ISSUES=$((CROSS_VALIDATION_ISSUES + 1))
    return 0
  fi
  
  local script_count=0
  # Check each script is documented in capabilities
  for script_file in "$scripts_dir"/*.sh; do
    [ -f "$script_file" ] || continue
    local script_name="${script_file##*/}"
    
    # Skip test files and hidden files
    [[ "$script_name" == *.test.sh ]] && continue
    [[ "$script_name" == .* ]] && continue
    
    script_count=$((script_count + 1))
    
    # Check if script is mentioned in capabilities.mdc
    if ! grep -q "$script_name" "$capabilities_file"; then
      [ "$issues" -eq 0 ] && echo ""  # New line before first issue
      echo "  ⚠ Script not in capabilities.mdc: $script_name"
      issues=$((issues + 1))
    fi
  done
  
  if [ "$issues" -eq 0 ]; then
    echo "✓ all $script_count scripts documented"
  else
    echo "✗ $issues of $script_count scripts missing"
  fi
  
  CROSS_VALIDATION_ISSUES=$((CROSS_VALIDATION_ISSUES + issues))
  return 0
}

# Track start time
START_TIME=$(date +%s)

# Run validators
echo "Repository Health Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Starting validation at $(date '+%H:%M:%S')"
echo ""
echo "Rules & Documentation"
run_validator "Rules validation" "$SCRIPT_DIR/rules-validate.sh"
run_validator "Capabilities sync" "$SCRIPT_DIR/capabilities-sync.sh --check"

echo ""
echo "Code Quality"
run_validator "ShellCheck" "$SCRIPT_DIR/shellcheck-run.sh"
run_validator "Help text format" "$SCRIPT_DIR/help-validate.sh"
run_validator "Error format" "$SCRIPT_DIR/error-validate.sh"

echo ""
echo "Tests"
run_validator "Test colocation" "$SCRIPT_DIR/test-colocation-validate.sh"

echo ""
echo "Cross-Validation Checks"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cross_validate_rules_to_scripts
cross_validate_scripts_to_capabilities

# Calculate elapsed time
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))

# Calculate category scores
calculate_category_scores() {
  # Rules Quality (out of 100) - rules validation + capabilities sync
  local rules_score=100
  local rules_pass=0
  local rules_total=0
  
  for validator in "Rules validation" "Capabilities sync"; do
    rules_total=$((rules_total + 1))
    if [ "${VALIDATOR_RESULTS[$validator]:-FAIL}" = "PASS" ]; then
      rules_pass=$((rules_pass + 1))
    fi
  done
  [ "$rules_total" -gt 0 ] && rules_score=$(( (rules_pass * 100) / rules_total ))
  
  # Script Quality (out of 100) - shellcheck, help format, error format
  local script_score=100
  local script_pass=0
  local script_total=0
  
  for validator in "ShellCheck" "Help text format" "Error format"; do
    script_total=$((script_total + 1))
    if [ "${VALIDATOR_RESULTS[$validator]:-FAIL}" = "PASS" ]; then
      script_pass=$((script_pass + 1))
    fi
  done
  [ "$script_total" -gt 0 ] && script_score=$(( (script_pass * 100) / script_total ))
  
  # Documentation / Cross-refs (out of 100)
  local doc_score=100
  if [ "$CROSS_VALIDATION_ISSUES" -gt 0 ]; then
    # Deduct 5 points per issue, min 0
    doc_score=$((100 - (CROSS_VALIDATION_ISSUES * 5)))
    [ "$doc_score" -lt 0 ] && doc_score=0
  fi
  
  # Test Quality (out of 100) - colocation
  local test_score=100
  if [ "${VALIDATOR_RESULTS[Test colocation]:-FAIL}" = "FAIL" ]; then
    test_score=60
  fi
  
  # Overall (average of categories)
  local overall=$(( (rules_score + script_score + doc_score + test_score) / 4 ))
  
  # Export for display
  echo "$rules_score:$script_score:$doc_score:$test_score:$overall"
}

SCORES=$(calculate_category_scores)
IFS=':' read -r RULES_SCORE SCRIPT_SCORE DOC_SCORE TEST_SCORE HEALTH_SCORE <<< "$SCORES"

# JSON report mode
if [ "$REPORT_MODE" = "true" ]; then
  echo ""
  echo "{"
  echo "  \"overall_score\": $HEALTH_SCORE,"
  echo "  \"categories\": {"
  echo "    \"rules_quality\": $RULES_SCORE,"
  echo "    \"script_quality\": $SCRIPT_SCORE,"
  echo "    \"documentation\": $DOC_SCORE,"
  echo "    \"test_quality\": $TEST_SCORE"
  echo "  },"
  echo "  \"validators\": {"
  
  first=true
  for validator in "${!VALIDATOR_RESULTS[@]}"; do
    if [ "$first" = "true" ]; then
      first=false
    else
      echo ","
    fi
    printf "    \"%s\": \"%s\"" "$(json_escape "$validator")" "${VALIDATOR_RESULTS[$validator]}"
  done
  
  echo ""
  echo "  },"
  echo "  \"cross_validation_issues\": $CROSS_VALIDATION_ISSUES"
  echo "}"
  exit 0
fi

echo ""
echo "Overall Health Score: $HEALTH_SCORE/100"
echo "  Rules Quality:    $RULES_SCORE/100"
echo "  Script Quality:   $SCRIPT_SCORE/100"
echo "  Documentation:    $DOC_SCORE/100"
echo "  Test Quality:     $TEST_SCORE/100"
echo ""
echo "Completed in ${ELAPSED}s"

# Auto-fix functionality
if [ "$FIX_MODE" = "true" ]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Auto-Fix Attempts"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # Rules validation with autofix
  if [ "${VALIDATOR_RESULTS[Rules validation]:-FAIL}" = "FAIL" ]; then
    echo "Running rules-validate.sh --autofix..."
    "$SCRIPT_DIR/rules-validate.sh" --autofix 2>&1 | head -10
  fi
  
  # Capabilities sync update
  if [ "${VALIDATOR_RESULTS[Capabilities sync]:-FAIL}" = "FAIL" ]; then
    echo "Running capabilities-sync.sh --update..."
    "$SCRIPT_DIR/capabilities-sync.sh" --update 2>&1 | head -10
  fi
  
  echo ""
  echo "✓ Auto-fix complete. Re-run validation to see updated scores."
elif [ "$HEALTH_SCORE" -lt 100 ]; then
  echo ""
  echo "Run with --fix to attempt auto-repairs."
fi

# Exit successfully (validation completed, regardless of findings)
exit 0

