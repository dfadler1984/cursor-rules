---
status: active
owner: rules-maintainers
---

# Engineering Requirements Document — Script Test Hardening (Lite)

Links: `.cursor/scripts/tests/run.sh` | `docs/projects/script-test-hardening/tasks.md`

## 1. Introduction/Overview

Tests for shell scripts sometimes mutate global environment variables (e.g., `GITHUB_TOKEN`) and leak state across runs. Harden scripts and tests to avoid global env dependence and make tests isolated and reproducible.

## 2. Goals/Objectives

- Parameterize environment inputs for scripts (prefer flags over implicit env reads)
- Provide safe shims for env access with override hooks in tests
- Ensure tests snapshot/restore env and never leak changes
- Add lints/checks to catch unsafe exports/unsets in tests

## 3. Functional Requirements

- Scripts accept a `--token <value>` (or similar) to override env-based tokens
- When flag not provided, scripts may read from env, but tests must pass explicit flags
- Test harness snapshots env and restores after each test file
- Add a minimal `env-get` helper in `.cursor/scripts/.lib.sh` that centralizes env reads

## 4. Acceptance Criteria

- No test leaves `GITHUB_TOKEN` (or other critical vars) altered after execution
- `pr-update.sh` and `pr-create.sh` support explicit token flags for tests
- Focused run shows passing behavior without profile sourcing
- README updated with guidance on flags vs env and test patterns

## 5. Risks/Edge Cases

- Backward compatibility: flags must be optional for users relying on env
- CI masks/secrets handling; avoid logging sensitive values
- jq/curl availability remains required when performing API calls
