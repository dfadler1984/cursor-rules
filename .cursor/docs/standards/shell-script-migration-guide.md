# Script Standardization Migration Guide


## Overview

All maintained scripts in `.cursor/scripts/` follow these standards:

- **D1**: Help/Version — Standardized help output with Options, Examples, Exit Codes
- **D2**: Strict Mode — Bash strict mode with proper error traps
- **D3**: Error Semantics — Standardized exit codes and error handling
- **D4**: Networkless — Tests use seams/fixtures; production can make network calls
- **D5**: Portability — bash + git only; optional tools degrade gracefully
- **D6**: Test Isolation — Subshell isolation prevents env leakage

## Prerequisites

**Required (all machines):**
- Bash 4.0+
- Git (when in repo context)

**Required for GitHub automation scripts only:**
- `curl` (for pr-create.sh, pr-update.sh, checks-status.sh, changesets-automerge-dispatch.sh)
- `GH_TOKEN` environment variable

**Optional (enhanced UX):**
- `jq` — Better JSON formatting
- `column` — Table formatting
- `shellcheck` — Static analysis

## Remote Machine Setup

### Quick Start (Minimal)

Most scripts work immediately after cloning:

```bash
# On your remote machine
git clone <repo-url>
cd cursor-rules

# These work with zero setup (bash + git only)
bash .cursor/scripts/help-validate.sh      # ✅ Works
bash .cursor/scripts/error-validate.sh     # ✅ Works
bash .cursor/scripts/tests/run.sh          # ✅ Works
bash .cursor/scripts/shellcheck-run.sh     # ✅ Works (degrades gracefully)
```

### Full Setup (For GitHub Automation)

To use GitHub automation scripts (pr-create, pr-update, checks-status):

```bash
# 1. Check if curl is present (usually is)
which curl || {
  # Install if missing
  sudo apt-get install curl      # Debian/Ubuntu
  # OR
  sudo yum install curl          # RHEL/CentOS
  # OR
  brew install curl              # macOS (rarely needed)
}

# 2. Set up GitHub token
# Create token at: https://github.com/settings/tokens
# Requires: repo scope (classic) or Contents: Read/Write + Pull requests: Read/Write (fine-grained)

# Add to your shell profile (~/.bashrc or ~/.zshrc)
export GH_TOKEN="ghp_your_token_here"

# Reload profile
source ~/.bashrc  # or source ~/.zshrc

# 3. Verify setup
bash .cursor/scripts/pr-create.sh --help  # ✅ Should work
```

### Quick Setup Script

Run this one-liner on new machines:

```bash
curl -fsSL https://raw.githubusercontent.com/<your-repo>/main/.cursor/scripts/setup-remote.sh | bash
```

Or manually:

```bash
bash .cursor/scripts/setup-remote.sh
```

This script will:
- Check bash/git versions
- Verify curl availability
- Check for GH_TOKEN (optional, prompts if missing)
- Test validators work
- Report what's ready vs needs setup

## Migration Checklist

For each script you're migrating:

- [ ] Add shebang and strict mode (D2)
- [ ] Source `.lib.sh` helpers (D2, D3)
- [ ] Add help documentation using template functions (D1)
- [ ] Use exit code constants (D3)
- [ ] Use `die` helper for errors (D3)
- [ ] Add `--version` flag (D1)
- [ ] Add owner tests (TDD-first)
- [ ] Validate with `help-validate.sh`, `error-validate.sh`, `network-guard.sh`

## Step-by-Step Migration

### 1. Add Shebang and Strict Mode (D2)

**Before:**

```bash
#!/bin/bash
# ... script content
```

**After:**

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1090
source "$(dirname "$0")/.lib.sh"

