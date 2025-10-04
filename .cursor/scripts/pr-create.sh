#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Create a GitHub Pull Request via curl using GITHUB_TOKEN
# Usage: .cursor/scripts/pr-create.sh --title <t> [--body <b>] [--base <branch>] [--head <branch>] \
#        [--owner <o>] [--repo <r>] [--dry-run] [-h|--help] [--version]

# shellcheck disable=SC1090
source "$(dirname "$0")/.lib.sh"

VERSION="0.2.0"

TITLE=""
BODY=""
BASE=""
HEAD=""
OWNER=""
REPO=""
DRY_RUN=0

# Template injection controls
USE_TEMPLATE=1
TEMPLATE_PATH=""
BODY_APPEND=""

usage() {
  cat <<'USAGE'
Usage: pr-create.sh --title <title> [--body <body>] [--base <branch>] [--head <branch>] \
                    [--owner <owner>] [--repo <repo>] [--no-template] \
                    [--template <path>] [--body-append <text>] \
                    [--dry-run] [--version] [-h|--help]

Notes:
  - Requires GITHUB_TOKEN in env for actual API calls
  - Owner/repo and head/base are auto-derived when omitted
  - By default, the PR body is prefilled from .github/pull_request_template.md (if present)
    or the first file under .github/PULL_REQUEST_TEMPLATE/. Use --no-template to opt-out.
    Use --template <path> to select a specific template. Use --body-append to add
    extra context under a "## Context" section. When using --body without --no-template,
    the provided body is appended under "## Context" as well (backward-compatible).
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
    --no-template) USE_TEMPLATE=0; shift ;;
    --template) TEMPLATE_PATH="${2:-}"; shift 2 ;;
    --body-append) BODY_APPEND="${2:-}"; shift 2 ;;
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

# Discover and inject template content if enabled
compose_body_with_template() {
  local root tmpl candidate context_section composed
  root="$(repo_root)"
  if [ -n "$TEMPLATE_PATH" ]; then
    candidate="$TEMPLATE_PATH"
  else
    if [ -f "$root/.github/pull_request_template.md" ]; then
      candidate="$root/.github/pull_request_template.md"
    elif [ -d "$root/.github/PULL_REQUEST_TEMPLATE" ]; then
      # Pick first file by name for determinism
      candidate=$(find "$root/.github/PULL_REQUEST_TEMPLATE" -type f -maxdepth 1 2>/dev/null | sort | head -n1 || true)
    fi
  fi

  if [ -n "${candidate:-}" ] && [ -f "$candidate" ]; then
    tmpl="$(cat "$candidate")"
  else
    log_warn "PR template not found; proceeding without template injection"
    # Still compose a Context section if BODY/BODY_APPEND present
    if [ -n "${BODY:-}" ] || [ -n "${BODY_APPEND:-}" ]; then
      composed=""
      context_section="## Context\n"
      if [ -n "${BODY:-}" ]; then context_section+="$BODY\n"; fi
      if [ -n "${BODY_APPEND:-}" ]; then
        if [ -n "${BODY:-}" ]; then context_section+="\n"; fi
        context_section+="$BODY_APPEND\n"
      fi
      composed+="$context_section"
      BODY="${composed}"
    fi
    return 0
  fi

  composed="$tmpl"

  # Build Context section if any extra content supplied
  if [ -n "${BODY:-}" ] || [ -n "${BODY_APPEND:-}" ]; then
    context_section="## Context\n"
    if [ -n "${BODY:-}" ]; then
      context_section+="$BODY\n"
    fi
    if [ -n "${BODY_APPEND:-}" ]; then
      # Separate with a blank line if both present
      if [ -n "${BODY:-}" ]; then
        context_section+="\n"
      fi
      context_section+="$BODY_APPEND\n"
    fi
    composed+="\n\n${context_section}"
  fi

  BODY="$composed"
}

if [ $USE_TEMPLATE -eq 1 ]; then
  compose_body_with_template
fi

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
