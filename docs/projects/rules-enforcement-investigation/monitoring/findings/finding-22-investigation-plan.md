---
findingId: 22
date: "2025-10-24"  # Inferred from migration
project: "rules-enforcement-investigation"
severity: "medium"  # Default for migrated findings
status: "open"      # Default for migrated findings
reviewed: false
reviewedBy: null
reviewedDate: null
sourceLogs: []      # To be filled post-migration
---

# Gap #22 Investigation Plan: Why TDD Violations Persist

**Gap**: Gap #22 (TDD violation — project-archive-ready.sh created without tests)  
**Created**: 2025-10-24  
**Priority**: High (11th documented violation)

---

## Investigation Objective

**Primary Question**: Why do TDD violations continue to occur despite:

- ✅ alwaysApply rule loaded (tdd-first.mdc)
- ✅ Explicit scope coverage (shell scripts)
- ✅ Clear TDD pre-edit gate defined
- ✅ Working on rule enforcement project (maximum awareness)
- ✅ User repeatedly pointing out violations

**Expected Outcome**: Identify mechanical enforcement gap and propose blocking solution

---

## Investigation Hypotheses

### H1: TDD Gate is Informational, Not Blocking

**Hypothesis**: The TDD pre-edit gate shows in status updates but doesn't mechanically prevent file creation

**Evidence to collect**:

- Review `assistant-behavior.mdc` TDD pre-edit gate implementation
- Check if gate is "show warning" vs "refuse to proceed"
- Analyze past violations: did gate show but get ignored?

**Test**: Attempt to create a file without tests and observe if anything blocks it

**Predicted result**: Gate shows informational message but doesn't prevent action

---

### H2: File Creation vs File Editing Different Paths

**Hypothesis**: TDD gate triggers on "edit" but not "create new file"

**Evidence to collect**:

- Review gate language: "before editing any maintained source"
- Check if "editing" excludes "creating"
- Look at how file creation is handled vs file modification

**Test**: Check gate behavior for new files vs existing files

**Predicted result**: Gate only triggers for edits to existing files

---

### H3: Complex Workflows Bypass Simple Gates

**Hypothesis**: Multi-step workflows (create script + tests + docs) aren't covered by single-action gates

**Evidence to collect**:

- Review past violations: were they simple edits or complex workflows?
- Gap #17 (proactive documentation) - multi-step behavior
- Gap #22 (create script) - multi-step creation
- Check if gates are action-specific vs workflow-specific

**Test**: Compare simple edit vs complex workflow behavior

**Predicted result**: Gates work for simple edits, bypassed for complex workflows

---

### H4: Awareness Without Mechanical Prevention Insufficient

**Hypothesis**: Rules are advisory guidance, not executable constraints; awareness alone can't prevent violations

**Evidence to collect**:

- Count violations where rules were loaded and known
- Gap #15: Pre-send gate present, still violated
- Gap #17: AlwaysApply rule, explicit "don't wait", still violated
- Gap #22: TDD alwaysApply, working on enforcement project, still violated

**Test**: This gap itself is evidence (11th violation with full awareness)

**Predicted result**: 100% of recent violations had full rule awareness

---

## Evidence Collection Plan

### Part 1: Gate Behavior Analysis

**Actions**:

1. Review `assistant-behavior.mdc` TDD pre-edit gate section
2. Check if "must" means informational or blocking
3. Trace past violations: did gate show? what happened after?
4. Document gate trigger conditions

**Expected findings**:

- Gate is informational ("show TDD confirmation")
- No mechanical blocking ("refuse to create file")
- Violations occurred with gate visible

---

### Part 2: File Creation Path Analysis

**Actions**:

1. Review how file creation is handled
2. Check if TDD gate covers `write` tool calls
3. Look for file-creation-specific gates
4. Document coverage gaps

**Expected findings**:

- Gates may only cover edits, not creation
- `write` tool might bypass edit gates
- File pairing validation missing

---

### Part 3: Workflow Complexity Analysis

**Actions**:

1. Categorize past violations: simple vs complex
2. Compare gate effectiveness: single-action vs multi-step
3. Identify workflow types that bypass gates
4. Document workflow coverage gaps

**Expected findings**:

- Complex workflows more likely to bypass gates
- Multi-step behaviors need orchestration-level gates
- Single-action gates insufficient for workflows

---

### Part 4: Enforcement Pattern Analysis

**Actions**:

1. Review all 11 documented violations
2. Categorize by enforcement pattern present
3. Calculate violation rate by pattern type
4. Identify patterns that never violated

