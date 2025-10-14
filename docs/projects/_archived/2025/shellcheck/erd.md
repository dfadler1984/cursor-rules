# Engineering Requirements Document — ShellCheck Adoption

Mode: Full

## 1. Introduction/Overview

Adopt ShellCheck as a standard linter for all shell scripts under `.cursor/scripts/` and other designated shell locations. Provide local usage, optional CI integration, and guardrails so contributors can easily lint and fix shell scripts with consistent defaults.

### Uncertainty / Assumptions

- [NEEDS CLARIFICATION: Target directories beyond `.cursor/scripts/**.sh`?]
- [NEEDS CLARIFICATION: Include CI workflow now or later?]
- Assumption: macOS (Darwin) primary; POSIX‑portable scripts preferred.

## 2. Goals/Objectives

- Establish a consistent ShellCheck configuration and usage.
- Provide a local runner script and clear fix workflow.
- Optionally integrate a CI job to enforce lint on PRs.
- Document scope, exclusions, and how to suppress with rationale.

## 3. User Stories

- As a maintainer, I want shell scripts linted consistently to reduce defects.
- As a contributor, I want a simple command to lint/fix my scripts locally.
- As a reviewer, I want CI to flag ShellCheck issues with clear guidance.

## 4. Functional Requirements

1. Local Linting
   - Provide `./.cursor/scripts/shellcheck-run.sh` to lint target scripts.
   - Support `--paths <CSV>` to override defaults; default to `.cursor/scripts/**/*.sh`.
   - Support `--exclude <CSV>` for rule codes and `--severity <level>`.
   - Exit non‑zero on findings; print summary and remediation hints.
2. Configuration
   - Add `.shellcheckrc` with project defaults (severity, exclusions if any).
   - Document how to suppress (`# shellcheck disable=SCXXXX` with reason).
3. CI (optional)
   - Provide a workflow example `shellcheck.yml` that runs on PRs touching `*.sh`.
   - CI prints annotations or a concise report and fails on new issues.
4. Documentation
   - ERD + `tasks.md` describe scope, commands, and CI option.

## 5. Non-Functional Requirements

- Fast and deterministic on macOS; no network required after install.
- Clear, scannable output with file:line:code and short descriptions.
- Portable paths and no reliance on project-specific package managers.

## 6. Architecture/Design

- Local wrapper script invokes `shellcheck` with defaults from `.shellcheckrc` and CLI flags.
- Paths gathered via `find` with safe quoting; ignore vendor/temp paths.
- CI uses matrix-free single job; optional caching not required.

## 7. Data Model and Storage

- No persistent data; optional `.shellcheckrc` stored at repo root.

## 8. API/Contracts

- CLI contract for `shellcheck-run.sh`:
  - `--paths <csv>` — override default globs
  - `--exclude <csv>` — pass-through to ShellCheck `-e`
  - `--severity <level>` — pass-through to ShellCheck `-S`
  - `-h|--help` — usage info; `--version` prints tool version if available

## 9. Integrations/Dependencies

- Tooling: `shellcheck` binary available on PATH.
- Optional CI: GitHub Actions workflow using `ludeeus/action-shellcheck` or direct install.

## 10. Edge Cases and Constraints

- Absent `shellcheck` binary: script prints install guidance and exits non‑zero (configurable soft‑fail flag later).
- Large script sets: allow `--paths` narrowing and `-k` keyword filter in future.
- Mixed extensions: consider `**/*.sh` plus executable files with shebang in later phase.

## 11. Testing & Acceptance

- Shell tests for the runner under `.cursor/scripts/tests/` cover:
  - Help/usage exit 0; missing binary error path (non‑zero).
  - Linting a known-bad sample returns non‑zero and prints SC code.
  - Excluding that SC code returns 0.
- Acceptance: running the runner over `.cursor/scripts/**/*.sh` succeeds on current repo or reports issues with clear guidance.

## 12. Rollout & Ops

- Phase 1: Local runner + docs.
- Phase 2: Optional CI workflow.
- Rollback: remove CI job; keep local runner optional.

## 13. Success Metrics

- New shell scripts pass lint locally before PR.
- Reduced review time on shell changes.
- CI failures for shell lint are rare after adoption period.

## 14. Open Questions

- [NEEDS CLARIFICATION: Should we lint executable files without .sh extension?]
- [NEEDS CLARIFICATION: Default severity level and exclusions?]
