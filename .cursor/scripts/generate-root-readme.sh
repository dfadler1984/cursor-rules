#!/usr/bin/env bash
# Generate root README.md from template with auto-generated sections
#
# Description: Generate repository root README.md from template
# Flags: --template, --out, --dry-run, --help, --version
# Usage: generate-root-readme.sh [--template PATH] [--out PATH] [--dry-run]
#
# Examples:
#   # Generate with defaults
#   ./generate-root-readme.sh
#
#   # Dry-run preview
#   ./generate-root-readme.sh --dry-run
#
#   # Custom template and output
#   ./generate-root-readme.sh --template ./custom.md --out ./OUTPUT.md

set -euo pipefail

# Script metadata
SCRIPT_VERSION="0.1.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Default paths
DEFAULT_TEMPLATE="$REPO_ROOT/templates/root-readme.template.md"
DEFAULT_OUTPUT="$REPO_ROOT/README.md"

# Configuration
TEMPLATE_PATH="$DEFAULT_TEMPLATE"
OUTPUT_PATH="$DEFAULT_OUTPUT"
DRY_RUN=false

#
# Helper Functions: Script Metadata Extraction
#

# Extract description from script header
# Args: script_path
# Returns: description text or filename if no description found
extract_script_description() {
  local script_path="$1"
  local description
  
  # Try to find "# Description: ..." line
  description=$(grep "^# Description:" "$script_path" 2>/dev/null | head -1 | sed 's/^# Description: *//' || true)
  
  if [[ -z "$description" ]]; then
    # Fallback to filename without extension
    description=$(basename "$script_path" .sh)
  fi
  
  echo "$description"
}

# Extract flags from script header
# Args: script_path
# Returns: comma-separated list of flags
extract_script_flags() {
  local script_path="$1"
  local flags
  
  # Try to find "# Flags: ..." line
  flags=$(grep "^# Flags:" "$script_path" 2>/dev/null | head -1 | sed 's/^# Flags: *//' || true)
  
  echo "$flags"
}

# List scripts in directory (excluding .lib*.sh and *.test.sh)
# Args: scripts_dir
# Returns: newline-separated list of script paths
list_scripts() {
  local scripts_dir="$1"
  
  find "$scripts_dir" -maxdepth 1 -name "*.sh" -type f \
    ! -name ".lib*.sh" \
    ! -name "*.test.sh" \
    | sort
}

# Categorize script by filename prefix
# Args: script_name
# Returns: category name
categorize_script() {
  local script_name="$1"
  
  case "$script_name" in
    git-*|pr-*|checks-*)
      echo "Git Workflows"
      ;;
    rules-*)
      echo "Rules Management"
      ;;
    project-*|archive-*|final-summary-*)
      echo "Project Lifecycle"
      ;;
    validate-*|*-validate*|shellcheck-*|lint-*)
      echo "Validation"
      ;;
    security-*|health-*|compliance-*)
      echo "CI & Health"
      ;;
    *)
      echo "Utilities"
      ;;
  esac
}

#
# Helper Functions: Rules Metadata Extraction
#

