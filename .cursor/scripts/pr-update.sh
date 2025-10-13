#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Update an existing GitHub Pull Request title/body
# Provides guidance for manual updates (networkless per D4/D5)
# Usage:
#   .cursor/scripts/pr-update.sh (--pr <number> | --head <branch>) [--title <t>] [--body <b>] [--owner <o>] [--repo <r>] [--dry-run]

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"
source "$SCRIPT_DIR/.lib-net.sh"

VERSION="0.1.0"

PR_NUMBER=""
HEAD_BRANCH=""
TITLE=""
BODY=""
OWNER=""
REPO=""
DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage: pr-update.sh (--pr <number> | --head <branch>) [--title <title>] [--body <body>] \
                    [--owner <owner>] [--repo <repo>] [--dry-run] [--version] [-h|--help]

Provides guidance to update a GitHub Pull Request title/body.

Note: This script does not perform network requests (networkless per D4/D5).
      Use the GitHub UI or `gh pr edit` to update PRs.

Options:
  --pr <number>       PR number (required, OR use --head)
  --head <branch>     Find PR by head branch (requires manual lookup)
  --title <title>     New PR title (required, OR use --body)
  --body <body>       New PR body
  --owner <owner>     Repository owner (auto-derived from git origin)
  --repo <repo>       Repository name (auto-derived from git origin)
  --dry-run           Show what would be updated
  --version           Print version
  -h, --help          Show this help

Examples:
  # Update PR title (dry-run first)
  pr-update.sh --pr 123 --title "New Title" --dry-run
  pr-update.sh --pr 123 --title "New Title"
  
  # Update PR body
  pr-update.sh --pr 123 --body "Updated description"
  
  # Update both title and body
  pr-update.sh --pr 123 --title "Fix" --body "Resolves #456"
USAGE
  
  print_exit_codes
}

derive_owner_repo() {
  if git rev-parse --git-dir >/dev/null 2>&1; then
    local url
    url=$(git remote get-url origin 2>/dev/null || true)
    OWNER=$(printf '%s' "$url" | sed -E 's#.*github.com[:/]+([^/]+)/(.*)#\1#' | sed 's/.git$//' || true)
    REPO=$(printf '%s' "$url" | sed -E 's#.*github.com[:/]+([^/]+)/([^./]+)(\.git)?#\2#' || true)
  fi
}

while [ $# -gt 0 ]; do
  case "$1" in
    --pr) PR_NUMBER="${2:-}"; shift 2 ;;
    --head) HEAD_BRANCH="${2:-}"; shift 2 ;;
    --title) TITLE="${2:-}"; shift 2 ;;
    --body) BODY="${2:-}"; shift 2 ;;
    --owner) OWNER="${2:-}"; shift 2 ;;
    --repo) REPO="${2:-}"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --version) printf '%s\n' "$VERSION"; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    *) die 2 "Unknown argument: $1" ;;
  esac
done

derive_owner_repo
[ -n "$OWNER" ] || die 1 "Unable to derive --owner; pass explicitly"
[ -n "$REPO" ] || die 1 "Unable to derive --repo; pass explicitly"

if [ -z "$PR_NUMBER" ] && [ -z "$HEAD_BRANCH" ]; then
  die 2 "Specify --pr <number> or --head <branch>"
fi

if [ -z "$TITLE" ] && [ -z "$BODY" ]; then
  die 2 "Provide --title and/or --body"
fi

# Note PR resolution requirement when using --head
if [ -z "$PR_NUMBER" ]; then
  log_warn "PR number not specified; --head requires manual PR lookup"
  log_info "To find PR number for branch '$HEAD_BRANCH', use:"
  log_info "  gh pr list --head '$HEAD_BRANCH'"
  log_info "  Or visit: https://github.com/${OWNER}/${REPO}/pulls?q=is:pr+head:${HEAD_BRANCH}"
  die "$EXIT_USAGE" "Provide --pr <number> after looking up the PR"
fi

# Build PR URL
pr_url="https://github.com/${OWNER}/${REPO}/pull/${PR_NUMBER}"

if [ $DRY_RUN -eq 1 ]; then
  # Dry-run: show what would be updated (networkless)
  printf 'Would update PR #%s:\n' "$PR_NUMBER"
  printf '  Repository: %s/%s\n' "$OWNER" "$REPO"
  [ -n "$TITLE" ] && printf '  New title: %s\n' "$TITLE"
  [ -n "$BODY" ] && printf '  New body: %s\n' "$BODY"
  printf '\n'
  printf 'PR URL: %s\n' "$pr_url"
  exit 0
fi

# Non-dry-run: provide guidance (networkless per D4/D5)
net_guidance \
  "Manually update PR #$PR_NUMBER" \
  "$pr_url"

log_info ""
log_info "To update this PR, use one of:"
log_info ""
log_info "  GitHub UI:"
log_info "    1. Visit: $pr_url"
log_info "    2. Click 'Edit' next to the title or description"
[ -n "$TITLE" ] && log_info "    3. Set title to: $TITLE"
[ -n "$BODY" ] && log_info "    4. Set body to: $BODY"
log_info ""
log_info "  GitHub CLI:"
gh_cmd="gh pr edit $PR_NUMBER --repo ${OWNER}/${REPO}"
[ -n "$TITLE" ] && gh_cmd+=" --title '$TITLE'"
[ -n "$BODY" ] && gh_cmd+=" --body '$BODY'"
log_info "    $gh_cmd"


