#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

VERSION="0.1.0"

usage() {
  cat <<'USAGE'
Usage: tooling-inventory.sh [--detect] [--version] [-h|--help]

Display tooling inventory table for the repository.

Options:
  --detect    Auto-detect tool presence (enhanced table)
  --version   Print version and exit
  -h, --help  Show this help and exit

Examples:
  # Show static inventory table
  tooling-inventory.sh
  
  # Show inventory with auto-detection
  tooling-inventory.sh --detect
USAGE
  
  print_exit_codes
}

ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

print_table() {
  cat <<'TABLE'
Category | Present | Config File(s) | Enforcement | Owner
---|---|---|---|---
ESLint/Prettier | TBD | .eslintrc*, .prettierrc* | TBD | TBD
Jest (JS/TS) | TBD | jest.*, package.json | TBD | TBD
Shell tests | Yes | .cursor/scripts/tests/run.sh | Partial | eng-tools
Changesets | Yes | .changeset/, package.json | CI gated | eng-tools
CI Workflows | Yes | .github/workflows/*.yml | Mixed | eng-tools
Security scans | TBD | scripts/security* | TBD | TBD
Git hooks | TBD | .husky/, scripts | TBD | TBD
Project lifecycle | Yes | .cursor/scripts/validate-project-lifecycle.sh | Optional | eng-tools
Docs checks | Yes | .cursor/scripts/links-check.sh | Optional | eng-tools
Logging (ALP) | Yes | .cursor/scripts/alp-*.sh | Local-only | eng-tools
TABLE
}

detect() {
  local security_present="No"
  if ls "$ROOT_DIR"/.cursor/scripts/security-scan.sh >/dev/null 2>&1; then
    security_present="Yes"
  fi
  # Print with computed security row
  cat <<TABLE
Category | Present | Config File(s) | Enforcement | Owner
---|---|---|---|---
ESLint/Prettier | TBD | .eslintrc*, .prettierrc* | TBD | TBD
Jest (JS/TS) | TBD | jest.*, package.json | TBD | TBD
Shell tests | Yes | .cursor/scripts/tests/run.sh | Partial | eng-tools
Changesets | Yes | .changeset/, package.json | CI gated | eng-tools
CI Workflows | Yes | .github/workflows/*.yml | Mixed | eng-tools
Security scans | ${security_present} | scripts/security* | TBD | TBD
Git hooks | TBD | .husky/, scripts | TBD | TBD
Project lifecycle | Yes | .cursor/scripts/validate-project-lifecycle.sh | Optional | eng-tools
Docs checks | Yes | .cursor/scripts/links-check.sh | Optional | eng-tools
Logging (ALP) | Yes | .cursor/scripts/alp-*.sh | Local-only | eng-tools
TABLE
}

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --detect) detect; exit 0 ;;
    --version) printf '%s\n' "$VERSION"; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    *) die "$EXIT_USAGE" "Unknown argument: $1" ;;
  esac
done

# Default: print static table
print_table
