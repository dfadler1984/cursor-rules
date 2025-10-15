#!/usr/bin/env bash
# compliance-dashboard.sh
# Aggregate compliance metrics into dashboard

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=.lib.sh
source "$SCRIPT_DIR/.lib.sh"

VERSION="0.1.0"

usage() {
  print_help_header "compliance-dashboard.sh" "$VERSION" "Aggregate compliance metrics into a dashboard view"
  print_usage "compliance-dashboard.sh [OPTIONS]"
  
  print_options
  print_option "--limit N" "Number of commits to analyze" "100"
  print_option "-h, --help" "Show this help and exit"
  
  print_examples
  print_example "Show dashboard for last 100 commits" "compliance-dashboard.sh"
  print_example "Show dashboard for last 50 commits" "compliance-dashboard.sh --limit 50"
  
  print_exit_codes
}

# Defaults
LIMIT=100

# Parse args
while [ $# -gt 0 ]; do
  case "$1" in
    --limit)
      LIMIT="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die 2 "Unknown argument: $1"
      ;;
  esac
done

# Header
echo "═══════════════════════════════════════════════════════════════"
echo "            RULES COMPLIANCE DASHBOARD"
echo "            Generated: $(date '+%Y-%m-%d %H:%M:%S')"
echo "═══════════════════════════════════════════════════════════════"
echo

# Script Usage
if [[ -x "$SCRIPT_DIR/check-script-usage.sh" ]]; then
  echo "📊 Script Usage (Commit Messages)"
  "$SCRIPT_DIR/check-script-usage.sh" --limit "$LIMIT" 2>&1 | sed 's/^/   /'
  echo
fi

# TDD Compliance
if [[ -x "$SCRIPT_DIR/check-tdd-compliance.sh" ]]; then
  echo "📊 TDD Compliance (Spec Changes)"
  "$SCRIPT_DIR/check-tdd-compliance.sh" --limit "$LIMIT" 2>&1 | sed 's/^/   /'
  echo
fi

# Branch Naming
branch_rate=0
if [[ -x "$SCRIPT_DIR/check-branch-names.sh" ]]; then
  echo "📊 Branch Naming"
  output=$("$SCRIPT_DIR/check-branch-names.sh" 2>&1)
  echo "$output" | sed 's/^/   /'
  branch_rate=$(echo "$output" | grep "Branch naming compliance:" | grep -oE '[0-9]+' | head -1)
  echo
fi

# Overall Score
echo "───────────────────────────────────────────────────────────────"
echo

# Extract rates
script_rate=$(bash "$SCRIPT_DIR/check-script-usage.sh" --limit "$LIMIT" 2>&1 | grep "Script usage rate:" | grep -oE '[0-9]+' | head -1)
tdd_rate=$(bash "$SCRIPT_DIR/check-tdd-compliance.sh" --limit "$LIMIT" 2>&1 | grep "TDD compliance rate:" | grep -oE '[0-9]+' | head -1)

overall=$(( (script_rate + tdd_rate + branch_rate) / 3 ))

echo "Overall Compliance Score: ${overall}%"
echo

if [[ "$overall" -ge 90 ]]; then
  echo "✅ Overall compliance MEETS TARGET (>90%)"
else
  echo "⚠️  Overall compliance BELOW TARGET (target: >90%)"
fi

echo
echo "For detailed analysis, see individual checker outputs."

exit 0
