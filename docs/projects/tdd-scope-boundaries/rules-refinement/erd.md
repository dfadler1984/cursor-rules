# Engineering Requirements Document — TDD Rules Refinement (Lite)

Mode: Lite

## 1. Introduction/Overview

Refine TDD-related rules so the assistant more reliably identifies when TDD must be applied and guides nano/micro cycles. Emphasis on detection signals, pre-edit gates, and concise confirmations that reduce false positives/negatives.

### Uncertainty / Assumptions

- [NEEDS CLARIFICATION: scope — JS/TS + shell only, or broader?]
- [NEEDS CLARIFICATION: where detection hooks live — router vs. rule files?]
- Assumption: docs-first changes; no runtime dependencies.

## 2. Goals/Objectives

- Make TDD triggers and gates explicit and easily detectable.
- Reduce missed TDD applications on implementation/refactor/bug-fix intents.
- Keep confirmations lightweight; avoid over-prompting on obvious cases.

## 3. User Stories

- As a developer, I get a precise prompt to add a failing spec before any edit.
- As a maintainer, I see fewer cases where edits occur without owner specs.
- As a reviewer, I can verify TDD gates were applied via concise status notes.

## 4. Functional Requirements

1. Intent Detection

   - Strengthen triggers for implementation-like intents (implement/add/fix/refactor/update) and consent-after-plan.
   - Add fallback detection from file context signals (opening `*.spec.*`, editing maintained sources).

2. Pre-edit TDD Gate

   - Before editing maintained sources, surface owner spec path(s) and require Red → Green → Refactor.
   - If spec missing, prompt to create colocated `*.spec.*` first.

3. Status Updates

   - Emit concise Red/Green micro-updates when tests fail/pass.
   - Note any deviations and request a one-line confirmation to proceed.

4. Documentation & Examples

   - Provide nano/micro cycle examples for JS/TS and shell.
   - Link to `tdd-first.mdc`, `tdd-first-js.mdc`, `tdd-first-sh.mdc`.

## 5. Non-Functional Requirements

- Keep wording short and skimmable; avoid duplicating existing rules.
- Zero external dependencies; local docs-only.

## 6. Architecture/Design

- Update routing rules to elevate TDD gates on implementation-like intents and file signals.
- Add minimal examples block to TDD rules; cross-link from this ERD.

## 7. Data Model and Storage

- Artifacts: `erd.md`, `tasks.md` under `docs/projects/tdd-rules-refinement/`.

## 8. API/Contracts

- None; rule documents only. Examples are illustrative, not executable.

## 9. Integrations/Dependencies

- Existing rules: `tdd-first.mdc`, `tdd-first-js.mdc`, `tdd-first-sh.mdc`, `intent-routing.mdc`, `assistant-behavior.mdc`.

## 10. Edge Cases and Constraints

- Avoid double-prompting when explicit verbs are present and owner spec path is known.
- When uncertainty remains (ambiguous goal), prefer one clarifying question.

## 11. Testing & Acceptance

- Acceptance (docs-level):
  - ERD and tasks exist; project listed in `docs/projects/README.md` under Active.
  - TDD gates are clearly enumerated with detection sources and minimal prompts.
  - Example nano/micro cycles are present for JS/TS and shell.

## 12. Rollout & Ops

- Phase 1: Draft refined detection/gate text and examples.
- Phase 2: Apply to one small change and observe status updates.
- Phase 3: Integrate refinements into routing and rules.

## 13. Success Metrics

- Fewer missed TDD prompts on implementation-like intents.
- Reduced confirmation friction without losing safety.

## 14. Open Questions

- Should we add a short “owner spec reminder” snippet to status updates by default?
- Where should examples live — inside TDD rules vs. a shared examples doc?
