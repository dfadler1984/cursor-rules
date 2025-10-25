---
status: active
owner: repo-maintainers
created: 2025-10-24
lastUpdated: 2025-10-24
---

# Engineering Requirements Document — Pre-commit Shell Executable Bit (Lite)

Mode: Lite

## 1. Overview

Prevent committing non-executable shell scripts. A pre-commit hook blocks commits when staged .sh files lack the executable bit.

## 2. Scope and Non-Goals

- Scope: Check staged .sh files for executable bit during pre-commit.
- Non-Goals: Linting, style, runtime tests (handled by other projects).

## 3. Requirements

1. Identify staged files matching pattern: \*.sh
2. Check each file is executable (test -x path)
3. On any violation, list files and exit non-zero
4. Provide remediation hint (chmod +x <file> && git add <file>)

## 4. Implementation Notes

- Hook location: repository-managed hooks via core.hooksPath (e.g., .githooks/pre-commit)
- Portability: POSIX sh, no network
- Staged-only: derive file list from git index
- TDD: add focused shell tests in related testing project

## 5. Acceptance

- This ERD and tasks.md exist in docs/projects/pre-commit-shell-executable/
- A pre-commit hook script exists that enforces executable bit for staged .sh files
- Docs include how to enable hooks and validate locally

## 6. Ownership

- Owner: rules-maintainers
- Last updated: 2025-10-11

## 7. Links

- Tasks: docs/projects/pre-commit-shell-executable/tasks.md
- Related: docs/projects/\_archived/2025/shell-and-script-tooling/final-summary.md
