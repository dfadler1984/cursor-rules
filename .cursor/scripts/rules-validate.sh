#!/usr/bin/env bash
set -euo pipefail

# Portable rules validator for .cursor/rules/*.mdc
# - Uses only POSIX-ish tools available on macOS (BSD grep/awk/sed)
# - Prints diagnostics as: path:line: message
# - Exits non-zero if any issues are found

LC_ALL=C

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
RULES_DIR="$ROOT_DIR/.cursor/rules"

fail_count=0

print_usage() {
  cat <<EOF
Usage: $(basename "$0") [--list] [--dir <rules-dir>] [--help]

Validates rule files under .cursor/rules/*.mdc for:
  - Required front matter fields and formats
  - CSV spacing and brace expansion { } in globs/overrides
  - Boolean casing for alwaysApply
  - Deprecated references (assistant-learning-log.mdc)
  - Common typography typo (ev<space>ents)
  - Invariants for tdd-first.mdc (globs includes **/*.cjs)
EOF
}

list_rule_files() {
  find "$RULES_DIR" -type f -name "*.mdc" | sort
}

extract_front_matter() {
  # Args: <file>
  # Prints only the first YAML front matter block (lines between first pair of ---)
  awk 'BEGIN{inside=0} /^---[ \t]*$/{ if(inside==0){inside=1; next}else{ exit } } inside==1{ print }' "$1"
}

report_line() {
  # Args: <file> <line> <message>
  printf "%s:%s: %s\n" "$1" "$2" "$3"
  fail_count=$((fail_count+1))
}

report_block() {
  # Args: <multi-line string>
  # Each line already formatted as path:line: message
  # Count lines and echo
  local out="$1"
  if [ -n "$out" ]; then
    printf "%s\n" "$out"
    # Count lines (portable)
    # Trim trailing newline to avoid off-by-one
    local n
    n=$(printf "%s" "$out" | awk 'END{print NR}')
    # awk prints 0 for empty input; we guarded for non-empty
    fail_count=$((fail_count + n))
  fi
}

check_required_fields() {
  local f="$1"
  local fm
  fm="$(extract_front_matter "$f")"
  # description
  if ! printf "%s\n" "$fm" | grep -qE '^description:'; then
    report_line "$f" 1 'missing required field: description'
  fi
  # lastReviewed format
  if ! printf "%s\n" "$fm" | grep -qE '^lastReviewed:[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
    # Try to locate the line number if present; else default to 1
    local ln
    ln="$(awk 'BEGIN{inside=0} /^---[ \t]*$/{ if(inside==0){inside=1; next}else{ exit } } inside==1 && $1=="lastReviewed:"{ print NR; exit }' "$f")"
    [ -z "$ln" ] && ln=1
    report_line "$f" "$ln" 'missing or invalid lastReviewed (YYYY-MM-DD)'
  fi
  # healthScore keys
  if ! printf "%s\n" "$fm" | grep -qE '^healthScore:'; then
    report_line "$f" 1 'missing healthScore'
  else
    for k in content usability maintenance; do
      if ! printf "%s\n" "$fm" | grep -qE "^[[:space:]]{2}$k:[[:space:]]*(green|yellow|red)"; then
        report_line "$f" 1 "missing healthScore.$k"
      fi
    done
  fi
}

check_csv_and_boolean() {
  local f="$1"
  # Use awk to validate CSV fields and boolean casing
  local out
  out="$(awk -v file="$f" '
    function report(ln,msg){ printf "%s:%d: %s\n", file, ln, msg }
    {
      if ($0 ~ /^(globs|overrides):/) {
        if ($0 ~ /,\s+/) report(NR, "spaces around commas in CSV (globs/overrides)")
        if ($0 ~ /[{}]/) report(NR, "brace expansion {} not allowed in CSV (globs/overrides)")
      }
      if ($0 ~ /^alwaysApply:[[:space:]]*/) {
        line=$0
        sub(/^alwaysApply:[[:space:]]*/, "", line)
        if (line !~ /^(true|false)$/) report(NR, "alwaysApply must be unquoted lowercase true|false")
      }
    }
  ' "$f")"
  report_block "$out"
}

