#!/usr/bin/env bash
# Context Efficiency Gauge — qualitative heuristics for chat context health
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

# Default values
scope_concrete="true"
rules_count=0
clarification_loops=0
user_issues=""
output_format="line"  # line|dashboard|decision-flow|json

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
      die 2 "Unknown option: $1"
      ;;
  esac
done

# Compute score
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
    # 6-8 rules: score 3 range
    score=$(echo "$score - 1" | bc)
  elif [ "$rules_count" -ge 3 ]; then
    # 3-5 rules: score 4 range
    score=$(echo "$score - 0.5" | bc)
  fi

  # Clarification loops
  if [ "$clarification_loops" -ge 5 ]; then
    score=$((score - 2))
  elif [ "$clarification_loops" -ge 4 ]; then
    score=$(echo "$score - 0.5" | bc)
  elif [ "$clarification_loops" -ge 2 ]; then
    # 2-3 loops: score 3 range
    score=$(echo "$score - 1" | bc)
  elif [ "$clarification_loops" -ge 1 ]; then
    # 1 loop: score 4 range
    score=$(echo "$score - 0.25" | bc)
  fi

  # User-reported issues (count severe issues only)
  local severe_count=0
  local minor_count=0
  if [ -n "$user_issues" ]; then
    IFS=',' read -ra issues_array <<< "$user_issues"
    for issue in "${issues_array[@]}"; do
      # Severe: explicit severity terms or truncation
      if [[ "$issue" =~ severe|"cut off"|truncated|degraded ]]; then
        severe_count=$((severe_count + 1))
      # Minor: mentioned but not severe
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

# Get label
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
  elif [ "$rules_count" -le 5 ]; then
    parts+=("$rules_count rules")
  elif [ "$rules_count" -le 8 ]; then
    parts+=("$rules_count rules")
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
  local score="$1"

  if [ "$score" -le 2 ]; then
    echo "new-chat"
    return
  fi

  if [ "$score" -eq 3 ]; then
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

# Format gauge line
format_gauge_line() {
  local score="$1"
  local label="$2"
  local rationale="$3"
  echo "Context Efficiency Gauge: $score/5 ($label) — $rationale"
}

# Format dashboard
format_dashboard() {
  local score="$1"
  local label="$2"
  local gauge_bar=$(printf '#%.0s' $(seq 1 "$score"))$(printf -- '-%.0s' $(seq 1 $((5 - score))))
  local scope_label="narrow"
  [ "$scope_concrete" = "false" ] && scope_label="vague"
  
  local issues_label="none"
  [ -n "$user_issues" ] && issues_label="$user_issues"

  cat <<EOF
┌───────────────────────────────┐
│ CONTEXT EFFICIENCY — DASHBOARD │
├───────────────────────────────┤
│ Gauge: [$gauge_bar] $score/5 ($label)     │
│ Scope: $scope_label                 │
│ Rules: $rules_count                      │
│ Loops: $clarification_loops                      │
│ Issues: $issues_label               │
└───────────────────────────────┘
EOF
}

# Format decision flow
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

# Format JSON
format_json() {
  local score="$1"
  local label="$2"
  local rationale="$3"
  local recommendation="$4"

  cat <<EOF
{
  "score": $score,
  "label": "$label",
  "rationale": "$(json_escape "$rationale")",
  "recommendation": {
    "action": "$recommendation"
  }
}
EOF
}

# Main logic
score=$(compute_score)
label=$(get_label "$score")
rationale=$(get_rationale)
recommendation=$(get_recommendation "$score")

case "$output_format" in
  line)
    format_gauge_line "$score" "$label" "$rationale"
    ;;
  dashboard)
    format_dashboard "$score" "$label"
    ;;
  decision-flow)
    format_decision_flow
    ;;
  json)
    format_json "$score" "$label" "$rationale" "$recommendation"
    ;;
  *)
    die 2 "Unknown format: $output_format"
    ;;
esac

