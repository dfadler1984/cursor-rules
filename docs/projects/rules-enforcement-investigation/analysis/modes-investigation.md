# Cursor Modes Investigation

**Date**: 2025-10-20  
**Purpose**: Understand how Cursor modes (Chat, Agent, Plan, etc.) affect rule enforcement and explain hooks limitation

---

## Executive Summary

**Key Question**: Why didn't hooks work? Could it be mode-related?

**Answer**: Hooks require experiment flag (disabled by org policy). Mode may be a factor, but org policy is the blocker.

**Practical Impact**: Rules enforcement works in current mode (Chat/Composer). AlwaysApply at 96% proves rules function regardless of mode.

---

## Known Cursor Modes

Based on ERD and documentation references:

### 1. Chat / Composer Mode (Current)

**What we observe**:

- ✅ Rules load and apply (alwaysApply works)
- ✅ Tool calls execute (read_file, search_replace, run_terminal_cmd)
- ✅ Context includes rules + conversation history
- ✅ AlwaysApply validated at 96% compliance
- ❌ Hooks don't trigger (but org policy blocks experiment flag)

**Characteristics** (inferred):

- Interactive Q&A and code edits
- Rules-driven behavior
- Consent-first workflows
- Supports all current enforcement patterns

### 2. Agent Mode

