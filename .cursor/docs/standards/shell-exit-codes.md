# Shell Script Exit Code Standards (D3)

**Purpose**: Standardized exit codes for all shell scripts in `.cursor/scripts/`  
**Source**: Extracted from shell-and-script-tooling project (Decision D3)  
**Enforcement**: Validated by `.cursor/scripts/error-validate.sh`

---

## Standard Exit Codes

All scripts must use these standardized exit codes from `.lib.sh`:

| Code | Constant | Meaning | Usage |
|------|----------|---------|-------|
| 0 | (success) | Command succeeded | Normal successful completion |
| 2 | `EXIT_USAGE` | Usage error | Missing required args, invalid flags, bad syntax |
| 3 | `EXIT_CONFIG` | Configuration error | Bad config file, missing settings, invalid configuration |
| 4 | `EXIT_DEPENDENCY` | Dependency missing | Required command not found, missing tool |
| 5 | `EXIT_NETWORK` | Network failure | API call failed, connection error, timeout |
| 6 | `EXIT_TIMEOUT` | Timeout | Operation exceeded time limit |
| 20 | `EXIT_INTERNAL` | Internal error | Unexpected condition, assertion failure, bug |

---

## Usage

### Import Constants

```bash
#!/usr/bin/env bash
# Source .lib.sh to get EXIT_* constants
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/.lib.sh"
```

### Use with die() Helper

```bash
# Usage error
[ -n "$required_arg" ] || die "$EXIT_USAGE" "--required argument missing"

# Config error
[ -f "$config_file" ] || die "$EXIT_CONFIG" "Config file not found: $config_file"

# Dependency error
have_cmd jq || die "$EXIT_DEPENDENCY" "jq is required but not installed"

# Network error
curl -f "$url" || die "$EXIT_NETWORK" "Failed to fetch: $url"

# Timeout
timeout 30 "$command" || die "$EXIT_TIMEOUT" "Command exceeded 30s timeout"

# Internal error (should never happen)
[ "$result" = "expected" ] || die "$EXIT_INTERNAL" "Unexpected result: $result"
```

### Direct Exit

```bash
# When not using die() helper
if [ -z "$PROJECT" ]; then
  echo "ERROR: Missing required argument: --project <slug>" >&2
  exit "$EXIT_USAGE"
fi
```

---

## Error Message Guidelines

**User-facing failures**:
- Use `die` helper for concise stderr messages
- Keep messages short and actionable
- stdout remains machine-output only (parseable)

**Examples**:

✅ Good:
```bash
die "$EXIT_USAGE" "--project is required"
die "$EXIT_CONFIG" "Invalid year: $YEAR (must be YYYY)"
die "$EXIT_DEPENDENCY" "git is required but not found in PATH"
```

❌ Avoid:
```bash
echo "ERROR: The --project argument is required but was not provided" >&2
exit 1  # Non-standard exit code
```

---

## Validation

**Check compliance**:
```bash
# Validate all scripts use standard exit codes
.cursor/scripts/error-validate.sh
```

**Expected**: 0 violations (all scripts use EXIT_* constants)

---

## Implementation in .lib.sh

Exit codes are defined in `.cursor/scripts/.lib.sh`:

```bash
# Standard exit codes (D3)
readonly EXIT_USAGE=2
readonly EXIT_CONFIG=3
readonly EXIT_DEPENDENCY=4
readonly EXIT_NETWORK=5
readonly EXIT_TIMEOUT=6
readonly EXIT_INTERNAL=20
```

---

## Related Standards

**D1**: Help/Version documentation (see `.cursor/docs/standards/shell-help-format.md`)  
**D2**: Strict mode baseline (see `.lib.sh` - `enable_strict_mode()`)  
**D4**: Test isolation/networkless (see `.cursor/docs/standards/shell-network-policy.md`)  
**D5**: Dependency portability (see `.lib.sh` - `have_cmd()`)

---

**Origin**: shell-and-script-tooling project (2025-10-13, archived)  
**Status**: Active standard, enforced by error-validate.sh  
**Adoption**: 100% (all 47 validated scripts compliant)

