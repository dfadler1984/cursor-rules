---
status: active
owner: rules-maintainers
---

# Engineering Requirements Document — Script Error Handling (Lite)

Links: `docs/projects/script-error-handling/tasks.md`
Related: `docs/projects/scripts-unix-philosophy/erd.md`, `docs/projects/script-test-hardening/erd.md`, `docs/projects/shell-scripts/erd.md`, `docs/projects/script-help-generation/erd.md`

Mode: Lite

## 1. Introduction/Overview

Ensure every maintained repository script exhibits predictable, safe error handling with clear messages, consistent exit codes, and clean cleanup behavior. Centralize common error helpers in a shared library and enforce adoption via a lightweight validator.

## 2. Goals/Objectives

- Establish a baseline of safety flags and traps for all scripts
- Provide centralized helpers for errors, cleanup, retries, and requirements
- Standardize exit code categories and documentation surfaced in `--help`
- Add a validator that enforces the contract across `.cursor/scripts/*.sh`
- Migrate representative scripts and optionally gate via CI

## 3. Functional Requirements

1. Shared library `.cursor/scripts/.lib.sh`
   - Provide: `enable_strict_mode`, `die`, `warn`, `require_cmd`, `require_var`, `with_tempdir`, `retry`, `on_exit_register`
   - `enable_strict_mode` enables safe defaults (`set -Eeuo pipefail`, IFS sane default) and installs a default `ERR` trap that prints script name, line number, and exit code
   - `retry` supports limited attempts with backoff for fragile network commands
   - `with_tempdir` creates a temporary directory and ensures cleanup on exit
2. Script contract
   - Scripts source `.cursor/scripts/.lib.sh` and call `enable_strict_mode`
   - Scripts provide a `main` function and call it from a thin wrapper
   - User-facing failures call `die` with a concise message and appropriate exit code
   - `--help` includes an Exit Codes section aligned with this ERD and the help-generation project
3. Exit code catalog (reserved)
   - 2: usage error (invalid/missing args)
   - 3: configuration error (missing env/config)
   - 4: dependency missing (required tool not found)
   - 5: network failure (including API non-2xx)
   - 6: timeout
   - 20: internal error (unexpected exception)
4. Validator CLI `.cursor/scripts/error-validate.sh`
   - Discovers `.cursor/scripts/*.sh` excluding `*.test.sh`
   - Asserts: sourcing `.lib.sh`, `enable_strict_mode` present, safe flags/traps in effect, and help includes Exit Codes section
   - Prints a concise report and exits non-zero when violations are found

## 4. Acceptance Criteria

- 100% of maintained scripts in `.cursor/scripts/` pass `error-validate.sh`
- Representative scripts are migrated to use `.lib.sh` helpers and strict mode
- Failures produce a single-line error with script:line and exit code; temporary artifacts are cleaned
- Networked scripts use `retry` or otherwise justify not doing so

## 5. Non-Functional Requirements

- Portability: bash-first on macOS; avoid GNU-only flags when possible
- Performance: overhead of helpers negligible; validator runs in < 2s for ≤25 scripts
- Security: do not echo secrets in error messages; redact sensitive values in logs

## 6. Architecture/Design

- Effects isolated behind helpers in `.lib.sh` to keep scripts readable and consistent
- Validator prefers simple grep/awk checks over parsing shell ASTs; allow explicit bypass comments for rare cases
- Exit code catalog documented once and referenced from `--help` outputs

## 7. Risks/Edge Cases

- `set -e` pitfalls in subshells and pipelines; require `set -o pipefail` and careful `|| true` where intended
- Legacy scripts may rely on implicit globals; migration must be incremental
- Overzealous validation could block legitimate patterns; support targeted bypass tags

## 8. Rollout & Ops

- Phase 1: implement `.lib.sh` helpers and `error-validate.sh`
- Phase 2: migrate 3–5 core scripts (e.g., `alp-logger.sh`, `pr-create.sh`, `pr-update.sh`)
- Phase 3: optionally add CI step to run `error-validate.sh` on PRs

## 9. Success Metrics

- 100% of maintained scripts pass validation
- Error outputs are concise and actionable; fewer flaky failures attributed to unhandled errors
- Migration completed for core scripts with helpers reused across new scripts
