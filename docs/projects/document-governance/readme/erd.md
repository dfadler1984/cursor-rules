---
status: active
owner: rules-maintainers
---

# Engineering Requirements Document — README Structure and Content Organization

Mode: Full


## 1. Introduction/Overview

Define a clear, concise structure for the root `README.md` and determine where existing repository content should live (what belongs in the root vs under `docs/` vs within feature/project folders). Produce an actionable content map and an outline for the updated README that improves onboarding and navigation.

### Uncertainty / Assumptions

- Assumption: The root `README.md` should remain concise and link-first.
- [NEEDS CLARIFICATION: Preferred audience weighting — new contributors vs repo users?]
- [NEEDS CLARIFICATION: Keep badges/status in root or relocate to docs landing?]

## 2. Goals/Objectives

- Establish a minimal, high-signal root `README.md` outline (≤ 200 lines).
- Map existing content to proper destinations (root vs `docs/` vs project folders).
- Reduce duplication by centralizing evergreen docs under `docs/` with clear links.
- Produce a migration plan (content map) that can be executed in a follow-up PR.

## 3. User Stories

- As a new contributor, I can skim the root README and quickly find setup, workflows, and where to go next.
- As a maintainer, I have a content map that tells me exactly what to move where.
- As an automation/tooling consumer, I find stable paths and anchors for links.

## 4. Functional Requirements

1. README Skeleton

   - Define a recommended section order for the root `README.md` (draft):
     1. Project summary
     2. Quickstart (minimal commands)
     3. Workflows overview (link to detailed docs)
     4. Rules/guardrails overview (link to `.cursor/rules/` and docs)
     5. Projects index link (`docs/projects/README.md`)
     6. Contributing/Support links
     7. License/Notices

2. Content Inventory

   - Inventory existing content in: `README.md`, `docs/`, `docs/projects/`, `.cursor/rules/`, and any FAQ/guide-like files.

3. Content Map (Source → Destination)

   - Produce `content-map.md` proposing where each item should live and how it is linked from the root README.
   - Include rename/move notes and anchor/link updates needed.

4. README Outline

   - Produce `README-outline.md` containing the proposed root README sections with one-line summaries and links to canonical docs.

5. Link Policy
   - Adopt a link-first policy in the root README; keep deep details in `docs/`.
   - Prefer descriptive anchors and relative links.

## 5. Non-Functional Requirements

- Clarity and skimmability over completeness in the root.
- Stable relative link structure; avoid fragile deep paths where possible.
- Keep GitHub rendering tidy (headings, short tables, short fenced blocks only when helpful).

## 6. Architecture/Design

- Directory roles:
  - Root: minimal `README.md` with links.
  - `docs/`: evergreen guides, workflows, and glossary.
  - `docs/projects/`: project-specific ERDs and task lists.
  - `.cursor/rules/`: rule sources; link from docs/; do not duplicate content.

## 7. Data Model and Storage

- Artifacts to produce: `README-outline.md`, `content-map.md` (kept under `docs/projects/readme-structure/` during review).
- Final README changes will be proposed in a follow-up implementation PR.

## 8. API/Contracts

- None.

## 9. Integrations/Dependencies

- References to existing docs: `docs/projects/README.md`, `.cursor/rules/*`.

## 10. Edge Cases and Constraints

- Duplicate content between root and `docs/` must be resolved — choose one canonical home, link from others.
- Existing external links/badges may need to remain in root for visibility.
- Ensure anchors remain valid after moves (update references in docs).

## 11. Testing & Acceptance

- Acceptance:
  - `README-outline.md` exists and is approved.
  - `content-map.md` lists source files, destinations, and link updates.
  - A brief migration plan is included (order of operations, risk notes).

## 12. Rollout & Ops

- Phase 1 (this project): Produce outline + content map.
- Phase 2 (separate PR): Apply the moves and update the root `README.md` accordingly.

## 13. Success Metrics

- Root `README.md` reduced to a concise, link-first doc while improving discoverability (qualitative review).
- Fewer “where is X?” questions; stable links from CI/docs/PR templates still work.

## 14. Open Questions

- Should Quickstart include local dev scripts or just link to `docs/workflows/`?
- Which badges (if any) are required in the root README?

---

Owner: rules-maintainers

Last updated: 2025-10-10
