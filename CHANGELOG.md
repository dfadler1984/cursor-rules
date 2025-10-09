# Changelog

## 0.3.10

### Patch Changes

- [#65](https://github.com/dfadler1984/cursor-rules/pull/65) [`841b1a0`](https://github.com/dfadler1984/cursor-rules/commit/841b1a0b77af868378197b4caef4bff5a51dc6c0) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Refine Changesets auto-merge to MVP: `workflow_run` (Changesets) + optional manual dispatch.

  - Enable Auto-merge after the Changesets workflow completes successfully
  - Keep `workflow_dispatch pr=<number>` for backfill on existing release PRs
  - Single job resolves the target PR (title/head + bot) and enables Auto-merge (squash)

## 0.3.9

### Patch Changes

- [#63](https://github.com/dfadler1984/cursor-rules/pull/63) [`c4ab8d7`](https://github.com/dfadler1984/cursor-rules/commit/c4ab8d75347317c0e9bc43bba48196fc5d9b5be7) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Simplify Changesets auto-merge to a minimal, reliable workflow.

  - Use `workflow_run` on `Changesets` (types: completed) to enable Auto-merge
  - Keep optional `workflow_dispatch pr=<number>` for backfill on existing PRs
  - Single job: resolve target PR (title/head + bot) and enable Auto-merge (squash)

## 0.3.8

### Patch Changes

- [#61](https://github.com/dfadler1984/cursor-rules/pull/61) [`5c90593`](https://github.com/dfadler1984/cursor-rules/commit/5c9059311609ebe4e7d5b2d111f9e10c22d24382) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Improve Changesets auto-merge reliability by reacting to the release workflow completion.

  - Add `workflow_run` trigger for the `Changesets` workflow (types: completed)
  - On success, find the open “Version Packages” PR and enable Auto-merge
  - Keep manual `workflow_dispatch` for backfill

## 0.3.7

### Patch Changes

- [#59](https://github.com/dfadler1984/cursor-rules/pull/59) [`28212e1`](https://github.com/dfadler1984/cursor-rules/commit/28212e1557126fb466404e7d440fdd3705ab56cc) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Add a reliable workflow to auto‑enable GitHub Auto‑merge for Changesets “Version Packages” PRs.

  - Dual triggers (`pull_request`, `pull_request_target`) with strict scope (title/head + author)
  - Manual `workflow_dispatch` to backfill enabling auto‑merge on an existing release PR
  - Permissions: `pull-requests: write`, `contents: read`
  - Logs targeted PR details for observability (title/head/author)

## 0.3.6

### Patch Changes

- [#57](https://github.com/dfadler1984/cursor-rules/pull/57) [`f1e535b`](https://github.com/dfadler1984/cursor-rules/commit/f1e535b507614c3815cba67be7a6b5710004ba0d) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Fix manual dispatch for enabling auto-merge on Changesets release PRs.

  - Use `github.rest.pulls.list` in `actions/github-script@v7`
  - Add guard to fail fast when no release PR is found

## 0.3.5

### Patch Changes

- [#55](https://github.com/dfadler1984/cursor-rules/pull/55) [`aa095a2`](https://github.com/dfadler1984/cursor-rules/commit/aa095a2c13c0bc1b027c17c7d4938ecd5762590a) Thanks [@dfadler1984](https://github.com/dfadler1984)! - docs(cursor-modes): add ERD and tasks for Cursor modes integration

  Includes `docs/projects/cursor-modes/erd.md` and `docs/projects/cursor-modes/tasks.md` with citations to:

  - Plan Mode announcement (product blog)
  - Agent/Ask/Manual docs hub
  - Changelog entry for Custom Modes

## 0.3.4

### Patch Changes

- [#53](https://github.com/dfadler1984/cursor-rules/pull/53) [`ac9a8dc`](https://github.com/dfadler1984/cursor-rules/commit/ac9a8dcd620d21137444945ae11ff5995f3fec1d) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Harden Changesets auto-merge enablement for release PRs.

  - Switch workflow to `pull_request_target` to ensure sufficient permissions
  - Add `workflow_dispatch` to enable auto-merge on an existing release PR (e.g., PR #52)
  - Keeps scope limited to titles starting with "Version Packages" or `changeset-release/*`

## 0.3.3

### Patch Changes

- [#51](https://github.com/dfadler1984/cursor-rules/pull/51) [`c4579f5`](https://github.com/dfadler1984/cursor-rules/commit/c4579f5101e3d3bc57bd1a5081400040bf73fbab) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Enable auto-merge for Changesets release PRs via GitHub Actions.

  - Add `.github/workflows/auto-merge-changesets.yml` using `peter-evans/enable-pull-request-automerge@v3`
  - Auto-enables PR auto-merge for titles starting with "Version Packages" after required checks pass
  - Requires repo setting "Allow auto-merge" and branch protection checks

## 0.3.2

### Patch Changes

- [#49](https://github.com/dfadler1984/cursor-rules/pull/49) [`cbdca41`](https://github.com/dfadler1984/cursor-rules/commit/cbdca41f068bda0c13ddc4808d6ba1b94b0e39cf) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Finalize project-erd-front-matter (archive + final summary) and strengthen ERD validation.

  - ERD set to completed; final summary generated; archived folder + index updated
  - Validator enforces status|owner|lastUpdated for project ERDs; tests added
  - pr-create auto-replace for full bodies (## Summary) with tests
  - Assistant behavior rule: fix PR link example formatting

## 0.3.1

### Patch Changes

- [#46](https://github.com/dfadler1984/cursor-rules/pull/46) [`0a4436e`](https://github.com/dfadler1984/cursor-rules/commit/0a4436ebefe9dbe1c5ed3a9bf9e8f312cfa3d277) Thanks [@dfadler1984](https://github.com/dfadler1984)! - docs: fold spec-driven into ai-workflow-integration; update references; remove old docs

## 0.3.0

### Minor Changes

- [#44](https://github.com/dfadler1984/cursor-rules/pull/44) [`64b5871`](https://github.com/dfadler1984/cursor-rules/commit/64b5871248b338683457de872be61d5010997304) Thanks [@dfadler1984](https://github.com/dfadler1984)! - ALP: add auto summary→mark→archive hook, portability fix in aggregator, tests for threshold/logger/triggers, and docs updates (mandatory trigger logging + ≥3‑incidents improvement threshold).

## 0.2.2

### Patch Changes

- [#42](https://github.com/dfadler1984/cursor-rules/pull/42) [`362ab23`](https://github.com/dfadler1984/cursor-rules/commit/362ab23b706880c15302c86508e43d7faf80e311) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Sync ERD/tasks with router rules; add outbound message checklist; require ANSI-C quoting/heredoc for multi-line PR bodies in PR scripts.

## 0.2.1

### Patch Changes

- [#40](https://github.com/dfadler1984/cursor-rules/pull/40) [`e745820`](https://github.com/dfadler1984/cursor-rules/commit/e7458208bf5eb12956f6f8789253d2f8e7a0bfbf) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Archive rules-validate-script; limit link checker to relative links; update tests; add URL formatting rule; default to including a Changeset for PRs.

## 0.2.0

### Minor Changes

- [#38](https://github.com/dfadler1984/cursor-rules/pull/38) [`6406de5`](https://github.com/dfadler1984/cursor-rules/commit/6406de5e819fe79c0d6b8f75c9bbe477cb85a76a) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Enhance rules validator: add JSON output, missing-references failure, 90-day staleness warnings/strict mode, autofix for formatting-only issues, and review report generation; update docs/capabilities; add CI; archive rule-maintenance project.

## 0.1.0

### Minor Changes

- [#36](https://github.com/dfadler1984/cursor-rules/pull/36) [`08003e2`](https://github.com/dfadler1984/cursor-rules/commit/08003e2a7cefdc4ebbb2864afbd01dd32b318824) Thanks [@dfadler1984](https://github.com/dfadler1984)! - feat(pr-create): add --label and --docs-only flags

  - Dry-run now includes a `labels` array when label flags are present
  - After successful PR creation, labels are added via the Issues API
  - Tests cover default/no labels, multiple labels, and `--docs-only` alias
  - ERD/tasks updated under `docs/projects/skip-changeset-opt-in`

## 0.0.5

### Patch Changes

- [#30](https://github.com/dfadler1984/cursor-rules/pull/30) [`297448b`](https://github.com/dfadler1984/cursor-rules/commit/297448bec1a807b89d1a2869cd78781aa4f61b5d) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Mock checks-status tests to avoid live GitHub API/token; add generic PR
  template; update assistant git rule to require a Changeset by default.

- [#32](https://github.com/dfadler1984/cursor-rules/pull/32) [`3308166`](https://github.com/dfadler1984/cursor-rules/commit/33081661fce078f42c01ea73ff026580a85d338f) Thanks [@dfadler1984](https://github.com/dfadler1984)! - docs: archive TDD-First; add test-coverage, pr-create-script, skip-changeset-opt-in projects; dedupe TDD rules

- [#29](https://github.com/dfadler1984/cursor-rules/pull/29) [`06e0b48`](https://github.com/dfadler1984/cursor-rules/commit/06e0b48cb777a5346fe682b9209aa13ac1957c41) Thanks [@dfadler1984](https://github.com/dfadler1984)! - chore: intent-routing docs and tasks improvements; add links-check script and project ERD front matter tasks. No runtime changes.

- [#33](https://github.com/dfadler1984/cursor-rules/pull/33) [`4a884fd`](https://github.com/dfadler1984/cursor-rules/commit/4a884fd254b80f62e9e88190741dba0aea070c09) Thanks [@dfadler1984](https://github.com/dfadler1984)! - docs(rules): update assistant behavior/capabilities; update projects README

## 0.0.4

### Patch Changes

- [#25](https://github.com/dfadler1984/cursor-rules/pull/25) [`3972974`](https://github.com/dfadler1984/cursor-rules/commit/3972974de0880d754489ba8e992cb617e28bf9e1) Thanks [@dfadler1984](https://github.com/dfadler1984)! - fix: correct duplicate JSON in .changeset/config.json to unblock changesets action

## 0.0.3

### Patch Changes

- [#25](https://github.com/dfadler1984/cursor-rules/pull/25) [`3972974`](https://github.com/dfadler1984/cursor-rules/commit/3972974de0880d754489ba8e992cb617e28bf9e1) Thanks [@dfadler1984](https://github.com/dfadler1984)! - fix: correct duplicate JSON in .changeset/config.json to unblock changesets action

- [#24](https://github.com/dfadler1984/cursor-rules/pull/24) [`a129980`](https://github.com/dfadler1984/cursor-rules/commit/a129980087f2cb05edf1eb63d5c3d91ab78f556a) Thanks [@dfadler1984](https://github.com/dfadler1984)! - chore: seed initial changeset to re-enable automated changelog and version PR

## 0.0.2

### Patch Changes

- [#13](https://github.com/dfadler1984/cursor-rules/pull/13) [`fc29369`](https://github.com/dfadler1984/cursor-rules/commit/fc293690dbbe50eeaf063e0a07eafb36fd8dd9b4) Thanks [@dfadler1984](https://github.com/dfadler1984)! - chore: demo linked changelog entries with GitHub formatter

## 0.0.1

### Patch Changes

- 564cdf4: chore: retry smoke run to validate changesets action
- 9e1d5e0: docs: smoke test changeset to verify Version Packages PR and VERSION sync

All notable changes to this project will be documented in this file.
Generated via Changesets from PR-authored changesets. `VERSION` is canonical.
