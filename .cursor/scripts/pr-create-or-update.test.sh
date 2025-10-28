#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/pr-create-or-update.sh"

export GH_TOKEN="dummy"

# 1) --dry-run with no existing PR creates new PR
MOCK_PR_LIST='[]'
out="$(echo "$MOCK_PR_LIST" | CURL_CMD=cat PR_LIST=1 bash "$SCRIPT" \
  --title "chore: test PR" \
  --body "Test body" \
  --title-pattern "chore: test" \
  --branch-prefix "bot/test-" \
  --owner o \
  --repo r \
  --base main \
  --head bot/test-123 \
  --dry-run)"

echo "$out" | grep -q '"action":"create"' || { echo "expected create action"; echo "$out"; exit 1; }
echo "$out" | grep -q '"head":"bot/test-123"' || { echo "expected head branch"; echo "$out"; exit 1; }

# 2) --dry-run with existing PR updates it
MOCK_PR_LIST='[{"number": 42, "title": "chore: test PR", "head": {"ref": "bot/test-old"}, "user": {"login": "dfadler1984"}}]'
out2="$(echo "$MOCK_PR_LIST" | CURL_CMD=cat PR_LIST=1 bash "$SCRIPT" \
  --title "chore: test PR updated" \
  --body "Updated body" \
  --title-pattern "chore: test" \
  --branch-prefix "bot/test-" \
  --owner o \
  --repo r \
  --base main \
  --head bot/test-new \
  --dry-run)"

echo "$out2" | grep -q '"action":"update"' || { echo "expected update action"; echo "$out2"; exit 1; }
echo "$out2" | grep -q '"pr_number":42' || { echo "expected pr_number 42"; echo "$out2"; exit 1; }

# 3) Matches by title pattern regardless of user
MOCK_PR_LIST='[{"number": 99, "title": "chore: test PR (old)", "head": {"ref": "bot/test-branch"}, "user": {"login": "any-user"}}]'
out3="$(echo "$MOCK_PR_LIST" | CURL_CMD=cat PR_LIST=1 bash "$SCRIPT" \
  --title "chore: test PR (new)" \
  --body "Body" \
  --title-pattern "chore: test PR" \
  --branch-prefix "bot/test-" \
  --owner o \
  --repo r \
  --base main \
  --head bot/test-branch \
  --dry-run)"

echo "$out3" | grep -q '"pr_number":99' || { echo "expected pr_number 99 regardless of user"; echo "$out3"; exit 1; }

# 4) Requires --title-pattern
set +e
bash "$SCRIPT" --title "Test" --owner o --repo r --base main --head h --dry-run >/dev/null 2>&1
rc=$?
set -e
[ $rc -ne 0 ] || { echo "expected error when --title-pattern missing"; exit 1; }

# 5) Requires --branch-prefix
set +e
bash "$SCRIPT" --title "Test" --title-pattern "Test" --owner o --repo r --base main --head h --dry-run >/dev/null 2>&1
rc=$?
set -e
[ $rc -ne 0 ] || { echo "expected error when --branch-prefix missing"; exit 1; }

exit 0

