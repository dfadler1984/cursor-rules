#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/links-check.sh"

# Failing RED: script should exist and be executable later
if [ ! -x "$SCRIPT" ]; then
  echo "links-check.sh not executable" >&2
  exit 1
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

good_md="$tmpdir/good.md"
bad_md="$tmpdir/bad.md"

cat >"$good_md" <<'MD'
# Good

See [Cursor](https://github.com) and [Local](./good.md).
MD

cat >"$bad_md" <<'MD'
# Bad

Broken external: https://example.invalid-domain-xyz-12345
Broken relative: [Missing](./nope.md)
MD

# GREEN target behavior:
# - Running on good.md exits 0
# - Running on bad.md exits non-zero and reports both errors

# Seam: use curl --head with short timeout when testing externals
export CURL_CMD="curl"

"$SCRIPT" --path "$good_md" >/dev/null

set +e
out="$("$SCRIPT" --path "$bad_md" 2>&1)"
rc=$?
set -e

[ $rc -ne 0 ] || { echo "expected non-zero for bad links"; exit 1; }
echo "$out" | grep -q "relative missing: ./nope.md" || { echo "missing relative error"; echo "$out"; exit 1; }
echo "$out" | grep -q "external failed:" || { echo "missing external error"; echo "$out"; exit 1; }

exit 0


