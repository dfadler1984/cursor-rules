#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/pr-create.sh"
TEMPLATE_FILE="$ROOT_DIR/.github/pull_request_template.md"

# Snapshot and auto-restore GH_TOKEN for test isolation
ORIGINAL_GH_TOKEN="${GH_TOKEN-}"
restore_gh_token() {
  if [ -n "${ORIGINAL_GH_TOKEN+x}" ]; then
    export GH_TOKEN="$ORIGINAL_GH_TOKEN"
  else
    unset GH_TOKEN || true
  fi
}
trap restore_gh_token EXIT

# 1) Dry-run prints JSON with required keys
export GH_TOKEN="dummy"
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
unset GH_TOKEN || true
if bash "$SCRIPT" --title t --owner o --repo r --base b --head h >/dev/null 2>&1; then
  echo "expected missing token to fail"; exit 1
fi

# 3) --no-template disables template injection (body should not start with template heading)
export GH_TOKEN="dummy"
out_notmpl="$(bash "$SCRIPT" --title "No Tmpl" --owner o --repo r --base main --head feat --no-template --body "Only body" --dry-run)"
printf '%s' "$out_notmpl" | grep -q '"body"' || { echo "missing body field"; exit 1; }
printf '%s' "$out_notmpl" | grep -q 'Only body' || { echo "expected provided body"; exit 1; }
printf '%s' "$out_notmpl" | grep -q '## Summary' && { echo "unexpected template when --no-template"; exit 1; }

# 4) --body-append appears under Context when template is used
out_ctx="$(bash "$SCRIPT" --title "Ctx" --owner o --repo r --base main --head feat --body "A" --body-append "B" --dry-run)"
printf '%s' "$out_ctx" | grep -q '## Context' || { echo "missing Context section"; exit 1; }
printf '%s' "$out_ctx" | grep -q 'A' || { echo "missing base body in Context"; exit 1; }
printf '%s' "$out_ctx" | grep -q 'B' || { echo "missing appended body in Context"; exit 1; }

# 5) Default dry-run should not include labels key
printf '%s' "$out" | grep -q '"labels"' && { echo "unexpected labels in default dry-run"; exit 1; }

# 6) --label skip-changeset includes labels array in dry-run
out_lbl="$(bash "$SCRIPT" --title "Label" --owner o --repo r --base main --head feat --label skip-changeset --dry-run)"
printf '%s' "$out_lbl" | grep -E -q '"labels"[[:space:]]*:[[:space:]]*\["skip-changeset"\]' || { echo "expected labels field with skip-changeset"; exit 1; }

# 7) Multiple --label flags include both labels in order
out_multi="$(bash "$SCRIPT" --title "Multi" --owner o --repo r --base main --head feat --label a --label b --dry-run)"
printf '%s' "$out_multi" | grep -E -q '"labels"[[:space:]]*:[[:space:]]*\["a","b"\]' || { echo "expected labels [a,b] in order"; exit 1; }

# 8) --docs-only acts as alias for skip-changeset
out_docs="$(bash "$SCRIPT" --title "Docs" --owner o --repo r --base main --head feat --docs-only --dry-run)"
printf '%s' "$out_docs" | grep -E -q '"labels"[[:space:]]*:[[:space:]]*\["skip-changeset"\]' || { echo "expected labels with skip-changeset via --docs-only"; exit 1; }

# 9) When a full body is provided (starts with '## Summary'), script auto-replaces template (no Context)
full_body=$'## Summary\nThis PR updates behavior.\n\n## Changes\n- Bullet\n\n## Why\nReason.'
out_full="$(bash "$SCRIPT" --title "Full Body" --owner o --repo r --base main --head feat --body "$full_body" --dry-run)"
printf '%s' "$out_full" | grep -q '## Summary' || { echo "expected provided full body to be used"; echo "$out_full"; exit 1; }
printf '%s' "$out_full" | grep -q '## Context' && { echo "did not expect Context section for full body"; echo "$out_full"; exit 1; }
# Ensure template boilerplate line not present (indicates replacement, not append)
printf '%s' "$out_full" | grep -q 'Briefly describe what this PR changes and why.' && { echo "template boilerplate leaked into body"; echo "$out_full"; exit 1; }

# 10) --replace-body forces replacement regardless of content
out_force="$(bash "$SCRIPT" --title "Force Replace" --owner o --repo r --base main --head feat --replace-body --body "Only this" --dry-run)"
printf '%s' "$out_force" | grep -q 'Only this' || { echo "expected exact body when --replace-body"; echo "$out_force"; exit 1; }
printf '%s' "$out_force" | grep -q '## Context' && { echo "did not expect Context when --replace-body"; echo "$out_force"; exit 1; }

exit 0
