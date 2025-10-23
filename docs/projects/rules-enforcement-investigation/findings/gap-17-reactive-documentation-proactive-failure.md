# Gap #17: Reactive Documentation — Proactive Behavior Failure

**Discovered**: 2025-10-23  
**Context**: routing-optimization Phase 3 monitoring  
**Severity**: High (alwaysApply rule violation + investigation methodology)

---

## Issue

During routing-optimization Phase 3 monitoring, when I discovered a routing failure (changeset intent contradiction), I offered to fix it immediately instead of proactively suggesting documentation first.

**User had to correct me**: "First we need to document this issue in the relevant projects and create task(s) to address it"

**Expected Behavior** (per self-improve.mdc lines 181-254):
- ✅ Recognize issue as investigation finding
- ✅ Proactively flag: "Should I document this as Finding #N before addressing it?"
- ✅ Document in appropriate findings file
- ✅ Create tasks across relevant projects
- ✅ THEN offer to fix

**Actual Behavior**:
- ✅ Recognized the routing failure
- ❌ Offered immediate fix first: "Fix the PR now? I can remove the skip-changeset label"
- ❌ Waited for user to direct documentation (violated "Don't wait for user prompts")
- ✅ Documented thoroughly once directed

---

## Root Cause: AlwaysApply Rule Violation (CONFIRMED)

**This is Type 1 Failure**: Rule exists, is loaded, but violated anyway

### Evidence

**Rule Status**:
- Rule: `self-improve.mdc`
- `alwaysApply: true` (line 3) — Rule WAS in context
- Section: "Special Case: Rule Investigations" (lines 181-254)

**Explicit Requirements Violated**:
- Line 187: "Observed rule gaps are first-class investigation data (not optional enhancements)"
- **Line 197**: "Don't wait for user prompts"
- Lines 195-200:
  ```
  2. **Don't wait for user prompts**
     - Bad: Wait for user to ask "did you notice X?"
     - Good: Flag gaps as they're observed during work
     - Proactive documentation, not reactive
  ```

**What I Did**:
- ❌ Waited for user to say "First we need to document this"
- ❌ Offered fix-first instead of document-first
- ❌ Exactly the "Bad" behavior shown in the example

**Severity**: This is an alwaysApply rule violation during investigation about rule violations

---

## Critical Insight: Execution Gap, Not Routing Gap

### Distinction

**Routing** (which rules attach):
- ✅ WORKING: self-improve.mdc was attached (alwaysApply: true)
- ✅ Intent was recognized correctly
- ✅ Appropriate rules in context

**Execution** (following attached rules):
- ❌ FAILING: Ignored explicit "Don't wait for user prompts" requirement
- ❌ Violated guidance despite it being loaded
- ❌ This is the same 68% baseline problem

**Implication**: 
- Routing optimizations won't fix this (routing already worked)
- This is an execution/compliance problem (different category)
- Same issue that motivated rules-enforcement-investigation originally

---

## Pattern Validation

### Same Pattern as Previous Gaps

**Gap #7** (documentation-before-execution):
- Pattern: Fix offered before documentation
- User correction: "should document that first"

**Gap #11** (structure violation):
- Pattern: Investigation about rules violated structure rules
- User correction: "you didn't follow the structure"

**Gap #12** (self-improve didn't catch gap #11):
- Pattern: Self-improve should have flagged structure violation
- Didn't happen proactively

**Gap #17** (this gap):
- Pattern: Investigation about routing violated investigation methodology
- User correction: "First we need to document this"

**All share**: Explicit guidance exists, alwaysApply or visible, still violated

---

## Complexity Hypothesis

### Simple vs Complex Rules

**Simple rules (100% compliance)**:
- "Use git-commit.sh for commits" (single action)
- "Use pr-create.sh for PRs" (single action)
- "Add changeset file before PR" (single action)

**Complex behaviors (violated even with alwaysApply)**:
- "Document findings proactively during investigations" (multi-step: observe → recognize → document → then fix)
- "Follow investigation structure" (multi-file: categorize → check threshold → place correctly)
- "Ensure no contradictory labels when changeset requested" (multi-check: has changeset → check labels → prevent contradiction)

**Hypothesis**: Rule complexity correlates with violation rate
- Single-action rules: High enforcement success
- Multi-step behaviors: Lower enforcement success (even with alwaysApply)

**Question**: What enforcement pattern works for complex behaviors?

---

## Proposed Solutions

### Analysis (Not Rule Content)

**Current guidance is excellent** (self-improve.mdc lines 181-254):
- Clear examples
- Explicit "don't wait" requirement
- Investigation-specific section

**Problem is enforcement**, not content:

- [ ] Analyze execution gap:
  - Why does alwaysApply work for simple rules but fail for complex behaviors?
  - Is it complexity? Number of decision points? Cognitive load?
  - Measure: Count steps in violated vs non-violated rules

- [ ] Compare to baseline findings:
  - Rules-enforcement-investigation: 68% baseline with rules loaded
  - AlwaysApply: 100% for git-usage (simple) but violated for investigation methodology (complex)
  - Pattern: Enforcement effectiveness decreases with rule complexity

- [ ] Explore blocking gates for complex behaviors:
  - **Visible gates**: Create transparency (100% visibility achieved in H2)
  - **Blocking gates**: Prevent execution until requirement met
  - Example: "Observed investigation finding. Document in findings/gap-##.md before proceeding? [Required]"
  - Similar to: TDD pre-edit gate (blocks implementation until spec exists)

### Cross-Project Documentation

- [ ] Update rules-enforcement-investigation scope:
  - Add: Investigation methodology enforcement (self-improve.mdc execution)
  - Track: Proactive documentation compliance
  - Monitor: Investigation-specific behavior patterns

- [ ] Create monitoring clarity mechanism:
  - Help assistant distinguish project scopes
  - Make active monitoring visible and explicit
  - Prevent cross-project documentation confusion

---

## Impact on Related Projects

### routing-optimization

**What this means**:
- Routing optimizations working correctly (rule attached ✅)
- Finding #2 reveals execution gap (different problem)
- Should cross-reference to this gap, not own it

**Action**: Update routing-optimization to cross-reference Gap #17

### rules-enforcement-investigation

**What this means**:
- Gap #17 is natural continuation of Gaps #7, #11, #12, #15
- Validates: AlwaysApply + visible gates insufficient for complex behaviors
- Strengthens: Need for blocking gates (Gap #15 proposal)

**Action**: Add Gap #17 to findings index and Phase 6G carryover

---

## Success Criteria

**Proactive documentation successful when**:

1. Future investigation findings trigger immediate proactive suggestion
2. No user redirection needed from fix → document
3. Blocking gate enforces documentation before fix (if implemented)
4. Investigation context automatically triggers document-first behavior

**Measurement**:
- Track user corrections: "document first", "create tasks for this"
- Target: Zero corrections needed for investigation findings
- Current: 1 correction in first 2 real-world findings (50% failure rate)

---

## Related

**Gaps (Same Pattern)**:
- Gap #7: Documentation-before-execution not automatic
- Gap #11: Structure violation during investigation
- Gap #12: Self-improve didn't catch violations
- Gap #15: Changeset violations even with visible gates

**Rules**:
- `self-improve.mdc` (alwaysApply: true, lines 181-254) — Violated
- `investigation-structure.mdc` — Related investigation guidance

**Projects**:
- `routing-optimization` — Where gap discovered (cross-reference)
- `rules-enforcement-investigation` — Where gap belongs (execution compliance)

---

**Status**: Gap #17 documented in correct project  
**Next**: Update routing-optimization with cross-reference, create monitoring clarity mechanism

