# Routing Optimization — Phase 3 Real-World Findings

**Date Started**: 2025-10-23  
**Purpose**: Document real-world routing behavior during Phase 3 monitoring  
**Status**: Active monitoring

---

## Finding #1: Changeset Intent Partially Honored

**Date**: 2025-10-23  
**Context**: PR creation for routing-optimization project  
**Severity**: Medium (intent contradiction)

### Issue

User explicitly requested: "Please create a branch, commit the changes, and create a pr **with changeset**"

**Expected Behavior**:
- ✅ Create changeset file
- ✅ Include changeset in commit
- ✅ Create PR
- ✅ Ensure NO `skip-changeset` label on PR

**Actual Behavior**:
- ✅ Created changeset file: `.changeset/routing-optimization-phase-2.md`
- ✅ Included in commit (b07851b)
- ✅ Created PR #159
- ❌ PR has `skip-changeset` label applied

**Result**: Partial success - changeset exists but contradictory label present

---

### Root Cause Analysis

**What Went Wrong**:

1. **Intent Routing Success**: Correctly identified user wanted changeset ✅
2. **Changeset Creation Success**: Created `.changeset/routing-optimization-phase-2.md` ✅
3. **PR Creation Success**: Used `pr-create.sh` script correctly (no `--label` flag passed) ✅
4. **GitHub Action Auto-Labeling Contradiction**: 
   - Workflow: `.github/workflows/changeset-autolabel-docs.yml`
   - Logic: "If all files match doc patterns → apply skip-changeset"
   - PR #159 files: `.cursor/rules/*.mdc`, `docs/`, `.changeset/*.md`
   - All match doc patterns → workflow applied skip-changeset ❌
   - **Gap**: Workflow doesn't check if changeset already exists

**Root Cause (Confirmed)**:
- GitHub Action automatically labels docs-only PRs with `skip-changeset`
- Workflow logic: `isDocsOnly` → add skip-changeset label
- Does NOT check: presence of `.changeset/*.md` files
- Does NOT check: user explicit intent
- Result: Auto-labels even when changeset present + user requested

**Evidence**:
- Script: `.github/workflows/changeset-autolabel-docs.yml` lines 34-70
- Doc patterns: `^docs/`, `README.md`, `.mdc?$`
- PR #159: All files match doc patterns
- Action ran on PR open → applied label automatically

**Composite Action Gap**: 
- User request was composite: "pr WITH changeset" (not "pr AND skip-changeset")
- I handled changeset creation (explicit instruction) ✅
- I didn't prevent GitHub Action auto-labeling (contradicts explicit instruction) ❌
- **Should have**: Detected docs-only PR + changeset intent → prevent auto-label OR remove after

**Decision Policy Issue**:
- Explicit user instruction: "with changeset"
- Should override automated workflow defaults
- Similar to intent override tier: explicit intent > default behavior
- **New pattern needed**: Explicit intent should prevent contradictory automation

---

### Impact Assessment

**User Impact**:
- Medium: Changeset exists but label causes confusion
- PR may be processed incorrectly by CI/automation
- User had to correct the behavior

**Routing Validation**:
- Good: This validates importance of intent override optimizations
- Gap: Composite actions need holistic fulfillment (not just parts)
- Lesson: "with X" means "X included AND nothing contradicting X"

---

### Proposed Solutions

#### Short-Term Fix (Immediate)

- [ ] Remove `skip-changeset` label from PR #159
- [ ] Verify changeset file is properly included

#### Medium-Term (Workflow Improvement)

**Fix GitHub Action** (`.github/workflows/changeset-autolabel-docs.yml`):

- [ ] Add changeset detection before applying skip-changeset:
  ```javascript
  // Check if PR includes changeset files
  const hasChangeset = files.some(f => /^\.changeset\/.*\.md$/.test(f.filename));
  
  const isDocsOnly = files.length > 0 && files.every(f => {
    // existing logic...
  });
  
  // Only apply skip-changeset if docs-only AND no changeset
  if (isDocsOnly && !hasChangeset) {
    // apply label
  } else if (!isDocsOnly || hasChangeset) {
    // remove label if present
  }
  ```

- [ ] Update workflow logic:
  - If docs-only + changeset present → do NOT apply skip-changeset
  - If docs-only + no changeset → apply skip-changeset (current behavior)
  - If changeset present (any files) → remove skip-changeset if accidentally applied

