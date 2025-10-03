#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
VALIDATOR="$ROOT_DIR/.cursor/scripts/rules-validate.sh"

assert_exit() {
  local expected=$1
  shift
  local desc=$1
  shift
  set +e
  "$@"
  local code=$?
  set -e
  if [ "$code" -ne "$expected" ]; then
    echo "FAIL: $desc (expected exit $expected, got $code)" >&2
    exit 1
  else
    echo "OK: $desc"
  fi
}

mk_rules_dir_ok() {
  local dir
  dir=$(mktemp -d)
  mkdir -p "$dir"
  cat >"$dir/good.mdc" <<'YAML'
---
description: Good rule
alwaysApply: false
lastReviewed: 2025-10-02
healthScore:
  content: green
  usability: green
  maintenance: green
---

# Good
YAML
  echo "$dir"
}

mk_rules_dir_fail() {
  local dir
  dir=$(mktemp -d)
  mkdir -p "$dir"
  # Missing lastReviewed
  cat >"$dir/missing-lastReviewed.mdc" <<'YAML'
---
description: Missing lastReviewed
alwaysApply: false
healthScore:
  content: green
  usability: green
  maintenance: green
---
YAML
  # CSV spacing and brace expansion
  cat >"$dir/csv-bad.mdc" <<'YAML'
---
description: CSV bad
globs: **/*.spec*, **/*.test*{,}
alwaysApply: false
lastReviewed: 2025-10-02
healthScore:
  content: green
  usability: green
  maintenance: green
---
YAML
  # Deprecated reference and typo
  cat >"$dir/deprecated-typo.mdc" <<'MD'
---
description: Deprecated ref and typo
alwaysApply: false
lastReviewed: 2025-10-02
healthScore:
  content: green
  usability: green
  maintenance: green
---

See assistant-learning-log.mdc and ev ents here.
MD
  # tdd-first missing cjs in globs
  cat >"$dir/tdd-first.mdc" <<'YAML'
---
description: TDD First test file
globs: **/*.ts,**/*.tsx,**/*.js,**/*.jsx,**/*.mjs
alwaysApply: true
lastReviewed: 2025-10-02
healthScore:
  content: green
  usability: green
  maintenance: green
---
YAML
  echo "$dir"
}

main() {
  if [ ! -x "$VALIDATOR" ]; then
    echo "Validator not found or not executable: $VALIDATOR" >&2
    exit 1
  fi

  local ok_dir fail_dir
  ok_dir=$(mk_rules_dir_ok)
  fail_dir=$(mk_rules_dir_fail)

  # Expect success on ok_dir
  assert_exit 0 "validator OK on clean rules dir" "$VALIDATOR" --dir "$ok_dir"

  # Expect failure on fail_dir
  assert_exit 1 "validator fails on bad rules dir" "$VALIDATOR" --dir "$fail_dir"

  echo "rules-validate.spec.sh: OK"
}

main "$@"


