# Action Plan: Post-Hooks Investigation (Updated 2025-10-20)

**Based on**: Hooks NOT viable (org policy), AlwaysApply validated (96%), Modes not critical  
**Status**: READY TO EXECUTE  
**Estimated total effort**: ~4-6 hours (reduced from original 10-14 hours)

---

## Summary of Findings

**What Changed Since Original Plan**:

- ❌ **Hooks**: NOT viable (organization blocks experiment flag)
- ✅ **AlwaysApply**: 96% validated (up from 74% baseline)
- ✅ **Modes**: Current mode fully functional, not a blocker
- ⏸️ **Prompt templates**: Still unexplored alternative

**Decisions Now Clear**:

- D1: ✅ Accept 96% as excellent (was 80%)
- D2: ✅ Use AlwaysApply for TDD rules (hooks not available)
- D3: ✅ H2/H3 monitoring sufficient (preliminary data good)
- D4: ⏸️ Prompt templates optional (96% may be sufficient)
- D5: ✅ Apply alwaysApply to tdd-first-js, tdd-first-sh
- D6: ✅ Complete after: synthesis + summary + approved changes

---

## Phase 1: Immediate Actions (~2 hours)

### 1.1: Apply Recommended AlwaysApply Changes

**Files to edit**:

- `.cursor/rules/tdd-first-js.mdc`
- `.cursor/rules/tdd-first-sh.mdc`
- `.cursor/rules/git-slash-commands.mdc`

**Changes**:

```yaml
# tdd-first-js.mdc and tdd-first-sh.mdc:
alwaysApply: false  →  alwaysApply: true
lastReviewed: 2025-10-20

# git-slash-commands.mdc:
alwaysApply: true  →  alwaysApply: false
lastReviewed: 2025-10-20
reason: Experiment failed (runtime routing wrong)
```

**Validation**:

```bash
bash .cursor/scripts/rules-validate.sh
```

**Expected outcome**:

- TDD rules now load in every context
- Git slash commands no longer load unnecessarily
- Net context change: +2k tokens (~3% increase)

---

### 1.2: Improve Intent Routing for Medium-Risk Rules (~1 hour)

**Rules to improve**:

**`project-lifecycle.mdc`**:

- Add triggers: "complete project", "archive project", "mark complete", "project done", "close project"
- Strengthen completion checklist visibility
- Add explicit "Complete (Active)" state definition

**`spec-driven.mdc`**:

- Add triggers: "should we plan", "need a plan", "design first", "what's the approach"
- Emphasize planning before implementation

**`guidance-first.mdc`**:

- Add triggers: "should we", "would you recommend", "what do you think about", "is it worth"
- Clarify guidance vs implementation signals

**Validation**:

- Test trigger phrases in chat
- Verify rules attach when expected

---

## Phase 2: Validation (1-2 Weeks Passive)

### 2.1: TDD Rules AlwaysApply Validation

**Objective**: Measure improvement from D5 decision

**Baseline**: 83% TDD compliance (17% non-compliance)

**What to accumulate**:

- 20-30 implementation commits
- Track: spec file changes per implementation change

**Measurement** (after accumulation):

```bash
bash .cursor/scripts/check-tdd-compliance.sh --limit 30
```

**Expected outcome**: 83% → 90%+ improvement

**Analysis**:

- Compare pre/post alwaysApply metrics
- Document improvement magnitude
- If <90%: investigate remaining gaps (likely test-quality issues)

---

## Phase 3: Synthesis & Documentation (~2-3 Hours)

### 3.1: Complete Synthesis Document

**File**: `synthesis.md`

**Sections to complete**:

1. ✅ H1/H2/H3 results analysis (done in synthesis.md)
2. ✅ Scalability analysis (done)
3. ✅ Enforcement pattern catalog (done)
4. ✅ Conditional rules categorization (done)
5. ✅ Hooks investigation complete (org policy blocker)
6. ⏸️ **Final recommendations** (incorporate hooks findings)
7. ⏸️ **Decision tree guidance** (based on validated patterns only)

**What to add**:

- Hooks conclusive findings and impact
- Updated enforcement pattern catalog (no hooks option)
- TDD alwaysApply validation results (after Phase 2)
- Final decision tree for all 25 conditional rules

---

### 3.2: Final Summary Document (~2 Hours)

**File**: `FINAL-SUMMARY.md` (to create)

**Required sections**:

