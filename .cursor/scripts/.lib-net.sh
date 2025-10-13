#!/usr/bin/env bash
# Network effects seam for repository scripts
# This library ensures NO network requests are ever performed.
# All network-requiring behaviors must use fixtures or guidance.

# Source the main library for helpers
# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

# Fixtures directory
readonly FIXTURES_DIR="$SCRIPT_DIR/tests/fixtures"

# Guard pattern: Set CURL_BIN=false or HTTP_BIN=false in test environments
# to catch scripts that try to invoke network tools directly.
# This library never performs network requests; net_request() always fails.

# Network request stub - NEVER performs actual HTTP
# Usage: net_request <method> <url> [curl_args...]
# Returns: prints fixture data or guidance; never makes real requests
net_request() {
  local method="${1:-GET}"
  local url="${2:-}"
  shift 2 || true
  
  if [ -z "$url" ]; then
    die "$EXIT_USAGE" "net_request requires method and URL"
  fi
  
  log_error "Network requests are not supported"
  log_error "Attempted: $method $url"
  die "$EXIT_NETWORK" "This script requires offline fixtures or --dry-run mode"
}

# Load fixture data for testing
# Usage: net_fixture <fixture-name>
# Returns: prints fixture content or exits with helpful error
net_fixture() {
  local fixture_name="$1"
  local fixture_path="$FIXTURES_DIR/$fixture_name"
  
  if [ ! -f "$fixture_path" ]; then
    die "$EXIT_CONFIG" "Fixture not found: $fixture_path"
  fi
  
  cat "$fixture_path"
}

# Print guidance URL without fetching
# Usage: net_guidance <description> <url>
# Returns: prints actionable guidance for user
net_guidance() {
  local description="$1"
  local url="$2"
  
  log_info "Action required: $description"
  log_info "Visit: $url"
  log_info "(This script does not perform network requests)"
}

# Check if running in dry-run mode
# Usage: if is_dry_run; then ...; fi
is_dry_run() {
  [ "${DRY_RUN:-0}" = "1" ]
}

