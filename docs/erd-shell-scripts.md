# Engineering Requirements Document — Shell Scripts Suite

Mode: Lite

## 1. Introduction/Overview

Create a cohesive suite of shell scripts to replace Node/yarn-based helpers with portable, documented CLI tooling. Target macOS (Darwin) with bash, preferring POSIX-compatible sh where practical. Scripts cover rules metadata, validation, Git helpers, PR creation, security scanning, workflow linting, and preflight checks.

## 2. Goals/Objectives

- Provide fast, dependency-light CLI scripts runnable on macOS with bash
- Standardize logging, strict modes, and exit codes across all scripts
- Minimize external deps; allow `jq`, `curl`, and `actionlint` when needed
- Document usage, env vars, and outputs in `README.md`

## 3. Functional Requirements

1. rules:list — Print a table/JSON of rule files and front matter
2. rules:validate — Validate front matter (required fields, dates) and cross-references
3. git:commit — Generate Conventional Commits (header/body/footers; breaking changes)
4. git:branch-name — Suggest and validate branch names from git config/remote
5. pr:create — Create a PR via GitHub API using `GITHUB_TOKEN` and `curl`
6. security:scan — Run a basic advisory scan (documented minimal approach)
7. lint:workflows — Run `actionlint` over `.github/workflows/` if present
8. preflight — Sanity check core configs (present/absent) and print guidance

## 4. Acceptance Criteria

- Each script:
  - Uses `#!/usr/bin/env bash`, `set -euo pipefail`, and `IFS` safety
  - Has `-h|--help` and `--version` (static/version file) options
  - Emits clear logs to stderr and machine-readable output to stdout when relevant
  - Returns non-zero exit code on failure with concise error
- `pr:create` reads `GITHUB_TOKEN` from env; fails with guidance if missing
- `rules:validate` fails on missing required fields or invalid dates (YYYY-MM-DD)
- `rules:list` supports `--format json|table` (default table)
- `lint:workflows` is a no-op if directory missing; exits 0 with note
- `preflight` prints explicit next steps when assets are missing (jest config, scripts, docs)
- Tests: each script has shell tests covering help, success, failure, and no-op cases; enforce strict exit codes
- Structure/locations:
  - All scripts live under `.cursor/scripts/`
  - Tests are named `*.test.sh` and discovered under `.cursor/scripts/` (the runner also supports `scripts/*.test.sh` during transition)
  - Do not expose via package.json; scripts are standalone executables

## 5. Risks/Edge Cases

- jq/actionlint availability: provide install guidance and degrade gracefully
- File naming differences or future rule locations: allow path args and defaults
- Rate limits/permissions on GitHub API: detect 401/403/422 and print next steps

## 6. Rollout Note

- Flag: shell-scripts-suite • Owner: eng-tools • Target: 2025-10-01

## 7. Testing

- Location: store tests alongside their owners under `.cursor/scripts/` (preferred)
- Discovery: the runner finds `*.test.sh` under `.cursor/scripts/`
- Harness: lightweight bash runner (`.cursor/scripts/tests/run.sh`), no `package.json`
- Fixtures: place under a local `tests/fixtures/` subdirectory near the tests as needed

---

### Convert to Full ERD

- Add Architecture/Design (script layout, helpers, shared lib)
- Add Data Model (output schemas for JSON modes)
- Add API Contracts (GitHub endpoints, request/response snippets)
- Add Ops (versioning strategy, changelog, distribution)
- Expand Non-Functional Requirements (portability matrix, performance budgets)
