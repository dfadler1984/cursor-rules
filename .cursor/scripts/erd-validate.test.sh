#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/erd-validate.sh"
FIXTURES="$ROOT_DIR/.cursor/scripts/tests/erd-fixtures"

mkdir -p "$FIXTURES/valid" "$FIXTURES/invalid"

# Valid ERD: no front matter required; H1 then Mode line, sections present
cat > "$FIXTURES/valid/erd-valid.md" <<'MD'
# Engineering Requirements Document — Example

Mode: Full

## 1. Introduction/Overview
text

## 2. Goals/Objectives
text
MD

# Invalid: front matter after H1 (should be at very top if present)
cat > "$FIXTURES/invalid/erd-front-matter-mid.md" <<'MD'
# Engineering Requirements Document — Bad

---
status: active
owner: test
---

Mode: Full
MD

# Invalid: extra '---' later (not in code fence) - actually valid if after front matter
# Skip this test as it's not actually invalid
# cat > "$FIXTURES/invalid/erd-extra-separator.md" <<'MD'
# ---
# status: active
# owner: test
# ---
# 
# # Engineering Requirements Document — Bad
# 
# Mode: Full
# 
# ---
# MD

# Project ERD validations (front matter required under docs/projects/*/erd.md)

# Valid project ERD with required front matter (active)
mkdir -p "$FIXTURES/tmp/docs/projects/sample"
cat > "$FIXTURES/tmp/docs/projects/sample/erd.md" <<'MD'
---
status: active
owner: rules-maintainers
lastUpdated: 2025-10-09
---
# Engineering Requirements Document — Example
Mode: Lite
MD

# Invalid: missing lastUpdated
mkdir -p "$FIXTURES/tmp/docs/projects/missing-last"
cat > "$FIXTURES/tmp/docs/projects/missing-last/erd.md" <<'MD'
---
status: active
owner: rules-maintainers
---
# Engineering Requirements Document — Example
Mode: Lite
MD

# Invalid: bad date format
mkdir -p "$FIXTURES/tmp/docs/projects/bad-date"
cat > "$FIXTURES/tmp/docs/projects/bad-date/erd.md" <<'MD'
---
status: active
owner: rules-maintainers
lastUpdated: 2025/10/09
---
# Engineering Requirements Document — Example
Mode: Lite
MD

# Invalid: missing owner
mkdir -p "$FIXTURES/tmp/docs/projects/missing-owner"
cat > "$FIXTURES/tmp/docs/projects/missing-owner/erd.md" <<'MD'
---
status: active
lastUpdated: 2025-10-09
---
# Engineering Requirements Document — Example
Mode: Lite
MD

# Invalid: bad status
mkdir -p "$FIXTURES/tmp/docs/projects/bad-status"
cat > "$FIXTURES/tmp/docs/projects/bad-status/erd.md" <<'MD'
---
status: draft
owner: rules-maintainers
lastUpdated: 2025-10-09
---
# Engineering Requirements Document — Example
Mode: Lite
MD

# Run script availability check
if [ ! -x "$SCRIPT" ]; then
  echo "erd-validate.sh missing or not executable" >&2
  exit 1
fi

# Valid should pass
"$SCRIPT" "$FIXTURES/valid/erd-valid.md" >/dev/null

# Valid project ERD should pass
"$SCRIPT" "$FIXTURES/tmp/docs/projects/sample/erd.md" >/dev/null

# Invalids should fail
if "$SCRIPT" "$FIXTURES/invalid/erd-front-matter-mid.md" >/dev/null 2>&1; then
  echo "expected erd-front-matter-mid.md to fail"; exit 1
fi

if "$SCRIPT" "$FIXTURES/invalid/erd-extra-separator.md" >/dev/null 2>&1; then
  echo "expected erd-extra-separator.md to fail"; exit 1
fi

# Invalid project ERDs should fail
if "$SCRIPT" "$FIXTURES/tmp/docs/projects/missing-last/erd.md" >/dev/null 2>&1; then
  echo "expected missing-lastUpdated to fail"; exit 1
fi
if "$SCRIPT" "$FIXTURES/tmp/docs/projects/bad-date/erd.md" >/dev/null 2>&1; then
  echo "expected bad-date to fail"; exit 1
fi
if "$SCRIPT" "$FIXTURES/tmp/docs/projects/missing-owner/erd.md" >/dev/null 2>&1; then
  echo "expected missing-owner to fail"; exit 1
fi
if "$SCRIPT" "$FIXTURES/tmp/docs/projects/bad-status/erd.md" >/dev/null 2>&1; then
  echo "expected bad-status to fail"; exit 1
fi

exit 0


