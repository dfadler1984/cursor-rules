#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/rules-validate.sh"
FIXTURES="$ROOT_DIR/.cursor/scripts/tests/fixtures"

mkdir -p "$FIXTURES/valid" "$FIXTURES/invalid" "$FIXTURES/refs"

cat > "$FIXTURES/valid/good.mdc" <<'YAML'
---
description: Example good rule
lastReviewed: 2025-09-20
healthScore:
  content: green
  usability: green
  maintenance: green
---
YAML

cat > "$FIXTURES/invalid/bad-date.mdc" <<'YAML'
---
description: Bad date rule
lastReviewed: 2025/09/20
healthScore:
  content: green
  usability: green
  maintenance: green
---
YAML

cat > "$FIXTURES/invalid/missing-fields.mdc" <<'YAML'
---
lastReviewed: 2025-09-20
healthScore:
  content: green
  usability: green
  maintenance: green
---
YAML

# 1) Valid fixtures pass
bash "$SCRIPT" --dir "$FIXTURES/valid" >/dev/null

# 2) Invalid date fails
if bash "$SCRIPT" --dir "$FIXTURES/invalid" >/dev/null 2>&1; then
  echo "expected invalid to fail"; exit 1
fi

# 3) Missing refs warning by default, error with flag
# Create a rule referencing a missing file (in separate refs dir)
cat > "$FIXTURES/refs/missing-ref.mdc" <<'YAML'
---
description: Missing ref
lastReviewed: 2025-09-20
healthScore:
  content: green
  usability: green
  maintenance: green
---

See `docs/nonexistent.md`.
YAML

# Warning mode (default) should not fail
bash "$SCRIPT" --dir "$FIXTURES/refs" >/dev/null

# Fail on refs should fail
if bash "$SCRIPT" --dir "$FIXTURES/refs" --fail-on-missing-refs >/dev/null 2>&1; then
  echo "expected fail-on-missing-refs to fail"; exit 1
fi

exit 0
