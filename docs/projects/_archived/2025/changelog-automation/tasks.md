## Tasks — ERD: Changelog Automation

## Relevant Files

- `docs/projects/changelog-automation/erd.md`
- `.github/workflows/changesets.yml`
- `.changeset/config.json`
- `VERSION`
- `CHANGELOG.md`
- `README.md`

## Todo

- [x] 1.0 Draft ERD (Lite) capturing VERSION canonical + bot PR flow
- [x] 2.0 Initialize Changesets and minimal Node tooling (tooling-only)
  - Add `package.json` (private: true) for scripts only; do not use as version source
  - Add `.changeset/config.json` with conventional commits mapping
  - Add `.changeset/README.md` (how to create changesets)
  - Seed root `CHANGELOG.md` header
- [x] 3.0 Set up GitHub Actions workflow for "Version Packages" PR
  - Workflow opens/updates bot PR when pending changesets exist
  - No GitHub Releases; repo-only updates
- [x] 4.0 Implement VERSION sync in version PR
  - Script computes next version from Changesets output and writes to `VERSION`
  - Ensure idempotency when PR updates
- [x] 5.0 Configure changelog categorization and commit mapping
  - Include all conventional types; highlight BREAKING CHANGES
  - Group low-signal types if needed (docs/chore) without filtering out
- [x] 6.0 Document author workflow and guardrails
  - Add concise doc to README section (how to add a changeset, PR expectations)
  - Confirm branch protection/CODEOWNERS include approvers for bot PR
- [ ] 7.0 Smoke test the flow (in progress; pending merge of setup PR)
  - Create a sample changeset; verify bot PR updates `CHANGELOG.md` and `VERSION`
  - Merge and confirm version tag/file updates correctly (no GitHub Release)
