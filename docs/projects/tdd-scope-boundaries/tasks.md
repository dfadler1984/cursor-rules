# Tasks — TDD Scope Boundaries

## Phase 1: Scope Definition

- [ ] Document recent false positives (docs/configs triggering TDD gate)
- [x] Define explicit include/exclude globs for TDD scope
- [x] Create decision tree for TDD applicability
- [x] List edge cases and clarification thresholds

## Phase 2: Implementation

- [x] Update `tdd-first.mdc` with scope definition and decision tree
- [x] Add pre-edit scope check before TDD gate
- [x] Add status transparency: note "TDD: in-scope" or "TDD: exempt (reason)"
- [x] Create `.cursor/scripts/tdd-scope-check.sh <file>` validation helper

## Phase 3: Validation

- [x] Create TDD scope test suite with ≥10 file types (12 test cases, 24 assertions)
- [ ] Test with real workflows: code edits (TDD), docs (no TDD), configs (no TDD)
- [ ] Verify zero false negatives and zero false positives
- [ ] Monitor for 1 week and adjust edge cases

## Related Files

- `.cursor/rules/tdd-first.mdc`
- `.cursor/rules/testing.mdc`
- `.cursor/rules/code-style.mdc`
