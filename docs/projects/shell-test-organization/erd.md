---
status: active  
owner: Engineering
created: 2025-10-21  
lastUpdated: 2025-10-24
---

# Engineering Requirements Document: Shell Test Organization

Mode: Lite


## 1. Problem Statement

Shell script tests are currently colocated with their source scripts (e.g., `pr-labels.sh` + `pr-labels.test.sh`), similar to the JS/TS pattern. However, this may impact **discoverability** — users scanning `.cursor/scripts/` for available tools must visually filter test files from executable scripts.

**Key tension**: Colocation aids maintainability (test next to code), but centralization aids discoverability (scripts folder shows only tools).

**Trigger**: After creating `pr-labels.sh` + `pr-labels.test.sh`, noticed the `.cursor/scripts/` directory now mixes tools and tests, making it harder to scan what scripts are available.
## 2. Goals

### Primary

- **Investigate** whether shell tests should move to a centralized `tests/` directory or remain colocated
- **Measure** the trade-offs: discoverability vs maintainability vs consistency with JS/TS patterns
- **Recommend** a standard for shell test organization with clear rationale

### Secondary

- Ensure the test runner (`.cursor/scripts/tests/run.sh`) works with either approach
- Document the decision and encode it in rules if needed
- Provide migration plan if centralization is chosen
## 3. Current State

### Directory Structure

```
.cursor/scripts/
  ├── pr-labels.sh                    # Script
  ├── pr-labels.test.sh               # Test (colocated)
  ├── pr-changeset-sync.sh            # Script
  ├── setup-remote.sh                 # Script
  ├── setup-remote.test.sh            # Test (colocated)
  ├── check-tdd-compliance.sh         # Script
  ├── tests/
  │   └── run.sh                      # Test runner
  └── [many other scripts...]
```

### Test Discovery

- Runner: `bash .cursor/scripts/tests/run.sh -k <keyword> -v`
- Pattern: Discovers `*.test.sh` under `.cursor/scripts/` recursively
- Works with both colocated and centralized tests

### JS/TS Pattern (for comparison)

- Tests colocated: `parse.ts` + `parse.spec.ts` in same folder
- Rule enforced: `test-quality-js.mdc` requires colocation
- CI guard: `yarn guard:no-tests-dir` fails if `__tests__/` exists
## 4. Proposed Solutions

### Option A: Keep Colocation (Status Quo)

**Structure**:
```
.cursor/scripts/
  ├── pr-labels.sh
  ├── pr-labels.test.sh
  ├── setup-remote.sh
  ├── setup-remote.test.sh
  └── ...
```

**Pros**:
- ✅ Test next to code (easy to find related test)
- ✅ Consistent with JS/TS pattern (colocation everywhere)
- ✅ Proximity aids maintenance (edit script + test together)
- ✅ No migration needed

**Cons**:
- ❌ Scripts directory cluttered (harder to scan available tools)
- ❌ `.sh` extension doesn't distinguish purpose (script vs test)
- ❌ Listing scripts requires filtering (`ls *.sh | grep -v test`)

### Option B: Centralize to `tests/`

**Structure**:
```
.cursor/scripts/
  ├── pr-labels.sh
  ├── setup-remote.sh
  ├── tests/
  │   ├── run.sh
  │   ├── pr-labels.test.sh
  │   └── setup-remote.test.sh
  └── ...
```

**Pros**:
- ✅ Clean scripts directory (only executable tools visible)
- ✅ Easy to scan available scripts (`ls .cursor/scripts/*.sh`)
- ✅ Tests organized separately (clear separation of concerns)
- ✅ Matches common shell project patterns

**Cons**:
- ❌ Distance from code (must navigate to `tests/` to find test)
- ❌ Inconsistent with JS/TS pattern (breaks unified colocation model)
- ❌ Migration effort (move files, update any references)
- ❌ Two patterns to maintain (JS colocated, shell centralized)

### Option C: Hybrid (Subdirectory Colocation)

**Structure**:
```
.cursor/scripts/
  ├── pr-labels/
  │   ├── pr-labels.sh
  │   └── pr-labels.test.sh
  ├── setup-remote/
  │   ├── setup-remote.sh
  │   └── setup-remote.test.sh
  └── tests/
      └── run.sh
```

