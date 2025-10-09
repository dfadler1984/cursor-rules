#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: changesets-automerge-dispatch.sh --repo <owner/repo> --pr <number> --token <token> [--ref main] [--dry-run]

Dispatches the Changesets auto-merge workflow with the given PR number.

Required:
  --repo    owner/repo
  --pr      PR number (integer)
  --token   GitHub token string (dispatch requires Actions: write)

Optional:
  --ref     git ref/branch to run on (default: main)
  --dry-run print the curl command instead of executing it
USAGE
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

[[ -n "$repo" && -n "$pr" && -n "$token" ]] || { echo "--repo, --pr and --token are required" >&2; usage; exit 2; }

api="https://api.github.com/repos/${repo}/actions/workflows/changesets-auto-merge.yml/dispatches"
# Build minimal JSON body without external deps
body=$(printf '{"ref":"%s","inputs":{"pr":"%s"}}' "$ref" "$pr")

if [[ $dry_run -eq 1 ]]; then
  printf 'curl -sS -X POST -H "Authorization: token ***" -H "Accept: application/vnd.github+json" -d %q %q\n' "$body" "$api"
  exit 0
fi

curl -sS -X POST \
  -H "Authorization: token ${token}" \
  -H "Accept: application/vnd.github+json" \
  -d "$body" \
  "$api"

echo "Dispatched changesets-auto-merge for PR #$pr on $ref"


