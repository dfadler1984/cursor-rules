---
status: active
owner: repo-maintainers
lastUpdated: 2025-10-11
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

## 5. Acceptance Criteria

- [ ] Documented: specific examples of rule violations with context
- [ ] Tested: at least 3 experiments with measurable outcomes
- [ ] Analyzed: taskmaster/spec-kit slash command patterns
- [ ] Proposed: concrete structural changes with rationale
- [ ] Validated: changes tested with real workflow examples

## 6. Risks/Constraints

- **Black box risk**: We cannot inspect AI internals; can only observe behavior
- **Confounding variables**: Changes in prompt, context, or model may affect results
- **Sample size**: Small number of observations may not be statistically significant
- **Bias**: Observer effect (assistant knows it's being tested)

## 7. Success Metrics

### Objective Measures

- Script usage rate: % of git ops using repo scripts vs raw git
- Consent compliance: % of commands preceded by consent request
- TDD compliance: % of impl edits preceded by failing test

### Qualitative Signals

- Assistant explicitly queries capabilities before git ops
- Assistant references specific rules when making decisions
- User reports increased confidence in assistant consistency

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

## 10. Next Steps (Immediate)

1. Create tasks.md with specific experiments
2. Document baseline violations from recent session
3. Review taskmaster/spec-kit slash command patterns
4. Design first experiment: explicit capability query
5. Run experiment and document results

---

Owner: repo-maintainers
Created: 2025-10-11
Motivation: Assistant violated multiple rules despite `alwaysApply: true`; need to understand enforcement mechanisms
