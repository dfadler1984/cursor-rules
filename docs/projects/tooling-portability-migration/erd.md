# Engineering Requirements Document — Tooling, Portability & Migration (Coordination)

Mode: Lite

## 1. Introduction/Overview

Provide a single coordination point for three related efforts without relocating their artifacts: `tooling-discovery`, `portability`, and `artifact-migration`. This ERD references those projects, aligns scope boundaries, and sequences cross-project milestones. Sources of truth remain in their respective projects.

## 2. Goals/Objectives

- Centralize links, status, and hand-offs between the three projects
- Make dependencies and sequencing explicit (what must land before what)
- Keep domain ownership within each project; avoid duplication or drift
- Offer a minimal coordination backlog that points back to owner projects

## 3. Scope & References

- Tooling Discovery — `docs/projects/tooling-discovery/erd.md` | `docs/projects/tooling-discovery/tasks.md`
- Portability and Paths — `docs/projects/portability/erd.md` | `docs/projects/portability/tasks.md`
- Artifact Migration System — `docs/projects/artifact-migration/erd.md` | `docs/projects/artifact-migration/tasks.md`

Note: This project does not move or copy assets; it only references and sequences.

## 4. Functional Requirements (Coordination)

1. Create and maintain a dependency map across the three projects
   - Example: Portability policy informs Artifact Migration defaults
2. Define hand-offs and interfaces between efforts
   - Examples: path policies → migration config; inventory gaps → migration backlog
3. Maintain a minimal, high-signal coordination backlog (see `tasks.md`)
4. Avoid duplication; updates should occur in the owner project first

## 5. Acceptance Criteria

- This ERD lists canonical links to all three projects (ERDs + tasks)
- `tasks.md` exists with a small, actionable coordination backlog
- Projects index (`docs/projects/README.md`) lists this coordination project
- No artifacts are relocated; all references remain valid

## 6. Risks/Edge Cases

- Divergent updates in owner projects; mitigate by linking to canonical sources
- Over-scoping coordination; prefer pointers over restating details
- Timing misalignments between inventories, policies, and migration tooling

## 7. Rollout & Ownership

- Owner: eng-tools (coordination)
- Cadence: lightweight check-ins aligned with each owner project’s milestones
