# Slash Commands Experiment — Execution Decision

**Status**: EXECUTING (empirical comparison)  
**Date Started**: 2025-10-16  
**Previous Status**: DEFERRED (2025-10-15)

---

## Current State Analysis

### Fixes Applied

1. ✅ **H1**: `assistant-git-usage.mdc` → `alwaysApply: true`

   - **Result**: 74% → 96% script usage (+22 points)
   - **Status**: Highly effective; approaching target

2. ✅ **H2**: Visible send gate checklist

   - **Result**: 0% → 100% gate visibility (+100 points)
   - **Status**: Explicit OUTPUT requirement works

3. ✅ **H3**: Visible query output ("Checked capabilities.mdc...")
   - **Result**: Implemented; monitoring in progress
   - **Expected**: 0% → ~100% (same pattern as H2)

### Combined Effect (Projected)

**H1 + H2 + H3 together**:

- Always-apply rule: Scripts always in context
- Visible gate: Accountability for compliance
- Visible query: Transparency in script selection

**Projected outcome**: >90% overall compliance (target achieved)

---

## Slash Commands Value Proposition

### What Slash Commands Would Add

**Advantages**:

- ✅ Unambiguous invocation (no routing ambiguity)
- ✅ User-visible tool invocation
- ✅ Discoverable (prompts teach users)
- ✅ Forcing function (can't be skipped)

**Disadvantages**:

- ❌ Requires user behavior change (learn new commands)
- ❌ More friction for users (extra syntax)
- ❌ Implementation complexity (~1-2 days)
- ❌ May not be needed if H1+H2+H3 already achieves >90%

---

## Decision Framework

### Execute Slash Commands Experiment IF:

**Condition A**: H1 validation shows <90% compliance

- After 20-30 commits, script usage remains <90%
- Current trajectory suggests H1+H2+H3 insufficient

**Condition B**: Scalability analysis requires alternative

- Context cost becomes problematic (>10% of budget)
- Need enforcement pattern for 25+ conditional rules
- AlwaysApply doesn't scale to all rules

**Condition C**: User experience issues identified

- Routing misses remain frequent despite H1+H2+H3
- Users request explicit commands for clarity
- Compliance violations concentrated in specific operations

### SKIP Slash Commands Experiment IF:

**Condition 1**: H1+H2+H3 achieves >90% overall compliance

- Target met without additional changes
- Slash commands become optional enhancement
- Document as "future consideration" not "required"

**Condition 2**: User friction concerns outweigh benefits

- Learning curve too steep
- Existing workflow works well enough
- Cost-benefit analysis favors simpler approach

---

## Decision: EXECUTE NOW (2025-10-16)

### Rationale for executing before H1 validation complete

1. **Empirical data preferred**: Get concrete comparison regardless of H1 results
2. **Independent test**: Slash commands vs intent routing comparison stands alone
3. **Efficient use of time**: Can run in parallel with H1 validation accumulation
4. **Clear baseline**: Can reuse H1 baseline (74% script usage) as Phase 1 data

### Previous Recommendation (2025-10-15)

~~DEFER execution until H1 validation complete~~

**Previous rationale** (no longer blocking):

1. Strong early results: 96% script usage after H1
2. H2 working: 100% gate visibility
3. H3 likely working: Same pattern as H2
4. Premature optimization: Slash commands may not be needed

### Timeline

**Decision Point 1** (After 20 commits):

- If H1 validation shows ≥90%: SKIP slash commands
- If H1 validation shows <90%: EXECUTE slash commands

**Decision Point 2** (After scalability analysis):

- If context cost acceptable: SKIP slash commands
- If context cost problematic: EXECUTE as scalable alternative

---

## If Executed Later

### Test Plan Available

**Location**: `tests/experiment-slash-commands.md`

**Phases**:

1. Baseline with intent routing (use H1 baseline)
2. Implementation (~0.5 day)
3. Testing (50 trials, ~1 day)
4. Comparison analysis (~0.5 day)
5. **Total**: 1-2 days

### Success Criteria

- Routing accuracy: >95% (vs ~70% baseline)
- Script usage: >95% (vs 96% with H1)
- User experience: positive feedback
- **Improvement**: ≥5 percentage points over H1 alone

### Risk Assessment

**Low Risk**:

- New rule doesn't break existing behavior
- Can revert easily if issues found
- User opt-in (manual fallback available)

---

## Status

**Current**: DEFERRED (Option A selected)  
**Decision Date**: 2025-10-16  
**Rationale**: H1 (alwaysApply) achieving 96% compliance; testing paradox identified

**Implementation Status**:

- ✅ Created `git-slash-commands.mdc` with enforcement protocol
- ✅ Updated `intent-routing.mdc` with slash command routing (highest priority)
- ✅ Rules validation passed
- ✅ Test protocol documented
- 🔒 Phase 3 testing DEFERRED pending H1 validation

**Decision**:

- H1 already showing 96% script usage (+22 points over 74% baseline)
- Target >90% likely achieved without slash commands
- Testing paradox: assistant cannot objectively test own behavior
- Will only execute if H1 drops below 90% after full validation

**Related**: See `../assistant-self-testing-limits/` for testing paradox documentation

---

## Documentation Reference

- **Full test plan**: `tests/experiment-slash-commands.md`
- **Inspiration**: `discovery.md` → Part 5 (Taskmaster/Spec-kit patterns)
- **Enforcement patterns**: `discovery.md` → Part 3 (6 patterns identified)
- **H1 validation**: `h1-validation-protocol.md`
- **H2 results**: `h2-test-d-checkpoint-1.md`
- **H3 results**: `h3-test-c-results.md`

---

**Decision**: DEFER slash commands pending H1 validation results  
**Rationale**: Strong early results suggest H1+H2+H3 may achieve target without additional complexity  
**Review**: After 20-30 commits accumulated
