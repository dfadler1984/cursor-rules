#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/pr-create.sh"
TEMPLATE_FILE="$ROOT_DIR/.github/pull_request_template.md"

# Snapshot and auto-restore GITHUB_TOKEN for test isolation
ORIGINAL_GITHUB_TOKEN="${GITHUB_TOKEN-}"
restore_github_token() {
  if [ -n "${ORIGINAL_GITHUB_TOKEN+x}" ]; then
    export GITHUB_TOKEN="$ORIGINAL_GITHUB_TOKEN"
  else
    unset GITHUB_TOKEN || true
  fi
}
trap restore_github_token EXIT

# 1) Dry-run prints JSON with required keys
export GITHUB_TOKEN="dummy"
# Fake git environment by running outside a git repo? We rely on origin; skip derivation by setting owner/repo/head.
out="$(bash "$SCRIPT" --title "Add feature" --body "Body" --owner o --repo r --base main --head feat --dry-run)"
printf '%s' "$out" | grep -q '"title"' || { echo "payload missing title"; exit 1; }
printf '%s' "$out" | grep -q '"base"' || { echo "payload missing base"; exit 1; }
printf '%s' "$out" | grep -q '"head"' || { echo "payload missing head"; exit 1; }

# 1a) Default template injection should include template heading from repo template
if [ -f "$TEMPLATE_FILE" ]; then
  printf '%s' "$out" | grep -q '## Summary' || { echo "expected template heading '## Summary' in body"; exit 1; }
fi

# 2) Missing token when not dry-run should error before curl
unset GITHUB_TOKEN || true
if bash "$SCRIPT" --title t --owner o --repo r --base b --head h >/dev/null 2>&1; then
  echo "expected missing token to fail"; exit 1
fi

# 3) --no-template disables template injection (body should not start with template heading)
export GITHUB_TOKEN="dummy"
out_notmpl="$(bash "$SCRIPT" --title "No Tmpl" --owner o --repo r --base main --head feat --no-template --body "Only body" --dry-run)"
printf '%s' "$out_notmpl" | grep -q '"body"' || { echo "missing body field"; exit 1; }
printf '%s' "$out_notmpl" | grep -q 'Only body' || { echo "expected provided body"; exit 1; }
printf '%s' "$out_notmpl" | grep -q '## Summary' && { echo "unexpected template when --no-template"; exit 1; }

# 4) --body-append appears under Context when template is used
out_ctx="$(bash "$SCRIPT" --title "Ctx" --owner o --repo r --base main --head feat --body "A" --body-append "B" --dry-run)"
printf '%s' "$out_ctx" | grep -q '## Context' || { echo "missing Context section"; exit 1; }
printf '%s' "$out_ctx" | grep -q 'A' || { echo "missing base body in Context"; exit 1; }
printf '%s' "$out_ctx" | grep -q 'B' || { echo "missing appended body in Context"; exit 1; }

exit 0
