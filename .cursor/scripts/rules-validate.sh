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
OUTPUT_FORMAT="text" # text|json
FAIL_ON_MISSING_REFS=0
missing_refs_count=0
AUTO_FIX=0
FAIL_ON_STALE=0
STALE_DAYS=90
REPORT_FLAG=0
REPORT_OUT=""
declare -A invalid_date_files=()
declare -A unresolved_ref_files=()
count_invalid_dates=0
count_unresolved_refs=0

fail_count=0

print_usage() {
  cat <<EOF
Usage: $(basename "$0") [--list] [--dir <rules-dir>] [--format text|json] [--fail-on-missing-refs] [--fail-on-stale] [--autofix] [--report] [--report-out PATH] [--help]

Validates rule files under .cursor/rules/*.mdc for:
  - Required front matter fields and formats
  - CSV spacing and brace expansion { } in globs/overrides
  - Boolean casing for alwaysApply
  - Deprecated references (assistant-learning-log.mdc)
  - Common typography typo (ev<space>ents)
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
  if [ "$OUTPUT_FORMAT" != "json" ]; then
    printf "%s:%s: %s\n" "$1" "$2" "$3"
  fi
  fail_count=$((fail_count+1))
}

report_block() {
  # Args: <multi-line string>
  # Each line already formatted as path:line: message
  # Count lines and echo
  local out="$1"
  if [ -n "$out" ]; then
    if [ "$OUTPUT_FORMAT" != "json" ]; then
      printf "%s\n" "$out"
    fi
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
    count_invalid_dates=$((count_invalid_dates+1))
    invalid_date_files["$f"]=1
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

check_staleness() {
  # Args: <file>
  local f="$1"
  local fm last ln
  fm="$(extract_front_matter "$f")"
  last="$(printf '%s\n' "$fm" | awk '$1=="lastReviewed:"{sub(/^lastReviewed:[ \t]*/, ""); print; exit}')"
  ln=$(awk 'BEGIN{inside=0} \
    /^---[ \t]*$/{ if(inside==0){inside=1; next}else{ exit } } \
    inside==1 && $1=="lastReviewed:"{ print NR; exit }' "$f")
  [ -z "$last" ] && return 0
  # Parse date; macOS BSD date
  local now ts
  now=$(date -u +%s)
  ts=$(date -u -j -f "%Y-%m-%d" "$last" +%s 2>/dev/null || true)
  [ -z "$ts" ] && return 0
  local days
  days=$(( (now - ts) / 86400 ))
  if [ "$days" -gt "$STALE_DAYS" ]; then
    if [ "$FAIL_ON_STALE" -eq 1 ]; then
      report_line "$f" "${ln:-1}" "stale lastReviewed (> ${STALE_DAYS}d old)"
    else
      if [ "$OUTPUT_FORMAT" != "json" ]; then
        printf "%s:%s: %s\n" "$f" "${ln:-1}" "stale lastReviewed (> ${STALE_DAYS}d old)"
      fi
    fi
  fi
}

autofix_file() {
  # Args: <file>
  # Fix CSV spaces after commas and normalize alwaysApply casing in-place
  local f="$1"
  sed -E -i '' \
    -e '/^(globs|overrides):/ s/,\s+/,/g' \
    -e 's/^alwaysApply:[[:space:]]*"?True"?[[:space:]]*$/alwaysApply: true/' \
    -e 's/^alwaysApply:[[:space:]]*"?False"?[[:space:]]*$/alwaysApply: false/' \
    "$f"
}

