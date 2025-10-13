#!/usr/bin/env bash
# Test helper library for network isolation
# Provides fixtures and guards for testing scripts that make network calls.
# 
# Usage: Source this in TEST files only (not production scripts).
# Production scripts make real API calls; tests use net_fixture() for deterministic data.

# Source the main library for helpers
# shellcheck disable=SC1090
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.lib.sh"

# Fixtures directory
readonly FIXTURES_DIR="$SCRIPT_DIR/tests/fixtures"

# Guard pattern: Set CURL_BIN=false in test environments to catch scripts
# that bypass test seams. Tests should use CURL_CMD=cat to inject fixtures.

# Network request stub for test mocking - NEVER performs actual HTTP
# Usage in tests: Call this to simulate network errors or fixture responses
# Production scripts: DO NOT call this; use real curl with CURL_CMD seam
net_request() {
  local method="${1:-GET}"
  local url="${2:-}"
  shift 2 || true
  
  if [ -z "$url" ]; then
    die "$EXIT_USAGE" "net_request requires method and URL"
  fi
  
  log_error "Test-only function: net_request called in non-test context"
  log_error "Attempted: $method $url"
  die "$EXIT_NETWORK" "Use real curl in production; net_request is for test mocking only"
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

