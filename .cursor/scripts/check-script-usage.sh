#!/usr/bin/env bash
# check-script-usage.sh
# Analyze git commits for conventional commit format

# Defaults
LIMIT=100

# Help
if [[ "${1:-}" == "--help" ]]; then
  cat << EOF
check-script-usage.sh - Check script usage compliance

Usage:
  check-script-usage.sh [--limit N]

Flags:
  --limit N    Number of recent commits to analyze (default: 100)
  --help       Show this help
EOF
  exit 0
fi

# Parse --limit flag
if [[ "${1:-}" == "--limit" ]] && [[ -n "${2:-}" ]]; then
  LIMIT="$2"
fi

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
