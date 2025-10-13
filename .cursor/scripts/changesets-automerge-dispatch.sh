#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"
source "$SCRIPT_DIR/.lib-net.sh"

usage() {
  cat <<'USAGE'
Usage: changesets-automerge-dispatch.sh --repo <owner/repo> --pr <number> [--ref main] [--dry-run]

Provides guidance to manually trigger the Changesets auto-merge workflow.

Note: This script does not perform network requests (networkless per D4/D5).
      Use the GitHub Actions UI to manually trigger the workflow.

Options:
  --repo <owner/repo> Repository (required)
  --pr <number>       PR number (required)
  --ref <branch>      git ref/branch to run on (default: main)
  --dry-run           show what workflow would be triggered
  -h, --help          Show this help

Examples:
  # Show workflow trigger info (dry-run)
  changesets-automerge-dispatch.sh --repo owner/repo --pr 123 --dry-run
  
  # Provide guidance to trigger workflow
  changesets-automerge-dispatch.sh --repo owner/repo --pr 123
  
  # Trigger on specific ref
  changesets-automerge-dispatch.sh --repo owner/repo --pr 456 --ref develop

Note: --token is no longer required (kept for backward compatibility, ignored)
USAGE
  
  print_exit_codes
}

repo=""; pr=""; ref="main"; token=""; dry_run=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) repo="$2"; shift 2;;
    --pr) pr="$2"; shift 2;;
    --ref) ref="$2"; shift 2;;
    --token) token="$2"; shift 2;;
    --dry-run) dry_run=1; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2;;
  esac
done

[[ -n "$repo" && -n "$pr" ]] || { echo "--repo and --pr are required" >&2; usage; exit 2; }

api="https://api.github.com/repos/${repo}/actions/workflows/changesets-auto-merge.yml/dispatches"
actions_ui="https://github.com/${repo}/actions/workflows/changesets-auto-merge.yml"

if [[ $dry_run -eq 1 ]]; then
  # Dry-run: show what would be sent (networkless)
  body=$(printf '{"ref":"%s","inputs":{"pr":"%s"}}' "$ref" "$pr")
  printf 'Would dispatch workflow with:\n'
  printf '  Workflow: changesets-auto-merge.yml\n'
  printf '  Repository: %s\n' "$repo"
  printf '  PR: %s\n' "$pr"
  printf '  Ref: %s\n' "$ref"
  printf '\n'
  printf 'API endpoint: %s\n' "$api"
  printf 'Payload: %s\n' "$body"
  exit 0
fi

# Non-dry-run: provide guidance to use GitHub UI (networkless per D4/D5)
net_guidance \
  "Manually trigger the changesets-auto-merge workflow for PR #$pr" \
  "$actions_ui"

log_info "Navigate to Actions → changesets-auto-merge → Run workflow"
log_info "Select branch: $ref"
log_info "Set pr input: $pr"


