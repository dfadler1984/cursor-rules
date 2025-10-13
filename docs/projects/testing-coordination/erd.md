---
status: active
owner: rules-maintainers
---

# Engineering Requirements Document — Testing Coordination (Unified)

Links: `docs/projects/testing-coordination/tasks.md`

## 1. Introduction/Overview

Unify and coordinate testing/TDD-related initiatives across the repository by referencing existing projects without moving files. This project provides a single place to align goals, reduce duplication, and track cross-cutting decisions while each source project remains authoritative for its own scope.

## 2. Scope & Approach

- Reference, do not move: Source projects remain as-is and authoritative.
- Dual tracking: Track relevant work both here (for consolidation visibility) and within each source project (for local ownership).
- Derive unique unified tasks as other projects progress; avoid premature merging.

## 3. Source Projects (authoritative references)

- TDD Rules Refinement — `docs/projects/tdd-rules-refinement/erd.md` | tasks: `docs/projects/tdd-rules-refinement/tasks.md`
- Test Coverage — `docs/projects/test-coverage/erd.md` | tasks: `docs/projects/test-coverage/tasks.md`
- Test Artifacts Cleanup — `docs/projects/test-artifacts-cleanup/erd.md` | tasks: `docs/projects/test-artifacts-cleanup/tasks.md`

### Related/Overlap

- Script Test Hardening (overlaps with shell/script testing concerns) — `docs/projects/script-test-hardening/erd.md` | tasks: `docs/projects/script-test-hardening/tasks.md`

## 4. Goals/Objectives

- Provide a cohesive vision spanning TDD rules, coverage policy, artifact hygiene, and regression safeguards.
- Reduce duplication and contradictions across testing-related projects.
- Establish a small set of shared, adoption-ready decisions that individual projects can opt into.
- Maintain project-level autonomy while enabling cross-project coordination.

## 5. Functional Requirements

### 5.1 Reference Integration

- Each source project link must be present (ERD + tasks) and kept current.
- This ERD may define cross-cutting decisions; adoptions occur in source projects with explicit links back here.

### 5.2 Tracking & Synchronization

- When creating a unified task here, add a corresponding entry or link in the relevant source project tasks.
- Include backlinks: from source tasks to this ERD (section or task) for traceability.

### 5.3 Governance & Ownership

- Owner: rules-maintainers
- Decision notes recorded as short entries with date, scope, and impacted projects.

## 6. Acceptance Criteria

- This ERD exists with links to all source projects and their tasks.
- A unified tasks file exists, describing coordination workflow and dual-tracking policy.
- Projects index updated to include this unified project.

## 7. Risks/Edge Cases

- Drift between unified guidance and project specifics — mitigated by explicit backlinks and minimal shared decisions.
- Over-centralization — mitigated by keeping source projects authoritative and adopting changes opt-in.

## 8. Rollout

- Comms: Link this project from the projects index once validated.
- Iteration: Start by referencing; derive unified tasks as individual projects progress.

## 9. Validation

- Manual check: all links resolve locally.
- Cross-reference check: new decisions recorded here have corresponding adoption notes in source projects.

---

Owner: rules-maintainers

Last updated: 2025-10-11
