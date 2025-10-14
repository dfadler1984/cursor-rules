#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"
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

# OK should pass and print expected messages
out_ok=$("$SCRIPT" "$TMP_DIR/projects" 2>&1)
printf '%s' "$out_ok" | grep -q "\[OK\] ok" || { echo "expected OK line for project 'ok'" >&2; echo "$out_ok" >&2; exit 1; }
printf '%s' "$out_ok" | grep -q "All completed projects passed validation." || { echo "expected final success message" >&2; echo "$out_ok" >&2; exit 1; }

# OK should also work with --projects-dir flag
out_ok_flag=$("$SCRIPT" --projects-dir "$TMP_DIR/projects" 2>&1)
printf '%s' "$out_ok_flag" | grep -q "\[OK\] ok" || { echo "expected OK line with --projects-dir" >&2; echo "$out_ok_flag" >&2; exit 1; }

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
out_bad=$("$SCRIPT" "$TMP_DIR/projects" 2>&1)
rc=$?
set -e
if [ "$rc" -eq 0 ]; then
  echo "expected validator to fail for missing artifacts" >&2
  echo "$out_bad" >&2
  exit 1
fi

# Must print FAIL line and specific reasons
printf '%s' "$out_bad" | grep -q "\[FAIL\] bad" || { echo "expected FAIL line for 'bad'" >&2; echo "$out_bad" >&2; exit 1; }
printf '%s' "$out_bad" | grep -q "final-summary.md missing" || { echo "expected reason: final-summary.md missing" >&2; echo "$out_bad" >&2; exit 1; }
printf '%s' "$out_bad" | grep -q "projects/README.md entry missing or not linkified" || { echo "expected reason: README link missing" >&2; echo "$out_bad" >&2; exit 1; }

# Red: missing 'completed' and 'owner' must be reported
mkdir -p "$TMP_DIR/projects/bad2"
cat > "$TMP_DIR/projects/bad2/erd.md" <<'MD'
---
status: completed
---

# ERD
MD

set +e
out_bad2=$("$SCRIPT" "$TMP_DIR/projects" 2>&1)
rc=$?
set -e
if [ "$rc" -eq 0 ]; then
  echo "expected validator to fail when 'completed'/'owner' missing" >&2
  echo "$out_bad2" >&2
  exit 1
fi
printf '%s' "$out_bad2" | grep -q "front matter: completed date (YYYY-MM-DD)" || { echo "expected reason: missing completed date" >&2; echo "$out_bad2" >&2; exit 1; }
printf '%s' "$out_bad2" | grep -q "front matter: owner" || { echo "expected reason: missing owner" >&2; echo "$out_bad2" >&2; exit 1; }

exit 0

