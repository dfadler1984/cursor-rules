#!/usr/bin/env bash
# Context Efficiency Formatter — format efficiency score with various output styles
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=.cursor/scripts/.lib.sh
source "$SCRIPT_DIR/.lib.sh"

enable_strict_mode

# Default values
score=""
label=""
scope_concrete="true"
rules_count=0
clarification_loops=0
user_issues=""
output_format="line"

VERSION="1.0.0"

print_help() {
  cat <<EOF
context-efficiency-format.sh (v${VERSION})
Format context efficiency score with various output styles

Usage: $(basename "$0") [OPTIONS]

Options:
  --score INT          Efficiency score (1-5, required for most formats)
  --label STR          Score label (lean|ok|bloated, required for most formats)
  --scope-concrete BOOL Is task scope narrow? (true|false, default: true)
  --rules COUNT        Number of rules attached (default: 0)
  --loops COUNT        Number of clarification loops (default: 0)
  --issues CSV         Comma-separated user-reported issues (optional)
  --format FORMAT      Output format: line|dashboard|decision-flow|json (default: line)
  --version            Print version and exit
  -h, --help           Show this help and exit

Output Formats:
  line:         Single-line summary
  dashboard:    Box-drawing dashboard
  decision-flow: Decision tree (static, no inputs needed)
  json:         JSON object with score, label, rationale, recommendation

Examples:
  # Line format (simple)
  $ context-efficiency-format.sh --score 5 --label lean --scope-concrete true --rules 2 --loops 0

  # Dashboard
  $ context-efficiency-format.sh --score 3 --label ok --rules 7 --loops 2 --format dashboard

  # JSON output
  $ context-efficiency-format.sh --score 4 --label ok --rules 3 --loops 1 --format json

  # Decision flow (no inputs needed)
  $ context-efficiency-format.sh --format decision-flow

Composition:
  # Pipe from score calculator
  eval \$(context-efficiency-score.sh --rules 5 --loops 1 --format text)
  context-efficiency-format.sh --score "\$score" --label "\$label" --rules 5 --loops 1 --format dashboard

EOF
  print_exit_codes
}

# Parse arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --score)
      score="$2"
      shift 2
      ;;
    --label)
      label="$2"
      shift 2
      ;;
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
    --version)
      echo "context-efficiency-format.sh v${VERSION}"
      exit 0
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

# Validation for most formats (decision-flow doesn't need score/label)
if [ "$output_format" != "decision-flow" ]; then
  if [ -z "$score" ] || [ -z "$label" ]; then
    die "$EXIT_USAGE" "--score and --label are required for format: $output_format"
  fi
fi

# Generate rationale
get_rationale() {
  local parts=()

  if [ "$scope_concrete" = "true" ]; then
    parts+=("narrow scope")
  else
    parts+=("vague scope")
  fi

  if [ "$rules_count" -eq 0 ]; then
    parts+=("no rules")
  elif [ "$rules_count" -le 2 ]; then
    parts+=("minimal rules")
  else
    parts+=("$rules_count rules")
  fi

  if [ "$clarification_loops" -eq 0 ]; then
    parts+=("no loops")
  elif [ "$clarification_loops" -eq 1 ]; then
    parts+=("1 clarification")
  else
    parts+=("$clarification_loops clarifications")
  fi

  if [ -n "$user_issues" ]; then
    parts+=("issues: $user_issues")
  else
    parts+=("no issues")
  fi

  # Join with commas
  local IFS=', '
  echo "${parts[*]}"
}

# Get recommendation
get_recommendation() {
  local s="$1"

  if [ "$s" -le 2 ]; then
    echo "new-chat"
    return
  fi

  if [ "$s" -eq 3 ]; then
    # Count signals
    local signal_count=0
    [ "$scope_concrete" = "false" ] && signal_count=$((signal_count + 1))
    [ "$rules_count" -ge 9 ] && signal_count=$((signal_count + 1))
    [ "$clarification_loops" -ge 4 ] && signal_count=$((signal_count + 1))
    
    # Count issues
    local issue_count=0
    if [ -n "$user_issues" ]; then
      IFS=',' read -ra issues_array <<< "$user_issues"
      issue_count="${#issues_array[@]}"
    fi
    [ "$issue_count" -ge 2 ] && signal_count=$((signal_count + 1))

    if [ "$signal_count" -ge 2 ]; then
      echo "consider-new-chat"
      return
    fi
  fi

  echo "continue"
}

# Format functions
format_gauge_line() {
  local s="$1"
  local lbl="$2"
  local rationale="$3"
  echo "Context Efficiency Gauge: $s/5 ($lbl) — $rationale"
}

format_dashboard() {
  local s="$1"
  local lbl="$2"
  local gauge_bar
  gauge_bar=$(printf '#%.0s' $(seq 1 "$s"))$(printf -- '-%.0s' $(seq 1 $((5 - s))))
  local scope_label="narrow"
  [ "$scope_concrete" = "false" ] && scope_label="vague"
  
  local issues_label="none"
  [ -n "$user_issues" ] && issues_label="$user_issues"

  cat <<EOF
┌───────────────────────────────┐
│ CONTEXT EFFICIENCY — DASHBOARD │
├───────────────────────────────┤
│ Gauge: [$gauge_bar] $s/5 ($lbl)     │
│ Scope: $scope_label                 │
│ Rules: $rules_count                      │
│ Loops: $clarification_loops                      │
│ Issues: $issues_label               │
└───────────────────────────────┘
EOF
}

format_decision_flow() {
  cat <<'EOF'
┌───────────────────────────────────────────────┐
│ SHOULD I START A NEW CHAT?                    │
├───────────────────────────────────────────────┤
│ 1) Is the task scope narrow and concrete?     │
│    - No → New chat (seed exact file + change) │
│    - Yes → 2) ≥2 clarification loops?         │
│             - Yes → New chat                  │
│             - No → 3) Broad searches/many     │
│                    rules attached?            │
│                    - Yes → New chat           │
│                    - No → 4) Latency spikes?  │
│                           - Yes → New chat    │
│                           - No → Stay here    │
└───────────────────────────────────────────────┘
EOF
}

format_json() {
  local s="$1"
  local lbl="$2"
  local rationale="$3"
  local recommendation="$4"

  cat <<EOF
{
  "score": $s,
  "label": "$lbl",
  "rationale": "$(json_escape "$rationale")",
  "recommendation": {
    "action": "$recommendation"
  }
}
EOF
}

# Main logic
case "$output_format" in
  line)
    rationale=$(get_rationale)
    format_gauge_line "$score" "$label" "$rationale"
    ;;
  dashboard)
    format_dashboard "$score" "$label"
    ;;
  decision-flow)
    format_decision_flow
    ;;
  json)
    rationale=$(get_rationale)
    recommendation=$(get_recommendation "$score")
    format_json "$score" "$label" "$rationale" "$recommendation"
    ;;
  *)
    die "$EXIT_USAGE" "Unknown format: $output_format"
    ;;
esac

