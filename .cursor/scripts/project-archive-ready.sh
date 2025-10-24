#!/usr/bin/env bash
# project-archive-ready.sh — Comprehensive pre-archival validation and automated archival
#
# Purpose: Validate project readiness, fix common issues, detect active artifacts, and archive when ready
# Usage:
#   project-archive-ready.sh --project <slug> --year <YYYY> [--dry-run] [--auto-fix]
#
# Workflow:
#   1. Validate project exists and is complete
#   2. Check for required artifacts (final-summary.md, Carryovers section, retrospective)
#   3. Check for active artifacts that should be extracted (standards, test specs, policies)
#   4. Auto-fix common issues (with --auto-fix or interactive prompts)
#   5. Run project-lifecycle-validate-scoped.sh
#   6. If validation passes, run project-archive-workflow.sh
#   7. Fix broken links in archived project
#   8. Final validation

set -euo pipefail

# Script metadata
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Defaults
PROJECT=""
YEAR=""
DRY_RUN=false
AUTO_FIX=false
INTERACTIVE=true

# Usage
usage() {
  cat <<EOF
Usage: $SCRIPT_NAME --project <slug> --year <YYYY> [OPTIONS]

Validate project readiness for archival, fix common issues, detect active artifacts, and archive.

REQUIRED:
  --project <slug>      Project slug (e.g., routing-optimization)
  --year <YYYY>         Archive year (e.g., 2025)

OPTIONS:
  --dry-run             Show what would be done without executing
  --auto-fix            Automatically fix common issues without prompting
  --no-interactive      Non-interactive mode (fail if manual fixes needed)
  -h, --help            Show this help message

WORKFLOW:
  1. Validate project exists in docs/projects/<slug>
  2. Check for required artifacts:
     - final-summary.md with proper front matter
     - Carryovers section in tasks.md
     - Retrospective (in final-summary.md or dedicated file)
  3. Check for active artifacts (standards, test specs, policies)
  4. If active artifacts found:
     - Warn user about files that should be extracted
     - Suggest extraction locations
     - Require explicit confirmation to proceed
  5. Run project-lifecycle-validate-scoped.sh
  6. If validation passes:
     - Run project-archive-workflow.sh
     - Fix broken relative links
     - Validate archived project
  7. Report final status

AUTO-FIX CAPABILITIES:
  - Add Carryovers section to tasks.md if missing
  - Generate final-summary.md from template if missing
  - Add required front matter fields
  - Fix relative links after archival

ACTIVE ARTIFACT DETECTION:
  - Checks for standards/policies referenced by scripts or rules
  - Checks for test specifications used by active features
  - Checks for migration guides referenced in documentation
  - Warns if project contains artifacts needed by active code

EXIT CODES:
  0    Project successfully archived
  1    Validation failed or archival incomplete
  2    Usage error or missing dependencies

EXAMPLES:
  # Dry run to see what would happen
  $SCRIPT_NAME --project routing-optimization --year 2025 --dry-run

  # Interactive mode (prompts for fixes)
  $SCRIPT_NAME --project routing-optimization --year 2025

  # Auto-fix common issues without prompting
  $SCRIPT_NAME --project routing-optimization --year 2025 --auto-fix

  # Non-interactive CI mode
  $SCRIPT_NAME --project my-project --year 2025 --no-interactive
EOF
}

# Error handling
error() {
  echo -e "${RED}ERROR:${NC} $*" >&2
  exit 2
}

warn() {
  echo -e "${YELLOW}WARNING:${NC} $*" >&2
}

info() {
  echo -e "${BLUE}INFO:${NC} $*"
}

success() {
  echo -e "${GREEN}✓${NC} $*"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --project)
      PROJECT="$2"
      shift 2
      ;;
    --year)
      YEAR="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --auto-fix)
      AUTO_FIX=true
      shift
      ;;
    --no-interactive)
      INTERACTIVE=false
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      error "Unknown option: $1"
      ;;
  esac
done

# Validate required arguments
if [[ -z "$PROJECT" ]]; then
  error "Missing required argument: --project <slug>"
fi

if [[ -z "$YEAR" ]]; then
  error "Missing required argument: --year <YYYY>"
fi

# Validate year format
if [[ ! "$YEAR" =~ ^[0-9]{4}$ ]]; then
  error "Invalid year format: $YEAR (must be YYYY)"
fi

# Project paths
PROJECT_DIR="${REPO_ROOT}/docs/projects/${PROJECT}"
ARCHIVED_DIR="${REPO_ROOT}/docs/projects/_archived/${YEAR}/${PROJECT}"

