# Tasks — TDD Scope Boundaries

## Phase 1: Scope Definition

- [ ] Document recent false positives (docs/configs triggering TDD gate)
- [ ] Define explicit include/exclude globs for TDD scope
- [ ] Create decision tree for TDD applicability
- [ ] List edge cases and clarification thresholds

## Phase 2: Implementation

- [ ] Update `tdd-first.mdc` with scope definition and decision tree
- [ ] Add pre-edit scope check before TDD gate
- [ ] Add status transparency: note "TDD: in-scope" or "TDD: exempt (reason)"
- [ ] Create `.cursor/scripts/tdd-scope-check.sh <file>` validation helper

## Phase 3: Validation

- [ ] Create TDD scope test suite with ≥10 file types
- [ ] Test with real workflows: code edits (TDD), docs (no TDD), configs (no TDD)
- [ ] Verify zero false negatives and zero false positives
- [ ] Monitor for 1 week and adjust edge cases

## Related Files

- `.cursor/rules/tdd-first.mdc`
- `.cursor/rules/testing.mdc`
- `.cursor/rules/code-style.mdc`
