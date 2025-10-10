---
status: active
owner: rules-maintainers
---

# Engineering Requirements Document — Test Artifacts Cleanup on Every Run

Mode: Lite

Links: `docs/projects/test-artifacts-cleanup/tasks.md`

## 1. Introduction/Overview

Ensure every test run leaves the workspace clean by standardizing where temporary artifacts are created and adding a cross‑platform cleanup step that runs consistently in local and CI environments.

## 2. Goals/Objectives

- Define a single, safe temporary root (e.g., `./.tmp/`) for all tests/scripts.
- Provide an idempotent cleanup routine that runs before/after tests.
- Prevent accidental deletion of important directories (guard rails on paths).
- Keep the solution portable (macOS/Linux) and easy to adopt.

## 3. Functional Requirements

1. Establish a canonical temp root path and document usage.
2. Implement a cleanup script that removes known test artifacts under the temp root and other safe paths (e.g., coverage reports) without touching protected dirs.
3. Wire cleanup to run locally (pre/post test) and in CI.
4. Provide dry‑run and verbose modes for visibility when needed.

## 4. Acceptance Criteria

- After a full test run, no stray temp directories/files remain outside the temp root.
- Running the cleanup twice in a row makes no changes the second time (idempotent).
- CI logs show cleanup execution with zero errors.
- Guard rails prevent deletion outside the approved paths.

## 5. Risks/Edge Cases

- Wildcard/glob misuse deleting unintended files.
- Tests creating artifacts outside the temp root.
- Platform differences (BSD vs GNU tools).

## 6. Notes

- Start with a conservative allow‑list for paths; expand incrementally.
- Consider `.gitignore` updates for the temp root and generated artifacts.
