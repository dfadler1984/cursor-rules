#!/usr/bin/env bash
# Test: monitoring-migrate-legacy.sh
# Purpose: Test migration from ACTIVE-MONITORING.md to YAML system

set -euo pipefail

# Source test helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/.lib.sh"

# Test configuration
TEST_WORKSPACE_DIR=""

setup_test_workspace() {
    TEST_WORKSPACE_DIR="$(mktemp -d)"
    
    # Create test project structure with existing findings
    mkdir -p "${TEST_WORKSPACE_DIR}/docs/projects/rules-enforcement-investigation/findings"
    mkdir -p "${TEST_WORKSPACE_DIR}/docs/projects/blocking-tdd-enforcement"
    
    # Create sample ACTIVE-MONITORING.md
    cat > "${TEST_WORKSPACE_DIR}/docs/projects/ACTIVE-MONITORING.md" << 'EOF'
# Active Project Monitoring

## Currently Active Monitoring

### blocking-tdd-enforcement

| **Field**           | **Value**                                                    |
| ------------------- | ------------------------------------------------------------ |
| **Status**          | 🔄 Active (Phase 2-3: user testing + monitoring)            |
| **Started**         | 2025-10-24                                                   |
| **Duration**        | 1 week (ends ~2025-10-31)                                   |
| **Findings Path**   | `docs/projects/blocking-tdd-enforcement/` (inline in README) |
| **Pattern**         | Document violations/issues inline in monitoring sections     |
| **Scope**           | TDD gate blocking effectiveness                               |

### rules-enforcement-investigation

| **Field**           | **Value**                                                    |
| ------------------- | ------------------------------------------------------------ |
| **Status**          | ✅ Complete (Active) — Ongoing execution monitoring          |
| **Started**         | 2025-10-15                                                   |
| **Duration**        | Continuous (no end date)                                     |
| **Findings Path**   | `docs/projects/rules-enforcement-investigation/findings/`    |
| **Pattern**         | `gap-##-<short-name>.md` (individual files, numbered)       |
| **Scope**           | Rule execution and compliance                                |
EOF

    # Create sample existing findings
    cat > "${TEST_WORKSPACE_DIR}/docs/projects/rules-enforcement-investigation/findings/gap-01-test-finding.md" << 'EOF'
# Gap #1: Test Finding

**Date**: 2025-10-24
**Category**: execution

Test finding content.
EOF

    cat > "${TEST_WORKSPACE_DIR}/docs/projects/rules-enforcement-investigation/findings/gap-02-another-finding.md" << 'EOF'
# Gap #2: Another Finding

**Date**: 2025-10-25
**Category**: workflow

Another test finding.
EOF
}

cleanup_test_workspace() {
    if [[ -n "${TEST_WORKSPACE_DIR}" && -d "${TEST_WORKSPACE_DIR}" ]]; then
        rm -rf "${TEST_WORKSPACE_DIR}"
    fi
}

test_help_flag() {
    echo "=== Test: Help flag ==="
    
    # Test --help flag
    local output
    output=$("${SCRIPT_DIR}/monitoring-migrate-legacy.sh" --help 2>&1) || true
    
    if [[ "${output}" =~ "Usage:" ]]; then
        echo "✓ --help flag shows usage"
    else
        echo "✗ --help flag failed"
        echo "Output: ${output}"
        return 1
    fi
    
    # Test -h flag
    local output_short
    output_short=$("${SCRIPT_DIR}/monitoring-migrate-legacy.sh" -h 2>&1) || true
    
    if [[ "${output_short}" =~ "Usage:" ]]; then
        echo "✓ -h flag shows usage"
    else
        echo "✗ -h flag failed"
        echo "Output: ${output_short}"
        return 1
    fi
}

test_missing_active_monitoring() {
    echo "=== Test: Missing ACTIVE-MONITORING.md ==="
    
    local temp_dir
    temp_dir=$(mktemp -d)
    cd "${temp_dir}"
    
    local output exit_code
    output=$("${SCRIPT_DIR}/monitoring-migrate-legacy.sh" 2>&1) || exit_code=$?
    
    if [[ "${exit_code:-0}" -ne 0 && "${output}" =~ "ACTIVE-MONITORING.md not found" ]]; then
        echo "✓ Missing ACTIVE-MONITORING.md handled correctly"
    else
        echo "✗ Missing ACTIVE-MONITORING.md not handled"
        echo "Output: ${output}"
        rm -rf "${temp_dir}"
        return 1
    fi
    
    rm -rf "${temp_dir}"
}

