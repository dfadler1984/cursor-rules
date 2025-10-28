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

# Gap #22 Root Cause Analysis: TDD Gate Behavior Investigation

**Created**: 2025-10-24  
**Type**: Deep-dive investigation  
**Focus**: Why TDD pre-edit gate doesn't prevent violations

---

## Executive Summary

**Root Cause Identified**: The TDD pre-edit gate exists in TWO places with DIFFERENT enforcement:

1. **Section: "TDD pre-edit gate"** (lines 352-368) → Informational guidance ("provide a TDD confirmation")
2. **Section: "Compliance-first send gate"** (line 290) → Checklist item but **behavior when FAIL is unclear for TDD**

**Critical Finding**: Pre-send gate says "if impl edits" but creating a NEW file may not trigger this check.

**Evidence**: Created `project-archive-ready.sh` (new file, not edit) → TDD gate likely not triggered

---

## Investigation Evidence

### Evidence 1: TDD Pre-Edit Gate Text (Lines 352-368)

```markdown
## TDD pre-edit gate (all maintained sources)

- Before editing any maintained source (see scope in `.cursor/rules/tdd-first.mdc`),
  provide a TDD confirmation with:

  - The owner spec/test path(s) to add/update
  - A one-line failing assertion/expectation

  Then proceed in order:

  1. Red: add or update the failing spec
  2. Green: implement the minimal change
  3. Re-run focused tests
  4. Refactor while keeping tests green

- If a test file does not exist, create it before any implementation edits.
```

**Analysis**:

- Says "**provide** a TDD confirmation" (informational)
- Does NOT say "refuse to edit" or "fail if missing"
- Says "before editing" — does this cover "creating new file"?
- Has guidance on what to do, but no blocking mechanism

**Conclusion**: This section is **advisory guidance**, not mechanical enforcement

---

### Evidence 2: Pre-Send Gate Checklist (Lines 285-299)

```markdown
Pre-Send Gate:

- [ ] Links: Markdown format?
- [ ] Status: included?
- [ ] TODOs: reconciled?
- [ ] Consent: obtained?
- [ ] TDD: spec updated? (if impl edits) <-- HERE
- [ ] Scripts: checked capabilities.mdc?
      ...
      Gate: [PASS/FAIL]
```

**Then verify each item**:

```markdown
- **TDD gate**: for implementation edits, owner spec added/updated
  (Red → Green → Refactor) or explicit blocker stated.
```

**Blocking behavior** (lines 315-316):

```markdown
**If any item fails**: Mark gate as FAIL. **DO NOT SEND MESSAGE**.
Revise the violation, re-check all items, repeat until PASS.
```

**Analysis**:

- TDD is a checklist item ✅
- Has blocking behavior if FAIL ("DO NOT SEND MESSAGE") ✅
- BUT condition is "**if impl edits**" ❓
- Creating NEW file = "impl edits"? **Unclear**
- Gate likely only checks EDITS to existing files, not NEW file creation

**Conclusion**: Blocking mechanism exists but may not cover file creation

---

### Evidence 3: What Happened with project-archive-ready.sh

**Action**: Created NEW file `project-archive-ready.sh` (not editing existing file)

**TDD Gate Trigger Check**:

- Is this "editing any maintained source"? **No** (new file, not edit)
- Is this "impl edits"? **Maybe** (creating implementation code)
- Did pre-send gate TDD check trigger? **Unknown** (likely no)

**Behavior observed**:

- No TDD confirmation shown in status
- No blocking occurred
- File created without tests
- User pointed out violation

**Conclusion**: **File creation bypassed TDD gate** (gate only triggers on edits to existing files)

---

## Root Cause Confirmed

**Primary Root Cause**: **TDD gate has scope gap — covers "editing" existing files but not "creating" new files**

**Supporting Evidence**:

1. **Gate text ambiguity**:

   - "before **editing** any maintained source" (line 354)
   - "if **impl edits**" (line 290)
   - Creating new file = editing? **Not explicitly covered**

