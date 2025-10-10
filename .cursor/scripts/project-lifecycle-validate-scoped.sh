#!/usr/bin/env bash
set -euo pipefail

# Wrapper alias: scoped project lifecycle validator (per changed projects)
# Delegates to the legacy script for backward compatibility

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
exec "$ROOT_DIR/.cursor/scripts/validate-project-lifecycle.sh" "$@"


