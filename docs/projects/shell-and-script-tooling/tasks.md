## Tasks — Shell & Script Tooling (Unified)

## Relevant Files

- `docs/projects/shell-and-script-tooling/erd.md`
- `.cursor/scripts/.lib.sh` — shared helpers (exit codes, strict mode, tempdir, help functions)
- `.cursor/scripts/.lib-net.sh` — network effects seam (no-network policy)
- `.cursor/scripts/shellcheck-run.sh` — ShellCheck runner with graceful degradation
- `.cursor/scripts/tests/fixtures/` — network request fixtures

## Todo

### Phase 1: Infrastructure (Completed)

- [x] 1.0 Create unified project scaffold (ERD + tasks) with references
- [x] 2.0 Add this project to `docs/projects/README.md` under Active
- [x] 3.0 For each source project, add a backlink to this ERD
  - [x] 3.1 `bash-scripts/tasks.md` → add link to unified project
  - [x] 3.2 `shell-scripts/tasks.md` → add link to unified project
  - [x] 3.3 `scripts-unix-philosophy/tasks.md` → add link to unified project
  - [x] 3.4 `script-rules/tasks.md` → add link to unified project
  - [x] 3.5 `script-help-generation/tasks.md` → add link to unified project
  - [x] 3.6 `script-error-handling/tasks.md` → add link to unified project
  - [x] 3.7 `script-test-hardening/tasks.md` → add link to unified project
  - [x] 3.8 `shellcheck/tasks.md` → add link to unified project
  - [x] 3.9 `networkless-scripts/tasks.md` → add link to unified project
  - [x] 3.10 `tests-github-deletion/tasks.md` → add link to unified project (added 2025-10-13)
- [x] 4.0 Derive cross-cutting decisions and portability policy
  - [x] 4.1 D1: Help/version flags minimums and section schema
  - [x] 4.2 D2: Strict-mode baseline and traps
  - [x] 4.3 D3: Error semantics and exit code catalog
  - [x] 4.4 D4: Networkless effects seam defaults
  - [x] 4.5 D5: Dependency portability policy
  - [x] 4.6 D6: Test isolation and environment hygiene (added 2025-10-13)

### Phase 2: Core Library Implementation (Completed)

- [x] 5.0 Implement `.lib.sh` enhancements
  - [x] 5.1 Add exit code constants (D3)
  - [x] 5.2 Add `enable_strict_mode()` function (D2)
  - [x] 5.3 Add `with_tempdir()` cleanup helper
  - [x] 5.4 Add help template functions (D1): `print_help_header`, `print_usage`, `print_options`, `print_option`, `print_exit_codes`, `print_examples`, `print_example`
  - [x] 5.5 Add owner tests: `.lib.test.sh` (exit codes, have_cmd, help functions, json_escape)
- [x] 6.0 Implement network effects seam (D4)
  - [x] 6.1 Create `.lib-net.sh` with `net_request`, `net_fixture`, `net_guidance`, `is_dry_run`
  - [x] 6.2 Create fixtures directory structure under `.cursor/scripts/tests/fixtures/`
  - [x] 6.3 Add example GitHub API fixtures (PR, checks)
  - [x] 6.4 Document fixtures usage in README
  - [x] 6.5 Add owner tests: `.lib-net.test.sh` (net_request dies, fixture loading, guidance)
- [x] 7.0 Implement ShellCheck runner (D5)
  - [x] 7.1 Create `shellcheck-run.sh` with graceful degradation
  - [x] 7.2 Support `--paths`, `--exclude`, `--severity`, `--format` options
  - [x] 7.3 Exit 0 when shellcheck not found (portability)
  - [x] 7.4 Use help template functions for consistent output
  - [x] 7.5 Add owner tests: `shellcheck-run.test.sh` (help, version, missing tool handling)

### Phase 3: Validators and Network Migration (COMPLETE ✅)

- [x] 9.0 Create validators for cross-cutting decisions
  - [x] 9.1 Create `help-validate.sh` (validates help sections per D1) — ✅ 100% compliant (46 scripts)
  - [x] 9.2 Create `error-validate.sh` (validates strict mode and exit codes per D2/D3) — ✅ 100% compliant (46 scripts)
  - [x] 9.3 Create `network-guard.sh` (validates network usage per D4/D5) — ✅ Informational (5 scripts legitimately use network)