**Update Assistant Behavior** (`.cursor/rules/assistant-git-usage.mdc`):

- [ ] Add explicit guidance for PR creation with changeset:
  - Document: "with changeset" means NO skip-changeset label
  - Add verification step after PR creation: check label state
  - If skip-changeset present + changeset requested → remove label immediately

- [ ] Add composite intent examples:
  - "create PR with changeset" → changeset + ensure no skip-changeset label
  - Clarify: explicit intent overrides automatic workflows

**Enhance PR Creation Script** (`pr-create.sh` or decomposed utilities):

- [ ] Add `--with-changeset` flag (explicit user intent):
  - Detect changeset files in HEAD commit
  - If found: ensure no skip-changeset label (wait for Action, then remove if applied)
  - If not found: warn user

- [ ] Add `--no-skip-changeset` flag (explicit label prevention):
  - Remove skip-changeset label after PR creation if present

#### Long-Term (Intent Routing Enhancement)

- [ ] Add to routing-optimization findings:
  - Composite action handling (not just single intents)
  - Action fulfillment verification (did ALL parts complete correctly?)
  - Contradiction detection ("with X" + "skip-X" = contradiction)

- [ ] Consider routing pattern:
  ```markdown
  - Composite actions with explicit modifiers
    - Pattern: "action WITH requirement"
    - Behavior: Ensure requirement met AND no contradictions
    - Example: "create PR with changeset" → changeset included, no skip-changeset label
    - Validation: Check both positive (has X) and negative (no anti-X)
  ```

---

### Related Work

**Projects**:
- `routing-optimization` — This is a Phase 3 validation finding
- Potentially: `assistant-git-usage` or `git-usage-suite` — PR workflow improvements

**Rules**:
- `.cursor/rules/intent-routing.mdc` — May need composite action guidance
- `.cursor/rules/assistant-git-usage.mdc` — PR creation and changeset policy

**Scripts**:
- `.cursor/scripts/pr-create.sh` — Investigate label behavior
- `.cursor/scripts/pr-update.sh` — May need label management capability

---

### Validation Metrics Impact

**Phase 3 Monitoring**:
- Real-world routing accuracy: 1 partial failure detected
- False positives: 0 (correct rules attached)
- False negatives: 0 (changeset created)
- **Composite action gap**: 1 (changeset created but contradictory label)

**Action Item**: Continue monitoring, document additional findings

---

## Template for Future Findings

```markdown
## Finding #N: [Title]

**Date**: YYYY-MM-DD
**Context**: [What was happening]
**Severity**: Low/Medium/High

### Issue
[User request vs actual behavior]

### Root Cause
[What went wrong and why]

### Impact
[Effect on user, validation, metrics]

### Proposed Solutions
- [ ] Short-term fix
- [ ] Medium-term improvement
- [ ] Long-term enhancement

### Related Work
[Projects, rules, scripts]
```

---

## Finding #2: Reactive Documentation (Meta-Gap)

**Date**: 2025-10-23  
**Context**: After Finding #1 discovered  
**Severity**: Medium (investigation methodology gap)

### Issue

