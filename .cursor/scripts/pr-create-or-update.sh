#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Create or Update GitHub Pull Request (idempotent PR management)

# shellcheck disable=SC1090
source "$(dirname "$0")/.lib.sh"

VERSION="0.1.0"

TITLE=""
BODY=""
TITLE_PATTERN=""
BRANCH_PREFIX=""
OWNER=""
REPO=""
BASE="main"
HEAD=""
DRY_RUN=0
LABELS=()

usage() {
  print_usage "pr-create-or-update.sh --title <title> --title-pattern <pattern> --branch-prefix <prefix> [OPTIONS]"
  
  print_options
  print_option "--title TITLE" "PR title (required)"
  print_option "--body BODY" "PR body (required)"
  print_option "--title-pattern PATTERN" "Pattern to match existing PRs (required)"
  print_option "--branch-prefix PREFIX" "Branch prefix to match (required)"
  print_option "--owner OWNER" "Repository owner (required)"
  print_option "--repo REPO" "Repository name (required)"
  print_option "--head BRANCH" "Head branch (required)"
  print_option "--base BRANCH" "Base branch" "main"
  print_option "--label NAME" "Apply label (repeatable, for new PRs only)"
  print_option "--dry-run" "Print action without executing"
  print_option "--version" "Print version and exit"
  print_option "-h, --help" "Show this help and exit"
  
  cat <<'NOTES'

Notes:
  - Requires GH_TOKEN in env for API calls
  - Checks for existing PRs matching pattern + prefix + bot user
  - If found: updates title/body on existing PR
  - If not found: creates new PR with all options
  - Prevents duplicate PRs during workflow runs

NOTES
  
  print_examples
  print_example "Create or update archive PR" "pr-create-or-update.sh --title 'chore: archive (1)' --body 'Details' --title-pattern 'chore: archive' --branch-prefix 'bot/archive-' --owner org --repo repo --head bot/archive-123 --base main"
  print_example "With labels" "pr-create-or-update.sh --title 'chore: update' --body 'Body' --title-pattern 'chore: update' --branch-prefix 'bot/update-' --owner org --repo repo --head bot/update-456 --label skip-changeset"
  
  print_exit_codes
}

while [ $# -gt 0 ]; do
  case "$1" in
    --title) TITLE="${2:-}"; shift 2 ;;
    --body) BODY="${2:-}"; shift 2 ;;
    --title-pattern) TITLE_PATTERN="${2:-}"; shift 2 ;;
    --branch-prefix) BRANCH_PREFIX="${2:-}"; shift 2 ;;
    --owner) OWNER="${2:-}"; shift 2 ;;
    --repo) REPO="${2:-}"; shift 2 ;;
    --base) BASE="${2:-}"; shift 2 ;;
    --head) HEAD="${2:-}"; shift 2 ;;
    --label) LABELS+=("${2:-}"); shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --version) printf '%s\n' "$VERSION"; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    *) die 2 "Unknown argument: $1" ;;
  esac
done

[ -n "$TITLE" ] || die 2 "--title required"
[ -n "$TITLE_PATTERN" ] || die 2 "--title-pattern required"
[ -n "$BRANCH_PREFIX" ] || die 2 "--branch-prefix required"
[ -n "$OWNER" ] || die 2 "--owner required"
[ -n "$REPO" ] || die 2 "--repo required"
[ -n "$HEAD" ] || die 2 "--head required"

list_api="https://api.github.com/repos/${OWNER}/${REPO}/pulls?state=open&per_page=50"

if [ "${CURL_CMD-curl}" = "cat" ] || [ -n "${PR_LIST-}" ]; then
  pr_json=$(cat)
else
  : "${GH_TOKEN:?GH_TOKEN required}"
  pr_json=$(curl -sS -H "Authorization: token ${GH_TOKEN}" -H "Accept: application/vnd.github+json" "$list_api")
fi

MATCHING_PR=$(printf '%s' "$pr_json" | jq -r --arg pattern "$TITLE_PATTERN" --arg prefix "$BRANCH_PREFIX" '
  .[] | select(
    (.title | startswith($pattern)) and
    (.head.ref | startswith($prefix)) and
    (.user.login == "github-actions[bot]")
  ) | .number' | head -1 || true)

if [ -n "$MATCHING_PR" ] && [ "$MATCHING_PR" != "null" ]; then
  if [ $DRY_RUN -eq 1 ]; then
    printf '{"action":"update","pr_number":%s,"title":"%s"}\n' "$MATCHING_PR" "$TITLE"
    exit 0
  fi
  
  # Update existing PR and extract URL
  response=$(bash "$(dirname "$0")/pr-update.sh" --pr "$MATCHING_PR" --title "$TITLE" --body "$BODY" --owner "$OWNER" --repo "$REPO")
  printf '%s' "$response" | jq -r '.html_url'
else
  if [ $DRY_RUN -eq 1 ]; then
    printf '{"action":"create","title":"%s","head":"%s"}\n' "$TITLE" "$HEAD"
    exit 0
  fi
  
  # Create new PR and extract URL
  CREATE_CMD=("$(dirname "$0")/pr-create.sh" --title "$TITLE" --body "$BODY" --owner "$OWNER" --repo "$REPO" --base "$BASE" --head "$HEAD" --no-template)
  [ ${#LABELS[@]} -gt 0 ] && for lbl in "${LABELS[@]}"; do CREATE_CMD+=(--label "$lbl"); done
  response=$(bash "${CREATE_CMD[@]}")
  printf '%s' "$response" | jq -r '.html_url'
fi

