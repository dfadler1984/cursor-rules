## Relevant Files

- `docs/projects/tdd-rules-refinement/erd.md` - Canonical ERD (Lite)
- `.cursor/rules/tdd-first.mdc` - Core TDD rules
- `.cursor/rules/tdd-first-js.mdc` - JS/TS specifics
- `.cursor/rules/tdd-first-sh.mdc` - Shell specifics
- `.cursor/rules/intent-routing.mdc` - Intent detection and gates
- `.cursor/rules/assistant-behavior.mdc` - Consent/status protocols

- `docs/projects/testing-coordination/erd.md` - Unified testing coordination hub

### Notes

- Goal: strengthen detection and reduce misses without adding friction.
- Keep confirmations short; prefer one-line prompts.

## Tasks

- [ ] 1.0 Clarify scope and detection sources (priority: high)

  - [ ] 1.1 Decide languages in scope (JS/TS and shell minimum)
  - [ ] 1.2 Enumerate detection signals (verbs, consent-after-plan, file signals)
  - [ ] 1.3 Define owner spec path inference rules

- [ ] 2.0 Draft refined TDD detection/gate wording (priority: high) (depends on: 1.0)

  - [ ] 2.1 Update wording for explicit verbs and composite consent
  - [ ] 2.2 Add fallback prompts for ambiguous guidance requests
  - [ ] 2.3 Add micro status examples for Red/Green updates

- [ ] 3.0 Add examples section to TDD rules (priority: medium) (depends on: 2.0)

  - [ ] 3.1 JS/TS nano/micro cycle example
  - [ ] 3.2 Shell nano/micro cycle example

- [ ] 4.0 Integrate with intent router (priority: medium) (depends on: 2.0)

  - [ ] 4.1 Elevate TDD gates on implementation-like intents
  - [ ] 4.2 Add file-context trigger paths (maintained sources → TDD attach)

- [ ] 5.0 Validate with a small change (priority: medium) (depends on: 3.0, 4.0)

  - [ ] 5.1 Apply refined flow to a trivial docs-only change (no TDD)
  - [ ] 5.2 Apply refined flow to a tiny JS/TS function change (with TDD)
  - [ ] 5.3 Capture status notes; confirm prompts are minimal and correct
