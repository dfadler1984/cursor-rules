# Tasks: Self-Improvement Pivot

**Project:** `self-improvement-pivot`  
**ERD:** [erd.md](./erd.md)  
**Status:** Deferred (activate only if pivot trigger fires)  

---

## Activation Conditions

This project is **deferred** until one of the following pivot triggers fires during Phase 4 monitoring of the parent project:

1. **Latency overhead:** Pattern observation adds >200ms per turn (over 10 turns)
2. **False positive rate:** >50% of proposals rejected (over 10 proposals)
3. **Context bloat:** Observation state >10% of token budget (per turn)
4. **User distraction:** Qualitative feedback reports proposals are problematic

**Once activated, proceed with tasks below based on which trigger fired.**

---

## Pre-Implementation (All Alternatives)

- [ ] **Confirm pivot trigger**

  - [ ] Document which trigger(s) fired
  - [ ] Paste measurement data (latency, false positive rate, context cost, or user feedback)
  - [ ] Confirm with stakeholder: proceed with pivot?

- [ ] **Select alternative approach**

  - [ ] Review comparison matrix in ERD
  - [ ] Choose recommended alternative based on trigger type:
    - Latency → Checkpoint-Gated
    - False Positives → Manual-Invoke
    - Context Bloat → Hybrid
    - User Distraction → Batch Mode
  - [ ] Document choice and rationale

- [ ] **Baseline metrics**
  - [ ] Record current latency, false positive rate, context cost, user feedback
  - [ ] Save as baseline for comparing post-pivot performance

---

## Alternative 1: Manual-Invoke Only

**Activate if:** False positive rate >50% or user distraction reported.

### Implementation

- [ ] **Modify `assistant-behavior.mdc`**

  - [ ] Remove "Pattern observation (always-on)" section
  - [ ] Keep "Rule improvement proposals (consent-gated)" section
  - [ ] Add "Manual pattern analysis" section describing `/rule-improve` command

- [ ] **Modify `self-improve.mdc`**

  - [ ] Change `alwaysApply: true` to `alwaysApply: false`
  - [ ] Add trigger: `/rule-improve [paths]` slash command
  - [ ] Document scan behavior (full codebase or specified paths)

- [ ] **Extend `intent-routing.mdc`**
  - [ ] Add `/rule-improve` to slash commands section
  - [ ] Route to `self-improve.mdc` on invocation

### Validation

- [ ] Test: `/rule-improve` scans entire codebase, surfaces all patterns (no threshold)
- [ ] Test: `/rule-improve src/cli` scans only `src/cli/`, surfaces patterns in that path
- [ ] Test: Proposals include file paths and pattern examples
- [ ] Test: User can approve/reject each proposal individually
- [ ] Test: No pattern detection during normal work (only on manual invoke)

### Post-Pivot Metrics

- [ ] Measure latency over 10 turns (expect: baseline or lower)
- [ ] Measure false positive rate over 10 proposals (expect: 0%, since user explicitly requests)
- [ ] Measure context cost per turn (expect: 0%, since no observation state)
- [ ] Collect user feedback (expect: no distraction, but may forget to invoke)

---

## Alternative 2: Checkpoint-Gated Observation

**Activate if:** Latency overhead >200ms per turn.

### Implementation

- [ ] **Modify `assistant-behavior.mdc`**

  - [ ] Change "Pattern observation (always-on)" to "Pattern observation (checkpoint-gated)"
  - [ ] Add checkpoint detection logic: scan changed files only at Green, PR created, task complete

- [ ] **Modify `self-improve.mdc`**
  - [ ] Add checkpoint detection (detect Green, PR created, task complete)
  - [ ] Limit scan to files changed since last checkpoint
  - [ ] Keep 3+ file threshold and session-scoped suppression

### Validation

- [ ] Test: No scanning during normal work (confirm zero latency overhead between checkpoints)
- [ ] Test: Change 4 files, reach Green checkpoint → verify proposal surfaces with correct evidence
- [ ] Test: Change 2 files, reach checkpoint → verify no proposal (below threshold)
- [ ] Test: Latency overhead per checkpoint scan <100ms

### Post-Pivot Metrics

- [ ] Measure latency over 10 turns (expect: baseline; overhead only at checkpoints)
- [ ] Measure latency per checkpoint scan over 10 checkpoints (expect: <100ms)
- [ ] Measure false positive rate over 10 proposals (expect: lower than baseline, since only changed files)
- [ ] Measure context cost per turn (expect: lower than baseline, since state only exists during scan)

---

## Alternative 3: Hybrid (High-Signal Always-On, Manual for Rest)

**Activate if:** Context bloat >10% of token budget or latency + false positives both exceed thresholds.

### Implementation

- [ ] **Define high-signal pattern taxonomy**

  - [ ] Error patterns: same bug fixed 3+ times
  - [ ] Security patterns: auth/crypto used inconsistently in 3+ files
  - [ ] Performance patterns: same perf fix applied 3+ times
  - [ ] Document taxonomy in `self-improve.mdc`

