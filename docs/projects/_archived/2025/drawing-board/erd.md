---
---

# Engineering Requirements Document — Drawing Board (Lite)

Links: `.cursor/rules/drawing-board.mdc` | `docs/projects/_archived/2025/drawing-board/tasks.md` | `docs/projects/split-progress/erd.md`

## 1. Introduction/Overview

Define a sandboxed Drawing Board for prototyping concepts (e.g., intent router, role-tailoring enhancements, bash script linting, Jest inference) before promoting them to full rules. Provide safe, consent-first triggers and log outcomes for future rule creation.

## 2. Goals/Objectives

- Provide an ideation/prototyping space with explicit triggers
- Support intent routing like “add {thing} to the drawing board” → `/draw {thing}`
- Catalog prototype concepts and outcomes; suggest candidates for promotion
- Keep effects minimal and logged; no production changes without consent

## 3. Functional Requirements

- Trigger: `@drawing-board` and `/draw <concept>`
- Intent routing step parses freeform requests into `/draw <concept>`
- Supported concept categories (non-exhaustive):
  - role-tailoring(-enhance)
  - intent-router (central, phase-aware)
  - bash-script-linting (e.g., ShellCheck exploration)
  - jest-inference (infer test patterns)
- Outcomes logged to `docs/assistant-learning-logs/` (local default)
- Propose promotion targets to rule creation flow

## 4. Acceptance Criteria

- Rule link present (`.cursor/rules/drawing-board.mdc`) with process: intent routing → `/draw` → log → propose
- Tasks file created with at least one active prototype concept
- Examples for at least two `/draw` invocations

## 5. Risks/Edge Cases

- Ambiguous “{thing}” parsing; mitigate with a single clarifying question
- Scope creep; keep experiments minimal with clear stop conditions

## 6. Rollout Note

- Owner: rules-maintainers
- Comms: Link from README and split-progress doc

## 7. Testing

- Dry-run: parse “Could you add role-tailoring enhance to the drawing board?” → `/draw role-tailoring-enhance`
- Log stub output to `docs/assistant-learning-logs/` and verify file created

---

Owner: rules-maintainers

Last updated: 2025-10-02