# Extract description from rule front matter
# Args: rule_path
# Returns: description text or "Rule: filename" if no description found
extract_rule_description() {
  local rule_path="$1"
  local description
  
  # Try to extract description from YAML front matter
  # Look for "description:" line between --- delimiters
  description=$(awk '
    /^---$/ { in_fm = !in_fm; next }
    in_fm && /^description:/ { 
      sub(/^description: */, ""); 
      print; 
      exit 
    }
  ' "$rule_path" 2>/dev/null || true)
  
  if [[ -z "$description" ]]; then
    # Fallback to "Rule: filename" without extension
    local filename
    filename=$(basename "$rule_path" .mdc)
    description="Rule: $filename"
  fi
  
  echo "$description"
}

# Check if rule has alwaysApply: true
# Args: rule_path
# Returns: "true" or "false"
is_always_apply_rule() {
  local rule_path="$1"
  local always_apply
  
  # Look for "alwaysApply: true" in front matter
  always_apply=$(awk '
    /^---$/ { in_fm = !in_fm; next }
    in_fm && /^alwaysApply:/ { 
      sub(/^alwaysApply: */, ""); 
      print; 
      exit 
    }
  ' "$rule_path" 2>/dev/null || true)
  
  if [[ "$always_apply" == "true" ]]; then
    echo "true"
  else
    echo "false"
  fi
}

# List rules in directory
# Args: rules_dir
# Returns: newline-separated list of rule paths
list_rules() {
  local rules_dir="$1"
  
  find "$rules_dir" -maxdepth 1 -name "*.mdc" -type f | sort
}

# Categorize rule by alwaysApply status
# Args: rule_path
# Returns: category name
categorize_rule() {
  local rule_path="$1"
  local always_apply
  
  always_apply=$(is_always_apply_rule "$rule_path")
  
  if [[ "$always_apply" == "true" ]]; then
    echo "Always Applied"
  else
    # For now, all non-always-apply rules go to "Workflow & Process"
    # Can be refined later based on keywords in description/tags
    echo "Workflow & Process"
  fi
}

#
# CLI Argument Parsing
#

show_help() {
  cat << EOF
Generate root README.md from template with auto-generated sections

Usage: $(basename "$0") [OPTIONS]

Options:
  --template PATH   Path to template file (default: templates/root-readme.template.md)
  --out PATH        Output file path (default: README.md)
  --dry-run         Print to stdout without writing file
  --help            Show this help message
  --version         Show script version

Examples:
  # Generate with defaults
  $(basename "$0")

  # Dry-run preview
  $(basename "$0") --dry-run

  # Custom template
  $(basename "$0") --template ./custom-template.md

Placeholders:
  {{HEALTH_BADGE}}           - Repository health badge
  {{SUPPORTED_ENVIRONMENTS}} - Node/shell/OS versions
  {{AVAILABLE_RULES}}        - Categorized rules list
  {{AVAILABLE_SCRIPTS}}      - Categorized scripts list
  {{AVAILABLE_COMMANDS}}     - Slash commands list
  {{ACTIVE_PROJECTS}}        - Active projects with completion %
  {{PRIORITY_PROJECTS}}      - High-priority and blocked projects
  {{TEST_STATS}}             - Test coverage stats (optional)
  {{DOCS_STRUCTURE}}         - Documentation links
  {{GENERATED_DATE}}         - ISO 8601 timestamp
  {{VERSION}}                - Current version from VERSION file

EOF
}

show_version() {
  echo "generate-root-readme.sh version $SCRIPT_VERSION"
}

#
# Helper Functions: Project Stats Extraction
#

# Count active projects (excluding _archived, _examples)
# Args: projects_dir
# Returns: count of active projects
count_active_projects() {
  local projects_dir="$1"
  local count=0
  
  # Find all directories with erd.md, excluding _archived and _examples
  while IFS= read -r -d '' erd_file; do
    local project_dir
    project_dir=$(dirname "$erd_file")
    local project_name
    project_name=$(basename "$project_dir")
    
    # Skip if starts with underscore (e.g., _archived, _examples)
    if [[ "$project_name" != _* ]]; then
      # Check if status is "active" in front matter
      local status
      status=$(awk '
        /^---$/ { in_fm = !in_fm; next }
        in_fm && /^status:/ { 
          sub(/^status: */, ""); 
          print; 
          exit 
        }
      ' "$erd_file" 2>/dev/null || true)
      
      if [[ "$status" == "active" ]]; then
        count=$((count + 1))
      fi
    fi
  done < <(find "$projects_dir" -maxdepth 2 -name "erd.md" -print0 2>/dev/null)
  
  echo "$count"
}

# Count archived projects in _archived subdirectories
# Args: projects_dir
# Returns: count of archived projects
count_archived_projects() {
  local projects_dir="$1"
  local count=0
  
  # Find all erd.md files under _archived/
  if [[ -d "$projects_dir/_archived" ]]; then
    count=$(find "$projects_dir/_archived" -name "erd.md" 2>/dev/null | wc -l | tr -d ' ')
  fi
  
  echo "$count"
}

# Count total rules in directory
# Args: rules_dir
# Returns: count of .mdc files
count_total_rules() {
  local rules_dir="$1"
  local count
  
  count=$(find "$rules_dir" -maxdepth 1 -name "*.mdc" -type f 2>/dev/null | wc -l | tr -d ' ')
  
  echo "$count"
}

#
# Helper Functions: Template Rendering
#

# Replace a placeholder in template with content
# Args: template_text placeholder_name replacement_content
# Returns: template with placeholder replaced
replace_placeholder() {
  local template_text="$1"
  local placeholder="$2"
  local replacement="$3"
  
  # Use bash parameter substitution for simple, multiline-safe replacement
  # This handles newlines correctly without escaping
  local placeholder_pattern="{{$placeholder}}"
  echo "${template_text//$placeholder_pattern/$replacement}"
}

# Load template file
# Args: template_path
# Returns: template content
load_template() {
  local template_path="$1"
  
  if [[ ! -f "$template_path" ]]; then
    echo "Error: Template file not found: $template_path" >&2
    return 1
  fi
  
  cat "$template_path"
}

#
# Helper Functions: Project Metadata Extraction
#

# Extract project title from ERD (first H1)
# Args: erd_path
# Returns: project title
extract_project_title() {
  local erd_path="$1"
  local title
  
  # Get first H1 (line starting with "# ")
  title=$(grep "^# " "$erd_path" 2>/dev/null | head -1 | sed 's/^# *//' || true)
  
  if [[ -z "$title" ]]; then
    # Fallback to directory name
    local project_dir
    project_dir=$(dirname "$erd_path")
    title=$(basename "$project_dir")
  fi
  
  echo "$title"
}

# Extract priority from ERD front matter
# Args: erd_path
# Returns: priority value (high|medium|low) or empty
extract_priority() {
  local erd_path="$1"
  
  awk '
    /^---$/ { in_fm = !in_fm; next }
    in_fm && /^priority:/ { 
      sub(/^priority: */, ""); 
      print; 
      exit 
    }
  ' "$erd_path" 2>/dev/null || true
}

# Check if project is blocked
# Args: erd_path
# Returns: "true" or "false"
is_blocked() {
  local erd_path="$1"
  local blocked
  
  blocked=$(awk '
    /^---$/ { in_fm = !in_fm; next }
    in_fm && /^blocked:/ { 
      sub(/^blocked: */, ""); 
      print; 
      exit 
    }
  ' "$erd_path" 2>/dev/null || true)
  
  if [[ "$blocked" == "true" ]]; then
    echo "true"
  else
    echo "false"
  fi
}

# Extract blocker reason from ERD front matter
# Args: erd_path
# Returns: blocker reason or empty
extract_blocker() {
  local erd_path="$1"
  
  awk '
    /^---$/ { in_fm = !in_fm; next }
    in_fm && /^blocker:/ { 
      sub(/^blocker: *"*/, ""); 
      sub(/"*$/, "");
      print; 
      exit 
    }
  ' "$erd_path" 2>/dev/null || true
}

# Calculate project completion percentage from tasks.md
# Args: tasks_path
# Returns: completion percentage (0-100) or "N/A"
calculate_completion() {
  local tasks_path="$1"
  
  if [[ ! -f "$tasks_path" ]]; then
    echo "N/A"
    return
  fi
  
  # Count checked and total tasks
  local checked
  local total
  checked=$(grep "^- \[x\]" "$tasks_path" 2>/dev/null | wc -l | tr -d ' ')
  total=$(grep "^- \[[x ]\]" "$tasks_path" 2>/dev/null | wc -l | tr -d ' ')
  
  # Ensure values are numeric and not empty
  checked=${checked:-0}
  total=${total:-0}
  
  # Remove any newlines or non-numeric characters
  checked=$(echo "$checked" | tr -d '\n' | grep -o '[0-9]*' || echo "0")
  total=$(echo "$total" | tr -d '\n' | grep -o '[0-9]*' || echo "0")
  
  if [[ -z "$checked" ]] || [[ -z "$total" ]] || [[ "$total" -eq 0 ]]; then
    echo "N/A"
  else
    local pct=$((checked * 100 / total))
    echo "${pct}%"
  fi
}

#
# Section Generators
#

# Generate scripts inventory section
# Args: scripts_dir
# Returns: markdown formatted scripts list
generate_scripts_section() {
  local scripts_dir="$1"
  local output=""
  
  # Declare associative array for categories
  declare -A categories
  
  # Collect scripts by category
  while IFS= read -r script_path; do
    local script_name
    script_name=$(basename "$script_path")
    local description
    description=$(extract_script_description "$script_path")
    local category
    category=$(categorize_script "$script_name")
    
    # Append to category
    if [[ -v categories[$category] ]]; then
      categories["$category"]+=$'\n'"- \`.cursor/scripts/$script_name\` — $description"
    else
      categories["$category"]="- \`.cursor/scripts/$script_name\` — $description"
    fi
  done < <(list_scripts "$scripts_dir")
  
  # Output in order: Git Workflows, Rules Management, Project Lifecycle, Validation, CI & Health, Utilities
  local ordered_categories=("Git Workflows" "Rules Management" "Project Lifecycle" "Validation" "CI & Health" "Utilities")
  
  for category in "${ordered_categories[@]}"; do
    if [[ -v categories[$category] ]] && [[ -n "${categories[$category]}" ]]; then
      output+="### $category"$'\n\n'
      output+="${categories[$category]}"$'\n\n'
    fi
  done
  
  echo "$output"
}

# Generate rules inventory section
# Args: rules_dir
# Returns: markdown formatted rules list
generate_rules_section() {
  local rules_dir="$1"
  local output=""
  
  # Declare associative arrays for categories
  declare -A always_applied
  declare -A workflow
  
  # Collect rules by category
  while IFS= read -r rule_path; do
    local rule_name
    rule_name=$(basename "$rule_path" .mdc)
    local description
    description=$(extract_rule_description "$rule_path")
    local category
    category=$(categorize_rule "$rule_path")
    
    local line="- \`$rule_name.mdc\` — $description"
    
    if [[ "$category" == "Always Applied" ]]; then
      if [[ -v always_applied[always] ]]; then
        always_applied[always]+=$'\n'"$line"
      else
        always_applied[always]="$line"
      fi
    else
      if [[ -v workflow[workflow] ]]; then
        workflow[workflow]+=$'\n'"$line"
      else
        workflow[workflow]="$line"
      fi
    fi
  done < <(list_rules "$rules_dir")
  
  # Output Always Applied first
  if [[ -v always_applied[always] ]] && [[ -n "${always_applied[always]}" ]]; then
    output+="**Always Applied** (active in all chats):"$'\n\n'
    output+="${always_applied[always]}"$'\n\n'
  fi
  
  # Then Workflow & Process
  if [[ -v workflow[workflow] ]] && [[ -n "${workflow[workflow]}" ]]; then
    output+="**Workflow & Process**:"$'\n\n'
    output+="${workflow[workflow]}"$'\n\n'
  fi
  
  echo "$output"
}

# Generate active projects section
# Args: projects_dir
# Returns: markdown formatted active projects list
generate_active_projects_section() {
  local projects_dir="$1"
  local output=""
  local count=0
  
  # Find all active projects (not blocked, not in _* directories)
  while IFS= read -r -d '' erd_file; do
    local project_dir
    project_dir=$(dirname "$erd_file")
    local project_name
    project_name=$(basename "$project_dir")
    
    # Skip _archived, _examples, etc.
    if [[ "$project_name" == _* ]]; then
      continue
    fi
    
    # Get status
    local status
    status=$(awk '
      /^---$/ { in_fm = !in_fm; next }
      in_fm && /^status:/ { 
        sub(/^status: */, ""); 
        print; 
        exit 
      }
    ' "$erd_file" 2>/dev/null || true)
    
    # Only include active projects
    if [[ "$status" != "active" ]]; then
      continue
    fi
    
    # Check if blocked
    local blocked
    blocked=$(is_blocked "$erd_file")
    if [[ "$blocked" == "true" ]]; then
      continue
    fi
    
    # Extract metadata
    local title
    title=$(extract_project_title "$erd_file")
    
    local completion
    local tasks_path="$project_dir/tasks.md"
    completion=$(calculate_completion "$tasks_path")
    
    # Format entry
    output+="- **$project_name** — $title [$completion complete]"$'\n'
    count=$((count + 1))
  done < <(find "$projects_dir" -maxdepth 2 -name "erd.md" -print0 2>/dev/null | sort -z)
  
  if [[ $count -eq 0 ]]; then
    output="No active projects"$'\n'
  fi
  
  echo "$output"
}

# Generate priority projects section
# Args: projects_dir
# Returns: markdown formatted priority and blocked projects
generate_priority_projects_section() {
  local projects_dir="$1"
  local output=""
  local high_priority=""
  local blocked_projects=""
  local high_count=0
  local blocked_count=0
  
  # Find all projects with priority or blocked status
  while IFS= read -r -d '' erd_file; do
    local project_dir
    project_dir=$(dirname "$erd_file")
    local project_name
    project_name=$(basename "$project_dir")
    
    # Skip _archived, _examples
    if [[ "$project_name" == _* ]]; then
      continue
    fi
    
    local priority
    priority=$(extract_priority "$erd_file")
    
    local blocked
    blocked=$(is_blocked "$erd_file")
    
    local title
    title=$(extract_project_title "$erd_file")
    
    local completion
    local tasks_path="$project_dir/tasks.md"
    completion=$(calculate_completion "$tasks_path")
    
    # High priority projects
    if [[ "$priority" == "high" ]]; then
      if [[ "$blocked" == "true" ]]; then
        # Goes in blocked section instead
        local blocker
        blocker=$(extract_blocker "$erd_file")
        blocked_projects+="- **$project_name** (priority: $priority) — $title"$'\n'
        blocked_projects+="  - ⚠️ Blocker: $blocker"$'\n'
        blocked_count=$((blocked_count + 1))
      else
        high_priority+="- **$project_name** — $title [$completion complete]"$'\n'
        high_count=$((high_count + 1))
      fi
    elif [[ "$blocked" == "true" ]]; then
      # Blocked but not high priority
      local blocker
      blocker=$(extract_blocker "$erd_file")
      blocked_projects+="- **$project_name** — $title"$'\n'
      blocked_projects+="  - ⚠️ Blocker: $blocker"$'\n'
      blocked_count=$((blocked_count + 1))
    fi
  done < <(find "$projects_dir" -maxdepth 2 -name "erd.md" -print0 2>/dev/null | sort -z)
  
  # Format output
  if [[ $high_count -gt 0 ]]; then
    output+="**High Priority** ($high_count):"$'\n\n'
    output+="$high_priority"$'\n'
  fi
  
  if [[ $blocked_count -gt 0 ]]; then
    output+="**Blocked** ($blocked_count need unblocking):"$'\n\n'
    output+="$blocked_projects"
  fi
  
  if [[ $high_count -eq 0 ]] && [[ $blocked_count -eq 0 ]]; then
    output="No priority or blocked projects"$'\n'
  fi
  
  echo "$output"
}

# Generate documentation structure section
# Args: docs_dir projects_dir rules_dir
# Returns: markdown formatted documentation links
generate_docs_structure_section() {
  local docs_dir="$1"
  local projects_dir="$2"
  local rules_dir="$3"
  
  local active_count
  active_count=$(count_active_projects "$projects_dir")
  
  local archived_count
  archived_count=$(count_archived_projects "$projects_dir")
  
  local rules_count
  rules_count=$(count_total_rules "$rules_dir")
  
  local output=""
  output+="- **Scripts**: [\`docs/scripts/README.md\`](./docs/scripts/README.md)"$'\n'
  output+="- **Projects**: [\`docs/projects/README.md\`](./docs/projects/README.md) ($active_count active, $archived_count archived)"$'\n'
  output+="- **Rules**: [\`.cursor/rules/\`](./.cursor/rules/) ($rules_count rules)"$'\n'
  output+="- **Guides**: [\`docs/guides/\`](./docs/guides/)"$'\n'
  
  echo "$output"
}

# Extract health badge from current README or generate placeholder
# Args: current_readme_path
# Returns: health badge markdown
extract_health_badge() {
  local current_readme="$1"
  
  if [[ -f "$current_readme" ]]; then
    # Try to extract existing badge from line 3
    local badge
    badge=$(sed -n '3p' "$current_readme" 2>/dev/null || true)
    
    if [[ "$badge" == [![Repository\ Health* ]]; then
      echo "$badge"
      return
    fi
  fi
  
  # Fallback: generate placeholder badge
  echo "[![Repository Health](https://img.shields.io/badge/health-pending-yellow)](https://github.com)"
}

# Generate supported environments from package.json
# Args: package_json_path
# Returns: markdown formatted environments list
generate_supported_environments() {
  local package_json="$1"
  local output=""
  
  # Extract Node version from package.json if available
  if [[ -f "$package_json" ]]; then
    local node_version
    node_version=$(grep -A 2 '"engines"' "$package_json" 2>/dev/null | grep '"node"' | sed 's/.*"node": *"\([^"]*\)".*/\1/' || true)
    
    if [[ -n "$node_version" ]]; then
      output+="- Node.js $node_version"$'\n'
    else
      output+="- Node.js 18+"$'\n'
    fi
  else
    output+="- Node.js 18+"$'\n'
  fi
  
  # Shell environments (static for now - could detect from shebangs)
  output+="- Bash 4+ or Zsh 5+"$'\n'
  output+="- macOS (primary), Linux (CI)"
  
  echo "$output"
}

#
# Main Generation Logic
#

main() {
  # Load template
  local template
  template=$(load_template "$TEMPLATE_PATH") || exit 1
  
  # Generate sections
  echo "Generating sections..." >&2
  
  # 1. Health Badge
  echo "  - Extracting health badge..." >&2
  local health_badge
  # Extract from current README.md (if it exists), not OUTPUT_PATH (which we're about to overwrite)
  health_badge=$(extract_health_badge "$REPO_ROOT/README.md")
  template=$(replace_placeholder "$template" "HEALTH_BADGE" "$health_badge")
  
  # 2. Supported Environments
  echo "  - Generating supported environments..." >&2
  local environments
  environments=$(generate_supported_environments "$REPO_ROOT/package.json")
  template=$(replace_placeholder "$template" "SUPPORTED_ENVIRONMENTS" "$environments")
  
  # 3. Available Rules
  echo "  - Generating rules section..." >&2
  local rules_section
  rules_section=$(generate_rules_section "$REPO_ROOT/.cursor/rules")
  template=$(replace_placeholder "$template" "AVAILABLE_RULES" "$rules_section")
  
  # 4. Available Scripts
  echo "  - Generating scripts section..." >&2
  local scripts_section
  scripts_section=$(generate_scripts_section "$REPO_ROOT/.cursor/scripts")
  template=$(replace_placeholder "$template" "AVAILABLE_SCRIPTS" "$scripts_section")
  
  # 5. Active Projects
  echo "  - Generating active projects section..." >&2
  local active_projects_section
  active_projects_section=$(generate_active_projects_section "$REPO_ROOT/docs/projects")
  template=$(replace_placeholder "$template" "ACTIVE_PROJECTS" "$active_projects_section")
  
  # 6. Priority Projects
  echo "  - Generating priority projects section..." >&2
  local priority_projects_section
  priority_projects_section=$(generate_priority_projects_section "$REPO_ROOT/docs/projects")
  template=$(replace_placeholder "$template" "PRIORITY_PROJECTS" "$priority_projects_section")
  
  # 7. Documentation Structure
  echo "  - Generating documentation structure section..." >&2
  local docs_structure_section
  docs_structure_section=$(generate_docs_structure_section "$REPO_ROOT/docs" "$REPO_ROOT/docs/projects" "$REPO_ROOT/.cursor/rules")
  template=$(replace_placeholder "$template" "DOCS_STRUCTURE" "$docs_structure_section")
  
  # 8-9. Remaining placeholders (to be implemented)
  template=$(replace_placeholder "$template" "AVAILABLE_COMMANDS" "[Commands section pending]")
  template=$(replace_placeholder "$template" "TEST_STATS" "")
  
  # Metadata
  local generated_date
  generated_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  template=$(replace_placeholder "$template" "GENERATED_DATE" "$generated_date")
  
  local version
  if [[ -f "$REPO_ROOT/VERSION" ]]; then
    version=$(cat "$REPO_ROOT/VERSION")
  else
    version="unknown"
  fi
  template=$(replace_placeholder "$template" "VERSION" "$version")
  
  # Output
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
    echo "DRY RUN - Generated README:" >&2
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
    echo "$template"
  else
    # Atomic write: write to temp file then move
    local temp_file="${OUTPUT_PATH}.tmp"
    echo "$template" > "$temp_file"
    mv "$temp_file" "$OUTPUT_PATH"
    echo "✓ Generated: $OUTPUT_PATH" >&2
  fi
}

# Run main function if executed (not sourced)
# Only parse arguments and run main if this script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Parse command-line arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --template)
        TEMPLATE_PATH="$2"
        shift 2
        ;;
      --out)
        OUTPUT_PATH="$2"
        shift 2
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --help)
        show_help
        exit 0
        ;;
      --version)
        show_version
        exit 0
        ;;
      *)
        echo "Error: Unknown option: $1" >&2
        echo "Use --help for usage information." >&2
        exit 1
        ;;
    esac
  done
  
  main
fi

