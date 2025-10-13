#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/checks-status.sh"

[ -x "$SCRIPT" ] || { echo "checks-status.sh not executable" >&2; exit 1; }

# 1) --dry-run prints API URL with the current HEAD sha
url="$($SCRIPT --dry-run)"
echo "$url" | grep -q "/commits/" || { echo "dry-run did not include /commits/"; exit 1; }

# Mock JSON used for non-networked checks
MOCK_OK='{"check_runs":[{"name":"links","status":"completed","conclusion":"success","started_at":"t","completed_at":"t"}]}'

# 2) --json returns a JSON array (mocked via CURL_CMD seam)
if command -v jq >/dev/null 2>&1; then
  out_json=$(GH_TOKEN=dummy echo "$MOCK_OK" | CURL_CMD=cat JQ_CMD=jq $SCRIPT --json 2>/dev/null)
  echo "$out_json" | jq -e . >/dev/null 2>&1 || { echo "--json not valid JSON"; exit 1; }
fi

# 3) --strict should pass on success JSON (mocked via CURL_CMD seam)
MOCK_STRICT='{"check_runs":[{"name":"links","status":"completed","conclusion":"success"}]}'
set +e
GH_TOKEN=dummy echo "$MOCK_STRICT" | CURL_CMD=cat JQ_CMD=jq $SCRIPT --strict >/dev/null 2>&1
rc=$?
set -e
[ $rc -eq 0 ] || { echo "strict mode failed on success JSON"; exit 1; }

# 4) Failing path: feed a mocked JSON with a failing conclusion and expect exit 1
MOCK='{"check_runs":[{"name":"links","status":"completed","conclusion":"failure"}]}'
set +e
GH_TOKEN=dummy echo "$MOCK" | CURL_CMD=cat JQ_CMD=jq $SCRIPT --strict >/dev/null 2>&1
rc=$?
set -e
[ $rc -ne 0 ] || { echo "expected strict to fail on failure conclusion"; exit 1; }

# 5) dry-run should not require token and prints the commit URL
out_url="$($SCRIPT --dry-run)"
echo "$out_url" | grep -q '/commits/' || { echo "dry-run missing commit URL"; exit 1; }

# 6) token missing should error for non-dry-run
set +e
GH_TOKEN= $SCRIPT --sha "$(git rev-parse HEAD)" >/dev/null 2>&1
rc=$?
set -e
[ $rc -ne 0 ] || { echo "expected error without token"; exit 1; }

# 7) no-jq path should print raw JSON and exit 0
set +e
out_nojq=$(GH_TOKEN=dummy echo "$MOCK_OK" | CURL_CMD=cat JQ_CMD=/nonexistent $SCRIPT 2>/dev/null)
rc=$?
set -e
[ $rc -eq 0 ] || { echo "expected no-jq path to succeed"; exit 1; }
echo "$out_nojq" | grep -q 'check_runs' || { echo "expected raw JSON output without jq"; exit 1; }

# 8) header row present with jq available
if command -v jq >/dev/null 2>&1; then
  table=$(GH_TOKEN=dummy echo "$MOCK_OK" | CURL_CMD=cat JQ_CMD=jq $SCRIPT 2>/dev/null)
  header_line=$(echo "$table" | sed -n '2p')
  echo "$header_line" | grep -q 'name\s\+status\s\+conclusion' || { echo "missing table header"; echo "$table"; exit 1; }
fi

# 9) PR resolution path: feed a PR JSON with head.sha and expect URL printed on dry-run
PR_FIX='{ "head": { "sha": "abc123" } }'
export PR_SHA=""
set +e
echo "$PR_FIX" | PR_SHA= CURL_CMD=cat JQ_CMD=jq $SCRIPT --pr 123 --dry-run >/dev/null 2>&1
rc=$?
set -e
[ $rc -eq 0 ] || { echo "expected --pr with dry-run to succeed"; exit 1; }


exit 0