**Pros**:
- ✅ Clear organization (each tool is a folder)
- ✅ Tests still colocated with code
- ✅ Cleaner top-level directory

**Cons**:
- ❌ More complex directory structure
- ❌ Invocation changes (`bash .cursor/scripts/pr-labels/pr-labels.sh`)
- ❌ Significant migration effort
- ❌ Breaks existing workflows and documentation
## 5. Investigation Approach

### Phase 1: Data Gathering

1. **Count current test files** — How many `*.test.sh` files exist?
2. **Measure directory clutter** — What % of `.cursor/scripts/*.sh` are tests vs tools?
3. **Survey similar projects** — How do other shell-heavy repos organize tests?
4. **Check test runner impact** — Does runner work equally with all options?

### Phase 2: Trade-Off Analysis

1. **Discoverability** — Time to find available scripts (simulate new user)
2. **Maintainability** — Effort to update script + test (measure proximity value)
3. **Consistency** — Value of unified colocation pattern across languages
4. **Migration cost** — Effort to move tests if centralization chosen

### Phase 3: Recommendation

1. **Decision matrix** — Weight trade-offs by importance
2. **Proposed standard** — Recommend Option A, B, or C with rationale
3. **Rule encoding** — Update `test-quality-sh.mdc` if pattern changes
4. **Migration plan** — If moving, document steps and script
## 6. Success Criteria

### Must Have

- [ ] Trade-off analysis complete (discoverability vs maintainability vs consistency)
- [ ] Decision made with clear rationale (documented)
- [ ] Test runner verified to work with chosen approach
- [ ] Rule updated if pattern changes (`test-quality-sh.mdc`)

### Should Have

- [ ] Migration script created (if centralization chosen)
- [ ] All existing tests moved (if centralization chosen)
- [ ] Documentation updated (scripts README, test-quality rules)
- [ ] Pattern validated with 3+ scripts following new standard

### Nice to Have

- [ ] Survey of similar projects (external validation)
- [ ] Helper script to create new script + test in chosen pattern
- [ ] Metrics on discoverability improvement (if measurable)
## 7. Non-Goals

- **Not** changing JS/TS test organization (stays colocated)
- **Not** creating new test infrastructure (runner already exists)
- **Not** rewriting tests (only moving location if needed)
## 8. Dependencies & Constraints

### Dependencies

- Test runner: `.cursor/scripts/tests/run.sh` (must continue to work)
- TDD rules: `tdd-first-sh.mdc`, `test-quality-sh.mdc` (may need updates)
- Existing tests: ~10-15 `*.test.sh` files (migration scope)

### Constraints

- Test runner discovery pattern must remain functional
- Cannot break existing test invocations during migration
- Should minimize disruption to active development
## 9. Open Questions

1. **How many shell tests exist?** (Need count to assess migration scope)
2. **How often are tests edited vs scripts scanned?** (Usage pattern informs priority)
3. **Do other Cursor rules repos centralize shell tests?** (External patterns)
4. **What's the user experience impact?** (Quantify discoverability difference)
## 10. Timeline

**Phase 1 (Data Gathering)**: 1-2 hours
- Count tests, measure clutter, check runner compatibility

**Phase 2 (Trade-Off Analysis)**: 1-2 hours
- Decision matrix, simulate discoverability, measure maintenance effort

**Phase 3 (Recommendation)**: 1 hour
- Document decision, update rules if needed

**Phase 4 (Migration)** (if needed): 2-3 hours
- Create migration script, move tests, validate

**Total Estimated**: 5-8 hours
## 11. Related Work

- **Rules Enforcement Investigation** (`docs/projects/rules-enforcement-investigation/`)
  - Validated: TDD-first with colocation for JS/TS
  - Question: Should shell follow same pattern?

- **Test Quality Rules**
  - `test-quality-sh.mdc` — May need update if pattern changes
  - `tdd-first-sh.mdc` — References owner coupling and focused harness

- **Similar Projects**
  - JS/TS colocation: Enforced via `test-quality-js.mdc` and CI guard
  - Investigation docs structure: Recently standardized in `investigation-structure.mdc`
## References

- Test runner: `.cursor/scripts/tests/run.sh`
- Shell TDD rules: `.cursor/rules/tdd-first-sh.mdc`, `.cursor/rules/test-quality-sh.mdc`
- Colocation enforcement (JS): `yarn guard:no-tests-dir`
