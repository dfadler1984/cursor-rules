#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1090
source "$(dirname "$0")/.lib.sh"

VERSION="0.1.0"

usage() {
  print_usage "changesets-automerge-dispatch.sh --repo <owner/repo> --pr <number> --token <token> [OPTIONS]"
  
  print_options
  print_option "--repo OWNER/REPO" "Repository in owner/repo format (required)"
  print_option "--pr NUMBER" "PR number to auto-merge (required)"
  print_option "--token TOKEN" "GitHub token with Actions: write (required)"
  print_option "--ref REF" "Git ref/branch to dispatch on" "main"
  print_option "--dry-run" "Print curl command without executing"
  print_option "--version" "Print version and exit"
  print_option "-h, --help" "Show this help and exit"
  
  cat <<'NOTES'

Description:
  Dispatches the Changesets auto-merge workflow for a given PR number.
  Requires a GitHub token with Actions: write permission.

NOTES
  
  print_examples
  print_example "Dispatch auto-merge for PR 123" "changesets-automerge-dispatch.sh --repo myorg/myrepo --pr 123 --token \$GH_TOKEN"
  print_example "Dry-run to see command" "changesets-automerge-dispatch.sh --repo myorg/myrepo --pr 123 --token \$GH_TOKEN --dry-run"
  print_example "Dispatch on custom ref" "changesets-automerge-dispatch.sh --repo myorg/myrepo --pr 123 --token \$GH_TOKEN --ref develop"
  
  print_exit_codes
}

repo=""; pr=""; ref="main"; token=""; dry_run=0
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) repo="$2"; shift 2;;
    --pr) pr="$2"; shift 2;;
    --ref) ref="$2"; shift 2;;
    --token) token="$2"; shift 2;;
    --dry-run) dry_run=1; shift;;
    --version) printf '%s\n' "$VERSION"; exit 0;;
    -h|--help) usage; exit 0;;
    *) die "$EXIT_USAGE" "Unknown arg: $1";;
  esac
done

[ -n "$repo" ] || die "$EXIT_USAGE" "--repo is required"
[ -n "$pr" ] || die "$EXIT_USAGE" "--pr is required"
[ -n "$token" ] || die "$EXIT_USAGE" "--token is required"

api="https://api.github.com/repos/${repo}/actions/workflows/changesets-auto-merge.yml/dispatches"
# Build minimal JSON body without external deps
body=$(printf '{"ref":"%s","inputs":{"pr":"%s"}}' "$ref" "$pr")

if [ $dry_run -eq 1 ]; then
  printf 'curl -sS -X POST -H "Authorization: token ***" -H "Accept: application/vnd.github+json" -d %q %q\n' "$body" "$api"
  exit 0
fi

curl -sS -X POST \
  -H "Authorization: token ${token}" \
  -H "Accept: application/vnd.github+json" \
  -d "$body" \
  "$api"

log_info "Dispatched changesets-auto-merge for PR #$pr on $ref"


