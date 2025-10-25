---
status: active
owner: repo-maintainers
created: 2025-10-24
lastUpdated: 2025-10-24
---

# Engineering Requirements Document — Roles & Intent Routing (Lite)

Mode: Lite


Links: `.cursor/rules/intent-routing.mdc` | `docs/projects/roles/tasks.md` | `docs/projects/split-progress/erd.md`

## 1. Introduction/Overview

Define role modes (Director, Manager, Engineer, Detective) and intent routing to adapt outputs and guardrails per role.

## 2. Goals/Objectives

- Map phrases/commands to roles with a single clarifying question on ambiguity
- Specify per-role output posture (verbosity, consent prompts, safety emphasis)
- Define transitions between roles as new signals appear

## 3. Functional Requirements

- Role selection based on trigger phrases and context
- Output posture varies per role; defaults to Engineer when unclear
- Composite consent-after-plan recognized for implementation steps

## 4. Acceptance Criteria

### Core Requirements

- Triggers list with examples per role
- Per-role posture checklist (e.g., TDD gate in Engineer)
- Transition rules documented; ambiguity resolution policy stated

### Nested Sub-Project

This project includes phase-mapping as an extension:

**Phase Mapping** (`phase-mapping/`)

- Status: New (drafted)
- Scope: Align role guidance with Spec-Driven phases
- Links: [`phase-mapping/erd.md`](phase-mapping/erd.md), [`phase-mapping/tasks.md`](phase-mapping/tasks.md)
- Dependency: Requires core role definitions complete

### Overall Completion

- [ ] ✅ Core role modes defined (Director/Manager/Engineer/Detective)
- [ ] ✅ Trigger phrases and examples documented
- [ ] ✅ Per-role posture described with examples
- [ ] ✅ Phase mapping complete (role advice aligned with workflow phases)

## 5. Risks/Edge Cases

- Ambiguous prompts; mitigate with one clarifying question
- Conflicting signals; prefer latest explicit instruction

## 6. Rollout Note

- Owner: rules-maintainers
- Comms: Link from README and progress doc

## 7. Testing

- Dry-run examples for each role; verify posture differences

## 8. Examples

### Triggers → Role

| Trigger phrase                     | Routed role |
| ---------------------------------- | ----------- |
| "Create an ERD for checkout flow"  | Director    |
| "Plan tasks for checkout flow"     | Manager     |
| "Implement price rounding in cart" | Engineer    |
| "Why is the build failing on CI?"  | Detective   |

### Per-role output deltas

- Director: asks one clarifying question; outputs ERD/spec skeleton (no file writes without consent)
- Manager: sequences steps with acceptance bundle; single active sub-task note
- Engineer: enforces TDD gate; lists owner spec path(s) before edits
- Detective: cites evidence paths/logs; proposes smallest next diagnostic step

### Short example outputs

- Director:
  - "To scope the checkout ERD: Do you need guest checkout? I'll propose `docs/specs/checkout-flow-spec.md` with Goals, Functional Requirements, Acceptance Criteria. Proceed?"
- Manager:
  - "Steps: 1) Add cart validation; 2) Wire price rounding; 3) Update totals. Acceptance bundle: targets [web/src/cart.ts, web/src/cart.spec.ts], exactChange 'Round to 2 decimals', successCriteria ['spec passes'], runInstructions ['yarn test web/src/cart.spec.ts -t "rounds to 2"']."
- Engineer:
  - "Owner spec: web/src/cart.spec.ts. Failing assertion: it('rounds to 2 decimals'). I'll add the failing spec first, then implement minimal rounding in cart.ts."
- Detective:
  - "CI log shows Jest timeout in web/src/api.spec.ts; evidence: .github/workflows/ci.yml step 'test'. Smallest next step: run `yarn test web/src/api.spec.ts -t "retries"` locally with increased timeout."

---

Owner: rules-maintainers

Last updated: 2025-10-02
