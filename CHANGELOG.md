# Changelog

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
