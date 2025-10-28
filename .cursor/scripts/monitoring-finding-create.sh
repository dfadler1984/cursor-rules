#!/usr/bin/env bash
# monitoring-finding-create.sh
# Purpose: Create a monitoring finding with auto-incrementing ID and front matter

set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/.lib.sh"

# Script configuration
SCRIPT_NAME="monitoring-finding-create.sh"
CONFIG_PATH="docs/active-monitoring.yaml"

show_help() {
    cat << 'EOF'
Usage: monitoring-finding-create.sh --project <slug> --title <pattern-name> [options]

Create a monitoring finding with auto-incrementing ID and structured template.

OPTIONS:
    --project <slug>        Project slug (must exist in active-monitoring.yaml)
    --title <pattern>       Pattern name for the finding
    --severity <level>      Severity level (critical|high|medium|low, default: medium)
    --status <status>       Status (open|in-progress|resolved, default: open)
    --source-logs <ids>     Comma-separated log IDs (e.g., "001,003,007")
    --help                  Show this help message

EXAMPLES:
    monitoring-finding-create.sh --project blocking-tdd-enforcement --title "tdd-gate-scope-gap"
    monitoring-finding-create.sh --project rules-enforcement --title "script-bypass-pattern" --severity critical --source-logs "001,005,012"

REQUIREMENTS:
    - active-monitoring.yaml must exist in current directory
    - Project must have active monitoring entry
    - Project monitoring/findings/ directory must exist

OUTPUT:
    Creates: docs/projects/<project>/monitoring/findings/finding-###-<pattern-slug>.md
    Format: Front matter + structured analysis template
    
EOF
}

validate_requirements() {
    # Check if active-monitoring.yaml exists
    if [[ ! -f "${CONFIG_PATH}" ]]; then
        log_error "active-monitoring.yaml not found in current directory"
        log_error "Run this script from the repository root"
        exit 1
    fi
    
    # Check if yq is available (for YAML parsing)
    if ! command -v yq >/dev/null 2>&1; then
        log_error "yq is required but not installed"
        log_error "Install with: brew install yq"
        exit 1
    fi
}

validate_project() {
    local project="$1"
    
    # Check if project exists in active monitoring
    if ! yq eval ".monitoring | has(\"${project}\")" "${CONFIG_PATH}" | grep -q "true"; then
        log_error "Project '${project}' not found in active-monitoring.yaml"
        log_error "Available projects:"
        yq eval '.monitoring | keys' "${CONFIG_PATH}" | sed 's/^/  /'
        exit 1
    fi
    
    # Check if project has active status
    local status
    status=$(yq eval ".monitoring.\"${project}\".status" "${CONFIG_PATH}")
    if [[ "${status}" != "active" ]]; then
        log_error "Project '${project}' status is '${status}', not 'active'"
        exit 1
    fi
    
    # Get findings path and verify directory exists
    local findings_path
    findings_path=$(yq eval ".monitoring.\"${project}\".findingsPath" "${CONFIG_PATH}")
    if [[ ! -d "${findings_path}" ]]; then
        log_error "Findings directory not found: ${findings_path}"
        log_error "Create with: mkdir -p ${findings_path}"
        exit 1
    fi
}

validate_severity() {
    local severity="$1"
    case "${severity}" in
        critical|high|medium|low)
            return 0
            ;;
        *)
            log_error "Invalid severity: ${severity}"
            log_error "Valid options: critical, high, medium, low"
            exit 1
            ;;
    esac
}

validate_status() {
    local status="$1"
    case "${status}" in
        open|in-progress|resolved)
            return 0
            ;;
        *)
            log_error "Invalid status: ${status}"
            log_error "Valid options: open, in-progress, resolved"
            exit 1
            ;;
    esac
}

get_next_finding_id() {
    local project="$1"
    local findings_path
    findings_path=$(yq eval ".monitoring.\"${project}\".findingsPath" "${CONFIG_PATH}")
    
    # Find highest existing finding ID
    local max_id=0
    if [[ -d "${findings_path}" ]]; then
        for finding_file in "${findings_path}"/finding-*.md; do
            if [[ -f "${finding_file}" ]]; then
                local filename
                filename=$(basename "${finding_file}")
                if [[ "${filename}" =~ finding-([0-9]+)- ]]; then
                    local id="${BASH_REMATCH[1]}"
                    if [[ "${id}" -gt "${max_id}" ]]; then
                        max_id="${id}"
                    fi
                fi
            fi
        done
    fi
    
    echo $((max_id + 1))
}

