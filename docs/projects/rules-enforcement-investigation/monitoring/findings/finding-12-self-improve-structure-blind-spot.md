---
findingId: 12
date: "2025-10-24"  # Inferred from migration
project: "rules-enforcement-investigation"
severity: "medium"  # Default for migrated findings
status: "open"      # Default for migrated findings
reviewed: false
reviewedBy: null
reviewedDate: null
sourceLogs: []      # To be filled post-migration
---

# Gap #12: Self-Improve Didn't Catch Structure Violation

**Discovered**: 2025-10-21  
**Context**: Investigation completion (synthesis phase)  
**Severity**: Medium (pattern detection gap)

---

## What Happened

**Violation**: Created `synthesis.md` in project root without checking investigation-structure pre-file-creation checklist

**Expected Behavior** (per `investigation-structure.mdc`):

1. Before creating file, determine category
2. Analysis document? → `analysis/<topic>.md`
3. Check root file count (threshold: ≤7)

**Actual Behavior**:

- Created `synthesis.md` in root
- Root file count: 8 (exceeded threshold by 1)
- Did not consult pre-file-creation checklist
- `self-improve.mdc` did not flag the violation

**User Observation**: "I would have thought that your self improvement rule should have been triggered by this."

---

## Why This Matters

**Self-Referential Validation Failure**:

- Investigation created `investigation-structure.mdc` (Gap #11)
- Immediately violated the rule while completing the investigation
- Self-improve pattern detection missed the violation
- User had to point it out

**Pattern**: This is the **third** structure violation during this investigation:

1. Gap #11: Created 40 files without structure (led to investigation-structure rule)
2. Today: Created 3 root files without checking structure rule
3. User caught both violations

---

## Root Cause Analysis

### Why Self-Improve Didn't Trigger

**Missing trigger in `self-improve.mdc`**:

- No explicit "before file creation" checkpoint for investigation projects
- Pattern detection happens at "natural checkpoints" (after tasks complete)
- Structure violations are **preventable** (should check BEFORE creating), not just observable (after creating)

**Current self-improve triggers** (from rule):

- At task completion
- After PR created
- After tests passing
- When user asks "anything else?"

**Missing trigger**:

- **Before file creation in investigation projects**

### Why Investigation-Structure Rule Insufficient

**Rule has checklist but no enforcement**:

- Pre-file-creation checklist exists
- But no forcing function to use it
- Advisory guidance only

**Compare to other rules**:

- `assistant-git-usage.mdc`: `alwaysApply: true` → 100% compliance
- `investigation-structure.mdc`: Conditional, no explicit OUTPUT requirement → violated

---

## Evidence

**Files created in root** (should be elsewhere):

1. `synthesis.md` → Should be `analysis/synthesis.md`
2. `action-plan.md` → Should be `analysis/action-plan.md`
3. `decision-points.md` → Should be `decisions/decision-points.md`

**Root file count**: 8 → Exceeded ≤7 threshold

**Self-improve missed**:

- No proactive "about to create file, checked structure?" prompt
- No post-creation "did this follow structure?" validation
- User caught violation before self-improve did

---

## Impact

**Investigation Quality**: Medium

- Files in wrong locations but easily moved
- Navigation slightly harder with 8 root files vs 5

**Pattern Detection**: High

- Self-improve rule has blind spot for preventable violations
- Investigation-structure rule lacks forcing function
- Validates findings about "rules about rules are hard"

**Meta-Lesson**: High value

- Real-world validation of enforcement pattern findings
- Shows even with high awareness, violations occur without forcing functions
- Demonstrates need for explicit OUTPUT requirements (H2 finding applies here too)

---

## Proposed Improvements

### 1. Add Pre-Creation Checkpoint to Self-Improve

**Location**: `.cursor/rules/self-improve.mdc`

**Add section**:

```markdown
## Pre-File-Creation Checkpoint (Investigation Projects)

**Trigger**: Before creating any file in `docs/projects/<investigation>/`

**Checklist**:

1. Consult investigation-structure rule pre-file-creation checklist
2. Determine file category (analysis/findings/sessions/decisions/protocols/guides)
3. Check root file count (threshold: ≤7)
4. Create in correct location

**Forcing Function**: OUTPUT the category determination before creating file

- Format: "Creating [filename]: Category = [analysis|findings|etc], Location = [path]"
- Rationale: [one sentence why this location]
```

### 2. Add Visible Output to Investigation-Structure Rule

**Location**: `.cursor/rules/investigation-structure.mdc`

**Modify pre-file-creation checklist**:

```markdown
## Pre-File-Creation Checklist (MUST OUTPUT)

**Before creating any file in an investigation project**, OUTPUT:

- File to create: [name]
- Category: [analysis|findings|sessions|decisions|protocols|guides|root]
- Destination: [full path]
- Root file count after: [number] (threshold: ≤7)

Then create file at determined location.
```

**Pattern**: Same as H2 (visible gate) — explicit OUTPUT requirement creates accountability

### 3. Apply AlwaysApply (If Investigation Active)

**Consideration**: If actively working on investigation project, make `investigation-structure.mdc` alwaysApply temporarily

**Trade-off**:

- Pro: 100% compliance (per H1 findings)
- Con: Not all projects are investigations (context cost for non-investigation work)

**Alternative**: Keep conditional but add visible output requirement (per H2 pattern)

---

## Lessons Learned

### Pattern Validated Again

**From synthesis.md**: "Explicit OUTPUT requirements > Advisory verification"

This gap validates the H2 finding:

- Investigation-structure (advisory): Violated immediately
- Git-usage with alwaysApply + visible gates: 100% compliance

### Self-Improve Scope

**Current**: Reactive pattern detection (after violations)  
**Needed**: Proactive prevention (before violations)

**Analogy**:

- Current: Observes you forgot to check blind spot, proposes improvement
- Needed: Prompts "check blind spot" before changing lanes

### Rules About Rules Really Are Hard

**Evidence count** (violations during investigation):

- Gap #7: Documentation-before-execution
- Gap #9: Changeset policy (twice)
- Gap #11: Structure violation (40 files)
- **Gap #12**: Structure violation again (synthesis.md in root)

**Pattern**: Even maximum rule awareness doesn't prevent violations without forcing functions

---

## Immediate Actions

1. ✅ Reorganize files to correct locations

   - `synthesis.md` → `analysis/synthesis.md`
   - `action-plan.md` → `analysis/action-plan.md`
   - `decision-points.md` → `decisions/decision-points.md`

2. ✅ Document this gap (Gap #12)

3. ⏸️ Propose rule improvements to user

   - Self-improve.mdc: Add pre-creation checkpoint
   - Investigation-structure.mdc: Add visible OUTPUT requirement

4. ⏸️ Add to synthesis meta-lessons
   - Gap #12 validates H2 findings about explicit OUTPUT requirements

---

## Related Gaps

- **Gap #11**: Investigation structure not defined (led to investigation-structure.mdc)
- **Gap #7**: Documentation-before-execution not automatic
- **Gap #9**: Changeset policy violated (pattern validation)
- **H2 Finding**: Visible OUTPUT creates accountability (0% → 100%)

---

**Status**: DOCUMENTED  
**Priority**: Medium (fix immediate issue, consider rule improvements)  
**Meta-Finding**: Validates enforcement pattern findings (explicit OUTPUT > advisory)
