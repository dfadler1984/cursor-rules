---
---

# Engineering Requirements Document — Shell & Script Tooling (Unified)

Links: `docs/projects/shell-and-script-tooling/tasks.md`

## 1. Introduction/Overview

Unify and coordinate shell/script-related initiatives across the repository by referencing existing projects without moving files. This project provides a single place to align goals, reduce duplication, and track cross-cutting decisions while each source project remains authoritative for its own scope.

## 2. Scope & Approach

- Reference, do not move: Source projects remain as-is and authoritative.
- Dual tracking: Track relevant work both here (for consolidation visibility) and within each source project (for local ownership).
- Derive unique unified tasks as other projects progress; avoid premature merging.

## 3. Source Projects (authoritative references)

- Bash Script Standards — `docs/projects/bash-scripts/erd.md` | tasks: `docs/projects/bash-scripts/tasks.md`
- Shell Scripts Suite — `docs/projects/_archived/2025/shell-scripts/final-summary.md` | **Completed 2025-10-11**
- Scripts & Unix Philosophy — `docs/projects/scripts-unix-philosophy/erd.md` | tasks: `docs/projects/scripts-unix-philosophy/tasks.md`
- Script Rules (best practices) — `docs/projects/script-rules/erd.md` | tasks: `docs/projects/script-rules/tasks.md`
- Script Help Generation — `docs/projects/script-help-generation/erd.md` | tasks: `docs/projects/script-help-generation/tasks.md`
- Script Error Handling — `docs/projects/script-error-handling/erd.md` | tasks: `docs/projects/script-error-handling/tasks.md`
- Script Test Hardening — `docs/projects/script-test-hardening/erd.md` | tasks: `docs/projects/script-test-hardening/tasks.md`
- ShellCheck Adoption — `docs/projects/shellcheck/erd.md` | tasks: `docs/projects/shellcheck/tasks.md`
- Networkless Scripts — `docs/projects/networkless-scripts/erd.md` | tasks: `docs/projects/networkless-scripts/tasks.md`

## 4. Goals/Objectives

- Provide a cohesive vision spanning standards, help UX, predictable errors, tests, linting, and offline capability.
- Reduce duplication and contradictions across script-related projects.
- Establish a small set of shared, adoption-ready decisions that individual suites can opt into.
- Maintain project-level autonomy while enabling cross-project coordination.

## 5. Functional Requirements

### 5.1 Reference Integration

- Each source project link must be present (ERD + tasks) and kept current.
- This ERD may define cross-cutting decisions; adoptions occur in source projects with explicit links back here.

### 5.2 Tracking & Synchronization

- When creating a unified task here, add a corresponding entry or link in the relevant source project tasks.
- Include backlinks: from source tasks to this ERD (section or task) for traceability.

### 5.3 Governance & Ownership

- Owner: rules-maintainers
- Decision notes recorded as short entries with date, scope, and impacted projects.

## 6. Acceptance Criteria

- This ERD exists with links to all nine source projects and their tasks.
- A unified tasks file exists, describing migration/derivation workflow and dual-tracking policy.
- Optional: Projects index updated to include this unified project.

## 7. Risks/Edge Cases

- Drift between unified guidance and project specifics — mitigated by explicit backlinks and minimal shared decisions.
- Over-centralization — mitigated by keeping source projects authoritative and adopting changes opt-in.

## 8. Rollout

- Comms: Link this project from the projects index once validated.
- Iteration: Start by referencing; derive unified tasks as individual projects progress.

## 9. Validation

- Manual check: all links resolve locally.
- Cross-reference check: new decisions recorded here have corresponding adoption notes in source projects.

## 10. Cross-cutting Decisions (Draft)

These proposals centralize defaults; adoptions occur in source projects with explicit backlinks.

### D1 — Help/Version Minimums and Section Schema

- Minimum flags: `-h|--help`, `--version` required for all maintained scripts.
- Help sections: Name, Synopsis, Description, Options, Environment, Examples, Exit Codes.
- Reference: `docs/projects/script-help-generation/erd.md` (validator/generator authority).

### D2 — Strict Mode Baseline and Traps

- Require sourcing `.cursor/scripts/.lib.sh` and calling `enable_strict_mode` or equivalent.
- Safety: `set -Eeuo pipefail`, sane `IFS`, default `ERR` trap with script:line print.
- Reference: `docs/projects/script-error-handling/erd.md` (helpers and validator).

### D3 — Error Semantics and Exit Code Catalog

- Reserve codes: 2 usage, 3 config, 4 dependency missing, 5 network failure, 6 timeout, 20 internal.
- User-facing failures use a `die` helper; concise stderr lines; stdout remains machine-output only.
- Reference: `docs/projects/script-error-handling/erd.md`.

### D4 — Networkless Effects Seam Defaults

- Introduce `.cursor/scripts/.lib-net.sh` with `net_request` that never performs HTTP.
- Require fixtures/guidance instead of live requests; honor `CURL_BIN=false`, `HTTP_BIN=false`.
- Reference: `docs/projects/networkless-scripts/erd.md`.

Adoption workflow:

- Record each adoption under `docs/projects/<source>/tasks.md` with a backlink to this section and status.
- Keep source ERDs authoritative for detailed behavior and validators.

---

Owner: rules-maintainers

Last updated: 2025-10-11
