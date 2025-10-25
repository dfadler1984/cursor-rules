#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Validate that a PR has a proper description (not null, not template)
# Usage: pr-validate-description.sh --pr <number> [--owner <o>] [--repo <r>]

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

VERSION="1.0.0"

PR_NUMBER=""
OWNER=""
REPO=""
EXPECTED_BODY=""  # Optional: body that was intended to be set

usage() {
  print_help_header "pr-validate-description.sh" "$VERSION" "Validate PR description"
  print_usage "pr-validate-description.sh --pr <number> [OPTIONS]"
  
  print_options
  print_option "--pr NUMBER" "PR number to validate (required)"
  print_option "--owner OWNER" "Repository owner" "auto-detected from git"
  print_option "--repo REPO" "Repository name" "auto-detected from git"
  print_option "--expected BODY" "Expected body content" "any non-empty, non-template"
  print_option "--version" "Print version and exit"
  print_option "-h, --help" "Show this help and exit"
  
  cat <<'NOTES'

Notes:
  - Fetches PR via API and checks body field
  - Fails if body is null, empty, or matches default template
  - Requires GH_TOKEN for API calls

Exit Codes:
  0 - Validation passed (body is properly set)
  1 - Validation failed (body is null/empty/template)
  2 - Usage error
  3 - API error

NOTES
  
  print_examples
  print_example "Validate PR description" "pr-validate-description.sh --pr 197"
  print_example "Check against expected body" "pr-validate-description.sh --pr 197 --expected \"## Summary...\""
}

derive_owner_repo() {
  if git rev-parse --git-dir >/dev/null 2>&1; then
    local url
    url=$(git remote get-url origin 2>/dev/null || true)
    OWNER=$(printf '%s' "$url" | sed -E 's#.*github.com[:/]+([^/]+)/(.*)#\1#' | sed 's/.git$//' || true)
    REPO=$(printf '%s' "$url" | sed -E 's#.*github.com[:/]+([^/]+)/([^./]+)(\.git)?#\2#' || true)
  fi
}

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --pr) PR_NUMBER="${2:-}"; shift 2 ;;
    --owner) OWNER="${2:-}"; shift 2 ;;
    --repo) REPO="${2:-}"; shift 2 ;;
    --expected) EXPECTED_BODY="${2:-}"; shift 2 ;;
    --version) printf '%s\n' "$VERSION"; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    *) die 2 "Unknown argument: $1" ;;
  esac
done

# Validate required args
[ -n "$PR_NUMBER" ] || die 2 "--pr is required"

# Derive owner/repo if not provided
derive_owner_repo
[ -n "$OWNER" ] || die 2 "Could not determine owner; pass --owner explicitly"
[ -n "$REPO" ] || die 2 "Could not determine repo; pass --repo explicitly"

# Fetch PR
: "${GH_TOKEN:?GH_TOKEN is required for API calls}"

tmpfile=$(mktemp) || die 3 "Failed to create temp file"
trap_cleanup "$tmpfile"

api_url="https://api.github.com/repos/${OWNER}/${REPO}/pulls/${PR_NUMBER}"

log_info "Fetching PR #${PR_NUMBER} to validate description..."

set +e
http_status=$(curl -sS -w '%{http_code}' -o "$tmpfile" \
  -H "Authorization: token ${GH_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  "$api_url" 2>/dev/null)
set -e

if [ "$http_status" != "200" ]; then
  log_error "Failed to fetch PR #${PR_NUMBER} (HTTP ${http_status})"
  cat "$tmpfile" >&2
  exit 3
fi

# Extract body field using grep/sed (avoid jq dependency)
body=$(grep -o '"body": *"[^"]*"' "$tmpfile" | head -1 | sed 's/.*"body": *"\(.*\)".*/\1/' || echo "null")

# Check if body is null (literal string "null" from JSON)
if [ "$body" = "null" ]; then
  log_error "Validation FAILED: PR body is null"
  log_error "PR #${PR_NUMBER} was created but description was not set"
  exit 1
fi

# Check if body is empty
if [ -z "$body" ]; then
  log_error "Validation FAILED: PR body is empty"
  log_error "PR #${PR_NUMBER} has an empty description"
  exit 1
fi

# Check if body matches default template (actual placeholder text, not just section headers)
default_template_placeholders=(
  "Briefly describe what this PR changes"
  "High-level bullets of what changed"
  "What problem does this solve"
  "Any alternatives considered"
  "Local checks pass"
  "Docs updated"
  "<behavior/outcome"
)

placeholder_match_count=0
for marker in "${default_template_placeholders[@]}"; do
  if echo "$body" | grep -qF "$marker"; then
    ((placeholder_match_count++)) || true
  fi
done

# If 2+ actual placeholders are present, likely still using default template
if [ "$placeholder_match_count" -ge 2 ]; then
  log_error "Validation FAILED: PR body contains template placeholders"
  log_error "Found $placeholder_match_count placeholder texts (threshold: 2)"
  log_error "PR #${PR_NUMBER} likely still has placeholder content"
  exit 1
fi

# If expected body provided, check for match
if [ -n "$EXPECTED_BODY" ]; then
  # Simple substring check (first 50 chars)
  expected_start=$(echo "$EXPECTED_BODY" | head -c 50)
  body_start=$(echo "$body" | head -c 50)
  
  if [ "$body_start" != "$expected_start" ]; then
    log_error "Validation FAILED: PR body doesn't match expected content"
    log_error "Expected start: ${expected_start}"
    log_error "Actual start:   ${body_start}"
    exit 1
  fi
fi

# Validation passed
log_info "Validation PASSED: PR #${PR_NUMBER} has proper description"
log_info "Body length: ${#body} characters"
exit 0

