---
status: completed
owner: rules-maintainers
---

# Engineering Requirements Document — Repository Health Validation Fixes (Lite)


## 1. Introduction/Overview

Fix validation issues discovered by `deep-rule-and-command-validate.sh` to restore repository health score from 52/100 to 90+/100. Issues include: 20 undocumented scripts in capabilities.mdc, 1 broken reference in script-execution.mdc (fixed), and test colocation warnings.

**Trigger**: Output from `bash .cursor/scripts/deep-rule-and-command-validate.sh` showing health score 52/100.

## 2. Goals/Objectives

- Document all scripts in `capabilities.mdc` (currently 20 missing)
- Fix broken rule references (1 found in `script-execution.mdc` — already fixed)
- Resolve test colocation issues
- Restore health score to 90+/100
- Ensure all validators pass cleanly

## 3. Functional Requirements

1. **Capabilities Documentation**

   - Add 20 undocumented scripts to `.cursor/rules/capabilities.mdc`
   - Organize by category (compliance, context-efficiency, PR tools, rules validators, etc.)
   - Include brief description for each script
   - Maintain alphabetical or logical ordering within categories

2. **Broken References**

   - ✅ Fixed: `script-execution.mdc` updated (removed `alp-triggers.sh` references)
   - Verify no other broken script references exist in rules

3. **Test Colocation**

   - Investigate test colocation validator failures
   - Ensure all test files properly colocated with source scripts
   - Fix any violations

4. **Validation**
   - Run `deep-rule-and-command-validate.sh` after fixes
   - Verify health score improves to 90+/100
   - All cross-validation checks passing

## 4. Acceptance Criteria

- ✅ All scripts documented in `capabilities.mdc` (0/59 missing) — **Completed**
- ✅ No broken references in rules (0 issues) — **Completed**
- ✅ Test colocation validator passes — **Completed**
- ✅ Health score ≥ 90/100 — **Achieved 100/100**
- ✅ `deep-rule-and-command-validate.sh` exits with all validators passing — **Completed**

## 5. Risks/Edge Cases

**Risks**:

- Large edit to `capabilities.mdc` may introduce formatting issues
- Some scripts may be internal helpers (should they be documented?)
- Test colocation issues may reveal deeper structural problems

**Mitigations**:

- Review each script before documenting (skip internal helpers like `.lib-*.sh`)
- Use capabilities-sync.sh output as starting point
- Validate formatting after each batch of additions

**Edge Cases**:

- Scripts without clear descriptions (check script header comments)
- Scripts that are deprecated but still present (mark as deprecated)
- Test files with unconventional naming (investigate why colocation fails)

## 6. Rollout Note

**Owner**: rules-maintainers  
**Timeline**: 1-2 hours  
**Phases**:

1. Document scripts in capabilities.mdc (30-45 min)
2. Fix test colocation issues (15-30 min)
3. Validate and verify health score (5-10 min)

## 7. Testing

**Validation steps**:

1. Run `deep-rule-and-command-validate.sh` before fixes (baseline: 52/100)
2. Apply fixes incrementally
3. Run validation after each fix batch
4. Final run should show 90+/100 with all validators passing

**Success**: Health score improves by at least 40 points (52 → 90+)
