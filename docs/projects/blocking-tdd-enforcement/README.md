# Blocking TDD Enforcement

**Status**: Active — Phase 2 (Validation Testing)  
**Priority**: CRITICAL  
**Created**: 2025-10-24  
**Owner**: repo-maintainers  
**Phase 1**: ⚠️ Partial (file pairing deployed, temporal ordering gap discovered)  
**Gap #23**: TDD violated 5 min after deployment - gate incomplete  
**Monitoring**: See [ACTIVE-MONITORING.md](../ACTIVE-MONITORING.md#blocking-tdd-enforcement)

---

## Problem

**TDD violations persist** despite alwaysApply rules and visible gates:

- **12 violations documented** (Gaps #7-22)
- **5 violations with alwaysApply rules loaded**
- **Latest**: Gap #22 (created 255-line shell script without tests while working on rule enforcement project)

**Current enforcement**: Informational gates (show warnings) but no mechanical blocking

---

## Root Cause (Confirmed)

**TDD pre-edit gate has scope gap**:

- Current: "before **editing** any maintained source"
- Gap: Doesn't cover "**creating**" new files
- Evidence: Gaps #18, #22 both created NEW files without tests

**Secondary**: Escape hatch allows bypassing:

- Current: "owner spec added/updated **or explicit blocker stated**"
- Problem: Can satisfy gate with "will add tests later"

---

## Solution

### Blocking TDD Enforcement

**1. Expand Scope**:

- Change: "editing" → "creating or editing"
- Trigger: File creation AND file editing

**2. Add File Pairing Validation**:

- Check: Creating _.sh → _.test.sh required
- Check: Creating _.ts → _.test.ts|\*.spec.ts required
- Exempt: _.mdc, _.md, .lib*.sh, *.config.\*

**3. Remove Escape Hatch**:

- Remove: "or explicit blocker stated"
- Make: Test file requirement absolute

**4. Mechanical Blocking**:

- If source without test → Gate = FAIL
- FAIL action: DO NOT SEND MESSAGE
- Error: "Cannot create <file> without test file. Create <test-file> first."

---

## Quick Navigation

- **ERD**: [erd.md](./erd.md) — Requirements and design
- **Tasks**: [tasks.md](./tasks.md) — Implementation phases
- **Evidence**: [Gap #22 docs](../rules-enforcement-investigation/findings/gap-22-tdd-violation-pattern-archive-ready.md)

---

## Implementation Plan

### Phase 1: Update assistant-behavior.mdc (~30-45 min)

- Update 4 locations (lines 290, 311, 354, after 332)
- Add file pairing validation logic
- Test blocking behavior

### Phase 2: Validation Testing (~15-30 min)

- 5 test scenarios (create without test, test first, batch, edit with/without tests)
- Document pass/fail for each
- Verify blocking works correctly

### Phase 3: Monitoring (1 week)

- Track: TDD violations (target: 0)
- Track: False positives (target: <1%)
- Track: Workflow disruption (target: none)
- Adjust exemptions if needed

---

## Success Criteria

**Must Achieve**:

- ✅ 0 TDD violations over 1 week (≥20 file operations)
- ✅ <1% false positives (legitimate files not blocked)
- ✅ Gate FAILS when creating source without test
- ✅ Gate PASSES when test created first or in same batch

**Impact Target**:

- From: 12 violations documented (baseline)
- To: 0 violations (100% prevention)

---

## Evidence

**Gap #22**: Created project-archive-ready.sh without tests despite:

- ✅ tdd-first.mdc loaded (alwaysApply: true)
- ✅ Shell scripts in explicit TDD scope
- ✅ Working on rule enforcement project
- ✅ User repeatedly noting pattern
- ❌ **Still violated**

**Historical pattern**:

- Gap #18: Created pr-labels.sh without tests (new file)
- Gap #22: Created project-archive-ready.sh without tests (new file)
- Both NEW files → confirms scope gap

**Validation**: 5 gaps with alwaysApply rules, 3 gaps with visible gates, all violated

---

## Timeline

| Phase   | Duration  | Status   |
| ------- | --------- | -------- |
| Phase 1 | 30-45 min | ⏸️ Ready |
| Phase 2 | 15-30 min | Pending  |
| Phase 3 | 1 week    | Pending  |
| Phase 4 | 30 min    | Pending  |

**Total**: ~2 hours implementation + 1 week validation

---

**Status**: Phase 1 ready to start  
**Priority**: CRITICAL (blocks rules-enforcement-investigation completion)  
**Confidence**: Very High (95%+) — root cause identified, solution designed  
**Next**: Implement blocking enforcement in assistant-behavior.mdc
