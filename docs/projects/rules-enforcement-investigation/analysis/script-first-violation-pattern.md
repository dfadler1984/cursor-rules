# Script-First Violation Pattern Analysis

**Date**: 2025-10-24  
**Source**: Gaps #14, #15, #18 (3 documented violations)  
**Pattern**: Script bypassed during multi-step complex workflows

---

## Pattern Overview

**Observed**: Despite `assistant-git-usage.mdc` being `alwaysApply: true` with explicit "Script-First Default (must)" requirement, scripts were bypassed 3 times using direct API/command calls.

**Commonality**: All violations occurred during complex multi-step workflows (PR creation, label management, error handling).

---

## Documented Violations

### Gap #14: Script Bypass on Error (PR #155)

**Context**: Removing skip-changeset label from PR #155

**What happened**:

1. Ran `pr-labels.sh --pr 155 --remove skip-changeset`
2. Script executed successfully (label removed)
3. Script printed error message: `success: command not found`
4. **Bypassed script** with direct curl to "verify"
5. Used curl instead of trusting script or investigating error

**Violation**: Used `curl` instead of trusting `pr-labels.sh` result

**Complexity**: 3 actions (run script → observe error → verify vs trust)

**Status**: ✅ FIXED (pattern documented, script trusted in future operations)

---

### Gap #15: Script Bypass During PR Creation (PR #149)

**Context**: Removing skip-changeset label after creating changeset

**What happened**:

1. Created PR #149 (auto-added skip-changeset label)
2. Created changeset file
3. **Used curl to check/remove label** instead of pr-labels.sh
4. No capabilities.mdc check OUTPUT shown
5. Violated H3 (query visibility) simultaneously

**Violation**: Triple violation (H1 script-first + H3 query visibility + Gap #9 label management)

**Complexity**: 5+ actions (create PR → create changeset → remember label exists → check capabilities → use script → verify)

**Status**: ⚠️ ACTIVE CONCERN (happened during investigation about script usage)

---

### Gap #18: Script Bypass During Label Removal (PR #159)

**Context**: Removing skip-changeset label from PR #159

**What happened**:

1. User requested: "Proceed with the fix for not adding the skip-changeset label"
2. **Used curl directly** without checking capabilities.mdc
3. No OUTPUT: "Checked capabilities.mdc for label management: found pr-labels.sh"
4. Bypassed available script

**Violation**: Script-first + query visibility (H3) violated

**Complexity**: 4 actions (receive request → check capabilities → use script → verify)

**Status**: ⚠️ CRITICAL (alwaysApply rule + explicit OUTPUT requirement both violated)

---

## Pattern Analysis

### Violation Correlation with Workflow Complexity

**Hypothesis**: Script bypass rate increases with workflow complexity

**Evidence**:

| Workflow Complexity  | Actions | Script Bypasses | Context                                  |
| -------------------- | ------- | --------------- | ---------------------------------------- |
| Simple git operation | 1-2     | 0 / 30+         | Direct commits, branch creation          |
| Moderate PR creation | 2-3     | 0 / ~15         | Using pr-create.sh successfully          |
| Complex label mgmt   | 4-5     | 3 / 3           | All 3 violations during label operations |

**Correlation**: **Strong** - 0% bypass for simple operations, 100% bypass for complex label management

### Why Complex Workflows Increase Bypass Rate

**Multi-step workflows require**:

1. Remembering to check capabilities.mdc
2. Finding relevant script
3. Understanding script flags/usage
4. Trusting script output (vs verifying with direct API)
5. Handling script errors appropriately

**Bypass motivations** (hypothesized):

- **Speed**: Direct curl feels faster than finding/reading script docs
- **Certainty**: API documentation is authoritative; script behavior may be unclear
- **Habit**: Familiar with GitHub API; less familiar with repo scripts
- **Error handling**: When script shows error, unclear whether to trust it or verify
- **Context overload**: During complex workflows, capacity for checking caps decreases

---

## Simpler Workflows vs Stronger Enforcement

### Option 1: Simplify Workflows

**Make label management simpler**:

- Auto-sync labels with changeset state (CI automation)
- Eliminate manual label removal step
- Reduce workflow from 5 actions → 2 actions

**Pros**: Removes complexity that causes bypasses  
**Cons**: Requires CI changes, external validation

### Option 2: Stronger Enforcement (Implemented)

**Make script-first blocking** (Task 30.0):

- Added to pre-send gate: "Scripts: MANDATORY (BLOCKING)"
- If script exists → MUST use; API bypass → FAIL
- Gate halts on violation, forces correction

**Pros**: Prevents bypasses through blocking enforcement  
**Cons**: Doesn't reduce underlying complexity

### Option 3: Hybrid Approach (Recommended)

**Combine both strategies**:

1. **Blocking gates** (Task 30.0) - prevents bypasses in short term
2. **Workflow simplification** - reduces long-term bypass motivation
3. **Script improvements** - better error messages, clearer trust signals

**Example improvements**:

- `pr-labels.sh --remove` → verify and report: "Label removed (verified)"
- `pr-changeset-sync.sh` → auto-sync labels with changeset state
- Clear script output reduces "need to verify with curl" impulse

---

## Recommendations

### Immediate (Implemented via Task 30.0)

✅ **Blocking gate for script-first** (assistant-behavior.mdc):

- Script exists → MUST use; bypass → FAIL
- Query visibility MANDATORY: "Checked capabilities.mdc for [op]: [result]"
- No exceptions for "complex workflows"

### Short-Term (Tasks 32.2)

⏸️ **Improve pr-labels.sh trustworthiness**:

- Add verification after --remove (check label actually gone)
- Clearer success messages: "Label 'X' removed (verified)"
- Better error handling (distinguish "not found" vs "auth failed")

### Long-Term (Enhancement)

⏸️ **Workflow automation**:

- `pr-changeset-sync.sh` - auto-remove skip-changeset when changeset added
- CI check: fail if changeset + skip-changeset both present
- Reduces manual label management to zero

---

## Success Metrics

**Script-first compliance**:

- Current (post-Gap #18): Unknown (too recent)
- Target: 100% (match H1 git-commit.sh compliance)
- Measurement: Monitor next 20 PR/label operations

**Bypass prevention**:

- Blocking gate should catch 100% of bypass attempts
- User reports zero script bypasses after Task 30.0
- No curl/API calls when repo script exists

**Workflow simplification**:

- If label sync automated: Manual label operations → 0
- If script verification added: "Need to verify" impulse → 0

---

## Related Gaps

- **Gap #14**: Script bypass on error (trust vs verify tension)
- **Gap #15**: Script bypass during PR creation (complexity caused bypass)
- **Gap #18**: Script bypass despite alwaysApply (validates pattern)
- **Gap #17**: Complex behaviors violated even with alwaysApply (same root cause)

---

## Meta-Lesson

**From synthesis.md**: "AlwaysApply works for simple rules but struggles with complex behaviors"

**This pattern validates**: Even with alwaysApply (H1: 100% for simple git-commit usage), complex workflows (label management: 3-5 actions) had 100% bypass rate before blocking gates.

**Conclusion**: Complex workflows need **blocking gates**, not just AlwaysApply + visible OUTPUT.

**Evidence**: Task 30.0 blocking gates implementation expected to reduce bypass rate from 100% → 0%

---

**Status**: Pattern documented (Task 32.4 complete)  
**Next**: Monitor script-first compliance post-blocking-gates implementation  
**Validation**: Next 20 PR/label operations should show 0% bypass rate
