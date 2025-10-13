#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# checks-status.sh — Print GitHub Checks status for a commit or PR

# shellcheck disable=SC1090
source "$(dirname "$0")/.lib.sh"

VERSION="0.1.0"

usage() {
  print_usage "checks-status.sh [OPTIONS]"
  
  print_options
  print_option "--sha COMMIT" "Commit SHA to inspect" "HEAD"
  print_option "--pr NUMBER" "PR number; resolves head SHA via API"
  print_option "--owner OWNER" "Repository owner" "derived from git origin"
  print_option "--repo REPO" "Repository name" "derived from git origin"
  print_option "--json" "Print raw JSON array of check runs"
  print_option "--dry-run" "Print resolved API URL and exit"
  print_option "--strict" "Exit non-zero if any check fails"
  print_option "--version" "Print version and exit"
  print_option "-h, --help" "Show this help and exit"
  
  cat <<'ENV'

Environment:
  GH_TOKEN must be set (repo:read scope required)

ENV
  
  print_examples
  print_example "Check status for current commit" "checks-status.sh"
  print_example "Check status for specific PR" "checks-status.sh --pr 123"
  print_example "Check status in strict mode (fail on any failing check)" "checks-status.sh --pr 123 --strict"
  print_example "Get raw JSON output" "checks-status.sh --sha abc123 --json"
  print_example "Dry-run to see API URL" "checks-status.sh --pr 123 --dry-run"
  
  print_exit_codes
}

owner=""
repo=""
sha=""
pr=""
print_json=0
strict=0
dry_run=0

while [ $# -gt 0 ]; do
  case "$1" in
    --sha) sha="${2-}"; shift 2;;
    --pr) pr="${2-}"; shift 2;;
    --owner) owner="${2-}"; shift 2;;
    --repo) repo="${2-}"; shift 2;;
    --json) print_json=1; shift;;
    --dry-run) dry_run=1; shift;;
    --strict) strict=1; shift;;
    --version) printf '%s\n' "$VERSION"; exit 0;;
    -h|--help) usage; exit 0;;
    *) die "$EXIT_USAGE" "Unknown arg: $1";;
  esac
done

# Derive owner/repo from origin if not provided
if [ -z "$owner" ] || [ -z "$repo" ]; then
  if git rev-parse --git-dir >/dev/null 2>&1; then
    url=$(git remote get-url origin 2>/dev/null || true)
    [ -n "$url" ] || die "$EXIT_CONFIG" "Unable to derive owner/repo; pass --owner/--repo"
    owner=$(printf '%s' "$url" | sed -E 's#.*github.com[:/]+([^/]+)/(.*)#\1#' | sed 's/.git$//')
    repo=$(printf '%s' "$url" | sed -E 's#.*github.com[:/]+([^/]+)/([^./]+)(\.git)?#\2#')
  else
    die "$EXIT_CONFIG" "Not a git repo; pass --owner and --repo"
  fi
fi

# Allow seams for curl/jq in tests
curl_cmd="${CURL_CMD-curl}"
jq_cmd="${JQ_CMD-jq}"

# Resolve SHA
if [ -n "$pr" ]; then
  if [ -n "${PR_SHA-}" ]; then
    sha="$PR_SHA"
  else
    api="https://api.github.com/repos/${owner}/${repo}/pulls/${pr}"
    if [ "$curl_cmd" = "cat" ]; then
      pr_resp="$(cat)"
    else
      # token may be required; defer token check until after dry-run branch below
      pr_resp=$($curl_cmd -sS -H "Authorization: token ${GH_TOKEN}" -H "Accept: application/vnd.github+json" "$api")
    fi
    sha=$(printf '%s' "$pr_resp" | "$jq_cmd" -r '.head.sha')
    [ "$sha" != "null" ] && [ -n "$sha" ] || die "$EXIT_CONFIG" "Unable to resolve head.sha for PR #$pr"
  fi
elif [ -z "$sha" ]; then
  sha=$(git rev-parse HEAD)
fi

api_checks="https://api.github.com/repos/${owner}/${repo}/commits/${sha}/check-runs"

# dry-run: print URL and exit without requiring token
if [ $dry_run -eq 1 ]; then
  echo "$api_checks"
  exit 0
fi

# Token requirement (skip for --dry-run handled above)
: "${GH_TOKEN:?GH_TOKEN is required}"

if [ "$curl_cmd" = "cat" ]; then
  resp="$(cat)"
else
  resp=$($curl_cmd -sS -H "Authorization: token ${GH_TOKEN}" -H "Accept: application/vnd.github+json" "$api_checks")
fi

# jq availability check
if ! command -v "$jq_cmd" >/dev/null 2>&1; then
  echo "$resp" | sed -E 's/,(\{|\[)/,\n\1/g'
  exit 0
