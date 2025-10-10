---
owner: rules-maintainers
status: active
lastUpdated: 2025-10-09
---

# Engineering Requirements Document — Auto‑merge Changesets Version PRs (Lite)

## 1. Introduction/Overview

Enable reliable, zero-touch auto‑merge for Changesets “Version Packages” PRs opened by the bot, once all required checks pass. The workflow should be permissions-safe, resistant to event delivery quirks, and provide a manual backfill path.

## 2. Goals/Objectives

- Automatically enable GitHub Auto‑merge on bot “Version Packages” PRs.
- Work across both PR event types (`pull_request`, `pull_request_target`).
- Provide a `workflow_dispatch` to backfill enabling auto‑merge on an existing release PR.
- Keep behavior narrowly scoped to Changesets release PRs only.

## 3. User Stories

- As a maintainer, I want the Changesets release PR to merge itself after checks, without manual clicks.
- As a maintainer, I can run a manual dispatch to enable auto‑merge on a currently open release PR.

## 4. Functional Requirements

1. Triggering

   - Listen on both `pull_request` and `pull_request_target` for: opened, reopened, synchronize, ready_for_review.
   - Keep a `workflow_dispatch` with input `pr` (PR number, optional).

2. Targeting (strict scope)

   - PR title starts with "Version Packages" OR head ref starts with `changeset-release/`.
   - PR author is `github-actions[bot]`.

3. Permissions

   - Workflow permissions include `pull-requests: write` and `contents: read`.
   - Use `secrets.GITHUB_TOKEN` only; no personal tokens.

4. Behavior

   - Call `peter-evans/enable-pull-request-automerge@v3` with configurable merge method (default `squash`).
   - Manual dispatch resolves PR number from input or finds the latest open Changesets PR via `github.rest.pulls.list`.
   - Emit clear failure when no target PR is found.

5. Observability
   - Log which PR was targeted and which condition matched (title/head/author).

## 5. Non‑Functional Requirements

- Permissions‑safe (no extra scopes, no external tokens).
- Minimal, readable workflow; practical comments inline.
- Deterministic behavior; no flaky conditions.

## 6. Acceptance Criteria

- New bot “Version Packages” PRs show Auto‑merge enabled without manual action.
- Running the manual dispatch with `pr=<number>` enables Auto‑merge on that specific PR.
- Non‑Changesets PRs never get modified by this workflow.
- Honors branch protection and merges only after required checks pass.

## 7. Risks & Mitigations

- Event mismatch (some PRs not delivering `pull_request_target`): trigger on both PR event types and remove event‑name guards.
- Insufficient permissions: ensure `pull-requests: write`; verify repo "Allow auto‑merge" is enabled.
- Over‑matching: restrict to title/head patterns AND author `github-actions[bot]`.

## 8. Rollout & Ops

- Owner: rules-maintainers
- Cadence: runs on every matching PR; manual backfill via dispatch
- Backout: revert the workflow file and disable Auto‑merge in repo settings if needed

Migration note:

- Introduce a new, dedicated workflow for enabling Auto‑merge on Changesets bot "Version Packages" PRs (dual triggers + strict filters).
- After merging and validating on a live release PR, delete any obsolete/overlapping auto‑merge workflows under `.github/workflows/` to avoid duplicates or skipped/conflicting runs.

## 9. Open Questions

- Merge method policy: keep `squash` or make configurable via repo variable?