**Expected findings**:
| Pattern | Violations | Total | Rate | Effectiveness |
|---------|-----------|-------|------|---------------|
| Advisory | ? | ? | High | Low |
| Visible gate | ? | ? | Medium | Medium |
| AlwaysApply | ? | ? | Low | High (but not 100%) |
| Blocking gate | 0 | 0 | 0% | Not tested |

---

## Analysis Method

### Step 1: Evidence Gathering (2-3 hours)

- Read all gap documents (#1-21)
- Extract: rule present? gate visible? violation occurred?
- Categorize by enforcement pattern
- Build violation frequency table

### Step 2: Pattern Analysis (1-2 hours)

- Compare enforcement patterns
- Identify common threads
- Test hypotheses against evidence
- Rank hypotheses by evidence strength

### Step 3: Solution Design (1-2 hours)

- For strongest hypothesis, design blocking mechanism
- Spec out enforcement points (pre-send gate, file pairing, etc.)
- Define success criteria (0 violations for 1 week)
- Propose implementation plan

### Step 4: Validation Plan (1 hour)

- Define test cases for proposed solution
- Specify measurement approach
- Set monitoring period
- Document exit criteria

---

## Success Criteria

**Investigation complete when**:

1. ✅ Root cause identified with strong evidence
2. ✅ Hypothesis validated or refuted
3. ✅ Blocking enforcement mechanism designed
4. ✅ Implementation plan documented
5. ✅ Test plan specified

**Validation successful when**:

1. Proposed solution implemented
2. 0 TDD violations for 1 week (≥20 file creations)
3. Gate blocks file creation without tests
4. No false positives (legitimate non-TDD files allowed)

---

## Initial Evidence (Quick Scan)

### Violations with Full Awareness

**Gap #17** (Reactive documentation):

- ✅ `self-improve.mdc` alwaysApply loaded
- ✅ Explicit "Proactive documentation required"
- ✅ User working on investigation (maximum awareness)
- ❌ Still offered fix-first, not document-first

**Gap #15** (Changeset label):

- ✅ Pre-send gate included changeset check
- ✅ Rule text explicit
- ❌ Still violated 3 times

**Gap #22** (This gap - TDD):

- ✅ `tdd-first.mdc` alwaysApply loaded
- ✅ Shell scripts explicitly covered
- ✅ Working on rule enforcement project
- ❌ Created 255-line script without tests

**Pattern**: **Awareness + visibility ≠ prevention**

---

## Proposed Solution (Preliminary)

### Blocking TDD Gate

**Concept**: Pre-send gate FAILS if source file created/edited without corresponding test file

**Implementation points**:

1. **File pairing check**: Before sending message with file operations:

   - If creating/editing `*.sh` → require `*.test.sh` exists or being created in same turn
   - If creating/editing `*.ts` → require `*.test.ts` or `*.spec.ts` exists or being created
   - If creating/editing `.cursor/rules/*.mdc` → exempt (docs)

2. **Pre-send gate item**: Add to compliance-first send gate:

   ```
   - [ ] TDD: source created/edited → test file present? (if impl edits)
   ```

3. **Gate behavior**:
   - If FAIL → Mark gate as FAIL
   - DO NOT SEND MESSAGE
   - Show error: "Cannot create <file> without test file. Create <test-file> first."
   - Require revision before proceeding

**Expected impact**: 0 TDD violations (mechanical prevention)

---

## Next Steps

### Immediate

1. ✅ Document as Gap #22
2. ✅ Create investigation plan (this file)
3. [ ] Fix failing tests for project-archive-ready.sh (complete TDD cycle)
4. [ ] Add Gap #22 to rules-enforcement-investigation findings/README.md

### Investigation Phase

1. [ ] Gather evidence from all 11 violations
2. [ ] Test hypotheses
3. [ ] Design blocking TDD gate
4. [ ] Propose implementation

### Implementation Phase (If investigation confirms blocking gate needed)

1. [ ] Update `assistant-behavior.mdc` pre-send gate
2. [ ] Add file pairing check
3. [ ] Test with intentional violations
4. [ ] Monitor for 1 week

---

## Questions for User

1. **Scope confirmation**: Should we investigate all TDD violations or focus specifically on this one?
2. **Priority**: Is this urgent (block other work) or can it be tracked as carryover?
3. **Approach**: Full investigation (multi-hour analysis) or quick fix (add blocking gate now)?

---

**Status**: Documented, investigation plan ready  
**Evidence**: Gap #22 is 11th violation, validates core finding  
**Proposed solution**: Blocking TDD gate in pre-send checklist  
**Next**: Gather evidence, test hypotheses, design blocking mechanism
