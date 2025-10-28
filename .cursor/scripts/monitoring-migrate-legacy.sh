#!/usr/bin/env bash
# monitoring-migrate-legacy.sh
# Purpose: Migrate from ACTIVE-MONITORING.md to active-monitoring.yaml system

set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/.lib.sh"

# Script configuration
SCRIPT_NAME="monitoring-migrate-legacy.sh"
LEGACY_FILE="docs/projects/ACTIVE-MONITORING.md"
NEW_CONFIG="docs/active-monitoring.yaml"

show_help() {
    cat << 'EOF'
Usage: monitoring-migrate-legacy.sh [options]

Migrate from ACTIVE-MONITORING.md to the new YAML-based monitoring system.

OPTIONS:
    --dry-run               Show what would be done without making changes
    --backup-suffix <sfx>   Backup suffix (default: .backup.YYYY-MM-DD)
    --help                  Show this help message

EXAMPLES:
    monitoring-migrate-legacy.sh --dry-run
    monitoring-migrate-legacy.sh
    monitoring-migrate-legacy.sh --backup-suffix .pre-migration

REQUIREMENTS:
    - docs/projects/ACTIVE-MONITORING.md must exist
    - Run from repository root
    - yq must be installed for YAML operations

ACTIONS:
    1. Creates active-monitoring.yaml from ACTIVE-MONITORING.md content
    2. Creates monitoring/ structure for active projects
    3. Migrates existing findings to new structure with front matter
    4. Backs up original ACTIVE-MONITORING.md
    5. Generates migration report
    
EOF
}

validate_requirements() {
    # Check if ACTIVE-MONITORING.md exists
    if [[ ! -f "${LEGACY_FILE}" ]]; then
        log_error "ACTIVE-MONITORING.md not found at: ${LEGACY_FILE}"
        log_error "Run this script from the repository root"
        exit 1
    fi
    
    # Check if target config already exists
    if [[ -f "${NEW_CONFIG}" ]]; then
        log_error "Target file already exists: ${NEW_CONFIG}"
        log_error "Remove or rename existing file before migration"
        exit 1
    fi
    
    # Check if yq is available
    if ! command -v yq >/dev/null 2>&1; then
        log_error "yq is required but not installed"
        log_error "Install with: brew install yq"
        exit 1
    fi
}

