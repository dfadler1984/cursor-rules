## Tasks — Rules Enforcement & Effectiveness Investigation

**Status**: ACTIVE — MONITORING | Phase: 6A (Validate H1 Fix) | ~40% Complete

**Update**: Discovery, Review, and Rule Improvements complete! H1 fix applied; awaiting 20-30 commits for validation. H2, H3, slash commands ready to execute. All 6 rule improvements applied to project-lifecycle.mdc, create-erd.mdc, generate-tasks-from-erd.mdc, and self-improve.mdc.

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

### Phase 6A: Validate H1 Fix - ⏳ IN PROGRESS

- [x] Built measurement framework (4 checkers + dashboard, all tests passing)
- [x] Established baseline metrics (71% script, 72% TDD, 62% branch, 68% overall)
- [x] Tested Hypothesis 0 (self-improve meta-test) - CONFIRMED
- [x] Confirmed Hypothesis 1 (conditional attachment) - ROOT CAUSE
- [x] Applied fix (git-usage → alwaysApply: true)
- [ ] **Validate fix with 20-30 commits of actual usage**
- [ ] **Measure improvement (target: 71% → >90%)**
- [ ] **Confirm no regression in other areas**

### Phase 6B: Core Enforcement Mechanisms - ⏸️ NOT STARTED

**These are NOT optional — they answer fundamental research questions**:

- [ ] Execute Hypothesis 2 (send gate enforcement)
  - [ ] Does pre-send gate execute?
  - [ ] Does it detect violations?
  - [ ] Does it BLOCK violations?
- [ ] Execute Hypothesis 3 (query visibility)
  - [ ] Is "check capabilities.mdc" executed?
  - [ ] Would visible output improve compliance?
- [ ] Document which enforcement patterns work and why

### Phase 6C: Scalable Patterns - ⏸️ NOT STARTED

**Critical for 25+ conditional rules**:

- [ ] Execute slash commands experiment
- [ ] Compare: alwaysApply vs slash commands vs improved intent routing
- [ ] Identify scalable patterns that don't require alwaysApply

### Phase 6D: Integration & Rule Improvements - ✅ RULE IMPROVEMENTS COMPLETE

- [ ] Synthesize findings into recommendations for all rule types — Pending H1 validation results
- [x] Complete 6 rule improvement tasks (see below) — ALL COMPLETE: Tasks 15.0-20.0 applied to 4 rule files
- [ ] Validate CI integration guide — Pending
- [ ] Create final summary with validated recommendations — Pending synthesis

---

## Discovery

Tasks to understand current behavior and plan remaining investigation work:

- [x] 0.1 Review and validate baseline metrics

  - [x] 0.1.1 Confirm 71% script usage baseline is accurate — Current: 74%, baseline validated
  - [x] 0.1.2 Confirm 72% TDD compliance baseline is accurate — Current: 75%, baseline validated
  - [x] 0.1.3 Confirm 62% branch naming baseline is accurate — Current: 61%, baseline validated
  - [x] 0.1.4 Document any measurement gaps or issues — No gaps identified; metrics stable

- [x] 0.2 Analyze enforcement patterns in 25 conditional rules

  - [x] 0.2.1 List all `alwaysApply: false` rules with descriptions — See conditional-rules-analysis.md
  - [x] 0.2.2 Categorize by risk level (critical/high/medium/low) — 1 critical (fixed), 5 high, 7 medium, 12 low
  - [x] 0.2.3 Identify which rules have violations in git history — 6 confirmed/suspected violations documented
  - [x] 0.2.4 Group rules by similar enforcement needs — 5 enforcement pattern groups identified

- [x] 0.3 Pre-test discovery for H2 (send gate)

  - [x] 0.3.1 Review assistant-behavior.mdc send gate implementation — 7 checklist items, "revise; do not send" policy
  - [x] 0.3.2 Identify observable signals if gate is executed — Explicit (gate output) and implicit (compliance patterns)
  - [x] 0.3.3 List specific violations to test (from discovery.md) — Script (26%), TDD (25%), Branch (39%), Consent (anecdotal)
  - [x] 0.3.4 Design violation scenarios for test — 20 Test A scenarios, 10 Test B violations, Test C/D protocols defined

