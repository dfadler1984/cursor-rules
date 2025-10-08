#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/project-archive.sh"

# Arrange: create a temp workspace root to avoid touching real repo paths
WORKDIR="$(mktemp -d 2>/dev/null || mktemp -d -t proj-archive)"
mkdir -p "$WORKDIR/docs/projects/rules-validate-script"
echo "sample" > "$WORKDIR/docs/projects/rules-validate-script/README.md"

# 1) Dry-run should NOT move files and should print planned actions
set +e
dry_out="$(bash "$SCRIPT" --project rules-validate-script --year 2025 --root "$WORKDIR" --dry-run 2>&1)"
dry_status=$?
set -e
[ $dry_status -eq 0 ] || { echo "dry-run should succeed"; echo "$dry_out"; exit 1; }
[ -d "$WORKDIR/docs/projects/rules-validate-script" ] || { echo "source should remain on dry-run"; exit 1; }
echo "$dry_out" | grep -q "Would move" || { echo "dry-run should print 'Would move'"; echo "$dry_out"; exit 1; }

# 2) Real run should move project to archived/year path
run_out="$(bash "$SCRIPT" --project rules-validate-script --year 2025 --root "$WORKDIR" 2>&1)"
echo "$run_out" | grep -qi "archived" || { echo "expected archive confirmation in output"; echo "$run_out"; exit 1; }
[ ! -d "$WORKDIR/docs/projects/rules-validate-script" ] || { echo "source dir should be removed after archive"; exit 1; }
[ -d "$WORKDIR/docs/projects/_archived/2025/rules-validate-script" ] || { echo "archived dir missing"; exit 1; }
[ -f "$WORKDIR/docs/projects/_archived/2025/rules-validate-script/README.md" ] || { echo "moved file missing in archive"; exit 1; }

exit 0


