#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

# Validate that maintained shell scripts under .cursor/scripts have colocated owner tests
# and that tests targeting maintained scripts are not centralized under .cursor/scripts/tests/.

usage() {
  cat <<'USAGE'
Usage: .cursor/scripts/test-colocation-validate.sh [--root <path>] [--warn-only]

Checks:
  1) For each maintained script: .cursor/scripts/<name>.sh → requires sibling .cursor/scripts/<name>.test.sh
  2) Flags non-colocated tests under .cursor/scripts/tests/*.test.sh when their owner exists in .cursor/scripts/<name>.sh

Options:
  --root <path>   Repository root (defaults to repo root resolved from this script)
  --warn-only     Do not fail; print warnings and exit 0

Examples:
  # Validate test colocation in default location
  test-colocation-validate.sh
  
  # Validate with custom root
  test-colocation-validate.sh --root /path/to/repo
  
  # Check without failing (warnings only)
  test-colocation-validate.sh --warn-only

Notes:
  - Excludes files under .cursor/scripts/tests/** from owner set
  - Excludes files already matching *.test.sh from owner set
USAGE
  
  print_exit_codes
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
WARN_ONLY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT_DIR="$(cd "$2" && pwd)"; shift 2 ;;
    --warn-only)
      WARN_ONLY=1; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; usage; exit 2 ;;
  esac
done

SCRIPTS_DIR="$ROOT_DIR/.cursor/scripts"
TESTS_DIR="$SCRIPTS_DIR/tests"

[[ -d "$SCRIPTS_DIR" ]] || { echo "Missing scripts dir: $SCRIPTS_DIR" >&2; exit 1; }

missing_tests=()
non_colocated_tests=()

# 1) Require sibling tests for maintained scripts (exclude tests dir and *.test.sh)
while IFS= read -r -d '' script; do
  base="$(basename "$script" .sh)"
  sibling_test="$SCRIPTS_DIR/$base.test.sh"
  if [[ ! -f "$sibling_test" ]]; then
    missing_tests+=("$base.sh → missing $base.test.sh")
  fi
done < <(find "$SCRIPTS_DIR" -maxdepth 1 -type f -name "*.sh" ! -name "*.test.sh" -print0)

# 2) Find centralized tests that appear to target a maintained script
if [[ -d "$TESTS_DIR" ]]; then
  while IFS= read -r -d '' t; do
    tbase="$(basename "$t" .test.sh)"
    owner="$SCRIPTS_DIR/$tbase.sh"
    if [[ -f "$owner" ]]; then
      non_colocated_tests+=("$t (owner exists at $owner)")
    fi
  done < <(find "$TESTS_DIR" -type f -name "*.test.sh" -print0)
fi

warn() { printf 'WARN: %s\n' "$*" >&2; }
fail() { printf 'ERROR: %s\n' "$*" >&2; }

exit_code=0

if (( ${#missing_tests[@]} > 0 )); then
  for m in "${missing_tests[@]}"; do
    if (( WARN_ONLY )); then warn "$m"; else fail "$m"; exit_code=1; fi
  done
fi

if (( ${#non_colocated_tests[@]} > 0 )); then
  for n in "${non_colocated_tests[@]}"; do
    if (( WARN_ONLY )); then warn "non-colocated: $n"; else fail "non-colocated: $n"; exit_code=1; fi
  done
fi

if (( exit_code == 0 )); then
  echo "OK: Colocation validation passed"
fi

exit $exit_code


