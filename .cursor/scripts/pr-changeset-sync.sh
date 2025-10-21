#!/usr/bin/env bash
# Sync skip-changeset label with actual changeset presence
#
# Checks if .changeset/*.md files exist and removes skip-changeset
# label from PR if they do.
#
# Usage:
#   pr-changeset-sync.sh --pr <number>
#
# Example:
#   pr-changeset-sync.sh --pr 147

set -euo pipefail

# Source shared library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
PR_NUMBER=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --pr)
      PR_NUMBER="$2"
      shift 2
      ;;
    *)
      echo "ERROR: Unknown option: $1" >&2
      echo "Usage: $0 --pr <number>" >&2
      exit 1
      ;;
  esac
done

# Validate
if [[ -z "$PR_NUMBER" ]]; then
  echo "ERROR: --pr <number> required" >&2
  exit 1
fi

# Check for changeset files
CHANGESET_FILES=$(find .changeset -maxdepth 1 -name '*.md' ! -name 'README.md' 2>/dev/null || true)

if [[ -n "$CHANGESET_FILES" ]]; then
  echo "Changeset found, checking for skip-changeset label on PR #$PR_NUMBER..."
  
  # Check if skip-changeset label exists
  if bash "$SCRIPT_DIR/pr-labels.sh" --pr "$PR_NUMBER" --has skip-changeset 2>/dev/null; then
    echo "Removing skip-changeset label..."
    bash "$SCRIPT_DIR/pr-labels.sh" --pr "$PR_NUMBER" --remove skip-changeset
    echo "✓ Label removed (changeset present)"
  else
    echo "✓ No skip-changeset label (correct state)"
  fi
else
  echo "⚠️  No changeset files found in .changeset/"
  echo "   Consider running: npx changeset"
  echo "   Or add skip-changeset label: bash $SCRIPT_DIR/pr-labels.sh --pr $PR_NUMBER --add skip-changeset"
fi

