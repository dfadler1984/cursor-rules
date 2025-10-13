#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Create a GitHub Pull Request - Provides guidance for manual creation
# Networkless per D4/D5
# Usage: .cursor/scripts/pr-create.sh --title <t> [--body <b>] [--base <branch>] [--head <branch>] \
#        [--owner <o>] [--repo <r>] [--dry-run] [-h|--help] [--version]

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"
source "$SCRIPT_DIR/.lib-net.sh"

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
  cat <<'USAGE'
Usage: pr-create.sh --title <title> [--body <body>] [--base <branch>] [--head <branch>] \
                    [--owner <owner>] [--repo <repo>] [--no-template] \
                    [--template <path>] [--body-append <text>] [--replace-body] \
                    [--label <name>] [--docs-only] [--dry-run] [--version] [-h|--help]

Provides guidance to create a GitHub Pull Request with templates.

Note: This script does not perform network requests (networkless per D4/D5).
      Use the GitHub compare URL or `gh pr create` to open PRs.

Options:
  --title <title>     PR title (required)
  --body <body>       PR body content
  --base <branch>     Base branch (default: auto-derived from origin)
  --head <branch>     Head branch (default: current branch)
  --owner <owner>     Repository owner (default: auto-derived)
  --repo <repo>       Repository name (default: auto-derived)
  --no-template       Skip PR template injection
  --template <path>   Use specific template file
  --body-append <txt> Add context under ## Context section
  --replace-body      Use body exactly (bypass templates)
  --label <name>      Note labels to apply (informational only)
  --docs-only         Alias for --label skip-changeset
  --dry-run           Show PR details without guidance
  --version           Print version
  -h, --help          Show this help

Examples:
  # Show PR creation guidance (dry-run)
  pr-create.sh --title "Add new feature" --dry-run
  
  # Create PR with body
  pr-create.sh --title "Fix bug" --body "Resolves issue with parser"
  
  # Create PR without template
  pr-create.sh --title "Update docs" --no-template --docs-only
  
  # Create PR with labels noted
  pr-create.sh --title "Feature X" --label "enhancement" --label "v2"
USAGE
  
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

# Build compare URL for manual PR creation
compare_url="https://github.com/${OWNER}/${REPO}/compare/${BASE}...${HEAD}"

# Provide guidance for manual PR creation (networkless per D4/D5)
net_guidance \
  "Manually create PR: $TITLE" \
  "$compare_url"

log_info ""
log_info "To create this PR, use one of:"
log_info ""
log_info "  GitHub UI:"
log_info "    1. Visit: $compare_url"
log_info "    2. Click 'Create pull request'"
log_info "    3. Title: $TITLE"
if [ -n "$BODY" ]; then
  log_info "    4. Body (copy below):"
  log_info ""
  log_info "--- BEGIN PR BODY ---"
  printf '%s\n' "$BODY" | sed 's/^/       /'
  log_info "--- END PR BODY ---"
  log_info ""
fi

if [ "${#LABELS[@]}" -gt 0 ]; then
  log_info "    5. Add labels: ${LABELS[*]}"
fi

log_info ""
log_info "  GitHub CLI:"
gh_cmd="gh pr create --repo ${OWNER}/${REPO} --base ${BASE} --head ${HEAD} --title '$TITLE'"
if [ -n "$BODY" ]; then
  # For gh CLI, save body to temp file for easier handling
  body_file="$(mktemp 2>/dev/null || mktemp -t pr-body)"
  printf '%s' "$BODY" > "$body_file"
  gh_cmd+=" --body-file '$body_file'"
  log_info "    $gh_cmd"
  log_info "    (Body saved to: $body_file)"
else
  gh_cmd+=" --body ''"
  log_info "    $gh_cmd"
fi

if [ "${#LABELS[@]}" -gt 0 ]; then
  for label in "${LABELS[@]}"; do
    log_info "    # Then add labels:"
    log_info "    gh pr edit <number> --add-label '$label'"
  done
fi
