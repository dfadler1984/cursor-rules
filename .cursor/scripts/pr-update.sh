#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Update an existing GitHub Pull Request title/body via API
# Usage:
#   .cursor/scripts/pr-update.sh (--pr <number> | --head <branch>) [--title <t>] [--body <b>] [--owner <o>] [--repo <r>] [--dry-run]

# shellcheck disable=SC1090
source "$(dirname "$0")/.lib.sh"

VERSION="0.1.0"

PR_NUMBER=""
HEAD_BRANCH=""
TITLE=""
BODY=""
OWNER=""
REPO=""
DRY_RUN=0

usage() {
  print_usage "pr-update.sh (--pr <number> | --head <branch>) [OPTIONS]"
  
  print_options
  print_option "--pr NUMBER" "PR number to update (mutually exclusive with --head)"
  print_option "--head BRANCH" "Find PR by head branch (mutually exclusive with --pr)"
  print_option "--title TITLE" "New PR title (optional)"
  print_option "--body BODY" "New PR body (optional)"
  print_option "--owner OWNER" "Repository owner" "auto-detected from origin"
  print_option "--repo REPO" "Repository name" "auto-detected from origin"
  print_option "--dry-run" "Print payload without updating PR"
  print_option "--version" "Print version and exit"
  print_option "-h, --help" "Show this help and exit"
  
  cat <<'NOTES'

Notes:
  - Requires GH_TOKEN in env for actual API calls
  - Owner/repo auto-derived from git origin when omitted
  - Either --title or --body must be provided (or both)

NOTES
  
  print_examples
  print_example "Update PR title by number" "pr-update.sh --pr 123 --title \"New title\""
  print_example "Update PR body by head branch" "pr-update.sh --head my-feature --body \"Updated description\""
  print_example "Update both title and body" "pr-update.sh --pr 123 --title \"Fix\" --body \"Fixes issue\""
  print_example "Dry-run to see payload" "pr-update.sh --pr 123 --title \"Test\" --dry-run"
  
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

# Resolve PR number via head branch when needed
if [ -z "$PR_NUMBER" ]; then
  # seam for tests: when PR_LIST is set, read JSON from stdin
  list_api="https://api.github.com/repos/${OWNER}/${REPO}/pulls?head=${OWNER}:${HEAD_BRANCH}"
  if [ "${CURL_CMD-curl}" = "cat" ] || [ -n "${PR_LIST-}" ]; then
    pr_json=$(cat)
  else
    : "${GH_TOKEN:?GH_TOKEN is required for API calls}"
    resp_file="$(mktemp 2>/dev/null || mktemp -t pr-list.json)"
    code=$(curl -sS -w '%{http_code}' -o "$resp_file" \
      -H "Authorization: token ${GH_TOKEN}" \
      -H "Accept: application/vnd.github+json" \
      "$list_api")
    if [ "$code" != "200" ]; then
      log_error "GitHub PR list failed (status $code) for head=${OWNER}:${HEAD_BRANCH}"
      if have_cmd jq; then jq '.' "$resp_file" >&2 || cat "$resp_file" >&2; else cat "$resp_file" >&2; fi
      exit 1
    fi
    pr_json="$(cat "$resp_file")"
  fi
  PR_NUMBER=$(printf '%s' "$pr_json" | ${JQ_CMD-jq} -r '.[0].number')
  [ "$PR_NUMBER" != "null" ] && [ -n "$PR_NUMBER" ] || die 1 "Unable to resolve PR number for head=${HEAD_BRANCH}"
fi

json_string_or_null() {
  # prints a JSON string when non-empty, otherwise JSON null
  jq -Rn --arg s "$1" 'if ($s|length)>0 then $s else null end'
}

TITLE_JSON=$(json_string_or_null "$TITLE")
BODY_JSON=$(json_string_or_null "$BODY")

payload=$(cat <<JSON
{
  "title": ${TITLE_JSON},
  "body": ${BODY_JSON}
}
JSON
)

url="https://api.github.com/repos/${OWNER}/${REPO}/pulls/${PR_NUMBER}"

if [ $DRY_RUN -eq 1 ]; then
  printf '{"method":"PATCH","url":"%s","payload":%s}\n' "$url" "$payload"
  exit 0
fi

: "${GH_TOKEN:?GH_TOKEN is required for API calls}"

resp_file="$(mktemp 2>/dev/null || mktemp -t pr-update.json)"
code=$(curl -sS -w '%{http_code}' -o "$resp_file" \
  -H "Authorization: token ${GH_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  -X PATCH "$url" -d "$payload")

if [ "$code" != "200" ]; then
  log_error "GitHub PR update failed (status $code)"
  if have_cmd jq; then jq '.' "$resp_file" >&2 || cat "$resp_file" >&2; else cat "$resp_file" >&2; fi
  exit 1
fi

if have_cmd jq; then jq '.' "$resp_file"; else cat "$resp_file"; fi


