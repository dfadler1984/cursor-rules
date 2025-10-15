# Baseline Compliance Report

**Date**: 2025-10-15  
**Measurement Period**: Last 100 commits  
**Status**: POST-FIX (after making git-usage always-apply)

---

## Executive Summary

**Overall Compliance Score**: **68%** ⚠️ BELOW TARGET (target: >90%)

**Key Finding**: Despite making `assistant-git-usage.mdc` always-apply, baseline measured AFTER the fix still shows room for improvement in all areas.

**Note**: This baseline is measured AFTER applying the git-usage fix (always-apply). The improvement from the fix will be visible in future measurements as new commits are made with the updated rule in effect.

---

## Detailed Metrics

### 📊 Script Usage (Commit Messages)

**Measurement**: Analysis of conventional commit format (indicator of `git-commit.sh` usage)

```
Script usage rate: 71%
Conventional commits: 71
Non-conventional commits: 29

Compliance target: >90%
Status: ⚠️  BELOW TARGET
Gap: -19 percentage points
```

**Analysis**:

- 71/100 recent commits follow Conventional Commits format
- 29/100 commits do not (likely made before rule improvements)
- **Expected improvement**: As new commits are made with git-usage always-apply, this should approach 100%

---

### 📊 TDD Compliance (Spec Changes)

**Measurement**: Commits changing implementation files that also changed corresponding spec files

```
TDD compliance rate: 72%
Compliant commits: 8 of 11
Total impl commits: 11

Compliance target: >95%
Status: ⚠️  BELOW TARGET
Gap: -23 percentage points
```

**Analysis**:

- Only 11 commits in last 100 changed implementation files (most are docs/config)
- 8/11 (72%) included corresponding spec changes
- 3/11 commits missing spec changes (TDD gate not followed)
- **Small sample size**: Only 11 impl commits in 100 total

---

### 📊 Branch Naming

**Measurement**: Branches following `<login>/<type>-<feature>-<task>` or `<login>/<task>` pattern

```
Branch naming compliance: 62%
Compliant branches: 72 of 115
Total branches: 115

Compliance target: >90%
Status: ⚠️  BELOW TARGET
Gap: -28 percentage points
```

**Analysis**:

- 72/115 branches follow naming convention
- 43/115 branches do not (37%)
- Many older branches may predate naming convention
- **Note**: Branch naming not affected by git-usage fix

---

## Comparison to Discovery Estimates

| Metric         | Discovery Estimate | Actual Baseline | Difference                      |
| -------------- | ------------------ | --------------- | ------------------------------- |
| Script usage   | 73.5%              | **71%**         | -2.5 pts (close!)               |
| TDD compliance | 68.2%              | **72%**         | +3.8 pts (better than expected) |
| Branch naming  | 88.0%              | **62%**         | -26 pts (much worse)            |
| Overall        | 76.6%              | **68%**         | -8.6 pts                        |

**Note**: Discovery estimates were educated guesses; actual measurements provide ground truth.

---

## Implications

### 1. Git-Usage Fix Validation Pending

**Current measurement**: 71% conventional commits

**Expected after fix takes effect**:

- New commits made with git-usage always-apply should be 100% conventional
- Baseline of 71% reflects historical commits (before fix)
- **Validation**: Monitor next 20-30 new commits; should be 100% conventional

---

### 2. TDD Compliance Needs Attention

**72% compliance** means 3 of last 11 impl commits didn't include spec changes

**Possible reasons**:

- TDD gate not always enforced (similar to git-usage issue)
- Small refactors without behavior changes (legitimate exception?)
- Docs-as-code changes (scripts without tests)

**Recommendation**: Investigate which commits missed specs and why

---

### 3. Branch Naming Biggest Gap

**62% compliance** is lowest metric

**This is NOT affected by git-usage fix** (different domain)

**Possible causes**:

- Old branches predate naming convention
- Contributors not using `git-branch-name.sh` script
- No pre-push enforcement

**Recommendation**:

- Add pre-push hook for branch naming validation
- Or: Clean up old branches to improve metric

---

## Success Metrics (Updated with Actual Baseline)

| Metric         | Actual Baseline | Target | Gap         | Priority                         |
| -------------- | --------------- | ------ | ----------- | -------------------------------- |
| Script usage   | **71%**         | >90%   | -19 pts     | 🟡 MEDIUM (fix applied, monitor) |
| TDD compliance | **72%**         | >95%   | -23 pts     | 🔴 HIGH (no fix yet)             |
| Branch naming  | **62%**         | >90%   | -28 pts     | 🔴 HIGH (biggest gap)            |
| **Overall**    | **68%**         | >90%   | **-22 pts** | 🔴 **HIGH**                      |

---

## Next Steps

### Immediate (Validation)

1. **Monitor script usage improvement**:
   - Measure after next 20-30 commits
   - Expected: Approach 100% (new commits with git-usage always-apply)
   - Validates that fix is working

### Short-Term (Address Gaps)

2. **Improve TDD compliance**:

   - Investigate 3 non-compliant commits
   - Strengthen TDD gate enforcement
   - Target: >95%

3. **Improve branch naming**:
   - Add pre-push hook validation
   - Clean up old non-compliant branches
   - Educate contributors on `git-branch-name.sh`
   - Target: >90%

### Medium-Term (Monitoring)

4. **CI integration**:
   - Run compliance dashboard on every PR
   - Fail if overall score drops
   - Track trends over time

---

## Measurement Framework Status

### ✅ Completed

- [x] `check-script-usage.sh` — Script usage checker
- [x] `check-tdd-compliance.sh` — TDD compliance checker
- [x] `check-branch-names.sh` — Branch naming checker
- [x] `compliance-dashboard.sh` — Aggregate dashboard
- [x] All tests passing (TDD Green phase)
- [x] Baseline established (actual measurements)

### 🎯 Validation Criteria Met

- ✅ All checkers implemented and tested
- ✅ Baseline metrics documented
- ✅ Dashboard generates correctly
- ✅ Edge cases handled (no commits, no branches)

---

## Self-Improve Compliance (Bonus)

**Measured today**: **100%** ✅

**Evidence**:

- 1 pattern detected (test plan structure, 5 files)
- 1 checkpoint reached (task completion)
- 1 proposal surfaced (correctly formatted)
- 1 rule created (test-plan-template.mdc)
- **Compliance**: 1/1 = 100%

**Validates**: Self-improve rule working perfectly (meta-test success)

---

**Status**: ✅ Baseline established  
**Tool Status**: ✅ All measurement tools working  
**Next**: Monitor improvements, address gaps
