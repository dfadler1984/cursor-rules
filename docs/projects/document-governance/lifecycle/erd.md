---
---

# Engineering Requirements Document — ERD Completion Metadata and Lifecycle

Mode: Full

Scope note: Define explicit completion metadata for ERDs, a clear status lifecycle, acceptance/validation gates, and lightweight automation so completion is unambiguous and auditable.

## 1. Introduction/Overview

This ERD proposes a standard way to mark when an ERD is complete. It introduces front matter metadata, a lifecycle with allowed transitions, and a completion gate that requires evidence (links to tasks/PRs/validation). The goal is to remove ambiguity around “done,” enable automated checks, and keep historical traceability via versioning and supersession.

## 2. Goals/Objectives

- Establish a deterministic ERD status lifecycle.
- Add front matter fields to encode completion, approvals, evidence, and lineage.
- Define acceptance gates for setting `status: Complete`.
- Provide minimal validator rules and CI hooks to enforce consistency.
- Preserve immutability of completed ERDs (changes require version bump or supersession).

## 3. Users and Ownership

- Producer: Engineer/Manager drafting and iterating the ERD.
- Reviewer: Project lead or rules‑maintainers approving readiness.
- Validator/CI: Automated checks that enforce gates.
- Owner: rules‑maintainers (rotating). Backup: project lead.

## 4. Functional Requirements

1. ERDs include front matter fields for lifecycle and evidence (see schema below).
2. `status` supports: `Draft | InReview | Approved | Implementing | Complete | Superseded`.
3. Allowed transitions (subset):
   - Draft → InReview → Approved → Implementing → Complete
   - Any → Superseded (with `superseded_by`)
   - Complete → Superseded only (no revert without version bump)
4. Completion gate (to set `status: Complete`) requires:
   - `approved_by` non‑empty (names/handles)
   - `completed_by` and `completed_at` (UTC ISO8601)
   - `evidence.links` include at least one PR and one tasks file
   - All linked tasks are marked done (per tasks file contract)
   - Optional: validator summary link (logs or CI output)
5. Governance:
   - When `status: Complete`, the ERD content is immutable except for:
     - `superseded_by` updates, or
     - Version bumps (`version`) with a changelog section describing the reason.
   - Substantive edits after completion require either a new `version` or a successor ERD marked via `supersedes`/`superseded_by`.
6. Traceability:
   - ERDs may reference predecessors via `supersedes` and successors via `superseded_by`.
   - Each ERD has a stable `id`.

## 5. Non‑Functional Requirements

- Simplicity: Metadata is minimal and human‑readable.
- Reliability: Validation yields deterministic pass/fail results.
- Portability: Works offline; no external services required.
- Transparency: Evidence links point to public repo artifacts when possible.

## 6. Front Matter Schema (Proposed)

```yaml
id: erd-completion-metadata
title: ERD Completion Metadata and Lifecycle
version: 0.1.0
status: Draft # Draft | InReview | Approved | Implementing | Complete | Superseded
approved_by: [] # ["owner1", "owner2"]
completed_by: "" # "user"
completed_at: "" # ISO8601 UTC, e.g., 2025-10-02T01:23:45Z
evidence:
  links: [] # ["tasks/tasks-foo.md", "PR #123", "docs/assistant-learning-logs/summary-*.md"]
supersedes: [] # ["erd-previous-id"]
superseded_by: "" # "erd-next-id"
```

Notes:

- Keep IDs short and kebab‑case; use the filename without extension when possible.
- `approved_by` is the set of reviewers who approved the ERD for implementation.
- `completed_by` is the operator who flipped to Complete.

## 7. Validation & Automation

- Rule: If `status: Complete`, require:
  - `approved_by.length > 0`
  - `completed_by` and valid `completed_at`
  - `evidence.links.length > 0` and contains at least one tasks path and one PR link/text
- Rule: If `status: Superseded`, require `superseded_by`.
- Rule: If `supersedes` present, ensure those IDs exist in repo.
- Rule: When `status: Complete`, block edits to body sections unless `version` is incremented or `superseded_by` is set.
- CLI (lightweight, future): Add a check to existing validation scripts to enforce the above. In CI, block PRs that set `Complete` without passing.

## 8. Acceptance Criteria

- Front matter schema documented in this ERD with fields and semantics.
- Lifecycle and allowed transitions listed.
- Completion gate spelled out with evidence requirements.
- Validation rules specified with pass/fail conditions.
- Worked example provided.

## 9. Testing

- Author a sample ERD (this document) and simulate transitions by updating `status` and required fields.
- Run validator (when implemented) to confirm failures until all required fields are present for `Complete`.
- Link a real tasks file and a mock PR link to demonstrate evidence checks.

## 10. Success Metrics

- Zero ERDs in `Complete` state without required metadata.
- 100% of `Complete` ERDs have at least one tasks link and one PR link.
- Time to review completion reduced (subjective): reviewers can verify at a glance.

## 11. Rollout & Ops

- Owner: rules‑maintainers
- Target: +7 days from approval
- Steps:
  - Update ERD authoring guidance to include front matter.
  - Add validator rule to existing scripts; wire optional CI check.
  - Migrate existing ERDs opportunistically when they next change or in a batch.

## 12. Open Questions

- Should approvals be typed (e.g., roles) or free‑text identifiers are sufficient?
- Do we require a minimum number of approvers?
- Should we enforce specific evidence link patterns (e.g., GitHub PR URL regex)?

## 13. Worked Example (Completed ERD front matter)

```yaml
id: erd-foo-feature
title: Foo Feature
version: 1.0.0
status: Complete
approved_by: ["rules-maintainers", "tech-lead"]
completed_by: "dfadler"
completed_at: 2025-10-02T02:15:00Z
evidence:
  links:
    - tasks/tasks-foo-feature.md
    - PR #123: Add Foo Feature
    - docs/assistant-learning-logs/summary-2025-10-02T01-57-46Z.md
supersedes: ["erd-foo-feature-beta"]
superseded_by: ""
```

When these fields are present and valid, the validator permits `status: Complete`. Subsequent substantive edits require a new `version` or a successor ERD marked via `superseded_by`.
