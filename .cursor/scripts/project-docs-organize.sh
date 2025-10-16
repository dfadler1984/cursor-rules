#!/usr/bin/env bash
# project-docs-organize.sh — Organize project documents into subdirectories
#
# Reorganizes accumulated project documents into a clear structure:
# - Creates analysis/, test-execution/, archived-summaries/ subdirectories
# - Moves files using git mv (preserves history)
# - Updates README.md navigation
# - Supports dry-run mode for preview
#
# Usage:
#   project-docs-organize.sh --project <slug> [--dry-run] [--pattern <type>]
#
# Patterns:
#   investigation: analysis/ + test-execution/ + archived-summaries/
#   minimal: Just archived-summaries/
#
# Examples:
#   project-docs-organize.sh --project rules-enforcement-investigation --dry-run
#   project-docs-organize.sh --project rules-enforcement-investigation --pattern minimal

set -euo pipefail

# Source common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Helper functions (self-contained)
info() { echo "ℹ️  $*"; }
success() { echo "✅ $*"; }
warning() { echo "⚠️  $*"; }
error() { echo "❌ $*" >&2; }

# Configuration
PROJECTS_DIR="docs/projects"
DEFAULT_PATTERN="investigation"

# Patterns define subdirectory structure and file categorization
declare -A PATTERNS
PATTERNS[investigation]="analysis test-execution archived-summaries"
PATTERNS[minimal]="archived-summaries"

# File categorization (glob patterns)
declare -A FILE_CATEGORIES
FILE_CATEGORIES[analysis]="discovery.md scalability-analysis.md conditional-rules-analysis.md premature-completion-analysis.md test-plans-review.md comparative-*.md"
FILE_CATEGORIES[test-execution]="h[0-9]*-*.md slash-commands-*.md experiment-*.md baseline-*.md"
FILE_CATEGORIES[archived-summaries]="*SESSION-SUMMARY*.md *UPDATE*.md *FINDINGS*.md BASELINE-REPORT*.md EXTENDED-*.md FINAL-*.md PROGRESS-*.md"

# Files to keep in root (never move)
KEEP_IN_ROOT="README.md erd.md tasks.md findings.md MONITORING-PROTOCOL.md"

usage() {
  cat <<EOF
Usage: $(basename "$0") --project <slug> [options]

Organize project documents into subdirectories with clear separation.

Required:
  --project <slug>        Project directory name under docs/projects/

Options:
  --pattern <type>        Organization pattern (default: investigation)
                          - investigation: full structure (analysis + test-execution + archive)
                          - minimal: just archived-summaries/
  --dry-run              Preview changes without executing
  --help                 Show this help message

Patterns:
  investigation:
    - analysis/           Deep analysis documents
    - test-execution/     Test artifacts and results
    - archived-summaries/ Historical session summaries

  minimal:
    - archived-summaries/ Just archive duplicate summaries

Examples:
  # Preview full reorganization
  $(basename "$0") --project rules-enforcement-investigation --dry-run

  # Execute minimal cleanup
  $(basename "$0") --project my-project --pattern minimal

  # Execute full reorganization
  $(basename "$0") --project rules-enforcement-investigation

Notes:
  - Uses 'git mv' to preserve file history
  - Skips files already in subdirectories
  - Keeps README.md, erd.md, tasks.md, findings.md in root
  - Creates backup list before moving files
EOF
}

# Parse arguments
PROJECT=""
PATTERN="$DEFAULT_PATTERN"
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --project)
      PROJECT="$2"
      shift 2
      ;;
    --pattern)
      PATTERN="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      error "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

# Validation
if [[ -z "$PROJECT" ]]; then
  error "Missing required --project argument"
  usage
  exit 1
fi

if [[ ! "${PATTERNS[$PATTERN]+x}" ]]; then
  error "Unknown pattern: $PATTERN"
  echo "Available patterns: ${!PATTERNS[*]}"
  exit 1
fi

PROJECT_DIR="$PROJECTS_DIR/$PROJECT"

if [[ ! -d "$PROJECT_DIR" ]]; then
  error "Project directory not found: $PROJECT_DIR"
  exit 1
