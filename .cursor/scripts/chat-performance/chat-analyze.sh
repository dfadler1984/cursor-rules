#!/usr/bin/env bash
# Chat Analyze CLI
# Unified tool for token estimation, headroom calculation, and efficiency gauge

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Help text
show_help() {
  cat << EOF
Usage: chat-analyze [FILE] [OPTIONS]

Analyze chat transcript for token usage, headroom, and efficiency.

Arguments:
  FILE                    Transcript file to analyze (use '-' or omit for stdin)

Options:
  --model MODEL           Model to use (default: gpt-4)
                          OpenAI: gpt-3.5-turbo, gpt-4, gpt-4-32k, gpt-4-turbo,
                                  gpt-4o, o1-preview, o1-mini
                          Anthropic: claude-3-haiku, claude-3-sonnet, claude-3-opus,
                                    claude-3-5-sonnet, claude-3-5-haiku, claude-sonnet-4-5
  --buffer PCT            Safety buffer percentage 0-100 (default: 10)
  --completion N          Planned completion tokens (default: 2000)
  --format FORMAT         Output format: text|json (default: text)
  -h, --help             Show this help message

Examples:
  chat-analyze transcript.txt
  chat-analyze transcript.txt --model claude-3-5-sonnet --buffer 15
  echo "Sample chat" | chat-analyze --format json
  chat-analyze < input.txt

Output (text format):
  ═══════════════════════════════════════
  CHAT ANALYSIS
  ═══════════════════════════════════════
  
  Tokens: 1234
  Method: tiktoken
  Model: gpt-4
  Encoding: cl100k_base
  
  Headroom: 5138 tokens (62.7%)
  Status: ok
  Recommendation: Headroom sufficient; continue
  
  Breakdown:
    Max context: 8192
    Current estimate: 1234
    Planned completion: 2000
    Safety buffer (10%): 819
    Total used: 4053

Output (json format):
  {
    "tokens": {...},
    "headroom": {...}
  }

Exit Codes:
  0   Success
  1   General error (file not found, estimation failed)
  2   Usage error (invalid arguments)
EOF
}

# Default values
INPUT_FILE="-"
MODEL="gpt-4"
BUFFER=10
COMPLETION=2000
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
    --buffer)
      BUFFER="$2"
      shift 2
      ;;
    --completion)
      COMPLETION="$2"
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

# Check dependencies
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

# Run analyzer
RESULT=$(node -e "
import { estimateTokens } from '$SCRIPT_DIR/token-estimator.js';
import { computeHeadroom, formatHeadroomText } from '$SCRIPT_DIR/headroom-calculator.js';

const text = process.argv[1];
const model = process.argv[2];
const buffer = parseFloat(process.argv[3]);
const completion = parseInt(process.argv[4], 10);
const format = process.argv[5];

try {
  // Estimate tokens
  const tokenResult = estimateTokens(text, { model });
  
  // Compute headroom
  const headroomResult = computeHeadroom({
    estimatedTokens: tokenResult.tokens,
    model,
    plannedCompletion: completion,
    bufferPct: buffer
  });
  
  if (format === 'json') {
    console.log(JSON.stringify({ tokens: tokenResult, headroom: headroomResult }, null, 2));
  } else {
    // Text format
    console.log('═══════════════════════════════════════');
    console.log('CHAT ANALYSIS');
    console.log('═══════════════════════════════════════');
    console.log('');
    console.log('Tokens:', tokenResult.tokens);
    console.log('Method:', tokenResult.method);
    console.log('Model:', tokenResult.model);
    console.log('Encoding:', tokenResult.encoding);
    if (tokenResult.warning) {
      console.log('Warning:', tokenResult.warning);
    }
    console.log('');
    console.log(formatHeadroomText(headroomResult));
  }
} catch (error) {
  console.error('Error:', error.message);
  process.exit(1);
}
" "$TEXT" "$MODEL" "$BUFFER" "$COMPLETION" "$FORMAT")

echo "$RESULT"

