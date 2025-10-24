# Tasks: Self-Improvement Rule Adoption

**Project:** `self-improvement-rule-adoption`  
**ERD:** [erd.md](./erd.md)  
**Status:** Phase 1 Complete — Ready for Behavior Validation

---

## Phase 1: Rule Integration

### Core Rule Modifications

- [x] **Modify `assistant-behavior.mdc`**

  - [x] Add "Pattern observation (always-on)" section after "Status transparency"
  - [x] Add "Rule improvement proposals (consent-gated)" section
  - [x] Update "Compliance-first send gate" to include pattern observation check
  - [x] Add checkpoint definitions (after Green, PR created, task complete, "anything else?")
  - [x] Document session-scoped suppression for rejected proposals

- [x] **Extend `rule-maintenance.mdc`**

  - [x] Add "Pattern-driven updates" section
  - [x] Document 3+ file threshold for pattern detection
  - [x] Add proposal workflow (collect → surface → approve → update)
  - [x] Include examples of high-signal patterns (repeated implementations, common errors)

- [x] **Extend `rule-creation.mdc`**

  - [x] Add "Evidence-based rule creation" section
  - [x] Require ≥3 instances of pattern for proposals
  - [x] Mandate real file path citations in examples
  - [x] Add proposal template (Pattern → Evidence → Change → Impact)

- [x] **Extend `rule-quality.mdc`**

  - [x] Add checklist: "Examples cite real file paths from codebase"
  - [x] Add checklist: "Rule triggered by ≥3 instances (if pattern-based)"
  - [x] Add checklist: "Deprecation path documented if replacing old pattern"

- [x] **Create `self-improve.mdc`**
  - [x] Adapt taskmaster rule content
  - [x] Mark `alwaysApply: true` in front matter
  - [x] Add consent-first modifications (observation passive, action consent-gated)
  - [x] Include repo-specific examples (yargs CLI pattern, TDD cycle boundaries)
  - [x] Document natural checkpoints explicitly

### Validation

- [x] Run `.cursor/scripts/rules-validate.sh` on all modified rules
- [x] Run `.cursor/scripts/rules-validate.sh --fail-on-missing-refs`
- [x] Verify front matter health scores ≥8 for all modified rules
- [x] Check cross-references between rules are valid

---

## Phase 2: Behavior Validation

### Non-Intrusive Observation

- [ ] **Test: Silent pattern detection**
  - [ ] Complete 3 unrelated tasks (e.g., add feature, fix bug, refactor)
  - [ ] Verify no pattern proposals interrupt mid-task
  - [ ] Verify no unsolicited tool calls or file writes during observation

### High-Signal Proposals

- [ ] **Test: 3+ file threshold**

  - [ ] Introduce identical pattern in 4 test files (e.g., same error handling)
  - [ ] Complete task and reach checkpoint
  - [ ] Verify proposal surfaces with correct evidence (file paths listed)

- [ ] **Test: Below-threshold silence**
  - [ ] Introduce pattern in only 2 files
  - [ ] Complete task and reach checkpoint
  - [ ] Verify no proposal surfaces (below 3-file threshold)

### Consent-Gated Action

- [ ] **Test: Rejection suppression**

  - [ ] Trigger proposal with 3+ file pattern
  - [ ] Respond "No" or "Skip"
  - [ ] Introduce same pattern in additional file (now 5+ instances)
  - [ ] Verify proposal does not re-appear in same session

- [ ] **Test: Approval flow**
  - [ ] Trigger proposal with 3+ file pattern
  - [ ] Respond "Yes" or "Proceed"
  - [ ] Verify rule update created with evidence citations
  - [ ] Verify updated rule passes validation

### Checkpoint Detection

- [ ] **Test: TDD cycle boundary**

  - [ ] Introduce pattern during Red phase (failing test)
  - [ ] Proceed to Green phase (test passing)
  - [ ] Verify proposal surfaces after Green, not during Red

- [ ] **Test: PR creation checkpoint**

  - [ ] Introduce pattern in branch
  - [ ] Run `.cursor/scripts/pr-create.sh`
  - [ ] Verify proposal surfaces after PR created

- [ ] **Test: Task completion checkpoint**

  - [ ] Mark task complete via `todo_write`
  - [ ] Verify proposal surfaces after status update

- [ ] **Test: Mid-task suppression**
  - [ ] Introduce pattern during file edit
  - [ ] Continue editing without reaching checkpoint
  - [ ] Verify no proposal interrupt

### Proposal Format

- [ ] **Test: Required fields**
  - [ ] Trigger any proposal
  - [ ] Verify includes: Pattern (one line), Evidence (file paths), Proposed change, Impact
  - [ ] Verify evidence cites actual file paths from codebase

---

## Phase 3: Pivot Project Setup

- [ ] **Create pivot project ERD**

  - [ ] Create `docs/projects/self-improvement-pivot/erd.md`
  - [ ] Document alternative approaches (manual-invoke, checkpoint-gated, hybrid, batch)
  - [ ] Define pivot triggers (latency, false positives, context bloat, user feedback)
  - [ ] Link back to this project

- [ ] **Create pivot project tasks**
  - [ ] Create `docs/projects/self-improvement-pivot/tasks.md`
  - [ ] Add tasks for each alternative approach
  - [ ] Mark as deferred until pivot trigger fires

---

## Phase 4: Monitoring & Iteration

### Metrics Collection

- [ ] **Proposal acceptance rate**

  - [ ] Track proposals over 10 tasks
  - [ ] Calculate acceptance rate (target: >50%)
  - [ ] Document reasons for rejections

- [ ] **Observation overhead**

  - [ ] Measure assistant response time across 10 turns with pattern observation
  - [ ] Compare to baseline (10 turns without observation)
  - [ ] Verify overhead <100ms per turn (target: <100ms)

- [ ] **False positive rate**
  - [ ] Track rejected proposals vs accepted proposals
  - [ ] Calculate false positive rate (target: <50%)
  - [ ] Adjust 3+ file threshold if needed

### User Feedback

- [ ] Collect qualitative feedback on proposal timing (good checkpoints vs interruptions)
- [ ] Collect feedback on proposal relevance (useful patterns vs noise)
- [ ] Collect feedback on proposal format (clear vs confusing)

### Iteration

- [ ] If acceptance rate <50%, increase threshold to 4+ files
- [ ] If observation overhead >200ms, activate pivot project (checkpoint-gated approach)
- [ ] If false positives >50%, refine pattern detection criteria
- [ ] If user reports distraction, activate pivot project (manual-invoke approach)

---

## Carryovers

- Integration with code review comments (out of scope for MVP)
- Cross-session pattern persistence (deferred; session-scoped for now)
- Batch proposals (>3 patterns at once; deferred until single-proposal flow validated)
- Function-level pattern detection (file-level only for MVP)

---

## Notes

- All tests in Phase 2 should be performed in a live assistant session
- Document test results in this file or linked experiment files
- If any Phase 2 test fails, pause and investigate before proceeding to Phase 3
- Pivot triggers in Phase 4 are non-blocking; project continues unless trigger fires
