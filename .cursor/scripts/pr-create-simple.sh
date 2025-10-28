#!/usr/bin/env bash
# Test comment for hooks validation
set -euo pipefail
IFS=$'\n\t'

# Create a GitHub Pull Request (simplified, Unix Philosophy compliant)
# Usage: pr-create-simple.sh --title <title> --body <body> [--base <branch>] [--head <branch>]
#
# Extracted/simplified from pr-create.sh for Unix Philosophy compliance:
# - Do one thing: create PRs only (no labels, no templates)
# - Small & focused: ~120 lines vs 282 in pr-create.sh
# - Composable: can be piped with git-context, pr-label, etc.

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

VERSION="1.1.0"

# Default values
TITLE=""
BODY=""
BASE=""
HEAD=""
OWNER=""
REPO=""
DRY_RUN=0
OUTPUT_FORMAT="text"  # text|json
VALIDATE=1  # Validate PR description after creation

usage() {
  print_help_header "pr-create-simple.sh" "$VERSION" "Create a GitHub Pull Request (simplified)"
  print_usage "pr-create-simple.sh --title <title> --body <body> [OPTIONS]"
  
  print_options
  print_option "--title TITLE" "PR title (required)"
  print_option "--body BODY" "PR body (required)"
  print_option "--base BRANCH" "Base branch" "auto-detected or main"
  print_option "--head BRANCH" "Head branch" "current branch"
  print_option "--owner OWNER" "Repository owner" "auto-detected from git"
  print_option "--repo REPO" "Repository name" "auto-detected from git"
  print_option "--format FORMAT" "Output format: text|json" "text"
  print_option "--no-validate" "Skip post-creation description validation"
  print_option "--dry-run" "Show payload without creating PR"
  print_option "--version" "Print version and exit"
  print_option "-h, --help" "Show this help and exit"
  
  cat <<'NOTES'

Notes:
  - Does one thing: creates PRs with title and body
  - No template handling (prepare body externally)
  - No label management (use pr-label.sh afterward)
  - Requires GH_TOKEN for actual API calls
  - Returns PR URL or JSON response
  - Validates description after creation (disable with --no-validate)

Composition:
  # Derive context, create PR, add labels
  eval $(git-context.sh --format eval)
  pr_url=$(pr-create-simple.sh --title "..." --body "...")
  pr_number=$(echo "$pr_url" | grep -oE '[0-9]+$')
  pr-label.sh --pr "$pr_number" --label bug

NOTES
  
  print_examples
  print_example "Create PR with auto-detect" "pr-create-simple.sh --title \"Fix bug\" --body \"Details here\""
  print_example "Specify all params" "pr-create-simple.sh --title \"Feature\" --body \"...\" --base main --head feature/x"
  print_example "Dry-run" "pr-create-simple.sh --title \"Test\" --body \"Test\" --dry-run"
  print_example "Skip validation" "pr-create-simple.sh --title \"Test\" --body \"Test\" --no-validate"
  
  print_exit_codes
}

# Parse arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --title) TITLE="${2:-}"; shift 2 ;;
    --body) BODY="${2:-}"; shift 2 ;;
    --base) BASE="${2:-}"; shift 2 ;;
    --head) HEAD="${2:-}"; shift 2 ;;
    --owner) OWNER="${2:-}"; shift 2 ;;
    --repo) REPO="${2:-}"; shift 2 ;;
    --format) OUTPUT_FORMAT="${2:-}"; shift 2 ;;
    --no-validate) VALIDATE=0; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --version) printf '%s\n' "$VERSION"; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    *) die "$EXIT_USAGE" "Unknown argument: $1" ;;
  esac
done

# Validate required args
[ -n "$TITLE" ] || die "$EXIT_USAGE" "--title is required"
[ -n "$BODY" ] || die "$EXIT_USAGE" "--body is required"

# Save explicit parameters
EXPLICIT_OWNER="$OWNER"
EXPLICIT_REPO="$REPO"
EXPLICIT_HEAD="$HEAD"
EXPLICIT_BASE="$BASE"

