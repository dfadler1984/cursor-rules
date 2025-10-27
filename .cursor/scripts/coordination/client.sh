#!/usr/bin/env bash
# Wrapper for coordination client CLI

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../.lib.sh
source "$SCRIPT_DIR/../.lib.sh"

usage() {
  print_help_header "client.sh" "Coordination client wrapper"
  print_usage "client.sh <role> <command> [args...]"
  echo ""
  echo "Arguments:"
  echo "  role       coordinator or worker"
  echo "  command    register, create-tasks, complete-task, status"
  print_exit_codes
  echo ""
  echo "Examples:"
  echo "  bash client.sh worker register --worker-id=worker-A"
  echo "  bash client.sh coordinator status"
}

# Parse args
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    *) break ;;
  esac
done

# Ensure build exists
if [[ ! -f "dist/coordination/cli.js" ]]; then
  echo "Error: Coordination client not built. Run: yarn build:coordination" >&2
  exit 4
fi

# Execute compiled CLI
exec node dist/coordination/cli.js "$@"