test_yaml_creation() {
    echo "=== Test: YAML config creation ==="
    
    setup_test_workspace
    cd "${TEST_WORKSPACE_DIR}"
    
    # Run migration
    local output
    output=$("${SCRIPT_DIR}/monitoring-migrate-legacy.sh" --dry-run 2>&1)
    
    if [[ "${output}" =~ "Would create: docs/active-monitoring.yaml" ]]; then
        echo "✓ YAML creation planned"
    else
        echo "✗ YAML creation not planned"
        echo "Output: ${output}"
        cleanup_test_workspace
        return 1
    fi
    
    cleanup_test_workspace
}

test_structure_creation() {
    echo "=== Test: Monitoring structure creation ==="
    
    setup_test_workspace
    cd "${TEST_WORKSPACE_DIR}"
    
    # Run migration (dry-run)
    local output
    output=$("${SCRIPT_DIR}/monitoring-migrate-legacy.sh" --dry-run 2>&1)
    
    if [[ "${output}" =~ "Would create monitoring directories" ]]; then
        echo "✓ Structure creation planned"
    else
        echo "✗ Structure creation not planned"
        echo "Output: ${output}"
        cleanup_test_workspace
        return 1
    fi
    
    cleanup_test_workspace
}

test_findings_migration() {
    echo "=== Test: Findings migration ==="
    
    setup_test_workspace
    cd "${TEST_WORKSPACE_DIR}"
    
    # Run migration (dry-run)
    local output
    output=$("${SCRIPT_DIR}/monitoring-migrate-legacy.sh" --dry-run 2>&1)
    
    # Check for any migration-related output (more flexible pattern)
    if [[ "${output}" =~ "findings" && "${output}" =~ "migrate" ]]; then
        echo "✓ Findings migration planned"
    else
        echo "✗ Findings migration not planned"
        echo "Output: ${output}"
        cleanup_test_workspace
        return 1
    fi
    
    cleanup_test_workspace
}

test_migration_report() {
    echo "=== Test: Migration report generation ==="
    
    setup_test_workspace
    cd "${TEST_WORKSPACE_DIR}"
    
    # Run migration (dry-run)
    local output
    output=$("${SCRIPT_DIR}/monitoring-migrate-legacy.sh" --dry-run 2>&1)
    
    if [[ "${output}" =~ "Migration Summary" ]]; then
        echo "✓ Migration report included"
    else
        echo "✗ Migration report missing"
        echo "Output: ${output}"
        cleanup_test_workspace
        return 1
    fi
    
    cleanup_test_workspace
}

test_backup_creation() {
    echo "=== Test: Backup creation ==="
    
    setup_test_workspace
    cd "${TEST_WORKSPACE_DIR}"
    
    # Run migration (dry-run)
    local output
    output=$("${SCRIPT_DIR}/monitoring-migrate-legacy.sh" --dry-run 2>&1)
    
    if echo "${output}" | grep -q "Would backup.*ACTIVE-MONITORING.md"; then
        echo "✓ Backup creation planned"
    else
        echo "✗ Backup creation not planned"
        echo "Output: ${output}"
        cleanup_test_workspace
        return 1
    fi
    
    cleanup_test_workspace
}

# Run tests
main() {
    echo "Running monitoring-migrate-legacy.sh tests..."
    echo
    
    local failed=0
    
    test_help_flag || ((failed++))
    test_missing_active_monitoring || ((failed++))
    test_yaml_creation || ((failed++))
    test_structure_creation || ((failed++))
    test_findings_migration || ((failed++))
    test_migration_report || ((failed++))
    test_backup_creation || ((failed++))
    
    echo
    if [[ "${failed}" -eq 0 ]]; then
        echo "✅ All tests passed!"
        exit 0
    else
        echo "❌ ${failed} test(s) failed"
        exit 1
    fi
}

# Cleanup on exit
trap cleanup_test_workspace EXIT

main "$@"
