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

  # JSON format: ok_dir should produce totalIssues: 0 and exit 0
  set +e
  json_ok=$("$VALIDATOR" --dir "$ok_dir" --format json 2>/dev/null)
  code_ok=$?
  set -e
  if [ "$code_ok" -ne 0 ]; then
    echo "FAIL: --format json exit code on ok_dir (expected 0, got $code_ok)" >&2
    exit 1
  fi
  echo "$json_ok" | grep -q '"totalIssues"[[:space:]]*:[[:space:]]*0' || { echo "FAIL: --format json missing totalIssues:0 on ok_dir" >&2; exit 1; }

  # JSON format: fail_dir should produce totalIssues > 0 and exit 1
  set +e
  json_fail=$("$VALIDATOR" --dir "$fail_dir" --format json 2>/dev/null)
  code_fail=$?
  set -e
  if [ "$code_fail" -ne 1 ]; then
    echo "FAIL: --format json exit code on fail_dir (expected 1, got $code_fail)" >&2
    exit 1
  fi
  echo "$json_fail" | grep -Eq '"totalIssues"[[:space:]]*:[[:space:]]*[1-9][0-9]*' || { echo "FAIL: --format json missing totalIssues>0 on fail_dir" >&2; exit 1; }

  # Missing refs flag should fail when unresolved references exist
  # Create a file that references a missing doc within fail_dir
  cat >> "$fail_dir/missing-ref-inline.mdc" <<'YAML'
---
description: Missing ref inline
alwaysApply: false
lastReviewed: 2025-10-02
healthScore:
  content: green
  usability: green
  maintenance: green
---

See `docs/nonexistent.md`.
YAML

  assert_exit 1 "--fail-on-missing-refs triggers failure" "$VALIDATOR" --dir "$fail_dir" --fail-on-missing-refs

  # Autofix: create a dir with formatting-only issues and ensure --autofix makes it pass
  autofix_dir=$(mktemp -d)
  cat >"$autofix_dir/autofix.mdc" <<'YAML'
---
description: Autofix target
globs: **/*.spec*, **/*.test*
alwaysApply: "True"
lastReviewed: 2025-10-02
healthScore:
  content: green
  usability: green
  maintenance: green
---

# content
YAML

  # Without autofix should fail due to CSV spacing and boolean casing
  assert_exit 1 "validator fails without --autofix on formatting-only issues" "$VALIDATOR" --dir "$autofix_dir"

  # With autofix should pass
  assert_exit 0 "validator passes with --autofix on formatting-only issues" "$VALIDATOR" --dir "$autofix_dir" --autofix

  # Staleness: create a rule with old lastReviewed; default should warn (exit 0), strict should fail (exit 1)
  stale_dir=$(mktemp -d)
  cat >"$stale_dir/stale.mdc" <<'YAML'
---
description: Stale rule
lastReviewed: 2024-01-01
healthScore:
  content: green
  usability: green
  maintenance: green
---
YAML
  assert_exit 0 "staleness warns by default" "$VALIDATOR" --dir "$stale_dir"
  assert_exit 1 "staleness fails with --fail-on-stale" "$VALIDATOR" --dir "$stale_dir" --fail-on-stale

  # Report: generate to temp path and assert file exists and contains counts
  report_file=$(mktemp)
  # Use fail_dir which we know has issues
  assert_exit 1 "validator still fails while generating report" "$VALIDATOR" --dir "$fail_dir" --report-out "$report_file"
  [ -s "$report_file" ] || { echo "FAIL: report file not created" >&2; exit 1; }
  grep -q "## Counts" "$report_file" || { echo "FAIL: report missing Counts section" >&2; exit 1; }

  echo "rules-validate.spec.sh: OK"
}

main "$@"


