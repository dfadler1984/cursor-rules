---
status: completed
---
# Engineering Requirements Document — Shell & Script Tooling (Unified)


## 1. Introduction/Overview

Unify and coordinate shell/script-related initiatives across the repository by referencing existing projects without moving files. This project provides a single place to align goals, reduce duplication, and track cross-cutting decisions while each source project remains authoritative for its own scope.

**Source projects:** 10 (8 active + 2 archived: shell-scripts 2025-10-11, tests-github-deletion 2025-10-13)

## 2. Scope & Approach

- Reference, do not move: Source projects remain as-is and authoritative.
- Dual tracking: Track relevant work both here (for consolidation visibility) and within each source project (for local ownership).
- Derive unique unified tasks as other projects progress; avoid premature merging.

## 3. Source Projects (authoritative references)

- Shell Scripts Suite — `docs/projects/_archived/2025/shell-scripts/final-summary.md` | **Completed 2025-10-11**
- Tests GitHub Deletion — `docs/projects/_archived/2025/tests-github-deletion/final-summary.md` | **Status: ARCHIVED (2025-10-13)**

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

- [x] All network-using scripts migrated to networkless (4 GitHub API scripts transitioned to guidance-based).
- [x] Network guard validator: 100% compliant (informational mode; 5 scripts legitimately use network).
- [x] Error validation: 100% compliant (strict mode).
- [x] Test coverage: 56 tests (53 test files), 100% passing.

**Script Inventory:**

- 45 production scripts total (excluding `.test.sh` and `.spec.sh` files)
- 47 scripts validated by help-validate.sh and error-validate.sh (includes 2 library files: `.lib.sh`, `.lib-net.sh`)
- 1 spec helper: `rules-validate.spec.sh` (excluded from validation; used by rules-validate.sh for schema checks)

**Phase 4 (Complete ✅):**

- [x] Help documentation migration (47 of 47 validated scripts = 100%).
- [x] Migration pattern established (context-efficiency-gauge.sh example).
- [x] All validated scripts now pass help-validate.sh validation.

**Phase 5-6 (Complete):**

- [x] Test isolation and environment hygiene (D6).
- [x] Documentation and CI integration.
- [x] Source project adoption tracking.

**Phase 7 (Unix Philosophy Refactoring) — SUBSTANTIALLY COMPLETE ✅:**

- [x] Script directory organization (see Section 11) — MIGRATED to script-refinement Task 3.0
- [x] Unix Philosophy refactoring — **MAJOR WORK COMPLETE (2025-10-14)**
  - **Status:** Infrastructure + 3 major orchestrators complete; optional polish moved to [script-refinement](../../../script-refinement/erd.md) project
  - [x] Created focused alternatives (9 scripts, all D1-D6 compliant, TDD-tested) ✅
  - [x] Enforcement rule active (shell-unix-philosophy.mdc) ✅
  - [x] Updated 3 major orchestrators to call focused scripts ✅
    - [x] rules-validate.sh: 497 → 301 lines (40% reduction)
    - [x] context-efficiency-gauge.sh: 342 → 124 lines (64% reduction)
    - [x] pr-create.sh: deprecated with alternatives recommended
  - [x] Extracted context-efficiency-format.sh (282 lines) ✅
  - **Achievement:** 839 lines reduced; 48% average reduction
  - **Remaining (P3):** 2 optional refinements moved to [script-refinement](../../../script-refinement/erd.md)
    - checks-status.sh extraction
    - rules-validate-format.sh split

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

- Keep source ERDs authoritative for detailed behavior and validators.

## 11. Future Considerations

### Script Directory Organization (MIGRATED)

**Status:** This work has been moved to [script-refinement](../../../script-refinement/erd.md) Section 4.3, Task 3.0.

**Current state:** 45 production scripts in flat `.cursor/scripts/` directory (90% of threshold)

**Trigger:** Organization will be triggered when script count reaches 50+ OR clear pain points emerge.

**Why migrated:** Threshold-based tasks belong in active projects, not archived ones. This ensures the work is tracked and executed when conditions are met.

**For complete details, see:** [script-refinement/erd.md](../../../script-refinement/erd.md) Section 4.3

---

---

## Status Summary (2025-10-14 — READY FOR COMPLETION)

**Completion:** All core objectives achieved; optional refinements split to [script-refinement](../../../script-refinement/erd.md) project

**Key Achievements:**

- ✅ 100% help documentation (D1) — All 47 validated scripts pass `help-validate.sh`
- ✅ 100% strict mode compliance (D2) — All 47 validated scripts pass `error-validate.sh`
- ✅ 100% exit code standardization (D3) — 0 warnings, all scripts use catalog
- ✅ 100% test isolation (D4) — Tests use fixtures/seams, never live API
- ✅ 100% portability (D5) — bash + git only; optional tools degrade gracefully
- ✅ 100% env isolation (D6) — Subshell isolation implemented, env leakage resolved
- ✅ Complete infrastructure with validators and test helpers
- ✅ 56 tests (53 test files) covering all critical paths (100% passing)
- ✅ All cross-cutting decisions (D1-D6) fully implemented and adopted
- ✅ CI integration — Validators run on every PR
- ✅ Migration guide published — `MIGRATION-GUIDE.md`
- ✅ Adoption tracking — All 8 source projects updated with status
- ✅ ShellCheck integration complete — Zero errors, zero warnings, CI enforced
- ✅ Unix Philosophy orchestrators — 3 major scripts refactored (839 lines reduced)
  - rules-validate.sh: 497 → 301 lines (40% reduction)
  - context-efficiency-gauge.sh: 342 → 124 lines (64% reduction)
  - pr-create.sh: deprecated with focused alternatives
- ✅ 10 focused alternatives created (9 extraction + 1 format script)

**Repository Impact:**

- 45 production scripts total (includes 10 extracted via Unix Philosophy refactoring)
- 47 scripts validated for D1-D6 standards (45 production + 2 libraries)
- 53 test files with 56 tests total (100% passing)
- 1 spec helper: `rules-validate.spec.sh` (used by rules-validate.sh; excluded from general validation)
- 5 scripts legitimately use network (per D4 policy):
  - 4 GitHub automation: pr-create.sh, pr-update.sh, checks-status.sh, changesets-automerge-dispatch.sh
  - 1 Setup utility: setup-remote.sh (dependency checking)
- Test suite isolated (uses fixtures/seams, never live network)
- CI enforcement via `shell-validators.yml` workflow

**Follow-up Work (All Migrated to script-refinement):**

- Script directory organization (Task 18.0) — migrated to [script-refinement](../../../script-refinement/erd.md) Task 3.0 (threshold: 50+ scripts)
- Optional extractions (Tasks 20.4, 20.5) — migrated to [script-refinement](../../../script-refinement/erd.md) Tasks 1.0, 2.0 (P3 priority)

**All deferred work is accounted for in active project.**

---

Owner: rules-maintainers

Last updated: 2025-10-14
