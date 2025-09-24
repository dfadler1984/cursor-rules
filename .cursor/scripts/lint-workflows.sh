#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Lint GitHub workflows using actionlint if present

# shellcheck disable=SC1090
source "$(dirname "$0")/.lib.sh"

ROOT_DIR="$(repo_root)"
WF_DIR="$ROOT_DIR/.github/workflows"

if [ ! -d "$WF_DIR" ]; then
  log_info "No .github/workflows directory; nothing to lint"
  exit 0
fi

if ! have_cmd actionlint; then
  log_error "actionlint not found. Install: https://github.com/rhysd/actionlint#installation"
  exit 1
fi

actionlint -color always "$WF_DIR" || die 1 "actionlint reported issues"
