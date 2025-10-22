#!/usr/bin/env bash
# TDD Scope Checker — validates whether a file requires TDD coverage
# Usage: tdd-scope-check.sh <file-path>
# Exit codes: 0 = in TDD scope, 1 = exempt, 2 = error

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Include/exclude patterns per tdd-first.mdc
readonly TDD_INCLUDE_EXTS=(ts tsx js jsx mjs cjs sh)
readonly TDD_EXCLUDE_PATTERNS=(
  "node_modules/"
  "dist/"
  "build/"
  "web/dist/"
)
readonly TDD_EXEMPT_PATTERNS=(
  "*.md"
  "*.mdx"
  "*.json"
  "*.yaml"
  "*.yml"
  "*.toml"
  ".cursor/rules/*.mdc"
  "*.d.ts"
  "*.css"
  "*.html"
)

print_usage() {
  cat <<EOF
Usage: $(basename "$0") <file-path>

Check whether a file requires TDD coverage per tdd-first.mdc scope rules.

Exit codes:
  0 = File is in TDD scope (TDD required)
  1 = File is exempt from TDD (no tests needed)
  2 = Error (invalid input or file not found)

Examples:
  $(basename "$0") src/parse.ts          # TDD required (exit 0)
  $(basename "$0") docs/projects/erd.md  # Exempt (exit 1)
  $(basename "$0") .cursor/scripts/validate.sh  # TDD required (exit 0)
EOF
}

is_excluded() {
  local file="$1"
  
  # Check if path contains excluded directory patterns
  # Match /node_modules/ or any directory starting with node_modules
  if [[ "$file" == *"/node_modules/"* ]] || [[ "$file" == */node_modules.* ]]; then
    return 0
  fi
  # Match /dist/ or any directory starting with dist
  if [[ "$file" == *"/dist/"* ]] || [[ "$file" == */dist.* ]]; then
    return 0
  fi
  # Match /build/ or any directory starting with build
  if [[ "$file" == *"/build/"* ]] || [[ "$file" == */build.* ]]; then
    return 0
  fi
  # Match web/dist specifically
  if [[ "$file" == *"/web/dist/"* ]] || [[ "$file" == */web/dist.* ]]; then
    return 0
  fi
  
  return 1
}

is_exempt() {
  local file="$1"
  local pattern
  
  for pattern in "${TDD_EXEMPT_PATTERNS[@]}"; do
    # Simple glob matching for file extensions and paths
    case "$file" in
      $pattern) return 0 ;;
    esac
  done
  return 1
}

has_tdd_extension() {
  local file="$1"
  local ext="${file##*.}"
  local tdd_ext
  
  for tdd_ext in "${TDD_INCLUDE_EXTS[@]}"; do
    if [[ "$ext" == "$tdd_ext" ]]; then
      return 0
    fi
  done
  return 1
}

check_tdd_scope() {
  local file="$1"
  
  # Normalize path relative to repo root
  if [[ "$file" == /* ]]; then
    # Absolute path: make relative to repo root
    file="${file#$REPO_ROOT/}"
  fi
  
  # 1. Check exclude patterns first
  if is_excluded "$file"; then
    printf 'TDD: exempt (excluded path: %s)\n' "$file"
    return 1
  fi
  
  # 2. Check exemption patterns
  if is_exempt "$file"; then
    printf 'TDD: exempt (non-code file: %s)\n' "$file"
    return 1
  fi
  
  # 3. Check if file has TDD extension
  if has_tdd_extension "$file"; then
    printf 'TDD: in-scope (source code: %s)\n' "$file"
    return 0
  fi
  
  # 4. Default: exempt (unknown file type)
  printf 'TDD: exempt (unknown file type: %s)\n' "$file"
  return 1
}

main() {
  if [[ $# -eq 0 ]] || [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
    print_usage
    exit 0
  fi
  
  local file="$1"
  
  if [[ ! -e "$file" ]]; then
    printf 'Error: file not found: %s\n' "$file" >&2
    exit 2
  fi
  
  if check_tdd_scope "$file"; then
    # In TDD scope
    exit 0
  else
    # Exempt from TDD
    exit 1
  fi
}

main "$@"

