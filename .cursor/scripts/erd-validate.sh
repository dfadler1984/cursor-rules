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
dir=$(dirname "$file")
base=$(basename "$dir")

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

# Additional front matter checks for project ERDs under docs/projects/*/erd.md
if echo "$file" | grep -Eq "/docs/projects/[^/]+/erd\\.md$"; then
  head_block=$(head -n 50 "$file" || true)
  # status must be active or completed (case-insensitive compare on key only)
  if ! echo "$head_block" | grep -iqE '^status:[[:space:]]*(active|completed)$'; then
    printf "%s:%s: %s\n" "$file" 1 'front matter: status must be active|completed'
    fail=$((fail+1))
  fi
  # owner must be present (non-empty)
  if ! echo "$head_block" | grep -iqE '^owner:[[:space:]]*\S'; then
    printf "%s:%s: %s\n" "$file" 1 'front matter: owner missing'
    fail=$((fail+1))
  fi
  # lastUpdated must be valid ISO date
  if ! echo "$head_block" | grep -Eq '^lastUpdated:[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
    printf "%s:%s: %s\n" "$file" 1 'front matter: lastUpdated must be YYYY-MM-DD'
    fail=$((fail+1))
  fi
fi

if [ "$fail" -gt 0 ]; then
  echo "erd-validate: $fail issue(s) found" >&2
  exit 1
fi
echo "erd-validate: OK"
exit 0