# Check project exists
if [[ ! -d "$PROJECT_DIR" ]]; then
  error "Project directory not found: $PROJECT_DIR"
fi

info "Validating project: $PROJECT (year: $YEAR)"
echo ""

# Validation counters
declare -i ISSUES_FOUND=0
declare -i ISSUES_FIXED=0
declare -a MANUAL_FIXES_NEEDED=()
declare -a ACTIVE_ARTIFACTS=()

# Check 1: final-summary.md exists
check_final_summary() {
  local final_summary="${PROJECT_DIR}/final-summary.md"
  
  if [[ ! -f "$final_summary" ]]; then
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
    warn "Missing: final-summary.md"
    
    if [[ "$AUTO_FIX" == "true" ]] || [[ "$DRY_RUN" == "true" ]]; then
      info "Would generate final-summary.md from template"
      if [[ "$DRY_RUN" == "false" ]]; then
        # Generate final-summary.md
        "${SCRIPT_DIR}/final-summary-generate.sh" --project "$PROJECT" --year "$YEAR" --root "$REPO_ROOT" --date "$(date +%Y-%m-%d)" || {
          MANUAL_FIXES_NEEDED+=("Generate final-summary.md manually")
          return 1
        }
        ISSUES_FIXED=$((ISSUES_FIXED + 1))
        success "Generated final-summary.md"
      fi
    elif [[ "$INTERACTIVE" == "true" ]]; then
      read -p "Generate final-summary.md? (y/n): " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        "${SCRIPT_DIR}/final-summary-generate.sh" --project "$PROJECT" --year "$YEAR" --root "$REPO_ROOT" --date "$(date +%Y-%m-%d)" || {
          MANUAL_FIXES_NEEDED+=("Generate final-summary.md manually")
          return 1
        }
        ISSUES_FIXED=$((ISSUES_FIXED + 1))
        success "Generated final-summary.md"
      else
        MANUAL_FIXES_NEEDED+=("Create final-summary.md with proper front matter and retrospective")
      fi
    else
      MANUAL_FIXES_NEEDED+=("Create final-summary.md")
      return 1
    fi
  else
    success "final-summary.md exists"
  fi
}

# Check 2: Carryovers section in tasks.md
check_carryovers() {
  local tasks_file="${PROJECT_DIR}/tasks.md"
  
  if [[ ! -f "$tasks_file" ]]; then
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
    warn "Missing: tasks.md"
    MANUAL_FIXES_NEEDED+=("Create tasks.md")
    return 1
  fi
  
  if ! grep -q "^## Carryovers" "$tasks_file"; then
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
    warn "Missing: Carryovers section in tasks.md"
    
    if [[ "$AUTO_FIX" == "true" ]] || [[ "$DRY_RUN" == "true" ]]; then
      info "Would add Carryovers section to tasks.md"
      if [[ "$DRY_RUN" == "false" ]]; then
        # Add Carryovers section before last section or at end
        if grep -q "^## Related Files" "$tasks_file"; then
          # Insert before Related Files
          sed -i '' '/^## Related Files/i\
\
## Carryovers\
\
No deferred items (all tasks complete).\
' "$tasks_file"
        else
          # Append at end
          cat >> "$tasks_file" <<'EOF'

## Carryovers

No deferred items (all tasks complete).
EOF
        fi
        ISSUES_FIXED=$((ISSUES_FIXED + 1))
        success "Added Carryovers section to tasks.md"
      fi
    elif [[ "$INTERACTIVE" == "true" ]]; then
      read -p "Add Carryovers section to tasks.md? (y/n): " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        if grep -q "^## Related Files" "$tasks_file"; then
          sed -i '' '/^## Related Files/i\
\
## Carryovers\
\
No deferred items (all tasks complete).\
' "$tasks_file"
        else
          cat >> "$tasks_file" <<'EOF'

## Carryovers

No deferred items (all tasks complete).
EOF
        fi
        ISSUES_FIXED=$((ISSUES_FIXED + 1))
        success "Added Carryovers section to tasks.md"
      else
        MANUAL_FIXES_NEEDED+=("Add ## Carryovers section to tasks.md")
      fi
    else
      MANUAL_FIXES_NEEDED+=("Add ## Carryovers section to tasks.md")
      return 1
    fi
  else
    success "Carryovers section exists in tasks.md"
  fi
}

