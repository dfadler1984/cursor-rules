# H1 Validation Protocol — AlwaysApply Fix Monitoring

**Purpose**: Validate that changing `assistant-git-usage.mdc` to `alwaysApply: true` improves compliance  
**Started**: 2025-10-15  
**Duration**: Until 20-30 commits accumulated  
**Status**: MONITORING

---

## Fix Applied

**Date**: 2025-10-15  
**Change**: `assistant-git-usage.mdc` → `alwaysApply: true`  
**Commit**: (to be recorded when committed)

**Hypothesis**: Making git-usage rule always-apply will improve script usage compliance

---

## Baseline Metrics (Pre-Fix)

**Established**: 2025-10-15  
**Method**: `bash .cursor/scripts/compliance-dashboard.sh --limit 100`

### Results:

| Metric         | Baseline | Target   | Improvement Needed |
| -------------- | -------- | -------- | ------------------ |
| Script usage   | 74%      | >90%     | +16 points         |
| TDD compliance | 75%      | >95%     | +20 points         |
| Branch naming  | 61%      | >90%     | +29 points         |
| **Overall**    | **70%**  | **>90%** | **+20 points**     |

**Note**: H1 fix specifically targets script usage. TDD and branch naming are secondary indicators.

---

## Validation Protocol

### Phase 1: Accumulation (Passive Monitoring)

**Duration**: Until 20-30 new commits

**Activities**:

1. Work normally on repository
2. Let assistant handle git operations naturally
3. No special efforts to "test" the fix
4. Accumulate real-world usage data

**Check Points**:

- After 10 commits: Quick check (`compliance-dashboard --limit 10`)
- After 20 commits: Formal measurement
- After 30 commits: Final validation

### Phase 2: Measurement (Active Validation)

**When**: After 20-30 new commits accumulated

**Command**:

```bash
bash .cursor/scripts/compliance-dashboard.sh --limit 25
```

**Data to Collect**:

- Script usage rate (current)
- Comparison to baseline (74%)
- Trend analysis (improving/stable/declining)
- Violation patterns (if any remain)

### Phase 3: Analysis

**Success Criteria**:

- ✅ Script usage >90% (target met)
- ✅ Improvement ≥16 points from baseline
- ✅ Violations <10% (if any, documented with patterns)

**Partial Success**:

- ⚠️ Script usage 80-90% (improved but below target)
- ⚠️ Improvement 10-15 points (positive trend)
- Action: Identify remaining gaps, consider H3 (query visibility)

**Failure**:

- ❌ Script usage <80% (minimal improvement)
- ❌ Improvement <10 points
- Action: Investigate why; H2 (send gate) and H3 become critical

---

## Monitoring Commands

### Quick Check (any time)

```bash
# Check recent 10 commits
bash .cursor/scripts/check-script-usage.sh --limit 10

# Full dashboard for recent 25 commits
bash .cursor/scripts/compliance-dashboard.sh --limit 25
```

### Formal Validation (after 20-30 commits)

```bash
# Complete dashboard
bash .cursor/scripts/compliance-dashboard.sh --limit 30

# Detailed script usage analysis
bash .cursor/scripts/check-script-usage.sh --limit 30

# Cross-check TDD compliance
bash .cursor/scripts/check-tdd-compliance.sh --limit 30
```

---

## What to Observe

### Positive Signals (Fix Working)

1. **Consistent script usage**

   - `git-commit.sh` used for all commits
   - `git-branch-name.sh` used for branch creation
   - `pr-create.sh` used for PR operations

2. **Conventional commit messages**

   - Format: `type(scope): description`
   - Types: feat, fix, docs, etc.
   - No raw "commit message" formats

3. **No violations in recent history**
   - Dashboard shows >90% compliance
   - Trend is stable or improving

### Warning Signals (Fix Partially Working)

1. **Intermittent script usage**

   - Some commits use scripts, some don't
   - Pattern unclear (when/why it works)

2. **Specific contexts trigger violations**

   - Example: Multi-file edits skip scripts
   - Example: PR creation still uses raw commands

3. **Compliance 80-90%**
   - Better than baseline but below target
   - Suggests additional factors at play

