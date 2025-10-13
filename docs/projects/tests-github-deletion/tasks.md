# Tasks — Test Run Deletes `.github/` and adds `tmp-scan/`

## Relevant Files

- `docs/projects/tests-github-deletion/erd.md`
- `docs/projects/shell-and-script-tooling/erd.md` — **Moved from testing-coordination (2025-10-13)**

### Notes

- This project was moved from `testing-coordination` to `shell-and-script-tooling` as it's specifically about shell test infrastructure issues.
- Actively observed during shell-and-script-tooling session (2025-10-13): `tmp-scan/` appeared, `.github/` workflows deleted.
- Related to `.cursor/scripts/tests/run.sh` and shell test harness behavior.

## Investigation Checklist — ✅ COMPLETE (2025-10-13)

- [x] Reproduce locally using `npm run test:scripts` ✅
- [x] Capture before/after directory snapshot focusing on `.github/` and `tmp-scan/` ✅
- [x] Identify which test file triggers the change (bisect via focused runs) ✅
  - `.github/` deletion: `lint-workflows.test.sh` line 9
  - `tmp-scan/` creation: `security-scan.test.sh`
- [x] Review `.cursor/scripts/tests/run.sh` and any cleanup helpers for `rm -rf` calls ✅
- [x] Search for patterns like `rm -rf .github` or `tmp-scan` in scripts/tests ✅
- [x] Verify CWD assumptions; ensure tests run from repo root ✅
- [x] Check for environment variables that redirect temp paths ✅
- [x] Confirm no CI job or pre/post hooks are mutating `.github/` ✅

## Remediation Tasks — ✅ COMPLETE (2025-10-13)

- [x] Replace unsafe deletions with guarded functions (deny-list critical paths) ✅
  - `lint-workflows.test.sh` now uses temp directory, never touches repo `.github/`
- [x] Route temp outputs to `.test-artifacts/` with unique prefixes ✅
  - Pattern: `.test-artifacts/<name>-$$` with cleanup traps
- [x] Add regression test: running the suite does not delete `.github/` ✅
  - `run.env-isolation.test.sh` verifies isolation
- [x] Document fix and safeguards in ERD notes ✅
- [x] Cleanup: ensure created temp dirs are removed after tests ✅
  - All tests use `trap "rm -rf '$tmpdir'" EXIT` pattern

## Repro Steps

1. Ensure a fresh clone with `.github/` present
2. Run:
   - `npm run test:scripts`
3. Observe whether `.github/` is removed and whether `tmp-scan/` appears at repo root
4. If not reproduced, expand to full test command used in CI (if different)

## Resolution Summary (2025-10-13)

**Issues resolved:**

1. `.github/` deletion fixed in `lint-workflows.test.sh`
2. `tmp-scan/` creation fixed in `security-scan.test.sh`
3. Test isolation implemented via D6 (subshell isolation in test runner)
4. Regression test added to prevent future occurrences

**Verification:**

- Full test suite passes: 46/46 tests ✅
- `.github/` directory intact after test runs ✅
- No `tmp-scan/` directory created ✅
- Environment variables properly isolated ✅

**Documentation:**

- Root cause analysis in ERD
- Fix implementation details in ERD
- Pattern documented in `shell-and-script-tooling/MIGRATION-GUIDE.md`

**Ready for archival:** Yes — project complete
