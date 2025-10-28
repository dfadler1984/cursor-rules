#!/usr/bin/env bash
# monitoring-review.sh
# Purpose: Review monitoring logs and findings, mark as reviewed, suggest patterns

set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/.lib.sh"

# Script configuration
SCRIPT_NAME="monitoring-review.sh"
CONFIG_PATH="docs/active-monitoring.yaml"

show_help() {
    cat << 'EOF'
Usage: monitoring-review.sh --project <slug> [options]

Review monitoring logs and findings for a project. Show unreviewed items and optionally mark them as reviewed.

OPTIONS:
    --project <slug>        Project slug (must exist in active-monitoring.yaml)
    --mark-reviewed         Mark all unreviewed items as reviewed
    --reviewer <name>       Reviewer name (for mark-reviewed, defaults to current user)
    --help                  Show this help message

EXAMPLES:
    monitoring-review.sh --project blocking-tdd-enforcement
    monitoring-review.sh --project rules-enforcement --mark-reviewed
    monitoring-review.sh --project consent-gates --mark-reviewed --reviewer "John Doe"

REQUIREMENTS:
    - active-monitoring.yaml must exist in current directory
    - Project must have active monitoring entry
    - Project monitoring/ directories must exist

OUTPUT:
    Shows: Unreviewed logs and findings with summary
    With --mark-reviewed: Updates front matter with review status
    
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
    
    # Get paths and verify directories exist
    local logs_path findings_path
    logs_path=$(yq eval ".monitoring.\"${project}\".logsPath" "${CONFIG_PATH}")
    findings_path=$(yq eval ".monitoring.\"${project}\".findingsPath" "${CONFIG_PATH}")
    
    if [[ ! -d "${logs_path}" ]]; then
        log_error "Logs directory not found: ${logs_path}"
        exit 1
    fi
    
    if [[ ! -d "${findings_path}" ]]; then
        log_error "Findings directory not found: ${findings_path}"
        exit 1
    fi
}

get_unreviewed_logs() {
    local project="$1"
    local logs_path
    logs_path=$(yq eval ".monitoring.\"${project}\".logsPath" "${CONFIG_PATH}")
    
    local unreviewed_logs=()
    
    if [[ -d "${logs_path}" ]]; then
        for log_file in "${logs_path}"/log-*.md; do
            if [[ -f "${log_file}" ]]; then
                # Check if reviewed: false in front matter
                if grep -q "reviewed: false" "${log_file}"; then
                    unreviewed_logs+=("$(basename "${log_file}")")
                fi
            fi
        done
    fi
    
    printf '%s\n' "${unreviewed_logs[@]}"
}

get_unreviewed_findings() {
    local project="$1"
    local findings_path
    findings_path=$(yq eval ".monitoring.\"${project}\".findingsPath" "${CONFIG_PATH}")
    
    local unreviewed_findings=()
    
    if [[ -d "${findings_path}" ]]; then
        for finding_file in "${findings_path}"/finding-*.md; do
            if [[ -f "${finding_file}" ]]; then
                # Check if reviewed: false in front matter
                if grep -q "reviewed: false" "${finding_file}"; then
                    unreviewed_findings+=("$(basename "${finding_file}")")
                fi
            fi
        done
    fi
    
    printf '%s\n' "${unreviewed_findings[@]}"
}

mark_file_as_reviewed() {
    local file_path="$1"
    local reviewer="$2"
    local review_date
    review_date=$(date -u "+%Y-%m-%d")
    
    # Create temporary file for editing
    local temp_file
    temp_file=$(mktemp)
    
    # Update front matter line by line
    while IFS= read -r line; do
        case "${line}" in
            "reviewed: false")
                echo "reviewed: true"
                ;;
            "reviewedBy: null")
                echo "reviewedBy: \"${reviewer}\""
                ;;
            "reviewedDate: null")
                echo "reviewedDate: \"${review_date}\""
                ;;
            *)
                echo "${line}"
                ;;
        esac
    done < "${file_path}" > "${temp_file}"
    
    # Replace original file
    mv "${temp_file}" "${file_path}"
}

mark_items_as_reviewed() {
    local project="$1"
    local reviewer="$2"
    local logs_path findings_path
    logs_path=$(yq eval ".monitoring.\"${project}\".logsPath" "${CONFIG_PATH}")
    findings_path=$(yq eval ".monitoring.\"${project}\".findingsPath" "${CONFIG_PATH}")
    
    local marked_count=0
    
    # Mark unreviewed logs
    if [[ -d "${logs_path}" ]]; then
        for log_file in "${logs_path}"/log-*.md; do
            if [[ -f "${log_file}" ]]; then
                if grep -q "reviewed: false" "${log_file}"; then
                    mark_file_as_reviewed "${log_file}" "${reviewer}"
                    log_info "Marked as reviewed: $(basename "${log_file}")"
                    ((marked_count++))
                fi
            fi
        done
    fi
    
    # Mark unreviewed findings
    if [[ -d "${findings_path}" ]]; then
        for finding_file in "${findings_path}"/finding-*.md; do
            if [[ -f "${finding_file}" ]]; then
                if grep -q "reviewed: false" "${finding_file}"; then
                    mark_file_as_reviewed "${finding_file}" "${reviewer}"
                    log_info "Marked as reviewed: $(basename "${finding_file}")"
                    ((marked_count++))
                fi
            fi
        done
    fi
    
    echo
    log_info "Total items marked as reviewed: ${marked_count}"
}

show_review_status() {
    local project="$1"
    
    log_info "Monitoring Review — ${project}"
    echo
    
    # Get unreviewed items
    local unreviewed_logs unreviewed_findings
    mapfile -t unreviewed_logs < <(get_unreviewed_logs "${project}")
    mapfile -t unreviewed_findings < <(get_unreviewed_findings "${project}")
    
    # Show unreviewed logs
    if [[ ${#unreviewed_logs[@]} -gt 0 ]]; then
        echo "🔍 Unreviewed logs:"
        for log in "${unreviewed_logs[@]}"; do
            echo "  - ${log}"
        done
        echo
    fi
    
    # Show unreviewed findings
    if [[ ${#unreviewed_findings[@]} -gt 0 ]]; then
        echo "📋 Unreviewed findings:"
        for finding in "${unreviewed_findings[@]}"; do
            echo "  - ${finding}"
        done
        echo
    fi
    
    # Show summary
    if [[ ${#unreviewed_logs[@]} -eq 0 && ${#unreviewed_findings[@]} -eq 0 ]]; then
        log_info "✅ All items reviewed"
    else
        local total_unreviewed=$((${#unreviewed_logs[@]} + ${#unreviewed_findings[@]}))
        log_info "📊 Summary: ${total_unreviewed} items need review"
        echo
        log_info "To mark as reviewed: monitoring-review.sh --project ${project} --mark-reviewed"
    fi
}

main() {
    local project=""
    local mark_reviewed=false
    local reviewer
    reviewer=$(git config user.name 2>/dev/null || echo "Unknown")
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --project)
                project="$2"
                shift 2
                ;;
            --mark-reviewed)
                mark_reviewed=true
                shift
                ;;
            --reviewer)
                reviewer="$2"
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
    
    # Validate environment and project
    validate_requirements
    validate_project "${project}"
    
    # Execute review action
    if [[ "${mark_reviewed}" == true ]]; then
        mark_items_as_reviewed "${project}" "${reviewer}"
    else
        show_review_status "${project}"
    fi
}

main "$@"
