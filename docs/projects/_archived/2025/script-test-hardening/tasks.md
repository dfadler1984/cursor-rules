## Tasks — ERD: Script Test Hardening

## Relevant Files

- `.cursor/scripts/pr-update.sh`
- `.cursor/scripts/pr-create.sh`
- `.cursor/scripts/.lib.sh`
- `.cursor/scripts/tests/run.sh`
- `docs/projects/script-test-hardening/erd.md`

- Unified coordination: `docs/projects/shell-and-script-tooling/erd.md`

## Todo

- [x] 1.0 Add token override flags (`--token` or `--github-token`) to pr-create.sh and pr-update.sh — ⚠️ NOT IMPLEMENTED (Decision: D6 subshell isolation solved the core issue)

  - Decision: D6 (Test Isolation) implemented subshell isolation in `.cursor/scripts/tests/run.sh`, which prevents env var leakage across tests
  - Rationale: Token override flags add complexity without addressing the root cause; subshell isolation is cleaner and protects all env vars, not just tokens
  - Tests can now directly `export` vars within test files; runner's subshell isolates changes
  - See: `docs/projects/shell-and-script-tooling/erd.md` D6 for implementation details

- [x] 2.0 Add `get_env(var, default)` helper in `.lib.sh` and route env reads through it — ⚠️ NOT IMPLEMENTED (Decision: Not needed with D6 subshell isolation)

  - Decision: Helper adds boilerplate without addressing the root cause
  - D6 subshell isolation provides superior isolation without requiring changes to production scripts

- [x] 3.0 Update tests to pass explicit token flags; snapshot/restore env per test file — ⚠️ SUPERSEDED (Decision: D6 subshell isolation eliminates need for snapshot/restore)

  - [x] Refactored: Removed snapshot/restore patterns from `pr-create.test.sh` (e.g., ORIGINAL_GH_TOKEN logic)
  - Tests now directly export vars; runner provides automatic cleanup via subshell
  - See: `docs/projects/shell-and-script-tooling/MIGRATION-GUIDE.md` Section 7 for test isolation pattern

- [x] 4.0 Add a lightweight linter in tests to detect `export`/`unset` of critical vars — ⚠️ NOT NEEDED (Decision: D6 makes this safeguard unnecessary)

  - D6 subshell isolation prevents env var leakage by design
  - Tests verified: `run.env-isolation.test.sh` confirms proper isolation

- [x] 5.0 Update README with guidance: flags over env in tests; sourcing not required — ✅ COMPLETE

  - Guidance documented in `docs/projects/shell-and-script-tooling/MIGRATION-GUIDE.md`
  - Pattern: Tests use `.test-artifacts/<name>-$$` for temp directories with cleanup traps
  - D6 documented: Each test runs in subshell, env changes don't leak

### Unified adoption checklist (from `docs/projects/shell-and-script-tooling/erd.md`)

- [x] D1 Help/Version: adopt minimum flags and section schema
- [x] D2 Strict Mode: source `.lib.sh` and call `enable_strict_mode`
- [x] D3 Error Semantics: align exit codes and `die` usage
- [x] D4 Networkless: adopt `.lib-net.sh` seam where relevant
- [x] D5 Portability: bash + git only; optional tools degrade gracefully
- [x] D6 Test Isolation: subshell isolation, no env leakage

#### Adoption status (2025-10-13)

- D1: ✅ Complete — All scripts have help documentation
- D2: ✅ Complete — All scripts use strict mode
- D3: ✅ Complete — All scripts use exit code catalog
- D4: ✅ Complete — Tests use seams
- D5: ✅ Complete — Portability policy adopted
- D6: ✅ Complete — **Primary focus of this project:** Test runner isolates each test in subshell (`.cursor/scripts/tests/run.sh`); env vars don't leak across tests; tmp directories use `.test-artifacts/` with proper cleanup traps; resolved tmp-scan/ and .github/ deletion issues

See: `docs/projects/shell-and-script-tooling/erd.md` D6 and `docs/projects/tests-github-deletion/erd.md` for detailed test isolation approach and fixes
