#!/usr/bin/env bash
set -euo pipefail

# Simple ERD validator
# Usage: .cursor/scripts/erd-validate.sh docs/projects/<feature>/erd.md

file="${1:-}"
if [ -z "$file" ] || [ ! -f "$file" ]; then
  echo "usage: $0 path/to/docs/projects/<feature>/erd.md" >&2
  exit 2
fi

fail=0

# Detect code fences and count front matter separators outside fences
awk_out=$(awk -v file="$file" '
  BEGIN{inCode=0; sepCount=0; firstNonEmptySeen=0; issues=0}
  /^```/ { inCode = 1 - inCode; next }
  {
    if ($0 !~ /^\s*$/ && $0 !~ /^---[ \t]*$/ && firstNonEmptySeen==0) {
      firstNonEmptySeen=NR
    }
  }
  /^---[ \t]*$/ && !inCode {
    sepCount++
    if (sepCount==1) {
      # Opening front matter must be the very first non-empty thing
      if (firstNonEmptySeen!=0) {
        printf "%s:%d: front matter separator not at file start\n", file, NR; issues++
      }
    } else if (sepCount>2) {
      printf "%s:%d: extra front matter separator detected\n", file, NR; issues++
    }
  }
  END{ if (issues>0) exit 1 }
' "$file") || fail=$((fail+1))

if [ -n "${awk_out:-}" ]; then
  printf "%s\n" "$awk_out"
fi

# Basic structure checks (lightweight)
if ! grep -qE '^#\s+Engineering Requirements Document' "$file"; then
  printf "%s:%s: %s\n" "$file" 1 'missing H1 ERD title'
  fail=$((fail+1))
fi
if ! grep -qE '^Mode:' "$file"; then
  printf "%s:%s: %s\n" "$file" 1 'missing Mode line'
  fail=$((fail+1))
fi

if [ "$fail" -gt 0 ]; then
  echo "erd-validate: $fail issue(s) found" >&2
  exit 1
fi
echo "erd-validate: OK"
exit 0


