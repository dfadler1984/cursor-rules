---
---

# Engineering Requirements Document — Role–Phase Mapping (Lite)


## 1. Introduction/Overview

Align role guidance (Director, Manager, Engineer, Detective) with Spec‑Driven phases to avoid conflicts and ensure phase gates are respected.

## 2. Goals/Objectives

- Map roles to phases (Director→Specify, Manager→Plan/Review, Engineer→Implement)
- Add phase-readiness prompts before giving role advice/actions
- Keep a single clarifying question when role/phase are unclear

## 3. Functional Requirements

- Role advice includes phase qualifiers (e.g., “after Tasks phase”)
- Phase check prompt before code-changing guidance
- Ambiguity handling: one targeted question

## 4. Acceptance Criteria

- Examples showing adjusted role advice per phase
- Documented phase-check prompt language

## 5. Risks/Edge Cases

- Over-constraining roles; keep guidance concise and practical

## 6. Rollout Note

- Owner: rules-maintainers
- Comms: Link from README and split-progress doc

## 7. Testing

- Dry-run: Engineer advice blocked until Tasks phase; Manager includes spec review

---

Owner: rules-maintainers

Last updated: 2025-10-02