- [x] 8.0 Migrate all network-using scripts to networkless standard
  - [x] 8.1 Update `pr-create.sh` to use `.lib-net.sh` seam ✅ COMPLETE
  - [x] 8.2 Update `pr-update.sh` to use `.lib-net.sh` seam ✅ COMPLETE
  - [x] 8.3 Update `checks-status.sh` to use `.lib-net.sh` seam ✅ COMPLETE
  - [x] 8.4 Update `changesets-automerge-dispatch.sh` to use `.lib-net.sh` seam ✅ COMPLETE
  - [x] 8.5 Add suppression mechanism to network-guard for false positives
  - [x] 8.6 All migration tests passing (10 test suites, 40+ tests total)
- [x] 10.0 Record adoption status in source projects (COMPLETE ✅)
  - [x] 10.1 Update adoption checklist in each source project's tasks.md (bash-scripts, script-help-generation, networkless-scripts, script-error-handling, script-rules, scripts-unix-philosophy, shellcheck, script-test-hardening) ✅
  - [x] 10.2 Add backlinks from adoptions to this ERD's decision sections ✅
  - [x] 10.3 Track migration progress (scripts migrated vs total) ✅
  - Status: All 8 source projects updated with D1-D6 adoption status (all complete); backlinks to ERD sections included

### Phase 4: Help Documentation Migration (COMPLETE ✅)

- [x] 8.5 Migrate all scripts to use help template functions (46/46 = **100% complete**)
  - [x] All 46 validated scripts pass `help-validate.sh` ✅
  - [x] 8.5.1 Fix pr-create.sh: add missing Options section ✅
  - [x] 8.5.2 Fix pr-update.sh: add missing Options, Examples, Exit Codes sections ✅
  - [x] 8.5.3 Fix changesets-automerge-dispatch.sh: add missing Options, Examples, Exit Codes sections ✅
  - [x] 8.5.4 Fix checks-status.sh: add missing Examples, Exit Codes sections ✅
  - [x] 8.5.5 setup-remote.sh: included in validation (dependency checking script) ✅
  - [x] Migrated in batches: all scripts enhanced with complete help

### Phase 5: Test Isolation Fix (D6 Implementation) — HIGH PRIORITY

- [x] 13.0 Fix test runner environment leakage ⚠️ RESOLVED
  - [x] 13.1 Update `.cursor/scripts/tests/run.sh` to run each test in subshell ✅
  - [x] 13.2 Move exports (TEST_ARTIFACTS_DIR, ALP_LOG_DIR) into subshell scope ✅
  - [x] 13.3 Add regression test: `run.env-isolation.test.sh` ✅
  - [x] 13.4 Validate: GH_TOKEN preserved after test suite ✅
  - [x] 13.5 Document: security-scan.test.sh creates tmp-scan (fixed) ✅
- [x] 14.0 Fix tmp-scan creation
  - [x] 14.1 Identified: security-scan.test.sh created tmp-scan/ in repo root ✅
  - [x] 14.2 Fixed: use .test-artifacts/<name>-$$ for test temps ✅
  - [x] 14.3 Added cleanup trap ✅
  - [x] 14.4 Verified: no tmp-scan/ after test runs ✅
- [x] 13.6 Simplify tests via subshell isolation (D6 Refactoring) ✅
  - [x] 13.6.1 Removed snapshot/restore boilerplate from pr-create.test.sh ✅
  - [x] 13.6.2 Audited all tests: no other snapshot/restore patterns found ✅
  - [x] 13.6.3 Pattern established: tests directly export vars, runner provides cleanup ✅
  - [x] 13.6.4 Documented in ERD D6: scripts keep seams, tests use subshell isolation ✅
  - [x] 13.6.5 All 55 tests passing after simplification ✅
- [x] 15.0 Investigate .github/ deletion ✅ RESOLVED
  - [x] 15.1 Identified: lint-workflows.test.sh line 9 had rm -rf \$ROOT_DIR/.github ✅
  - [x] 15.2 Fixed: test now uses temp directory, never mutates repo .github ✅
  - [x] 15.3 Verified: full test suite preserves .github (10 workflows before and after) ✅
  - [x] 15.4 Safeguard: D6 subshell isolation + proper temp directory usage ✅

