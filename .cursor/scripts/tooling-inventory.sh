#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"

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

case "${1-}" in
  --detect) detect ;;
  *) print_table ;;
esac

