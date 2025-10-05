#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/pr-update.sh"

# 0) Script should exist and be executable
[ -x "$SCRIPT" ] || { echo "pr-update.sh not executable" >&2; exit 1; }

# 1) --dry-run with --pr and --title prints PATCH payload with title
out="$($SCRIPT --pr 123 --title "Fix body" --dry-run)"
echo "$out" | grep -q '"method":\s*"PATCH"' || { echo "expected method PATCH in dry-run"; exit 1; }
echo "$out" | grep -q '"url":\s*"https://api.github.com/repos/.\+/pulls/123"' || { echo "expected PR URL in dry-run"; echo "$out"; exit 1; }
echo "$out" | grep -q '"title":\s*"Fix body"' || { echo "expected title in payload"; echo "$out"; exit 1; }

# 2) --dry-run with --pr and --body includes body
out2="$($SCRIPT --pr 42 --body "Updated body" --dry-run)"
echo "$out2" | grep -q '"body":\s*"Updated body"' || { echo "expected body in payload"; echo "$out2"; exit 1; }

# 3) Using --head <branch> resolves PR via list API (mock with seams)
#   Simulate GitHub API returning a PR number for head branch and ensure URL targets that PR
MOCK_PR_LIST='[{"number": 777}]'
set +e
out3=$(echo "$MOCK_PR_LIST" | CURL_CMD=cat PR_LIST=1 "$SCRIPT" --head "test/branch" --title "T" --dry-run 2>/dev/null)
rc=$?
set -e
[ $rc -eq 0 ] || { echo "expected dry-run with --head to succeed"; exit 1; }
echo "$out3" | grep -q 'pulls/777' || { echo "expected resolved PR number in URL"; echo "$out3"; exit 1; }

# 4) Error when neither --title nor --body provided
set +e
"$SCRIPT" --pr 1 --dry-run >/dev/null 2>&1
rc=$?
set -e
[ $rc -ne 0 ] || { echo "expected error when no fields provided"; exit 1; }

exit 0


