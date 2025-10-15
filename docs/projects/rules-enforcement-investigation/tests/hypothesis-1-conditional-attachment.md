# Test Plan: Hypothesis 1 — Conditional Attachment is a Weak Point

**Hypothesis**: Making `assistant-git-usage.mdc` always-apply will reduce script-first violations because the rule will always be in context.

**Related Discovery Section**: Part 4 → Hypothesis 1

---

## Background

**Current State**:

- `assistant-git-usage.mdc` has `alwaysApply: false`
- Only attached when `intent-routing.mdc` detects git terms (commit, branch, PR, etc.)
- Violations occurred: "used `git commit --amend` instead of `git-commit.sh`"

**Theory**:

- If assistant initiates git action without explicit git terms in user message
- Or if context is full and rule is not prioritized
- Then script-first protocol may not be in context

---

## Test Design

### Control Group (Baseline)

**Setup**:

- Keep `assistant-git-usage.mdc` with `alwaysApply: false`
- No changes to intent routing

**Test Scenarios** (10 trials each):

1. Direct git request: "commit these changes"
2. Indirect git request: "save this work" (no "commit" keyword)
3. Imperative without keyword: "record the current state"
4. Fix previous: "amend the last commit"
5. Update remote: "push this upstream"

**Measurement**:

- Record: Was `assistant-git-usage.mdc` attached? (check status/routing transparency)
- Record: Did assistant use repo script? (git-commit.sh vs raw git)
- Calculate: Script usage rate per scenario

### Experimental Group

**Setup**:

1. Change `assistant-git-usage.mdc`:
   ```diff
   ---
   description: Assistant Git usage
   - alwaysApply: false
   + alwaysApply: true
   ```
2. Restart Cursor to ensure rule reloaded

**Test Scenarios** (same 10 trials each):

1. Direct git request: "commit these changes"
2. Indirect git request: "save this work"
3. Imperative without keyword: "record the current state"
4. Fix previous: "amend the last commit"
5. Update remote: "push this upstream"

**Measurement**:

- Record: Was `assistant-git-usage.mdc` in context? (should be always)
- Record: Did assistant use repo script?
- Calculate: Script usage rate per scenario

---

## Success Criteria

### Primary Metrics

**Script Usage Rate**:

- Control (baseline): Expected ~60-70% (misses on indirect requests)
- Experimental: Target >90% (should catch all requests)
- **Success threshold**: Experimental > Control by ≥20 percentage points

**Rule Attachment Rate**:

- Control: Expected ~60-70% (keyword-dependent)
- Experimental: Target 100% (always-apply)
- **Success threshold**: Experimental = 100%

### Secondary Metrics

**False Positives** (noise from always-apply):

- Count: How many times rule was in context but not needed?
- Target: <10% noise rate
- **Acceptable if**: Script usage improvement outweighs noise cost

**Context Size Impact**:

- Measure: Token count difference with rule always-apply
- Target: <5% increase in average context size
- **Concern**: If always-apply causes context bloat

---

## Measurement Protocol

### During Each Trial

1. **Issue test request** (from scenario list)
2. **Record assistant response**:
   - Check for status transparency: "Triggered by: [signal]"
   - Check for script usage: Look for `.cursor/scripts/git-commit.sh` invocation
   - Check for raw git: Look for `git commit` direct call
3. **Log result**:
   ```csv
   scenario,group,rule_attached,script_used,notes
   "commit these changes",control,yes,yes,""
   "save this work",control,no,no,"missed routing"
   ```

### Post-Trial Analysis

1. **Calculate rates** per group:

   ```
   Script Usage Rate = (script_used_count / total_trials) * 100
   Rule Attachment Rate = (rule_attached_count / total_trials) * 100
   ```

