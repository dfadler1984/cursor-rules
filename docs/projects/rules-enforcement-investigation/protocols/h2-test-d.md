# H2 Test D Protocol: Visible Gate Effectiveness

**Test**: Hypothesis 2, Test D (Visible Gate Experiment)  
**Started**: 2025-10-15  
**Objective**: Measure if visible gate output improves compliance  
**Method**: Monitor responses after gate visibility requirement added

---

## Setup Change Applied

**File**: `.cursor/rules/assistant-behavior.mdc`  
**Section**: Lines 165-194 (Compliance-first send gate)  
**Date**: 2025-10-15

**Change Summary**:

- Added requirement to OUTPUT gate checklist before sending
- Added visible query output: "Checked capabilities.mdc for [operation]: [result]"
- Added PASS/FAIL status requirement
- Strengthened enforcement: "do not send until PASS"

**Backup**: Original version in git history (commit e1d34c6)

---

## Test D Measurement Protocol

### Baseline (from Test A Retrospective)

**Session**: 2025-10-15 (before visible gate change)  
**Operations**: 17 (14 file edits, 3 terminal commands)  
**Gate Visibility**: 0% (0/17 operations showed gate output)  
**Script Usage**: 100% (5/5 recent commits conventional)  
**Overall Compliance**: 74% script, 75% TDD, 61% branch (from earlier baseline)

### Post-Change Monitoring

**What to Observe**: Responses after gate visibility requirement applied

**Expected if Rule Works**:

- ✅ Gate checklist visible in 100% of responses with actions
- ✅ "Checked capabilities.mdc" output before terminal commands
- ✅ Gate PASS/FAIL status shown
- ✅ Compliance improves (script usage >90%, fewer violations)

**Expected if Rule Doesn't Work**:

- ❌ Gate output still not visible (rule not followed)
- ❌ Same patterns as baseline
- ❌ Compliance unchanged

### Data Collection

**For Each Response with Actions** (file edits, terminal commands, git operations):

```yaml
response_id: N
date: YYYY-MM-DD
operation_types: ["file_edit", "terminal", "git"]
gate_checklist_visible: true/false
gate_status_shown: true/false (PASS/FAIL visible?)
capabilities_query_visible: true/false
consent_prompt_present: true/false
violations_present: true/false (if any, what?)
notes: "[observations]"
```

### Checkpoints

**Checkpoint 1: Next Response** (immediate)

- This response should show gate output
- Check: Is gate checklist visible above?
- Result: (to be observed by user)

**Checkpoint 2: After 5 Responses**

- Count: How many showed gate output?
- Rate: X/5 (percentage)
- Trend: Improving/stable/declining

**Checkpoint 3: After 10 Responses**

- Visibility rate: X/10
- Compliance impact: Any change in script usage?
- Decision: Keep change, refine, or revert

**Checkpoint 4: After 20 Responses**

- Full comparison to baseline
- Effectiveness: Did visible gate improve compliance?
- Final decision: Permanent change or experiment failed

---

## Success Criteria

**Primary**:

- ✅ Gate visibility: 100% (or >90% if some edge cases)
- ✅ Compliance improvement: Script usage 74% → >90%
- ✅ Violation reduction: ≥20 percentage points

**Secondary**:

- ✅ User feedback: "I can see the gate working" (transparency)
- ✅ No false positives: Gate doesn't block legitimate actions
- ✅ Reasonable performance: No significant slowdown

**Failure Conditions**:

- ❌ Gate visibility <80% (rule not being followed)
- ❌ Compliance unchanged (<10 point improvement)
- ❌ User friction (gate output is noise/clutter)

---

## Timeline

**Immediate**: Gate requirement active (already applied)  
**Checkpoint 1**: This response (right now)  
**Checkpoint 2**: After 5 more responses with actions  
**Checkpoint 3**: After 10 responses (~1-2 sessions)  
**Checkpoint 4**: After 20 responses (~2-4 sessions)  
**Final Analysis**: 1 week calendar time

---

## What Changed in assistant-behavior.mdc

**Before** (lines 165-177):

```markdown
## Compliance-first send gate (must)

Before sending any message that includes actions or tool results, explicitly verify:

- Links: all URLs converted...
- Status update: present...
  [checklist items as prose]
- If any item fails, revise the message; do not send.
```

**After** (lines 165-194):

```markdown
## Compliance-first send gate (must)

Before sending any message that includes actions or tool results, OUTPUT this checklist:
```

Pre-Send Gate:

- [ ] Links: Markdown format?
- [ ] Status: included?
      [8 checklist items]

Gate: [PASS/FAIL]

```

Then verify each item:
[detailed descriptions]

If any item fails: Mark gate as FAIL, revise, re-check, do not send until PASS.
```

**Key Differences**:

1. **"OUTPUT this checklist"** — Explicit output requirement (was "verify")
2. **Checkbox format** — Visual checklist (was prose list)
3. **PASS/FAIL status** — Must show result (was implicit)
4. **Visible query output** — "Checked capabilities.mdc for X: [result]"

---

## Risks and Mitigations

**Risk**: Gate output creates noise/clutter  
**Mitigation**: User feedback; refine format if needed; can make collapsible

**Risk**: Gate output is ignored (just becomes boilerplate)  
**Mitigation**: Measure actual compliance improvement, not just visibility

**Risk**: False positives (gate blocks legitimate actions)  
**Mitigation**: Log all FAIL cases; review for accuracy

**Risk**: Performance impact (slower responses)  
**Mitigation**: Monitor response times; optimize if needed

---

## Expected Outcome

**If Visible Gate Works**:

- Compliance improves significantly (74% → >90%)
- Violations become obvious (gate shows check but wrong action taken)
- Accountability increases (users can verify gate ran)
- Transparency improves (enforcement is visible)

**If Visible Gate Doesn't Work**:

- Gate output not visible (rule still not followed)
- OR Gate visible but compliance unchanged (output alone insufficient)
- Need deeper investigation (platform constraints? Other factors?)

---

## Next Steps

**Immediate**:

- ✅ Test D setup complete (rule modified)
- ✅ This response demonstrates new gate format
- ⏸️ Monitor subsequent responses

**After Checkpoint 3** (10 responses):

- Analyze visibility rate
- Measure compliance impact
- Decision: Keep, refine, or revert

**Integration with H1 Validation**:

- Both monitoring in parallel
- H1: Script usage over 20-30 commits
- H2 Test D: Gate visibility over 10-20 responses
- Can correlate: Does visible gate + alwaysApply = >90% compliance?

---

**Status**: Test D active (gate visibility requirement applied)  
**First Checkpoint**: This response (you should see gate checklist above)  
**Next Checkpoint**: After 5 more responses with actions
