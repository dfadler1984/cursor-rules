#!/usr/bin/env bash
# Test: monitoring-finding-create.sh
# Purpose: Test monitoring finding creation script

set -euo pipefail

# Source test helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/.lib.sh"

# Test configuration
TEST_PROJECT="test-monitoring-project"
TEST_TITLE="test-pattern-name"
TEST_WORKSPACE_DIR=""

setup_test_workspace() {
    TEST_WORKSPACE_DIR="$(mktemp -d)"
    
    # Create test project structure
    mkdir -p "${TEST_WORKSPACE_DIR}/docs/projects/${TEST_PROJECT}/monitoring/findings"
    
    # Create test active-monitoring.yaml
    cat > "${TEST_WORKSPACE_DIR}/docs/active-monitoring.yaml" << 'EOF'
version: "1.0"
lastUpdated: "2025-10-27"

monitoring:
  test-monitoring-project:
    status: active
    started: "2025-10-27"
    duration: "1 week"
    endDate: "2025-11-03"
    logsPath: "docs/projects/test-monitoring-project/monitoring/logs"
    findingsPath: "docs/projects/test-monitoring-project/monitoring/findings"
    scope:
      - "Test monitoring scope"
    monitors:
      - "Test monitoring target"
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
    output=$("${SCRIPT_DIR}/monitoring-finding-create.sh" --help 2>&1) || true
    
    if [[ "${output}" =~ "Usage:" ]]; then
        echo "✓ --help flag shows usage"
    else
        echo "✗ --help flag failed"
        echo "Output: ${output}"
        return 1
    fi
    
    # Test -h flag
    local output_short
    output_short=$("${SCRIPT_DIR}/monitoring-finding-create.sh" -h 2>&1) || true
    
    if [[ "${output_short}" =~ "Usage:" ]]; then
        echo "✓ -h flag shows usage"
    else
        echo "✗ -h flag failed"
        echo "Output: ${output_short}"
        return 1
    fi
}

test_missing_project_flag() {
    echo "=== Test: Missing project flag ==="
    
    local output exit_code
    output=$("${SCRIPT_DIR}/monitoring-finding-create.sh" --title "test" 2>&1) || exit_code=$?
    
    if [[ "${exit_code:-0}" -ne 0 && "${output}" =~ "--project" ]]; then
        echo "✓ Missing project flag handled correctly"
    else
        echo "✗ Missing project flag not handled"
        echo "Output: ${output}"
        return 1
    fi
}

test_missing_title_flag() {
    echo "=== Test: Missing title flag ==="
    
    local output exit_code
    output=$("${SCRIPT_DIR}/monitoring-finding-create.sh" --project "${TEST_PROJECT}" 2>&1) || exit_code=$?
    
    if [[ "${exit_code:-0}" -ne 0 && "${output}" =~ "--title" ]]; then
        echo "✓ Missing title flag handled correctly"
    else
        echo "✗ Missing title flag not handled"
        echo "Output: ${output}"
        return 1
    fi
}

test_invalid_project() {
    echo "=== Test: Invalid project ==="
    
    setup_test_workspace
    cd "${TEST_WORKSPACE_DIR}"
    
    local output exit_code
    output=$("${SCRIPT_DIR}/monitoring-finding-create.sh" --project "nonexistent-project" --title "test" 2>&1) || exit_code=$?
    
    if [[ "${exit_code:-0}" -ne 0 && "${output}" =~ "not found in active-monitoring.yaml" ]]; then
        echo "✓ Invalid project handled correctly"
    else
        echo "✗ Invalid project not handled"
        echo "Output: ${output}"
        cleanup_test_workspace
        return 1
    fi
    
    cleanup_test_workspace
}

