#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Branch name helper: suggest and validate.
# Usage: .cursor/scripts/git-branch-name.sh --task <slug> [--type <feat|fix|...>] [--feature <name>] [--apply]
#        [-h|--help] [--version]
#
# Format: <login>/<type>-<feature>-<task>
# - login derived from origin owner, GITHUB_ACTOR, GIT_LOGIN, or git user.name fallback
# - type validated from conventional set

# shellcheck disable=SC1090
source "$(dirname "$0")/.lib.sh"

VERSION="0.1.0"

usage() {
  cat <<'USAGE'
Usage: git-branch-name.sh --task <slug> [--type <feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert>] [--feature <name>] [--apply] [--version] [-h|--help]

Options:
  --task <slug>    Required task slug (kebab-case)
  --type <type>    Conventional type (default: feat)
  --feature <name> Optional feature name (kebab-case)
  --apply          Rename current branch to suggested name
  --version        Print version and exit
  -h, --help       Show this help and exit
USAGE
}

TYPE="feat"
TASK=""
FEATURE=""
APPLY=0

valid_type() {
  case "$1" in
    feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert) return 0 ;;
    *) return 1 ;;
  esac
}

slug_ok() {
  # kebab-case only
  printf '%s' "$1" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'
}

login_from_origin() {
  if git rev-parse --git-dir >/dev/null 2>&1; then
    local url
    url=$(git remote get-url origin 2>/dev/null || true)
    # Patterns: git@github.com:owner/repo.git or https://github.com/owner/repo.git
    printf '%s' "$url" | sed -E 's#.*github.com[:/]+([^/]+)/(.*)#\1#' | sed 's/.git$//' || true
  fi
}

resolve_login() {
  if [ -n "${GIT_LOGIN:-}" ]; then printf '%s\n' "$GIT_LOGIN"; return; fi
  if [ -n "${GITHUB_ACTOR:-}" ]; then printf '%s\n' "$GITHUB_ACTOR"; return; fi
  local o
  o="$(login_from_origin || true)"
  if [ -n "$o" ]; then printf '%s\n' "$o"; return; fi
  git config user.name 2>/dev/null | tr ' ' '-' | tr '[:upper:]' '[:lower:]' || printf 'user'
}

while [ $# -gt 0 ]; do
  case "$1" in
    --task) TASK="${2:-}"; shift 2 ;;
    --type) TYPE="${2:-}"; shift 2 ;;
    --feature) FEATURE="${2:-}"; shift 2 ;;
    --apply) APPLY=1; shift ;;
    --version) printf '%s\n' "$VERSION"; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    *) die 2 "Unknown argument: $1" ;;
  esac
done

[ -n "$TASK" ] || die 2 "--task is required"
valid_type "$TYPE" || die 2 "Invalid type: $TYPE"
slug_ok "$TASK" || die 2 "--task must be kebab-case"
if [ -n "$FEATURE" ] && ! slug_ok "$FEATURE"; then die 2 "--feature must be kebab-case"; fi

LOGIN="$(resolve_login)"

NAME="$LOGIN/$TYPE"
if [ -n "$FEATURE" ]; then
  NAME+="-$FEATURE"
fi
NAME+="-$TASK"

printf '%s\n' "$NAME"

if [ $APPLY -eq 1 ]; then
  require_cmd git
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    die 1 "Not inside a git repository"
  fi
  git branch -m "$NAME"
fi
