#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

VERSION="0.1.0"

usage() {
  cat <<'USAGE'
Usage: project-lifecycle-validate-scoped.sh <slug> [--version] [-h|--help]

Validate lifecycle artifacts for a specific project.

Wrapper for: validate-project-lifecycle.sh

Arguments:
  <slug>      Project slug under docs/projects

Options:
  --version   Print version and exit
  -h, --help  Show this help and exit

Examples:
  # Validate single project
  project-lifecycle-validate-scoped.sh my-project
USAGE
  
  print_exit_codes
}

# Parse help/version before delegating
case "${1:-}" in
  -h|--help) usage; exit 0 ;;
  --version) printf '%s\n' "$VERSION"; exit 0 ;;
esac

# Delegate to main validator
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
exec "$ROOT_DIR/.cursor/scripts/validate-project-lifecycle.sh" "$@"
