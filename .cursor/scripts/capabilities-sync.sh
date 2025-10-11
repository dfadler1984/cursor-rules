#!/usr/bin/env bash
set -euo pipefail

# capabilities-sync.sh - Validate that all scripts are documented in capabilities.mdc
# Usage: capabilities-sync.sh [--check|--update]

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPTS_DIR="${SCRIPTS_DIR:-$REPO_ROOT/.cursor/scripts}"
CAPABILITIES_FILE="${CAPABILITIES_FILE:-$REPO_ROOT/.cursor/rules/capabilities.mdc}"

MODE="${1:---check}"

# Find all executable .sh scripts (excluding tests and this script)
find_scripts() {
    find "$SCRIPTS_DIR" -maxdepth 1 -name "*.sh" -type f ! -name "*.test.sh" ! -name "capabilities-sync.sh" | sort
}

# Extract script name from path
script_name() {
    basename "$1"
}

# Check if script is documented in capabilities.mdc
is_documented() {
    local script_name="$1"
    grep -q "\[.*$script_name\]" "$CAPABILITIES_FILE" 2>/dev/null
}

# Extract description from script's --help or header comments
get_description() {
    local script_path="$1"
    # Try to get first line of help output
    if "$script_path" --help 2>/dev/null | head -n 3 | tail -n 1; then
        return
    fi
    # Fallback: extract from header comments
    grep "^#" "$script_path" | grep -v "^#!/" | head -n 1 | sed 's/^# *//' || echo "No description available"
}

check_mode() {
    local missing=()
    
    echo "Checking script documentation in capabilities.mdc..."
    echo
    
    while IFS= read -r script_path; do
        local name
        name=$(script_name "$script_path")
        
        if ! is_documented "$name"; then
            missing+=("$name")
            echo "❌ Missing: $name"
        else
            echo "✅ Documented: $name"
        fi
    done < <(find_scripts)
    
    echo
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo "ERROR: ${#missing[@]} script(s) not documented in capabilities.mdc"
        echo
        echo "Missing scripts:"
        printf '  - %s\n' "${missing[@]}"
        echo
        echo "Run: $0 --update to see suggested additions"
        exit 1
    else
        echo "✅ All scripts are documented in capabilities.mdc"
        exit 0
    fi
}

update_mode() {
    echo "Scanning for undocumented scripts..."
    echo
    echo "Add these to capabilities.mdc under the appropriate section:"
    echo
    
    while IFS= read -r script_path; do
        local name
        name=$(script_name "$script_path")
        
        if ! is_documented "$name"; then
            local desc
            desc=$(get_description "$script_path")
            echo "- \`[.cursor/scripts/$name](.cursor/scripts/$name)\`: $desc"
        fi
    done < <(find_scripts)
}

case "$MODE" in
    --check)
        check_mode
        ;;
    --update)
        update_mode
        ;;
    -h|--help)
        cat <<EOF
Usage: capabilities-sync.sh [--check|--update]

Validates that all scripts in .cursor/scripts/ are documented in capabilities.mdc

Options:
  --check   Check for undocumented scripts (default, exits non-zero if any found)
  --update  List suggested additions for undocumented scripts
  -h, --help Show this help

Exit codes:
  0 - All scripts documented
  1 - Missing documentation found
EOF
        ;;
    *)
        echo "Unknown option: $MODE"
        echo "Use --help for usage"
        exit 2
        ;;
esac

