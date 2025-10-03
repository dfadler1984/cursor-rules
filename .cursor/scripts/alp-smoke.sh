#!/usr/bin/env bash
set -euo pipefail

# Smoke test: writes a learning log and prints the resulting path

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
cd "$root"

# Resolve dest dir similarly to alp-aliases.sh
if [[ -n "${ASSISTANT_LOG_DIR:-}" ]]; then
  destDir="$ASSISTANT_LOG_DIR"
elif [[ -f ".cursor/config.json" ]] && command -v jq >/dev/null 2>&1; then
  destDir="$(jq -r '.logDir // "assistant-logs"' < .cursor/config.json)"
else
  destDir="assistant-logs"
fi

ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
short="alp-smoke"
body_file="$(mktemp)"
cat >"$body_file" <<EOF
Timestamp: $ts
Event: Smoke Test
Owner: assistant-learning/protocol
What Changed: Smoke test write to verify logging pipeline.
Next Step: N/A
Links: .cursor/scripts/alp-smoke.sh
Outcome: Should print the created log path.
Bottleneck: N/A
Proposed Rule/Script Change: N/A
Interaction Hint: Use this to verify after changes.
EOF

path="$(.cursor/scripts/alp-logger.sh write-with-fallback "$destDir" "$short" <"$body_file")"
rm -f "$body_file"
echo "$path"


