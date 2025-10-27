---
status: completed
completedDate: 2025-10-13
owner: rules-maintainers
---

# Engineering Requirements Document — Test Run Deletes `.github/` and adds `tmp-scan/`

Mode: Lite


**Status:** ✅ RESOLVED (2025-10-13)

## Resolution Summary

Both issues have been identified and resolved:

1. **`.github/` deletion**: Caused by `lint-workflows.test.sh` line 9 (`rm -rf $ROOT_DIR/.github`). Fixed by using temp directories instead of mutating repo.
2. **`tmp-scan/` creation**: Caused by `security-scan.test.sh` creating temp directory in repo root. Fixed by using `.test-artifacts/<name>-$$` pattern with cleanup traps.

**Solution implemented**: Test runner (`.cursor/scripts/tests/run.sh`) now runs each test in a subshell with proper environment isolation (D6). Tests use `.test-artifacts/` for temp directories with cleanup traps.

**Verification**: Full test suite passes (46 tests), `.github/` directory intact, no `tmp-scan/` created.

## 1. Introduction/Overview

Running the full test suite was deleting the `.github/` directory and creating a `tmp-scan/` folder. This project investigated the root cause, implemented safeguards, and documented the fix.

## 2. Goals/Objectives

- Identify which test(s) or script(s) remove `.github/` or create `tmp-scan/`
- Provide a minimal, reliable reproduction and isolation steps
- Implement guardrails to prevent accidental deletion of `.github/`
- Document fixes and add targeted tests to prevent regression

## 3. Functional Requirements

1. A documented reproduction path (scripts/commands) that triggers the issue
2. Isolation to specific test file(s) or helper(s)
3. Root cause analysis with exact code path responsible
4. Remediation: code change and/or safety check added
5. Regression test ensuring `.github/` is not removed and `tmp-scan/` is only created in allowed temp paths

## 4. Acceptance Criteria

- [x] Running the full tests no longer deletes `.github/` ✅
- [x] Any temporary directories created are under `.test-artifacts/` with unique names, cleaned after tests ✅
- [x] Documentation updated: cause, fix, and safeguards ✅
- [x] Regression test added: `run.env-isolation.test.sh` verifies isolation ✅

## 5. Risks/Edge Cases

- Tests running with elevated permissions or from unexpected CWD
- Glob patterns or `rm -rf` paths that resolve unexpectedly
- Cross‑platform path assumptions in scripts

## 6. Implementation Notes

**Root causes identified:**

1. `lint-workflows.test.sh` line 9: `rm -rf $ROOT_DIR/.github` — directly deleted repo directory
2. `security-scan.test.sh`: Created `tmp-scan/` in repo root instead of using proper temp location

**Fixes applied:**

1. Updated `lint-workflows.test.sh` to use temp directory; never mutates repo `.github/`
2. Updated `security-scan.test.sh` to use `.test-artifacts/security-scan-$$` with cleanup trap
3. Implemented D6 (Test Isolation): Test runner runs each test in subshell, isolating environment changes
4. Added regression test: `run.env-isolation.test.sh` verifies proper isolation

**Related work:**

- See `docs/projects/shell-and-script-tooling/erd.md` D6 for full test isolation implementation
- Pattern documented in `MIGRATION-GUIDE.md` for future test authoring

## 7. Completion Date

**Completed:** 2025-10-13

**Ready for archival:** Yes — all issues resolved, documented, and tested
