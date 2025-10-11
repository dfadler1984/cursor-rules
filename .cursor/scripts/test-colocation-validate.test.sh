#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/test-colocation-validate.sh"
TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t colocation-test)"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

mkdir -p "$TMP_DIR/.cursor/scripts/tests"

# Create maintained owner scripts
cat > "$TMP_DIR/.cursor/scripts/foo.sh" <<'SH'
#!/usr/bin/env bash
exit 0
SH
chmod +x "$TMP_DIR/.cursor/scripts/foo.sh"

cat > "$TMP_DIR/.cursor/scripts/bar.sh" <<'SH'
#!/usr/bin/env bash
exit 0
SH
chmod +x "$TMP_DIR/.cursor/scripts/bar.sh"

# Add centralized test that incorrectly targets foo
cat > "$TMP_DIR/.cursor/scripts/tests/foo.test.sh" <<'SH'
#!/usr/bin/env bash
exit 0
SH
chmod +x "$TMP_DIR/.cursor/scripts/tests/foo.test.sh"

# Add correct colocated test for bar
cat > "$TMP_DIR/.cursor/scripts/bar.test.sh" <<'SH'
#!/usr/bin/env bash
exit 0
SH
chmod +x "$TMP_DIR/.cursor/scripts/bar.test.sh"

set +e
"$SCRIPT" --root "$TMP_DIR" >/dev/null 2>&1
status=$?
set -e

if [[ $status -eq 0 ]]; then
  echo "expected failure due to missing foo.test.sh and centralized foo.test.sh" >&2
  exit 1
fi

# Now fix by adding colocated foo.test.sh and removing centralized one
rm -f "$TMP_DIR/.cursor/scripts/tests/foo.test.sh"
cat > "$TMP_DIR/.cursor/scripts/foo.test.sh" <<'SH'
#!/usr/bin/env bash
exit 0
SH
chmod +x "$TMP_DIR/.cursor/scripts/foo.test.sh"

"$SCRIPT" --root "$TMP_DIR" >/dev/null

echo "OK: test-colocation-validate works"