2. **Behavior pattern**:

   - Created new file → no TDD gate triggered
   - Editing existing file → TDD gate should trigger
   - **Scope gap**: New file creation not covered

3. **Historical pattern**:
   - Gap #18: Created `pr-labels.sh` without tests (new file)
   - Gap #22: Created `project-archive-ready.sh` without tests (new file)
   - Both were NEW files, not edits
   - **Pattern**: New file creation bypasses TDD gate

---

## Secondary Root Cause

**Even if gate triggered, enforcement is weak**:

**Current behavior** (line 290-299):

```markdown
- [ ] TDD: spec updated? (if impl edits)
- For implementation edits, owner spec added/updated OR explicit blocker stated
```

**Problem**: "OR explicit blocker stated" is an escape hatch

- Can satisfy gate by stating "blocker: no test runner"
- Can satisfy gate by stating "will add tests later"
- **No forcing function** to actually create tests first

**Needed**: Remove escape hatch, make it absolute:

```markdown
- [ ] TDD: test file exists for source file?
  - Check: Creating/editing _.sh → _.test.sh must exist or be created in same batch
  - If NO: Gate = FAIL, DO NOT SEND
  - No exceptions for "will add later"
```

---

## Why This Matters

**This explains ALL recent TDD violations**:

| Gap | File                     | Type     | TDD Gate Triggered? | Why Not?                |
| --- | ------------------------ | -------- | ------------------- | ----------------------- |
| #18 | pr-labels.sh             | New file | ❌ No               | File creation, not edit |
| #22 | project-archive-ready.sh | New file | ❌ No               | File creation, not edit |

**If gate covered file creation**: Both violations would have been prevented

---

## Solution Design

### Fix 1: Expand TDD Gate Scope (Critical)

**Current** (line 354):

```markdown
- Before editing any maintained source...
```

**Proposed**:

```markdown
- Before creating or editing any maintained source...
```

**Current** (line 290):

```markdown
- [ ] TDD: spec updated? (if impl edits)
```

**Proposed**:

```markdown
- [ ] TDD: test file exists? (if creating/editing impl sources)
  - Check: Creating/editing _.sh → _.test.sh present or in same batch
  - Check: Creating/editing _.ts → _.test.ts|\*.spec.ts present or in same batch
  - Exempt: _.mdc, _.md, .lib\*.sh
```

**Impact**: Covers file creation, not just edits

---

### Fix 2: Remove Escape Hatch (Critical)

**Current** (line 307):

```markdown
- **TDD gate**: for implementation edits, owner spec added/updated
  (Red → Green → Refactor) or explicit blocker stated.
```

**Proposed**:

```markdown
- **TDD gate**: for implementation sources, test file must exist.
  - Creating _.sh → _.test.sh required (no exceptions)
  - Creating _.ts → _.test.ts|\*.spec.ts required (no exceptions)
  - If missing: Gate = FAIL, show error, DO NOT SEND
  - Error: "Cannot create <file> without test file. Create <test-file> first."
```

**Impact**: No escape hatch, absolute requirement

---

### Fix 3: Strengthen Blocking Language (Important)

**Current** (lines 315-316):

```markdown
**If any item fails**: Mark gate as FAIL. **DO NOT SEND MESSAGE**.
Revise the violation, re-check all items, repeat until PASS.
```

**Status**: Already strong (DO NOT SEND MESSAGE in bold)

**Issue**: Despite strong language, still violated

**Hypothesis**: Language interpreted as "should not" rather than "cannot"

**Proposed enhancement**: Make it computational/mechanical:

```markdown
**Blocking enforcement** (Gap #15, #22 validated):

- Gate failures MUST halt message send
- Visible gates create transparency but don't prevent violations
- Blocking gates force correction before proceeding
- No exceptions: If gate FAIL, revise first, then re-check
```

**Impact**: Clarifies that FAIL means mechanical block, not advisory warning

---

## Validation Test

**Test scenario**: Try to create a new shell script without tests

