#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/project-lifecycle-validate.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$TMP_DIR/projects/ok"

# OK project — completed with summary and README link
cat > "$TMP_DIR/projects/ok/erd.md" <<'MD'
---
status: completed
completed: 2025-10-04
owner: tester
---

# ERD
MD

touch "$TMP_DIR/projects/ok/final-summary.md"

cat > "$TMP_DIR/projects/README.md" <<'MD'
# Projects

## Completed

- [ok](./ok/erd.md) — test
MD

# Script must exist and be executable
if [ ! -x "$SCRIPT" ]; then
  echo "project-lifecycle-validate.sh missing or not executable" >&2
  exit 1
fi

# OK should pass
"$SCRIPT" "$TMP_DIR/projects" >/dev/null

# Now add a bad project — completed but missing summary and README link
mkdir -p "$TMP_DIR/projects/bad"
cat > "$TMP_DIR/projects/bad/erd.md" <<'MD'
---
status: completed
completed: 2025-10-04
owner: tester
---

# ERD
MD

set +e
"$SCRIPT" "$TMP_DIR/projects" >/dev/null 2>&1
rc=$?
set -e
if [ "$rc" -eq 0 ]; then
  echo "expected validator to fail for missing artifacts" >&2
  exit 1
fi

exit 0

