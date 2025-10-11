#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Migrates centralized tests under .cursor/scripts/tests/*.test.sh
# to be colocated next to their owners in .cursor/scripts/<name>.test.sh

usage() {
  cat <<'USAGE'
Usage: .cursor/scripts/test-colocation-migrate.sh [--root <path>] [--dry-run]

Moves:
  .cursor/scripts/tests/<name>.test.sh → .cursor/scripts/<name>.test.sh (when owner exists)

Options:
  --root <path>   Repository root (defaults to repo root)
  --dry-run       Print planned moves without changing files
USAGE
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root) ROOT_DIR="$(cd "$2" && pwd)"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
done

SCRIPTS_DIR="$ROOT_DIR/.cursor/scripts"
TESTS_DIR="$SCRIPTS_DIR/tests"

[[ -d "$TESTS_DIR" ]] || { echo "No centralized tests dir: $TESTS_DIR" >&2; exit 0; }

moves=()
while IFS= read -r -d '' t; do
  name="$(basename "$t" .test.sh)"
  owner="$SCRIPTS_DIR/$name.sh"
  dest="$SCRIPTS_DIR/$name.test.sh"
  [[ -f "$owner" ]] || continue
  if [[ -f "$dest" ]]; then
    echo "Skip: destination exists $dest" >&2
    continue
  fi
  moves+=("$t => $dest")
  if (( DRY_RUN )); then
    continue
  fi
  git mv "$t" "$dest" 2>/dev/null || mv "$t" "$dest"
  chmod +x "$dest" || true
done < <(find "$TESTS_DIR" -type f -name "*.test.sh" -print0)

if (( ${#moves[@]} == 0 )); then
  echo "No moves needed."
else
  printf 'Planned/Performed moves:\n'
  printf ' - %s\n' "${moves[@]}"
fi

exit 0


