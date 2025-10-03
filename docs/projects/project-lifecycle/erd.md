---
status: completed
completed: 2025-10-03
owner: rules-maintainers
---

---

---

# Engineering Requirements Document — Project Lifecycle & Completion Process (Lite)

Links: `docs/projects/project-lifecycle/tasks.md` | `docs/projects/project-lifecycle/completion-checklist.template.md` | `docs/projects/project-lifecycle/final-summary.template.md` | `docs/projects/project-lifecycle/final-summary.md`

## 1. Introduction/Overview

Define a lightweight, consistent process to mark projects as completed without breaking links: prefer status tagging and indexing over moving folders; allow optional archiving for legacy/large projects.

## 2. Goals/Objectives

- Standardize completion flow and definition of done.
- Keep stable paths; introduce Active vs Completed index.
- Provide templates: Completion Checklist and Final Summary.
- Document optional `_archive` policy and redirects.

## 3. Functional Requirements

1. Status Tagging

   - Add front matter fields: `status: active|completed`, `completed: YYYY-MM-DD`, `owner`.
   - Apply to `erd.md` and optionally `tasks.md`.

2. Indexing

   - Maintain `docs/projects/index.md` (or similar) listing Active vs Completed projects automatically or manually.

3. Completion Checklist

   - Template covering ERD updated, tasks closed, tests green (coverage > 0), learning log summary, ADRs updated, docs updated, ownership note.

4. Final Summary

   - Short write-up with outcome, what worked, improvements, next review date, and links.

5. Archive Policy (optional)
   - Keep projects in place; only move to `docs/projects/_archive/<name>` when truly legacy.
   - Provide a simple redirect/note from original path if moved.

## 4. Acceptance Criteria

- New projects can be marked `completed` without moving directories.
- An index shows Active vs Completed.
- Templates exist and are referenced from the ERD.
- Archive guidance documented and optional.

## 5. Risks/Edge Cases

- Diverging styles across projects; mitigate with templates.
- Link rot if folders are moved; prefer status tagging first.

## 6. Rollout Note

- Start manual; add automation later if desired.
- Owner: rules-maintainers
- Comms: link from `README.md`.

## 7. Testing

- Dry-run on one existing project: set `status: completed` and verify it appears under Completed index.
- Validate links remain intact.

---

Owner: rules-maintainers

Last updated: 2025-10-03
