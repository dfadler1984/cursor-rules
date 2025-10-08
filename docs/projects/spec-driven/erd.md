---
---

# Engineering Requirements Document — Spec‑Driven Workflow (Lite)

[Links: Glossary](../../glossary.md)

Links: `.cursor/rules/spec-driven.mdc` | `docs/projects/spec-driven/tasks.md` | `docs/projects/split-progress/erd.md`

## 1. Introduction/Overview

Specify the phased workflow: Specify (ERD/spec) → Plan → Tasks, with deterministic artifacts and progress rules.

## 2. Goals/Objectives

- Deterministic artifact templates and cross-links
- Single active sub-task policy with status updates
- Slash commands preference over phrase triggers when both present

## 3. Functional Requirements

- Generate `docs/specs/<feature>-spec.md`, `docs/plans/<feature>-plan.md`, `projects/<feature>/tasks/tasks-<feature>.md`
- Required headings and acceptance bundle schema for Plans
- Phase boundary confirmations unless explicit verbs are used

## 4. Acceptance Criteria

- Templates documented for Spec, Plan, and Tasks
- Acceptance bundle schema present and example provided
- Progress rules and integrations with TDD-first noted

## 5. Risks/Edge Cases

- Over-constraining templates; keep minimal required sections

## 6. Rollout Note

- Owner: rules-maintainers
- Comms: Link from README and progress doc

## 7. Testing

- Create sample trio and validate required sections and cross-links

## 8. Minimal Templates (filled)

### Spec (docs/specs/<feature>-spec.md)

- Overview: One-sentence purpose
- Goals: 2–3 bullets
- Functional Requirements: 3–5 bullets
- Acceptance Criteria: 2–3 measurable checks
- Risks/Edge Cases: 1–2 bullets

### Plan (docs/plans/<feature>-plan.md)

- Steps:
  - Step 1: short imperative
  - Step 2: short imperative
- Acceptance Bundle:
  - targets: ["src/foo.ts", "src/foo.spec.ts"]
  - exactChange: "Implement X in foo.ts"
  - successCriteria: ["Spec 'does X' passes"]
  - constraints: ["No new deps"]
  - runInstructions: ["yarn test src/foo.spec.ts -t 'does X'"]

### Tasks (projects/<feature>/tasks/tasks-<feature>.md)

- Relevant Files listed
- Todo:
  - [x] First step done
  - [ ] Second step (active)

## 9. Acceptance Bundle Example

```json
{
  "targets": ["web/src/cart.ts", "web/src/cart.spec.ts"],
  "exactChange": "Round totals to 2 decimals in cart.ts",
  "successCriteria": ["Spec 'rounds to 2 decimals' passes"],
  "constraints": ["No new dependencies"],
  "runInstructions": [
    "yarn test web/src/cart.spec.ts -t 'rounds to 2 decimals'"
  ],
  "ownerSpecs": ["web/src/cart.spec.ts"]
}
```

## 10. Single Active Sub-task Progression

- [x] Add rounding helper
- [ ] Wire rounding in totals (active)
- [ ] Update UI display

---

Owner: rules-maintainers

Last updated: 2025-10-02
