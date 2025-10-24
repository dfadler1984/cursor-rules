#!/usr/bin/env bash
# Generate health badge from repository validation output
#
# Extracts health score from deep-rule-and-command-validate.sh output
# and generates a static SVG badge with color-coded score display.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=.lib.sh
source "$SCRIPT_DIR/.lib.sh"

VERSION="1.0.0"

# Default values
OUTPUT_FILE=".github/badges/health.svg"
DRY_RUN=0
INPUT_MODE="stdin"

usage() {
  cat <<EOF
health-badge-generate.sh (v$VERSION)
Generate repository health badge from validation output

Usage: health-badge-generate.sh [OPTIONS]

DESCRIPTION
  Generates a static SVG badge showing repository health score (0-100).
  Reads validation output from stdin or runs deep-rule-and-command-validate.sh.

  Color mapping:
    - Green: 90-100 (healthy)
    - Yellow: 70-89 (needs attention)
    - Red: 0-69 (critical)

OPTIONS
  -o, --output PATH       Output badge file path (default: .github/badges/health.svg)
  --dry-run              Print badge content to stdout without writing file
  --extract-score        Extract score from stdin and print it (testing mode)
  --map-color SCORE      Map score to color name (testing mode)
  -h, --help             Show this help and exit
  -v, --version          Show version and exit

EXAMPLES
  Generate badge from validation:
    $ deep-rule-and-command-validate.sh | health-badge-generate.sh

  Specify output path:
    $ health-badge-generate.sh --output docs/badges/health.svg

  Dry run (preview):
    $ health-badge-generate.sh --dry-run

  Extract score (testing):
    $ echo 'Overall Health Score: 95/100' | health-badge-generate.sh --extract-score
EOF
}

# Extract score from validation output
extract_score() {
  local input
  input=$(cat)
  
  # Match "Overall Health Score: N/100"
  if echo "$input" | grep -q "Overall Health Score:"; then
    echo "$input" | grep "Overall Health Score:" | sed 's/.*Overall Health Score: \([0-9]*\)\/100.*/\1/'
  else
    echo "ERROR: Could not find health score in input" >&2
    return 1
  fi
}

# Map score to color
map_color() {
  local score=$1
  
  if [[ $score -ge 90 ]]; then
    echo "green"
  elif [[ $score -ge 70 ]]; then
    echo "yellow"
  else
    echo "red"
  fi
}

# Generate SVG badge
generate_svg() {
  local score=$1
  local color=$2
  
  # SVG template for badge
  cat <<EOF
<svg xmlns="http://www.w3.org/2000/svg" width="120" height="20">
  <linearGradient id="b" x2="0" y2="100%">
    <stop offset="0" stop-color="#bbb" stop-opacity=".1"/>
    <stop offset="1" stop-opacity=".1"/>
  </linearGradient>
  <mask id="a">
    <rect width="120" height="20" rx="3" fill="#fff"/>
  </mask>
  <g mask="url(#a)">
    <path fill="#555" d="M0 0h50v20H0z"/>
    <path fill="$color" d="M50 0h70v20H50z"/>
    <path fill="url(#b)" d="M0 0h120v20H0z"/>
  </g>
  <g fill="#fff" text-anchor="middle" font-family="DejaVu Sans,Verdana,Geneva,sans-serif" font-size="11">
    <text x="25" y="15" fill="#010101" fill-opacity=".3">health</text>
    <text x="25" y="14">health</text>
    <text x="85" y="15" fill="#010101" fill-opacity=".3">$score/100</text>
    <text x="85" y="14">$score/100</text>
  </g>
</svg>
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      usage
      exit 0
      ;;
    -v|--version)
      echo "$VERSION"
      exit 0
      ;;
    -o|--output)
      OUTPUT_FILE="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --extract-score)
      # Testing mode: just extract and print score
      extract_score
      exit $?
      ;;
    --map-color)
      # Testing mode: just map score to color
      map_color "$2"
      exit 0
      ;;
    *)
      echo "ERROR: Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

# Main execution
main() {
  local input
  local score
  local color
  local svg
  
  # Read validation output from stdin
  input=$(cat)
  
  # Extract score
  if ! score=$(echo "$input" | extract_score 2>&1); then
    echo "ERROR: Failed to extract health score" >&2
    echo "Input was: $input" >&2
    
    # Generate error badge
    score="error"
    color="red"
    svg="<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"120\" height=\"20\"><text x=\"60\" y=\"14\" text-anchor=\"middle\" fill=\"red\">Error</text></svg>"
  else
    # Map score to color
    color=$(map_color "$score")
    
    # Generate SVG
    svg=$(generate_svg "$score" "$color")
  fi
  
  # Output
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "$svg"
  else
    # Ensure output directory exists
    mkdir -p "$(dirname "$OUTPUT_FILE")"
    
    # Write badge file
    echo "$svg" > "$OUTPUT_FILE"
    echo "✓ Badge generated: $OUTPUT_FILE (score: $score, color: $color)" >&2
  fi
}

# Run main if not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi

