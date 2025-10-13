#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Lint GitHub workflows using actionlint if present

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

VERSION="0.1.0"

usage() {
  cat <<'USAGE'
Usage: lint-workflows.sh [--version] [-h|--help]

Lint GitHub Actions workflow files using actionlint.

Options:
  --version   Print version and exit
  -h, --help  Show this help and exit

Examples:
  # Lint all workflows
  lint-workflows.sh

Note: Requires actionlint binary. Install from: https://github.com/rhysd/actionlint#installation
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
WF_DIR="$ROOT_DIR/.github/workflows"

if [ ! -d "$WF_DIR" ]; then
  log_info "No .github/workflows directory; nothing to lint"
  exit 0
fi

if ! have_cmd actionlint; then
  log_error "actionlint not found. Install: https://github.com/rhysd/actionlint#installation"
  exit "$EXIT_DEPENDENCY"
fi

actionlint -color always "$WF_DIR" || die 1 "actionlint reported issues"