### Phase 6: Documentation and CI (COMPLETE ✅)

- [x] 16.0 Documentation updates
  - [x] 16.2 Add usage examples for new library functions (README.md complete) ✅
  - [x] 16.1 Create migration guide for existing scripts (`MIGRATION-GUIDE.md` created) ✅
  - [x] 16.3 Document portability guarantees (exists in ERD D5 + migration guide) ✅
- [x] 17.0 CI integration
  - [x] 17.1 Add ShellCheck CI job (optional/non-blocking) ✅
  - [x] 17.2 Add help validation to CI (help-validate.sh runs on PRs, blocks on failure) ✅
  - [x] 17.3 Add error/network validators to CI (error-validate.sh blocks, network-guard.sh informational) ✅
  - Created: `.github/workflows/shell-validators.yml` workflow

### Phase 7: Future Work (Deferred/Optional)

- [ ] 18.0 Organize scripts into subdirectories (see ERD Section 11) — **DEFERRED (Decision threshold: 50+ scripts)**

  - Current: 45 scripts; flat structure manageable
  - Threshold: Reorganize when count reaches **50+ scripts** OR clear pain points emerge
  - [ ] 18.1 Define final directory structure (git/, project/, rules/, tests/, lib/)
  - [ ] 18.2 Create subdirectories and move scripts (keep top-level entrypoints or add shims)
  - [ ] 18.3 Update all path references in `.cursor/rules/*.mdc` (~30-40 references)
  - [ ] 18.4 Update CI workflow paths (`.github/workflows/*.yml`)
  - [ ] 18.5 Update `.gitignore` patterns if needed
  - [ ] 18.6 Validate with `project-lifecycle-validate.sh` and manual smoke tests
  - [ ] 18.7 Document directory structure and rationale in README or rules
  - [ ] 18.8 Update `docs/scripts/README.md` with new categories
  - Status: Deferred; reassess when approaching 45-50 scripts (see ERD Section 11 for detailed proposal and decision criteria)

- [x] 20.0 Refactor existing Unix Philosophy violators — **✅ MAJOR WORK COMPLETE (2025-10-14)**

  - **Status:** 3 major orchestrators complete; remaining work moved to script-refinement project
  - See: `docs/projects/scripts-unix-philosophy/erd.md` Section 11
  - See: `docs/projects/script-refinement/erd.md` for remaining optional work
  - **What was accomplished:**
    - [x] Created 9 focused scripts (all D1-D6 compliant, TDD-tested) ✅
    - [x] Created 56 tests (55 passing, 1 new format test) ✅
    - [x] Enforcement rule active (shell-unix-philosophy.mdc) ✅
    - [x] 20.1 rules-validate.sh → orchestrator (497 → 301 lines, 40% reduction) ✅
    - [x] 20.2 context-efficiency-gauge.sh → orchestrator (342 → 124 lines, 64% reduction) ✅
    - [x] 20.2.1 context-efficiency-format.sh extracted (282 lines) ✅
    - [x] 20.3 pr-create.sh deprecated with focused alternatives recommended ✅
  - **What was migrated to script-refinement (P3 optional):**
    - [ ] 20.4 Extract checks-status.sh → Moved to script-refinement Task 1.0
    - [ ] 20.5 Split rules-validate-format.sh → Moved to script-refinement Task 2.0
  - **Achievement:** 839 lines reduced via orchestrators (497+342 → 301+124)
  - **Current state:** 2 refinement opportunities remain (checks-status, rules-validate-format split); deferred to optional project
  - **Priority:** Core work complete ✅; remaining work is P3 polish

