#!/usr/bin/env bash
# Wrapper for coordination client CLI
# Usage: coordination-client.sh <role> <command> [args...]

set -euo pipefail

# Ensure build exists
if [[ ! -f "dist/coordination/cli.js" ]]; then
  echo "Error: Coordination client not built. Run: yarn build:coordination" >&2
  exit 1
fi

# Execute compiled CLI
exec node dist/coordination/cli.js "$@"

