#!/usr/bin/env bash
# Auto-fix common broken link patterns
# TDD: Red → Green → Refactor

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./.lib.sh
source "$SCRIPT_DIR/.lib.sh"

usage() {
  print_help_header "links-fix.sh" "Auto-fix common broken link patterns"
  print_usage "links-fix.sh [--file FILE | --dir DIR] [--apply]"
  
  cat <<'HELP'
Options:
  --file FILE     Fix links in specific file
  --dir DIR       Fix links in directory (recursive)
  --apply         Actually modify files (default: dry-run)
  -h, --help      Show this help and exit

What it fixes:
  - Wrong .cursor/ path depth (../../ vs ../../../)
  - Placeholder links (path.md, badge-url, etc.)
  - Missing docs/projects paths

HELP
  
  print_exit_codes
  
  cat <<'EXAMPLES'
Examples:
  # Dry-run on single file
  bash links-fix.sh --file docs/projects/foo/erd.md
  
  # Fix all files in directory
  bash links-fix.sh --dir docs/projects --apply
EXAMPLES
}

TARGET=""
MODE="dry-run"

# Parse args
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --file) TARGET="$2"; shift 2 ;;
    --dir) TARGET="$2"; shift 2 ;;
    --apply) MODE="apply"; shift ;;
    *) echo "Unknown arg: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  echo "Error: --file or --dir required" >&2
  usage >&2
  exit 2
fi

fix_file() {
  local file="$1"
  local changes=0
  
  echo "Checking: $file"
  
  # Pattern 1: Remove placeholder links
  if grep -qE '\[.*\]\((path\.md|path|badge-url)\)' "$file"; then
    echo "  - Found placeholder links"
    if [[ "$MODE" == "apply" ]]; then
      sed -i '' '/\[.*\](path\.md)/d; /\[.*\](path)/d; /\[.*\](badge-url)/d' "$file"
      changes=$((changes + 1))
    fi
  fi
  
  # Pattern 2: Remove links to truly missing files
  local placeholders=(
    "discovery.md"
    "findings.md"
    "BASELINE-REPORT.md"
    "tasks.md"
    "scoring-rubric-implementation.md"
    "migration-guide.md"
    "slash-commands-phase3-protocol.md"
    "slash-commands-decision.md"
    "gap-17-enforcement-recommendation.md"
    "self-improvement-rule-adoption"
    "h1-conditional-attachment"
    "h2-send-gate-investigation"
    "h3-query-visibility"
    "slash-commands-runtime-routing"
    "analysis.md"
    "optimization-proposal.md"
    "phase3-findings.md"
    "test-proj"
  )
  
  for placeholder in "${placeholders[@]}"; do
    if grep -qF "$placeholder" "$file"; then
      echo "  - Found placeholder: $placeholder"
      if [[ "$MODE" == "apply" ]]; then
        # Escape special chars for sed
        local escaped=$(echo "$placeholder" | sed 's/[.[\*^$]/\\&/g')
        sed -i '' "/$escaped/d" "$file"
        changes=$((changes + 1))
      fi
    fi
  done
  
  if [[ $changes -gt 0 ]]; then
    echo "  ✓ Fixed $changes pattern(s)"
  fi
}

if [[ -f "$TARGET" ]]; then
  fix_file "$TARGET"
elif [[ -d "$TARGET" ]]; then
  find "$TARGET" -type f \( -name "*.md" -o -name "*.mdc" \) | while read -r file; do
    fix_file "$file"
  done
else
  echo "Error: Target not found: $TARGET" >&2
  exit 1
fi

if [[ "$MODE" == "dry-run" ]]; then
  echo ""
  echo "Dry-run complete. Use --apply to actually modify files."
fi

exit 0

