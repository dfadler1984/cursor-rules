#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# checks-status.sh — Provides guidance to check GitHub Checks status
# Networkless per D4/D5
#
# Usage:
#   .cursor/scripts/checks-status.sh [--sha <commit>] [--pr <number>] \
#     [--owner <o>] [--repo <r>] [--dry-run]

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"
source "$SCRIPT_DIR/.lib-net.sh"

usage() {
  cat <<'USAGE'
Usage: checks-status.sh [options]

Provides guidance to check GitHub Checks status for a commit or PR.

Note: This script does not perform network requests (networkless per D4/D5).
      Use the GitHub UI or `gh pr checks` to view check status.

Options:
  --sha <commit>      Commit SHA to inspect (default: HEAD)
  --pr <number>       Pull Request number
  --owner <o>         Repo owner (default: derived from git origin)
  --repo <r>          Repo name  (default: derived from git origin)
  --dry-run           Show what would be checked
  -h, --help          Show help

Examples:
  # Check CI status for current HEAD
  checks-status.sh
  
  # Check specific commit
  checks-status.sh --sha abc123def
  
  # Check PR (requires manual SHA lookup first)
  checks-status.sh --pr 123  # Will prompt for SHA
  
  # Dry-run to see what would be checked
  checks-status.sh --dry-run
USAGE
  
  print_exit_codes
}

owner=""
repo=""
sha=""
pr=""
dry_run=0

while [ $# -gt 0 ]; do
  case "$1" in
    --sha) sha="${2-}"; shift 2;;
    --pr) pr="${2-}"; shift 2;;
    --owner) owner="${2-}"; shift 2;;
    --repo) repo="${2-}"; shift 2;;
    --dry-run) dry_run=1; shift;;
    -h|--help) usage; exit 0;;
    *) die "$EXIT_USAGE" "Unknown arg: $1";;
  esac
done

# Derive owner/repo from origin if not provided
if [ -z "$owner" ] || [ -z "$repo" ]; then
  if git rev-parse --git-dir >/dev/null 2>&1; then
    url=$(git remote get-url origin 2>/dev/null || true)
    [ -n "$url" ] || die "$EXIT_CONFIG" "Unable to derive owner/repo; pass --owner/--repo"
    owner=$(printf '%s' "$url" | sed -E 's#.*github.com[:/]+([^/]+)/(.*)#\1#' | sed 's/.git$//')
    repo=$(printf '%s' "$url" | sed -E 's#.*github.com[:/]+([^/]+)/([^./]+)(\.git)?#\2#')
  else
    die "$EXIT_CONFIG" "Not a git repo; pass --owner and --repo"
  fi
fi

# Resolve SHA
if [ -n "$pr" ]; then
  log_warn "PR-based check lookup requires manual SHA resolution"
  log_info "To find head SHA for PR #$pr, use:"
  log_info "  gh pr view $pr --json headRefOid -q .headRefOid"
  log_info "Then run: $0 --sha <sha> --owner $owner --repo $repo"
  die "$EXIT_USAGE" "Provide --sha after looking up the PR's head SHA"
elif [ -z "$sha" ]; then
  sha=$(git rev-parse HEAD)
fi

# Build URLs
commit_url="https://github.com/${owner}/${repo}/commit/${sha}"
checks_url="${commit_url}/checks"

if [ $dry_run -eq 1 ]; then
  # Dry-run: show what would be checked (networkless)
  printf 'Would check CI status for:\n'
  printf '  Repository: %s/%s\n' "$owner" "$repo"
  printf '  Commit: %s\n' "$sha"
  printf '\n'
  printf 'Commit URL: %s\n' "$commit_url"
  printf 'Checks URL: %s\n' "$checks_url"
  exit 0
fi

# Non-dry-run: provide guidance (networkless per D4/D5)
net_guidance \
  "View GitHub Checks status for commit $sha" \
  "$checks_url"

log_info ""
log_info "To check CI status, use one of:"
log_info ""
log_info "  GitHub UI:"
log_info "    Visit: $checks_url"
log_info ""
log_info "  GitHub CLI:"
if [ -n "$pr" ]; then
  log_info "    gh pr checks $pr --repo ${owner}/${repo}"
else
  log_info "    gh pr checks --repo ${owner}/${repo}"
  log_info "    (if commit $sha is part of a PR)"
fi

exit 0