test_successful_finding_creation() {
    echo "=== Test: Successful finding creation ==="
    
    setup_test_workspace
    cd "${TEST_WORKSPACE_DIR}"
    
    # Run the script
    local output
    output=$("${SCRIPT_DIR}/monitoring-finding-create.sh" --project "${TEST_PROJECT}" --title "${TEST_TITLE}" 2>&1)
    
    # Check if finding file was created
    local finding_file
    finding_file=$(find "${TEST_WORKSPACE_DIR}/docs/projects/${TEST_PROJECT}/monitoring/findings" -name "finding-001-*.md" 2>/dev/null | head -1)
    
    if [[ -f "${finding_file}" ]]; then
        echo "✓ Finding file created: $(basename "${finding_file}")"
        
        # Check front matter
        if grep -q "findingId: 1" "${finding_file}"; then
            echo "✓ Front matter contains findingId"
        else
            echo "✗ Front matter missing findingId"
            cleanup_test_workspace
            return 1
        fi
        
        # Check date format
        if grep -q "date: \"[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\"" "${finding_file}"; then
            echo "✓ Date format correct"
        else
            echo "✗ Date format incorrect"
            cleanup_test_workspace
            return 1
        fi
        
        # Check project field
        if grep -q "project: \"${TEST_PROJECT}\"" "${finding_file}"; then
            echo "✓ Project field correct"
        else
            echo "✗ Project field incorrect"
            cleanup_test_workspace
            return 1
        fi
        
        # Check title content
        if grep -q "${TEST_TITLE}" "${finding_file}"; then
            echo "✓ Title content included"
        else
            echo "✗ Title content missing"
            cleanup_test_workspace
            return 1
        fi
        
    else
        echo "✗ Finding file not created"
        echo "Output: ${output}"
        cleanup_test_workspace
        return 1
    fi
    
    cleanup_test_workspace
}

test_finding_counter_increment() {
    echo "=== Test: Finding counter increment ==="
    
    setup_test_workspace
    cd "${TEST_WORKSPACE_DIR}"
    
    # Create first finding
    "${SCRIPT_DIR}/monitoring-finding-create.sh" --project "${TEST_PROJECT}" --title "first-pattern" >/dev/null 2>&1
    
    # Create second finding
    "${SCRIPT_DIR}/monitoring-finding-create.sh" --project "${TEST_PROJECT}" --title "second-pattern" >/dev/null 2>&1
    
    # Check both files exist with correct IDs
    local finding1 finding2
    finding1=$(find "${TEST_WORKSPACE_DIR}/docs/projects/${TEST_PROJECT}/monitoring/findings" -name "finding-001-*.md" 2>/dev/null | head -1)
    finding2=$(find "${TEST_WORKSPACE_DIR}/docs/projects/${TEST_PROJECT}/monitoring/findings" -name "finding-002-*.md" 2>/dev/null | head -1)
    
    if [[ -f "${finding1}" && -f "${finding2}" ]]; then
        echo "✓ Both finding files created with incremented IDs"
        
        # Verify findingId in front matter
        if grep -q "findingId: 1" "${finding1}" && grep -q "findingId: 2" "${finding2}"; then
            echo "✓ FindingId incremented correctly in front matter"
        else
            echo "✗ FindingId not incremented correctly"
            cleanup_test_workspace
            return 1
        fi
    else
        echo "✗ Finding files not created with correct IDs"
        cleanup_test_workspace
        return 1
    fi
    
    cleanup_test_workspace
}

test_severity_and_status_defaults() {
    echo "=== Test: Severity and status defaults ==="
    
    setup_test_workspace
    cd "${TEST_WORKSPACE_DIR}"
    
    # Create finding with defaults
    "${SCRIPT_DIR}/monitoring-finding-create.sh" --project "${TEST_PROJECT}" --title "default-test" >/dev/null 2>&1
    
    local finding_file
    finding_file=$(find "${TEST_WORKSPACE_DIR}/docs/projects/${TEST_PROJECT}/monitoring/findings" -name "finding-001-*.md" 2>/dev/null | head -1)
    
    if [[ -f "${finding_file}" ]]; then
        # Check default severity
        if grep -q "severity: \"medium\"" "${finding_file}"; then
            echo "✓ Default severity is medium"
        else
            echo "✗ Default severity incorrect"
            cleanup_test_workspace
            return 1
        fi
        
        # Check default status
        if grep -q "status: \"open\"" "${finding_file}"; then
            echo "✓ Default status is open"
        else
            echo "✗ Default status incorrect"
            cleanup_test_workspace
            return 1
        fi
        
        # Check reviewed defaults to false
        if grep -q "reviewed: false" "${finding_file}"; then
            echo "✓ Default reviewed is false"
        else
            echo "✗ Default reviewed incorrect"
            cleanup_test_workspace
            return 1
        fi
    else
        echo "✗ Finding file not created"
        cleanup_test_workspace
        return 1
    fi
    
    cleanup_test_workspace
}

# Run tests
main() {
    echo "Running monitoring-finding-create.sh tests..."
    echo
    
    local failed=0
    
    test_help_flag || ((failed++))
    test_missing_project_flag || ((failed++))
    test_missing_title_flag || ((failed++))
    test_invalid_project || ((failed++))
    test_successful_finding_creation || ((failed++))
    test_finding_counter_increment || ((failed++))
    test_severity_and_status_defaults || ((failed++))
    
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






