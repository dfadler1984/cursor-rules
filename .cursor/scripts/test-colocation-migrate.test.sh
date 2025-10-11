#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/test-colocation-migrate.sh"
TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t colocation-migrate)"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

mkdir -p "$TMP_DIR/.cursor/scripts/tests"

cat > "$TMP_DIR/.cursor/scripts/baz.sh" <<'SH'
#!/usr/bin/env bash
exit 0
SH
chmod +x "$TMP_DIR/.cursor/scripts/baz.sh"

cat > "$TMP_DIR/.cursor/scripts/tests/baz.test.sh" <<'SH'
#!/usr/bin/env bash
exit 0
SH
chmod +x "$TMP_DIR/.cursor/scripts/tests/baz.test.sh"

# Dry run should report planned move but not change files
out=$("$SCRIPT" --root "$TMP_DIR" --dry-run)
echo "$out" | grep -q "baz.test.sh" || { echo "expected dry-run to plan baz" >&2; exit 1; }
test -f "$TMP_DIR/.cursor/scripts/tests/baz.test.sh" || { echo "dry-run moved file unexpectedly" >&2; exit 1; }

# Real move
"$SCRIPT" --root "$TMP_DIR" >/dev/null

test -f "$TMP_DIR/.cursor/scripts/baz.test.sh" || { echo "expected baz.test.sh at destination" >&2; exit 1; }
test ! -f "$TMP_DIR/.cursor/scripts/tests/baz.test.sh" || { echo "expected source removed" >&2; exit 1; }

echo "OK: test-colocation-migrate works"


