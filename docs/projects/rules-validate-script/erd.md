---
---

# Rules Validation Script Enhancements — Lite ERD

Mode: Lite

## Introduction/Overview

Add a repository-local validator (.cursor/scripts/rules-validate.sh) that scans .cursor/rules/*.mdc for common correctness and consistency issues. The goal is to automate detection of front matter problems, CSV/boolean format violations, deprecated references, and specific typos or regressions found during recent maintenance.

## Goals/Objectives

- Automate validation of rule front matter and key content conventions
- Provide clear, actionable diagnostics with file and line context
- Exit non-zero on violations; zero when clean to enable CI use
- Remain dependency-free (POSIX tools only) and fast (<2s on this repo)

## Functional Requirements

1. Front matter checks (per front-matter.mdc):
   - Require description, lastReviewed (YYYY-MM-DD), and healthScore.{content,usability,maintenance}
   - Validate lastReviewed format with regex; do not auto-change dates
2. CSV fields (if present):
   - In globs and overrides, forbid spaces around commas (,)
   - Forbid brace expansion {}; require separate CSV entries
3. Boolean fields:
   - alwaysApply must be lowercase, unquoted true|false
4. Deprecated references:
   - Flag assistant-learning-log.mdc references; recommend logging-protocol.mdc
5. Common content issues:
   - Flag ev\s+ents (typo across "events")
6. Rule-specific invariants:
   - In tdd-first.mdc, globs must include **/*.cjs
7. Output formatting:
   - Print path:line: message for each violation
   - Summarize counts and exit with non-zero status if any issues

## Acceptance Criteria

- Running bash .cursor/scripts/rules-validate.sh on current HEAD prints no errors and exits 0
- Introducing any of the violations above produces targeted messages and non-zero exit
- Script uses only bash, grep, sed, awk, and find
- Works on macOS (BSD tools) without GNU extensions

## Risks/Edge Cases

- BSD vs GNU regex differences; prefer portable grep -E and awk
- False positives on backticked examples; restrict scans to front matter where applicable
- Performance regressions if scanning non-rules paths; constrain to .cursor/rules/*.mdc

## Rollout Note

- Owner: Rules/Infra
- Flag: rules-validate-v1
- Date: 2025-10-02
- Plan: land script -> add CI step -> optionally wire a pre-commit hook (advisory)
