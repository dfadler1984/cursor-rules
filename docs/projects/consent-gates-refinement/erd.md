---
status: active
owner: repo-maintainers
lastUpdated: 2025-10-11
---

# Engineering Requirements Document — Consent Gates Refinement

## 1. Introduction/Overview

Conduct a deep dive on consent-first gating and exceptions to fix issues where consent gates aren't working as expected.

**Context**: Current consent gating has exceptions (read-only commands, session allowlists, composite consent-after-plan) but the user reports these aren't working smoothly. Need to identify specific friction points and refine the flow.

### Uncertainty / Assumptions

- [NEEDS CLARIFICATION: What specific consent gate failures have you observed?]
- [NEEDS CLARIFICATION: Are gates too aggressive (blocking safe ops) or too lax (allowing risky ops)?]
- Assumption: Core consent policy is in `assistant-behavior.mdc`

## 2. Goals/Objectives

- Identify specific failures in consent gating (over-prompting, under-prompting, unclear exceptions)
- Streamline exception handling for safe/obvious operations
- Improve user experience without compromising safety
- Create clear, predictable consent behavior

## 3. User Stories

- As a user, I want obvious read-only commands to execute without extra prompts
- As a user, I want risky operations to always require explicit consent
- As a user, I want session allowlists to work consistently
- As a user, I want consent-after-plan to recognize when I've already approved

## 4. Functional Requirements

### 4.1 Analysis Phase

1. Document recent consent gate issues (over-prompting, missed gates, unclear state)
2. Categorize operations by risk: safe (read-only) → moderate (local edits) → risky (git push, destructive)
3. Review current exception mechanisms (read-only allowlist, session allowlist, composite consent)
4. Identify gaps: operations that should be in allowlist but aren't, or vice versa

### 4.2 Refinement Phase

1. Expand safe read-only allowlist based on common operations
2. Clarify session allowlist grant/revoke workflow
3. Improve composite consent-after-plan detection (better signal matching)
4. Add explicit "consent state" tracking across turns
5. Create consent decision flowchart for assistant reference

## 5. Non-Functional Requirements

- **Safety first**: Default to asking when uncertain
- **Predictability**: Same operation should yield same consent behavior
- **Transparency**: User always knows why consent was requested or skipped
- **Minimal friction**: Eliminate redundant prompts for safe operations

## 6. Architecture/Design

### Current State (from `assistant-behavior.mdc`)

- **One-shot consent**: First command per tool category requires consent
- **Read-only exception**: Allowlisted safe commands execute without prompt
- **Session allowlist**: User can grant standing consent for approved commands
- **Composite consent-after-plan**: Previous plan + "go ahead" → implementation
- **Tool category switches**: Crossing categories requires fresh consent

### Proposed Improvements

1. **Risk-based gating**

   - Tier 1 (safe): read-only git, file reads, status checks → no consent
   - Tier 2 (moderate): local edits, test runs → one-shot consent
   - Tier 3 (risky): git push, destructive ops → always consent

2. **Consent state persistence**

   - Track `consentState: granted|required|not-applicable` per operation
   - Carry state across turns within same workflow

3. **Clearer exception triggers**

   - Imperative phrasing + safe command → execute
   - Previous concrete plan + consent phrase → implementation
   - Add confidence check: if uncertain, ask once

4. **Session allowlist improvements**
   - Standardize grant format: "Grant standing consent for: `<command>`"
   - Add revoke command: "Revoke consent for: `<command>`"
   - Show active allowlist on request

## 7. Data Model and Storage

### Consent State (per operation)

```typescript
{
  "operation": "git-commit|pr-create|edit-file|...",
  "risk": "safe|moderate|risky",
  "consentState": "granted|required|not-applicable",
  "source": "explicit|allowlist|composite|exception",
  "timestamp": "ISO-8601"
}
```

## 8. API/Contracts

### Consent Decision Output

```json
{
  "operation": "git-commit",
  "command": "git commit -m 'feat: add feature'",
  "risk": "moderate",
  "consentRequired": true,
  "reason": "First git command in turn",
  "allowlistEligible": true
}
```

## 9. Integrations/Dependencies

- Related: `assistant-behavior.mdc` (consent-first section)
- Related: `security.mdc` (command execution rules)
- Related: `user-intent.mdc` (intent classification)
- Scripts: Consider adding `.cursor/scripts/consent-audit.sh` to review consent decisions

## 10. Edge Cases and Constraints

- **Ambiguous imperative**: "Can you commit?" (question or directive?)
- **Multi-step workflows**: Plan → implement → test → commit (consent at each step?)
- **Category switch mid-turn**: Local edit → git commit (requires fresh consent?)
- **Retry after failure**: Command failed, retry with fix (re-ask consent?)

## 11. Testing & Acceptance

### Test Cases

1. **Safe read-only**: "Run `git status`" → execute without prompt
2. **Obvious risky**: "Push to main" → always ask consent
3. **Session allowlist**: Grant consent for `git-commit.sh`, then request commit → execute
4. **Composite consent**: Previous plan + "go ahead" → implementation without re-asking
5. **Ambiguous**: "We should commit" → ask clarification
6. **Category switch**: Edit file (granted) → then `git add` → ask consent for git category

### Acceptance Criteria

- [ ] Documented: baseline consent gate issues from recent conversations
- [ ] Classified: all common operations by risk tier
- [ ] Implemented: risk-based gating with clear thresholds
- [ ] Tested: consent test suite with ≥15 cases covering edge cases
- [ ] Validated: user reports smoother consent flow with maintained safety

## 12. Rollout & Ops

1. Document baseline consent issues (over/under-prompting examples)
2. Implement risk tiers and update allowlists
3. Add consent state tracking across turns
4. Test with real workflows for 1 week
5. Adjust based on feedback

## 13. Success Metrics

### Objective Measures

- **Over-prompting reduction**: % decrease in redundant consent requests (target: >50%)
- **Safety maintained**: Zero risky operations executed without consent
- **Allowlist usage**: % of safe commands using exception (target: >80%)
- **Composite consent hit rate**: % of "go ahead" correctly recognized (target: >90%)

### Qualitative Signals

- User reports fewer unnecessary prompts
- Risky operations still feel appropriately gated
- Session allowlist is easy to understand and use

## 14. Open Questions

1. **Risk classification**: What makes an operation risky vs moderate vs safe?
2. **State persistence**: How long should consent state last (per-turn, per-workflow, per-session)?
3. **Multi-step consent**: Should workflows have "consent once for entire plan" option?
4. **Failure retry**: If command fails, should we re-ask consent for retry?
5. **Revoke workflow**: How should users revoke session allowlist items?

---

Owner: repo-maintainers  
Created: 2025-10-11  
Motivation: Consent gating and exceptions not working as smoothly as expected; need refinement for better UX without compromising safety
