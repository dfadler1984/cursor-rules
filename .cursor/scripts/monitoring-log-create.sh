#!/usr/bin/env bash
# monitoring-log-create.sh
# Purpose: Create a monitoring log with auto-incrementing ID and front matter

set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/.lib.sh"

# Script configuration
SCRIPT_NAME="monitoring-log-create.sh"
CONFIG_PATH="docs/active-monitoring.yaml"

show_help() {
    print_help_header "monitoring-log-create.sh" "Create a monitoring log with timestamped observation and auto-incrementing ID"
    
    print_usage "monitoring-log-create.sh --project <slug> --observation <description> [options]"
    
    print_options \
        "--project <slug>" "Project slug (must exist in active-monitoring.yaml)" \
        "--observation <desc>" "Description of the observation" \
        "--context <context>" "Work context (optional, defaults to current work)" \
        "--observer <name>" "Observer name (optional, defaults to Assistant)" \
        "-h, --help" "Show this help message"
    
    print_exit_codes
    
    print_examples \
        "monitoring-log-create.sh --project blocking-tdd-enforcement --observation \"Created file without test\"" \
        "monitoring-log-create.sh --project rules-enforcement --observation \"Pre-send gate bypassed\" --context \"Working on PR creation\""
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
    
    # Get logs path and verify directory exists
    local logs_path
    logs_path=$(yq eval ".monitoring.\"${project}\".logsPath" "${CONFIG_PATH}")
    if [[ ! -d "${logs_path}" ]]; then
        log_error "Logs directory not found: ${logs_path}"
        log_error "Create with: mkdir -p ${logs_path}"
        exit 1
    fi
}

get_next_log_id() {
    local project="$1"
    local logs_path
    logs_path=$(yq eval ".monitoring.\"${project}\".logsPath" "${CONFIG_PATH}")
    
    # Find highest existing log ID
    local max_id=0
    if [[ -d "${logs_path}" ]]; then
        for log_file in "${logs_path}"/log-*.md; do
            if [[ -f "${log_file}" ]]; then
                local filename
                filename=$(basename "${log_file}")
                if [[ "${filename}" =~ log-([0-9]+)- ]]; then
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

create_log_file() {
    local project="$1"
    local observation="$2"
    local context="${3:-Current work}"
    local observer="${4:-Assistant}"
    
    # Get paths and IDs
    local logs_path
    logs_path=$(yq eval ".monitoring.\"${project}\".logsPath" "${CONFIG_PATH}")
    
    local log_id
    log_id=$(get_next_log_id "${project}")
    
    local description_slug
    description_slug=$(sanitize_slug "${observation}")
    
    # Create filename with zero-padded ID
    local log_filename
    log_filename="log-$(printf "%03d" "${log_id}")-${description_slug}.md"
    local log_filepath="${logs_path}/${log_filename}"
    
    # Generate timestamps
    local timestamp
    timestamp=$(date -u "+%Y-%m-%d %H:%M:%S UTC")
    local creation_timestamp
    creation_timestamp=$(date -u "+%Y-%m-%d %H:%M:%S UTC")
    
    # Create log content directly (avoid template complexity)
    cat > "${log_filepath}" << EOF
---
logId: ${log_id}
timestamp: "${timestamp}"
project: "${project}"
observer: "${observer}"
reviewed: false
reviewedBy: null
reviewedDate: null
context: "${context}"
---

# Monitoring Log ${log_id} — ${observation}

**Project**: ${project}  
**Observer**: ${observer}  
**Context**: ${context}

---

## Observation

${observation}

<!-- 
Factual description of what happened. Keep objective and minimal interpretation.
Examples:
- Created \`project-archive-ready.sh\` (255 lines) without test file
- User said "implement X", guidance rules attached instead of implementation rules
- Pre-send gate did not trigger despite TDD rule loaded
-->

---

## System State

- **Rule(s) loaded**: [To be filled during observation]
- **Gate status**: [To be filled during observation]
- **Pre-send gate**: [To be filled during observation]
- **Files involved**: [To be filled during observation]

<!-- 
Capture the state of the system when the observation occurred:
- Which rules were attached/loaded (from intent routing)
- Did any gates trigger? (TDD pre-edit, pre-send, etc.)
- What was the gate response? (blocked, passed, warning)
- List specific files created, edited, or involved
-->

---

## Raw Data

- **Timestamp**: ${timestamp}
- **Duration**: [To be measured if applicable]
- **Error messages**: [None or to be filled]
- **Command executed**: [To be filled if applicable]
- **Exit code**: [To be filled if applicable]
- **File size**: [To be measured if applicable]
- **Line count**: [To be counted if applicable]

<!-- 
Measurable data points. Include any quantifiable information:
- Exact timestamps (start/end if measurable)
- File sizes, line counts
- Commands that were run (or should have been run)
- Error messages verbatim
- Exit codes, response codes
- Time elapsed between events
-->

---

## Notes

[Additional context to be filled]

<!-- 
Additional context that helps understand the observation, but keep interpretation minimal.
This is raw data collection, not analysis.
Examples:
- "This occurred 5 minutes after TDD gate was deployed"
- "Project context was rules-enforcement-investigation (ironic)"
- "User was working on archival script functionality"
- "Similar pattern observed in log-003 and log-007"
-->

---

## Related Logs

- [Reference to related log if applicable]

<!-- 
Reference other logs that might be related to this observation.
Use log IDs (log-001, log-002, etc.) not finding IDs.
-->

---

**Created**: ${creation_timestamp}  
**Template version**: 1.0
EOF
    
    # Output success message
    log_info "Created monitoring log: ${log_filename}"
    log_info "Location: ${log_filepath}"
    log_info "Log ID: ${log_id}"
    log_info "Project: ${project}"
    
    # Show next steps
    echo
    log_info "Next steps:"
    log_info "1. Edit ${log_filepath} to fill in observation details"
    log_info "2. Fill in System State, Raw Data, and Notes sections"
    log_info "3. Run 'monitoring-review.sh --project ${project}' to analyze patterns"
}

main() {
    local project=""
    local observation=""
    local context="Current work"
    local observer="Assistant"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --project)
                project="$2"
                shift 2
                ;;
            --observation)
                observation="$2"
                shift 2
                ;;
            --context)
                context="$2"
                shift 2
                ;;
            --observer)
                observer="$2"
                shift 2
                ;;
            -h|--help)
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
    
    if [[ -z "${observation}" ]]; then
        log_error "Missing required argument: --observation"
        show_help
        exit 1
    fi
    
    # Validate environment and project
    validate_requirements
    validate_project "${project}"
    
    # Create the log file
    create_log_file "${project}" "${observation}" "${context}" "${observer}"
}

main "$@"