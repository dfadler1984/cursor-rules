#!/usr/bin/env bash
# check-tdd-compliance.sh
# Check TDD compliance via spec file changes

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=.lib.sh
source "$SCRIPT_DIR/.lib.sh"

VERSION="0.1.0"

usage() {
  print_help_header "check-tdd-compliance.sh" "$VERSION" "Check TDD compliance by correlating impl and spec file changes"
  print_usage "check-tdd-compliance.sh [OPTIONS]"
  
  print_options
  print_option "--limit N" "Number of commits to analyze" "100"
  print_option "-h, --help" "Show this help and exit"
  
  print_examples
  print_example "Check last 100 commits" "check-tdd-compliance.sh"
  print_example "Check last 50 commits" "check-tdd-compliance.sh --limit 50"
  
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
