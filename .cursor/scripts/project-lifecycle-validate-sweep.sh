#!/usr/bin/env bash
set -euo pipefail

# Wrapper alias: sweep validator for all completed projects
# Delegates to the repo-scan script for backward compatibility

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
exec "$ROOT_DIR/.cursor/scripts/project-lifecycle-validate.sh" "$@"


