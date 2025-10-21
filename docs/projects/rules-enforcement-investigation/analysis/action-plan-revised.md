# Action Plan: TDD Investigation First (Revised 2025-10-20)

**Based on**: User feedback - investigate WHY rules are ignored before changing alwaysApply  
**Status**: READY TO EXECUTE  
**Estimated total effort**: ~5-6 hours investigation + implementation based on findings

---

## Key Insight from User

> "I've never said that we have had a problem with globs. From what I've seen the globs work, but sometimes the agent still ignores the rules"

**This changes everything**:

- ❌ **Problem is NOT**: Rules don't load (globs work fine)
- ✅ **Problem IS**: Rules are ignored even when loaded
- ✅ **Solution**: Understand WHY before changing alwaysApply settings

---

## Revised Priorities

### Priority 1: TDD Compliance Investigation (NEW)

- Understand root cause of 17% non-compliance
- Don't assume alwaysApply is the solution
- Data-driven recommendations

### Priority 2: Quick Wins

- Remove failed experiments (git-slash-commands)
- Improve intent routing for known issues

### Priority 3: Implementation

- Apply findings from investigation
- Validate improvements

---

## Phase 1: Investigation (~3-4 hours)

### 1.1: TDD Compliance Root Cause Analysis

**Purpose**: Understand why TDD rules are violated 17% of the time even when loaded via globs

**Investigation document**: [`tdd-compliance-investigation.md`](tdd-compliance-investigation.md)

**Four hypotheses to examine**:

1. **H1: Rule Content Unclear**

   - Rule is reference-heavy (points to 3 other rules)
   - Doesn't spell out immediate action clearly
   - Multiple hops to get actionable guidance

2. **H2: Conflicting Rules**

   - TDD says "create test first"
   - Consent says "ask before creating files"
   - Scope-check says "clarify criteria first"
   - Which takes precedence?

3. **H3: Measurement Error**

   - Library files (`.lib-net.sh`) - tested via consumers
   - Test files themselves - don't need own tests
   - Trivial changes - comments, formatting
   - How much of 17% is legitimate exceptions?

4. **H4: Habit/Oversight**
   - Cognitive load (too many rules)
   - Competing priorities
   - Workflow interruption
   - Unclear consequences

**Investigation steps**:

**Step 1: Data Analysis**

```bash
# Run compliance checker
bash .cursor/scripts/check-tdd-compliance.sh --limit 100 > /tmp/tdd-compliance.txt

# Analyze violations
# - Pick 3-5 to deep-dive
# - Categorize: exception vs real violation
# - Calculate adjusted compliance rate
```

**Step 2: Rule Content Analysis**

- Map reference chain: tdd-first-sh → test-quality-sh → testing → tdd-first
- Extract immediate requirements (what to do BEFORE editing)
- Compare to high-compliance rules (assistant-git-usage @ 96%)

**Step 3: Rule Interaction Analysis**

- List rules that load together when editing shell/JS files
- Map decision points and potential conflicts
- Test conflict scenarios

**Step 4: Pattern Analysis**

- Look for violation patterns (time/type/context)
- Compare to compliance successes
- Examine pre-send gate effectiveness

**Expected outcomes**:

- Root cause(s) identified with evidence
- Adjusted compliance rate (accounting for exceptions)
- Specific recommendations (NOT just "make alwaysApply")
- Action plan for improvements

---

### 1.2: Remove Failed Experiments (~15 minutes)

**File to edit**: `.cursor/rules/git-slash-commands.mdc`

**Change**:

```yaml
alwaysApply: true  →  alwaysApply: false
lastReviewed: 2025-10-20
reason: Experiment failed (runtime routing wrong, Cursor uses / for prompt templates)
```

**Validation**:

```bash
bash .cursor/scripts/rules-validate.sh
```

**Impact**: Saves ~2k tokens

---

### 1.3: Improve Intent Routing (~1 hour)

**For rules with confirmed violations**:

**`project-lifecycle.mdc`**:

- Add triggers: "complete project", "archive project", "mark complete", "project done"
- Strengthen completion checklist

**`spec-driven.mdc`**:

- Add triggers: "should we plan", "need a plan", "design first"
- Emphasize planning before implementation

**`guidance-first.mdc`**:

- Add triggers: "should we", "would you recommend", "what do you think about"
- Clarify guidance vs implementation signals

---

## Phase 2: Recommendations Based on Findings (~1-2 hours)

**After TDD investigation complete, we'll have**:

### Scenario A: Most 17% are legitimate exceptions

- **Real compliance**: >90%
- **Action**: Update compliance checker to filter exceptions
- **Action**: Document what counts as exception
- **Outcome**: Problem mostly solved, no rule changes needed

