#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Create a GitHub Pull Request via curl using GH_TOKEN
# Usage: .cursor/scripts/pr-create.sh --title <t> [--body <b>] [--base <branch>] [--head <branch>] \
#        [--owner <o>] [--repo <r>] [--dry-run] [-h|--help] [--version]

# shellcheck disable=SC1090
source "$(dirname "$0")/.lib.sh"

VERSION="0.4.0"

TITLE=""
BODY=""
BASE=""
HEAD=""
OWNER=""
REPO=""
DRY_RUN=0
LABELS=()

# Template injection controls
USE_TEMPLATE=1
TEMPLATE_PATH=""
BODY_APPEND=""
# Body composition controls
REPLACE_BODY=0
SKIP_CONTEXT=0

usage() {
  print_usage "pr-create.sh --title <title> [OPTIONS]"
  
  print_options
  print_option "--title TITLE" "PR title (required)"
  print_option "--body BODY" "PR body (appended to template unless --replace-body)"
  print_option "--base BRANCH" "Base branch" "auto-detected or main"
  print_option "--head BRANCH" "Head branch" "current branch"
  print_option "--owner OWNER" "Repository owner" "auto-detected from origin"
  print_option "--repo REPO" "Repository name" "auto-detected from origin"
  print_option "--template PATH" "Use specific PR template" "auto-detected"
  print_option "--body-append TEXT" "Append text under Context section"
  print_option "--no-template" "Disable template injection"
  print_option "--replace-body" "Use exact body (bypass template and context)"
  print_option "--label NAME" "Apply label after creation (repeatable)"
  print_option "--docs-only" "Shortcut for --label skip-changeset"
  print_option "--dry-run" "Print payload without creating PR"
  print_option "--version" "Print version and exit"
  print_option "-h, --help" "Show this help and exit"
  
  cat <<'NOTES'

Notes:
  - Requires GH_TOKEN in env for actual API calls
  - Owner/repo and head/base are auto-derived when omitted
  - By default, the PR body is prefilled from .github/pull_request_template.md (if present)
    or the first file under .github/PULL_REQUEST_TEMPLATE/. Use --no-template to opt-out.
  - Use --template <path> to select a specific template.
  - Use --body-append to add extra context under a "## Context" section.
  - When using --body without --no-template, provided body is appended under "## Context".
  - Use --replace-body to bypass templates; BODY becomes the exact PR body.
  - Labels require jq for PR number extraction.

NOTES
  
  print_examples
  print_example "Create PR with title and body" "pr-create.sh --title \"Add feature X\" --body \"Implements feature X\""
  print_example "Dry-run to see payload" "pr-create.sh --title \"Fix bug\" --dry-run"
  print_example "Create PR with labels" "pr-create.sh --title \"Update docs\" --docs-only"
  print_example "Create PR without template" "pr-create.sh --title \"Quick fix\" --no-template --body \"Simple change\""
  
  print_exit_codes
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
    --replace-body) REPLACE_BODY=1; shift ;;
    --label) LABELS+=("${2:-}"); shift 2 ;;
    --docs-only) LABELS+=("skip-changeset"); shift ;;
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

# If replacing body, disable templates and context injection entirely
if [ $REPLACE_BODY -eq 1 ]; then
  USE_TEMPLATE=0
  SKIP_CONTEXT=1
fi

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
    if [ $SKIP_CONTEXT -eq 0 ] && { [ -n "${BODY:-}" ] || [ -n "${BODY_APPEND:-}" ]; }; then
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

# Auto-replace heuristic: if BODY appears to be a full PR body (starts with a heading like '## Summary'),
# prefer exact replacement to avoid duplicating the template. This keeps CLI simple without new flags.
if [ $REPLACE_BODY -eq 0 ] && [ -n "${BODY:-}" ]; then
  if printf '%s' "$BODY" | grep -qE '^##[[:space:]]+Summary'; then
    REPLACE_BODY=1
    USE_TEMPLATE=0
    SKIP_CONTEXT=1
  fi
fi

if [ $USE_TEMPLATE -eq 1 ]; then
  compose_body_with_template
fi

# Build labels JSON array for dry-run display and later API body if needed
labels_json=""
if [ ${#LABELS[@]} -gt 0 ]; then
  labels_json="["
  for i in "${!LABELS[@]}"; do
    if [ "$i" -gt 0 ]; then labels_json+=","; fi
    labels_json+="\"$(json_escape "${LABELS[$i]}")\""
  done
  labels_json+="]"
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

# Compose a dry-run payload that includes labels (for testability) without affecting real API payload
if [ $DRY_RUN -eq 1 ]; then
  if [ -n "$labels_json" ]; then
    DRY_PAYLOAD=$(cat <<JSON
{
  "title": "$(json_escape "$TITLE")",
  "body": "$(json_escape "$BODY")",
  "base": "$(json_escape "$BASE")",
  "head": "$(json_escape "$HEAD")",
  "labels": $labels_json
}
JSON
)
  else
    DRY_PAYLOAD="$PAYLOAD"
  fi
  printf '%s\n' "$DRY_PAYLOAD"
  exit 0
fi

: "${GH_TOKEN:?GH_TOKEN is required for API calls}"
require_cmd curl

API="https://api.github.com/repos/${OWNER}/${REPO}/pulls"

resp_file="$(mktemp 2>/dev/null || mktemp -t pr.json)"
status=$(curl -sS -w '%{http_code}' -o "$resp_file" \
  -H "Authorization: token ${GH_TOKEN}" \
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

# If labels were requested, add them via Issues API
if [ -n "$labels_json" ]; then
  require_cmd jq
  pr_number=$(jq -r '.number' "$resp_file" 2>/dev/null || true)
  if [ -z "$pr_number" ] || [ "$pr_number" = "null" ]; then
    die 1 "Failed to extract PR number for labeling"
  fi
  labels_api="https://api.github.com/repos/${OWNER}/${REPO}/issues/${pr_number}/labels"
  labels_body=$(cat <<JSON
{"labels": $labels_json}
JSON
)
  label_status=$(curl -sS -w '%{http_code}' -o /dev/stderr \
    -H "Authorization: token ${GH_TOKEN}" \
    -H "Accept: application/vnd.github+json" \
    -X POST "$labels_api" -d "$labels_body")
  case "$label_status" in
    200|201) : ;; # ok
    *) die 1 "Labeling failed (status $label_status)" ;;
  esac
fi

if have_cmd jq; then
  jq '.' "$resp_file"
else
  cat "$resp_file"
fi
