#!/usr/bin/env bash
# check-script-usage.sh
# Analyze git commits for conventional commit format

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=.lib.sh
source "$SCRIPT_DIR/.lib.sh"

VERSION="0.1.0"

usage() {
  print_help_header "check-script-usage.sh" "$VERSION" "Analyze git commits for conventional commit format compliance"
  print_usage "check-script-usage.sh [OPTIONS]"
  
  print_options
  print_option "--limit N" "Number of recent commits to analyze" "100"
  print_option "-h, --help" "Show this help and exit"
  
  print_examples
  print_example "Check last 100 commits" "check-script-usage.sh"
  print_example "Check last 50 commits" "check-script-usage.sh --limit 50"
  
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

# Check git repo
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Error: Not in a git repository" >&2
  exit 1
fi

# Count conventional commits
conventional=0
total=0

while IFS= read -r msg; do
  total=$((total + 1))
  if echo "$msg" | grep -qE '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9-]+\))?(!)?:'; then
    conventional=$((conventional + 1))
  fi
done < <(git log --format=%s -n "$LIMIT")

if [[ "$total" -eq 0 ]]; then
  echo "No commits found"
  exit 0
fi

# Calculate rate
nonconventional=$((total - conventional))
rate=$((conventional * 100 / total))

# Output
echo "Script usage rate: ${rate}%"
echo "Conventional commits: $conventional"
echo "Non-conventional commits: $nonconventional"
echo
echo "Compliance target: >90%"

if [[ "$rate" -ge 90 ]]; then
  echo "Status: ✅ PASS"
else
  echo "Status: ⚠️  BELOW TARGET"
fi

exit 0