VERSION="1.0.0"
```

### 2. Replace Custom Help with Template Functions (D1)

**Before:**

```bash
usage() {
  echo "Usage: script.sh [OPTIONS]"
  echo "  --flag    Some flag"
}
```

**After:**

```bash
usage() {
  print_usage "script.sh [OPTIONS]"

  print_options
  print_option "--flag" "Some flag description"
  print_option "--verbose" "Enable verbose output"
  print_option "--version" "Print version and exit"
  print_option "-h, --help" "Show this help and exit"

  print_examples
  print_example "Basic usage" "script.sh --flag value"
  print_example "Verbose mode" "script.sh --flag value --verbose"

  print_exit_codes
}
```

**Available template functions:**

- `print_usage <pattern>` — Usage line
- `print_options` — Options header
- `print_option <flag> <description> [default]` — Single option
- `print_examples` — Examples header
- `print_example <description> <command>` — Single example
- `print_exit_codes` — Standard exit codes section

### 3. Use Exit Code Constants (D3)

**Before:**

```bash
if [ -z "$required_arg" ]; then
  echo "Error: --required is missing" >&2
  exit 1
fi
```

**After:**

```bash
[ -n "$required_arg" ] || die "$EXIT_USAGE" "--required is required"
```

**Available exit codes from `.lib.sh`:**

- `EXIT_USAGE=2` — Usage error (missing args, invalid flags)
- `EXIT_CONFIG=3` — Configuration error (bad config file, missing settings)
- `EXIT_DEPENDENCY=4` — Dependency missing (required command not found)
- `EXIT_NETWORK=5` — Network failure (API call failed)
- `EXIT_TIMEOUT=6` — Timeout
- `EXIT_INTERNAL=20` — Internal error (unexpected condition)

### 4. Add Version Flag (D1)

**Add to argument parsing:**

```bash
while [ $# -gt 0 ]; do
  case "$1" in
    --version) printf '%s\n' "$VERSION"; exit 0;;
    -h|--help) usage; exit 0;;
    *) die "$EXIT_USAGE" "Unknown argument: $1";;
  esac
done
```

### 5. Network Usage (D4)

**For production scripts that need network access:**

Scripts CAN make real API calls in production. Tests MUST use seams.

```bash
# Production script (e.g., pr-create.sh)
curl -sS -H "Authorization: token $GH_TOKEN" "$api_url"
```

**For tests:**

```bash
# Test file
export CURL_CMD=cat
export JQ_CMD=jq

# Test injects fixture instead of making live call
result=$(echo "$fixture_json" | CURL_CMD=cat SCRIPT_UNDER_TEST)
```

**Validators:**

- `network-guard.sh` — Informational; shows which scripts use network tools

### 6. Portability (D5)

**Required dependencies:**

- bash (≥4.0)
- git (when in repo context)

**Optional dependencies with graceful degradation:**

```bash
if ! have_cmd jq; then
  log_warn "jq not found; output will be less formatted"
  # ... provide fallback behavior
fi

if ! have_cmd column; then
  cat  # Fallback: plain output instead of columnar
else
  column -t -s $'\t'
fi
```

**Pattern for optional tools:**

```bash
have_cmd shellcheck || {
  log_warn "shellcheck not found; skipping linting"
  log_info "Install: brew install shellcheck (macOS)"
  exit 0
}
```

### 7. Test Isolation (D6)

Tests automatically run in subshells via `.cursor/scripts/tests/run.sh`, so env changes don't leak.

**Test file structure:**

```bash
#!/usr/bin/env bash
set -euo pipefail

# Setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/my-script.sh"

# Create temp directory
tmpdir="$ROOT_DIR/.test-artifacts/my-script-$$"
mkdir -p "$tmpdir"
trap "rm -rf '$tmpdir'" EXIT

# Test 1: Basic usage
output=$(bash "$SCRIPT" --flag value 2>&1)
[ "$?" -eq 0 ] || { echo "FAIL: exit code"; exit 1; }
[[ "$output" =~ "expected" ]] || { echo "FAIL: output"; exit 1; }

# Test 2: Error handling
output=$(bash "$SCRIPT" --invalid 2>&1)
[ "$?" -eq 2 ] || { echo "FAIL: should exit 2"; exit 1; }

echo "PASS: all tests"
```

**Key patterns:**

- Use `.test-artifacts/<name>-$$` for temp directories
- Add cleanup trap: `trap "rm -rf '$tmpdir'" EXIT`
- Export vars freely; runner's subshell isolates them
- Assert exit codes and output patterns

### 8. Validation

After migration, run validators:

```bash
# Validate help documentation
bash .cursor/scripts/help-validate.sh

