#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Git context derivation utility
# Derives: owner, repo, head branch, base branch from git remote
#
# Extracted from pr-create.sh for Unix Philosophy compliance:
# - Do one thing: derive git context only
# - Small & focused: ~90 lines vs 282 in pr-create.sh
# - Reusable: other GitHub scripts can use this

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

VERSION="1.0.0"

# Default values
OUTPUT_FORMAT="text"  # text|json|eval

usage() {
  print_help_header "git-context.sh" "$VERSION" "Derive GitHub context from git remote"
  print_usage "git-context.sh [OPTIONS]"
  
  print_options
  print_option "--format FORMAT" "Output format: text|json|eval" "text"
  print_option "--version" "Print version and exit"
  print_option "-h, --help" "Show this help and exit"
  
  cat <<'DETAILS'

Derives from git remote:
  - owner: GitHub repository owner
  - repo: Repository name
  - head: Current branch name
  - base: Default branch (from remote)

Formats:
  - text: Human-readable output
  - json: JSON object
  - eval: Shell variable assignments (sourceable)

DETAILS
  
  print_examples
  print_example "Default output" "git-context.sh"
  print_example "JSON format" "git-context.sh --format json"
  print_example "Source into shell" "eval \$(git-context.sh --format eval)"
  
  print_exit_codes
}

# Parse arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --format)
      OUTPUT_FORMAT="${2:-}"
      if [ "$OUTPUT_FORMAT" != "text" ] && [ "$OUTPUT_FORMAT" != "json" ] && [ "$OUTPUT_FORMAT" != "eval" ]; then
        die "$EXIT_USAGE" "--format must be 'text', 'json', or 'eval'"
      fi
      shift 2
      ;;
    --version)
      printf '%s\n' "$VERSION"
      exit 0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "$EXIT_USAGE" "Unknown argument: $1"
      ;;
  esac
done

# Verify we're in a git repo
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  die "$EXIT_CONFIG" "Not a git repository"
fi

# Derive context
url=$(git remote get-url origin 2>/dev/null || true)

if [ -z "$url" ]; then
  die "$EXIT_CONFIG" "No git remote 'origin' found"
fi

OWNER=$(printf '%s' "$url" | sed -E 's#.*github.com[:/]+([^/]+)/(.*)#\1#' | sed 's/.git$//' || true)
REPO=$(printf '%s' "$url" | sed -E 's#.*github.com[:/]+([^/]+)/([^./]+)(\.git)?#\2#' || true)
HEAD=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
BASE=$(git remote show origin 2>/dev/null | awk '/HEAD branch/ {print $NF}' || true)

# Validate derived values
[ -n "$OWNER" ] || die "$EXIT_CONFIG" "Could not derive owner from remote: $url"
[ -n "$REPO" ] || die "$EXIT_CONFIG" "Could not derive repo from remote: $url"
[ -n "$HEAD" ] || log_warn "Could not derive HEAD branch"
[ -n "$BASE" ] || log_warn "Could not derive BASE branch"

# Output based on format
case "$OUTPUT_FORMAT" in
  json)
    cat <<EOF
{
  "owner": "$OWNER",
  "repo": "$REPO",
  "head": "$HEAD",
  "base": "$BASE"
}
EOF
    ;;
  eval)
    printf 'OWNER="%s"\n' "$OWNER"
    printf 'REPO="%s"\n' "$REPO"
    printf 'HEAD="%s"\n' "$HEAD"
    printf 'BASE="%s"\n' "$BASE"
    ;;
  text)
    printf "owner=%s\n" "$OWNER"
    printf "repo=%s\n" "$REPO"
    printf "head=%s\n" "$HEAD"
    printf "base=%s\n" "$BASE"
    ;;
esac

exit 0

