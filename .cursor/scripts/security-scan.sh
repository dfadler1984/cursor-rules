#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Minimal security scan wrapper
# If package.json exists, run npm/yarn audit; else, print guidance and exit 0

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

VERSION="0.1.0"

usage() {
  cat <<'USAGE'
Usage: security-scan.sh [--version] [-h|--help]

Run security audit on npm/yarn dependencies.

Checks:
  - Looks for package.json in current directory or repository root
  - Runs yarn npm audit or npm audit if available
  - Gracefully skips if no package.json or package manager found

Options:
  --version   Print version and exit
  -h, --help  Show this help and exit

Examples:
  # Run security scan
  security-scan.sh
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

# Prefer current working directory during tests; fallback to repo root
ROOT_DIR="$(repo_root)"
CWD="$(pwd)"
SCAN_DIR="$CWD"
if [ ! -f "$CWD/package.json" ] && [ -f "$ROOT_DIR/package.json" ]; then
  SCAN_DIR="$ROOT_DIR"
fi

if [ -f "$SCAN_DIR/package.json" ]; then
  if have_cmd yarn; then
    log_info "Running: yarn npm audit --all"
    yarn npm audit --all || true
  elif have_cmd npm; then
    log_info "Running: npm audit"
    npm audit || true
  else
    log_warn "Neither yarn nor npm found; skipping audit"
  fi
else
  echo "No package.json; skipping security scan" >&2
  exit 0
fi