- [ ] **Modify `assistant-behavior.mdc`**

  - [ ] Split into "High-signal pattern observation (always-on)" and "Low-priority pattern analysis (manual-invoke)"
  - [ ] High-signal: surface at checkpoints
  - [ ] Low-priority: require `/rule-improve --low-priority`

- [ ] **Modify `self-improve.mdc`**

  - [ ] Add high-signal detection logic (filter by taxonomy)
  - [ ] Add `/rule-improve --low-priority` for manual scans (style, library, naming)

- [ ] **Extend `intent-routing.mdc`**
  - [ ] Add `/rule-improve --low-priority` to slash commands

### Validation

- [ ] Test: Introduce error pattern in 4 files → verify always-on proposal at checkpoint
- [ ] Test: Introduce code style pattern in 4 files → verify no always-on proposal
- [ ] Test: `/rule-improve --low-priority` detects code style pattern
- [ ] Test: Context cost <5% of token budget (high-signal patterns only)

### Post-Pivot Metrics

- [ ] Measure latency over 10 turns (expect: lower than baseline, since only high-signal tracked)
- [ ] Measure context cost per turn (expect: <5%, since only high-signal patterns)
- [ ] Measure false positive rate for high-signal proposals (expect: lower than baseline)
- [ ] Collect user feedback on taxonomy (clear vs confusing? useful vs too restrictive?)

---

## Alternative 4: Batch Mode (Weekly/Monthly Review Sessions)

**Activate if:** User distraction reported or latency + false positives + context bloat all problematic.

### Implementation

- [ ] **Modify `assistant-behavior.mdc`**

  - [ ] Remove "Pattern observation (always-on)" section
  - [ ] Add "Rule review sessions (scheduled)" section
  - [ ] Document `/rule-review-session` command and workflow

- [ ] **Modify `self-improve.mdc`**

  - [ ] Change `alwaysApply: true` to `alwaysApply: false`
  - [ ] Add batch scan mode: scan entire codebase, no threshold, priority ranking
  - [ ] Document session workflow (scan → surface → approve/reject/defer → summarize)

- [ ] **Extend `intent-routing.mdc`**
  - [ ] Add `/rule-review-session` to slash commands

### Validation

- [ ] Test: No pattern detection during normal work (confirm zero overhead)
- [ ] Test: `/rule-review-session` scans entire codebase, surfaces all patterns (no threshold)
- [ ] Test: Session ranks patterns by priority (errors > security > style)
- [ ] Test: User can approve/reject/defer each pattern
- [ ] Test: Session summarizes approved updates at end (e.g., "3 rules added, 2 updated, 4 deferred")

### Post-Pivot Metrics

- [ ] Measure latency over 10 turns outside sessions (expect: baseline, zero overhead)
- [ ] Measure false positive rate during session (expect: 0%, since user reviews all)
- [ ] Measure context cost outside sessions (expect: 0%, no observation state)
- [ ] Collect user feedback (useful? overwhelming? good session cadence?)

---

## Rollback (If Pivot Fails)

**Activate if:** Post-pivot metrics are worse than baseline, or user feedback is negative.

- [ ] **Compare metrics**

  - [ ] Post-pivot latency vs baseline
  - [ ] Post-pivot false positive rate vs baseline
  - [ ] Post-pivot context cost vs baseline
  - [ ] Post-pivot user feedback vs baseline feedback

- [ ] **Decide: rollback or try next alternative**

  - [ ] If post-pivot is worse: rollback to always-on
  - [ ] If post-pivot is better but still problematic: try next alternative from comparison matrix
  - [ ] If all alternatives tried and all worse: rollback to always-on with refined thresholds (e.g., 4+ files)

- [ ] **Rollback steps**

  - [ ] Revert `assistant-behavior.mdc` to always-on version
  - [ ] Revert `self-improve.mdc` to always-on version
  - [ ] Revert `intent-routing.mdc` if slash commands were added
  - [ ] Run `.cursor/scripts/rules-validate.sh` to confirm rollback succeeded

- [ ] **Document lessons learned**
  - [ ] Update this ERD with why alternative failed
  - [ ] Document refined thresholds or taxonomy if applicable
  - [ ] Propose out-of-scope improvements (cross-session persistence, A/B testing) if all alternatives exhausted

---

## Carryovers

- A/B testing framework (deferred; single-track pivot for MVP)
- User preference settings (deferred; single canonical mode for MVP)
- Gradual rollout (deferred; full pivot or rollback for MVP)
- Cross-session pattern persistence (remains out of scope for all alternatives)

---

## Notes

- This project remains **deferred** until a pivot trigger fires
- Only implement tasks for the selected alternative (not all alternatives at once)
- If first alternative fails, try next recommended alternative before rollback
- Document all measurements and decisions in this file for traceability
