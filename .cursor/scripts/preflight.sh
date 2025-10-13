#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Preflight: check presence/absence of common configs and print guidance

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

VERSION="0.1.0"

usage() {
  cat <<'USAGE'
Usage: preflight.sh [--version] [-h|--help]

Run preflight checks for repository configuration.

Checks:
  - .cursor/scripts directory exists
  - .cursor/rules directory exists
  - Common config files present

Options:
  --version   Print version and exit
  -h, --help  Show this help and exit

Examples:
  # Run all preflight checks
  preflight.sh
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

ROOT_DIR="$(repo_root)"

missing=0

desc() { printf ' - %s\n' "$1"; }

log_info "Preflight checks:"

# Check scripts directory
if [ -d "$ROOT_DIR/.cursor/scripts" ]; then
  desc ".cursor/scripts present"
else
  log_warn ".cursor/scripts missing — create and add executables"
  missing=$((missing+1))
fi

# Check .cursor/rules
if [ -d "$ROOT_DIR/.cursor/rules" ]; then
  desc ".cursor/rules present"
else
  log_warn ".cursor/rules missing — add repository rules for Cursor"
  missing=$((missing+1))
fi

# Check docs/workspace-security.md
if [ -f "$ROOT_DIR/docs/workspace-security.md" ]; then
  desc "docs/workspace-security.md present"
else
  log_warn "docs/workspace-security.md missing — add Workspace Security doc"
  missing=$((missing+1))
fi

# Jest config optional — just note if present
if [ -f "$ROOT_DIR/jest.config.cjs" ] || [ -f "$ROOT_DIR/jest.config.js" ]; then
  desc "Jest config present"
else
  desc "Jest config not found (ok if not using Jest)"
fi

if [ $missing -gt 0 ]; then
  log_warn "Preflight found $missing missing item(s). See messages above."
  exit 1
fi

log_info "Preflight OK"