check_deprecated_and_typos() {
  local f="$1"
  local out
  # Deprecated reference
  if grep -nE 'assistant-learning-log\.mdc' "$f" >/dev/null 2>&1; then
    out="$(grep -nE 'assistant-learning-log\.mdc' "$f" | sed -e "s|^|$f:|" -e 's/$/: deprecated reference, use `logging-protocol.mdc`/')"
    report_block "$out"
  fi

  # Typography typo: ev\s+ents
  if grep -nE 'ev[[:space:]]+ents' "$f" >/dev/null 2>&1; then
    out="$(grep -nE 'ev[[:space:]]+ents' "$f" | sed -e "s|^|$f:|" -e 's/$/: fix typography: use "events"/')"
    report_block "$out"
  fi
}

check_tdd_first_invariant() {
  local f="$1"
  local base
  base="$(basename "$f")"
  if [ "$base" = "tdd-first.mdc" ]; then
    local fm
    fm="$(extract_front_matter "$f")"
    if ! printf "%s\n" "$fm" | grep -qE '^globs:.*\*\*/\*\.cjs'; then
      # Try to locate the globs line number
      local ln
      ln="$(awk 'BEGIN{inside=0} /^---[ \t]*$/{ if(inside==0){inside=1; next}else{ exit } } inside==1 && $1=="globs:"{ print NR; exit }' "$f")"
      [ -z "$ln" ] && ln=1
      report_line "$f" "$ln" 'tdd-first.mdc: globs should include **/*.cjs'
    fi
  fi
}

check_embedded_front_matter_and_duplicate_headers() {
  local f="$1"
  # Detect embedded front matter blocks beyond the first pair of --- lines
  local fm_out
  fm_out=$(awk -v file="$f" '
    BEGIN{sepCount=0; inCode=0}
    /^```/ { inCode = 1 - inCode; next }
    /^---[ \t]*$/ {
      if (!inCode) {
        sepCount++
        if (sepCount>2) { printf "%s:%d: embedded front matter block detected\n", file, NR }
      }
    }
  ' "$f")
  report_block "$fm_out"

  # Detect duplicate top-level headers (# ...)
  local hdr_out
  hdr_out=$(awk -v file="$f" '
    BEGIN{firstSeen=0; inCode=0}
    /^```/ { inCode = 1 - inCode; next }
    /^# [^#]/ {
      if (!inCode) {
        if (firstSeen==0) { firstSeen=1 }
        else { printf "%s:%d: duplicate top-level header\n", file, NR }
      }
    }
  ' "$f")
  report_block "$hdr_out"
}

main() {
  # Parse simple args
  while [ $# -gt 0 ]; do
    case "$1" in
      --list)
        list_rule_files
        exit 0
        ;;
      --dir)
        shift
        RULES_DIR="${1:-}"
        if [ -z "$RULES_DIR" ]; then
          echo "--dir requires a value" >&2
          exit 2
        fi
        ;;
      --help|-h)
        print_usage
        exit 0
        ;;
      *)
        echo "Unknown argument: $1" >&2
        print_usage >&2
        exit 2
        ;;
    esac
    shift
  done

  if [ ! -d "$RULES_DIR" ]; then
    printf "No rules directory found at %s\n" "$RULES_DIR" >&2
    exit 1
  fi

  while IFS= read -r f; do
    # Front matter
    check_required_fields "$f"
    # CSV + boolean
    check_csv_and_boolean "$f"
    # Deprecated refs and typos
    check_deprecated_and_typos "$f"
    # Invariants
    check_tdd_first_invariant "$f"
    # Structure hygiene
    check_embedded_front_matter_and_duplicate_headers "$f"
  done < <(list_rule_files)

  if [ "$fail_count" -gt 0 ]; then
    printf "rules-validate: %d issue(s) found\n" "$fail_count" >&2
    exit 1
  else
    printf "rules-validate: OK\n"
  fi
}

main "$@"
