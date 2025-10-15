---
status: active
owner: repo-maintainers
lastUpdated: 2025-10-15
phase: test-execution
---

# Engineering Requirements Document — Rules Enforcement & Effectiveness Investigation

## 1. Introduction/Overview

Investigate how Cursor rules are processed and enforced by the AI assistant to determine:

1. Whether rules act as hard constraints or soft reference material
2. What mechanisms exist (or could exist) to ensure rule compliance
3. Whether slash commands provide better adherence than intent routing
4. How to structure rules for maximum effectiveness

**Context**: Assistant violated multiple rules (script-first, consent-first) despite rules being in context. Initial investigation identified conditional attachment as one factor, but fundamental questions remain unanswered about enforcement mechanisms, pre-send gates, query protocols, and scalable patterns for 25+ conditional rules.

## 2. Goals/Objectives

- Understand how rules in `.cursor/rules/*.mdc` are processed and enforced by the AI
- Determine what makes enforcement effective (beyond just `alwaysApply: true`)
- Discover scalable enforcement patterns for 25+ conditional rules (not just critical rules)
- Compare intent routing (current) vs slash commands (taskmaster/spec-kit) for rule adherence
- Understand why pre-send gates and query protocols may not be working
- Identify measurable signals for rule compliance
- Propose structural changes that scale across all rule types

## 3. Research Questions

### 3.1 Rules Processing

- Q: What happens when a rule has `alwaysApply: true`?
- Q: Can rules create blocking constraints on behavior?
- Q: How do "pre-send gates" in rules affect assistant behavior?
- Q: What's the difference between a rule and reference documentation?

### 3.2 Enforcement Mechanisms

- Q: Do checklist-style rules improve compliance vs prose rules?
- Q: Does placement in the rule matter (top vs bottom)?
- Q: Can we create verification scripts that validate rule adherence post-hoc?

### 3.3 Slash Commands vs Intent Routing

- Q: Do slash commands (explicit `/plan`, `/tasks`) provide better rule adherence than intent routing?
- Q: What makes taskmaster and spec-kit effective (if they are)?
- Q: Can we implement mandatory slash-command gating for high-risk operations?

### 3.4 Observable Signals

- Q: What signals indicate rule compliance? (script usage, consent requests, TDD cycle)
- Q: Can we instrument the workflow to measure compliance automatically?

## 4. Investigation Approach

### Phase 1: Baseline Measurement

1. Document recent rule violations with specifics:
   - Expected: use `git-commit.sh`
   - Actual: used `git commit --amend`
   - Rule: `capabilities.mdc` (alwaysApply: true) + `assistant-git-usage.mdc`
2. Identify pattern: rules present but not consulted before action
3. Categorize violations: script-first, consent-first, TDD-first

### Phase 2: Experimental Tests

Design small experiments to test rule processing:

**Experiment 1: Explicit Pre-Action Query**

- Add rule: "Before git commands, explicitly ask: 'What scripts exist in capabilities.mdc for this operation?'"
- Test: Request a commit
- Measure: Does assistant query capabilities before acting?

**Experiment 2: Slash Command Gating**

- Implement: `/commit` command that routes to git-commit.sh
- Test: Request a commit without using slash command
- Measure: Does assistant suggest slash command first?

**Experiment 3: Pre-Send Gate Verification**

- Rule states: "If any item fails, revise message; do not send"
- Test: Introduce intentional violation
- Measure: Does assistant catch and revise before sending?

### Phase 3: External Reference Analysis

Review how other projects structure enforcement:

**Taskmaster** (reference: `docs/projects/ai-workflow-integration/`)

- Uses slash commands for task operations
- Structured prompts force specific workflows
- Research: Does this approach show better compliance?

**Spec-kit** (reference: `docs/projects/ai-workflow-integration/`)

- Uses `/spec`, `/plan`, `/analyze` slash commands
- Commands have required arguments
- Research: How do mandatory parameters affect behavior?

### Phase 4: Measurement Framework

Create post-hoc validation:

- Script to scan chat logs for rule compliance signals
- Checklist: "Did assistant use repo script when available?"
- Automated check: parse commands executed vs capabilities.mdc entries

### Phase 5: Test Plan Development (✅ COMPLETED)

**Deliverables**:

1. **Discovery Document** ([discovery.md](discovery.md)) — 1,252 lines

   - Analyzed 15+ rules for enforcement patterns
   - Identified 6 patterns (strong → weak)
   - Critical finding: `assistant-git-usage.mdc` has `alwaysApply: false`
   - Proposed 5 structural improvements
   - Compared to external patterns (Taskmaster/Spec-kit)