# Validate error handling
bash .cursor/scripts/error-validate.sh

# Check network usage (informational)
bash .cursor/scripts/network-guard.sh

# Optional: run ShellCheck
bash .cursor/scripts/shellcheck-run.sh
```

**All scripts must pass:**

- `help-validate.sh` — No missing help sections
- `error-validate.sh` — Strict mode + exit codes

## Common Patterns

### Argument Parsing with Required Args

```bash
FLAG=""
REQUIRED=""

while [ $# -gt 0 ]; do
  case "$1" in
    --flag) FLAG="${2:-}"; shift 2;;
    --required) REQUIRED="${2:-}"; shift 2;;
    --version) printf '%s\n' "$VERSION"; exit 0;;
    -h|--help) usage; exit 0;;
    *) die "$EXIT_USAGE" "Unknown argument: $1";;
  esac
done

[ -n "$REQUIRED" ] || die "$EXIT_USAGE" "--required is required"
```

### Derived Defaults from Git

```bash
derive_owner_repo() {
  if git rev-parse --git-dir >/dev/null 2>&1; then
    local url
    url=$(git remote get-url origin 2>/dev/null || true)
    [ -n "$url" ] || die "$EXIT_CONFIG" "Unable to derive owner/repo from git origin"
    OWNER=$(printf '%s' "$url" | sed -E 's#.*github.com[:/]+([^/]+)/(.*)#\1#' | sed 's/.git$//')
    REPO=$(printf '%s' "$url" | sed -E 's#.*github.com[:/]+([^/]+)/([^./]+)(\.git)?#\2#')
  else
    die "$EXIT_CONFIG" "Not a git repo; pass --owner and --repo"
  fi
}
```

### JSON Output Without jq

```bash
# Use built-in json_escape from .lib.sh
title_json=$(json_escape "$TITLE")
body_json=$(json_escape "$BODY")

printf '{"title":"%s","body":"%s"}\n' "$title_json" "$body_json"
```

### Logging with Timestamps

```bash
# Use built-in log functions from .lib.sh
log_info "Starting process..."
log_warn "Deprecated flag used"
log_error "Failed to connect"

# Or use die for fatal errors
die "$EXIT_NETWORK" "API call failed"
```

## CI Integration

The `shell-validators.yml` workflow runs on every PR touching `.cursor/scripts/*.sh`:

- ✅ `help-validate.sh` — Blocks PR if help sections missing
- ✅ `error-validate.sh` — Blocks PR if strict mode violated
- ℹ️ `network-guard.sh` — Informational only
- ℹ️ `shellcheck-run.sh` — Optional linting

## Reference

- **Helper library**: [`../../scripts/.lib.sh`](../../scripts/.lib.sh)
- **Network seam**: [`../../scripts/.lib-net.sh`](../../scripts/.lib-net.sh)
- **Test runner**: [`../../scripts/tests/run.sh`](../../scripts/tests/run.sh)

## Examples

See these scripts for complete migration examples:

- **Full-featured**: `.cursor/scripts/pr-create.sh`, `.cursor/scripts/pr-update.sh`
- **Simple validator**: `.cursor/scripts/help-validate.sh`, `.cursor/scripts/error-validate.sh`
- **Graceful degradation**: `.cursor/scripts/shellcheck-run.sh`

## Troubleshooting

### "Missing Options section"

Add Options section using `print_options` and `print_option` functions.

### "Strict mode not enabled"

Ensure you have:

```bash
set -euo pipefail
IFS=$'\n\t'
source "$(dirname "$0")/.lib.sh"
```

### "Tests failing after migration"

- Check that exit codes match expected values
- Ensure temp directories use `.test-artifacts/` prefix
- Verify cleanup traps are present

### "Script fails in CI but passes locally"

- Ensure optional deps (jq, column) degrade gracefully
- Check for hardcoded paths (use relative or derived paths)
- Verify network seams are used in tests

---

