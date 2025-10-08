#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"

required_rules=("testing.mdc" "test-quality.mdc")
caps_glob="$ROOT/.cursor/rules/*.caps.mdc"
router_file="$ROOT/.cursor/rules/intent-routing.mdc"

failures=0

for rule in "${required_rules[@]}"; do
  have_caps=0
  have_router=0

  if grep -Rqs -- "$rule" $caps_glob; then
    have_caps=1
  fi

  if [ -f "$router_file" ] && grep -qs -- "Attach: \`$rule\`" "$router_file"; then
    have_router=1
  fi

  if [ $have_caps -eq 0 ] && [ $have_router -eq 0 ]; then
    echo "missing proactive attach path for $rule (no caps referencing it, and router lacks Attach: \`$rule\`)"
    failures=$((failures+1))
  fi
done

if [ $failures -gt 0 ]; then
  echo "rules-attach-validate: FAIL ($failures missing)"
  exit 1
fi

echo "rules-attach-validate: OK"