fi

# Check git status
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
  warning "Working directory has uncommitted changes"
  echo "Consider committing or stashing changes before reorganizing."
  if [[ "$DRY_RUN" == "false" ]]; then
    read -rp "Continue anyway? (y/N) " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
      exit 1
    fi
  fi
fi

# Get subdirectories for this pattern
IFS=' ' read -ra SUBDIRS <<< "${PATTERNS[$PATTERN]}"

info "Organization pattern: $PATTERN"
info "Project: $PROJECT_DIR"
info "Subdirectories: ${SUBDIRS[*]}"
if [[ "$DRY_RUN" == "true" ]]; then
  info "DRY RUN MODE (no changes will be made)"
fi
echo

# Create subdirectories (dry-run just shows)
for subdir in "${SUBDIRS[@]}"; do
  target_dir="$PROJECT_DIR/$subdir"
  if [[ ! -d "$target_dir" ]]; then
    if [[ "$DRY_RUN" == "true" ]]; then
      echo "[DRY RUN] Would create: $subdir/"
    else
      mkdir -p "$target_dir"
      success "Created: $subdir/"
    fi
  else
    echo "Already exists: $subdir/"
  fi
done
echo

# Categorize and move files
declare -A moves
total_moves=0

for category in "${SUBDIRS[@]}"; do
  if [[ ! "${FILE_CATEGORIES[$category]+x}" ]]; then
    continue
  fi
  
  # Split glob patterns
  IFS=' ' read -ra patterns <<< "${FILE_CATEGORIES[$category]}"
  
  for pattern in "${patterns[@]}"; do
    # Use shell globbing (more reliable than find with patterns)
    shopt -s nullglob
    for file in "$PROJECT_DIR"/$pattern; do
      # Skip if file doesn't exist (pattern didn't match)
      if [[ ! -f "$file" ]]; then
        continue
      fi
      
      basename_file=$(basename "$file")
      
      # Skip if in KEEP_IN_ROOT list
      if [[ " $KEEP_IN_ROOT " =~ " $basename_file " ]]; then
        continue
      fi
      
      # Skip if already in a subdirectory (has more than one /)
      rel_path="${file#$PROJECT_DIR/}"
      if [[ "$rel_path" == *"/"* ]]; then
        continue
      fi
      
      # Record move
      target="$PROJECT_DIR/$category/$basename_file"
      moves["$file"]="$target"
      ((total_moves++)) || true
    done
    shopt -u nullglob
  done
done

# Show planned moves
if [[ $total_moves -eq 0 ]]; then
  info "No files to reorganize (already organized or no matches)"
  exit 0
fi

echo "Planned moves ($total_moves files):"
echo
for src in "${!moves[@]}"; do
  dest="${moves[$src]}"
  rel_src="${src#$PROJECT_DIR/}"
  rel_dest="${dest#$PROJECT_DIR/}"
  echo "  $rel_src → $rel_dest"
done
echo

if [[ "$DRY_RUN" == "true" ]]; then
  info "DRY RUN complete. Run without --dry-run to execute."
  exit 0
fi

# Confirm execution
read -rp "Proceed with reorganization? (y/N) " response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
  info "Cancelled."
  exit 0
fi

# Execute moves
moved_count=0
failed_count=0

for src in "${!moves[@]}"; do
  dest="${moves[$src]}"
  
  if git mv "$src" "$dest" 2>/dev/null; then
    ((moved_count++)) || true
  else
    ((failed_count++)) || true
    error "Failed to move: $src"
  fi
done

echo
if [[ $failed_count -eq 0 ]]; then
  success "Reorganization complete: $moved_count files moved"
else
  warning "Reorganization completed with errors: $moved_count moved, $failed_count failed"
fi

# Suggest next steps
echo
info "Next steps:"
echo "  1. Review changes: git status"
echo "  2. Update README.md navigation to point to new structure"
echo "  3. Update any broken links in other documents"
echo "  4. Commit: git commit -m 'docs($PROJECT): organize documents into subdirectories'"

