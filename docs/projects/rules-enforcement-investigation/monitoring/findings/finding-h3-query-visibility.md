---
findingId: 1
date: "2025-10-24"  # Inferred from migration
project: "rules-enforcement-investigation"
severity: "medium"  # Default for migrated findings
status: "open"      # Default for migrated findings
reviewed: false
reviewedBy: null
reviewedDate: null
sourceLogs: []      # To be filled post-migration
---

# H3 Meta-Violation — Assistant Self-Test

**Date**: 2025-10-15  
**Type**: Validation data point  
**Context**: Rules enforcement investigation

---

## Event

**Scenario**: Assistant proposed git commit during investigation session

**What Should Have Happened** (per H3 implementation):

1. Query: "Is there a script in capabilities.mdc for commit?"
2. **OUTPUT result**: "Checked capabilities.mdc for commit: found `.cursor/scripts/git-commit.sh`"
3. Use script: `bash .cursor/scripts/git-commit.sh ...`

**What Actually Happened**:

1. ❌ No query output shown
2. ❌ Proposed raw `git commit -m "..."` directly
3. ❌ Didn't use script until user prompted

**User Intervention**: User asked "Should the self-improvement rule account for this?"

**Corrective Action Taken**:

1. Acknowledged meta-violation
2. Output query result (late)
3. Used `git-commit.sh` properly
4. Also used `git-branch-name.sh` when pre-commit hook blocked main

---

## H3 Validation Data

### Query Visibility

- **Expected**: "Checked capabilities.mdc for commit: found ..."
- **Actual**: Not shown (0% visibility)
- **Pattern**: Same as H2 baseline (advisory requirements → silent/skipped)

### Compliance

- **Expected**: Script used automatically
- **Actual**: Script not used until after user prompted
- **Finding**: Even with explicit OUTPUT requirement implemented, not followed

---

## Why This Matters

### 1. Meta-Test Evidence

This is a **meta-test** — testing whether the assistant follows its own rules during investigation:

- **Hypothesis**: Rules work when properly enforced
- **Evidence**: Rule implemented but not followed immediately
- **Implication**: Implementation ≠ automatic compliance; enforcement matters

### 2. H3 Validation

Confirms H3 hypothesis about query visibility:

- Baseline: Query not visible → script usage inconsistent
- After implementation: Query still not visible in this instance → script not used
- **Conclusion**: Visibility requirement needs active enforcement, not just definition

### 3. Self-Improvement Pattern Gap

Identified gap in `self-improve.mdc`:

**Missing**: Meta-consistency requirement during investigations

**Proposed**:

> When investigating rule enforcement, **apply those rules to your own process**.
>
> - Investigating scripts? Use scripts consistently
> - Investigating gates? Follow gates yourself
> - Investigating visibility? Make your own checks visible

**Why**: Violating patterns under investigation:

- Undermines credibility
- Misses valuable validation data
- Reduces investigation effectiveness

---

## Corrective Actions Taken

### Immediate (This Session)

1. ✅ Used `git-branch-name.sh` to create branch
2. ✅ Used `git-commit.sh` for all 3 commits
3. ✅ Documented meta-violation as H3 data

### Proposed (Follow-up)

4. [ ] Update `self-improve.mdc`: add meta-consistency requirement
5. [ ] Include in H3 final results as validation data point
6. [ ] Consider: Does H2/H3 need additional enforcement beyond OUTPUT requirement?

---

## Lessons Learned

### For Investigation

- **Meta-violations are valuable data**: They reveal where rules need strengthening
- **Document in real-time**: Capture evidence as it happens
- **User prompts reveal gaps**: Questions like "should the rule account for this?" identify missing coverage

### For Rule Design

- **Explicit requirements aren't enough**: Need enforcement mechanisms
- **Visibility alone doesn't guarantee compliance**: Need forcing functions
- **Self-consistency matters**: Rules apply to rule creators/investigators too

---

## Next Steps

1. **Monitor**: Track whether visible query output appears in future git operations
2. **Update rules**: Add meta-consistency to `self-improve.mdc`
3. **Include in synthesis**: Document as part of H3 findings
4. **Generalize pattern**: Create "meta-test" checklist for future investigations

---

**Status**: Documented as H3 validation data  
**Impact**: Confirms need for enforcement beyond definition  
**Value**: Real-world evidence of rule compliance challenges
