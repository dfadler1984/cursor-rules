# Tasks — Blocking TDD Enforcement

**Status**: ACTIVE  
**Phase**: Phase 2 (Validation Testing)  
**Completion**: 25% (Phase 1 complete)

---

## Phase 1: Implementation ✅ COMPLETE (~1 hour)

### 1.0 Update assistant-behavior.mdc with blocking TDD enforcement ✅

- [x] 1.1 Line 354: Change "editing" → "creating or editing" (scope expansion) ✅
- [x] 1.2 Lines 290-291: Update pre-send gate TDD check to cover file creation ✅
  - ✅ Changed: "spec updated? (if impl edits)" → "test file exists? (if creating/editing impl sources)"
  - ✅ Expanded scope to cover file creation AND editing
- [x] 1.3 Lines 311-320: Replaced TDD gate with detailed file pairing requirements ✅
  - ✅ Added file patterns: `*.sh` → `*.test.sh`, `*.ts` → `*.test.ts|*.spec.ts`, `*.tsx` → `*.test.tsx|*.spec.tsx`
  - ✅ Added exemptions: `*.mdc`, `*.md`, `.lib*.sh`, `*.test.*`, `*.spec.*`, `*.config.*`
  - ✅ Added batch detection: "must exist or be in same batch"
  - ✅ Removed escape hatch "or explicit blocker stated"
  - ✅ Made test requirement absolute
  - ✅ Specified FAIL action: DO NOT SEND MESSAGE
  - ✅ Added error template with file name and expected test file
- [x] 1.4 Lines 343-350: Added file pairing enforcement note ✅
  - ✅ Documented Gap #22 fix and validation
  - ✅ Explained scope expansion (creating + editing)
  - ✅ Noted escape hatch removal
  - ✅ Referenced pattern (Gaps #18, #22)

**Deliverable**: ✅ Updated assistant-behavior.mdc with blocking TDD enforcement (deployed 2025-10-24)

---

## Phase 2: Validation Testing 🔄 IN PROGRESS

**Testing Paradox**: Assistant cannot self-test blocking gates (see `phase2-testing-paradox.md`)

**Solution**: User manual testing + ongoing monitoring

**Gap #23 Evidence** (2025-10-24): Modified project-archive-ready.sh without updating tests first - blocking gate didn't catch it because it only checks file existence, not temporal ordering or modification tracking. See `phase2-gap23-evidence.md`.

### 2.0 Test blocking behavior with 6 scenarios (USER-EXECUTED)

**Approach**: User requests scenarios, observes whether gate blocks or allows

- [ ] 2.1 **Test 1**: User requests creating source without test (expect: FAIL)

  - User: "Create `.cursor/scripts/test-blocking.sh` that prints hello"
  - Expected: Pre-send gate FAILS, message blocked
  - Expected: Error: "Cannot create test-blocking.sh without test file. Create test-blocking.test.sh first"

- [ ] 2.2 **Test 2**: User requests creating test first (expect: PASS)

  - User: "Create `.cursor/scripts/test-blocking.test.sh` with failing assertion"
  - Expected: Pre-send gate PASSES (test file allowed)
  - Then: "Create test-blocking.sh" should PASS (test exists)

- [ ] 2.3 **Test 3**: User requests both in same message (expect: PASS)

  - User: "Create test-blocking.test.sh AND test-blocking.sh together"
  - Expected: Pre-send gate PASSES (both in same batch)

- [ ] 2.4 **Test 4**: Edit existing file with tests (expect: PASS)

  - User: "Edit `.cursor/scripts/rules-list.sh`"
  - Expected: Pre-send gate PASSES (rules-list.test.sh exists)

- [ ] 2.5 **Test 5**: Edit existing file without tests (expect: FAIL)
  - User: "Edit source file lacking tests"
  - Expected: Pre-send gate FAILS, test creation required

- [x] 2.6 **Test 6**: Modify existing file with tests but don't update test first (ACTUAL: Gap #23)
  - Actual: Modified project-archive-ready.sh without updating test first
  - Gate behavior: **PASSED** (test file existed)
  - Expected: Should FAIL (test not modified first)
  - **Result**: **Gate gap identified** - checks existence, not temporal ordering
  - Evidence: See `phase2-gap23-evidence.md`

**Deliverable**: User observation results + behavioral evidence + Gap #23 real-world validation

**Note**: Cannot self-test; requires external validation (user or monitoring)

**Phase 2 Finding**: Current gate has second gap (temporal ordering) - see Gap #23 evidence

---

## Phase 3: Monitoring & Adjustment (1 week)

### 3.0 Monitor TDD enforcement effectiveness

- [ ] 3.1 Track file creation operations (target: ≥20 for significance)
- [ ] 3.2 Count TDD violations (target: 0)
- [ ] 3.3 Count false positives (target: <1%)
- [ ] 3.4 Verify legitimate workflows unblocked (target: 100%)
- [ ] 3.5 Collect user feedback on error messages
- [ ] 3.6 Adjust exemptions if false positives found

**Deliverable**: Monitoring report with metrics vs targets

---

## Phase 4: Documentation & Completion (~30 min)

### 4.0 Document results and complete project

- [ ] 4.1 Create final-summary.md with results
- [ ] 4.2 Document any exemption adjustments made
- [ ] 4.3 Update rules-enforcement-investigation with Gap #22 resolution
- [ ] 4.4 Add to ACTIVE-MONITORING.md if ongoing monitoring needed

**Deliverable**: Final summary, project completion

---

## Success Metrics

| Metric              | Target | Measurement Method                       |
| ------------------- | ------ | ---------------------------------------- |
| TDD Violations      | 0      | Count violations over 1 week             |
| False Positives     | <1%    | Count legitimate files blocked / total   |
| True Positives      | 100%   | Count violations caught / total attempts |
| Workflow Disruption | None   | User feedback, workflow completion rate  |

---

## Dependencies

**Blocks**:

- Completing rules-enforcement-investigation Phase 6G (Gap #22 is blocker)
- Any future shell script or TypeScript development (will enforce TDD)

**Blocked by**:

- None (can implement immediately)

---

## Related Files

- `.cursor/rules/assistant-behavior.mdc` — Implementation target
- `.cursor/rules/tdd-first.mdc` — TDD scope and process
- `docs/projects/rules-enforcement-investigation/findings/gap-22-*.md` — Evidence and analysis
- `docs/projects/ACTIVE-MONITORING.md` — Monitoring guidance
