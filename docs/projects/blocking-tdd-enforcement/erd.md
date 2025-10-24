---
status: active
owner: repo-maintainers
created: 2025-10-24
lastUpdated: 2025-10-24
---

# Engineering Requirements Document — Blocking TDD Enforcement (Lite)

## 1. Introduction/Overview

**Problem**: TDD violations persist despite alwaysApply rules and visible gates. Gap #22 (creating project-archive-ready.sh without tests) is the 12th documented violation, proving awareness + visibility ≠ prevention.

**Root Cause**: TDD pre-edit gate has **scope gap** — covers "editing" existing files but NOT "creating" new files. Additionally, escape hatch ("or explicit blocker stated") allows bypassing.

**Solution**: Implement blocking TDD enforcement with file pairing validation in pre-send gate. Expand scope to cover file creation, remove escape hatch, add mechanical blocking.

## 2. Goals/Objectives

- **Achieve 0 TDD violations** through mechanical blocking (not advisory)
- Expand TDD gate scope: "editing" → "creating or editing"
- Remove escape hatch from pre-send gate TDD check
- Add file pairing validation (_.sh → _.test.sh, _.ts → _.test.ts|\*.spec.ts)
- Maintain <1% false positive rate

## 3. Functional Requirements

1. **File Pairing Validation** — Detect creating/editing impl sources (_.sh, _.ts, \*.tsx), check if test file exists or being created in same batch
2. **Blocking Pre-Send Gate** — If source without test → Gate = FAIL, DO NOT SEND MESSAGE, show error
3. **Scope Expansion** — Change "editing" → "creating or editing" in gate text
4. **Remove Escape Hatch** — Remove "or explicit blocker stated", make test requirement absolute
5. **Exemptions** — _.mdc, _.md, .lib*.sh, *.config.\* correctly excluded

## 4. Acceptance Criteria

**Implementation**:

- ✅ assistant-behavior.mdc updated (lines 290, 311, 354)
- ✅ File pairing check added to pre-send gate verification
- ✅ Escape hatch removed
- ✅ Blocking language strengthened

**Validation**:

- ✅ Test: Create _.sh without _.test.sh → Gate FAILS, message blocked
- ✅ Test: Create _.test.sh first, then _.sh → Gate PASSES
- ✅ Test: Create both in same batch → Gate PASSES
- ✅ No false positives (_.mdc, _.md correctly exempted)

**Monitoring** (1 week):

- ✅ 0 TDD violations (≥20 file creations tracked)
- ✅ <1% false positives
- ✅ 100% legitimate TDD workflows unblocked

## 5. Risks/Edge Cases

**Risk 1: False Positives** — Blocking legitimate non-impl files

- Mitigation: Comprehensive exemption list
- Validation: Monitor false positive rate <1%

**Risk 2: Batch Detection** — Missing source + test created together

- Mitigation: Check both file system AND pending tool calls
- Validation: Test batch creation scenarios

**Risk 3: Workflow Disruption** — Too aggressive blocking

- Mitigation: Clear error messages, suggest solutions
- Validation: Monitor user feedback

**Edge Case 1**: Editing test file itself (\*.test.sh)

- Should NOT require \*.test.test.sh
- Exemption: Files matching _.test._, _.spec._

**Edge Case 2**: Renaming/moving files

- May appear as create + delete
- Need to detect rename operations

## 6. Rollout

**Owner**: repo-maintainers  
**Implementation**: ~1 hour (update assistant-behavior.mdc, test blocking)  
**Validation**: 1 week monitoring  
**Target**: 2025-10-24 implementation, 2025-10-31 validation complete

**Deployment strategy**:

1. Update assistant-behavior.mdc with blocking enforcement
2. Test 5 scenarios (create without test, test first, batch, edit with tests, edit without tests)
3. Deploy if all tests pass
4. Monitor for 1 week
5. Adjust exemptions based on false positives

---

**Evidence**: Gap #22 + 11 prior violations → 12 total, 5 with alwaysApply, 3 with visible gates  
**Confidence**: Very High (95%+) — root cause identified, solution designed, ready to implement  
**Impact**: Eliminates TDD violations through mechanical prevention (not advisory guidance)

Owner: repo-maintainers  
Created: 2025-10-24