2. **Test Plans Suite** ([tests/](tests/)) — 6 detailed documents, ~2,500 lines
   - Hypothesis 1: Conditional Attachment test plan
   - Hypothesis 2: Send Gate Enforcement test plan
   - Hypothesis 3: Query Protocol Visibility test plan
   - Experiment: Slash Command Gating test plan
   - Measurement Framework implementation plan
   - Test execution guide with success criteria

**Key Findings from Discovery**:

- **Conditional attachment is a weakness**: Git-usage rule not always in context
- **Verification lacks visibility**: No output required for capability queries
- **Strong patterns identified**: Pre-send gates, numbered protocols, tool constraints
- **Weak patterns identified**: Advisory prose, self-assessed gates, buried requirements

**Test Plans Ready**:

- Each includes: test design, success criteria, measurement protocol, implementation checklist
- Timeline: 3-4 weeks for full suite execution
- Baseline targets: >90% script usage, >95% TDD compliance, >95% routing accuracy

### Phase 6: Test Execution (CURRENT PHASE)

Execute test plans in priority order:

**Completed (Week 0)**:

1. ✅ Built measurement framework (compliance checkers, baseline dashboard)
2. ✅ Ran Hypothesis 0 (meta-test with self-improve rule)
3. ✅ Established baseline metrics (68% overall, 71% script usage, 72% TDD, 62% branch naming)
4. ✅ Applied H1 fix (git-usage → alwaysApply: true)

**Remaining Work**:

**Phase 6A: Validate H1 Fix (2-3 weeks)**

1. Monitor script usage over 20-30 commits with alwaysApply: true
2. Measure actual improvement (expect: 71% → >90%)
3. Confirm fix effectiveness or identify gaps

**Phase 6B: Core Enforcement Mechanisms (2-3 weeks)**

4. Run Hypothesis 2 (send gate enforcement) — Does the pre-send gate actually block violations?
5. Run Hypothesis 3 (query visibility) — Is "check capabilities.mdc" executed? Would visible output help?

**Phase 6C: Scalable Patterns (2-3 weeks)**

6. Run Slash Commands Experiment — Can explicit commands solve routing for 25 conditional rules?
7. Compare approaches: alwaysApply vs slash commands vs improved intent routing

**Phase 6D: Integration & Validation (1 week)**

8. Synthesize findings into scalable enforcement patterns
9. Document recommendations for all rule types (not just critical rules)
10. Address 6 rule improvement gaps discovered during investigation

## 5. Acceptance Criteria

### Phase 5: Test Plan Development ✅ COMPLETE

**Deliverables**: Comprehensive test plans for all hypotheses and experiments

- ✅ Test plans with success criteria, timelines, and risk mitigation
- ✅ Measurement framework design with automated compliance checking
- ✅ Analysis of 15+ rules for enforcement patterns
- ✅ Comparison with external patterns (taskmaster/spec-kit)
- ✅ Structural improvement proposals with rationale

### Phase 6A: Validate H1 Fix ⏳ IN PROGRESS

**Deliverables**: Validate that alwaysApply fix actually solves the problem

- ✅ Applied fix (git-usage → alwaysApply: true)
- ❌ Validated fix with 20-30 commits of actual usage
- ❌ Measured improvement (baseline 71% → target >90%)
- ❌ Confirmed no regression in other areas

**Success Criteria**: Script usage ≥90% after fix (vs 71% baseline)

### Phase 6B: Core Enforcement Mechanisms ⏸️ NOT STARTED

**Deliverables**: Answer fundamental questions about how rules work

- ❌ H2: Does pre-send gate execute and block violations?
- ❌ H3: Is query protocol executed? Would visibility improve compliance?
- ❌ Document which enforcement patterns work and why

**Success Criteria**:

- H2: Gate visibility >10% AND detection accuracy >80%
- H3: Query execution confirmed AND visibility = 100%

### Phase 6C: Scalable Patterns ⏸️ NOT STARTED

**Deliverables**: Discover enforcement patterns for 25+ conditional rules

- ❌ Execute slash commands experiment
- ❌ Compare: alwaysApply vs slash commands vs improved intent routing
- ❌ Identify scalable patterns that don't require alwaysApply

**Success Criteria**: Routing accuracy >95% with scalable approach (vs ~70% baseline)

### Phase 6D: Integration & Final Deliverables ⏸️ NOT STARTED

**Deliverables**: Synthesize findings and complete rule improvements

- ❌ Synthesized recommendations for all rule types
- ❌ Complete 6 rule improvement tasks (project-lifecycle, ERD scope, task structure, etc.)
- ❌ CI integration guide validated
- ❌ Final summary with validated recommendations

**Success Criteria**:

