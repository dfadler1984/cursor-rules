#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: changesets-automerge-dispatch.sh --repo <owner/repo> --pr <number> [--ref main]

Dispatches the Changesets auto-merge workflow with the given PR number.

Required:
  --repo   owner/repo
  --pr     PR number (integer)

Optional:
  --ref    git ref/branch to run on (default: main)

Env:
  GH_TOKEN must be set with permissions to dispatch workflows.
USAGE
}

repo=""; pr=""; ref="main"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) repo="$2"; shift 2;;
    --pr) pr="$2"; shift 2;;
    --ref) ref="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2;;
  esac
done

[[ -n "$repo" && -n "$pr" ]] || { echo "--repo and --pr are required" >&2; usage; exit 2; }
[[ -n "${GH_TOKEN:-}" ]] || { echo "GH_TOKEN is required in env" >&2; exit 2; }

api="https://api.github.com/repos/${repo}/actions/workflows/changesets-auto-merge.yml/dispatches"
body=$(jq -nc --arg ref "$ref" --arg pr "$pr" '{ref:$ref, inputs:{pr:$pr}}')

curl -sS -X POST \
  -H "Authorization: token ${GH_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  -d "$body" \
  "$api"

echo "Dispatched changesets-auto-merge for PR #$pr on $ref"


