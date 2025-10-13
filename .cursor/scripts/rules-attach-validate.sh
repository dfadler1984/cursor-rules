#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

VERSION="0.1.0"

usage() {
  cat <<'USAGE'
Usage: rules-attach-validate.sh [--version] [-h|--help]

Validate that required rules have proactive attachment paths.

Checks:
  - Required rules are referenced in capabilities or intent-routing
  - Ensures rules are discoverable and attachable

Options:
  --version   Print version and exit
  -h, --help  Show this help and exit

Examples:
  # Validate rule attachment paths
  rules-attach-validate.sh
USAGE
  
  print_exit_codes
}

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --version) printf '%s\n' "$VERSION"; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    *) die "$EXIT_USAGE" "Unknown argument: $1" ;;
  esac
done

ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

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
  echo "$failures rule(s) missing proactive attachment"
  exit 1
fi

log_info "All required rules have proactive attachment paths"
exit 0
