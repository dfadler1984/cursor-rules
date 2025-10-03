#!/usr/bin/env bash
set -euo pipefail

# Sourceable helper: provides a function `alp_log` to write a learning log.
# Usage:
#   source .cursor/scripts/alp-aliases.sh
#   alp_log "short-name" <<'BODY'
#   Timestamp: ...
#   ...
#   BODY

alp_log() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: alp_log <short-name>" >&2
    return 2
  fi
  local shortName="$1"; shift || true
  local destDir
  # Resolve destination directory with precedence: env override -> .cursor/config.json -> default
  if [[ -n "${ASSISTANT_LOG_DIR:-}" ]]; then
    destDir="$ASSISTANT_LOG_DIR"
  elif [[ -f ".cursor/config.json" ]]; then
    # Use jq if available; otherwise fall back to default
    if command -v jq >/dev/null 2>&1; then
      destDir="$(jq -r '.logDir // "assistant-logs"' < .cursor/config.json)"
    else
      destDir="assistant-logs"
    fi
  else
    destDir="assistant-logs"
  fi
  .cursor/scripts/alp-logger.sh write-with-fallback "$destDir" "$shortName"
}

export -f alp_log


