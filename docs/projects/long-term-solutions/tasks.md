## Relevant Files

- `docs/projects/long-term-solutions/erd.md` — Canonical ERD (Lite)
- `docs/projects/README.md` — Projects index (Active listing)
- `.cursor/scripts/final-summary-generate.sh` — Final summary generator (target for hardening)

### Notes

- Automation‑first: replace manual edits with durable, test‑backed fixes.
- TDD‑first: add a focused failing test before implementation changes.
- Prefer portable shell and small validators; integrate optional CI after local validation is solid.

## Tasks

- [ ] 1.0 Inventory manual workarounds (priority: high)

  - [ ] 1.1 List recurring manual edits (e.g., final summaries, indexes, changelogs)
  - [ ] 1.2 Rank top 3 by frequency and impact

- [ ] 2.0 TDD fix: final summary generator (priority: high) (depends on: 1.0)

  - [ ] 2.1 Add a focused failing shell test capturing the current gap in `final-summary-generate.sh`
  - [ ] 2.2 Implement the minimal fix in the script to make the test pass
  - [ ] 2.3 Add `--help`/usage and predictable exit codes if missing
  - [ ] 2.4 Record commands and outputs as acceptance evidence

- [ ] 3.0 Add drift validator (priority: high) (depends on: 2.0)

  - [ ] 3.1 Create a local script to regenerate and diff final summaries
  - [ ] 3.2 Ensure deterministic output (no timestamps/unordered sections)
  - [ ] 3.3 Document usage in this project and link from ERD

- [ ] 4.0 Optional CI gate (priority: medium) (depends on: 3.0)

  - [ ] 4.1 Add a lightweight GitHub Action job to run the drift validator on PRs
  - [ ] 4.2 Path‑filter to docs/projects/\*\* to keep runs fast
  - [ ] 4.3 Tune failure messaging and remediation guidance

- [ ] 5.0 Policy & guidance (priority: medium)

  - [ ] 5.1 Draft a short checklist: choose long‑term fix vs. workaround
  - [ ] 5.2 Place under `docs/guides/` (or link from this project) and reference in rules

- [ ] 6.0 Migration (priority: medium) (depends on: 2.0, 3.0)

  - [ ] 6.1 Run the generator across applicable projects and commit outputs
  - [ ] 6.2 Remove any lingering manual update steps from docs
  - [ ] 6.3 Capture before/after deltas as evidence

- [ ] 7.0 Acceptance (priority: medium)

  - [ ] 7.1 Project listed under Active in `docs/projects/README.md`
  - [ ] 7.2 Tests for `final-summary-generate.sh` show Red→Green with the fix
  - [ ] 7.3 Drift validator runnable locally; optional CI green on main
  - [ ] 7.4 Evidence recorded in this file