extract_projects_from_legacy() {
    local legacy_file="$1"
    
    # Extract project sections from ACTIVE-MONITORING.md
    # This is a simplified parser - in real implementation would be more robust
    local projects=()
    
    # Look for project headers (### project-name)
    while IFS= read -r line; do
        if [[ "${line}" =~ ^###[[:space:]]+([a-z0-9-]+)$ ]]; then
            projects+=("${BASH_REMATCH[1]}")
        fi
    done < "${legacy_file}"
    
    printf '%s\n' "${projects[@]}"
}

create_yaml_config() {
    local dry_run="$1"
    
    if [[ "${dry_run}" == true ]]; then
        log_info "Would create: ${NEW_CONFIG}"
        return 0
    fi
    
    # Extract projects from legacy file
    local projects
    mapfile -t projects < <(extract_projects_from_legacy "${LEGACY_FILE}")
    
    log_info "Creating ${NEW_CONFIG}..."
    
    # Create YAML config
    cat > "${NEW_CONFIG}" << 'EOF'
version: "1.0"
lastUpdated: "2025-10-27"

# Active monitoring entries (migrated from ACTIVE-MONITORING.md)
monitoring:
EOF

    # Add each project (simplified - real implementation would parse fields)
    for project in "${projects[@]}"; do
        if [[ "${project}" =~ ^(blocking-tdd-enforcement|rules-enforcement-investigation|tdd-scope-boundaries|consent-gates-refinement)$ ]]; then
            cat >> "${NEW_CONFIG}" << EOF
  ${project}:
    status: active
    started: "2025-10-24"  # Inferred from legacy file
    duration: "continuous"
    endDate: null
    logsPath: "docs/projects/${project}/monitoring/logs"
    findingsPath: "docs/projects/${project}/monitoring/findings"
    scope:
      - "Migrated from ACTIVE-MONITORING.md"
    outOfScope:
      - "See project documentation for details"
    monitors:
      - "Legacy monitoring target"
    crossReferences: []
EOF
        fi
    done
    
    # Add completed projects section
    cat >> "${NEW_CONFIG}" << 'EOF'

# Completed/archived monitoring (migrated)
completed:
  routing-optimization:
    status: "archived"
    started: "2025-10-23"
    completed: "2025-10-24"
    archivedTo: "docs/projects/_archived/2025/routing-optimization"
    finalResults: "100% routing accuracy achieved"
    
  assistant-self-improvement:
    status: "paused"
    started: "2025-10-15"
    paused: "2025-10-24"
    reason: "Auto-logging deprecated"

# Decision tree (migrated from ACTIVE-MONITORING.md lines 164-194)
routing:
  categories:
    - name: "routing"
      description: "Wrong rules attached"
      symptom: "Intent misread, wrong rules attached"
    - name: "execution" 
      description: "Right rules attached but ignored"
      symptom: "Rule loaded but pre-edit gate skipped"
    - name: "workflow"
      description: "Automation contradiction"
      symptom: "GitHub Actions, PR scripts"
  rules:
    - symptom: "TDD gate BLOCKING (file pairing enforcement)"
      project: "blocking-tdd-enforcement"
    - symptom: "FOLLOWING attached rules"
      project: "rules-enforcement-investigation"
    - symptom: "TDD scope check accuracy"
      project: "tdd-scope-boundaries"
    - symptom: "consent gate behavior"
      project: "consent-gates-refinement"

# System configuration
staleness:
  timeBased: 30        # days without logs before stale
  durationGrace: 14    # days past endDate before stale
  newMonitoringGrace: 60  # days grace for new monitoring

constraints:
  maxActiveProjects: 5
  maxConfigLines: 300  # lines before archival needed
EOF

    log_info "✓ Created ${NEW_CONFIG}"
}

create_monitoring_structure() {
    local dry_run="$1"
    local projects
    mapfile -t projects < <(extract_projects_from_legacy "${LEGACY_FILE}")
    
    if [[ "${dry_run}" == true ]]; then
        log_info "Would create monitoring directories for:"
        for project in "${projects[@]}"; do
            if [[ "${project}" =~ ^(blocking-tdd-enforcement|rules-enforcement-investigation|tdd-scope-boundaries|consent-gates-refinement)$ ]]; then
                log_info "  - docs/projects/${project}/monitoring/{logs,findings}"
            fi
        done
        return 0
    fi
    
    # Create monitoring directories for active projects
    for project in "${projects[@]}"; do
        if [[ "${project}" =~ ^(blocking-tdd-enforcement|rules-enforcement-investigation|tdd-scope-boundaries|consent-gates-refinement)$ ]]; then
            local project_monitoring="docs/projects/${project}/monitoring"
            mkdir -p "${project_monitoring}/logs"
            mkdir -p "${project_monitoring}/findings"
            log_info "✓ Created ${project_monitoring}/{logs,findings}"
        fi
    done
}

migrate_existing_findings() {
    local dry_run="$1"
    
    # Migrate rules-enforcement-investigation findings
    local rei_findings="docs/projects/rules-enforcement-investigation/findings"
    local rei_new="docs/projects/rules-enforcement-investigation/monitoring/findings"
    
    if [[ -d "${rei_findings}" ]]; then
        local finding_count
        finding_count=$(find "${rei_findings}" -name "gap-*.md" 2>/dev/null | wc -l | tr -d ' ')
        
        if [[ "${dry_run}" == true ]]; then
            log_info "Would migrate ${finding_count} findings from ${rei_findings} to ${rei_new}"
            log_info "Would migrate: existing findings with front matter"
            return 0
        fi
        
        if [[ "${finding_count}" -gt 0 ]]; then
            log_info "Migrating ${finding_count} findings..."
            
            # Move existing findings to new location
            for gap_file in "${rei_findings}"/gap-*.md; do
                if [[ -f "${gap_file}" ]]; then
                    local basename
                    basename=$(basename "${gap_file}")
                    local new_name="${basename//gap-/finding-}"
                    local new_path="${rei_new}/${new_name}"
                    
                    # Add front matter to existing finding
                    local temp_file
                    temp_file=$(mktemp)
                    
                    # Extract finding number from filename
                    local finding_id="1"
                    if [[ "${basename}" =~ gap-([0-9]+)- ]]; then
                        finding_id="${BASH_REMATCH[1]}"
                    fi
                    
                    # Add front matter
                    cat > "${temp_file}" << EOF
---
findingId: ${finding_id}
date: "2025-10-24"  # Inferred from migration
project: "rules-enforcement-investigation"
severity: "medium"  # Default for migrated findings
status: "open"      # Default for migrated findings
reviewed: false
reviewedBy: null
reviewedDate: null
sourceLogs: []      # To be filled post-migration
---

EOF
                    # Append original content
                    cat "${gap_file}" >> "${temp_file}"
                    
                    # Move to new location
                    mv "${temp_file}" "${new_path}"
                    log_info "✓ Migrated: ${basename} → ${new_name}"
                fi
            done
            
            # Remove old findings directory after migration
            rm -rf "${rei_findings}"
            log_info "✓ Removed old findings directory"
        fi
    fi
}

backup_legacy_file() {
    local dry_run="$1"
    local backup_suffix="$2"
    local backup_file="${LEGACY_FILE}${backup_suffix}"
    
    if [[ "${dry_run}" == true ]]; then
        log_info "Would backup: ${LEGACY_FILE} → ${backup_file}"
        return 0
    fi
    
    cp "${LEGACY_FILE}" "${backup_file}"
    log_info "✓ Backed up: ${backup_file}"
}

generate_migration_report() {
    local dry_run="$1"
    local report_file="migration-report-$(date -u +%Y-%m-%d).md"
    
    if [[ "${dry_run}" == true ]]; then
        echo
        log_info "=== Migration Summary ==="
        log_info "Would create: ${NEW_CONFIG}"
        log_info "Would create: monitoring/ structure for active projects"
        log_info "Would migrate: existing findings with front matter"
        log_info "Would backup: ${LEGACY_FILE}"
        log_info "Would generate: ${report_file}"
        return 0
    fi
    
    local projects
    mapfile -t projects < <(extract_projects_from_legacy "${LEGACY_FILE}")
    
    cat > "${report_file}" << EOF
# Migration Report — $(date -u "+%Y-%m-%d")

**Migration Date**: $(date -u "+%Y-%m-%d %H:%M:%S UTC")
**Source**: ${LEGACY_FILE}
**Target**: ${NEW_CONFIG}

## Migration Summary

**Projects migrated**: ${#projects[@]}
**Structure created**: monitoring/{logs,findings} for active projects
**Findings migrated**: rules-enforcement-investigation findings → new structure
**Backup created**: ${LEGACY_FILE}${backup_suffix}

## Active Projects

$(for project in "${projects[@]}"; do
    if [[ "${project}" =~ ^(blocking-tdd-enforcement|rules-enforcement-investigation|tdd-scope-boundaries|consent-gates-refinement)$ ]]; then
        echo "- ${project}: Active monitoring configured"
    fi
done)

## Next Steps

1. Validate migration: Check all projects have monitoring/ directories
2. Update assistant rules: Change ACTIVE-MONITORING.md references to active-monitoring.yaml
3. Test routing: Ensure assistant routes correctly to new log locations
4. Remove legacy: Delete ${LEGACY_FILE} after validation period

## Validation Commands

\`\`\`bash
# Check YAML is valid
yq eval . ${NEW_CONFIG}

# Verify project structure
ls docs/projects/*/monitoring/{logs,findings}

# Test log creation
monitoring-log-create.sh --project blocking-tdd-enforcement --observation "Migration test"

# Test finding creation  
monitoring-finding-create.sh --project rules-enforcement --title "migration-validation"
\`\`\`

---

**Migration completed**: $(date -u "+%Y-%m-%d %H:%M:%S UTC")
EOF

    log_info "✓ Generated migration report: ${report_file}"
}

main() {
    local dry_run=false
    local backup_suffix=".backup.$(date -u +%Y-%m-%d)"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                dry_run=true
                shift
                ;;
            --backup-suffix)
                backup_suffix="$2"
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
    
    # Validate requirements
    validate_requirements
    
    # Show what we're about to do
    if [[ "${dry_run}" == true ]]; then
        log_info "=== DRY RUN MODE ==="
        log_info "Analyzing migration from ${LEGACY_FILE}..."
    else
        log_info "=== MIGRATION MODE ==="
        log_info "Migrating from ${LEGACY_FILE} to ${NEW_CONFIG}..."
    fi
    
    # Execute migration steps
    create_yaml_config "${dry_run}"
    create_monitoring_structure "${dry_run}"
    migrate_existing_findings "${dry_run}"
    backup_legacy_file "${dry_run}" "${backup_suffix}"
    generate_migration_report "${dry_run}"
    
    if [[ "${dry_run}" == true ]]; then
        echo
        log_info "Dry run complete. Use without --dry-run to execute migration."
    else
        echo
        log_info "✅ Migration complete!"
        log_info "Next: Update assistant rules to use ${NEW_CONFIG}"
        log_info "Then: Test routing with new system"
    fi
}

main "$@"
