---
---

# Engineering Requirements Document — Intent Router (Lite)

Links: `.cursor/rules/intent-router.mdc` | `docs/projects/intent-router/tasks.md` | `docs/projects/split-progress/erd.md`

## 1. Introduction/Overview

Define a central intent router that parses user inputs and routes to the correct rule/phase with consent-first gates (e.g., TDD before code edits), reducing ambiguity and enforcing safety.

## 2. Goals/Objectives

- Parse phrases/commands into normalized intents (specify, plan, tasks, implement, investigate)
- Enforce consent-first and TDD gates before code-changing actions
- Respect role–phase mapping and split-progress status
- Provide a single clarifying question when intent/targets are ambiguous

## 3. Functional Requirements

- Triggers: implicit (natural language) and explicit (slash commands)
- Parsing: extract verb, targets, and scope; default to clarify when uncertain
- Routing: map to rules (spec-driven, tdd-first, git-usage, capabilities, drawing-board)
- Gates: enforce phase checks and TDD owner spec paths before JS/TS edits
- Status: emit brief status updates per step

## 4. Acceptance Criteria

- Examples of parsed inputs → routed rule + gates applied
- Clarifying-question policy documented; exactly one targeted question on ambiguity
- Integration points listed for spec-driven, tdd-first, git-usage, capabilities, drawing-board

## 5. Risks/Edge Cases

- Over-parsing freeform inputs; mitigate with clarify-first default
- Conflicting signals; prefer latest explicit instruction

## 6. Rollout Note

- Owner: rules-maintainers
- Comms: Link from README and split-progress doc

## 7. Testing

- Dry-run parse: “Implement rounding” → gate on TDD with owner spec path required
- Dry-run parse: “Could you add X to the drawing board?” → `/draw X`

---

Owner: rules-maintainers

Last updated: 2025-10-02
