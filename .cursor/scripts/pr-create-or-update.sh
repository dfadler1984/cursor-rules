#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Create or Update GitHub Pull Request (idempotent PR management)
#
# Checks if a PR matching criteria exists and updates it, otherwise creates new.

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
    *) die 2 "Unknown argument: $1" ;;
  esac
done

[ -n "$TITLE" ] || die 2 "--title required"
[ -n "$TITLE_PATTERN" ] || die 2 "--title-pattern required"
[ -n "$BRANCH_PREFIX" ] || die 2 "--branch-prefix required"
[ -n "$OWNER" ] || die 2 "--owner required"
[ -n "$REPO" ] || die 2 "--repo required"
[ -n "$HEAD" ] || die 2 "--head required"

# Check for existing PR matching criteria
list_api="https://api.github.com/repos/${OWNER}/${REPO}/pulls?state=open&per_page=50"

if [ "${CURL_CMD-curl}" = "cat" ] || [ -n "${PR_LIST-}" ]; then
  pr_json=$(cat)
else
  : "${GH_TOKEN:?GH_TOKEN required}"
  pr_json=$(curl -sS -H "Authorization: token ${GH_TOKEN}" -H "Accept: application/vnd.github+json" "$list_api")
fi

# Find matching PR
MATCHING_PR=$(printf '%s' "$pr_json" | jq -r --arg pattern "$TITLE_PATTERN" --arg prefix "$BRANCH_PREFIX" '
  .[] | select(
    (.title | startswith($pattern)) and
    (.head.ref | startswith($prefix)) and
    (.user.login == "github-actions[bot]")
  ) | .number' | head -1 || true)

if [ -n "$MATCHING_PR" ] && [ "$MATCHING_PR" != "null" ]; then
  # Update existing PR
  if [ $DRY_RUN -eq 1 ]; then
    printf '{"action":"update","pr_number":%s,"title":"%s"}\n' "$MATCHING_PR" "$TITLE"
    exit 0
  fi
  
  bash "$(dirname "$0")/pr-update.sh" --pr "$MATCHING_PR" --title "$TITLE" --body "$BODY" --owner "$OWNER" --repo "$REPO"
else
  # Create new PR
  if [ $DRY_RUN -eq 1 ]; then
    printf '{"action":"create","title":"%s","head":"%s"}\n' "$TITLE" "$HEAD"
    exit 0
  fi
  
  CREATE_CMD=("$(dirname "$0")/pr-create.sh" --title "$TITLE" --body "$BODY" --owner "$OWNER" --repo "$REPO" --base "$BASE" --head "$HEAD" --no-template)
  [ ${#LABELS[@]} -gt 0 ] && for lbl in "${LABELS[@]}"; do CREATE_CMD+=(--label "$lbl"); done
  
  bash "${CREATE_CMD[@]}"
fi
