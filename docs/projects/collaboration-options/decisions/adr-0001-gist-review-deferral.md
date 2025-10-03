---
adr: 0001
status: Accepted
context: Defer Gist-based review mechanism
decision: Pause use of GitHub Gists as a rules/review mechanism for now.
consequences: |
  - Avoid process sprawl; keep review flows local until structure is finalized
  - Local docs capture decisions/requirements reliably
  - A clear re-introduction plan will be defined if needed
---

### Defer Gist-based review mechanism

- Decision: Pause use of GitHub Gists as a rules/review mechanism for now.
- Rationale: Avoid process sprawl; keep review flows local until we finalize structure.
- Success criteria:
  - No ERD/docs reference Gists for review or as the source of truth
  - Local docs capture decisions/requirements reliably
  - A clear re-introduction plan exists (if needed)
- Revisit date: 2025-10-15

Open items

- Identify any remaining references to Gists across docs and remove/update
- Define alternative review flow (local docs + PRs/issues) if required
- Criteria to re-enable Gist usage (e.g., portability needs, external collab)
