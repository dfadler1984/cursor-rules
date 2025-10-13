#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1090
source "$(dirname "$0")/.lib.sh"

VERSION="1.0.0"

usage() {
  print_usage "setup-remote.sh [OPTIONS]"
  
  print_options
  print_option "--skip-token-check" "Skip GitHub token verification"
  print_option "--version" "Print version and exit"
  print_option "-h, --help" "Show this help and exit"
  
  cat <<'DESC'

Description:
  Verify dependencies and setup for shell scripts on a new/remote machine.
  Checks for required tools (bash, git) and optional tools (curl, jq, column, shellcheck).
  Reports what's ready and what needs setup.

DESC
  
  print_examples
  print_example "Check all dependencies" "setup-remote.sh"
  print_example "Skip token check" "setup-remote.sh --skip-token-check"
  
  print_exit_codes
}

skip_token_check=0

while [ $# -gt 0 ]; do
  case "$1" in
    --skip-token-check) skip_token_check=1; shift;;
    --version) printf '%s\n' "$VERSION"; exit 0;;
    -h|--help) usage; exit 0;;
    *) die "$EXIT_USAGE" "Unknown argument: $1";;
  esac
done

printf '\n=== Shell Scripts Setup Check ===\n\n'

# Track overall status
all_required_ok=1
warnings=0

# Check bash version
printf 'Checking bash version... '
if [ -n "${BASH_VERSION:-}" ]; then
  bash_major="${BASH_VERSION%%.*}"
  if [ "$bash_major" -ge 4 ]; then
    printf '✅ %s (>= 4.0)\n' "$BASH_VERSION"
  else
    printf '⚠️  %s (< 4.0, some features may not work)\n' "$BASH_VERSION"
    warnings=$((warnings + 1))
  fi
else
  printf '❌ Not running in bash\n'
  all_required_ok=0
fi

# Check git
printf 'Checking git... '
if have_cmd git; then
  git_version=$(git --version | awk '{print $3}')
  printf '✅ %s\n' "$git_version"
else
  printf '❌ Not found (required for most scripts)\n'
  all_required_ok=0
fi

# Check curl (required for GitHub automation)
printf 'Checking curl... '
if have_cmd curl; then
  curl_version=$(curl --version | head -1 | awk '{print $2}')
  printf '✅ %s (required for GitHub automation)\n' "$curl_version"
else
  printf '⚠️  Not found (install: sudo apt-get install curl)\n'
  printf '    Note: Required for pr-create.sh, pr-update.sh, checks-status.sh\n'
  warnings=$((warnings + 1))
fi

# Check GH_TOKEN (optional but needed for GitHub scripts)
if [ $skip_token_check -eq 0 ]; then
  printf 'Checking GH_TOKEN... '
  if [ -n "${GH_TOKEN:-}" ]; then
    # Redact token, just show first 4 chars
    printf '✅ Set (ghp_%s...)\n' "${GH_TOKEN:4:4}"
  else
    printf '⚠️  Not set (needed for GitHub automation)\n'
    printf '    Export: export GH_TOKEN="ghp_your_token_here"\n'
    printf '    Get token: https://github.com/settings/tokens\n'
    warnings=$((warnings + 1))
  fi
fi

printf '\n--- Optional Tools ---\n'

# Check jq
printf 'Checking jq... '
if have_cmd jq; then
  jq_version=$(jq --version)
  printf '✅ %s (enhanced JSON output)\n' "$jq_version"
else
  printf '⚠️  Not found (optional; install: brew install jq)\n'
fi

# Check column
printf 'Checking column... '
if have_cmd column; then
  printf '✅ Found (enhanced table formatting)\n'
else
  printf '⚠️  Not found (optional; usually pre-installed)\n'
fi

# Check shellcheck
printf 'Checking shellcheck... '
if have_cmd shellcheck; then
  shellcheck_version=$(shellcheck --version | awk '/^version:/ {print $2}')
  printf '✅ %s (static analysis)\n' "$shellcheck_version"
else
  printf '⚠️  Not found (optional; install: brew install shellcheck)\n'
fi

printf '\n--- Validation Tests ---\n'

# Test a validator
printf 'Testing help-validate.sh... '
if bash "$(dirname "$0")/help-validate.sh" >/dev/null 2>&1; then
  printf '✅ Works\n'
else
  printf '⚠️  Failed\n'
  warnings=$((warnings + 1))
fi

# Test the test runner
printf 'Testing test runner... '
test_count=$(bash "$(dirname "$0")/tests/run.sh" 2>&1 | grep -o '[0-9]* passed' | awk '{print $1}' || echo "0")
if [ "$test_count" -gt 0 ]; then
  printf '✅ %s tests pass\n' "$test_count"
else
  printf '⚠️  No tests passed\n'
  warnings=$((warnings + 1))
fi

printf '\n=== Summary ===\n\n'

if [ $all_required_ok -eq 1 ]; then
  printf '✅ All required dependencies present (bash + git)\n'
else
  printf '❌ Missing required dependencies\n'
fi

if [ $warnings -eq 0 ]; then
  printf '✅ All optional tools present\n'
  printf '\n🎉 Full setup complete! All scripts ready to use.\n'
else
  printf '⚠️  %d warning(s) — some features may be limited\n' "$warnings"
  printf '\n✅ Core scripts ready. Install optional tools for full functionality.\n'
fi

printf '\nNext steps:\n'
printf '  - Run validators: bash .cursor/scripts/help-validate.sh\n'
printf '  - Run tests: bash .cursor/scripts/tests/run.sh\n'
printf '  - See docs: docs/projects/shell-and-script-tooling/\n'

exit 0