### Scenario B: Rule content is unclear

- **Root cause**: Reference chain too long, language not actionable
- **Action**: Simplify rule language, add "Before editing" checklist
- **Action**: Reduce cross-reference hops
- **Outcome**: Clearer rules → better compliance

### Scenario C: Rules conflict

- **Root cause**: TDD, consent, and scope-check create decision paralysis
- **Action**: Document precedence in assistant-behavior.mdc
- **Action**: Add escape valves for TDD + consent
- **Outcome**: Clear decision path → better compliance

### Scenario D: Habit/oversight issue

- **Root cause**: Too many rules, competing priorities, no consequences
- **Action**: Strengthen visible reminders (pre-send gate)
- **Action**: Add TDD item to send gate checklist
- **Action**: Consider external validation (CI checks)
- **Outcome**: Reinforced habit → better compliance

### Scenario E: Multiple factors

- **Action**: Address highest-impact issue first
- **Action**: Re-measure after first fix
- **Action**: Iterate based on results

---

## Phase 3: Implementation (Based on Phase 2 Findings)

**Will be determined by investigation results**

**Possible actions** (not decided yet):

- Update rule language (if H1 confirmed)
- Document precedence (if H2 confirmed)
- Update compliance checker (if H3 confirmed)
- Strengthen pre-send gate (if H4 confirmed)
- Add external validation (CI/pre-commit for TDD)
- **Only if necessary**: Consider alwaysApply for TDD rules

---

## Phase 4: Validation (1-2 weeks passive)

**After implementing improvements**:

1. Accumulate 20-30 commits
2. Re-measure TDD compliance
3. Target: >90% (accounting for legitimate exceptions)
4. If target met: Document success
5. If target missed: Iterate with additional improvements

---

## What Changed From Original Plan

### Original Plan (Premature)

- ❌ Assumed alwaysApply was the solution
- ❌ Didn't investigate WHY rules were violated
- ❌ Didn't account for globs working correctly
- ❌ Would have added +4k tokens without understanding problem

### Revised Plan (Data-Driven)

- ✅ Investigate root cause first
- ✅ Recognize that globs work (problem is elsewhere)
- ✅ Four hypotheses to examine with data
- ✅ Multiple possible solutions beyond alwaysApply
- ✅ Make decision after investigation, not before

---

## User's Priorities (Documented)

From conversation:

1. **"alwaysApply should be reserved for all but the most important rules"**

   - Don't use alwaysApply casually
   - Investigate other solutions first

2. **"Globs work, but sometimes the agent still ignores the rules"**

   - Problem is NOT loading
   - Problem IS compliance even when loaded

3. **"These sound like good questions to ask"** (about WHY rules are violated)

   - User wants investigation-first approach
   - Data-driven decision making

4. **"Option 1 with option 2 added as a task to look into later"**
   - Investigate root cause (Option 1)
   - External validation as future task (Option 2)

---

## Timeline Estimates

**Phase 1: Investigation**

- TDD compliance analysis: 3-4 hours
- Remove failed experiments: 15 minutes
- Improve intent routing: 1 hour
- **Subtotal**: ~4-5 hours

**Phase 2: Recommendations**

- Synthesize findings: 1-2 hours
- Document action plan: 30 minutes
- **Subtotal**: ~1.5-2.5 hours

**Phase 3: Implementation**

- **Unknown**: Depends on findings
- Estimate: 1-3 hours

**Phase 4: Validation**

- Passive: 1-2 weeks
- Analysis: 1 hour

**Total**: ~7-11 hours active + 1-2 weeks passive validation

---

## Completion Checklist

Investigation complete when:

- [ ] **TDD investigation complete** (all 4 hypotheses examined)
- [ ] **Root cause(s) identified** with evidence
- [ ] **Adjusted compliance rate calculated** (accounting for exceptions)
- [ ] **Specific recommendations made** (based on data)
- [ ] **Approved improvements implemented**
- [ ] **Validation period complete** (20-30 commits measured)
- [ ] **Target >90% achieved** (or understood why not)
- [ ] **Findings documented** for future reference

---

## Next Immediate Steps

1. ✅ Hooks findings documented
2. ✅ AlwaysApply review complete
3. ✅ Modes investigation complete
4. ✅ TDD investigation plan created
5. ⏸️ **User approval**: Proceed with TDD investigation?
6. ⏸️ Execute Phase 1 (investigation)
7. ⏸️ Synthesize findings and recommendations
8. ⏸️ Implement approved improvements
9. ⏸️ Validate and measure results

---

**Status**: Action plan revised based on user feedback  
**Ready to execute**: Phase 1.1 (TDD investigation)  
**Awaiting**: User approval to begin investigation

**Key change**: Investigation-first, not solution-first
