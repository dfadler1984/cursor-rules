#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<'USAGE'
Usage: alp-redaction.sh redact < input

Reads from stdin and writes redacted output to stdout.
Redacts:
- Authorization-like headers (Authorization, X-API-Key, X-Auth-Token)
- Token-looking substrings (ghp_..., sk_live/test_..., bearer tokens, key/token/secret=...)
USAGE
}

redact_stream() {
  awk 'BEGIN{IGNORECASE=1}
  {
    split($0, a, ":");
    key=a[1];
    low=tolower(key);
    if (low=="authorization" || low=="x-api-key" || low=="x-auth-token") {
      print a[1] ": [REDACTED]";
    } else {
      print $0;
    }
  }' |
  sed -E \
    -e 's/(^|[[:space:]])(ghp_[A-Za-z0-9]{20,})/\1[REDACTED]/g' \
    -e 's/(^|[[:space:]])(sk_(live|test)_[A-Za-z0-9]{20,})/\1[REDACTED]/g' \
    -e 's/([Aa][Pp][Ii][-_]?[Kk][Ee][Yy]|[Tt][Oo][Kk][Ee][Nn]|[Ss][Ee][Cc][Rr][Ee][Tt])=[^[:space:]]+/\1=[REDACTED]/g' \
    -e 's/[Bb]earer[[:space:]]+[A-Za-z0-9._-]{10,}/Bearer [REDACTED]/g'
}

case "${1:-}" in
  redact) redact_stream ;;
  -h|--help|*) usage ;;
esac