**From documentation** ([docs.cursor.com/agent](https://docs.cursor.com/agent)):

- More autonomous operation
- Hooks documentation lives under `/docs/agent/hooks`
- May have different autonomy levels

**Unknown**:

- ❓ Does Agent mode enable hooks without experiment flag?
- ❓ How does autonomy differ from Chat mode?
- ❓ Do rules apply differently?
- ❓ Is this a workspace-level mode or task-level mode?

**Hypothesis**: Hooks might be Agent-mode-only, but **org policy still blocks** the experiment flag regardless of mode.

### 3. Plan Mode

**From announcement** ([cursor.com/blog/plan-mode](https://cursor.com/blog/plan-mode)):

- Planning-focused workflow
- Generates plan before implementation
- May align with `spec-driven.mdc` workflow

**Unknown**:

- ❓ How does Plan Mode interact with TDD-first rules?
- ❓ Does it enforce planning phase before edits?
- ❓ Can it bypass consent gates?

### 4. Ask Mode / Manual Mode

**From ERD** ([docs.cursor.com/agent](https://docs.cursor.com/agent)):

- Different interaction patterns
- Less autonomy than Agent mode?

**Unknown**:

- ❓ What distinguishes these modes?
- ❓ How do rules apply in each?

### 5. Custom Modes

**From changelog** ([cursor.com/changelog/0-48-x](https://cursor.com/changelog/0-48-x)):

- User-definable modes
- Custom behavior patterns?

**Unknown**:

- ❓ How are custom modes configured?
- ❓ Can they override rules?

---

## Impact on Rules Enforcement

### What We Know Works (Validated)

**Current Mode (Chat/Composer)**:

- ✅ AlwaysApply rules: Load consistently, 96% compliance
- ✅ Conditional rules: Intent routing works
- ✅ Tool execution: All tools function
- ✅ Consent gates: User can grant/deny
- ✅ TDD gates: Pre-edit checks trigger

**Conclusion**: Rules enforcement is **fully functional** in current mode.

### What We Don't Know

**Mode-Specific Behavior**:

- ❓ Do hooks work in Agent mode without experiment flag? (Unlikely - flag is flag)
- ❓ Does Plan Mode enforce `spec-driven.mdc` automatically?
- ❓ Do modes affect which rules load (beyond alwaysApply)?
- ❓ Do autonomy levels affect consent gates?

### What Matters for Investigation

**Critical Questions**:

1. **Does mode explain hooks failure?**

   - Partial: Hooks docs are under `/agent/`, suggesting Agent mode focus
   - But: Org policy blocks experiment flag regardless of mode
   - **Result**: Mode might be necessary but org policy is sufficient blocker

2. **Do modes affect rule compliance?**

   - Unknown: Can't test other modes
   - Evidence: Current mode works at 96%
   - **Result**: Current patterns are validated and sufficient

3. **Should we document mode-specific guidance?**
   - Yes: If modes have different autonomy/planning behavior
   - But: Need access to other modes to validate
   - **Result**: Document what we know, note gaps

---

## Practical Recommendations

### For This Investigation

**1. Mode is NOT the blocker for hooks** ✅

- Org policy blocks experiment flag
- Even if Agent mode enables hooks, flag is still required
- Investigation proceeds without hooks regardless of mode

**2. Current mode is sufficient for rules enforcement** ✅

- AlwaysApply: 96% validated
- Conditional routing: Works
- External validation: 100% (CI/pre-commit)
- No evidence that switching modes would improve compliance

**3. Mode-specific guidance is out of scope** ⏸️

- Can't access other modes to test
- Documentation lacks detailed mode comparisons
- Would require extensive testing in each mode
- Not critical for investigation completion

### For Future Work

**If modes become available**:

1. **Test hooks in Agent mode**

   - Even with org restrictions, document findings
   - May inform future when restrictions lift

2. **Test Plan Mode with spec-driven.mdc**

   - Does it enforce planning automatically?
   - Could reduce need for alwaysApply on planning rules

3. **Compare rule enforcement across modes**

   - Do violation rates differ?
   - Do consent gates behave differently?
   - Does autonomy affect TDD compliance?

4. **Create mode-specific guidance**
   - When to use each mode for this repository
   - Mode→rule compatibility matrix
   - Caveats for each mode

---

## Answers to Original Questions

### "Why didn't hooks work?"

**Primary cause**: Organization policy blocks experiment flag  
**Secondary factor**: Hooks documentation is Agent-focused, may require Agent mode  
**Conclusion**: Mode might matter, but org policy is the blocker

### "Do modes affect rule enforcement?"

**Answer**: Unknown for other modes, but current mode works at 96%  
**Evidence**: AlwaysApply validation shows rules function in current mode  
**Conclusion**: No evidence that mode affects enforcement in ways that matter for this investigation

### "Should we consider modes for our work?"

**Answer**: Not critical for this investigation  
**Rationale**:

- Current mode supports all validated patterns
- Can't access other modes to test
- Org policy blocks hooks regardless of mode
- Investigation can proceed with current findings

---

## Mode Investigation Status

**What we established**:

- ✅ Current mode (Chat/Composer) fully supports rules enforcement
- ✅ AlwaysApply validated at 96% in current mode
- ✅ Hooks blocked by org policy (mode likely irrelevant)
- ✅ No evidence that modes affect compliance in measurable ways

**What remains unknown**:

- ❓ Detailed differences between modes
- ❓ Whether Agent mode enables any hooks without flag
- ❓ Whether Plan Mode enforces planning automatically
- ❓ Mode-specific rule behavior

**Recommendation**:

- Document current mode as validated
- Note mode investigation as future work
- Proceed with investigation using current mode findings
- **Mode differences are NOT a blocker for completion**

---

## User Input Needed (Optional)

If you want deeper mode investigation:

1. **What mode are we currently in?**

   - Chat? Composer? Agent? Other?

2. **Can you access other modes?**

   - Is Agent mode available?
   - Is Plan Mode available?
   - Are there UI indicators for mode switching?

3. **Have you observed mode-specific behavior?**
   - Does behavior change in different modes?
   - Do rules apply differently?

**But**: These questions are **not critical** for investigation completion. We have validated that rules work in the current environment, which is sufficient.

---

**Status**: Mode investigation complete (within scope)  
**Conclusion**: Modes not a blocker; current mode fully functional  
**Next**: Update action plan with available patterns (hooks unavailable, modes not critical)
