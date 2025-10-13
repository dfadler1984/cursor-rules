#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

VERSION="0.1.0"

usage() {
  cat <<'USAGE'
Usage: rules-validate.spec.sh [--version] [-h|--help]

Test helper for rules-validate.sh tests.

Provides assertions and fixtures for validating rule validation behavior.

Options:
  --version   Print version and exit
  -h, --help  Show this help and exit

Examples:
  # This is a test helper, normally invoked by test files
  # See: rules-validate.test.sh for usage
USAGE
  
  print_exit_codes
}

# Parse arguments  
case "${1:-}" in
  --version) printf '%s\n' "$VERSION"; exit 0 ;;
  -h|--help) usage; exit 0 ;;
esac

ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

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
  dir="$(mktemp -d)"
  cat > "$dir/sample.mdc" <<'MD'
---
description: Sample
globs: ["*.md"]
alwaysApply: false
---
# Sample
MD
  printf '%s' "$dir"
}

# Test helper functions available for sourcing by test files
# Main test logic lives in rules-validate.test.sh