- [x] 0.4 Pre-test discovery for H3 (query visibility)

  - [x] 0.4.1 Review assistant-git-usage.mdc query protocol — 3-step protocol: Query → Use script → Fallback
  - [x] 0.4.2 Search recent git history for query evidence — No direct evidence; scripts used but query not visible
  - [x] 0.4.3 Identify what visible output would look like — Minimal format: "[Query] Checked capabilities.mdc for X: [result]"
  - [x] 0.4.4 Design baseline measurement approach — 20 git operations, search for query keywords, cross-tabulation

- [x] 0.5 Pre-test discovery for slash commands

  - [x] 0.5.1 Review taskmaster/spec-kit patterns from discovery.md — Explicit commands create forcing functions (vs implicit routing)
  - [x] 0.5.2 Identify which git operations to target first — 4 high-risk (commit/PR/branch/force-push), 2 medium, N low
  - [x] 0.5.3 Draft slash command rule structure — New `git-slash-commands.mdc` with 3-step enforcement protocol
  - [x] 0.5.4 Identify integration points with intent-routing — Highest priority (above exact phrases), direct routing

- [x] 0.6 Scalability analysis
  - [x] 0.6.1 Calculate context cost: 19 alwaysApply rules vs 44 total — Current: ~34k tokens; All always: ~67k (+97%)
  - [x] 0.6.2 Estimate context impact if all 25 conditional → alwaysApply — +33k tokens, practical concerns documented
  - [x] 0.6.3 Document why alwaysApply doesn't scale — Finite budget, linear cost, exponential complexity
  - [x] 0.6.4 Identify enforcement patterns that DO scale — 6 patterns: scripts, progressive, routing, linters, slash commands, constraints

## Review

Periodic review checkpoints to validate progress and findings:

- [x] R.1 Review Phase 5 deliverables (test plans)

  - [x] R.1.1 Validate test plans are complete and actionable — All 7 plans have complete sections, step-by-step procedures (9/10)
  - [x] R.1.2 Confirm success criteria are measurable — All have quantitative criteria with specific thresholds (10/10)
  - [x] R.1.3 Verify measurement protocols are well-defined — Data templates, analysis methods, reproducible (9/10)
  - [x] R.1.4 Check for gaps or missing scenarios — Minor gaps only; non-blocking; documented (8/10)

- [x] R.2 Review premature completion root causes

  - [x] R.2.1 Review findings.md "Why Was This Marked Complete?" section — 5 root causes identified (momentum, checklist, states, blind spots, self-improve)
  - [x] R.2.2 Identify what signals were missed — 5 signals: open tasks, unvalidated fix, scalability, core questions, no approval
  - [x] R.2.3 Document what would have prevented premature completion — 5 preventions: hard checklist, stages, validation period, weighting, real-time flagging
  - [x] R.2.4 Propose safeguards for future investigations — 9 recommendations for project-lifecycle/self-improve/tasks rules

- [ ] R.3 Mid-investigation review checkpoint (after 6B)

  - [ ] R.3.1 Review H1 validation results
  - [ ] R.3.2 Review H2 and H3 findings
  - [ ] R.3.3 Assess whether slash commands test is still needed
  - [ ] R.3.4 Update timeline and effort estimates

- [ ] R.4 Final review before declaring complete
  - [ ] R.4.1 All 4 phases (6A-6D) complete
  - [ ] R.4.2 All research questions answered
  - [ ] R.4.3 Scalable patterns documented for 25 conditional rules
  - [ ] R.4.4 6 rule improvements complete
  - [ ] R.4.5 Validation: compliance >90% measured over 20+ commits
  - [ ] R.4.6 User approval: explicit "this is complete" confirmation

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

## Phase 6A: Validate H1 Fix (Current — Passive Monitoring)

- [ ] 9.0 Monitor git-usage improvement over actual usage — AWAITING DATA (0/20-30 commits)

  - [ ] 9.1 Make 20-30 commits with git-usage alwaysApply: true — In progress (passive accumulation)
  - [ ] 9.2 Run: `bash .cursor/scripts/compliance-dashboard.sh --limit 25` after 25 new commits — Pending
  - [ ] 9.3 Measure improvement: baseline 74% → target >90% — Pending
  - [ ] 9.4 Document: did fix work as expected? — Pending
  - [ ] 9.5 If <90%: identify remaining gaps — Pending (see h1-validation-protocol.md)

