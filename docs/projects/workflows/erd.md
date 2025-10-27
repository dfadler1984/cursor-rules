---
status: active
owner: repo-maintainers
created: 2025-10-24
lastUpdated: 2025-10-24
---

# Engineering Requirements Document — Workflows (Lite)

Mode: Lite

## 1. Introduction/Overview

Investigate and define “workflows” as encoded, repeatable ways of doing tasks to get more reliable results from the assistant. Focus on representing common flows (specify → plan → tasks; PR flow; logging; validations) as lightweight, reusable rules and templates.

### Uncertainty / Assumptions

- [NEEDS CLARIFICATION: scope — authoring guidance only vs. runnable helpers?]
- [NEEDS CLARIFICATION: target areas — planning, tasks, git, logging, research?]
- Assumption: local-only docs/rules; no external services.

## 2. Goals/Objectives

- Capture repeatable assistant workflows as concise, composable rules.
- Improve reliability by reducing ambiguity and enforcing small, deterministic gates.
- Provide minimal templates and checklists to encode “how we do things”.

## 3. User Stories

- As a maintainer, I can reference standard workflows to guide contributions.
- As a developer, I can follow encoded steps to reliably complete tasks.
- As a reviewer, I can verify artifacts against workflow checklists.

## 4. Functional Requirements

1. Define a small set of core workflows with clear triggers and outcomes.
2. Provide templates/checklists for each workflow (acceptance bundle friendly).
3. Integrate with existing rules: consent-first, TDD-first, task-list process, self-improvement logs (see `docs/projects/assistant-self-improvement/`).
4. Document minimal, reversible steps; prefer local read/edit and validation scripts.

## 5. Non-Functional Requirements

- Keep artifacts small, readable, and portable (Markdown + shell scripts only).
- Avoid new dependencies; reuse existing repo tooling.

## 6. Architecture/Design

- Represent workflows as rule docs under `.cursor/rules/` with light templates in `docs/`.
- Cross-link from project index; keep examples under `docs/projects/_examples/` if needed.

## 7. Data Model and Storage

- Optional: small templates under `.cursor/templates/workflows/` (future work).

## 8. API/Contracts

- None (docs-first). Prefer CLI wrappers only when valuable and testable.

## 9. Integrations/Dependencies

- Reuse existing rules: `spec-driven`, `project-lifecycle` (Task List Process subsection)

## 10. Edge Cases and Constraints

- Don’t over-prescribe; keep workflows opt-in and modular.
- Ensure rules do not conflict; resolve precedence explicitly.

## 11. Testing & Acceptance

- Acceptance (docs-level):
  - ERD and tasks exist; project listed in `docs/projects/README.md` under Active.
  - Each workflow has a concise checklist and clear entry/exit criteria.
  - Example application on a small change demonstrates reliability gains.

## 12. Rollout & Ops

- Phase 1: Draft 2–3 core workflows and templates.
- Phase 2: Validate on one small project; adjust wording.
- Phase 3: Document adoption guidance.

## 13. Success Metrics

- Fewer clarification back-and-forths during tasks.
- Higher consistency in task execution (checklist adherence observed).

## 14. Open Questions

- Which core workflows first? Candidate set: ERD→Tasks, Small Fix via TDD, PR with Changesets, Self-Improvement logging.
- Where to place runnable helpers (if any) and how to test them?
