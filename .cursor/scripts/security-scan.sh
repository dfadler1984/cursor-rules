#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Minimal security scan wrapper
# If package.json exists, run npm/yarn audit; else, print guidance and exit 0

# shellcheck disable=SC1090
source "$(dirname "$0")/.lib.sh"

ROOT_DIR="$(repo_root)"

if [ -f "$ROOT_DIR/package.json" ]; then
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
  log_info "No package.json; skipping security scan"
fi
