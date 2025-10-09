#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/changesets-automerge-dispatch.sh"

# 1) Dry-run prints a redacted curl with our arguments embedded
out="$($SCRIPT --repo owner/repo --pr 123 --token tok_123 --ref main --dry-run)"
case "$out" in
  *"https://api.github.com/repos/owner/repo/actions/workflows/changesets-auto-merge.yml/dispatches"* ) :;;
  *) echo "expected repo in output"; exit 1;;
esac
# We assert presence of repo, PR, and token redaction; ref is optional for this smoke test
echo "$out" | grep -q '\\"pr\\":\\"123\\"' || { echo "expected pr 123 in body"; exit 1; }
case "$out" in
  *"Authorization: token ***"* ) :;;
  *) echo "expected redacted token in output"; exit 1;;
esac

echo "OK"

