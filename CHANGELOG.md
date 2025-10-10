# Changelog

## 0.3.21

### Patch Changes

- [#89](https://github.com/dfadler1984/cursor-rules/pull/89) [`3859c6a`](https://github.com/dfadler1984/cursor-rules/commit/3859c6a84ae4bbcfbe0ae28f2f424a2149ad21f9) Thanks [@dfadler1984](https://github.com/dfadler1984)! - docs: add ALP logging project (erd, tasks, discussion); update pr-create usage guidance; dedupe PR template; archive pr-create-script project

## 0.3.20

### Patch Changes

- [#87](https://github.com/dfadler1984/cursor-rules/pull/87) [`168eb41`](https://github.com/dfadler1984/cursor-rules/commit/168eb419df6d80abed9692a121162ed85dc67919) Thanks [@dfadler1984](https://github.com/dfadler1984)! - docs(projects): archive auto-merge-bot-changeset-version via git mv; add final summary

## 0.3.19

### Patch Changes

- [#85](https://github.com/dfadler1984/cursor-rules/pull/85) [`c478ab0`](https://github.com/dfadler1984/cursor-rules/commit/c478ab036e955150a90ad3a48b064d4a3f5bc5e3) Thanks [@dfadler1984](https://github.com/dfadler1984)! - ci: changeset to re-trigger release flow and validate auto-merge permissions

## 0.3.18

### Patch Changes

- [#84](https://github.com/dfadler1984/cursor-rules/pull/84) [`12bb8fd`](https://github.com/dfadler1984/cursor-rules/commit/12bb8fd83a4af34b0c9a3c65e1546f7a227ffdcd) Thanks [@dfadler1984](https://github.com/dfadler1984)! - ci: attach jobs to AUTO_MERGE_TOKEN environment so env-scoped PAT is available

- [#82](https://github.com/dfadler1984/cursor-rules/pull/82) [`150b168`](https://github.com/dfadler1984/cursor-rules/commit/150b1688d92f93a8c9a5b3ea62b1330e87918456) Thanks [@dfadler1984](https://github.com/dfadler1984)! - ci: add test changeset to trigger Changesets release PR and validate auto-merge

## 0.3.17

### Patch Changes

- [#79](https://github.com/dfadler1984/cursor-rules/pull/79) [`01440be`](https://github.com/dfadler1984/cursor-rules/commit/01440be23cfca1346a8cb5b25c4fbe88a09b2cc1) Thanks [@dfadler1984](https://github.com/dfadler1984)! - ci: use AUTO_MERGE_TOKEN for enable-pull-request-automerge

  Switch the auto-merge workflow to a PAT-backed secret so the gh CLI
  and action have permission to enable auto-merge on Changesets PRs.

## 0.3.16

### Patch Changes

- [#77](https://github.com/dfadler1984/cursor-rules/pull/77) [`c2efdd9`](https://github.com/dfadler1984/cursor-rules/commit/c2efdd932455d85656efaf572f65e9ae6c21dc5b) Thanks [@dfadler1984](https://github.com/dfadler1984)! - ci: fix Changesets auto-merge by exporting GH_TOKEN and using github.token

  This ensures the `enable-pull-request-automerge` action's gh CLI has the
  required token and reliably enables auto-merge on Changesets release PRs.

## 0.3.15

### Patch Changes

- [#75](https://github.com/dfadler1984/cursor-rules/pull/75) [`10f43cb`](https://github.com/dfadler1984/cursor-rules/commit/10f43cb1f2b23576a535c35aaf7b406fabc33953) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Use a PAT-backed secret for enabling PR auto-merge.

  - Update `.github/workflows/changesets-auto-merge.yml` to use `secrets.AUTO_MERGE_TOKEN` instead of `secrets.GITHUB_TOKEN` to avoid GraphQL permission errors when enabling auto-merge.

## 0.3.14

### Patch Changes

- [#73](https://github.com/dfadler1984/cursor-rules/pull/73) [`51861ea`](https://github.com/dfadler1984/cursor-rules/commit/51861eac456b4bcb63e2fcc8a4734dcd9b89d313) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Remove legacy auto-merge workflow.

  - Delete `.github/workflows/auto-merge-changesets.yml` to avoid duplicate runs and the deprecated `gh pr merge` path. Keep a single source of truth in `changesets-auto-merge.yml`.

## 0.3.13

### Patch Changes

- [#71](https://github.com/dfadler1984/cursor-rules/pull/71) [`b2d7558`](https://github.com/dfadler1984/cursor-rules/commit/b2d75582ad9a24da6655b5a84865a177297b616f) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Switch Changesets auto-merge to use squash method.

  - Update `.github/workflows/changesets-auto-merge.yml` to `merge-method: squash` in both jobs so Version Packages PRs produce a single clean commit when merged.

## 0.3.12

### Patch Changes

- [#69](https://github.com/dfadler1984/cursor-rules/pull/69) [`1f0646f`](https://github.com/dfadler1984/cursor-rules/commit/1f0646f689dcf64784bac93a624d97ee87c69b20) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Add helper script to manually dispatch the Changesets auto-merge workflow.

  - `.cursor/scripts/changesets-automerge-dispatch.sh` — triggers `changesets-auto-merge.yml` with `pr=<number>`

## 0.3.11

### Patch Changes

- [#67](https://github.com/dfadler1984/cursor-rules/pull/67) [`2d9e110`](https://github.com/dfadler1984/cursor-rules/commit/2d9e110c4a4cba2c3f9b7d09b1c364f4a6874f38) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Reintroduce Changesets auto-merge MVP using `workflow_run` + optional `workflow_dispatch`.

  - Enable Auto-merge when the `Changesets` workflow completes successfully
  - Keep manual `workflow_dispatch pr=<number>` for backfill on existing release PRs

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
