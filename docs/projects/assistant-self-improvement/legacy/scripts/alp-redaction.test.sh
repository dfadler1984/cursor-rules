#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../" && pwd)"
SCRIPT="$ROOT_DIR/docs/projects/assistant-self-improvement/legacy/scripts/alp-redaction.sh"

SK_PREFIX="sk"; SK_ENV="live"; STRIPE_KEY="${SK_PREFIX}_${SK_ENV}_1234567890abcdefghijklmnopqrstuvwxyz"
GHP_PREFIX="gh"; GITHUB_PAT="${GHP_PREFIX}p_abcdefghijklmnopqrstuvwxyz0123456789"

INPUT=$(cat <<EOF
Authorization: Bearer abcdefghijklmnopqrstuvwxyz0123456789
X-API-Key: ${STRIPE_KEY}
token=${GITHUB_PAT}
EOF
)

EXPECTED=$(cat <<'EOF'
Authorization: [REDACTED]
X-API-Key: [REDACTED]
token=[REDACTED]
EOF
)

OUT=$(printf '%s' "$INPUT" | bash "$SCRIPT" redact)

if [ "$OUT" != "$EXPECTED" ]; then
  echo "Redaction mismatch"
  echo "Got:"; echo "$OUT"
  echo "Expected:"; echo "$EXPECTED"
  exit 1
fi

exit 0