### Failure Signals (Fix Not Working)

1. **No improvement**

   - Still around 70-75% compliance
   - Same violation patterns as baseline

2. **Script usage not increasing**

   - Dashboard shows no trend improvement
   - Manual git commands still common

3. **Rule not in context**
   - Evidence: assistant doesn't reference git-usage rule
   - Suggests alwaysApply setting not effective

---

## Investigation Triggers

### If Compliance Reaches Target (>90%)

**Action**: Document success and proceed

1. Update findings.md with validation results
2. Mark H1 as VALIDATED
3. Consider if H2/H3 still needed (likely yes, for understanding)
4. Proceed to synthesis phase

### If Compliance 80-90% (Partial Success)

**Action**: Investigate remaining gaps

1. Analyze violation patterns

   - Which operations still bypass scripts?
   - What contexts trigger failures?

2. Execute H3 (Query Visibility)

   - Test if visible query output improves compliance
   - May be the missing piece

3. Document findings
   - What worked (alwaysApply helped)
   - What didn't (remaining 10-20% violations)

### If Compliance <80% (Failure)

**Action**: Deep investigation required

1. Execute H2 (Send Gate Enforcement)

   - Is gate actually running?
   - Does it detect violations?
   - Does it block them?

2. Execute H3 (Query Visibility)

   - Is query step executed?
   - Would visible output help?

3. Re-examine H1 hypothesis
   - Was conditional attachment really the root cause?
   - Or was it one factor among many?

---

## Documentation Protocol

### After Each Check Point

**File**: This document (h1-validation-protocol.md)

**Update sections**:

- Commit count
- Compliance score
- Observations
- Trend (improving/stable/declining)

### After Final Validation (20-30 commits)

**Files to Update**:

1. **findings.md**

   - Add "H1 Validation Results" section
   - Document success/partial/failure
   - Include baseline vs final comparison

2. **tasks.md**

   - Check off task 9.0 (Monitor git-usage improvement)
   - Update status for Phase 6B (next steps)

3. **README.md**
   - Update status line
   - Note validation complete

---

## Check Point Log

### Check Point 1: After ~10 Commits

**Date**: (to be filled)  
**Commit Count**: (to be filled)  
**Command**: `bash .cursor/scripts/compliance-dashboard.sh --limit 10`

**Results**:

- Script usage: \_\_\_\_%
- Trend: (improving/stable/declining)
- Observations: (any patterns noted)

### Check Point 2: After ~20 Commits

**Date**: (to be filled)  
**Commit Count**: (to be filled)  
**Command**: `bash .cursor/scripts/compliance-dashboard.sh --limit 20`

**Results**:

- Script usage: \_\_\_\_%
- Trend: (improving/stable/declining)
- Observations: (any patterns noted)

### Check Point 3: Final Validation (~30 Commits)

**Date**: (to be filled)  
**Commit Count**: (to be filled)  
**Command**: `bash .cursor/scripts/compliance-dashboard.sh --limit 30`

**Results**:

- Script usage: \_\_\_\_%
- Improvement from baseline: **\_** points
- Success criteria met: (yes/partial/no)
- Next steps: (based on results)

---

## Success Criteria (Reminder)

**Primary**:

- ✅ Script usage >90% (from 74% baseline)
- ✅ Improvement ≥16 percentage points
- ✅ Trend stable or improving

**Secondary**:

- ✅ Violation patterns documented (if <100%)
- ✅ No regression in other metrics (TDD, branch naming)

**Completion Gate**:

- ✅ 20-30 commits accumulated
- ✅ Measurements taken and documented
- ✅ Results analyzed against criteria
- ✅ Next steps determined based on results

---

## Current Status

**Fix Applied**: 2025-10-15  
**Commits Since Fix**: 0  
**Target Commits**: 20-30  
**Status**: AWAITING USAGE DATA

**Next Milestone**: Check Point 1 (after ~10 commits)

---

## Notes

- This is passive monitoring; no special testing needed
- Natural repository work will accumulate data
- Check points are for tracking, not for intervention
- Final validation determines next phase actions
- If failure or partial success, H2/H3 become critical (not optional)