sanitize_slug() {
    local input="$1"
    # Convert to lowercase, replace non-alphanumeric with hyphens, clean up
    local slug
    slug=$(echo "${input}" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g')
    slug=$(echo "${slug}" | sed 's/--*/-/g')
    slug=$(echo "${slug}" | sed 's/^-*//' | sed 's/-*$//')
    echo "${slug}"
}

format_source_logs() {
    local source_logs="$1"
    if [[ -n "${source_logs}" ]]; then
        # Convert comma-separated IDs to YAML array format
        echo "[\"$(echo "${source_logs}" | sed 's/,/", "/g')\"]"
    else
        echo "[]"
    fi
}

create_finding_file() {
    local project="$1"
    local title="$2"
    local severity="$3"
    local status="$4"
    local source_logs="$5"
    
    # Get paths and IDs
    local findings_path
    findings_path=$(yq eval ".monitoring.\"${project}\".findingsPath" "${CONFIG_PATH}")
    
    local finding_id
    finding_id=$(get_next_finding_id "${project}")
    
    local title_slug
    title_slug=$(sanitize_slug "${title}")
    
    # Create filename with zero-padded ID
    local finding_filename
    finding_filename="finding-$(printf "%03d" "${finding_id}")-${title_slug}.md"
    local finding_filepath="${findings_path}/${finding_filename}"
    
    # Generate timestamps
    local date
    date=$(date -u "+%Y-%m-%d")
    local creation_timestamp
    creation_timestamp=$(date -u "+%Y-%m-%d %H:%M:%S UTC")
    
    # Format source logs for YAML
    local formatted_source_logs
    formatted_source_logs=$(format_source_logs "${source_logs}")
    
    # Create finding content directly
    cat > "${finding_filepath}" << EOF
---
findingId: ${finding_id}
date: "${date}"
project: "${project}"
severity: "${severity}"
status: "${status}"
reviewed: false
reviewedBy: null
reviewedDate: null
sourceLogs: ${formatted_source_logs}
---

# Finding ${finding_id}: ${title}

**Project**: ${project}  
**Severity**: ${severity}  
**Status**: ${status}  
**Source Logs**: ${source_logs:-None}

---

## Pattern

[Describe the pattern that was identified across multiple logs]

<!-- 
Examples:
- "TDD pre-edit gate triggers on 'editing' but not 'creating' new files"
- "Intent routing attaches guidance rules when implementation was requested"
- "Pre-send gate bypassed when specific rule combinations are loaded"
- "Changeset policy violations occur during manual PR creation"
-->

---

## Evidence

[References to specific logs, with key facts]

**Supporting logs**:
$(if [[ -n "${source_logs}" ]]; then
    IFS=',' read -ra LOG_IDS <<< "${source_logs}"
    for log_id in "${LOG_IDS[@]}"; do
        echo "- **log-${log_id}**: [Key fact from this log]"
    done
else
    echo "- [Reference to supporting logs when available]"
fi)

**Key facts**:
- [Key fact 1]
- [Key fact 2]
- [Key fact 3]

<!-- 
Reference specific logs and extract the key facts that support this pattern.
Be specific about what each log contributed to the pattern recognition.
Include quantifiable data where possible (timestamps, file counts, etc.)
-->

---

## Root Cause

[Analysis of why this pattern occurs]

**Primary cause**: [Main underlying reason]

**Contributing factors**:
- [Contributing factor 1]
- [Contributing factor 2]

**Why this happens**:
[Detailed explanation of the underlying mechanism]

<!-- 
Analysis of why this pattern occurs. Dig into the underlying reasons.
Examples:
- Rule text ambiguity ("editing" vs "creating")
- Missing enforcement mechanism (OUTPUT requirement not enforced)
- Timing issues (rule loaded after gate should trigger)
- Configuration conflicts (multiple rules with overlapping scope)
- Process gaps (manual steps bypassing automation)
-->

---

## Impact

**Effect on project**: [Impact on this specific project]

**Effect on quality**: [Impact on overall system quality]

**Effect on compliance**: [Impact on rule compliance]

**Quantified impact**:
- [Quantified impact 1]
- [Quantified impact 2]

<!-- 
Assess the impact of this pattern on the project and broader system.
Examples:
- "13 TDD violations documented despite gate deployment"
- "95% of findings documented in wrong project before routing fix"
- "Average time to identify pattern: 5 days vs 1 day with better logging"
- "User correction required in 15% of routing decisions"
-->

---

## Recommendation

**Immediate actions**:
1. [Immediate action 1]
2. [Immediate action 2]
3. [Immediate action 3]

**Long-term improvements**:
- [Long-term improvement 1]
- [Long-term improvement 2]

**Proposed changes**:
- **[Change target 1]**: [Change description 1]
- **[Change target 2]**: [Change description 2]

**Success criteria**:
- [Success criterion 1]
- [Success criterion 2]

<!-- 
Specific, actionable recommendations to address the root cause.
Include both immediate fixes and longer-term improvements.
Examples:
- "Update assistant-behavior.mdc line 290: change 'editing' to 'creating or editing'"
- "Add file pairing validation to TDD pre-edit gate"
- "Implement OUTPUT requirement enforcement in pre-send gate"
- "Create monitoring-validate-paths.sh to detect wrong-project findings"
-->

---

## Related

**Other findings**:
- [Related finding 1]: [Relationship description]
- [Related finding 2]: [Relationship description]

**Relevant projects**:
- [Related project 1]: [Project relationship]
- [Related project 2]: [Project relationship]

**Rules affected**:
- [Affected rule 1]: [Rule impact]
- [Affected rule 2]: [Rule impact]

**Scripts affected**:
- [Affected script 1]: [Script impact]
- [Affected script 2]: [Script impact]

<!-- 
Link to related findings, projects, rules, and scripts.
Show how this finding connects to the broader system.
Examples:
- "Related to Finding #3: Both involve TDD gate scope issues"
- "Affects rules-enforcement-investigation: This pattern is what they monitor"
- "Impacts assistant-behavior.mdc: Core enforcement mechanism"
- "Requires update to git-commit.sh: Must handle new changeset policy"
-->

---

## Resolution Tracking

**Status updates**:
- ${date}: Finding created

**Implementation progress**:
- [ ] [Implementation task 1]
- [ ] [Implementation task 2]
- [ ] [Implementation task 3]

**Validation**:
- [ ] [Validation task 1]
- [ ] [Validation task 2]

<!-- 
Track the progress of implementing the recommendations.
Update this section as work progresses.
Mark tasks as completed and add new status updates.
-->

---

**Created**: ${creation_timestamp}  
**Last updated**: ${creation_timestamp}  
**Template version**: 1.0
EOF
    
    # Output success message
    log_info "Created monitoring finding: ${finding_filename}"
    log_info "Location: ${finding_filepath}"
    log_info "Finding ID: ${finding_id}"
    log_info "Project: ${project}"
    log_info "Severity: ${severity}"
    log_info "Status: ${status}"
    
    # Show next steps
    echo
    log_info "Next steps:"
    log_info "1. Edit ${finding_filepath} to fill in analysis"
    log_info "2. Complete Pattern, Evidence, Root Cause, Impact sections"
    log_info "3. Add specific recommendations and related items"
    log_info "4. Update status as work progresses"
}

main() {
    local project=""
    local title=""
    local severity="medium"
    local status="open"
    local source_logs=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --project)
                project="$2"
                shift 2
                ;;
            --title)
                title="$2"
                shift 2
                ;;
            --severity)
                severity="$2"
                shift 2
                ;;
            --status)
                status="$2"
                shift 2
                ;;
            --source-logs)
                source_logs="$2"
                shift 2
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Validate required arguments
    if [[ -z "${project}" ]]; then
        log_error "Missing required argument: --project"
        show_help
        exit 1
    fi
    
    if [[ -z "${title}" ]]; then
        log_error "Missing required argument: --title"
        show_help
        exit 1
    fi
    
    # Validate optional arguments
    validate_severity "${severity}"
    validate_status "${status}"
    
    # Validate environment and project
    validate_requirements
    validate_project "${project}"
    
    # Create the finding file
    create_finding_file "${project}" "${title}" "${severity}" "${status}" "${source_logs}"
}

main "$@"






