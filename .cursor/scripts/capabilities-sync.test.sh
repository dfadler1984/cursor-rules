#!/usr/bin/env bash
# Tests for capabilities-sync.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUT="$SCRIPT_DIR/capabilities-sync.sh"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Test fixtures
TEMP_DIR=""

setup() {
    TEMP_DIR=$(mktemp -d)
    export TEMP_SCRIPTS_DIR="$TEMP_DIR/scripts"
    export TEMP_CAPABILITIES="$TEMP_DIR/capabilities.mdc"
    mkdir -p "$TEMP_SCRIPTS_DIR"
}

teardown() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Test: --help flag shows usage
test_help_flag() {
    local output
    output=$("$SUT" --help 2>&1)
    
    if ! echo "$output" | grep -q "Usage:"; then
        echo "FAIL: --help should show usage"
        return 1
    fi
    
    if ! echo "$output" | grep -q "capabilities-sync.sh"; then
        echo "FAIL: --help should show script name"
        return 1
    fi
    
    echo "PASS: --help shows usage"
}

# Test: --check mode with all scripts documented returns 0
test_check_all_documented() {
    setup
    
    # Create test scripts
    echo "#!/usr/bin/env bash" > "$TEMP_SCRIPTS_DIR/test-script.sh"
    chmod +x "$TEMP_SCRIPTS_DIR/test-script.sh"
    
    # Create capabilities file that documents the script
    cat > "$TEMP_CAPABILITIES" <<'EOF'
# Test capabilities
- `[.cursor/scripts/test-script.sh](.cursor/scripts/test-script.sh)`: Test script
EOF
    
    # Override paths for testing
    local output exit_code
    cd "$TEMP_DIR"
    if output=$(SCRIPTS_DIR="$TEMP_SCRIPTS_DIR" CAPABILITIES_FILE="$TEMP_CAPABILITIES" bash "$SUT" --check 2>&1); then
        exit_code=0
    else
        exit_code=$?
    fi
    
    teardown
    
    if [ $exit_code -ne 0 ]; then
        echo "FAIL: --check should exit 0 when all scripts documented"
        echo "Output: $output"
        return 1
    fi
    
    if ! echo "$output" | grep -q "All scripts are documented"; then
        echo "FAIL: --check should confirm all scripts documented"
        echo "Output: $output"
        return 1
    fi
    
    echo "PASS: --check with all documented returns 0"
}

# Test: --check mode with missing scripts returns non-zero
test_check_missing_scripts() {
    setup
    
    # Create test script
    echo "#!/usr/bin/env bash" > "$TEMP_SCRIPTS_DIR/undocumented.sh"
    chmod +x "$TEMP_SCRIPTS_DIR/undocumented.sh"
    
    # Create empty capabilities file
    echo "# Test capabilities" > "$TEMP_CAPABILITIES"
    
    # Override paths for testing
    local output exit_code
    cd "$TEMP_DIR"
    if output=$(SCRIPTS_DIR="$TEMP_SCRIPTS_DIR" CAPABILITIES_FILE="$TEMP_CAPABILITIES" bash "$SUT" --check 2>&1); then
        exit_code=0
    else
        exit_code=$?
    fi
    
    teardown
    
    if [ $exit_code -eq 0 ]; then
        echo "FAIL: --check should exit non-zero when scripts missing"
        echo "Output: $output"
        return 1
    fi
    
    if ! echo "$output" | grep -q "ERROR:"; then
        echo "FAIL: --check should show error message"
        echo "Output: $output"
        return 1
    fi
    
    if ! echo "$output" | grep -q "undocumented.sh"; then
        echo "FAIL: --check should list missing script"
        echo "Output: $output"
        return 1
    fi
    
    echo "PASS: --check with missing scripts returns non-zero"
}

# Test: --check mode excludes test files
test_check_excludes_tests() {
    setup
    
    # Create test script (should be excluded)
    echo "#!/usr/bin/env bash" > "$TEMP_SCRIPTS_DIR/script.test.sh"
    chmod +x "$TEMP_SCRIPTS_DIR/script.test.sh"
    
    # Create empty capabilities file
    echo "# Test capabilities" > "$TEMP_CAPABILITIES"
    
    # Override paths for testing
    local output exit_code
    cd "$TEMP_DIR"
    if output=$(SCRIPTS_DIR="$TEMP_SCRIPTS_DIR" CAPABILITIES_FILE="$TEMP_CAPABILITIES" bash "$SUT" --check 2>&1); then
        exit_code=0
    else
        exit_code=$?
    fi
    
    teardown
    
    if [ $exit_code -ne 0 ]; then
        echo "FAIL: --check should not require test files to be documented"
        echo "Output: $output"
        return 1
    fi
    
    echo "PASS: --check excludes test files"
}

