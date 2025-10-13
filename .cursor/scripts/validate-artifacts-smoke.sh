#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

VERSION="0.1.0"

usage() {
  cat <<'USAGE'
Usage: validate-artifacts-smoke.sh [--version] [-h|--help]

Smoke test for validate-artifacts.sh using sample artifacts.

Options:
  --version   Print version and exit
  -h, --help  Show this help and exit

Examples:
  # Run smoke tests
  validate-artifacts-smoke.sh
USAGE
  
  print_exit_codes
}

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
  --version) printf '%s\n' "$VERSION"; exit 0 ;;
esac

ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
VALIDATE="$ROOT_DIR/.cursor/scripts/validate-artifacts.sh"

# Default trio
DEFAULT_SPEC="$ROOT_DIR/docs/specs/sample-feature-spec.md"
DEFAULT_PLAN="$ROOT_DIR/docs/plans/sample-feature-plan.md"
DEFAULT_TASKS="$ROOT_DIR/tasks/tasks-sample-feature.md"

echo "[default] validating sample trio"
bash "$VALIDATE" --paths "$DEFAULT_SPEC,$DEFAULT_PLAN,$DEFAULT_TASKS"

# Overridden dirs (simulate by copying to temp)
TMP_DIR="$(mktemp -d)"
mkdir -p "$TMP_DIR/specs" "$TMP_DIR/plans" "$TMP_DIR/tasks"
cp "$DEFAULT_SPEC" "$TMP_DIR/specs/sample-feature-spec.md"
cp "$DEFAULT_PLAN" "$TMP_DIR/plans/sample-feature-plan.md"
cp "$DEFAULT_TASKS" "$TMP_DIR/tasks/tasks-sample-feature.md"

echo "[override] validating copied trio in temp dirs"
bash "$VALIDATE" --paths "$TMP_DIR/specs/sample-feature-spec.md,$TMP_DIR/plans/sample-feature-plan.md,$TMP_DIR/tasks/tasks-sample-feature.md"

echo "Smoke tests passed"
