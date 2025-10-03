#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/alp-archive.sh"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/assistant-logs"

# Create two logs: one reviewed, one not
log_reviewed="$tmpdir/assistant-logs/log-2025-10-01T17-03-00Z-reviewed-case.md"
log_unreviewed="$tmpdir/assistant-logs/log-2025-10-01T17-04-00Z-unreviewed-case.md"
printf '%s\n' "Timestamp: 2025-10-01T17:03:00Z" >"$log_reviewed"
printf '%s\n' "Timestamp: 2025-10-01T17:04:00Z" >"$log_unreviewed"

# Mark the first as reviewed
OUT_MARK="$($SCRIPT mark "$log_reviewed" --date 2025-10-02)"
[ "$OUT_MARK" = "$log_reviewed" ] || { echo "mark output path mismatch"; exit 1; }
grep -q '^Reviewed: 2025-10-02$' "$log_reviewed" || { echo "missing Reviewed marker"; exit 1; }

# Dry-run archive should show only the reviewed file
DRY_OUT="$($SCRIPT archive --source "$tmpdir/assistant-logs" --dry-run)"
echo "$DRY_OUT" | grep -q "reviewed-case.md" || { echo "dry-run did not include reviewed"; exit 1; }
echo "$DRY_OUT" | grep -q "unreviewed-case.md" && { echo "dry-run included unreviewed"; exit 1; }

# Real archive
ARCHIVE_OUTS="$($SCRIPT archive --source "$tmpdir/assistant-logs")"
echo "$ARCHIVE_OUTS" | grep -q "/_archived/2025/10/log-2025-10-01T17-03-00Z-reviewed-case.md" || { echo "archive path unexpected"; echo "$ARCHIVE_OUTS"; exit 1; }

# File moved and contains Archived stamp
[ ! -f "$log_reviewed" ] || { echo "reviewed file not moved"; exit 1; }
archived_path="$tmpdir/assistant-logs/_archived/2025/10/log-2025-10-01T17-03-00Z-reviewed-case.md"
[ -f "$archived_path" ] || { echo "archived file missing"; exit 1; }
grep -q '^Archived: ' "$archived_path" || { echo "missing Archived stamp"; exit 1; }

# Unreviewed file remains in place
[ -f "$log_unreviewed" ] || { echo "unreviewed file moved unexpectedly"; exit 1; }

# Summary file created under docs/assistant-learning-logs
summary_path=$(printf "%s" "$ARCHIVE_OUTS" | grep 'docs/assistant-learning-logs/summary-archived-' | tail -n1 || true)
[ -n "$summary_path" ] || { echo "summary path not printed"; echo "$ARCHIVE_OUTS"; exit 1; }
[ -f "$summary_path" ] || { echo "summary file missing"; exit 1; }
grep -q "# Archived Assistant Learning Logs" "$summary_path" || { echo "summary header missing"; exit 1; }
grep -q "## Learnings" "$summary_path" || { echo "summary missing Learnings section"; exit 1; }

exit 0


