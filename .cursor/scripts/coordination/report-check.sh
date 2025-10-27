#!/usr/bin/env bash
# Check for new worker reports

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../.lib.sh
source "$SCRIPT_DIR/../.lib.sh"

usage() {
  print_help_header "report-check.sh" "Check for worker completion reports"
  print_usage "report-check.sh [--format json|text]"
  echo ""
  echo "Options:"
  echo "  --format FORMAT    Output format: json or text (default: text)"
  print_exit_codes
  echo ""
  echo "Examples:"
  echo "  bash report-check.sh"
  echo "  bash report-check.sh --format json"
}

FORMAT="text"

# Parse args
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --format) FORMAT="${2:-text}"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; usage >&2; exit 2 ;;
  esac
done

# Paths
COORD_DIR="tmp/coordination"
REPORTS_DIR="$COORD_DIR/reports"

# Validate reports directory exists
if [[ ! -d "$REPORTS_DIR" ]]; then
  echo "Error: Reports directory not found: $REPORTS_DIR" >&2
  exit 1
fi

# Find all report files
mapfile -t REPORTS < <(find "$REPORTS_DIR" -name "task-*-report.json" -type f 2>/dev/null || true)

# No reports found
if [[ ${#REPORTS[@]} -eq 0 ]]; then
  if [[ "$FORMAT" == "json" ]]; then
    echo '{"reports": [], "count": 0}'
  else
    echo "No reports found"
  fi
  exit 0
fi

# Format output
if [[ "$FORMAT" == "json" ]]; then
  echo '{"reports": ['
  for i in "${!REPORTS[@]}"; do
    echo -n "  \"${REPORTS[$i]}\""
    if [[ $i -lt $((${#REPORTS[@]} - 1)) ]]; then
      echo ","
    else
      echo ""
    fi
  done
  echo "], \"count\": ${#REPORTS[@]}}"
else
  echo "Found ${#REPORTS[@]} report(s):"
  for report in "${REPORTS[@]}"; do
    BASENAME=$(basename "$report")
    TASK_ID=$(echo "$BASENAME" | sed 's/-report\.json$//')
    WORKER_ID=$(jq -r '.workerId' "$report" 2>/dev/null || echo "unknown")
    STATUS=$(jq -r '.status' "$report" 2>/dev/null || echo "unknown")
    echo "  - $TASK_ID: $STATUS (worker: $WORKER_ID)"
  done
fi

exit 0

