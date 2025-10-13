---
---

# Engineering Requirements Document — Shell & Script Tooling (Unified)

Links: [`tasks.md`](./tasks.md) | [`MIGRATION-GUIDE.md`](./MIGRATION-GUIDE.md) | [`PROGRESS.md`](./PROGRESS.md)

## 1. Introduction/Overview

Unify and coordinate shell/script-related initiatives across the repository by referencing existing projects without moving files. This project provides a single place to align goals, reduce duplication, and track cross-cutting decisions while each source project remains authoritative for its own scope.

**Source projects:** 10 (9 original + tests-github-deletion added 2025-10-13)

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
- Tests GitHub Deletion — `docs/projects/tests-github-deletion/erd.md` | tasks: `docs/projects/tests-github-deletion/tasks.md` | **Note: Actively experiencing this issue (tmp-scan/ appeared during session)**

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

**Phase 1-2 (Complete ✅):**

- [x] This ERD exists with links to all ten source projects and their tasks.
- [x] A unified tasks file exists, describing migration/derivation workflow and dual-tracking policy.
- [x] Projects index updated to include this unified project.
- [x] Cross-cutting decisions D1-D5 documented.
- [x] Core libraries implemented: `.lib.sh` enhancements, `.lib-net.sh` seam.
- [x] Validators created: `network-guard.sh`, `help-validate.sh`, `error-validate.sh`.
- [x] ShellCheck runner with portability guarantees.

**Phase 3 (Complete ✅):**

- [x] All network-using scripts migrated to networkless (4/4 scripts).
- [x] Network guard validator: 100% compliant (0 violations).
- [x] Error validation: 100% compliant (strict mode).
- [x] Test coverage: 52 tests, 100% passing.

**Phase 4 (Near Complete):**

- [x] Help documentation migration (32 of 36 scripts complete = 89%).
- [x] Migration pattern established (context-efficiency-gauge.sh example).
- [ ] Fix remaining 4 scripts: pr-create.sh, pr-update.sh, changesets-automerge-dispatch.sh, checks-status.sh.

**Phase 5-6 (Complete):**

- [x] Test isolation and environment hygiene (D6).
- [x] Documentation and CI integration.
- [x] Source project adoption tracking.

**Phase 7 (Future/Optional):**

- [ ] Script directory organization (see Section 11).

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

### D4 — Test Isolation via Network Seams

- Tests must use seams (`CURL_CMD=cat`, `JQ_CMD=jq`) to inject fixtures; never make live API calls.
- Production scripts may make network calls when that's their primary purpose (e.g., GitHub automation).
- `.cursor/scripts/.lib-net.sh` provides test helpers (`net_fixture`) for loading fixture data in test code.
- Guard tests: set `CURL_BIN=false` to verify scripts respect seams and fail if they bypass to live network.
- Fixtures live under `.cursor/scripts/tests/fixtures/` for deterministic test data.
- Reference: `docs/projects/networkless-scripts/erd.md` (test isolation approach).

### D5 — Dependency Portability Policy

- Required dependencies: `bash` (≥4.0), `git` (when in repo context).
- Optional dependencies with graceful degradation: `jq`, `column`, `shellcheck`.
  - Pattern: `have_cmd <tool> || { log_warn "...; skipping/degrading"; exit 0; }`
  - Scripts must function (possibly with reduced UX) when optional deps are absent.
- Network clients (`curl`, `wget`, `gh`, `http`):
  - **Production scripts**: May use curl directly when network is their primary purpose (e.g., GitHub automation per D4)
  - **Tests**: Must use `.lib-net.sh` seam and fixtures; forbidden from making live network calls
- CI/validation tools: may require additional deps but must document and handle absence gracefully.
- Portability targets: macOS (Darwin) primary; prefer POSIX-sh compatible patterns where feasible.
- Reference: this ERD (authoritative for cross-project dependency policy).

### D6 — Test Isolation and Environment Hygiene

