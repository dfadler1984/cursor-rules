#!/usr/bin/env bash
# Generate and update repository health badge in README
# Uses shields.io dynamic badge based on deep validation score

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=.lib.sh
source "$SCRIPT_DIR/.lib.sh"

VERSION="0.1.0"

show_help() {
  print_help_header "repo-health-badge.sh" "$VERSION" \
    "Generate and update repository health badge in README"
  
  print_usage "repo-health-badge.sh [OPTIONS]"
  
  cat <<'HELP'
Description:
  Runs deep validation, extracts health score, generates shields.io badge URL,
  and updates README.md with the badge. Badge color is determined by score:
    - 90-100: brightgreen
    - 70-89: yellow
    - <70: red

HELP

  print_options
  print_option "--dry-run" "Show what would be updated without modifying files"
  print_option "--workflow-url URL" "GitHub Actions workflow run URL for clickable badge"
  print_option "--help" "Show this help message"
  
  print_exit_codes
  
  print_examples
  print_example "Update badge in README" \
    "repo-health-badge.sh"
  print_example "Dry run to preview changes" \
    "repo-health-badge.sh --dry-run"
  print_example "With workflow link" \
    "repo-health-badge.sh --workflow-url 'https://github.com/owner/repo/actions/runs/123'"
}

# Parse arguments
DRY_RUN=false
WORKFLOW_URL=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --workflow-url)
      WORKFLOW_URL="$2"
      shift 2
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      die 2 "Unknown option: $1"
      ;;
  esac
done

# Find repo root
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
README_PATH="$REPO_ROOT/README.md"

# Validate README exists
if [ ! -f "$README_PATH" ]; then
  die 1 "README.md not found at: $README_PATH"
fi

# Run deep validation and capture score
log_info "Running health validation..."
VALIDATION_OUTPUT=$("$SCRIPT_DIR/deep-rule-and-command-validate.sh" --score-only 2>&1 || true)

# Extract score from output (handle various formats)
SCORE=$(echo "$VALIDATION_OUTPUT" | grep -oE '[0-9]+' | head -n1 || echo "0")

if [ -z "$SCORE" ]; then
  die 1 "Failed to extract health score from validation output"
fi

log_info "Health score: $SCORE/100"

# Determine badge color based on score
if [ "$SCORE" -ge 90 ]; then
  COLOR="brightgreen"
elif [ "$SCORE" -ge 70 ]; then
  COLOR="yellow"
else
  COLOR="red"
fi

log_info "Badge color: $COLOR"

# Generate shields.io badge URL
BADGE_URL="https://img.shields.io/badge/health-${SCORE}-${COLOR}"

# Generate badge markdown
if [ -n "$WORKFLOW_URL" ]; then
  BADGE_MARKDOWN="[![Repository Health](${BADGE_URL})](${WORKFLOW_URL})"
else
  BADGE_MARKDOWN="![Repository Health](${BADGE_URL})"
fi

log_info "Badge markdown: $BADGE_MARKDOWN"

# Find the badge line in README (line 3 based on current structure)
# Look for line starting with ![Repository Health] or [![Repository Health]
BADGE_LINE=$(grep -n "!\[\(Repository Health\|Health Score\)" "$README_PATH" | head -n1 | cut -d: -f1 || echo "")

if [ -z "$BADGE_LINE" ]; then
  die 1 "Could not find badge line in README.md (expected line starting with '![Repository Health]')"
fi

log_info "Found badge at line $BADGE_LINE"

if [ "$DRY_RUN" = true ]; then
  log_info "DRY RUN: Would update line $BADGE_LINE in README.md with:"
  echo "  $BADGE_MARKDOWN"
  exit 0
fi

# Update README with new badge
# Create temp file with updated content
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

awk -v line="$BADGE_LINE" -v badge="$BADGE_MARKDOWN" '
  NR == line { print badge; next }
  { print }
' "$README_PATH" > "$TEMP_FILE"

# Replace original file
mv "$TEMP_FILE" "$README_PATH"

log_info "Updated badge in README.md (line $BADGE_LINE)"
log_info "Score: $SCORE/100 ($COLOR)"

exit 0