check_missing_refs() {
  # Args: <file>
  # Detect unresolved references in backticks or markdown links; count, and optionally fail
  local f="$1"
  local base_dir
  base_dir="$(cd "$(dirname "$f")" && pwd)"

  # Collect candidates from backticks
  local candidates_bq
  candidates_bq=$(grep -oE '`[^`]+`' "$f" | tr -d '`' || true)

  # Collect candidates from markdown links [text](path) excluding http/mailto
  local candidates_md
  candidates_md=$(sed -nE 's/.*\[[^]]*\]\(([^)#]+)\).*/\1/p' "$f" | sed -E '/^https?:\/\//d; /^mailto:/d; /^#/d' || true)

  # Merge candidates (newline-delimited)
  local all
  all="$(printf '%s\n%s\n' "$candidates_bq" "$candidates_md" | sed '/^\s*$/d' | sort -u)"

  local rel abs trimmed
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    # strip anchors
    rel="${rel%%#*}"
    # ignore obvious externals
    case "$rel" in
      http://*|https://*|mailto:*|\#*) continue;;
    esac
    # trim surrounding spaces and trailing punctuation ) >
    trimmed="$(printf '%s' "$rel" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//; s/[)>]+$//')"
    [ -n "$trimmed" ] || continue
    if [[ "$trimmed" = /* ]]; then
      abs="$trimmed"
    elif [[ "$trimmed" == ./* || "$trimmed" == ../* ]]; then
      abs="$base_dir/$trimmed"
    else
      abs="$ROOT_DIR/$trimmed"
    fi
    if [ ! -e "$abs" ]; then
      missing_refs_count=$((missing_refs_count+1))
      count_unresolved_refs=$((count_unresolved_refs+1))
      unresolved_ref_files["$f"]=1
      if [ "$FAIL_ON_MISSING_REFS" -eq 1 ]; then
        report_line "$f" 1 "unresolved reference: $trimmed"
      fi
    fi
  done <<< "$all"
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
      --fail-on-missing-refs)
        FAIL_ON_MISSING_REFS=1
        ;;
      --format)
        shift
        OUTPUT_FORMAT="${1:-}"
        if [ -z "$OUTPUT_FORMAT" ]; then
          echo "--format requires a value (text|json)" >&2
          exit 2
        fi
        if [ "$OUTPUT_FORMAT" != "text" ] && [ "$OUTPUT_FORMAT" != "json" ]; then
          echo "--format must be 'text' or 'json'" >&2
          exit 2
        fi
        ;;
      --autofix)
        AUTO_FIX=1
        ;;
      --report)
        REPORT_FLAG=1
        ;;
      --report-out)
        shift
        REPORT_OUT="${1:-}"
        if [ -z "$REPORT_OUT" ]; then
          echo "--report-out requires a file path" >&2
          exit 2
        fi
        ;;
      --fail-on-stale)
        FAIL_ON_STALE=1
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
    # Pre-fix formatting-only issues when requested
    if [ "$AUTO_FIX" -eq 1 ]; then
      autofix_file "$f" || true
    fi
    # Front matter
    check_required_fields "$f"
    # CSV + boolean
    check_csv_and_boolean "$f"
    # Deprecated refs and typos
    check_deprecated_and_typos "$f"
    # Invariants (none specific at this time)
    # Structure hygiene
    check_embedded_front_matter_and_duplicate_headers "$f"
    # Missing references
    check_missing_refs "$f"
    # Staleness
    check_staleness "$f"
  done < <(list_rule_files)

  # Generate review report if requested
  if [ "$REPORT_FLAG" -eq 1 ] || [ -n "$REPORT_OUT" ]; then
    local out
    if [ -z "$REPORT_OUT" ]; then
      local dir
      dir="$ROOT_DIR/docs/reviews"
      mkdir -p "$dir"
      out="$dir/review-$(date -u +"%Y-%m-%d").md"
    else
      mkdir -p "$(dirname "$REPORT_OUT")"
      out="$REPORT_OUT"
    fi
    {
      printf '# Rules Review — %s\n\n' "$(date -u +"%Y-%m-%d")"
      printf '## Counts\n\n'
      printf '-- invalidDates: %d\n' "$count_invalid_dates"
      printf '-- unresolvedReferences: %d\n\n' "$count_unresolved_refs"
      printf '## Actions\n\n'
      for f in "${!invalid_date_files[@]}"; do
        printf '-- Fix invalid date in %s\n' "${f#"$ROOT_DIR/"}"
      done
      for f in "${!unresolved_ref_files[@]}"; do
        printf '-- Resolve references in %s\n' "${f#"$ROOT_DIR/"}"
      done
      printf '\n'
    } > "$out"
  fi

  if [ "$OUTPUT_FORMAT" = "json" ]; then
    printf '{"totalIssues": %d}\n' "$fail_count"
    if [ "$fail_count" -gt 0 ]; then
      exit 1
    else
      exit 0
    fi
  else
    if [ "$fail_count" -gt 0 ]; then
      printf "rules-validate: %d issue(s) found\n" "$fail_count" >&2
      exit 1
    else
      printf "rules-validate: OK\n"
    fi
  fi
}

main "$@"
