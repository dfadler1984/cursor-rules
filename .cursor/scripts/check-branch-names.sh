#!/usr/bin/env bash
# check-branch-names.sh
# Check branch naming compliance

# Help
if [[ "${1:-}" == "--help" ]]; then
  cat << EOF
check-branch-names.sh - Check branch naming compliance

Usage:
  check-branch-names.sh

Flags:
  --help       Show this help
EOF
  exit 0
fi

# Check git repo
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Error: Not in a git repository" >&2
  exit 1
fi

# Count compliant branches
compliant=0
total=0

# Remote branches
while IFS= read -r branch; do
  [[ -z "$branch" ]] && continue
  name="${branch##*/}"
  [[ "$name" == "HEAD" ]] && continue
  
  total=$((total + 1))
  
  if echo "$name" | grep -qE '^[a-zA-Z0-9_-]+/'; then
    compliant=$((compliant + 1))
  fi
done < <(git branch -r 2>/dev/null | sed 's/^[[:space:]]*//')

# Local branches
while IFS= read -r branch; do
  [[ -z "$branch" ]] && continue
  name=$(echo "$branch" | sed 's/^[* ]*//')
  [[ "$name" == "HEAD" ]] && continue
  
  total=$((total + 1))
  
  if echo "$name" | grep -qE '^[a-zA-Z0-9_-]+/'; then
    compliant=$((compliant + 1))
  fi
done < <(git branch 2>/dev/null)

if [[ "$total" -eq 0 ]]; then
  echo "No branches found"
  exit 0
fi

# Calculate rate
rate=$((compliant * 100 / total))

# Output
echo "Branch naming compliance: ${rate}%"
echo "Compliant branches: $compliant"
echo "Total branches: $total"
echo
echo "Compliance target: >90%"

if [[ "$rate" -ge 90 ]]; then
  echo "Status: ✅ PASS"
else
  echo "Status: ⚠️  BELOW TARGET"
fi

exit 0
