#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Create a GitHub Pull Request via curl using GITHUB_TOKEN
# Usage: .cursor/scripts/pr-create.sh --title <t> [--body <b>] [--base <branch>] [--head <branch>] \
#        [--owner <o>] [--repo <r>] [--dry-run] [-h|--help] [--version]

# shellcheck disable=SC1090
source "$(dirname "$0")/.lib.sh"

VERSION="0.1.0"

TITLE=""
BODY=""
BASE=""
HEAD=""
OWNER=""
REPO=""
DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage: pr-create.sh --title <title> [--body <body>] [--base <branch>] [--head <branch>] \
                    [--owner <owner>] [--repo <repo>] [--dry-run] [--version] [-h|--help]

Notes:
  - Requires GITHUB_TOKEN in env for actual API calls
  - Owner/repo and head/base are auto-derived when omitted
USAGE
}

# derive owner/repo/head/base
derive_owner_repo() {
  if git rev-parse --git-dir >/dev/null 2>&1; then
    local url
    url=$(git remote get-url origin 2>/dev/null || true)
    OWNER=$(printf '%s' "$url" | sed -E 's#.*github.com[:/]+([^/]+)/(.*)#\1#' | sed 's/.git$//' || true)
    REPO=$(printf '%s' "$url" | sed -E 's#.*github.com[:/]+([^/]+)/([^./]+)(\.git)?#\2#' || true)
    HEAD=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
    BASE=$(git remote show origin 2>/dev/null | awk '/HEAD branch/ {print $NF}' || true)
  fi
}

while [ $# -gt 0 ]; do
  case "$1" in
    --title) TITLE="${2:-}"; shift 2 ;;
    --body) BODY="${2:-}"; shift 2 ;;
    --base) BASE="${2:-}"; shift 2 ;;
    --head) HEAD="${2:-}"; shift 2 ;;
    --owner) OWNER="${2:-}"; shift 2 ;;
    --repo) REPO="${2:-}"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --version) printf '%s\n' "$VERSION"; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    *) die 2 "Unknown argument: $1" ;;
  esac
done

[ -n "$TITLE" ] || die 2 "--title is required"

derive_owner_repo

[ -n "$OWNER" ] || die 1 "Unable to derive --owner; pass explicitly"
[ -n "$REPO" ] || die 1 "Unable to derive --repo; pass explicitly"
[ -n "$HEAD" ] || die 1 "Unable to derive --head; pass explicitly"
[ -n "$BASE" ] || BASE="main"

PAYLOAD=$(cat <<JSON
{
  "title": "$(json_escape "$TITLE")",
  "body": "$(json_escape "$BODY")",
  "base": "$(json_escape "$BASE")",
  "head": "$(json_escape "$HEAD")"
}
JSON
)

if [ $DRY_RUN -eq 1 ]; then
  printf '%s\n' "$PAYLOAD"
  exit 0
fi

: "${GITHUB_TOKEN:?GITHUB_TOKEN is required for API calls}"
require_cmd curl

API="https://api.github.com/repos/${OWNER}/${REPO}/pulls"

resp_file="$(mktemp 2>/dev/null || mktemp -t pr.json)"
status=$(curl -sS -w '%{http_code}' -o "$resp_file" \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  -X POST "$API" -d "$PAYLOAD")

if [ "$status" != "201" ]; then
  log_error "GitHub PR create failed (status $status)"
  if have_cmd jq; then
    jq '.' "$resp_file" >&2 || cat "$resp_file" >&2
  else
    cat "$resp_file" >&2
  fi
  # Fallback compare URL
  printf 'Compare URL: https://github.com/%s/%s/compare/%s...%s\n' "$OWNER" "$REPO" "$BASE" "$HEAD" >&2
  exit 1
fi

if have_cmd jq; then
  jq '.' "$resp_file"
else
  cat "$resp_file"
fi
