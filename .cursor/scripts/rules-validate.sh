#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Validate rule files' front matter for required fields and formats.
# Usage: .cursor/scripts/rules-validate.sh [--dir PATH] [--fail-on-missing-refs] [-h|--help] [--version]

# shellcheck disable=SC1090
source "$(dirname "$0")/.lib.sh"

VERSION="0.1.0"

ROOT_DIR="$(repo_root)"
RULES_DIR="$ROOT_DIR/.cursor/rules"
FAIL_ON_REFS=0

usage() {
  cat <<USAGE
Usage: ${script_name} [--dir PATH] [--fail-on-missing-refs] [--version] [-h|--help]

Options:
  --dir PATH               Directory containing rule files (default: .cursor/rules)
  --fail-on-missing-refs   Treat missing internal references as errors (default: warn)
  --version                Print version and exit
  -h, --help               Show this help and exit
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dir)
      [ $# -ge 2 ] || die 2 "--dir requires a path"
      RULES_DIR="$2"; shift 2 ;;
    --fail-on-missing-refs)
      FAIL_ON_REFS=1; shift ;;
    --version)
      printf '%s\n' "$VERSION"; exit 0 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      die 2 "Unknown argument: $1" ;;
  esac
done

if [ ! -d "$RULES_DIR" ]; then
  log_error "Rules directory not found: $RULES_DIR"
  exit 1
fi

mapfile -t FILES < <(find "$RULES_DIR" -maxdepth 1 -type f -name "*.mdc" | sort -f)

error_count=0
warn_count=0

# Extract first front matter block
front_matter() {
  awk 'BEGIN{inside=0} /^---$/ { if(inside==0){inside=1; next} else{ exit } } inside==1{ print }' "$1"
}

trim() {
  printf '%s' "$1" \
    | sed -E 's/[[:space:]]+#.*$//' \
    | sed -E 's/^[[:space:]]+//' \
    | sed -E 's/[[:space:]]+$//'
}

validate_csv() {
  local v="$1"
  # No spaces, no braces, no quotes
  if echo "$v" | grep -qE '[[:space:]]' ; then return 1; fi
  if echo "$v" | grep -q '[{}]' ; then return 1; fi
  if echo "$v" | grep -q '"' ; then return 1; fi
  return 0
}

check_refs() {
  local f="$1" root="$2"; local fm="$3"
  # naive: backtick-enclosed references
  local refs
  refs=$(printf '%s\n' "$fm" | grep -oE '`[^`]+`' | tr -d '`' || true)
  local missing=0
  if [ -n "$refs" ]; then
    while IFS= read -r r; do
      # Skip http/https URLs and @tokens
      if printf '%s' "$r" | grep -qE '^https?://'; then continue; fi
      if printf '%s' "$r" | grep -qE '^@'; then continue; fi
      # Skip placeholders/commands/globs/absolute paths
      if printf '%s' "$r" | grep -qE '\[[^]]*\]'; then continue; fi
      if printf '%s' "$r" | grep -qE '[[:space:]]'; then continue; fi
      if printf '%s' "$r" | grep -qE '^/'; then continue; fi
      if printf '%s' "$r" | grep -qE '\*'; then continue; fi
      # Skip directory-style tokens (ending with a slash)
      if printf '%s' "$r" | grep -qE '/$'; then continue; fi

      local path="$r"
      # Skip CODEOWNERS example
      if [ "$path" = "CODEOWNERS" ]; then continue; fi
      # If it's a bare .mdc filename, resolve under .cursor/rules/
      if printf '%s' "$r" | grep -qE '^([^/]+)\.mdc$'; then
        path=".cursor/rules/$r"
      fi

      # Only validate references within the repo docs/rules areas (skip .github examples)
      if ! printf '%s' "$path" | grep -qE '^(.cursor/|docs/|tasks/|CODEOWNERS$)'; then
        continue
      fi
      case "$path" in
        *.mdc|*.md|*.cjs|*.json|*.ts|*.tsx|CODEOWNERS)
          if [ -f "$root/$path" ]; then :; else missing=$((missing+1)); fi ;;
        *) : ;;
      esac
    done <<< "$refs"
  fi
  if [ $missing -gt 0 ]; then
    if [ $FAIL_ON_REFS -eq 1 ]; then
      printf '%s: ERROR missing %d referenced file(s)\n' "$f" "$missing" >&2
      return 1
    else
      printf '%s: WARN missing %d referenced file(s)\n' "$f" "$missing" >&2
      return 0
    fi
  fi
  return 0
}

