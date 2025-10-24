# Routing Optimization — Phase 3 Real-World Findings

**Date Started**: 2025-10-23  
**Purpose**: Document real-world routing behavior during Phase 3 monitoring  
**Status**: Active monitoring

---

## Finding #1: Changeset Intent Partially Honored [RESOLVED]

**Date**: 2025-10-23  
**Context**: PR creation for routing-optimization project  
**Severity**: Medium (intent contradiction)  
**Status**: ✅ RESOLVED (2025-10-23)

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
- ❌ PR has `skip-changeset` label applied (initial)
- ✅ Label removed after identification (resolved)

**Result**: Initial partial success, fully resolved after root cause analysis

### Resolution

**Actions Taken**:
- ✅ Removed `skip-changeset` label from PR #159
- ✅ Verified changeset file present in PR
- ✅ Identified root cause: GitHub Action `.github/workflows/changeset-autolabel-docs.yml`
- ✅ Documented issue in phase3-findings.md
- ✅ Created tasks in github-workflows-utility and pr-create-decomposition for permanent fix

**Status**: PR #159 now correct (changeset present, no contradictory label)

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

#### Short-Term Fix (Immediate) ✅ COMPLETE

- [x] Remove `skip-changeset` label from PR #159 ✅
- [x] Verify changeset file is properly included ✅
  - Verified: `.changeset/routing-optimization-phase-2.md` present in PR
  - Verified: No labels on PR (skip-changeset successfully removed)

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

## Finding #2: Moved to rules-enforcement-investigation

**Date**: 2025-10-23  
**Category**: Execution compliance (not routing)  
**Severity**: High (alwaysApply rule violation)

**Issue**: Reactive documentation - offered fix-first instead of proactively suggesting document-first

**Root Cause**: AlwaysApply rule violation (self-improve.mdc was loaded, explicit "Don't wait for user prompts" requirement ignored)

**Why Moved**: This is an **execution failure** (right rules attached but ignored), not a **routing failure** (wrong rules attached). Belongs in rules-enforcement-investigation which monitors rule execution/compliance.

**See**: [`rules-enforcement-investigation/findings/gap-17-reactive-documentation-proactive-failure.md`](../../../rules-enforcement-investigation/findings/gap-17-reactive-documentation-proactive-failure.md)

**Cross-Reference Context**: 
- Discovered during routing-optimization Phase 3 monitoring
- Validates that execution compliance is separate problem from routing accuracy
- Demonstrates: AlwaysApply necessary but not sufficient for complex multi-step behaviors

---

**Content moved to**: [`rules-enforcement-investigation/findings/gap-17-reactive-documentation-proactive-failure.md`](../../../rules-enforcement-investigation/findings/gap-17-reactive-documentation-proactive-failure.md)

**Why moved**: This is an execution compliance issue (alwaysApply rule violated), not a routing issue (wrong rules attached). Execution compliance is monitored by rules-enforcement-investigation.

**Related to routing-optimization**: Validates that routing and execution are separate problem categories. Routing optimizations improved intent recognition; execution compliance requires different enforcement mechanisms (blocking gates, not just alwaysApply).

**Cross-reference maintained**: Finding discovered during routing-optimization Phase 3 monitoring, documented in appropriate project.

