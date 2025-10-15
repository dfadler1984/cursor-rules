#!/usr/bin/env bash
# check-tdd-compliance.sh
# Check TDD compliance via spec file changes

# Defaults
LIMIT=100

# Help
if [[ "${1:-}" == "--help" ]]; then
  cat << EOF
check-tdd-compliance.sh - Check TDD compliance

Usage:
  check-tdd-compliance.sh [--limit N]

Flags:
  --limit N    Number of commits to analyze (default: 100)
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

# Count compliant commits
compliant=0
impl_commits=0

while IFS= read -r sha; do
  # Get changed files
  files=$(git show --name-only --format= "$sha" 2>/dev/null || true)
  
  # Find impl files (exclude specs/tests)
  impl=$(echo "$files" | grep -E '\.(ts|tsx|js|jsx|mjs|cjs|sh)$' | grep -v '\.spec\.' | grep -v '\.test\.' || true)
  
  if [[ -z "$impl" ]]; then
    continue
  fi
  
  impl_commits=$((impl_commits + 1))
  
  # Check if corresponding spec file changed
  has_spec=false
  while IFS= read -r impl_file; do
    [[ -z "$impl_file" ]] && continue
    
    base="${impl_file%.*}"
    ext="${impl_file##*.}"
    spec="${base}.spec.${ext}"
    test="${base}.test.${ext}"
    
    if echo "$files" | grep -qE "^${spec}$|^${test}$"; then
      has_spec=true
      break
    fi
  done <<< "$impl"
  
  if [[ "$has_spec" == "true" ]]; then
    compliant=$((compliant + 1))
  fi
done < <(git log --format=%H -n "$LIMIT")

if [[ "$impl_commits" -eq 0 ]]; then
  echo "No implementation commits found"
  exit 0
fi

# Calculate rate
rate=$((compliant * 100 / impl_commits))

# Output
echo "TDD compliance rate: ${rate}%"
echo "Compliant commits: $compliant"
echo "Total impl commits: $impl_commits"
echo
echo "Compliance target: >95%"

if [[ "$rate" -ge 95 ]]; then
  echo "Status: ✅ PASS"
else
  echo "Status: ⚠️  BELOW TARGET"
fi

exit 0