for f in "${FILES[@]}"; do
  fm="$(front_matter "$f")"
  [ -n "$fm" ] || { printf '%s: ERROR missing front matter\n' "${f#$ROOT_DIR/}" >&2; error_count=$((error_count+1)); continue; }

  desc="$(printf '%s\n' "$fm" | awk -F':' '/^description:/{ $1=""; sub(/^ /,""); print; exit }')"
  last="$(printf '%s\n' "$fm" | awk -F':' '/^lastReviewed:/{ $1=""; sub(/^ /,""); print; exit }')"
  always="$(printf '%s\n' "$fm" | awk -F':' '/^alwaysApply:/{ $1=""; sub(/^ /,""); print; exit }')"
  globs="$(printf '%s\n' "$fm" | awk -F':' '/^globs:/{ $1=""; sub(/^ /,""); print; exit }')"
  overrides="$(printf '%s\n' "$fm" | awk -F':' '/^overrides:/{ $1=""; sub(/^ /,""); print; exit }')"

  desc="$(trim "$desc")"
  last="$(trim "$last")"
  always="$(trim "$always")"
  globs="$(trim "$globs")"
  overrides="$(trim "$overrides")"

  # healthScore keys
  has_hs=$(printf '%s\n' "$fm" | grep -c '^healthScore:') || true
  hs_content=$(printf '%s\n' "$fm" | awk -F':' '/^[[:space:]]+content:/{ $1=""; sub(/^ /,""); print; exit }')
  hs_usability=$(printf '%s\n' "$fm" | awk -F':' '/^[[:space:]]+usability:/{ $1=""; sub(/^ /,""); print; exit }')
  hs_maintenance=$(printf '%s\n' "$fm" | awk -F':' '/^[[:space:]]+maintenance:/{ $1=""; sub(/^ /,""); print; exit }')

  rel="${f#$ROOT_DIR/}"

  if [ -z "$desc" ]; then printf '%s: ERROR missing description\n' "$rel" >&2; error_count=$((error_count+1)); fi
  if [ -z "$last" ]; then printf '%s: ERROR missing lastReviewed\n' "$rel" >&2; error_count=$((error_count+1)); fi
  if [ -n "$last" ] && ! echo "$last" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
    printf '%s: ERROR invalid lastReviewed format (YYYY-MM-DD): %s\n' "$rel" "$last" >&2; error_count=$((error_count+1));
  fi

  if [ "$has_hs" -eq 0 ]; then printf '%s: ERROR missing healthScore block\n' "$rel" >&2; error_count=$((error_count+1)); fi
  if [ -z "$(trim "$hs_content")" ]; then printf '%s: ERROR missing healthScore.content\n' "$rel" >&2; error_count=$((error_count+1)); fi
  if [ -z "$(trim "$hs_usability")" ]; then printf '%s: ERROR missing healthScore.usability\n' "$rel" >&2; error_count=$((error_count+1)); fi
  if [ -z "$(trim "$hs_maintenance")" ]; then printf '%s: ERROR missing healthScore.maintenance\n' "$rel" >&2; error_count=$((error_count+1)); fi

  if [ -n "$always" ] && ! echo "$always" | grep -qE '^(true|false)$'; then
    printf '%s: ERROR alwaysApply must be true or false (lowercase)\n' "$rel" >&2; error_count=$((error_count+1));
  fi

  if [ -n "$globs" ] && ! validate_csv "$globs"; then
    printf '%s: ERROR globs must be CSV without spaces, quotes, or braces\n' "$rel" >&2; error_count=$((error_count+1));
  fi
  if [ -n "$overrides" ] && ! validate_csv "$overrides"; then
    printf '%s: ERROR overrides must be CSV without spaces, quotes, or braces\n' "$rel" >&2; error_count=$((error_count+1));
  fi

  # Check references in front matter and in full file content
  if ! check_refs "$rel" "$ROOT_DIR" "$fm"; then
    if [ $FAIL_ON_REFS -eq 1 ]; then error_count=$((error_count+1)); else warn_count=$((warn_count+1)); fi
  fi
  file_content="$(cat "$f")"
  if ! check_refs "$rel" "$ROOT_DIR" "$file_content"; then
    if [ $FAIL_ON_REFS -eq 1 ]; then error_count=$((error_count+1)); else warn_count=$((warn_count+1)); fi
  fi

done

if [ $error_count -ne 0 ]; then
  printf 'Validation failed: %d error(s), %d warning(s)\n' "$error_count" "$warn_count" >&2
  exit 1
fi

printf 'Validation passed: %d file(s), %d warning(s)\n' "${#FILES[@]}" "$warn_count" >&2
exit 0
