# Tasks — Routing Optimization

## Phase 1: Analysis

- [ ] Review last 20 conversations for routing decisions (correct/incorrect/delayed)
- [ ] Identify top 10 most-used intent patterns and their outcomes
- [ ] Document common failure modes (ambiguous signals, conflicting triggers)
- [ ] Measure baseline: false-positive rate, context overhead, time-to-route

## Phase 2: Optimization

- [ ] Refine trigger patterns for top 10 intents based on analysis
- [ ] Implement confidence-based disambiguation for medium matches
- [ ] Add routing test suite with ≥20 test cases covering edge cases
- [ ] Reduce redundant rule content via cross-references

## Phase 3: Validation

- [ ] Run routing test suite and verify accuracy
- [ ] Deploy optimizations and monitor for 1 week
- [ ] Measure post-deployment metrics and compare to baseline
- [ ] Document findings and update `intent-routing.mdc` successor

## Related Files

- `.cursor/rules/intent-routing.mdc` (archived)
- `.cursor/rules/user-intent.mdc`
- `.cursor/rules/guidance-first.mdc`
