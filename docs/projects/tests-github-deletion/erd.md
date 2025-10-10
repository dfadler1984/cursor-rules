---
status: active
owner: rules-maintainers
---

# Engineering Requirements Document — Test Run Deletes `.github/` and adds `tmp-scan/`

Mode: Lite

Links: `docs/projects/tests-github-deletion/tasks.md`

## 1. Introduction/Overview

Running the full test suite appears to delete the `.github/` directory and create a `tmp-scan/` folder. This project investigates the root cause, adds safeguards, and documents a safe reproduction and fix.

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

- Running the full tests no longer deletes `.github/`
- Any temporary directories created are under a safe temp root (e.g., `./.tmp/`), cleaned after tests
- Documentation updated: steps to reproduce, cause, fix, and safeguards

## 5. Risks/Edge Cases

- Tests running with elevated permissions or from unexpected CWD
- Glob patterns or `rm -rf` paths that resolve unexpectedly
- Cross‑platform path assumptions in scripts

## 6. Notes

- Current test entry: `npm run test:scripts` → `.cursor/scripts/tests/run.sh -v`
- Start by reviewing shell test harness and any cleanup routines.
