---
---

# Engineering Requirements Document — Changelog Automation (Lite)

## 1. Introduction/Overview

Automate generation and maintenance of a root `CHANGELOG.md` from Conventional Commits, with semantic versioning and no GitHub Releases. Use a CI-driven workflow so merges to `main` automatically update the changelog and version source-of-truth.

## 2. Goals/Objectives

- Auto-generate `CHANGELOG.md` at repo root using Conventional Commits.
- Bump version automatically on merge to `main` (no manual release steps).
- Avoid publishing GitHub Releases; keep changes in-repo only.
- Include all Conventional Commit types (feat, fix, perf, refactor, docs, chore, etc.), with special handling for BREAKING CHANGES.
- Source-of-truth for version: `VERSION` file (canonical).

## 3. Functional Requirements

1. Tooling

   - Use Changesets (CLI + GitHub Action) to collect changes and generate changelog entries.
   - Do not create GitHub Releases; only update files in the repository.

2. Workflow

   - The CI opens a bot "Version Packages" PR when pending changesets exist. Maintainers review and merge this PR; no direct auto-commit to `main`.
   - Merging the PR results in a commit that:
     - Updates root `CHANGELOG.md` with categorized entries derived from Conventional Commits.
     - Bumps the version according to SemVer rules (major for BREAKING CHANGE, minor for feat, patch for fix/others unless overridden).
     - Updates the canonical `VERSION` file.
   - No backfill: historical entries prior to enabling this system are not imported.

3. Content & Format

   - `CHANGELOG.md` groups entries by version with date, and categorizes by Added/Changed/Fixed/Docs/Chore/Perf/Refactor/etc.
   - Include commit scope (if present) and PR/commit links where available.
   - Surface BREAKING CHANGES prominently within each release section.

4. Enforcement & Signals
   - Conventional Commits are already enforced in this repo; continue to rely on those signals.
   - If no pending changesets, merges to `main` produce no version commit.

## 4. Acceptance Criteria

- Merging a PR into `main` with applicable changesets results in a commit that updates `CHANGELOG.md` and the version source-of-truth without creating a GitHub Release.
- The generated changelog includes all commit types and correctly highlights BREAKING CHANGES.
- Version increments follow SemVer based on commit signals or explicit changeset configuration.
- A dry-run CI step can show the would-be changelog/version changes without modifying the repo.

## 5. Risks/Edge Cases

- Changesets typically manages versions via `package.json`. Using a standalone `VERSION` file requires a small sync step in CI to write the computed version into `VERSION` (keeping `VERSION` canonical). A minimal `package.json` may still be included for tooling only.
- If this is ever expanded to a monorepo, Changesets configuration must be adapted (independent vs locked versions).
- Fully automatic version commits on merge reduce human review of release notes. Mitigation: use a bot PR that maintainers approve before merging.
- Commit types like `chore` may create noisy entries. Consider filtering or grouping to keep signal high.

## 6. Rollout Note

- Owner: rules-maintainers
- Cadence: automatic on merge to `main`
- Initial enablement: introduce configuration and a smoke test PR to verify CI behavior
- Status: completed (see `docs/projects/changelog-automation/final-summary.md`)

## Consolidated Open Questions

1. Single-package vs monorepo: Confirm current repo structure so we choose the correct Changesets mode.
2. Changelog noise policy: You selected "include all types"; revisit if noise becomes an issue.

---

Owner: rules-maintainers (proposed)

Last updated: 2025-10-03
