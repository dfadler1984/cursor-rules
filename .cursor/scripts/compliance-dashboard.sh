#!/usr/bin/env bash
# compliance-dashboard.sh
# Aggregate compliance metrics into dashboard

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIMIT=100

# Help
if [[ "${1:-}" == "--help" ]]; then
  cat << EOF
compliance-dashboard.sh - Generate compliance dashboard

Usage:
  compliance-dashboard.sh [--limit N]

Flags:
  --limit N    Number of commits (default: 100)
  --help       Show this help
EOF
  exit 0
fi

# Parse --limit
if [[ "${1:-}" == "--limit" ]] && [[ -n "${2:-}" ]]; then
  LIMIT="$2"
fi

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
