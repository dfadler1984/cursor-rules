## Relevant Files

- `docs/projects/github-workflows-utility/erd.md` — Canonical ERD (Lite)
- `.github/workflows/` — GitHub Actions workflows directory

### Notes

- Keep `.github/` config-only per repo rules; place docs under `docs/`.
- Favor small, fast workflows with clear triggers and path filters.

## Tasks

- [ ] 1.0 Inventory existing workflows (priority: high)

  - [ ] 1.1 List all `.github/workflows/*.yml` files (or confirm none)
  - [ ] 1.2 For each: capture triggers, purpose, outcomes, maintenance cost
  - [ ] 1.3 Identify overlaps/gaps and any repo rule conflicts

- [ ] 2.0 Assess utility and actions (priority: high) (depends on: 1.0)

  - [ ] 2.1 Recommend keep/tweak/remove per workflow
  - [ ] 2.2 Document rationale and expected impact

- [ ] 3.0 Propose additions (priority: high) (depends on: 2.0)

  - [ ] 3.1 CI: Lint/Type/Test on `pull_request` and `push`
  - [ ] 3.2 Rules validator job (rules validation script)
  - [ ] 3.3 Links checker for docs PRs (path-filtered)
  - [ ] 3.4 PR title Conventional Commits check (optional)

- [ ] 4.0 Draft workflow YAMLs (priority: medium) (depends on: 3.0)

  - [ ] 4.1 Draft `ci.yml` with node setup, install, lint/type/test
  - [ ] 4.2 Draft `rules-validate.yml` running repo validators
  - [ ] 4.3 Draft `links-check.yml` for docs-only changes
  - [ ] 4.4 Draft `pr-title-check.yml` (if adopted)

- [ ] 5.0 Rollout & docs (priority: medium) (depends on: 4.0)

  - [ ] 5.1 Open PR(s) adding workflows; include rationale and risk notes
  - [ ] 5.2 Update `docs/projects/README.md` entry and acceptance evidence
  - [ ] 5.3 Monitor initial runs; tune path filters and concurrency

- [ ] 6.0 Acceptance (priority: medium) (depends on: 5.0)

  - [ ] 6.1 Inventory and proposals documented
  - [ ] 6.2 At least one new workflow merged and running successfully
  - [ ] 6.3 Noise reduction or time-to-signal improvement observed

## Real-World Issues (From Other Projects)

### Issue #1: changeset-autolabel-docs.yml Contradiction (2025-10-23)

**Source**: routing-optimization Phase 3 validation (PR #159)  
**Severity**: Medium

**Problem**:
- Workflow auto-applies `skip-changeset` to docs-only PRs
- Logic: If all files match doc patterns → apply skip-changeset
- **Gap**: Doesn't check if changeset files already present (`.changeset/*.md`)
- Result: PR with changeset + skip-changeset label (contradiction)

**Tasks**:

- [ ] Fix changeset-autolabel-docs.yml workflow:
  - [ ] Add changeset file detection (`hasChangeset = files.some(f => /^\.changeset\/.*\.md$/.test(...)`)
  - [ ] Update logic: Only apply skip-changeset if docs-only AND no changeset
  - [ ] Remove skip-changeset if changeset present (correct accidental labels)
  - [ ] Add test cases for changeset presence scenarios

- [ ] Update workflow documentation:
  - [ ] Document new logic in workflow comments
  - [ ] Add examples: docs-only + changeset → no label
  - [ ] Update related project references

**References**:
- `docs/projects/routing-optimization/phase3-findings.md` — Finding #1 (detailed analysis)
- `docs/projects/routing-optimization/tasks.md` — Phase 3 corrective actions
- PR #159 — Real-world example (changeset present but skip-changeset applied)
