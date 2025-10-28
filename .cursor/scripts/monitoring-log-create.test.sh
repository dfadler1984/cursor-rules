#!/usr/bin/env bash
# Test: monitoring-log-create.sh
# Purpose: Test monitoring log creation script

set -euo pipefail

# Source test helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/.lib.sh"

# Test configuration
TEST_PROJECT="test-monitoring-project"
TEST_OBSERVATION="Test observation for monitoring"
TEST_WORKSPACE_DIR=""

setup_test_workspace() {
    TEST_WORKSPACE_DIR="$(mktemp -d)"
    
    # Create test project structure
    mkdir -p "${TEST_WORKSPACE_DIR}/docs/projects/${TEST_PROJECT}/monitoring/logs"
    
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
    output=$("${SCRIPT_DIR}/monitoring-log-create.sh" --help 2>&1) || true
    
    if [[ "${output}" =~ "Usage:" ]]; then
        echo "✓ --help flag shows usage"
    else
        echo "✗ --help flag failed"
        echo "Output: ${output}"
        return 1
    fi
    
    # Test -h flag
    local output_short
    output_short=$("${SCRIPT_DIR}/monitoring-log-create.sh" -h 2>&1) || true
    
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
    output=$("${SCRIPT_DIR}/monitoring-log-create.sh" --observation "test" 2>&1) || exit_code=$?
    
    if [[ "${exit_code:-0}" -ne 0 && "${output}" =~ "--project" ]]; then
        echo "✓ Missing project flag handled correctly"
    else
        echo "✗ Missing project flag not handled"
        echo "Output: ${output}"
        return 1
    fi
}

test_missing_observation_flag() {
    echo "=== Test: Missing observation flag ==="
    
    local output exit_code
    output=$("${SCRIPT_DIR}/monitoring-log-create.sh" --project "${TEST_PROJECT}" 2>&1) || exit_code=$?
    
    if [[ "${exit_code:-0}" -ne 0 && "${output}" =~ "--observation" ]]; then
        echo "✓ Missing observation flag handled correctly"
    else
        echo "✗ Missing observation flag not handled"
        echo "Output: ${output}"
        return 1
    fi
}

