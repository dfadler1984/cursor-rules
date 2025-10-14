#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Context efficiency score computation
# Computes: efficiency score (1-5) based on heuristics
#
# Extracted from context-efficiency-gauge.sh for Unix Philosophy compliance:
# - Do one thing: compute score only
# - Small & focused: ~150 lines vs 342 in original
# - Composable: outputs score, can be piped to formatter

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

VERSION="1.0.0"

# Default values
scope_concrete="true"
rules_count=0
clarification_loops=0
user_issues=""
OUTPUT_FORMAT="text"  # text|json

usage() {
  print_help_header "context-efficiency-score.sh" "$VERSION" "Compute context efficiency score"
  print_usage "context-efficiency-score.sh [OPTIONS]"
  
  print_options
  print_option "--scope-concrete BOOL" "Is task scope narrow and concrete? (true|false)" "true"
  print_option "--rules COUNT" "Number of rules attached" "0"
  print_option "--loops COUNT" "Number of clarification loops" "0"
  print_option "--issues CSV" "Comma-separated user-reported issues (optional)"
  print_option "--format FORMAT" "Output format: text|json" "text"
  print_option "--version" "Print version and exit"
  print_option "-h, --help" "Show this help and exit"
  
  cat <<'DETAILS'

Scoring Algorithm:
  Start at 5 (lean), deduct based on:
  - Vague scope: -2
  - Rules: 13+ (-2), 9-12 (-0.5), 6-8 (-1), 3-5 (-0.5)
  - Loops: 5+ (-2), 4 (-0.5), 2-3 (-1), 1 (-0.25)
  - Issues: severe terms (-0.5 to -1), minor (-0.1 to -0.25)
  
  Final score clamped to 1-5 range.

Output:
  text format: "score=N label=LABEL"
  json format: {"score": N, "label": "LABEL"}

Labels:
  5: lean, 4: ok, 3: ok, 2-1: bloated

DETAILS
  
  print_examples
  print_example "Lean context" "context-efficiency-score.sh --scope-concrete true --rules 2 --loops 0"
  print_example "Bloated context" "context-efficiency-score.sh --scope-concrete false --rules 10 --loops 4"
  print_example "JSON output" "context-efficiency-score.sh --rules 5 --loops 1 --format json"
  
  print_exit_codes
}

# Compute score based on heuristics
compute_score() {
  local score=5
  
  # Scope check
  if [ "$scope_concrete" = "false" ]; then
    score=$((score - 2))
  fi
  
  # Rules attached
  if [ "$rules_count" -ge 13 ]; then
    score=$((score - 2))
  elif [ "$rules_count" -ge 9 ]; then
    score=$(echo "$score - 0.5" | bc)
  elif [ "$rules_count" -ge 6 ]; then
    score=$(echo "$score - 1" | bc)
  elif [ "$rules_count" -ge 3 ]; then
    score=$(echo "$score - 0.5" | bc)
  fi
  
  # Clarification loops
  if [ "$clarification_loops" -ge 5 ]; then
    score=$((score - 2))
  elif [ "$clarification_loops" -ge 4 ]; then
    score=$(echo "$score - 0.5" | bc)
  elif [ "$clarification_loops" -ge 2 ]; then
    score=$(echo "$score - 1" | bc)
  elif [ "$clarification_loops" -ge 1 ]; then
    score=$(echo "$score - 0.25" | bc)
  fi
  
  # User-reported issues
  local severe_count=0
  local minor_count=0
  if [ -n "$user_issues" ]; then
    IFS=',' read -ra issues_array <<< "$user_issues"
    for issue in "${issues_array[@]}"; do
      if [[ "$issue" =~ severe|"cut off"|truncated|degraded ]]; then
        severe_count=$((severe_count + 1))
      elif [[ "$issue" =~ latency|quality|slow ]]; then
        minor_count=$((minor_count + 1))
      fi
    done
  fi
  
  if [ "$severe_count" -ge 3 ]; then
    score=$(echo "$score - 1" | bc)
  elif [ "$severe_count" -ge 2 ]; then
    score=$(echo "$score - 0.75" | bc)
  elif [ "$severe_count" -ge 1 ]; then
    score=$(echo "$score - 0.5" | bc)
  elif [ "$minor_count" -ge 2 ]; then
    score=$(echo "$score - 0.25" | bc)
  elif [ "$minor_count" -ge 1 ]; then
    score=$(echo "$score - 0.1" | bc)
  fi
  
  # Round and clamp to 1-5
  score=$(printf "%.0f" "$score")
  if [ "$score" -lt 1 ]; then score=1; fi
  if [ "$score" -gt 5 ]; then score=5; fi
  
  echo "$score"
}

# Get label for score
get_label() {
  local score="$1"
  if [ "$score" -ge 4 ]; then
    echo "lean"
  elif [ "$score" -ge 3 ]; then
    echo "ok"
  else
    echo "bloated"
  fi
}

# Parse arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --scope-concrete) scope_concrete="$2"; shift 2 ;;
    --rules) rules_count="$2"; shift 2 ;;
    --loops) clarification_loops="$2"; shift 2 ;;
    --issues) user_issues="$2"; shift 2 ;;
    --format) OUTPUT_FORMAT="$2"; shift 2 ;;
    --version) printf '%s\n' "$VERSION"; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    *) die "$EXIT_USAGE" "Unknown argument: $1" ;;
  esac
done

# Compute score
score=$(compute_score)
label=$(get_label "$score")

# Output based on format
case "$OUTPUT_FORMAT" in
  json)
    cat <<EOF
{
  "score": $score,
  "label": "$label",
  "inputs": {
    "scope_concrete": $scope_concrete,
    "rules_count": $rules_count,
    "clarification_loops": $clarification_loops,
    "user_issues": "$user_issues"
  }
}
EOF
    ;;
  text)
    printf "score=%d label=%s\n" "$score" "$label"
    ;;
esac

exit 0

