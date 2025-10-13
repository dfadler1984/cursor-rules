# Tasks — Consent Gates Refinement

## Phase 1: Analysis

- [ ] Document recent consent gate issues (over-prompting, missed gates, unclear state)
- [ ] Categorize common operations by risk: safe → moderate → risky
- [ ] Review current exception mechanisms and identify gaps
- [ ] Measure baseline: over-prompting rate, missed risky ops, exception usage

## Phase 2: Refinement

- [ ] Define risk tiers with clear criteria and examples
- [ ] Expand safe read-only allowlist based on common operations
- [ ] Improve composite consent-after-plan signal detection
- [ ] Add consent state tracking across turns
- [ ] Create consent decision flowchart for assistant reference

## Phase 3: Validation

- [ ] Create consent test suite with ≥15 test cases
- [ ] Deploy refinements and monitor for 1 week
- [ ] Measure post-deployment metrics (over-prompting reduction, safety maintained)
- [ ] Update `assistant-behavior.mdc` with refined consent rules

## Related Files

- `.cursor/rules/assistant-behavior.mdc` (consent-first section)
- `.cursor/rules/security.mdc` (command execution rules)
- `.cursor/rules/user-intent.mdc`
