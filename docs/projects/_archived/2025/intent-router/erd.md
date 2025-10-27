---
status: completed
owner: rules-maintainers
lastUpdated: 2025-10-08
---

# Engineering Requirements Document — Intent Router (Lite)


## 1. Introduction/Overview

Define a central intent router that parses user inputs and routes to the correct rule/phase with consent-first gates (e.g., TDD before code edits), reducing ambiguity and enforcing safety.

## 2. Goals/Objectives

- Parse phrases/commands into normalized intents (specify, plan, tasks, implement, investigate)
- Enforce consent-first and TDD gates before code-changing actions
- Prefer role–phase mapping and split-progress status (advisory until enforcement lands)
- Provide a single clarifying question when intent/targets are ambiguous

## 3. Functional Requirements

- Triggers: implicit (natural language) and explicit (slash commands)
- Parsing: extract verb, targets, and scope; default to clarify when uncertain
- Routing: map to rules (spec-driven, tdd-first, git-usage, capabilities, project-lifecycle)
- Gates: enforce phase checks and TDD owner spec paths before JS/TS edits
- Status: emit brief status updates per step
- Signals: use file/context signals as supporting triggers (e.g., focused test files)

## 4. Acceptance Criteria

- Examples of parsed inputs → routed rule + gates applied
- Clarifying-question policy documented; exactly one targeted question on ambiguity
- Integration points listed for spec-driven, tdd-first, git-usage, capabilities

## 5. Risks/Edge Cases

- Over-parsing freeform inputs; mitigate with clarify-first default
- Conflicting signals; prefer latest explicit instruction

## 6. Rollout Note

- Owner: rules-maintainers
- Comms: Link from README and split-progress doc

## 7. Testing

- Dry-run parse: “Implement rounding” → gate on TDD with owner spec path required

- Conflicting intents: “Refactor parse.ts and open a PR” → choose one; PR waits for green
- Missing details: “Add tests” (no target) → ask once for file/module; then proceed
- Slash vs phrase + consent-after-plan: “/plan X then implement it” → plan, then ask “Proceed to implement?”; if yes, TDD gate
- JS/TS hard gate: Any edit on `**/*.{ts,tsx,js,jsx}` requires owner spec path + failing assertion before code changes

DRY RUN:

- Exact-phrase `DRY RUN:` forces plan-only behavior; attach guidance-first; no edits/commands

## 8. Clarify-on-Ambiguity Policy

- Decision weights: exact phrase triggers > consent-after-plan > keyword fallback > file/context signals. If still ambiguous, ask one clarifying question and pause.
- Confidence tiers:
  - High confidence: attach immediately.
  - Medium (fuzzy/partial): ask one confirmation; attach only on “Yes/Go”.
  - Low (vague): ask one clarifying question; do not attach.
- One-shot question templates:
  - Guidance vs implementation: “Do you want guidance or for me to implement this now?”
  - Target missing: “Which file(s)/component(s) should this affect?”
  - Scope missing: “Is this limited to a directory or repo‑wide?”
  - Rule choice: “Should I route this to `tdd-first` or `spec-driven`?”
- Safety defaults: No edits/commands without consent; JS/TS edits hard‑gate on TDD confirmation (owner spec path + failing assertion) before any code change.

## 9. Example Parses

| Input                     | Intent    | Route                 | Gates                                                       |
| ------------------------- | --------- | --------------------- | ----------------------------------------------------------- |
| Implement user login      | implement | tdd-first, code-style | TDD: owner spec path + failing assertion; consent for edits |
| /plan checkout flow       | plan      | spec-driven           | consent; produce plan scaffold                              |
| Open a PR from feat/foo   | git-usage | assistant-git-usage   | consent + non-interactive                                   |
| What are Cursor’s limits? | guidance  | capabilities          | docs-backed answer; no edits                                |
| Refactor src/parse.ts     | refactor  | tdd-first             | TDD gate enforced                                           |

## 10. Integration Points and Handoff

- spec-driven: For specify/plan/tasks/analyze; emits acceptance-bundle scaffolds and links required artifacts.
- tdd-first: For implement/refactor/fix in JS/TS; pre‑edit hard gate requires owner spec path + failing assertion; block edits until Red is established.
- assistant-git-usage: For branch/commit/PR; request explicit command consent and use repo scripts non‑interactively.
- capabilities: For platform knowledge; docs-backed responses; no edits/commands.
- direct-answers: For direct questions; respond with cause, evidence, next step.
- Handoff contract: Router supplies {intent, targets, rule, gates, consentState}; callee rule executes and reports status back for consistent updates.

## 11. Slash Commands

- `/plan <topic>` → route to `spec-driven` (plan/specify); consent-first; produce plan scaffold
- `/tasks` → route to `project-lifecycle` (Task List Process subsection); manage/update tasks when safe
- `/pr` → route to `assistant-git-usage`; prefer `.cursor/scripts/pr-create.sh` with explicit consent and non-interactive flags

---

Owner: rules-maintainers
