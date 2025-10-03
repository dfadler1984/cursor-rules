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

# Invalid: extra '---' later (not in code fence)
cat > "$FIXTURES/invalid/erd-extra-separator.md" <<'MD'
---
status: active
owner: test
---

# Engineering Requirements Document — Bad

Mode: Full

---
MD

# Run script availability check
if [ ! -x "$SCRIPT" ]; then
  echo "erd-validate.sh missing or not executable" >&2
  exit 1
fi

# Valid should pass
"$SCRIPT" "$FIXTURES/valid/erd-valid.md" >/dev/null

# Invalids should fail
if "$SCRIPT" "$FIXTURES/invalid/erd-front-matter-mid.md" >/dev/null 2>&1; then
  echo "expected erd-front-matter-mid.md to fail"; exit 1
fi

if "$SCRIPT" "$FIXTURES/invalid/erd-extra-separator.md" >/dev/null 2>&1; then
  echo "expected erd-extra-separator.md to fail"; exit 1
fi

exit 0


