## Tasks — Rules Enforcement & Effectiveness Investigation

**Status**: Primary objective COMPLETE ✅ | Optional follow-ups DEFERRED ⏸️

---

## Acceptance Criteria Tracking

### Phase 5: Test Plan Development - ✅ COMPLETE

- [x] Documented violations with context (discovery.md Part 1-2)
- [x] Analyzed 15+ rules for enforcement patterns (discovery.md Part 1-3)
- [x] Analyzed taskmaster/spec-kit patterns (discovery.md Part 5)
- [x] Proposed structural changes with rationale (discovery.md Part 6-8)
- [x] Created comprehensive test plans (tests/)
- [x] Created measurement framework design
- [x] Documented success criteria, timelines, risk mitigation

### Phase 6: Test Execution - ✅ PRIMARY OBJECTIVES COMPLETE

- [x] Built measurement framework (4 checkers + dashboard, all tests passing)
- [x] Established baseline metrics (71% script, 72% TDD, 62% branch, 68% overall)
- [x] Tested Hypothesis 0 (self-improve meta-test) - CONFIRMED
- [x] Confirmed Hypothesis 1 (conditional attachment) - ROOT CAUSE
- [x] Applied primary fix (git-usage → alwaysApply: true) - validated
- [x] Measured baseline with actual data
- [x] Documented comprehensive findings (9 core docs + 7 test plans)

**Optional tests deferred**:

- [ ] Hypothesis 2 (send gate enforcement)
- [ ] Hypothesis 3 (query visibility)
- [ ] Slash commands experiment

### Final Deliverables - ✅ ALL COMPLETE

- [x] Summary documents (README.md, findings.md)
- [x] Quantitative results (BASELINE-REPORT.md)
- [x] Recommendations (findings.md, discovery.md Part 11)
- [x] Measurement tools (4 checkers + dashboard, CI-ready)
- [x] Fix validated (rules-validate.sh passed)
- [x] Document consolidation (15 docs → 6, 60% reduction)

---

## Phase 1: Baseline Documentation

- [x] 1.0 Document recent rule violations
  - [x] 1.1 Catalog violations from 2025-10-11 session
  - [x] 1.2 Note rule status and expected vs actual behavior
  - [x] 1.3 Identify pattern
  - [x] 1.4 Create comprehensive discovery document

## Phase 2: Test Plans & Execution

- [x] 2.0 Create detailed test plans for all hypotheses

  - [x] 2.1 Hypothesis 1 (Conditional Attachment)
  - [x] 2.2 Hypothesis 2 (Send Gate Enforcement)
  - [x] 2.3 Hypothesis 3 (Query Protocol Visibility)
  - [x] 2.4 Slash Commands Experiment
  - [x] 2.5 Measurement Framework plan
  - [x] 2.6 Test plans index
  - [x] 2.7 Hypothesis 0 (Self-Improve Meta-Test)

- [x] 2.8 Execute primary tests
  - [x] 2.8.1 Execute Hypothesis 0
  - [x] 2.8.2 Confirm Hypothesis 1 via meta-test
  - [x] 2.8.3 Build measurement framework and establish baseline
  - [x] 2.8.4 Apply primary fix (git-usage → alwaysApply: true)
  - [x] 2.8.5 Create test-plan-template.mdc

## Phase 3: External Pattern Analysis

- [x] 3.0 Analyze external patterns
  - [x] 3.1 Review taskmaster patterns
  - [x] 3.2 Review spec-kit patterns
  - [x] 3.3 Comparative analysis
  - [x] 3.4 Document hypothesis

## Phase 4: Measurement & Validation

- [x] 4.0 Create compliance measurement tools

  - [x] 4.1 Build check-script-usage.sh
  - [x] 4.2 Build check-tdd-compliance.sh
  - [x] 4.3 Build check-branch-names.sh
  - [x] 4.4 Build compliance-dashboard.sh
  - [x] 4.5 TDD-test all scripts
  - [x] 4.6 Establish baseline metrics

- [x] 5.0 Identify structural improvements
  - [x] 5.1 Make high-risk rules always-apply
  - [x] 5.2 Add visible query execution
  - [x] 5.3 Slash command gating
  - [x] 5.4 Pre-send gate self-check
  - [x] 5.5 Measurement hooks

## Phase 5: Implementation

- [x] 6.0 Implement primary fix

  - [x] 6.1 Change assistant-git-usage.mdc to alwaysApply: true
  - [x] 6.2 Update lastReviewed date
  - [x] 6.3 Run rules-validate.sh
  - [x] 6.4 Document fix rationale

- [x] 7.0 Create artifacts

  - [x] 7.1 Create test-plan-template.mdc
  - [x] 7.2 Create project documents
  - [x] 7.3 Create measurement scripts with tests
  - [x] 7.4 Update ERD

- [x] 8.0 Document consolidation
  - [x] 8.1 Remove duplicative documents (6 files)
  - [x] 8.2 Update remaining docs
  - [x] 8.3 Improve context health (2/5 → 4/5)

## Optional Enhancements (Deferred)

- [ ] 9.0 Hypothesis 2: Send Gate Enforcement

  - [ ] 9.1 Test gate visibility (20 trials)
  - [ ] 9.2 Test gate accuracy (10 violations)
  - [ ] 9.3 Test gate blocking behavior
  - [ ] 9.4 Add visible gate output if needed

- [ ] 10.0 Hypothesis 3: Query Protocol Visibility

  - [ ] 10.1 Baseline query visibility (20 trials)
  - [ ] 10.2 Add visible capabilities check output
  - [ ] 10.3 Post-change test (20 trials)
  - [ ] 10.4 Compare improvement

- [ ] 11.0 Slash Commands Experiment

  - [ ] 11.1 Design commands
  - [ ] 11.2 Test with vs without
  - [ ] 11.3 Measure routing accuracy
  - [ ] 11.4 Test user comprehension

- [ ] 12.0 Monitor git-usage improvement

  - [ ] 12.1 Measure script usage after 20-30 commits
  - [ ] 12.2 Validate fix effectiveness

- [ ] 13.0 Audit other conditional rules
  - [ ] 13.1 List all alwaysApply: false rules
  - [ ] 13.2 Categorize by risk
  - [ ] 13.3 Change high-risk to always-apply
  - [ ] 13.4 Document changes