1. **Executive Summary** (1 page)

   - Problem statement
   - Key findings (including hooks)
   - Recommendations (AlwaysApply + routing + external)
   - Impact (96% validated, scalable patterns identified)

2. **What Worked**

   - AlwaysApply effectiveness (74% → 96% validated)
   - Visible gates (100% visibility achieved)
   - Visible queries (implementation complete)
   - External validation (CI/pre-commit 100%)

3. **What Didn't Work**

   - Runtime routing slash commands (platform design mismatch)
   - Hooks (organization policy blocks experiment flag)

4. **Recommendations by Rule Type**

   - Critical rules (5): AlwaysApply (assistant-git-usage validated)
   - High-risk rules (4): AlwaysApply (TDD rules recommended)
   - Medium-risk rules (7): Improved routing (guidance-first, project-lifecycle)
   - Low-risk rules (13): Current state sufficient

5. **Reusable Patterns**

   - For other Cursor rules repositories
   - For similar AI assistant constraint problems
   - Meta-lessons from investigation itself (testing paradox validated 3x)

6. **Future Work** (optional)
   - Prompt templates exploration (if 96% proves insufficient)
   - Hooks (when org policy changes or feature graduates from experimental)
   - Mode-specific guidance (when modes become accessible)

---

## Phase 4: Completion Checklist (Per D6)

Investigation complete when ALL of the following are done:

- [x] **Hooks investigated** (conclusive: not viable due to org policy)
- [x] **Modes investigated** (current mode functional, not a blocker)
- [x] **AlwaysApply review complete** (all 44 rules analyzed, recommendations made)
- [ ] **Approved changes applied** (tdd-first-js/sh → true, git-slash-commands → false)
- [ ] **TDD rules validation** (20-30 commits measured after changes applied)
- [ ] **Synthesis written** (recommendations finalized, decision tree complete)
- [ ] **Final summary complete** (executive summary + reusable patterns documented)
- [ ] **All artifacts validated** (rules-validate.sh passing, no broken links)

---

## Timeline Estimates (Updated)

**Immediate (can start now)**:

- Phase 1.1: Apply alwaysApply changes → 30 minutes
- Phase 1.2: Improve routing → 1 hour
- **Subtotal**: ~1.5 hours

**Passive accumulation (1-2 weeks)**:

- Phase 2.1: TDD validation → passive during normal work
- **Subtotal**: 0 active hours, wait for 20-30 commits

**Analysis & documentation (after validation)**:

- Phase 3.1: Complete synthesis → 2 hours
- Phase 3.2: Final summary → 2 hours
- **Subtotal**: ~4 hours

**Total effort**: ~5.5 hours active + 1-2 weeks passive validation

---

## What We Learned From Hooks Investigation

### Testing Paradox Validated (3rd time)

**Slash commands**: Quick test revealed platform design mismatch  
**Hooks initial**: 5 restarts, found experiment flag message  
**Hooks complete**: Discovered org policy restriction

**Result**: 1 hour of real testing >> days of building around unavailable features

### Documentation vs Reality

**Documented**: Hooks exist, are beta, enable automated enforcement  
**Reality**: Hooks require experiment flag, blocked by org policy  
**Lesson**: Verify feature availability before deep investment

### Scalability Insights

**Original hope**: Hooks would solve context cost (no tokens, unlimited rules)  
**Reality**: AlwaysApply at 96% is excellent; context cost manageable for critical rules  
**Pattern**: Focus on highest-risk rules, use external validation where possible

---

## Next Immediate Steps

1. ✅ Hooks findings documented (DONE)
2. ✅ AlwaysApply review complete (DONE)
3. ✅ Modes investigation complete (DONE)
4. ✅ Action plan updated (DONE - this document)
5. ⏸️ **User approval**: Apply Phase 1 changes?
6. ⏸️ Execute Phase 1 (apply changes, improve routing)
7. ⏸️ Begin Phase 2 passive monitoring (TDD validation)
8. ⏸️ Complete Phase 3 after validation
9. ⏸️ Final review before declaring complete

---

**Status**: Action plan updated with hooks/modes findings  
**Ready to execute**: Phase 1 (immediate changes)  
**Awaiting**: User approval to proceed

**Changes from original plan**:

- Removed hooks exploration (not viable)
- Removed prompt templates as required (96% sufficient, optional future work)
- Reduced effort estimate (10-14 hours → 5.5 hours active)
- Clearer completion criteria (hooks/modes resolved)