2. **Statistical comparison**:

   - Use proportion test (z-test) for script usage rates
   - p-value < 0.05 for significance
   - Calculate effect size (Cohen's h)

3. **Qualitative analysis**:
   - Review "missed routing" cases from control
   - Review "noise" cases from experimental (rule present but irrelevant)

---

## Data Collection Template

```markdown
### Trial Log

**Scenario**: [test scenario]
**Group**: [control/experimental]
**Request**: "[exact user message]"

**Observation**:

- Rule attached? [yes/no] — Evidence: [status message or context check]
- Script used? [yes/no] — Evidence: [command invocation or raw git]
- Command executed: `[exact command]`
- Notes: [any deviations, errors, or observations]

**Classification**:

- [ ] Success: rule attached + script used
- [ ] Partial: rule attached but script not used
- [ ] Failure: rule not attached, script not used
- [ ] Noise: rule attached but not relevant
```

---

## Expected Outcomes

### If Hypothesis is Correct

**Control Group**:

- Script usage rate: ~60-70%
- Misses on indirect requests (scenarios 2, 3)
- Misses on non-standard git terms (scenario 4: "amend", scenario 5: "push")

**Experimental Group**:

- Script usage rate: >90%
- Catches all indirect requests
- Catches non-standard git terms
- **Pattern**: Always-apply eliminates routing misses

**Conclusion**: Conditional attachment IS a weak point; always-apply significantly improves compliance

### If Hypothesis is Incorrect

**Possible Outcomes**:

1. **No improvement**: Script usage rate same in both groups

   - Implication: Rule presence ≠ rule enforcement
   - Next: Investigate gate enforcement (Hypothesis 2)

2. **Improvement but modest**: Script usage rate improves by <10 points

   - Implication: Conditional attachment is A weak point, not THE weak point
   - Next: Multiple factors at play

3. **Improvement with high noise**: Script usage improves but context bloat significant
   - Implication: Trade-off exists; need targeted solution
   - Next: Consider slash commands or visible query instead

---

## Follow-Up Investigations

### If Hypothesis Confirmed

1. **Identify other high-risk conditional rules**:

   - Which other rules with `alwaysApply: false` should be promoted?
   - Criteria: high-risk operations (data loss, inconsistency)

2. **Measure context impact**:

   - Does always-apply cause performance degradation?
   - Are there context window size concerns?

3. **Optimize rule size**:
   - Can `assistant-git-usage.mdc` be split into always-apply core + optional details?

### If Hypothesis Rejected

1. **Investigate routing logs**:

   - Was rule present in failed cases?
   - If yes → gate enforcement issue (Hypothesis 2)
   - If no → routing has additional failure modes

2. **Test intent detection**:
   - Are keywords insufficient?
   - Do we need semantic intent classification?

---

## Implementation Checklist

### Pre-Test Setup

- [ ] Create test scenarios CSV template
- [ ] Set up logging mechanism (manual or automated)
- [ ] Establish baseline: run control group first (10 trials × 5 scenarios = 50 trials)
- [ ] Document current rule state (alwaysApply: false, routing triggers)

### Control Group Execution

- [ ] Run 50 baseline trials (5 scenarios × 10 repetitions)
- [ ] Log all results to CSV
- [ ] Calculate control group metrics
- [ ] Identify routing miss patterns

### Experimental Group Setup

- [ ] Backup current `assistant-git-usage.mdc`
- [ ] Change `alwaysApply: false` → `alwaysApply: true`
- [ ] Restart Cursor / reload rules
- [ ] Verify rule is always-apply (check rule status)

### Experimental Group Execution

- [ ] Run 50 experimental trials (same 5 scenarios × 10 repetitions)
- [ ] Log all results to CSV
- [ ] Calculate experimental group metrics
- [ ] Note any context/performance issues

### Analysis

- [ ] Compare script usage rates (control vs experimental)
- [ ] Statistical significance test (proportion z-test)
- [ ] Review miss patterns (control) vs success patterns (experimental)
- [ ] Assess noise/context impact
- [ ] Document findings

### Reporting

- [ ] Write summary: hypothesis confirmed/rejected/partial
- [ ] Quantitative evidence: rates, p-values, effect sizes
- [ ] Qualitative evidence: example cases, patterns
- [ ] Recommendations: keep change, revert, modify, or investigate further

---

## Timeline

- **Control group**: 2-3 hours (50 trials + logging)
- **Setup change**: 5 minutes
- **Experimental group**: 2-3 hours (50 trials + logging)
- **Analysis**: 1-2 hours
- **Reporting**: 1 hour
- **Total**: ~1 day of focused testing

---

## Risk Mitigation

**Risk**: Always-apply increases context size, hits token limits  
**Mitigation**: Monitor context size; revert if >10% increase or performance degrades

**Risk**: Rule always-apply creates noise (irrelevant attachments)  
**Mitigation**: Log noise cases; if >20% noise rate, consider rule splitting

**Risk**: Change doesn't persist (Cursor caching)  
**Mitigation**: Verify rule status at start of each experimental trial

---

## Automation Opportunities

**Semi-automated testing** (future):

1. Script to generate test requests
2. Script to parse assistant responses for script usage
3. Automated CSV logging
4. Statistical analysis script

**Fully automated** (stretch):

1. Cursor API (if available) to run trials
2. Response parsing + classification
3. End-to-end test harness

---

**Status**: Ready to execute  
**Owner**: rules-enforcement-investigation  
**Dependencies**: None (standalone test)  
**Estimated effort**: 1 day  
**Priority**: HIGH (low-effort, high-impact if confirmed)