## Phase 6B: Core Enforcement Mechanisms

- [ ] 10.0 Hypothesis 2: Send Gate Enforcement — Test D ACTIVE (monitoring visible gate effectiveness)

  - [x] 10.1 Test gate visibility (20 trials) — RETROSPECTIVE: 0% visibility (0/17 operations); gate silent or not executing
  - [x] 10.2 Test gate accuracy (10 violations) — SKIPPED: Can't test without visible output (per decision tree)
  - [x] 10.3 Test gate blocking behavior — SKIPPED: Can't test without visible detection (per decision tree)
  - [ ] 10.4 Test D: Visible gate experiment — ACTIVE: Modified assistant-behavior.mdc; Checkpoint 1 ✅ (100% visibility confirmed)
  - [ ] 10.5 Test D checkpoints — Checkpoint 1: ✅ (1/1 visible); Checkpoint 2: pending (after 5 responses); Checkpoint 3: pending (after 10)
  - [ ] 10.6 Document findings: Does visible gate work? — PRELIMINARY: Yes! 0% → 100% visibility via explicit OUTPUT requirement
  - [ ] 10.7 Measure compliance improvement — Pending more data (need git operations, terminal commands to test all gate items)

- [ ] 11.0 Hypothesis 3: Query Protocol Visibility

  - [ ] 11.1 Baseline query visibility (20 trials) — see tests/hypothesis-3-query-protocol-visibility.md
  - [ ] 11.2 Test: is query executed at all?
  - [ ] 11.3 Implement: add visible capabilities check output
  - [ ] 11.4 Post-change test (20 trials)
  - [ ] 11.5 Compare improvement and document findings

## Phase 6C: Scalable Patterns

- [ ] 12.0 Slash Commands Experiment

  - [ ] 12.1 Implement slash command rule — see tests/experiment-slash-commands.md
  - [ ] 12.2 Phase 1: Baseline with intent routing (50 trials)
  - [ ] 12.3 Phase 2: Test with slash commands (50 trials)
  - [ ] 12.4 Measure routing accuracy improvement
  - [ ] 12.5 Document: Can this scale to 25 conditional rules?

- [ ] 13.0 Compare Enforcement Approaches

  - [ ] 13.1 Synthesize results from H1, H2, H3, slash commands
  - [ ] 13.2 Create decision tree: when to use each approach
  - [ ] 13.3 Document scalable patterns for conditional rules
  - [ ] 13.4 Identify which 25 rules benefit from each pattern

## Phase 6D: Integration & Rule Improvements

- [ ] 14.0 Apply Learnings to Conditional Rules
  - [ ] 14.1 List all alwaysApply: false rules (25 total)
  - [ ] 14.2 Categorize by enforcement pattern needed
  - [ ] 14.3 Apply appropriate pattern to each
  - [ ] 14.4 Validate improvements

---

## Rule Improvements from Investigation Meta-Findings

**Source**: [`findings.md`](findings.md) lines 96-155

**Status**: These are REQUIRED deliverables, not optional carryovers. They are substantive findings from the investigation.

- [x] 15.0 Fix project-lifecycle.mdc completion state ambiguity

  - [x] 15.1 Add "Complete (Active)" state definition (complete but not archived, with follow-ups) — Added with clear when to stay vs archive guidance
  - [x] 15.2 Clarify when to archive vs keep active — 4 criteria for each documented
  - [x] 15.3 Update completion checklist in rule — Added Pre-Closure Checklist (Hard Gates) with 8 mandatory items
  - [x] 15.4 Evidence: This project is complete but has open follow-ups — Plus added 7 explicit lifecycle stages and validation periods section

- [x] 16.0 Update task document structure guidance

  - [x] 16.1 Update project-lifecycle.mdc: tasks.md = phase sections with checklists only — Added strict structure section with must include/exclude lists
  - [x] 16.2 Update generate-tasks-from-erd.mdc: clarify no findings/questions in tasks.md — Added "What NOT to Include" section with 5 prohibited content types
  - [x] 16.3 Evidence: tasks.md accumulated 152 lines of non-task content — Cited in both rules with examples

