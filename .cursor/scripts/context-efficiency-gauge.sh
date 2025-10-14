#!/usr/bin/env bash
# Context Efficiency Gauge — orchestrator for score computation and formatting
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=.cursor/scripts/.lib.sh
source "$SCRIPT_DIR/.lib.sh"

enable_strict_mode

# Default values
scope_concrete="true"
rules_count=0
clarification_loops=0
user_issues=""
output_format="line"

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Assess context efficiency using qualitative heuristics and provide recommendations.

OPTIONS:
  --scope-concrete BOOL     Is task scope narrow and concrete? (true|false, default: true)
  --rules COUNT            Number of rules attached (default: 0)
  --loops COUNT            Number of clarification loops (default: 0)
  --issues CSV             Comma-separated user-reported issues (optional)
  --format FORMAT          Output format: line|dashboard|decision-flow|json (default: line)
  -h, --help               Show this help

EXAMPLES:
  # Gauge line for lean context
  $(basename "$0") --scope-concrete true --rules 2 --loops 0

  # Dashboard for moderate context
  $(basename "$0") --scope-concrete true --rules 7 --loops 2 --format dashboard

  # JSON output for bloated context
  $(basename "$0") --scope-concrete false --rules 10 --loops 4 --issues "latency,quality" --format json

  # Show decision flow
  $(basename "$0") --format decision-flow

SCORING:
  5 (lean):    Narrow scope, 0-2 rules, 0-1 loops, no issues
  4 (ok):      Focused scope, 3-5 rules, 1-2 loops, minor issues
  3 (ok):      Moderate scope, 6-8 rules, 2-3 loops, some issues
  2 (bloated): Vague scope, 9-12 rules, 4+ loops, multiple issues
  1 (bloated): Unclear scope, 13+ rules, 5+ loops, severe issues

RECOMMENDATIONS:
  Score 4-5:                 Continue in current chat
  Score 3 + ≥2 signals:      Consider new chat or summarization
  Score 1-2:                 Strongly recommend new chat
EOF
  
  print_exit_codes
}

# Parse arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --scope-concrete)
      scope_concrete="$2"
      shift 2
      ;;
    --rules)
      rules_count="$2"
      shift 2
      ;;
    --loops)
      clarification_loops="$2"
      shift 2
      ;;
    --issues)
      user_issues="$2"
      shift 2
      ;;
    --format)
      output_format="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "$EXIT_USAGE" "Unknown option: $1"
      ;;
  esac
done

# Step 1: Compute score using focused script
score_flags=(
  "--scope-concrete" "$scope_concrete"
  "--rules" "$rules_count"
  "--loops" "$clarification_loops"
  "--format" "text"
)
if [ -n "$user_issues" ]; then
  score_flags+=("--issues" "$user_issues")
fi

score_output=$(bash "$SCRIPT_DIR/context-efficiency-score.sh" "${score_flags[@]}")

# Parse score output: "score=N label=LABEL"
score=$(echo "$score_output" | sed -n 's/^score=\([0-9]*\).*/\1/p')
label=$(echo "$score_output" | sed -n 's/.*label=\(.*\)$/\1/p')

# Step 2: Format output using focused script
format_flags=(
  "--score" "$score"
  "--label" "$label"
  "--scope-concrete" "$scope_concrete"
  "--rules" "$rules_count"
  "--loops" "$clarification_loops"
  "--format" "$output_format"
)
if [ -n "$user_issues" ]; then
  format_flags+=("--issues" "$user_issues")
fi

bash "$SCRIPT_DIR/context-efficiency-format.sh" "${format_flags[@]}"
