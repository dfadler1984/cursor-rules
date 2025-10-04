#!/usr/bin/env bash
set -euo pipefail

# alp-logger.sh — write learning logs with fallback and redaction
# Usage:
#   .cursor/scripts/alp-logger.sh write-with-fallback <destDir> <short-name> <<'BODY'
#   ...log body...
#   BODY

usage() {
  echo "Usage: $0 write-with-fallback <destDir> <short-name>" >&2
  exit 1
}

timestamp_iso() {
  date -u +%Y-%m-%dT%H-%M-%SZ
}

slugify() {
  local input="$1"
  echo "$input" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

write_with_fallback() {
  local destDir="$1"
  local shortName="$2"
  local ts
  ts="$(timestamp_iso)"
  local fileName
  fileName="log-${ts}-$(slugify "$shortName").md"

  local primaryDir
  # Allow tests to redirect logs to a temp dir via ALP_LOG_DIR
  if [[ -n "${ALP_LOG_DIR-}" ]]; then
    primaryDir="${ALP_LOG_DIR}"
  else
    primaryDir="${destDir}"
  fi
  local fallbackDir
  fallbackDir="docs/assistant-learning-logs"

  mkdir -p -- "$primaryDir" || true
  mkdir -p -- "$fallbackDir" || true

  local body
  body="$(cat -)"

  # Redact via helper if present; if it fails (e.g., BSD sed incompat), skip redaction
  if [[ -x ".cursor/scripts/alp-redaction.sh" ]]; then
    if redacted="$(printf "%s" "$body" | .cursor/scripts/alp-redaction.sh 2>/dev/null)"; then
      body="$redacted"
    fi
  fi

  local target
  target="$primaryDir/$fileName"
  if printf "%s\n" "$body" > "$target" 2>/dev/null; then
    echo "$target"
    return 0
  fi

  target="$fallbackDir/$fileName"
  printf "%s\n" "$body" > "$target"
  echo "$target"
}

main() {
  if [[ $# -lt 3 ]]; then
    usage
  fi
  local cmd="$1"; shift
  case "$cmd" in
    write-with-fallback)
      write_with_fallback "$@"
      ;;
    *)
      usage
      ;;
  esac
}

main "$@"
