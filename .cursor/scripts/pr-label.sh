#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Add labels to GitHub Pull Request
# Usage: pr-label.sh --pr <number> --label <name> [--label <name>...] [--owner <o>] [--repo <r>]
#
# Extracted from pr-create.sh for Unix Philosophy compliance:
# - Do one thing: add labels to existing PRs
# - Small & focused: ~120 lines vs 282 in pr-create.sh
# - Reusable: can be used independently or in pipelines

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

VERSION="1.0.0"

# Default values
PR_NUMBER=""
OWNER=""
REPO=""
LABELS=()
DRY_RUN=0
OUTPUT_FORMAT="text"  # text|json

usage() {
  print_help_header "pr-label.sh" "$VERSION" "Add labels to a GitHub Pull Request"
  print_usage "pr-label.sh --pr <number> --label <name> [OPTIONS]"
  
  print_options
  print_option "--pr NUMBER" "Pull request number (required)"
  print_option "--label NAME" "Label to add (repeatable, required)"
  print_option "--owner OWNER" "Repository owner" "auto-detected from git"
  print_option "--repo REPO" "Repository name" "auto-detected from git"
  print_option "--format FORMAT" "Output format: text|json" "text"
  print_option "--dry-run" "Show what would be done without making API call"
  print_option "--version" "Print version and exit"
  print_option "-h, --help" "Show this help and exit"
  
  cat <<'NOTES'

Notes:
  - Requires GH_TOKEN environment variable for actual API calls
  - Requires jq for JSON parsing
  - Owner/repo auto-detected from git remote when omitted
  - Multiple --label flags can be specified

NOTES
  
  print_examples
  print_example "Add single label" "pr-label.sh --pr 123 --label bug"
  print_example "Add multiple labels" "pr-label.sh --pr 123 --label bug --label enhancement"
  print_example "Dry-run" "pr-label.sh --pr 123 --label skip-changeset --dry-run"
  
  print_exit_codes
}

# Parse arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --pr) PR_NUMBER="${2:-}"; shift 2 ;;
    --label) LABELS+=("${2:-}"); shift 2 ;;
    --owner) OWNER="${2:-}"; shift 2 ;;
    --repo) REPO="${2:-}"; shift 2 ;;
    --format) OUTPUT_FORMAT="${2:-}"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --version) printf '%s\n' "$VERSION"; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    *) die "$EXIT_USAGE" "Unknown argument: $1" ;;
  esac
done

# Validate required args
[ -n "$PR_NUMBER" ] || die "$EXIT_USAGE" "--pr is required"
[ "${#LABELS[@]}" -gt 0 ] || die "$EXIT_USAGE" "At least one --label is required"

# Auto-detect owner/repo from git if not provided
if [ -z "$OWNER" ] || [ -z "$REPO" ]; then
  if git rev-parse --git-dir >/dev/null 2>&1; then
    url=$(git remote get-url origin 2>/dev/null || true)
    [ -n "$OWNER" ] || OWNER=$(printf '%s' "$url" | sed -E 's#.*github.com[:/]+([^/]+)/(.*)#\1#' | sed 's/.git$//' || true)
    [ -n "$REPO" ] || REPO=$(printf '%s' "$url" | sed -E 's#.*github.com[:/]+([^/]+)/([^./]+)(\.git)?#\2#' || true)
  fi
fi

[ -n "$OWNER" ] || die "$EXIT_CONFIG" "Could not determine owner (use --owner or ensure git remote exists)"
[ -n "$REPO" ] || die "$EXIT_CONFIG" "Could not determine repo (use --repo or ensure git remote exists)"

# Build labels JSON array
labels_json="["
for i in "${!LABELS[@]}"; do
  [ "$i" -gt 0 ] && labels_json+=","
  labels_json+="\"${LABELS[$i]}\""
done
labels_json+="]"

# Dry-run mode
if [ $DRY_RUN -eq 1 ]; then
  if [ "$OUTPUT_FORMAT" = "json" ]; then
    cat <<EOF
{
  "pr": $PR_NUMBER,
  "owner": "$OWNER",
  "repo": "$REPO",
  "labels": $labels_json,
  "dry_run": true
}
EOF
  else
    log_info "Would add labels to PR #$PR_NUMBER ($OWNER/$REPO):"
    for label in "${LABELS[@]}"; do
      printf "  - %s\n" "$label" >&2
    done
  fi
  exit 0
fi

# Real API call
require_cmd jq
: "${GH_TOKEN:?GH_TOKEN is required for API calls}"

# Create temp file for response
tmpfile=$(mktemp) || die "$EXIT_INTERNAL" "Failed to create temp file"
trap_cleanup "$tmpfile"

labels_api="https://api.github.com/repos/${OWNER}/${REPO}/issues/${PR_NUMBER}/labels"
labels_body=$(cat <<JSON
{"labels": $labels_json}
JSON
)

set +e
label_status=$(curl -sS -w '%{http_code}' -o "$tmpfile" \
  -H "Authorization: token ${GH_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  -X POST "$labels_api" -d "$labels_body" 2>/dev/null)
set -e

case "$label_status" in
  200|201)
    if [ "$OUTPUT_FORMAT" = "json" ]; then
      jq '.' "$tmpfile"
    else
      log_info "Labels added to PR #$PR_NUMBER"
    fi
    ;;
  *)
    die "$EXIT_NETWORK" "Labeling failed (HTTP $label_status)"
    ;;
esac

exit 0