When I discovered the changeset intent contradiction (Finding #1), I proposed to fix it immediately: "Fix the PR now? I can remove the `skip-changeset` label immediately. Proceed?"

**User had to correct me**: "First we need to document this issue in the relevant projects and create task(s) to address it"

**Expected Behavior** (for investigation/optimization projects):
- ✅ Recognize issue as investigation finding
- ✅ Proactively suggest documenting it
- ✅ Propose creating tasks across relevant projects
- ✅ THEN offer to fix

**Actual Behavior**:
- ✅ Recognized the issue
- ❌ Offered immediate fix first (reactive)
- ❌ Waited for user to direct documentation (should be proactive)
- ✅ Documented thoroughly once directed

**Result**: User had to redirect from fix-first to document-first approach

---

### Root Cause Analysis

**Why Did I Jump to Fix Instead of Document?**

**Hypothesis 1: Context-specific behavior not triggered**
- Working on routing-optimization project (active investigation)
- Phase 3 = monitoring and documenting findings
- Should have triggered: "This is investigation data, document it"
- Actual: Treated as normal bug fix, offered immediate solution

**Hypothesis 2: Investigation methodology not internalized**
- Similar to Gap #7 from rules-enforcement-investigation: "documentation-before-execution pattern not automatic"
- Pattern exists: document → then execute
- Not consistently applied when discovering issues during investigation work

**Hypothesis 3: Project-specific behavior not clear**
- No explicit guidance: "For routing-optimization and similar investigation projects, proactively suggest documenting findings"
- Treated finding like normal bug rather than investigation evidence
- Missing: project-type-specific behavior (investigation vs feature development)

**Hypothesis 4: Self-improvement rule violated (CONFIRMED)**
- **Critical finding**: self-improve.mdc (alwaysApply: true) has explicit investigation guidance
- Section: "Special Case: Rule Investigations" (lines 181-254)
- **Explicit requirement**: "Observed rule gaps are first-class investigation data (not optional enhancements)"
- **Explicit behavior**: "Don't wait for user prompts" - "Bad: Wait for user to ask 'did you notice X?'" - "Good: Flag gaps as they're observed during work"
- **What I did**: Waited for user prompt (violated explicit "Don't wait" requirement)
- **Severity**: This is an alwaysApply rule violation (rule WAS in context, I ignored it)

---

### Impact Assessment

**User Impact**:
- Low: User caught it immediately and redirected
- Required one correction to shift from fix-first to document-first

**Investigation Quality**:
- Medium: Documentation happened but not proactively
- Risk: Could miss documenting less obvious issues if user doesn't catch them
- Pattern: Same as rules-enforcement-investigation meta-findings

**Self-Improvement**:
- **HIGH - CRITICAL**: This is an alwaysApply rule violation
- self-improve.mdc was in context (alwaysApply: true)
- Explicit guidance: "Don't wait for user prompts"
- I violated it anyway: waited for user to direct documentation
- This meta-gap reveals behavior pattern that affects all investigation work
- **Validates routing-optimization Finding #1**: Even alwaysApply rules can be violated

**Routing Validation Insight**:
- This IS a routing failure, just not in the traditional sense
- Rule was attached (alwaysApply) ✅
- Intent was clear (investigation context) ✅
- Behavior was specified (proactive documentation) ✅
- **Execution failed**: Ignored the rule despite all correct inputs ❌
- Validates: AlwaysApply necessary but not sufficient (same as changeset label issue)

---

### Proposed Solutions

#### Immediate Documentation (This Session)

- [x] Document Finding #2 (this document)
- [ ] Create tasks to analyze root cause
- [ ] Cross-reference to rules-enforcement-investigation Gap #7

#### Analysis Tasks (CRITICAL - AlwaysApply Rule Violated)

- [ ] **Confirm alwaysApply violation** (Priority: High):
  - ✅ Verify self-improve.mdc has alwaysApply: true (confirmed: line 3)
  - ✅ Verify explicit investigation guidance exists (confirmed: lines 181-254)
  - ✅ Verify "Don't wait for user prompts" requirement (confirmed: line 197)
  - ✅ Verify I violated it (confirmed: offered fix-first, user had to redirect)
  - **Conclusion**: This is Type 1 failure (rule loaded, still violated)

- [ ] **Analyze why alwaysApply rule ignored**:
  - Rule was in context (alwaysApply: true) ✅
  - Guidance was explicit ("Don't wait for user prompts") ✅
  - Context was clear (investigation project, monitoring phase) ✅
  - **Question**: Why did execution fail despite all correct inputs?
  - Compare to rules-enforcement-investigation baseline: 68% compliance despite rules loaded
  - **Hypothesis**: Same execution gap that motivated routing-optimization project

- [ ] **Compare to rules-enforcement-investigation meta-findings**:
  - Gap #7: Documentation-before-execution not automatic (same pattern)
  - Gap #11: Structure violation during investigation (alwaysApply violated)
  - Gap #12: Self-improve didn't catch structure violation
  - Gap #15: Changeset policy violated 3 times (even with visible gates)
  - **Pattern**: Even alwaysApply + explicit guidance can be violated

- [ ] **Identify execution vs routing gap**:
  - Routing: Which rules to attach? ✅ WORKED (self-improve.mdc attached)
  - Execution: Follow the attached rules? ❌ FAILED (ignored "don't wait" requirement)
  - **Critical insight**: This is NOT a routing problem (optimization won't help)
  - This is an execution/compliance problem (different category of issue)

#### Enforcement Analysis (Not Rule Content)

**Critical Insight**: Guidance already exists in self-improve.mdc (alwaysApply: true)

**Current guidance is CLEAR**:
- ✅ Lines 181-254: "Special Case: Rule Investigations"
- ✅ Line 187: "Observed rule gaps are first-class investigation data"
- ✅ Line 197: "Don't wait for user prompts"
- ✅ Lines 224-238: Example showing incorrect (wait for user) vs correct (flag immediately) behavior

**Problem is EXECUTION, not content**:
- Rule content: Excellent ✅
- Rule routing: Working (alwaysApply attached it) ✅
- Rule execution: Failed (ignored "don't wait") ❌

**Analysis Focus**:

- [ ] Determine why execution failed:
  - Is this the 68% baseline problem? (Rules attached, sometimes ignored anyway)
  - What enforcement pattern could prevent this? (AlwaysApply didn't work)
  - Is visible gate needed? ("OUTPUT: Checked for investigation context")
  - Is blocking gate needed? (FAIL if finding not documented before fix)

- [ ] Explore enforcement beyond AlwaysApply:
  - AlwaysApply successful for: Simple actions (use script X)
  - AlwaysApply violated for: Complex behaviors (investigate methodology)
  - **Hypothesis**: Single-action rules easier to enforce than multi-step patterns
  - **Question**: Does complexity correlate with violation rate?

- [ ] Consider blocking gates for investigation findings:
  - Pattern: Observed failure during investigation → MUST document before proceeding
  - Implementation: "Document as Finding #N? [Yes required to proceed]"
  - Similar to TDD pre-edit gate (MUST have spec before implementing)
  - Block execution path until documentation complete

- [ ] Evaluate if this finding affects routing-optimization goals:
  - **Original goal**: Improve routing accuracy (which rules attach)
  - **This finding**: Execution accuracy (following attached rules)
  - **Implication**: Routing optimization addresses one problem; execution compliance is separate
  - **Scope consideration**: Should routing-optimization expand to cover execution, or separate project?

---

### Related Patterns

**From rules-enforcement-investigation**:

- **Gap #7**: Documentation-before-execution not automatic
  - Same pattern: Fix offered before documentation
  - User correction: "should document that first"
  - Resolution: Added process-order trigger to self-improve.mdc

- **Gap #11**: Structure violation during investigation about structure
  - Same pattern: Investigation work doesn't automatically follow investigation methodology
  - Meta-observation valuable evidence

- **Investigation Meta-Lessons** (from synthesis.md):
  - "Apply findings to your own process during investigation"
  - "Meta-consistency matters"
  - "Gaps discovered during work are investigation evidence"

**This Is Finding #2 Happening in Real-Time**:
- Investigation about routing optimization
- Discovers routing failure (Finding #1)
- Doesn't proactively suggest documenting it
- User catches it: "First we need to document this"
- Then documents the failure to document (Finding #2)

**The Value**: Perfect meta-example of investigation methodology gap

---

### Success Criteria

**Proactive documentation behavior successful when**:

1. Future routing failures trigger immediate suggestion:
   - "I observed a routing failure. Should I document this as Finding #N in phase3-findings.md before addressing it?"

2. Investigation context recognized:
   - Working on routing-optimization project
   - Phase 3 = monitoring
   - Observed issue = finding (not just bug)

3. Document-before-fix becomes default:
   - For investigation projects specifically
   - User doesn't need to redirect
   - Findings captured proactively

4. Self-improve triggers correctly:
   - "Noticed gap during investigation work → flag as meta-finding"
   - "Investigation violating own patterns → document as evidence"

---

### Related Work

**Projects**:
- `routing-optimization` — This finding
- `rules-enforcement-investigation` — Similar meta-findings (Gaps #7, #11, #12)
- `assistant-self-improvement` — Pattern detection and proactive improvement

**Rules**:
- `.cursor/rules/self-improve.mdc` — Pattern observation and improvement proposals
- `.cursor/rules/investigation-structure.mdc` — Investigation organization
- Potentially: `.cursor/rules/investigation-methodology.mdc` (to create)

---

**Status**: Finding #2 documented, analysis tasks created  
**Severity**: Medium (affects investigation quality)  
**Pattern**: Reactive vs proactive documentation during investigation work  
**Next**: Analyze root cause and update self-improve.mdc