- All 6 rule gaps addressed
- Scalable enforcement patterns documented
- Overall compliance >90% validated

## 6. Risks/Constraints

- **Black box risk**: We cannot inspect AI internals; can only observe behavior
- **Confounding variables**: Changes in prompt, context, or model may affect results
- **Sample size**: Small number of observations may not be statistically significant
- **Bias**: Observer effect (assistant knows it's being tested)

## 7. Success Metrics

### Objective Measures (Baseline → Target)

**From Discovery Analysis**:

- Script usage rate: 73.5% → **target >90%** (+17 pts improvement needed)
- TDD compliance rate: 68.2% → **target >95%** (+27 pts improvement needed)
- Branch naming compliance: 88.0% → **target >90%** (+2 pts improvement needed)

**From Test Plans**:

- Query visibility rate: ~0-20% → **target 100%** (+80 pts improvement needed)
- Send gate visibility: ~0-10% → **target 100%** (gate output in all responses)
- Routing accuracy: ~70% → **target >95%** (+25 pts improvement needed)
- Rule attachment (git-usage): ~60-70% → **target 100%** (with always-apply)

### Per-Test Success Criteria

**Hypothesis 1 (Conditional Attachment)**:

- Experimental script usage ≥ 90% (vs ~70% baseline)
- Improvement ≥ 20 percentage points
- Rule attachment rate: 100%

**Hypothesis 2 (Send Gate Enforcement)**:

- Gate visibility: >10% (proves gate is executed)
- Detection accuracy: >80% (gate catches violations)
- Blocking rate: >80% (gate prevents violations)

**Hypothesis 3 (Query Visibility)**:

- Query output visible: 100% (with improvement)
- Query accuracy: >95% (correct script detection)
- Behavior consistency: >90% (uses script when found)

**Experiment: Slash Commands**:

- Routing accuracy: >95% (vs ~70% baseline)
- Script usage (indirect requests): >90% (vs ~30% baseline)
- User comprehension: >80% understand prompts

**Measurement Framework**:

- All checkers implemented and tested
- Baseline established for all metrics
- Dashboard generates correctly
- CI integration ready

### Qualitative Signals

- Assistant explicitly queries capabilities before git ops (visible output)
- Assistant references specific rules when making decisions (routing transparency)
- User reports increased confidence in assistant consistency (feedback survey)
- Violations are obvious when they occur (observable compliance)

## 8. Related Work

### Internal Projects

- [ai-workflow-integration](../ai-workflow-integration/erd.md) — Analysis of taskmaster, spec-kit patterns
- [intent-router](../_archived/2025/intent-router/final-summary.md) — Current intent routing implementation
- [slash-commands-runtime](../slash-commands-runtime/erd.md) — Proposed slash command execution

### Key Questions from AI Workflow Integration

From `docs/projects/ai-workflow-integration/erd.md`:

- Taskmaster uses structured task format with dependencies/priority
- Spec-kit uses `/analyze` command with explicit safety gates
- Both force explicit state transitions vs implicit routing

**Hypothesis**: Explicit commands create forcing functions that intent routing lacks.

## 9. Open Questions

1. **Fundamental**: Are Cursor rules constraints or hints?
2. **Mechanism**: What creates a "forcing function" in assistant behavior?
3. **Design**: Should high-risk operations require slash commands?
4. **Measurement**: How do we validate rule compliance without manual review?
5. **Precedent**: What do other AI coding assistants do for consistency?

## 10. Implementation Timeline

**Original Plan**: 4 weeks (phased execution)

**Revised Timeline**:

- **Week 0** (2025-10-15): ✅ Test plan development, measurement framework, baseline, H0 meta-test, H1 fix applied
- **Weeks 1-2**: Validate H1 fix effectiveness (20-30 commits)
- **Weeks 3-4**: Execute H2 (send gate) and H3 (query visibility)
- **Weeks 5-6**: Execute slash commands experiment
- **Week 7**: Synthesize findings, complete 6 rule improvements
- **Total**: ~7 weeks from start (vs 4 weeks originally planned)

**Status**: ~15% complete (infrastructure built, one fix applied but not validated, core questions unanswered)

**Key Insight**: Meta-test proved rules CAN work, but did NOT answer:

- What enforcement patterns scale to 25+ conditional rules?
- Why pre-send gates may not be working
- Whether slash commands provide better enforcement
- How to validate the fix actually works

**See**: [`tasks.md`](tasks.md) for execution checklist

---

**Project Metadata**:

- Owner: repo-maintainers
- Created: 2025-10-11
- Status: Active (test execution phase)
- Current Phase: 6A (validate H1 fix)
- Completion: ~15%
