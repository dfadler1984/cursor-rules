## Tasks — Shell Test Organization

**Status**: ACTIVE | Phase: Discovery | ~0% Complete

**Update**: Project created to investigate whether shell script tests should be centralized in `tests/` directory or remain colocated with scripts.

---

## Phase 1: Data Gathering

- [ ] 1.0 Count current state
  - [ ] 1.1 Count total `*.test.sh` files in `.cursor/scripts/`
  - [ ] 1.2 Count total `*.sh` files (scripts) in `.cursor/scripts/`
  - [ ] 1.3 Calculate percentage: tests vs scripts
  - [ ] 1.4 Document clutter level

- [ ] 2.0 Verify test runner compatibility
  - [ ] 2.1 Confirm runner works with colocated tests (current)
  - [ ] 2.2 Test runner with centralized tests (mock structure)
  - [ ] 2.3 Document any changes needed to runner

- [ ] 3.0 Survey similar projects (optional)
  - [ ] 3.1 Check 3-5 shell-heavy repos on GitHub
  - [ ] 3.2 Document their test organization patterns
  - [ ] 3.3 Note any common practices

## Phase 2: Trade-Off Analysis

- [ ] 4.0 Measure discoverability
  - [ ] 4.1 Time to find available scripts (simulate new user)
  - [ ] 4.2 Compare: `ls .cursor/scripts/*.sh` (colocated vs centralized)
  - [ ] 4.3 Document ease of scanning

- [ ] 5.0 Measure maintainability
  - [ ] 5.1 Time to update script + test (colocated)
  - [ ] 5.2 Time to update script + test (centralized, simulated)
  - [ ] 5.3 Document proximity value

- [ ] 6.0 Assess consistency impact
  - [ ] 6.1 Value of unified colocation (JS/TS and shell)
  - [ ] 6.2 Cost of split patterns (JS colocated, shell centralized)
  - [ ] 6.3 Document maintenance burden

## Phase 3: Recommendation

- [ ] 7.0 Create decision matrix
  - [ ] 7.1 Weight trade-offs by importance
  - [ ] 7.2 Score each option (A, B, C from ERD)
  - [ ] 7.3 Select recommended approach

- [ ] 8.0 Document decision
  - [ ] 8.1 Write recommendation with clear rationale
  - [ ] 8.2 Document any rule changes needed
  - [ ] 8.3 Create migration plan if needed

- [ ] 9.0 Update rules (if pattern changes)
  - [ ] 9.1 Update `test-quality-sh.mdc`
  - [ ] 9.2 Update `tdd-first-sh.mdc` if needed
  - [ ] 9.3 Validate rules pass `rules-validate.sh`

## Phase 4: Migration (if centralization chosen)

- [ ] 10.0 Create migration script
  - [ ] 10.1 Script to move `*.test.sh` to `tests/`
  - [ ] 10.2 Update any hardcoded paths
  - [ ] 10.3 Test script on sample files

- [ ] 11.0 Execute migration
  - [ ] 11.1 Run migration script
  - [ ] 11.2 Verify all tests still discoverable
  - [ ] 11.3 Run full test suite to confirm no breaks

- [ ] 12.0 Update documentation
  - [ ] 12.1 Update scripts README if exists
  - [ ] 12.2 Update test-quality rules
  - [ ] 12.3 Document new pattern for future scripts

---

## Summary

**Current Phase**: Discovery (not started)  
**Next Milestone**: Count current state, assess test runner compatibility  
**Completion**: ~0% (Project just created)

**Deliverables**:
- Decision matrix with recommendation
- Updated rules (if pattern changes)
- Migration script (if centralization chosen)
- Documentation updates

