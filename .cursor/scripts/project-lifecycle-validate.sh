#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# project-lifecycle-validate.sh — dry-run validator for completed projects
# Usage: .cursor/scripts/project-lifecycle-validate.sh [--projects-dir docs/projects]
# Exits non-zero if any completed project is missing required artifacts.

PROJECTS_DIR=${1:-docs/projects}
if [[ "$1" == "--projects-dir" ]]; then
  PROJECTS_DIR=${2:-docs/projects}
fi

failures=0

shopt -s nullglob
for erd in "$PROJECTS_DIR"/*/erd.md; do
  dir=$(dirname "$erd")
  name=$(basename "$dir")

  # Read first 50 lines to catch front matter quickly
  head_block=$(head -n 50 "$erd" || true)

  # Detect completed status (portable on BSD/macOS grep)
  if echo "$head_block" | grep -iqE '^status:[[:space:]]*completed'; then
    missing=()
    # Require completed date in ISO format and owner field
    if ! echo "$head_block" | grep -Eq '^completed:[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
      missing+=("front matter: completed date (YYYY-MM-DD)")
    fi
    if ! echo "$head_block" | grep -iqE '^owner:[[:space:]]*'; then
      missing+=("front matter: owner")
    fi
    if [[ ! -f "$dir/final-summary.md" ]]; then
      missing+=("final-summary.md missing")
    fi
    # Check presence in projects README (best-effort)
    # Accept either pre-move (Active: ./<name>/erd.md) or post-move (Completed: _archived/<YYYY>/<name>/final-summary.md)
    if [[ -f "$PROJECTS_DIR/README.md" ]]; then
      if grep -q "^##[[:space:]]*Completed" "$PROJECTS_DIR/README.md"; then
        # Completed section: accept archived final-summary.md, archived erd.md, or local ./<name>/erd.md (test env)
        if ! grep -q "\[$name\](_archived/.*/$name/final-summary.md)" "$PROJECTS_DIR/README.md" \
           && ! grep -q "\[$name\](_archived/.*/$name/erd.md)" "$PROJECTS_DIR/README.md" \
           && ! grep -q "\[$name\](\./$name/erd.md)" "$PROJECTS_DIR/README.md"; then
          missing+=("projects/README.md entry missing or not linkified")
        fi
      else
        # Fallback (pre-move): ensure Active entry exists
        if ! grep -q "\[$name\](\./$name/erd.md)" "$PROJECTS_DIR/README.md"; then
          missing+=("projects/README.md entry missing or not linkified (Active)")
        fi
      fi
    fi

    if (( ${#missing[@]} > 0 )); then
      failures=$((failures+1))
      printf "[FAIL] %s\n" "$name" >&2
      for m in "${missing[@]}"; do
        printf "  - %s\n" "$m" >&2
      done
    else
      printf "[OK] %s\n" "$name"
    fi
  fi
done

if (( failures > 0 )); then
  printf "\n%d completed project(s) failed validation.\n" "$failures" >&2
  exit 1
fi

printf "All completed projects passed validation.\n"
