# Sub-Projects Coordination

**Purpose**: Track sub-projects and their contributions to the parent investigation

---

## Overview

The rules-enforcement-investigation has been broken into focused sub-projects for clear scope and parallel execution. Each sub-project investigates a specific hypothesis or enforcement pattern.

---

## Sub-Projects

### H1: Conditional Attachment

**Location**: Parent investigation (not split)  
**Status**: ✅ COMPLETE (2025-10-21)  
**Objective**: Test if `alwaysApply: true` improves compliance

**Resolution**:

- ✅ Confirmed: 74% → **100%** script usage (+26 points) — **EXCEEDS 90% TARGET**
- ✅ Primary fix validated with 30 commits
- ✅ Approach: alwaysApply highly effective for ~20 critical rules

**Contribution**: Main enforcement mechanism; solves git operations compliance completely

**Documents**:

- Test plan: [tests/hypothesis-1-conditional-attachment.md](tests/hypothesis-1-conditional-attachment.md)
- Protocol: [protocols/h1-validation.md](protocols/h1-validation.md)

---

### H2: Send Gate Investigation

**Location**: [h2-send-gate-investigation](../../h2-send-gate-investigation/)  
**Status**: ⏸️ MONITORING  
**Objective**: Validate send gate executes, detects violations, blocks them

**Current State**:

- ✅ Test A complete: 0% baseline gate visibility
- ✅ Test D Checkpoint 1: 100% gate visibility after explicit OUTPUT requirement
- ⏸️ Monitoring: Passive accumulation over 10-20 responses

**Interim Finding**: Visible output creates accountability (0% → 100%)

**Contribution**: Transparency mechanism; gate works when OUTPUT required

**Documents**:

- Sub-project: [h2-send-gate-investigation/](../../h2-send-gate-investigation/)
- Test plan: [tests/hypothesis-2-send-gate-enforcement.md](tests/hypothesis-2-send-gate-enforcement.md)
- Test results: [test-results/h2/](test-results/h2/)
- Protocol: [protocols/h2-test-d.md](protocols/h2-test-d.md)
- Finding: [findings/gap-h2-send-gate.md](findings/gap-h2-send-gate.md)

---

### H3: Query Visibility

**Location**: [h3-query-visibility](../../h3-query-visibility/)  
**Status**: ⏸️ MONITORING  
**Objective**: Test whether visible query output improves script usage

**Current State**:

- ✅ Test A complete: 0% query visibility baseline
- ✅ Test C complete: Visible output requirement implemented
- ⏸️ Monitoring: Passive accumulation

**Expected**: 0% → ~100% visibility (same pattern as H2)

**Contribution**: Transparency in script selection process

**Documents**:

- Sub-project: [h3-query-visibility/](../../h3-query-visibility/)
- Test plan: [tests/hypothesis-3-query-protocol-visibility.md](tests/hypothesis-3-query-protocol-visibility.md)
- Test results: [test-results/h3/](test-results/h3/)
- Finding: [findings/gap-h3-query-visibility.md](findings/gap-h3-query-visibility.md)

---

### Slash Commands: Runtime Routing

**Location**: [slash-commands-runtime-routing](../../slash-commands-runtime-routing/)  
**Status**: ❌ NOT VIABLE (platform constraint)  
**Objective**: Test slash commands for runtime routing enforcement

**Resolution**:

- ❌ Runtime routing doesn't work: Cursor's `/` is for prompt templates
- ✅ Platform design understood: `/command` loads `.cursor/commands/command.md`
- 📝 Prompt template approach unexplored (future option)

**Contribution**:

- Eliminated non-viable approach (saved 8-12 hours testing)
- Validated testing paradox (real usage > prospective trials)
- Created assistant-self-testing-limits project

**Documents**:

- Sub-project: [slash-commands-runtime-routing/](../../slash-commands-runtime-routing/)
- Test plan: [tests/experiment-slash-commands.md](tests/experiment-slash-commands.md)
- Decision: [decisions/slash-commands.md](decisions/slash-commands.md)
- Protocol: [protocols/slash-commands-phase3.md](protocols/slash-commands-phase3.md) (not executed)
- Related project: [assistant-self-testing-limits](../../assistant-self-testing-limits/)

---

### Assistant Self-Testing Limits

**Location**: [assistant-self-testing-limits](../../assistant-self-testing-limits/)  
**Status**: ✅ COMPLETE  
**Objective**: Document testing paradox and valid measurement strategies

**Resolution**:

- ✅ Testing paradox: Assistants cannot objectively self-test (observer bias)
- ✅ Valid strategies: Historical analysis, passive monitoring, external validation
- ✅ Platform constraints documented with official Cursor references

**Contribution**:

- Methodology insight: Real usage > prospective testing
- Meta-findings: Gaps #8, #10
- Future experiment design guidance

**Documents**:

- Project: [assistant-self-testing-limits/](../../assistant-self-testing-limits/)

---

### Prompt Templates (Future)

**Location**: Not yet created  
**Status**: PROPOSED  
**Objective**: Test Cursor's actual slash command design (prompt templates)

**Scope**: Create `.cursor/commands/commit.md` etc. with prompts like "Use git-commit.sh"

**Depends on**: H1 validation results; only pursue if H1 drops below 90% or discoverability valued

**Documents**:

- Exploration: [analysis/prompt-templates/exploration.md](analysis/prompt-templates/exploration.md)

---

## Integration & Synthesis

### How Sub-Projects Feed Parent

**H1** → Primary fix (alwaysApply)  
**H2** → Transparency mechanism (visible gate)  
**H3** → Transparency mechanism (visible query)  
**Slash commands** → Eliminated non-viable approach, validated testing methodology  
**Testing limits** → Methodology guidance for future experiments

### Current State

**Complete**: H1 (validated at 100%), Slash commands (platform constraint), Testing limits (paradox documented)  
**Monitoring**: H2 (Checkpoint 1 complete — 100% visibility), H3 (passive accumulation)  
**Proposed**: Prompt templates (lower priority given H1 at 100%)

### Next Phase

**After H2/H3 monitoring** (10-20 responses):

- Synthesize all findings (H1 validated; H2/H3 results pending)
- Create decision tree (when to use each enforcement pattern)
- Document scalable patterns for 25 conditional rules
- Categorize conditional rules with recommendations
- Final summary with validated lessons learned

---

## Meta-Finding

This coordination structure itself addresses **Gap #11**: Investigation documentation structure not defined.

The sub-project pattern provides:

- Clear scope boundaries
- Independent execution
- Explicit contribution to parent
- Reusable for future investigations