# Check 3: Detect active artifacts (NEW)
check_active_artifacts() {
  info "Checking for active artifacts (standards, test specs, policies)..."
  
  local found_artifacts=false
  
  # Search for references to this project from active scripts
  if grep -r "docs/projects/${PROJECT}/" "${REPO_ROOT}/.cursor/scripts" --include="*.sh" --exclude="*.test.sh" 2>/dev/null | grep -v "^Binary"; then
    found_artifacts=true
    warn "Found script references to project artifacts"
    ACTIVE_ARTIFACTS+=("Scripts reference docs/projects/${PROJECT}/ - check if artifacts should be extracted")
  fi
  
  # Search for references from active rules
  if grep -r "docs/projects/${PROJECT}/" "${REPO_ROOT}/.cursor/rules" --include="*.mdc" 2>/dev/null | grep -v "^Binary"; then
    found_artifacts=true
    warn "Found rule references to project artifacts"
    ACTIVE_ARTIFACTS+=("Rules reference docs/projects/${PROJECT}/ - check if artifacts should be extracted")
  fi
  
  # Check for files that look like active artifacts
  local -a potential_artifacts=()
  
  # Test specifications
  if find "$PROJECT_DIR" -name "*-test-suite.md" -o -name "*-test-spec.md" 2>/dev/null | grep -q .; then
    potential_artifacts+=("Test suite/spec files (should these go to .cursor/docs/tests/?)")
  fi
  
  # Standards/policies
  if find "$PROJECT_DIR" -name "*-standard.md" -o -name "*-policy.md" -o -name "*-guide.md" 2>/dev/null | grep -q .; then
    potential_artifacts+=("Standard/policy/guide files (should these go to .cursor/docs/standards/?)")
  fi
  
  # Migration guides
  if find "$PROJECT_DIR" -name "*MIGRATION*.md" -o -name "*migration*.md" 2>/dev/null | grep -q .; then
    potential_artifacts+=("Migration guides (should these go to .cursor/docs/standards/?)")
  fi
  
  # Decision documents (D1, D2, etc.)
  if grep -rl "^### D[0-9]" "$PROJECT_DIR" 2>/dev/null | grep -v ".test.sh"; then
    potential_artifacts+=("Decision documents (D1-D6 standards - should these be extracted?)")
  fi
  
  if [[ ${#potential_artifacts[@]} -gt 0 ]]; then
    found_artifacts=true
    warn "Found potential active artifacts:"
    for artifact in "${potential_artifacts[@]}"; do
      echo "  • $artifact"
    done
    ACTIVE_ARTIFACTS+=("${potential_artifacts[@]}")
  fi
  
  if [[ "$found_artifacts" == "true" ]]; then
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
    echo ""
    warn "Active artifacts detected that may need extraction before archival"
    echo ""
    info "Suggested extraction locations:"
    echo "  • Standards/policies/guides → .cursor/docs/standards/"
    echo "  • Test specifications → .cursor/docs/tests/"
    echo "  • Reusable templates → .cursor/templates/"
    echo ""
    
    if [[ "$DRY_RUN" == "false" ]] && [[ "$INTERACTIVE" == "true" ]]; then
      echo "Active artifacts should be extracted before archiving."
      echo "Projects in archive should contain only historical documentation."
      echo ""
      read -p "Have you extracted all active artifacts? Continue anyway? (y/n): " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        error "Archival cancelled - please extract active artifacts first"
      fi
    elif [[ "$DRY_RUN" == "false" ]]; then
      error "Active artifacts found - extract them before archiving (or use interactive mode)"
    fi
  else
    success "No active artifacts detected"
  fi
}

# Check 4: Run project-lifecycle-validate-scoped.sh
run_validation() {
  info "Running project-lifecycle-validate-scoped.sh..."
  
  if [[ "$DRY_RUN" == "true" ]]; then
    info "Would run: ${SCRIPT_DIR}/project-lifecycle-validate-scoped.sh $PROJECT"
    return 0
  fi
  
  if "${SCRIPT_DIR}/project-lifecycle-validate-scoped.sh" "$PROJECT" 2>&1; then
    success "Project validation passed"
    return 0
  else
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
    warn "Project validation failed"
    MANUAL_FIXES_NEEDED+=("Fix validation errors reported above")
    return 1
  fi
}

# Execute archival workflow
run_archival() {
  info "Running project-archive-workflow.sh..."
  
  if [[ "$DRY_RUN" == "true" ]]; then
    "${SCRIPT_DIR}/project-archive-workflow.sh" --project "$PROJECT" --year "$YEAR" --dry-run
    return 0
  fi
  
  if "${SCRIPT_DIR}/project-archive-workflow.sh" --project "$PROJECT" --year "$YEAR"; then
    success "Project archived to ${ARCHIVED_DIR}"
    return 0
  else
    error "Archival failed"
  fi
}

# Fix broken links in archived project
fix_archived_links() {
  if [[ "$DRY_RUN" == "true" ]]; then
    info "Would fix broken links in archived project"
    return 0
  fi
  
  if [[ ! -d "$ARCHIVED_DIR" ]]; then
    warn "Archived directory not found, skipping link fixes"
    return 0
  fi
  
  info "Fixing relative links in archived project..."
  
  # Fix links to active projects (add ../../.. to go up from _archived/YYYY/project to projects/)
  cd "$ARCHIVED_DIR" || return 1
  
  # Find all markdown files and fix common relative link patterns
  find . -name "*.md" -exec sed -i '' 's|(\.\./\([^/][^)]*\)/|\(\.\./../../../\1/|g' {} \; 2>/dev/null || true
  find . -name "*.md" -exec sed -i '' 's|(\.\./\([^)]*\.md\))|(\.\./../../../\1)|g' {} \; 2>/dev/null || true
  
  success "Fixed relative links"
  
  # Validate links
  info "Validating links..."
  if "${SCRIPT_DIR}/links-check.sh" --path "$ARCHIVED_DIR" 2>&1 | grep -q "All links OK"; then
    success "All links validated"
    return 0
  else
    warn "Some links may still be broken (check links-check.sh output)"
    info "Run: ${SCRIPT_DIR}/links-check.sh --path $ARCHIVED_DIR"
    return 1
  fi
}

# Main workflow
main() {
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Project Archive Readiness Check"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Project: $PROJECT"
  echo "Year: $YEAR"
  echo "Mode: $(if [[ "$DRY_RUN" == "true" ]]; then echo "DRY RUN"; else echo "LIVE"; fi)"
  echo ""
  
  # Step 1: Check final-summary.md
  echo "─────────────────────────────────────────────"
  echo "Step 1: Check final-summary.md"
  echo "─────────────────────────────────────────────"
  check_final_summary
  echo ""
  
  # Step 2: Check Carryovers section
  echo "─────────────────────────────────────────────"
  echo "Step 2: Check Carryovers section"
  echo "─────────────────────────────────────────────"
  check_carryovers
  echo ""
  
  # Step 3: Check for active artifacts (NEW)
  echo "─────────────────────────────────────────────"
  echo "Step 3: Detect active artifacts"
  echo "─────────────────────────────────────────────"
  check_active_artifacts
  echo ""
  
  # Step 4: Run validation
  echo "─────────────────────────────────────────────"
  echo "Step 4: Validate project lifecycle"
  echo "─────────────────────────────────────────────"
  run_validation || {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Validation Failed"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Issues found: $ISSUES_FOUND"
    echo "Issues fixed: $ISSUES_FIXED"
    echo ""
    if [[ ${#MANUAL_FIXES_NEEDED[@]} -gt 0 ]]; then
      echo "Manual fixes needed:"
      for fix in "${MANUAL_FIXES_NEEDED[@]}"; do
        echo "  • $fix"
      done
    fi
    if [[ ${#ACTIVE_ARTIFACTS[@]} -gt 0 ]]; then
      echo ""
      echo "Active artifacts found:"
      for artifact in "${ACTIVE_ARTIFACTS[@]}"; do
        echo "  • $artifact"
      done
    fi
    echo ""
    exit 1
  }
  echo ""
  
  # Step 5: Archive project
  if [[ "$DRY_RUN" == "false" ]]; then
    echo "─────────────────────────────────────────────"
    echo "Step 5: Archive project"
    echo "─────────────────────────────────────────────"
    run_archival
    echo ""
    
    # Step 6: Fix links
    echo "─────────────────────────────────────────────"
    echo "Step 6: Fix archived project links"
    echo "─────────────────────────────────────────────"
    fix_archived_links
    echo ""
  fi
  
  # Final summary
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "Dry Run Complete"
  else
    echo "Archive Complete"
  fi
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Issues found: $ISSUES_FOUND"
  echo "Issues fixed: $ISSUES_FIXED"
  if [[ ${#MANUAL_FIXES_NEEDED[@]} -gt 0 ]]; then
    echo "Manual fixes: ${#MANUAL_FIXES_NEEDED[@]}"
  fi
  if [[ ${#ACTIVE_ARTIFACTS[@]} -gt 0 ]]; then
    echo "Active artifacts: ${#ACTIVE_ARTIFACTS[@]}"
  fi
  echo ""
  if [[ "$DRY_RUN" == "false" ]]; then
    echo "Archived to: $ARCHIVED_DIR"
    echo ""
    success "Project successfully archived!"
  else
    info "Run without --dry-run to execute archival"
  fi
  echo ""
}

main
