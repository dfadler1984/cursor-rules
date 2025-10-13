#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"
LIB_SH="$ROOT_DIR/.cursor/scripts/.lib.sh"

# Optional shared helpers
if [ -f "$LIB_SH" ]; then
  # shellcheck disable=SC1090
  source "$LIB_SH"
else
  log_info()  { printf '%s\n' "$*" >&2; }
  log_error() { printf 'ERROR: %s\n' "$*" >&2; }
fi

usage() {
  cat <<'USAGE'
Usage: .cursor/scripts/tests/run.sh [-k keyword] [-v] [-h|--help] [test_path ...]

Options:
  -k keyword   Only run tests whose path contains this keyword (case-insensitive)
  -v           Verbose output (print test stdout/stderr)
  -h, --help   Show help

Conventions:
  - Discovers tests under ./.cursor/scripts matching pattern: *.test.sh
  - Runs each test in a fresh bash process; exit code 0 = pass, non-zero = fail

Examples:
  # Run all tests
  run.sh
  
  # Run tests with keyword filter (verbose)
  run.sh -k pr-create -v
  
  # Run specific test file
  run.sh /path/to/test.sh
USAGE
  
  print_exit_codes
}

KEYWORD=""
VERBOSE=0

# Handle --help before getopts (getopts only handles short options)
case "${1:-}" in
  --help) usage; exit 0 ;;
esac

while getopts ":k:vh" opt; do
  case "$opt" in
    k) KEYWORD="$OPTARG" ;;
    v) VERBOSE=1 ;;
    h) usage; exit 0 ;;
    :) log_error "Option -$OPTARG requires an argument"; usage; exit 2 ;;
    \?) log_error "Unknown option: -$OPTARG"; usage; exit 2 ;;
  esac
done
shift $((OPTIND - 1))

collect_tests() {
  if [ "$#" -gt 0 ]; then
    printf '%s\n' "$@"
  else
    find "$ROOT_DIR/.cursor/scripts" -type f -name "*.test.sh" | sort -f
  fi
}

mapfile -t TESTS < <(collect_tests "$@")

# Filter by keyword if provided
if [ -n "$KEYWORD" ]; then
  mapfile -t TESTS < <(printf '%s\n' "${TESTS[@]}" | grep -i "$KEYWORD" || true)
fi

if [ "${#TESTS[@]}" -eq 0 ]; then
  log_info "No tests found."
  exit 0
fi

passes=0
fails=0
failed_list=()
outputs_dir="$(mktemp -d 2>/dev/null || mktemp -d -t sh-tests)"

# Run each test in a subshell for environment isolation (D6)
for t in "${TESTS[@]}"; do
  if [ $VERBOSE -eq 1 ]; then
    log_info "Running: $t"
  fi
  out="$outputs_dir/$(basename "$t").out"
  set +e
  (
    # Isolate test environment variables in subshell
    export TEST_ARTIFACTS_DIR="${TEST_ARTIFACTS_DIR:-.test-artifacts}"
    export ALP_LOG_DIR="$TEST_ARTIFACTS_DIR/alp"
    mkdir -p "$ALP_LOG_DIR" || true
    bash "$t"
  ) >"$out" 2>&1
  status=$?
  set -e
  if [ $status -eq 0 ]; then
    passes=$((passes + 1))
    if [ $VERBOSE -eq 1 ]; then
      printf 'PASS %s\n' "$t"
      cat "$out"
      printf '\n'
    else
      printf '.'
    fi
  else
    fails=$((fails + 1))
    failed_list+=("$t")
    if [ $VERBOSE -eq 1 ]; then
      printf 'FAIL %s (exit=%d)\n' "$t" "$status"
      cat "$out"
      printf '\n'
    else
      printf 'F'
    fi
  fi
done

if [ $VERBOSE -eq 0 ]; then
  printf '\n'
fi

log_info "Summary: ${passes} passed, ${fails} failed, ${#TESTS[@]} total"

if [ $fails -ne 0 ]; then
  printf '\nFailed tests:\n'
  for f in "${failed_list[@]}"; do
    printf ' - %s\n' "$f"
  done
  exit 1
fi

exit 0
