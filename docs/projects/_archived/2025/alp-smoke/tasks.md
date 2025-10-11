---
archived: true
archivedOn: 2025-10-11
source: docs/projects/alp-smoke/tasks.md
---

## Relevant Files

- `.cursor/scripts/alp-smoke.sh` — Smoke runner writing under `.test-artifacts/alp/`
- `.cursor/scripts/alp-logger.sh` — Logger with fallback + threshold trigger
- `.cursor/scripts/alp-threshold.sh` — Threshold/archive automation (best-effort)

## Tasks

- [ ] 1.0 Document smoke usage and safety (priority: high)

  - [x] 1.1 Describe sandboxing to `.test-artifacts/alp` via env vars
  - [x] 1.2 Define expected summary output and counts
  - [x] 1.3 Note non-interactive, local-only behavior

- [ ] 2.0 Validate archival threshold behavior (priority: medium)

  - [ ] 2.1 Confirm one top-level log remains; older logs archived
  - [ ] 2.2 Confirm at least one `summary-*.md` exists

- [ ] 3.0 Optional: add README snippet (priority: low)

  - [ ] 3.1 Brief note linking to this project from root README

### Notes

- Do not commit `.test-artifacts/` outputs; verification is local-only.
