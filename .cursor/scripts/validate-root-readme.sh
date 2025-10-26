#!/usr/bin/env bash
# Validate root README.md freshness
#
# Description: Validate that README.md is up-to-date with generator
# Flags: --fix, --dry-run, --help, --version
# Usage: validate-root-readme.sh [--fix] [--dry-run]
#
# Exit codes:
#   0 - README is current
#   1 - README is stale (needs regeneration)
#   2 - Error (missing files, generation failed)

set -euo pipefail

# Script metadata
SCRIPT_VERSION="0.1.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Configuration
FIX_MODE=false
DRY_RUN=false

#
# CLI Functions
#

show_help() {
  cat << EOF
Validate root README.md freshness

Usage: $(basename "$0") [OPTIONS]

Validates that the committed README.md matches the output of generate-root-readme.sh.
If they differ, the README is considered stale and needs regeneration.

Options:
  --fix         Regenerate README.md if stale
  --dry-run     Show diff without writing (with --fix)
  --help        Show this help message
  --version     Show script version

Exit Codes:
  0 - README is current
  1 - README is stale
  2 - Error (missing files, generation failed)

Examples:
  # Check if README is current
  $(basename "$0")

  # Check and show diff if stale
  $(basename "$0") --dry-run

  # Regenerate if stale
  $(basename "$0") --fix

EOF
}

show_version() {
  echo "validate-root-readme.sh version $SCRIPT_VERSION"
}

#
# Validation Logic
#

validate_readme() {
  local current_readme="$REPO_ROOT/README.md"
  local generator_script="$REPO_ROOT/.cursor/scripts/generate-root-readme.sh"
  
  # Check that files exist
  if [[ ! -f "$current_readme" ]]; then
    echo "Error: README.md not found at: $current_readme" >&2
    return 2
  fi
  
  if [[ ! -f "$generator_script" ]]; then
    echo "Error: Generator script not found at: $generator_script" >&2
    return 2
  fi
  
  # Generate fresh README to temp location
  echo "Generating fresh README..." >&2
  local temp_readme
  temp_readme=$(mktemp)
  
  if ! "$generator_script" --out "$temp_readme" >/dev/null 2>&1; then
    echo "Error: Generator script failed" >&2
    rm -f "$temp_readme"
    return 2
  fi
  
  # Compare current with generated
  if diff -q "$current_readme" "$temp_readme" >/dev/null 2>&1; then
    echo "✓ README is current" >&2
    rm -f "$temp_readme"
    return 0
  else
    echo "✗ README is stale" >&2
    
    if [[ "$DRY_RUN" == "true" ]] || [[ "$FIX_MODE" == "false" ]]; then
      echo "" >&2
      echo "Differences:" >&2
      diff -u "$current_readme" "$temp_readme" | head -50 >&2
      echo "" >&2
      
      if [[ "$FIX_MODE" == "false" ]]; then
        echo "Run with --fix to regenerate README.md" >&2
      fi
    fi
    
    if [[ "$FIX_MODE" == "true" ]] && [[ "$DRY_RUN" == "false" ]]; then
      echo "Regenerating README.md..." >&2
      mv "$temp_readme" "$current_readme"
      echo "✓ README.md regenerated" >&2
      return 0
    fi
    
    rm -f "$temp_readme"
    return 1
  fi
}

#
# Main
#

main() {
  validate_readme
  return $?
}

# Parse arguments and run
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --fix)
        FIX_MODE=true
        shift
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --help)
        show_help
        exit 0
        ;;
      --version)
        show_version
        exit 0
        ;;
      *)
        echo "Error: Unknown option: $1" >&2
        echo "Use --help for usage information." >&2
        exit 2
        ;;
    esac
  done
  
  main
fi