# Auto-detect context for missing values
if git rev-parse --git-dir >/dev/null 2>&1; then
  url=$(git remote get-url origin 2>/dev/null || true)
  [ -n "$OWNER" ] || OWNER=$(printf '%s' "$url" | sed -E 's#.*github.com[:/]+([^/]+)/(.*)#\1#' | sed 's/.git$//' || true)
  [ -n "$REPO" ] || REPO=$(printf '%s' "$url" | sed -E 's#.*github.com[:/]+([^/]+)/([^./]+)(\.git)?#\2#' || true)
  [ -n "$HEAD" ] || HEAD=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
  [ -n "$BASE" ] || BASE=$(git remote show origin 2>/dev/null | awk '/HEAD branch/ {print $NF}' || true)
fi

# Restore explicit parameters (they take precedence)
[ -n "$EXPLICIT_OWNER" ] && OWNER="$EXPLICIT_OWNER"
[ -n "$EXPLICIT_REPO" ] && REPO="$EXPLICIT_REPO"
[ -n "$EXPLICIT_HEAD" ] && HEAD="$EXPLICIT_HEAD"
[ -n "$EXPLICIT_BASE" ] && BASE="$EXPLICIT_BASE"

# Validate derived values
[ -n "$OWNER" ] || die "$EXIT_CONFIG" "Could not determine owner"
[ -n "$REPO" ] || die "$EXIT_CONFIG" "Could not determine repo"
[ -n "$HEAD" ] || die "$EXIT_CONFIG" "Could not determine head branch"
[ -z "$BASE" ] && BASE="main"  # Final fallback

# Build PR payload
PAYLOAD=$(cat <<JSON
{
  "title": "$(json_escape "$TITLE")",
  "body": "$(json_escape "$BODY")",
  "base": "$(json_escape "$BASE")",
  "head": "$(json_escape "$HEAD")"
}
JSON
)

# Dry-run output
if [ $DRY_RUN -eq 1 ]; then
  if [ "$OUTPUT_FORMAT" = "json" ]; then
    echo "$PAYLOAD"
  else
    log_info "Would create PR: $OWNER/$REPO"
    log_info "  title: $TITLE"
    log_info "  base: $BASE ← head: $HEAD"
    printf "\nPayload:\n%s\n" "$PAYLOAD" >&2
  fi
  exit 0
fi

# Real API call
: "${GH_TOKEN:?GH_TOKEN is required for API calls}"

tmpfile=$(mktemp) || die "$EXIT_INTERNAL" "Failed to create temp file"
trap_cleanup "$tmpfile"

api_url="https://api.github.com/repos/${OWNER}/${REPO}/pulls"

set +e
http_status=$(curl -sS -w '%{http_code}' -o "$tmpfile" \
  -H "Authorization: token ${GH_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  -X POST "$api_url" -d "$PAYLOAD" 2>/dev/null)
set -e

case "$http_status" in
  201)
    if [ "$OUTPUT_FORMAT" = "json" ]; then
      cat "$tmpfile"
    else
      pr_url=$(grep -o '"html_url": *"[^"]*"' "$tmpfile" | head -1 | sed 's/.*"\(https[^"]*\)".*/\1/')
      echo "$pr_url"
    fi
    
    # Post-creation validation
    if [ "$VALIDATE" -eq 1 ]; then
      pr_number=$(grep -o '"number": *[0-9]*' "$tmpfile" | head -1 | sed 's/[^0-9]//g')
      
      log_info "Validating PR description..." >&2
      
      if "$SCRIPT_DIR/pr-validate-description.sh" --pr "$pr_number" --owner "$OWNER" --repo "$REPO" >&2; then
        : # Validation passed, continue
      else
        log_error "PR created but description validation failed!" >&2
        log_error "You may need to update the PR manually or re-run pr-update.sh" >&2
        exit 4
      fi
    fi
    ;;
  *)
    log_error "PR creation failed (HTTP $http_status)"
    cat "$tmpfile" >&2
    exit "$EXIT_NETWORK"
    ;;
esac

exit 0
