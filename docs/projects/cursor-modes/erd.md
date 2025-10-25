---
status: active
owner: repo-maintainers
created: 2025-10-24
lastUpdated: 2025-10-24
---

# Engineering Requirements Document — Cursor Modes Integration

Mode: Full

## 1. Introduction/Overview

Explore how Cursor modes — Plan Mode, Agent Mode, Ask Mode, Manual Mode, and Custom Modes — align with and extend our repository rules (consent-first, TDD-first, task gating, Assistant Learning Protocol). Produce a mapping and recommended usage guidance.

### Uncertainty / Assumptions

- [NEEDS CLARIFICATION: final authoritative docs page for Plan Mode beyond the blog]
- Assume current modes per official sources and changelog.

## 2. Goals/Objectives

- Map each Cursor mode to our rules triggers and safeguards.
- Provide concise guidance (when to use which mode) with repo-specific caveats.
- Capture acceptance checks to validate mode→rule compatibility.

## 3. User Stories

- As a maintainer, I can see mode→rule mappings to guide contributors.
- As a developer, I know which mode to choose for a given task shape.
- As a reviewer, I can verify that mode usage keeps our gates intact.

## 4. Functional Requirements

1. Mode Inventory & Sources

   - Plan Mode: product blog intro and how-to.
   - Agent / Ask / Manual: covered under agent docs.
   - Custom Modes: changelog entry.

2. Mapping to Rules

   - Consent-first: clarify which modes can act autonomously vs. require explicit consent.
   - TDD-First: ensure implementation flows still add owner specs (Red→Green→Refactor).
   - Task gating: preserve one-active-subtask policy when modes execute changes.
   - Assistant Learning: log high-signal events regardless of mode.

3. Guidance Artifacts
   - Provide a short table of “When to use each mode”.
   - Cite official sources for each mode.

## 5. Non-Functional Requirements

- Keep outputs concise and scannable; links in Markdown; no external dependencies.

## 6. Architecture/Design

- Artifacts under `docs/projects/cursor-modes/`:
  - `erd.md` (this file)
  - `tasks.md` with parent tasks first, then sub-tasks after approval.
- Cross-link sources in citations.

## 7. Data Model and Storage

- Markdown only. No runtime code.

## 8. References / Citations

- Plan Mode announcement: [Introducing Plan Mode](https://cursor.com/blog/plan-mode)
- Agent/Ask/Manual docs hub: [Agent docs](https://docs.cursor.com/agent)
- Custom Modes mention: [Changelog 0.48.x](https://cursor.com/changelog/0-48-x)

## 9. Edge Cases and Constraints

- Docs may evolve; revisit mappings when official docs update.
- Keep `.github/` boundaries intact (no feature docs there).

## 10. Testing & Acceptance

- ERD present with sources and mappings sections filled.
- Tasks generated in two phases; Relevant Files listed.
- Citations resolve to official Cursor properties.

## 11. Rollout & Ops

- Land docs in a feature branch; review with rules maintainers.

## 12. Success Metrics

- Contributors correctly pick modes in PRs with fewer clarifications needed.

## 13. Open Questions

- Should we include screenshots or GIF links in `docs/projects/cursor-modes/`?
