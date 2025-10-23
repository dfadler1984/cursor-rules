#!/usr/bin/env bash
# Token Estimator CLI
# Estimates token counts for text files or stdin

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Help text
show_help() {
  cat << EOF
Usage: token-estimate [FILE] [OPTIONS]

Estimate token count for a text file or stdin.

Arguments:
  FILE                    File to analyze (use '-' or omit for stdin)

Options:
  --model MODEL           Model to use for estimation (default: gpt-4)
                          OpenAI: gpt-3.5-turbo, gpt-4, gpt-4-32k, gpt-4-turbo,
                                  gpt-4o, o1-preview, o1-mini
                          Anthropic: claude-3-haiku, claude-3-sonnet, claude-3-opus,
                                    claude-3-5-sonnet, claude-3-5-haiku, claude-sonnet-4-5
  --format FORMAT         Output format: text|json (default: text)
  -h, --help             Show this help message

Examples:
  token-estimate transcript.txt
  token-estimate transcript.txt --model claude-3-5-sonnet
  echo "Hello world" | token-estimate
  token-estimate --format json < input.txt

Output (text format):
  Estimated tokens: 1234
  Model: gpt-4
  Method: tiktoken
  Encoding: cl100k_base

Output (json format):
  {"tokens":1234,"method":"tiktoken","model":"gpt-4","encoding":"cl100k_base"}

Exit Codes:
  0   Success
  1   General error (file not found, estimation failed)
  2   Usage error (invalid arguments)
EOF
}

# Default values
INPUT_FILE="-"
MODEL="gpt-4"
FORMAT="text"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_help
      exit 0
      ;;
    --model)
      MODEL="$2"
      shift 2
      ;;
    --format)
      FORMAT="$2"
      shift 2
      ;;
    -*)
      echo "Error: Unknown option: $1" >&2
      echo "Use --help for usage information" >&2
      exit 1
      ;;
    *)
      INPUT_FILE="$1"
      shift
      ;;
  esac
done

# Check if node_modules exists, if not, prompt to install
if [[ ! -d "$SCRIPT_DIR/node_modules" ]]; then
  echo "Error: Dependencies not installed" >&2
  echo "Run: cd $SCRIPT_DIR && npm install" >&2
  exit 1
fi

# Read input
if [[ "$INPUT_FILE" == "-" ]]; then
  TEXT=$(cat)
else
  if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: File not found: $INPUT_FILE" >&2
    exit 1
  fi
  TEXT=$(cat "$INPUT_FILE")
fi

# Run estimator
RESULT=$(node -e "
import { estimateTokens } from '$SCRIPT_DIR/token-estimator.js';

const text = process.argv[1];
const model = process.argv[2];

try {
  const result = estimateTokens(text, { model });
  console.log(JSON.stringify(result));
} catch (error) {
  console.error('Error:', error.message);
  process.exit(1);
}
" "$TEXT" "$MODEL")

# Format output
if [[ "$FORMAT" == "json" ]]; then
  echo "$RESULT"
else
  # Parse JSON and format as text
  echo "$RESULT" | node -e "
const result = JSON.parse(require('fs').readFileSync(0, 'utf-8'));
console.log('Estimated tokens:', result.tokens);
console.log('Model:', result.model);
console.log('Method:', result.method);
console.log('Encoding:', result.encoding);
if (result.warning) {
  console.log('Warning:', result.warning);
}
"
fi