fi

if [ $print_json -eq 1 ]; then
  echo "$resp" | "$jq_cmd" '.check_runs'
  exit 0
fi

echo "Commit: $sha  (${owner}/${repo})"
echo "$resp" | "$jq_cmd" -r '
  .check_runs[] | [
    (.name // ""),
    (.status // ""),
    (.conclusion // ""),
    (.started_at // ""),
    (.completed_at // "")
  ] | @tsv' | (
    echo -e "name\tstatus\tconclusion\tstarted_at\tcompleted_at" && cat
  ) | column -t -s $'\t'

if [ $strict -eq 1 ]; then
  conclusion=$(echo "$resp" | "$jq_cmd" -r '.check_runs[].conclusion // ""')
  if echo "$conclusion" | grep -Eq 'failure|timed_out|cancelled|action_required'; then
    exit 1
  fi
fi

exit 0

#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# checks-status.sh — Print GitHub Checks for a commit (defaults to HEAD)
#
# Usage:
#   .cursor/scripts/checks-status.sh [--sha <sha>] [--branch <branch>] [--owner <o>] [--repo <r>]
#
# Notes:
#   - Requires GH_TOKEN in the environment (metadata + checks:read)
#   - Derives owner/repo from git remote when not provided
#   - If both --sha and --branch are omitted, uses `git rev-parse HEAD`

usage() {
  cat <<'USAGE'
Usage: checks-status.sh [--sha <sha>] [--branch <branch>] [--owner <o>] [--repo <r>]

Print GitHub check runs for the target commit. Defaults to HEAD.

Environment:
  GH_TOKEN   Token with repo read permissions
USAGE
}

have_cmd() { command -v "$1" >/dev/null 2>&1; }

OWNER=""
REPO=""
SHA=""
BRANCH=""

while [ $# -gt 0 ]; do
  case "$1" in
    --owner) OWNER="${2:-}"; shift 2 ;;
    --repo) REPO="${2:-}"; shift 2 ;;
    --sha) SHA="${2:-}"; shift 2 ;;
    --branch) BRANCH="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
done

# Require GH_TOKEN
: "${GH_TOKEN:?GH_TOKEN is required}"
TOKEN="$GH_TOKEN"

# Derive owner/repo when missing
if [ -z "$OWNER" ] || [ -z "$REPO" ]; then
  if git rev-parse --git-dir >/dev/null 2>&1; then
    url=$(git remote get-url origin 2>/dev/null || true)
    OWNER=$(printf '%s' "$url" | sed -E 's#.*github.com[:/]+([^/]+)/(.*)#\1#' | sed 's/.git$//' || true)
    REPO=$(printf '%s' "$url" | sed -E 's#.*github.com[:/]+([^/]+)/([^./]+)(\.git)?#\2#' || true)
  fi
fi
if [ -z "$OWNER" ] || [ -z "$REPO" ]; then
  echo "Unable to derive owner/repo; pass --owner and --repo" >&2
  exit 2
fi

# Resolve SHA
if [ -n "$BRANCH" ]; then
  if git rev-parse --verify "$BRANCH" >/dev/null 2>&1; then
    SHA=$(git rev-parse "$BRANCH")
  else
    echo "Branch not found locally: $BRANCH" >&2
    exit 2
  fi
fi
if [ -z "$SHA" ]; then
  if git rev-parse --git-dir >/dev/null 2>&1; then
    SHA=$(git rev-parse HEAD)
  else
    echo "No git repository found; pass --sha" >&2
    exit 2
  fi
fi

API="https://api.github.com/repos/${OWNER}/${REPO}/commits/${SHA}/check-runs"
resp_file=$(mktemp 2>/dev/null || mktemp -t checks.json)
touch "$resp_file" 2>/dev/null || true
chmod u+rw "$resp_file" 2>/dev/null || true
code=$(curl -sS -w '%{http_code}' -o "$resp_file" \
  -H "Authorization: token ${TOKEN}" \
  -H "Accept: application/vnd.github+json" "$API")

if [ "$code" != "200" ]; then
  echo "GitHub API error (status $code)" >&2
  if have_cmd jq; then jq '.' "$resp_file" >&2 || cat "$resp_file" >&2; else cat "$resp_file" >&2; fi
  exit 1
fi

if have_cmd jq; then
  jq -r '
    .check_runs[] | {
      name, status, conclusion,
      started_at, completed_at
    } | "\(.name) — status=\(.status) conclusion=\(.conclusion) started=\(.started_at) completed=\(.completed_at)"'
    "$resp_file"
else
  # Minimal fallback without jq
  grep -E '"name"|"status"|"conclusion"' "$resp_file" | sed 's/[",]//g'
fi

rm -f "$resp_file"
exit 0


