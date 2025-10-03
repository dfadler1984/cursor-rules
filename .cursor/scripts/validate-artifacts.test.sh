#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
SCRIPT="$ROOT_DIR/.cursor/scripts/validate-artifacts.sh"

TMP_DIR="$ROOT_DIR/docs/examples/validator-spec"
rm -rf "$TMP_DIR" || true
mkdir -p "$TMP_DIR"

# 1) Create an invalid spec missing required headings
INVALID_SPEC="$TMP_DIR/invalid-feature-spec.md"
cat > "$INVALID_SPEC" <<'MD'
# invalid-feature Spec

## Overview

## Goals

## Functional Requirements

## Risks/Edge Cases

[Links: Plan | Tasks]
MD

set +e
out="$($SCRIPT --paths "$INVALID_SPEC" 2>&1)"
status=$?
set -e

[ $status -ne 0 ] || { echo "expected non-zero exit for missing headings"; echo "$out"; exit 1; }
echo "$out" | grep -q "missing required heading: Acceptance Criteria" || { echo "missing expected error message"; echo "$out"; exit 1; }

exit 0

