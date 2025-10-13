#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Conventional Commits helper
# Usage:
#   .cursor/scripts/git-commit.sh --type <type> [--scope <scope>] --description <text> \
#     [--body <line>]... [--footer <line>]... [--breaking <text>] [--dry-run]
#     [--version] [-h|--help]
#
# - Valid types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
# - Header length <= 72 chars
# - If --breaking is provided, '!' is added to the header and a BREAKING CHANGE footer is appended.

# shellcheck disable=SC1090
source "$(dirname "$0")/.lib.sh"

VERSION="0.1.0"

usage() {
  cat <<'USAGE'
Usage: git-commit.sh --type <type> [--scope <scope>] --description <text> \
                     [--body <line>]... [--footer <line>]... \
                     [--breaking <text>] [--dry-run] [--version] [-h|--help]

Options:
  --type <type>         Conventional type (feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert)
  --scope <scope>       Optional scope (no spaces)
  --description <text>  Required description (header subject)
  --body <line>         Body line (repeatable)
  --footer <line>       Footer line (repeatable)
  --breaking <text>     Breaking change description; adds '!' and BREAKING CHANGE footer
  --dry-run             Print message to stdout; do not run git
  --version             Print version and exit
  -h, --help            Show help and exit

Examples:
  # Feature commit
  git-commit.sh --type feat --description "add user authentication"
  
  # Fix with scope
  git-commit.sh --type fix --scope api --description "handle null response"
  
  # Breaking change with body
  git-commit.sh --type feat --breaking "remove legacy API" --description "migrate to v2 API" --body "All endpoints now use /v2/"
  
  # Commit with footer
  git-commit.sh --type docs --description "update README" --footer "Closes #123"
USAGE
  
  print_exit_codes
}

TYPE=""
SCOPE=""
DESC=""
BODIES=()
FOOTERS=()
BREAKING=""
DRY_RUN=0

valid_type() {
  case "$1" in
    feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert) return 0 ;;
    *) return 1 ;;
  esac
}

while [ $# -gt 0 ]; do
  case "$1" in
    --type) TYPE="${2:-}"; shift 2 ;;
    --scope) SCOPE="${2:-}"; shift 2 ;;
    --description) DESC="${2:-}"; shift 2 ;;
    --body) BODIES+=("${2:-}"); shift 2 ;;
    --footer) FOOTERS+=("${2:-}"); shift 2 ;;
    --breaking) BREAKING="${2:-}"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --version) printf '%s\n' "$VERSION"; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    *) die 2 "Unknown argument: $1" ;;
  esac
done

[ -n "$TYPE" ] || die 2 "--type is required"
valid_type "$TYPE" || die 2 "Invalid type: $TYPE"
[ -n "$DESC" ] || die 2 "--description is required"

if [ -n "$SCOPE" ] && echo "$SCOPE" | grep -qE '[[:space:]]'; then
  die 2 "--scope must not contain spaces"
fi

if [ -n "$BREAKING" ]; then
  # Ensure a footer will exist
  FOOTERS+=("BREAKING CHANGE: $BREAKING")
fi

# Build header
header_type="$TYPE"
if [ -n "$SCOPE" ]; then
  header_type+="($SCOPE)"
fi
if [ -n "$BREAKING" ]; then
  header_type+="!"
fi
HEADER="$header_type: $DESC"

# Header length validation (<=72)
if [ ${#HEADER} -gt 72 ]; then
  die 2 "Header exceeds 72 characters (${#HEADER})"
fi

print_message() {
  printf '%s\n' "$HEADER"
  if [ ${#BODIES[@]} -gt 0 ]; then
    printf '\n'
    for b in "${BODIES[@]}"; do
      printf '%s\n' "$b"
    done
  fi
  if [ ${#FOOTERS[@]} -gt 0 ]; then
    printf '\n'
    for f in "${FOOTERS[@]}"; do
      printf '%s\n' "$f"
    done
  fi
}

if [ $DRY_RUN -eq 1 ]; then
  print_message
  exit 0
fi

# Ensure git is available and we're in a repo
require_cmd git
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  die 1 "Not inside a git repository"
fi

# Compose git commit with multiple -m parts
set -- -m "$HEADER"
if [ ${#BODIES[@]} -gt 0 ]; then
  for b in "${BODIES[@]}"; do
    set -- "$@" -m "$b"
  done
fi
if [ ${#FOOTERS[@]} -gt 0 ]; then
  for f in "${FOOTERS[@]}"; do
    set -- "$@" -m "$f"
  done
fi

git commit "$@"