- [x] 19.0 Source project task reconciliation — ✅ COMPLETE
  - [x] 19.1 networkless-scripts tasks — Document: Guidance-based approach chosen over seam approach for GitHub scripts; mark tasks 1.0-6.0 as "superseded by guidance approach" ✅
  - [x] 19.2 script-test-hardening tasks — Document: D6 subshell isolation solved core issue; token override flags (1.0-5.0) not needed; mark as "superseded by D6" ✅
  - [x] 19.3 shellcheck tasks — Document: Inline config decision; mark 2.0 (.shellcheckrc creation) as "not needed"; update 1.0 subtasks to reflect completion ✅
  - [x] 19.4 scripts-unix-philosophy tasks — Mark 1.0-6.0 as "embedded in D1-D6"; add note linking to cross-cutting decisions ✅
  - [x] 19.5 script-rules tasks — Document: Validators merged into help-validate.sh and error-validate.sh; mark 1.0 as "superseded by unified validators" ✅
  - [x] 19.6 script-help-generation tasks — Document: Template functions approach chosen; mark 2.0 (help-generate.sh) as "not implemented—template approach used"; mark 5.0 (docs/scripts/) as "not needed" ✅
  - [x] 19.7 script-error-handling tasks — Mark 1.0-3.0 infrastructure tasks as complete; update adoption status ✅
  - [x] 19.8 bash-scripts tasks — Complete 2.0 and 3.0 or mark as optional ✅
  - [x] 19.9 tests-github-deletion — Archive project (resolved and complete) — **READY FOR ARCHIVAL** ✅
    - Issue resolved: `.github/` deletion and `tmp-scan/` creation fixed via D6 test isolation
    - Verification complete: 46/46 tests passing, `.github/` intact, no `tmp-scan/`
    - ERD marked as completed: 2025-10-13
    - Archival target: `docs/projects/_archived/2025/tests-github-deletion/`
    - Action needed: Run `project-archive-workflow.sh --project tests-github-deletion --year 2025`
  - Status: ✅ COMPLETE (2025-10-13) — All source projects reconciled, design decisions documented

### Known Issues & Documentation Notes

- **Script count**: 45 production scripts (includes 10 extracted via Unix Philosophy refactoring; 1 spec helper: `rules-validate.spec.sh` excluded from count)
- **Network usage**: 7 scripts use network legitimately (4 GitHub API + 3 new extraction scripts)
- **Test count**: 56 tests (53 test files; all passing)
- **.shellcheckrc**: Created at repo root (2025-10-14); provides centralized suppression config for shellcheck-run.sh
- **docs/scripts/**: Not created; .lib.sh template functions provide help standardization without separate doc generation (decision: template approach over doc generation)

### Unix Philosophy Compliance Status

**Infrastructure:** ✅ COMPLETE (D1-D6)  
**Actual script refactoring:** ⏸️ PARTIAL, DEFERRED (2025-10-14) — Focused alternatives created; orchestration optional

**Decision:** Accept partial completion. Enforcement rule prevents new violations (primary goal achieved); orchestration updates are optional enhancement work.

**What was accomplished:**

- Created 9 focused scripts (all Unix Philosophy compliant, TDD-tested) ✅
- Created 53 new tests (100% passing) ✅
- Enforcement rule active (shell-unix-philosophy.mdc) ✅
- All new scripts D1-D6 compliant ✅

**What was deferred (optional, non-urgent):**

- Update originals to orchestrators ⏸️
- Complete format/template extractions ⏸️
- Deprecation notices and migration guides ⏸️

**Current state (acceptable):**

- 5 violators exist (4 originals + 1 large extraction)
- Focused alternatives available for all major use cases
- Enforcement rule ensures new scripts comply
- Original scripts remain functional

**Focused alternatives created:**

- rules-validate-frontmatter.sh, rules-validate-refs.sh, rules-validate-staleness.sh, rules-autofix.sh, rules-validate-format.sh
- git-context.sh, pr-label.sh, pr-create-simple.sh, context-efficiency-score.sh

**Rationale for deferral:** Enforcement rule achieved primary goal (prevent future violations). Updating originals is mechanical work with diminishing returns; alternatives provide Unix Philosophy compliance for those who want it.

See: [`UNIX-PHILOSOPHY-AUDIT.md`](./UNIX-PHILOSOPHY-AUDIT.md) | [`UNIX-PHILOSOPHY-AUDIT-UPDATED.md`](./UNIX-PHILOSOPHY-AUDIT-UPDATED.md) | [`REVIEW-FINDINGS.md`](./REVIEW-FINDINGS.md)