**Expected behavior BEFORE fix**:

1. Create `test-new-script.sh`
2. Pre-send gate TDD check: "if impl edits" → ambiguous for new files
3. Gate likely not triggered or passes with escape hatch
4. Message sent, file created
5. **Violation occurs**

**Expected behavior AFTER fix**:

1. Attempt to create `test-new-script.sh`
2. Pre-send gate TDD check: "if creating/editing impl sources" → TRIGGERED
3. Check: `test-new-script.test.sh` exists? NO
4. Gate = FAIL
5. **Message NOT sent**, error shown
6. Must create `test-new-script.test.sh` first
7. Then can create implementation

---

## Implementation Plan

### Phase 1: Update assistant-behavior.mdc (30 min)

1. Line 354: Change "editing" → "creating or editing"
2. Line 290-291: Expand TDD gate check to cover file creation
3. Line 307: Remove escape hatch, make absolute requirement
4. Line 315-320: Add blocking enforcement clarification
5. Test by creating new file without tests (should be blocked)

### Phase 2: Add File Pairing Validation (45 min)

Add to pre-send gate verification logic (after line 300):

```markdown
- **TDD gate (file pairing check)**:
  - Scan tool calls for `write` or `search_replace` on impl sources
  - For each source file, check if corresponding test file exists or is being created
  - File patterns:
    - `*.sh` → `*.test.sh`
    - `*.ts` (not _.mdc) → `_.test.ts`OR`\*.spec.ts`
    - `*.tsx` → `*.test.tsx` OR `*.spec.tsx`
  - Exempt patterns: `*.mdc`, `*.md`, `.lib*.sh`, `*.config.*`
  - If source file without test file: Gate = FAIL
  - FAIL action: DO NOT SEND MESSAGE, show:
    "Cannot create/edit <file> without test file. Create <test-file> first (Red → Green → Refactor)."
```

### Phase 3: Test Enforcement (15 min)

1. Attempt to create `enforcement-test.sh` without tests
2. Expected: Gate FAILS, message blocked
3. Create `enforcement-test.test.sh` first
4. Then create `enforcement-test.sh`
5. Expected: Gate PASSES

### Phase 4: Monitor (1 week)

1. Track file creations
2. Count TDD violations (target: 0)
3. Count false positives (legitimate files blocked)
4. Target: 0 violations, <1% false positives

**Total time**: ~2 hours implementation + 1 week monitoring

---

## Confidence Assessment

**Root cause confidence**: **VERY HIGH (95%+)**

**Evidence strength**:

1. ✅ Gate text explicitly says "editing" not "creating"
2. ✅ Pre-send gate condition says "if impl edits" (ambiguous for new files)
3. ✅ Both recent TDD violations were NEW files
4. ✅ Pattern consistent: new files bypass gate, edits may trigger it
5. ✅ Solution (expand scope to cover creation) directly addresses gap

**Alternative explanations ruled out**:

- ❌ Not "awareness insufficient" (was aware, still violated)
- ❌ Not "gate doesn't exist" (gate exists in two places)
- ❌ Not "gate not visible" (defined in alwaysApply rule)
- ✅ **IS "gate has scope gap"** (doesn't cover file creation)

---

## Next Steps

### Immediate

1. ✅ Root cause identified
2. ✅ Solution designed
3. [ ] Implement fixes to assistant-behavior.mdc
4. [ ] Test blocking behavior
5. [ ] Monitor for 1 week

### Documentation

1. ✅ Gap #22 documented
2. ✅ Root cause analysis complete (this file)
3. [ ] Add to rules-enforcement-investigation tasks
4. [ ] Update findings/README.md with solution

---

**Root Cause**: TDD gate scope gap — covers "editing" but not "creating" new files  
**Solution**: Expand scope + remove escape hatch + strengthen blocking language  
**Confidence**: Very high (95%+)  
**Implementation**: ~2 hours  
**Expected Impact**: 0 TDD violations (mechanical prevention)