- [x] 17.0 Clarify ERD vs tasks separation for acceptance criteria

  - [x] 17.1 Update project-lifecycle.mdc: ERD describes criteria as narrative, tasks.md contains checklists — Added "ERD vs tasks.md: Acceptance Criteria" section with examples
  - [x] 17.2 Update create-erd.mdc: acceptance criteria are requirements, not execution checklists — Added "Acceptance Criteria Format" section with do/don't examples
  - [x] 17.3 Update generate-tasks-from-erd.mdc: convert ERD acceptance criteria to task checklists — Added "Converting ERD Acceptance Criteria to Tasks" section with transformation example
  - [x] 17.4 Evidence: ERD section 5 had checklists (should be in tasks.md) — Cited with correct vs incorrect examples

- [x] 18.0 Define ERD scope clearly

  - [x] 18.1 Update create-erd.mdc: ERD = requirements/approach only — Added "ERD Scope Definition" section at top of rule
  - [x] 18.2 Add guidance: findings/retrospective go in separate findings.md — Listed in "What ERDs Do NOT Contain" with rationale
  - [x] 18.3 Add guidance: detailed timeline belongs in tasks.md, not ERD section 10 — Example of scope creep to avoid; correct separation documented
  - [x] 18.4 Evidence: ERD section 11 (73 lines) contained findings, not requirements — Cited with 441-line ERD bloat example

- [x] 19.0 Add guidance on summary document proliferation

  - [x] 19.1 Update project-lifecycle.mdc: README.md = single entry point — Added "README.md as Single Entry Point" section with structure template
  - [x] 19.2 Add guidance: avoid multiple summary documents unless distinct audiences require it — Single Entry Point Policy with justified vs unjustified criteria
  - [x] 19.3 Add guidance: specialized summaries need clear justification — Must articulate "Summary X for audience Y who needs Z"
  - [x] 19.4 Evidence: Created 3 summary docs with 70-80% overlap — Cited as evidence of proliferation with correct approach example

- [x] 20.0 Strengthen self-improvement pattern detection
  - [x] 20.1 Update self-improve.mdc: during rule investigations, treat observed issues as first-class data — Added "Special Case: Rule Investigations" section
  - [x] 20.2 Add guidance: flag rule gaps proactively during active investigations — "Notice gap → Document immediately" with do/don't examples
  - [x] 20.3 Evidence: Project-lifecycle gap noticed but not added to scope until user prompted — Cited with what happened vs what should happen comparison

---

## Summary

**Current Status**: Phase 6A (Validate H1 Fix) — MONITORING  
**Next Milestone**: Accumulate 20-30 commits, then measure H1 validation results  
**Completion**: ~30-40% (Discovery, Review, Rule Improvements complete; H1 validation in progress)

**Key Insight**: AlwaysApply works for ~20 critical rules but doesn't scale to 44 (+97% context cost). Investigation has identified 6 scalable enforcement patterns for the remaining 25 conditional rules. All preparatory work complete; validation requires real-world usage data.

**What's Complete** ✅:

1. ✅ Discovery tasks (0.1-0.6) — All analysis and pre-test work done
2. ✅ Review R.1 and R.2 — Test plans validated, premature completion analyzed
3. ✅ Rule improvements (15.0-20.0) — 6 rule improvements applied to 4 files

**What's In Progress** ⏸️: 4. ⏸️ Phase 6A (H1 validation) — Awaiting 20-30 commits for measurement

**What's Ready to Execute** ⏸️: 5. ⏸️ Phase 6B (H2 send gate) — Test plan ready, ~8-12 hours 6. ⏸️ Phase 6C (H3 query visibility + slash commands) — Test plans ready, ~14-18 hours 7. ⏸️ Phase 6D (Synthesis) — Awaits H1 validation results, ~4 hours

**Recommended Next Steps**:

1. **Pause investigation work** (all prep complete)
2. **Work normally on repository** (accumulates H1 validation data)
3. **Check dashboard after ~10 commits** (trend check)
4. **Full validation after 20-30 commits** (determine success/partial/failure)
5. **Execute H2/H3 based on H1 results** (if needed)
6. **Synthesis and final summary** (after all tests complete)
7. **Review R.4 before declaring complete** (user approval required)