- **Problem:** Test runner exports vars (TEST_ARTIFACTS_DIR, ALP_LOG_DIR) in parent shell, causing leakage across tests. Tests can mutate GH_TOKEN and break subsequent runs.
- **Solution:** Test runner isolates each test in a subshell; tests can directly export vars without snapshot/restore boilerplate.
- **Evidence:** tmp-scan/ directory created in repo root; GH_TOKEN corruption observed.

**Implementation Pattern:**

- Test runner: `( export TEST_ARTIFACTS_DIR=...; bash "$test" ) >"$output"` — subshell isolates all env changes
- Scripts: Keep seams (`${CURL_CMD-curl}`, `${JQ_CMD-jq}`) for test flexibility
- Tests: Directly `export VAR=value` without snapshot/restore — runner's subshell handles cleanup
- Temp directories: Use `.test-artifacts/<name>-$$` for test temps (not repo root or system temp)
- Cleanup: `trap "rm -rf '$tmpdir'" EXIT` in each test file

**Refactoring:**

- Remove snapshot/restore patterns from tests (e.g., pr-create.test.sh ORIGINAL_GH_TOKEN logic)
- Rely on runner's subshell for isolation (single point of control)
- Tests become simpler: set vars, run script, assert — no cleanup needed

- Reference: `docs/projects/tests-github-deletion/erd.md` (environment leakage investigation).

Adoption workflow:

- Record each adoption under `docs/projects/<source>/tasks.md` with a backlink to this section and status.
- Keep source ERDs authoritative for detailed behavior and validators.

## 11. Future Considerations

### Script Directory Organization

As the script collection grows (64+ scripts currently), a flat `.cursor/scripts/` directory becomes difficult to navigate. After Phase 3 migrations stabilize, organize scripts into logical subdirectories based on functional groupings.

Proposed structure:

- `.cursor/scripts/git/` — Git workflow helpers (commits, branches, PRs, checks)
- `.cursor/scripts/project/` — Project lifecycle, archival, validation
- `.cursor/scripts/rules/` — Rules validation, listing, attachment, capabilities sync
- `.cursor/scripts/tests/` — Test runners, harnesses, and `fixtures/`
- `.cursor/scripts/lib/` or `.cursor/scripts/_lib/` — Shared libraries (`.lib.sh`, `.lib-net.sh`)

Migration requirements:

- Update all script path references in `.cursor/rules/*.mdc`
- Update CI workflow paths and `.gitignore` patterns
- Add compatibility shims for public entrypoints if needed
- Validate with smoke tests and lifecycle validators

Timing: Defer until Phase 3 migrations complete to avoid churn and allow real usage patterns to inform final groupings.

---

---

## Status Summary (2025-10-13 — COMPLETE)

**Completion:** 100% (All phases complete; directory organization deferred)

**Key Achievements:**

- ✅ 100% help documentation (D1) — All 36 scripts pass `help-validate.sh`
- ✅ 100% strict mode compliance (D2) — All 36 scripts validated by `error-validate.sh`
- ✅ 100% exit code standardization (D3) — 0 warnings, all scripts use catalog
- ✅ 100% test isolation (D4) — Tests use fixtures/seams, never live API
- ✅ 100% portability (D5) — bash + git only; optional tools degrade gracefully
- ✅ 100% env isolation (D6) — Subshell isolation implemented, env leakage resolved
- ✅ Complete infrastructure with validators and test helpers
- ✅ 46 tests covering all critical paths (100% passing)
- ✅ All cross-cutting decisions (D1-D6) fully implemented and adopted
- ✅ CI integration — Validators run on every PR
- ✅ Migration guide published — `MIGRATION-GUIDE.md`
- ✅ Adoption tracking — All 8 source projects updated with status

**Repository Impact:**

- 36 scripts validated for all standards (D1-D6)
- 4 GitHub automation scripts make real API calls in production (per D4 policy)
- Test suite isolated (uses fixtures/seams, never live network)
- 7,520 total lines of shell code
- ~2,200 lines of new infrastructure added
- CI enforcement via `shell-validators.yml` workflow

**Phase 7 (Deferred):**

- Script directory organization (Task 18.0, see Section 11) — defer until usage patterns stabilize

---

Owner: rules-maintainers

Last updated: 2025-10-13