test_invalid_project() {
    echo "=== Test: Invalid project ==="
    
    setup_test_workspace
    cd "${TEST_WORKSPACE_DIR}"
    
    local output exit_code
    output=$("${SCRIPT_DIR}/monitoring-log-create.sh" --project "nonexistent-project" --observation "test" 2>&1) || exit_code=$?
    
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

test_successful_log_creation() {
    echo "=== Test: Successful log creation ==="
    
    setup_test_workspace
    cd "${TEST_WORKSPACE_DIR}"
    
    # Run the script
    local output
    output=$("${SCRIPT_DIR}/monitoring-log-create.sh" --project "${TEST_PROJECT}" --observation "${TEST_OBSERVATION}" 2>&1)
    
    # Check if log file was created
    local log_file
    log_file=$(find "${TEST_WORKSPACE_DIR}/docs/projects/${TEST_PROJECT}/monitoring/logs" -name "log-001-*.md" 2>/dev/null | head -1)
    
    if [[ -f "${log_file}" ]]; then
        echo "✓ Log file created: $(basename "${log_file}")"
        
        # Check front matter
        if grep -q "logId: 1" "${log_file}"; then
            echo "✓ Front matter contains logId"
        else
            echo "✗ Front matter missing logId"
            cleanup_test_workspace
            return 1
        fi
        
        # Check timestamp format
        if grep -q "timestamp: \"[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\} UTC\"" "${log_file}"; then
            echo "✓ Timestamp format correct"
        else
            echo "✗ Timestamp format incorrect"
            cleanup_test_workspace
            return 1
        fi
        
        # Check project field
        if grep -q "project: \"${TEST_PROJECT}\"" "${log_file}"; then
            echo "✓ Project field correct"
        else
            echo "✗ Project field incorrect"
            cleanup_test_workspace
            return 1
        fi
        
        # Check observation content
        if grep -q "${TEST_OBSERVATION}" "${log_file}"; then
            echo "✓ Observation content included"
        else
            echo "✗ Observation content missing"
            cleanup_test_workspace
            return 1
        fi
        
    else
        echo "✗ Log file not created"
        echo "Output: ${output}"
        cleanup_test_workspace
        return 1
    fi
    
    cleanup_test_workspace
}

test_log_counter_increment() {
    echo "=== Test: Log counter increment ==="
    
    setup_test_workspace
    cd "${TEST_WORKSPACE_DIR}"
    
    # Create first log
    "${SCRIPT_DIR}/monitoring-log-create.sh" --project "${TEST_PROJECT}" --observation "First observation" >/dev/null 2>&1
    
    # Create second log
    "${SCRIPT_DIR}/monitoring-log-create.sh" --project "${TEST_PROJECT}" --observation "Second observation" >/dev/null 2>&1
    
    # Check both files exist with correct IDs
    local log1 log2
    log1=$(find "${TEST_WORKSPACE_DIR}/docs/projects/${TEST_PROJECT}/monitoring/logs" -name "log-001-*.md" 2>/dev/null | head -1)
    log2=$(find "${TEST_WORKSPACE_DIR}/docs/projects/${TEST_PROJECT}/monitoring/logs" -name "log-002-*.md" 2>/dev/null | head -1)
    
    if [[ -f "${log1}" && -f "${log2}" ]]; then
        echo "✓ Both log files created with incremented IDs"
        
        # Verify logId in front matter
        if grep -q "logId: 1" "${log1}" && grep -q "logId: 2" "${log2}"; then
            echo "✓ LogId incremented correctly in front matter"
        else
            echo "✗ LogId not incremented correctly"
            cleanup_test_workspace
            return 1
        fi
    else
        echo "✗ Log files not created with correct IDs"
        cleanup_test_workspace
        return 1
    fi
    
    cleanup_test_workspace
}

test_slug_sanitization() {
    echo "=== Test: Description slug sanitization ==="
    
    setup_test_workspace
    cd "${TEST_WORKSPACE_DIR}"
    
    local special_observation="Test with spaces & special chars!"
    
    # Create log with special characters
    "${SCRIPT_DIR}/monitoring-log-create.sh" --project "${TEST_PROJECT}" --observation "${special_observation}" >/dev/null 2>&1
    
    # Check if filename is sanitized (no spaces or special chars)
    local log_file
    log_file=$(find "${TEST_WORKSPACE_DIR}/docs/projects/${TEST_PROJECT}/monitoring/logs" -name "log-001-test-with-spaces-special-chars.md" 2>/dev/null | head -1)
    
    if [[ -f "${log_file}" ]]; then
        echo "✓ Filename sanitized correctly"
        
        # Check that original observation is preserved in content
        if grep -q "${special_observation}" "${log_file}"; then
            echo "✓ Original observation preserved in content"
        else
            echo "✗ Original observation not preserved"
            cleanup_test_workspace
            return 1
        fi
    else
        echo "✗ Filename not sanitized correctly"
        ls "${TEST_WORKSPACE_DIR}/docs/projects/${TEST_PROJECT}/monitoring/logs/"
        cleanup_test_workspace
        return 1
    fi
    
    cleanup_test_workspace
}

# Run tests
main() {
    echo "Running monitoring-log-create.sh tests..."
    echo
    
    local failed=0
    
    test_help_flag || ((failed++))
    test_missing_project_flag || ((failed++))
    test_missing_observation_flag || ((failed++))
    test_invalid_project || ((failed++))
    test_successful_log_creation || ((failed++))
    test_log_counter_increment || ((failed++))
    test_slug_sanitization || ((failed++))
    
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






