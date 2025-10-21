#!/usr/bin/env bash
# PR Label Management
#
# Manages GitHub PR labels via API (no gh CLI dependency)
#
# Usage:
#   pr-labels.sh --pr <number> --add <label>
#   pr-labels.sh --pr <number> --remove <label>
#   pr-labels.sh --pr <number> --list
#   pr-labels.sh --pr <number> --has <label>
#
# Examples:
#   pr-labels.sh --pr 147 --add skip-changeset
#   pr-labels.sh --pr 147 --remove skip-changeset
#   pr-labels.sh --pr 147 --list
#   pr-labels.sh --pr 147 --has skip-changeset

set -euo pipefail

# Source shared library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=.lib.sh
source "$SCRIPT_DIR/.lib.sh"

# Parse arguments
PR_NUMBER=""
ACTION=""
LABEL=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --pr)
      PR_NUMBER="$2"
      shift 2
      ;;
    --add)
      ACTION="add"
      LABEL="$2"
      shift 2
      ;;
    --remove)
      ACTION="remove"
      LABEL="$2"
      shift 2
      ;;
    --list)
      ACTION="list"
      shift
      ;;
    --has)
      ACTION="has"
      LABEL="$2"
      shift 2
      ;;
    *)
      error "Unknown option: $1"
      echo "Usage: $0 --pr <number> [--add|--remove|--list|--has <label>]" >&2
      exit 1
      ;;
  esac
done

# Validate inputs
if [[ -z "$PR_NUMBER" ]]; then
  echo "ERROR: --pr <number> required" >&2
  exit 1
fi

if [[ -z "$ACTION" ]]; then
  echo "ERROR: Action required: --add, --remove, --list, or --has" >&2
  exit 1
fi

if [[ "$ACTION" != "list" && -z "$LABEL" ]]; then
  echo "ERROR: Label name required for --$ACTION" >&2
  exit 1
fi

# Get GitHub token
GITHUB_TOKEN="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "ERROR: GITHUB_TOKEN or GH_TOKEN environment variable required" >&2
  exit 1
fi

# Get repo info from git remote
REMOTE_URL=$(git config --get remote.origin.url)
if [[ "$REMOTE_URL" =~ github\.com[:/]([^/]+)/([^/.]+)(\.git)?$ ]]; then
  OWNER="${BASH_REMATCH[1]}"
  REPO="${BASH_REMATCH[2]}"
else
  echo "ERROR: Could not parse GitHub owner/repo from remote URL: $REMOTE_URL" >&2
  exit 1
fi

API_BASE="https://api.github.com/repos/$OWNER/$REPO"

# Execute action
case "$ACTION" in
  add)
    info "Adding label '$LABEL' to PR #$PR_NUMBER"
    RESPONSE=$(curl -s -w "\n%{http_code}" \
      -X POST \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      "$API_BASE/issues/$PR_NUMBER/labels" \
      -d "{\"labels\":[\"$LABEL\"]}")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [[ "$HTTP_CODE" == "200" ]]; then
      success "Label '$LABEL' added to PR #$PR_NUMBER"
      exit 0
    else
      error "Failed to add label (HTTP $HTTP_CODE)"
      echo "$BODY" >&2
      exit 1
    fi
    ;;
    
  remove)
    info "Removing label '$LABEL' from PR #$PR_NUMBER"
    RESPONSE=$(curl -s -w "\n%{http_code}" \
      -X DELETE \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      "$API_BASE/issues/$PR_NUMBER/labels/$LABEL")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [[ "$HTTP_CODE" == "200" || "$HTTP_CODE" == "204" ]]; then
      success "Label '$LABEL' removed from PR #$PR_NUMBER"
      exit 0
    elif [[ "$HTTP_CODE" == "404" ]]; then
      info "Label '$LABEL' not found on PR #$PR_NUMBER (already removed or never existed)"
      exit 0
    else
      error "Failed to remove label (HTTP $HTTP_CODE)"
      echo "$BODY" >&2
      exit 1
    fi
    ;;
    
  list)
    RESPONSE=$(curl -s -w "\n%{http_code}" \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      "$API_BASE/issues/$PR_NUMBER/labels")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [[ "$HTTP_CODE" == "200" ]]; then
      # Parse JSON and extract label names
      echo "$BODY" | grep -o '"name":"[^"]*"' | cut -d'"' -f4
      exit 0
    else
      error "Failed to list labels (HTTP $HTTP_CODE)"
      echo "$BODY" >&2
      exit 1
    fi
    ;;
    
  has)
    RESPONSE=$(curl -s -w "\n%{http_code}" \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      "$API_BASE/issues/$PR_NUMBER/labels")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [[ "$HTTP_CODE" == "200" ]]; then
      if echo "$BODY" | grep -q "\"name\":\"$LABEL\""; then
        echo "true"
        exit 0
      else
        echo "false"
        exit 1
      fi
    else
      error "Failed to check labels (HTTP $HTTP_CODE)"
      echo "$BODY" >&2
      exit 1
    fi
    ;;
esac

