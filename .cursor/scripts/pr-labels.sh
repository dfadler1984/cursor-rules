#!/usr/bin/env bash
# PR Label Management
#
# Manages GitHub PR labels via API (no gh CLI dependency)

set -euo pipefail

# Source shared library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=.lib.sh
source "$SCRIPT_DIR/.lib.sh"

# Help documentation
show_help() {
  cat << 'EOF'
Usage: pr-labels.sh --pr <number> --add <label>
       pr-labels.sh --pr <number> --remove <label>
       pr-labels.sh --pr <number> --list
       pr-labels.sh --pr <number> --has <label>

Manage GitHub PR labels via API (no gh CLI dependency).

OPTIONS:
  --pr NUMBER              PR number (required)
  --add LABEL             Add label to PR
  --remove LABEL          Remove label from PR
  --list                  List all labels on PR
  --has LABEL             Check if label exists (exit 0 if yes, 1 if no)
  -h, --help              Show this help

EXAMPLES:
  # Add skip-changeset label
  pr-labels.sh --pr 147 --add skip-changeset

  # Remove skip-changeset label
  pr-labels.sh --pr 147 --remove skip-changeset

  # List all labels
  pr-labels.sh --pr 147 --list

  # Check if label exists
  pr-labels.sh --pr 147 --has skip-changeset

AUTHENTICATION:
  Requires GITHUB_TOKEN or GH_TOKEN environment variable.
  Fine-grained token permissions: Repository Metadata (read), Pull requests (write)

Exit Codes:
  0   Success
  1   General error or label not found (--has)
  2   Usage error (invalid arguments)
  3   Configuration error
  4   Dependency missing
  5   Network error
  6   Timeout
  20  Internal error

EOF
}


# Parse arguments
PR_NUMBER=""
ACTION=""
LABEL=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      show_help
      exit 0
      ;;
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
      echo "ERROR: Unknown option: $1" >&2
      echo "Usage: $0 --pr <number> [--add|--remove|--list|--has <label>]" >&2
      echo "Run '$0 --help' for more information." >&2
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
    log_info "Adding label '$LABEL' to PR #$PR_NUMBER"
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
    log_info "Removing label '$LABEL' from PR #$PR_NUMBER"
    RESPONSE=$(curl -s -w "\n%{http_code}" \
      -X DELETE \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      "$API_BASE/issues/$PR_NUMBER/labels/$LABEL")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [[ "$HTTP_CODE" == "200" || "$HTTP_CODE" == "204" ]]; then
      log_info "Label '$LABEL' removed from PR #$PR_NUMBER"
      exit 0
    elif [[ "$HTTP_CODE" == "404" ]]; then
      log_info "Label '$LABEL' not found on PR #$PR_NUMBER (already removed or never existed)"
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
      # Parse JSON and extract label names (handle empty array and spacing variations)
      echo "$BODY" | grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/' || true
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

