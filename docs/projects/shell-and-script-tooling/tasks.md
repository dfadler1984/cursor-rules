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
  - [x] 9.1 Create `help-validate.sh` (validates help sections per D1) — Found 32 violations
  - [x] 9.2 Create `error-validate.sh` (validates strict mode and exit codes per D2/D3) — ✅ 100% compliant
  - [x] 9.3 Create `network-guard.sh` (validates no direct curl/gh usage per D4/D5) — ✅ 100% compliant (all violations resolved)
- [x] 8.0 Migrate all network-using scripts to networkless standard
  - [x] 8.1 Update `pr-create.sh` to use `.lib-net.sh` seam ✅ COMPLETE
  - [x] 8.2 Update `pr-update.sh` to use `.lib-net.sh` seam ✅ COMPLETE
  - [x] 8.3 Update `checks-status.sh` to use `.lib-net.sh` seam ✅ COMPLETE
  - [x] 8.4 Update `changesets-automerge-dispatch.sh` to use `.lib-net.sh` seam ✅ COMPLETE
  - [x] 8.5 Add suppression mechanism to network-guard for false positives
  - [x] 8.6 All migration tests passing (10 test suites, 40+ tests total)
- [ ] 10.0 Record adoption status in source projects
  - [ ] 10.1 Update adoption checklist in each source project's tasks.md
  - [ ] 10.2 Add backlinks from adoptions to this ERD's decision sections
  - [ ] 10.3 Track migration progress (scripts migrated vs total)

### Phase 4: Help Documentation Migration (COMPLETE ✅)

- [x] 8.5 Migrate all scripts to use help template functions (32/32 = **100% complete**)
  - [x] All 36 maintained scripts now have complete help documentation
  - [x] All scripts pass `help-validate.sh` (36/36 = 100%) ✅
  - [x] Migrated in 6 batches: 16 scripts with new help, 16 scripts enhanced with Examples/Exit Codes

### Phase 5: Test Isolation Fix (D6 Implementation) — HIGH PRIORITY

- [ ] 13.0 Fix test runner environment leakage ⚠️ BLOCKING ISSUE
  - [ ] 13.1 Update `.cursor/scripts/tests/run.sh` to run each test in subshell: `( export TEST_ARTIFACTS_DIR=...; bash "$t" ) >"$out"`
  - [ ] 13.2 Move exports (TEST_ARTIFACTS_DIR, ALP_LOG_DIR) into subshell scope (lines 88-99)
  - [ ] 13.3 Add regression test: verify GITHUB_TOKEN isn't mutated after test runs
  - [ ] 13.4 Validate fix: run test suite, then `validate:ghtoken` should still return correct value
  - [ ] 13.5 Document: which test(s) mutate GITHUB_TOKEN (likely checks-status.test.sh line 45)
- [ ] 14.0 Investigate and fix tmp-scan creation
  - [ ] 14.1 Identify which test creates tmp-scan/ directory
  - [ ] 14.2 Replace with proper temp directory using with_tempdir or mktemp
  - [ ] 14.3 Add cleanup trap to prevent orphaned temp dirs
  - [ ] 14.4 Add regression test: verify no tmp-scan/ after test runs
- [ ] 15.0 Investigate .github/ deletion
  - [ ] 15.1 Identify which test or script removes .github/
  - [ ] 15.2 Add safeguard: deny-list critical paths in cleanup routines
  - [ ] 15.3 Add regression test: verify .github/ exists after test suite
  - [ ] 15.4 Document findings in tests-github-deletion ERD

### Phase 6: Documentation and CI (Future)

- [ ] 16.0 Documentation updates
  - [ ] 16.1 Create migration guide for existing scripts
  - [ ] 16.2 Add usage examples for new library functions
  - [ ] 16.3 Document portability guarantees and graceful degradation patterns
- [ ] 17.0 Optional CI integration
  - [ ] 17.1 Add ShellCheck CI job (non-blocking initially)
  - [ ] 17.2 Add help validation to CI
  - [ ] 17.3 Add network guard tests to CI
- [ ] 13.0 Organize scripts into subdirectories
  - [ ] 13.1 Define final directory structure (git/, project/, rules/, tests/, lib/)
  - [ ] 13.2 Create subdirectories and move scripts (keep top-level entrypoints or add shims)
  - [ ] 13.3 Update all path references in `.cursor/rules/*.mdc`
  - [ ] 13.4 Update CI workflow paths (`.github/workflows/*.yml`)
  - [ ] 13.5 Update `.gitignore` patterns if needed
  - [ ] 13.6 Validate with `project-lifecycle-validate.sh` and manual smoke tests
  - [ ] 13.7 Document directory structure and rationale in README or rules