# Test: --check mode excludes capabilities-sync.sh itself
test_check_excludes_self() {
    setup
    
    # Copy capabilities-sync.sh to temp dir
    cp "$SUT" "$TEMP_SCRIPTS_DIR/"
    
    # Create empty capabilities file
    echo "# Test capabilities" > "$TEMP_CAPABILITIES"
    
    # Override paths for testing
    local output exit_code
    cd "$TEMP_DIR"
    if output=$(SCRIPTS_DIR="$TEMP_SCRIPTS_DIR" CAPABILITIES_FILE="$TEMP_CAPABILITIES" bash "$SUT" --check 2>&1); then
        exit_code=0
    else
        exit_code=$?
    fi
    
    teardown
    
    if [ $exit_code -ne 0 ]; then
        echo "FAIL: --check should not require capabilities-sync.sh to be documented"
        echo "Output: $output"
        return 1
    fi
    
    echo "PASS: --check excludes capabilities-sync.sh itself"
}

# Test: --update mode suggests additions
test_update_suggests_additions() {
    setup
    
    # Create test script
    echo "#!/usr/bin/env bash" > "$TEMP_SCRIPTS_DIR/new-script.sh"
    echo "# new-script.sh - A new script" >> "$TEMP_SCRIPTS_DIR/new-script.sh"
    chmod +x "$TEMP_SCRIPTS_DIR/new-script.sh"
    
    # Create empty capabilities file
    echo "# Test capabilities" > "$TEMP_CAPABILITIES"
    
    # Override paths for testing
    local output
    cd "$TEMP_DIR"
    output=$(SCRIPTS_DIR="$TEMP_SCRIPTS_DIR" CAPABILITIES_FILE="$TEMP_CAPABILITIES" bash "$SUT" --update 2>&1)
    
    teardown
    
    if ! echo "$output" | grep -q "new-script.sh"; then
        echo "FAIL: --update should suggest undocumented script"
        echo "Output: $output"
        return 1
    fi
    
    if ! echo "$output" | grep -q "\[.cursor/scripts/new-script.sh\]"; then
        echo "FAIL: --update should format as markdown link"
        echo "Output: $output"
        return 1
    fi
    
    echo "PASS: --update suggests additions"
}

# Test: Invalid flag returns error
test_invalid_flag() {
    local output exit_code
    if output=$("$SUT" --invalid 2>&1); then
        exit_code=0
    else
        exit_code=$?
    fi
    
    if [ $exit_code -eq 0 ]; then
        echo "FAIL: invalid flag should exit non-zero"
        return 1
    fi
    
    if ! echo "$output" | grep -q "Unknown option"; then
        echo "FAIL: invalid flag should show error"
        echo "Output: $output"
        return 1
    fi
    
    echo "PASS: invalid flag returns error"
}

# Test: Script is executable
test_executable() {
    if [ ! -x "$SUT" ]; then
        echo "FAIL: capabilities-sync.sh should be executable"
        return 1
    fi
    
    echo "PASS: script is executable"
}

# Test: Script has proper shebang
test_shebang() {
    local first_line
    first_line=$(head -n 1 "$SUT")
    
    if [ "$first_line" != "#!/usr/bin/env bash" ]; then
        echo "FAIL: script should have proper shebang"
        echo "Got: $first_line"
        return 1
    fi
    
    echo "PASS: script has proper shebang"
}

# Run all tests
main() {
    local failed=0
    local tests=(
        test_help_flag
        test_executable
        test_shebang
        test_check_all_documented
        test_check_missing_scripts
        test_check_excludes_tests
        test_check_excludes_self
        test_update_suggests_additions
        test_invalid_flag
    )
    
    echo "Running capabilities-sync.sh tests..."
    echo
    
    for test in "${tests[@]}"; do
        if ! $test; then
            failed=$((failed + 1))
        fi
    done
    
    echo
    if [ $failed -eq 0 ]; then
        echo "✅ All tests passed"
        exit 0
    else
        echo "❌ $failed test(s) failed"
        exit 1
    fi
}

main "$@"

