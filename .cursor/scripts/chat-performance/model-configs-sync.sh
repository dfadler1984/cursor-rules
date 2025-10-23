#!/usr/bin/env bash
# Model Configurations Sync Script
#
# Syncs model configurations from Cursor documentation
# Source: https://cursor.com/docs/models

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODELS_FILE="$SCRIPT_DIR/models.json"

# Help text
show_help() {
  cat << EOF
Usage: model-configs-sync.sh [OPTIONS]

Sync model configurations from Cursor documentation or validate current configs.

Options:
  --check                 Check if models.json is valid (validate only)
  --list                  List currently configured models
  --add MODEL             Add a new model interactively
  --update-date           Update lastSync date to today
  -h, --help             Show this help message

Examples:
  model-configs-sync.sh --check
  model-configs-sync.sh --list
  model-configs-sync.sh --add gpt-5
  model-configs-sync.sh --update-date

Manual Sync Procedure:
  1. Visit https://cursor.com/docs/models
  2. For each model, note: maxContext, maxOutput, encoding
  3. Run: model-configs-sync.sh --add <model-id>
  4. Follow prompts to enter model specs
  5. Run: model-configs-sync.sh --check (validate)
  6. Run: cd $SCRIPT_DIR && npm test (verify)

Current Models File: $MODELS_FILE
EOF
}

# Validate models.json structure
validate_models_json() {
  echo "Validating models.json..." >&2
  
  # Check if file exists
  if [[ ! -f "$MODELS_FILE" ]]; then
    echo "Error: models.json not found at $MODELS_FILE" >&2
    exit 1
  fi
  
  # Check JSON syntax
  if ! jq empty "$MODELS_FILE" 2>/dev/null; then
    echo "Error: Invalid JSON in models.json" >&2
    exit 1
  fi
  
  # Check required fields
  local required_fields=("source" "lastSync" "models")
  for field in "${required_fields[@]}"; do
    if ! jq -e ".$field" "$MODELS_FILE" >/dev/null 2>&1; then
      echo "Error: Missing required field: $field" >&2
      exit 1
    fi
  done
  
  echo "✓ models.json is valid" >&2
  return 0
}

# List configured models
list_models() {
  validate_models_json
  
  echo "Configured Models:"
  echo ""
  
  # Group by provider
  local openai_models=$(jq -r '.models | to_entries | map(select(.value.provider == "openai") | .key) | sort | .[]' "$MODELS_FILE")
  local anthropic_models=$(jq -r '.models | to_entries | map(select(.value.provider == "anthropic") | .key) | sort | .[]' "$MODELS_FILE")
  
  echo "OpenAI:"
  echo "$openai_models" | while read -r model; do
    local max_context=$(jq -r ".models[\"$model\"].maxContext" "$MODELS_FILE")
    local max_output=$(jq -r ".models[\"$model\"].maxOutput" "$MODELS_FILE")
    echo "  - $model (context: ${max_context}, output: ${max_output})"
  done
  
  echo ""
  echo "Anthropic:"
  echo "$anthropic_models" | while read -r model; do
    local max_context=$(jq -r ".models[\"$model\"].maxContext" "$MODELS_FILE")
    local max_output=$(jq -r ".models[\"$model\"].maxOutput" "$MODELS_FILE")
    echo "  - $model (context: ${max_context}, output: ${max_output})"
  done
  
  echo ""
  local total=$(jq '.models | length' "$MODELS_FILE")
  echo "Total: $total models"
  echo "Last sync: $(jq -r '.lastSync' "$MODELS_FILE")"
}

# Add a new model interactively
add_model() {
  local model_id="$1"
  
  validate_models_json
  
  # Check if model already exists
  if jq -e ".models[\"$model_id\"]" "$MODELS_FILE" >/dev/null 2>&1; then
    echo "Model '$model_id' already exists. Use manual edit to update." >&2
    exit 1
  fi
  
  echo "Adding model: $model_id"
  echo ""
  
  # Prompt for details
  read -rp "Provider (openai|anthropic): " provider
  read -rp "Max context tokens: " max_context
  read -rp "Max output tokens: " max_output
  read -rp "Encoding (default: cl100k_base): " encoding
  encoding="${encoding:-cl100k_base}"
  
  # Add to models.json
  local temp_file=$(mktemp)
  jq ".models[\"$model_id\"] = {
    \"encoding\": \"$encoding\",
    \"maxContext\": $max_context,
    \"maxOutput\": $max_output,
    \"provider\": \"$provider\"
  }" "$MODELS_FILE" > "$temp_file"
  
  mv "$temp_file" "$MODELS_FILE"
  
  echo ""
  echo "✓ Model '$model_id' added successfully"
  echo ""
  echo "Next steps:"
  echo "  1. Validate: model-configs-sync.sh --check"
  echo "  2. Test: cd $SCRIPT_DIR && npm test"
  echo "  3. Update help text in token-estimate.sh and chat-analyze.sh"
}

# Update lastSync date
update_sync_date() {
  validate_models_json
  
  local today=$(date +%Y-%m-%d)
  local temp_file=$(mktemp)
  
  jq ".lastSync = \"$today\"" "$MODELS_FILE" > "$temp_file"
  mv "$temp_file" "$MODELS_FILE"
  
  echo "✓ Updated lastSync to $today"
}

# Main script logic
main() {
  if [[ $# -eq 0 ]]; then
    show_help
    exit 0
  fi
  
  case "$1" in
    --check)
      validate_models_json
      echo "All checks passed ✓"
      ;;
    --list)
      list_models
      ;;
    --add)
      if [[ $# -lt 2 ]]; then
        echo "Error: --add requires a model ID" >&2
        echo "Usage: model-configs-sync.sh --add <model-id>" >&2
        exit 1
      fi
      add_model "$2"
      ;;
    --update-date)
      update_sync_date
      ;;
    -h|--help)
      show_help
      ;;
    *)
      echo "Error: Unknown option: $1" >&2
      echo "Use --help for usage information" >&2
      exit 1
      ;;
  esac
}

main "$@"

