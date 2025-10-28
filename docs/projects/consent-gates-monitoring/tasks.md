# Tasks — Consent Gates Monitoring

**Project Type**: Observational monitoring  
**Parent Project**: [consent-gates-refinement](../consent-gates-refinement/)  
**Monitoring Period**: 2025-10-28 to ~2026-04-28 (3-6 months)

---

## Overview

This project tracks **deferred observational validation** from [consent-gates-refinement](../consent-gates-refinement/final-summary.md#what-was-deferred-carryovers). All items below are **low-priority and organic**; document observations as they occur naturally during normal work.

**Approach**: Passive observation, not active testing. No dedicated monitoring sessions required.

---

## Phase 1: Setup

- [x] Create project structure (ERD, tasks, README)
- [x] Create monitoring directories (`monitoring/findings/`, `monitoring/logs/`)
- [ ] Add initial observation template
- [ ] Link from consent-gates-refinement final-summary.md

---

## Phase 2: Observational Monitoring (3-6 Months)

### Natural Language Triggers (Opportunistic)

**From**: [consent-gates-refinement carryovers](../consent-gates-refinement/tasks.md#real-session-testing-low-priority)

- [ ] Test "show active allowlist" trigger when convenient
  - **Priority**: Low (convenience feature; `/allowlist` command works)
  - **Document**: If tested, record whether it worked correctly
- [ ] Test "list session consent" trigger when convenient

  - **Priority**: Low
  - **Document**: If tested, record whether it worked correctly

- [ ] Test "what has standing consent" trigger when convenient
  - **Priority**: Low
  - **Document**: If tested, record whether it worked correctly

### Session Allowlist Workflows (As Needed)

**From**: [consent-gates-refinement carryovers](../consent-gates-refinement/tasks.md#real-session-testing-low-priority)

- [ ] Document grant workflow usage (if/when used)

  - **Example**: "Grant standing consent for: git push"
  - **Priority**: Low (document if naturally used)
  - **Document**: Did it work as expected? Any confusion?

- [ ] Document revoke workflow usage (if/when used)

  - **Example**: "Revoke consent for: git status"
  - **Priority**: Low
  - **Document**: Did it work correctly? Clear feedback provided?

- [ ] Document "Revoke all consent" usage (if/when used)
  - **Priority**: Low
  - **Document**: Did it clear allowlist? Confirmation message shown?

### Metrics Collection (Informal)

**From**: [consent-gates-refinement carryovers](../consent-gates-refinement/tasks.md#metrics-collection-observational)

- [ ] Note over-prompting instances (if observed)

  - **Target**: Compare to pre-refinement baseline (if available)
  - **Priority**: Low (opportunistic observation)
  - **Document**: Frequency, context, whether it felt excessive

- [ ] Note under-prompting instances (if observed)

  - **Target**: Zero risky operations without consent
  - **Priority**: High (safety-critical if occurs)
  - **Document**: What operation, why no prompt, immediate fix

- [ ] Note allowlist usage patterns (informal)

  - **Target**: Which commands use allowlist frequently?
  - **Priority**: Low
  - **Document**: Which mechanisms used most (slash, read-only, session, composite)

- [ ] Note composite consent accuracy (if observed)
  - **Target**: "Go ahead" correctly recognized
  - **Priority**: Medium
  - **Document**: False positives (asked when shouldn't) or false negatives (didn't ask when should)

### Intent Routing Consistency

**From**: [consent-gates-refinement carryovers](../consent-gates-refinement/tasks.md#real-session-testing-low-priority)

- [ ] Document intent routing inconsistency examples (if observed)
  - **Issue**: Same request yields different consent behavior
  - **Priority**: Medium (if patterns emerge)
  - **Document**: Specific examples with context

### State Tracking Observations

**From**: [consent-gates-refinement carryovers](../consent-gates-refinement/tasks.md#metrics-collection-observational)

- [ ] Document unexpected state resets (if observed)

  - **Example**: Consent cleared unexpectedly mid-workflow
  - **Priority**: Medium
  - **Document**: Context when reset occurred, expected vs actual behavior

- [ ] Document state persistence confusion (if observed)
  - **Example**: Unclear why re-prompted or not re-prompted
  - **Priority**: Medium
  - **Document**: User confusion instances

---

## Phase 3: Assessment & Completion (After 3-6 Months)

### Mid-Point Check (Month 3: ~2026-01-28)

- [ ] Review observations collected so far
- [ ] Assess if any patterns emerging
- [ ] Decide: continue monitoring or extend/shorten period

### Final Assessment (Month 6: ~2026-04-28)

- [ ] Compile all observations
- [ ] Qualitative assessment: consent flow better/same/worse?
- [ ] Document recommendations:
  - [ ] Keep current implementation (if no issues)
  - [ ] Refine specific mechanisms (if issues observed)
  - [ ] Propose new refinement project (if major issues)

### Completion

- [ ] Document final summary
- [ ] Link to any refinement proposals (if created)
- [ ] Mark project complete
- [ ] Archive project (if no follow-up needed)

---

## Optional: Platform Testing (If Prioritized)

**From**: [consent-gates-refinement carryovers](../consent-gates-refinement/tasks.md#platform-testing-optional-scope)

**Note**: Not pursued in parent project; consent rules are platform-agnostic

- [ ] Test consent gates on Linux (if Linux support becomes priority)

  - **Justification**: Scripts use POSIX patterns; no platform-specific code
  - **Priority**: Low unless user reports Linux issues

- [ ] Test consent gates on macOS (implicit validation)
  - **Justification**: Development environment is macOS
  - **Priority**: N/A (already using macOS)

---

## Optional: Portability Classification (If Reuse Pattern Emerges)

**From**: [consent-gates-refinement carryovers](../consent-gates-refinement/tasks.md#documentation-updates-optional-scope)

**Note**: Deferred until consent patterns reused elsewhere

- [ ] Mark consent behaviors as repo-specific vs reusable

  - **Trigger**: If consent mechanisms adopted in other projects
  - **Priority**: Low (premature without reuse evidence)

- [ ] Document which features are portable
  - **Trigger**: Same as above
  - **Priority**: Low

---

## Findings & Observations

**Document findings in**: `monitoring/findings/`  
**Pattern**: `finding-##-<short-name>.md` (numbered sequentially)  
**Template**: Use template from parent project

### Findings Log

_Document observations here or in separate finding files_

---

## Related Files

- **Parent Project**: [consent-gates-refinement](../consent-gates-refinement/)
- **Implementation**: [consent-gates-refinement/phase2-summary.md](../consent-gates-refinement/phase2-summary.md)
- **Specifications**:
  - [risk-tiers.md](../consent-gates-refinement/risk-tiers.md)
  - [composite-consent-signals.md](../consent-gates-refinement/composite-consent-signals.md)
  - [consent-state-tracking.md](../consent-gates-refinement/consent-state-tracking.md)
  - [consent-decision-flowchart.md](../consent-gates-refinement/consent-decision-flowchart.md)
- **Test Suite**: [consent-test-suite.md](../consent-gates-refinement/consent-test-suite.md)
- **Rules**:
  - `.cursor/rules/assistant-behavior.mdc` (consent-first section)
  - `.cursor/rules/user-intent.mdc` (composite signals)
  - `.cursor/rules/intent-routing.mdc` (slash commands, allowlist)
