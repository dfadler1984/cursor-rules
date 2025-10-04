#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Minimal security scan wrapper
# If package.json exists, run npm/yarn audit; else, print guidance and exit 0

# shellcheck disable=SC1090
source "$(dirname "$0")/.lib.sh"

# Prefer current working directory during tests; fallback to repo root
ROOT_DIR="$(repo_root)"
CWD="$(pwd)"
SCAN_DIR="$CWD"
if [ ! -f "$CWD/package.json" ] && [ -f "$ROOT_DIR/package.json" ]; then
  SCAN_DIR="$ROOT_DIR"
fi

if [ -f "$SCAN_DIR/package.json" ]; then
  if have_cmd yarn; then
    log_info "Running: yarn npm audit --all"
    yarn npm audit --all || true
  elif have_cmd npm; then
    log_info "Running: npm audit"
    npm audit || true
  else
    log_warn "Neither yarn nor npm found; skipping audit"
  fi
else
  echo "No package.json; skipping security scan" >&2
  exit 0
fi
