#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# List rule files and selected front matter fields as table (default) or JSON.
# Usage: .cursor/scripts/rules-list.sh [--dir PATH] [--format table|json] [-h|--help] [--version]

# shellcheck disable=SC1090
source "$(dirname "$0")/.lib.sh"

VERSION="0.1.0"

ROOT_DIR="$(repo_root)"
RULES_DIR="$ROOT_DIR/.cursor/rules"
FORMAT="table"

usage() {
  cat <<USAGE
Usage: ${script_name} [--dir PATH] [--format table|json] [--version] [-h|--help]

Options:
  --dir PATH         Directory containing rule files (default: .cursor/rules)
  --format FORMAT    Output format: table (default) or json
  --version          Print version and exit
  -h, --help         Show this help and exit
USAGE
}

# parse args
while [ $# -gt 0 ]; do
  case "${1}" in
    --dir)
      [ $# -ge 2 ] || die 2 "--dir requires a path"
      RULES_DIR="$2"; shift 2 ;;
    --format)
      [ $# -ge 2 ] || die 2 "--format requires an argument"
      FORMAT="$2"; shift 2 ;;
    --version)
      printf '%s\n' "$VERSION"; exit 0 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      die 2 "Unknown argument: $1" ;;
  esac
done

# resolve to absolute path
if [ ! -d "$RULES_DIR" ]; then
  log_warn "Rules directory not found: $RULES_DIR (printing nothing)"
  # no output, success
  exit 0
fi

# Collect list of .mdc rule files
mapfile -t FILES < <(find "$RULES_DIR" -maxdepth 1 -type f -name "*.mdc" | sort -f)

# function: parse a rule file and emit a TSV line: file<TAB>description<TAB>lastReviewed<TAB>content<TAB>usability<TAB>maintenance
parse_rule_tsv() {
  local f="$1"
  local in=0 desc="" last="" c="" u="" m=""
  # Read only the first front matter block
  while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" == "---" ]]; then
      if [ $in -eq 0 ]; then in=1; continue; else break; fi
    fi
    if [ $in -eq 1 ]; then
      case "$line" in
        description:*)
          desc="${line#description:}"
          ;;
        lastReviewed:*)
          last="${line#lastReviewed:}"
          ;;
        "  content:"*)
          c="${line#  content:}"
          ;;
        "  usability:"*)
          u="${line#  usability:}"
          ;;
        "  maintenance:"*)
          m="${line#  maintenance:}"
          ;;
      esac
    fi
  done < "$f"

  # trim leading/trailing whitespace and inline comments after a ' #'
  trim() { local s="$1"; s="${s%%#*}"; s="${s##[[:space:]]*}"; s="${s%%[[:space:]]*}"; printf '%s' "$s"; }

  local desc_t="$(trim "$desc")"
  local last_t="$(trim "$last")"
  local c_t="$(trim "$c")"
  local u_t="$(trim "$u")"
  local m_t="$(trim "$m")"

  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "${f#$ROOT_DIR/}" "$desc_t" "$last_t" "$c_t" "$u_t" "$m_t"
}

emit_table() {
  printf 'file\tdescription\tlastReviewed\tcontent\tusability\tmaintenance\n'
  for f in "${FILES[@]}"; do
    parse_rule_tsv "$f"
  done | print_table
}

emit_json() {
  printf '['
  local sep=""
  for f in "${FILES[@]}"; do
    local line
    line="$(parse_rule_tsv "$f")"
    local file_path desc last c u m
    file_path="${line%%$'\t'*}"; line="${line#*$'\t'}"
    desc="${line%%$'\t'*}"; line="${line#*$'\t'}"
    last="${line%%$'\t'*}"; line="${line#*$'\t'}"
    c="${line%%$'\t'*}"; line="${line#*$'\t'}"
    u="${line%%$'\t'*}"; line="${line#*$'\t'}"
    m="${line}"
    printf '%s' "$sep"
    print_kv_json \
      file "$file_path" \
      description "$desc" \
      lastReviewed "$last" \
      content "$c" \
      usability "$u" \
      maintenance "$m"
    sep=','
  done
  printf ']\n'
}

case "$FORMAT" in
  table) emit_table ;;
  json)  emit_json ;;
  *) die 2 "Unknown format: $FORMAT" ;;
esac
