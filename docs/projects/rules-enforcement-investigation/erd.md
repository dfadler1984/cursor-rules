---
status: complete
owner: repo-maintainers
lastUpdated: 2025-10-15
completedDate: 2025-10-15
phase: complete
---

# Engineering Requirements Document — Rules Enforcement & Effectiveness Investigation

## 1. Introduction/Overview

Investigate how Cursor rules are processed and enforced by the AI assistant to determine:

1. Whether rules act as hard constraints or soft reference material
2. What mechanisms exist (or could exist) to ensure rule compliance
3. Whether slash commands provide better adherence than intent routing
4. How to structure rules for maximum effectiveness

**Context**: Assistant violated multiple rules (script-first, consent-first) despite rules being in context (`alwaysApply: true`). Need to understand root cause and identify structural improvements.

## 2. Goals/Objectives

- Understand how rules in `.cursor/rules/*.mdc` are processed by the AI
- Determine difference between `alwaysApply: true` vs `false` in practice
- Compare intent routing (current) vs slash commands (taskmaster/spec-kit) for rule adherence
- Identify measurable signals for rule compliance
- Propose structural changes to improve enforcement

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

**Week 1: Infrastructure & Quick Wins**

1. Build measurement framework (compliance checkers, baseline dashboard)
2. Run Hypothesis 1 (conditional attachment) — expected +20 pts improvement
3. Establish objective baseline for all metrics

**Week 2: Core Mechanisms** 4. Run Hypothesis 3 (query visibility) — expected +80 pts transparency improvement 5. Run Hypothesis 2 (send gate enforcement) — determine if gate blocks violations

**Week 3: Advanced Improvements** 6. Run Slash Commands Experiment — expected +25 pts routing accuracy 7. Test with/without slash commands, measure adoption

**Week 4: Integration & Validation** 8. Combine successful improvements (always-apply + visible output + slash commands) 9. Measure cumulative effect, validate no negative interactions 10. Document final recommendations and rollout plan

## 5. Acceptance Criteria

### Phase 5: Test Plan Development

**Deliverables**: Comprehensive test plans for all hypotheses and experiments

- Test plans with success criteria, timelines, and risk mitigation
- Measurement framework design with automated compliance checking
- Analysis of 15+ rules for enforcement patterns
- Comparison with external patterns (taskmaster/spec-kit)
- Structural improvement proposals with rationale

**Status**: ✅ COMPLETE (see tasks.md Phase 2)

### Phase 6: Test Execution

**Deliverables**: Execute tests and validate findings

- Build measurement framework (4 compliance checkers + dashboard)
- Establish baseline metrics
- Execute meta-test (Hypothesis 0)
- Confirm root cause (Hypothesis 1)
- Apply and validate primary fix
- Document comprehensive findings

**Status**: ✅ PRIMARY OBJECTIVES COMPLETE (see tasks.md Phases 2-5)

**Optional tests deferred**: H2 (send gate), H3 (query visibility), slash commands experiment

### Final Deliverables

**Required artifacts**:

- Executive summary documents
- Quantitative results (baseline metrics)
- Recommendations with evidence
- Measurement tools (CI-ready)
- Fix validation

**Status**: ✅ ALL COMPLETE (see tasks.md Phase 5)

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

**Planned**: 4 weeks (phased execution across Weeks 1-4)

**Actual**: <1 day (2025-10-15)

**Key acceleration**: Meta-test (Hypothesis 0) with self-improve rule answered fundamental question in <5 minutes, confirming Hypothesis 1 without need for planned control/experimental trials.

**See**: [`tasks.md`](tasks.md) for execution checklist and [`findings.md`](findings.md) for outcomes

---

**Project Metadata**:

- Owner: repo-maintainers
- Created: 2025-10-11
- Completed: 2025-10-15
- Status: Primary objective complete
- See: [`findings.md`](findings.md) for outcomes, [`tasks.md`](tasks.md) for execution details
