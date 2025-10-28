# Consent Gates Monitoring

**Status**: 🔄 Active (Observational)  
**Started**: 2025-10-28  
**Monitoring Period**: 3-6 months (ends ~2026-01-28 to 2026-04-28)  
**Type**: Observational monitoring  
**Mode**: Lite

---

## Overview

Lightweight observational monitoring of consent gate mechanisms implemented in [consent-gates-refinement](../consent-gates-refinement/). Documents organic observations of deferred validation tasks during normal work over 3-6 months.

**Parent Project**: [consent-gates-refinement](../consent-gates-refinement/) (completed 2025-10-28)

---

## Purpose

Track deferred validation tasks from consent-gates-refinement completion:

- Natural language trigger testing ("show active allowlist")
- Session allowlist grant/revoke workflows
- Metrics collection (over-prompting, allowlist usage, composite consent)
- Intent routing consistency
- State tracking observations

**Approach**: Passive observation, not active testing. Document as issues occur naturally.

---

## Quick Links

- **[ERD](./erd.md)** — Observational monitoring scope and acceptance criteria
- **[Tasks](./tasks.md)** — Deferred validation items (opportunistic)
- **[Parent Project](../consent-gates-refinement/)** — Implementation and specifications

### Parent Project Artifacts

- **[Final Summary](../consent-gates-refinement/final-summary.md)** — Parent project completion report
- **[Risk Tiers](../consent-gates-refinement/risk-tiers.md)** — 3-tier risk classification
- **[Composite Consent](../consent-gates-refinement/composite-consent-signals.md)** — Plan approval detection
- **[State Tracking](../consent-gates-refinement/consent-state-tracking.md)** — Workflow persistence
- **[Decision Flowchart](../consent-gates-refinement/consent-decision-flowchart.md)** — Mechanism reference
- **[Test Suite](../consent-gates-refinement/consent-test-suite.md)** — 33 validation scenarios

---

## What to Monitor

### 1. Natural Language Triggers (Opportunistic)

Test when convenient:

- "show active allowlist"
- "list session consent"
- "what has standing consent"

### 2. Session Allowlist Workflows (As Needed)

Document if/when used:

- Grant: "Grant standing consent for: git push"
- Revoke: "Revoke consent for: git status"
- Clear: "Revoke all consent"

### 3. Consent Gate Behavior (Observe)

Note if observed:

- Over-prompting (unnecessary consent requests)
- Under-prompting (risky ops without consent)
- Composite consent accuracy
- State tracking confusion
- Intent routing inconsistency

---

## How to Document Observations

### Quick Observations

**Add to tasks.md under "Findings & Observations"**:

```markdown
- [Date] [Category] — Brief observation
  - Context: What triggered it
  - Expected: What should have happened
  - Actual: What happened
  - Impact: Low/Medium/High
```

### Detailed Findings

**Create file**: `monitoring/findings/finding-##-<short-name>.md`

Use parent project template (see [validation-findings.md](../consent-gates-refinement/validation-findings.md))

---

## Completion Criteria

**Lightweight (observational project)**:

✅ Monitoring structure created  
✅ 3-6 months elapsed  
✅ At least one observation documented (even if "no issues")  
✅ Qualitative assessment: consent flow better/same/worse

**Not required**:

- Formal metrics
- Quantitative comparison
- All deferred tasks completed

---

## Milestones

- **Month 1 (Nov 2025)**: Initial observations; test natural language triggers if convenient
- **Month 3 (Jan 2026)**: Mid-point check; assess if patterns emerging
- **Month 6 (Apr 2026)**: Final assessment; completion decision

---

## Current Status

**Monitoring Started**: 2025-10-28  
**Observations Documented**: 0  
**Issues Found**: 0  
**Next Milestone**: Month 1 check (~2025-11-28)

---

## Related Projects

- **[consent-gates-refinement](../consent-gates-refinement/)** — Parent project (implementation)
- **[rules-enforcement-investigation](../rules-enforcement-investigation/)** — Rule execution monitoring
- **[tdd-scope-boundaries](../tdd-scope-boundaries/)** — TDD gate scope validation

---

## Navigation

- **← [Projects Index](../README.md)** — All active and archived projects
- **→ [ERD](./erd.md)** — Monitoring scope and criteria
- **→ [Tasks](./tasks.md)** — Observational checklist
- **⬆ [Parent Project](../consent-gates-refinement/)** — Implementation details

---

**Owner**: repo-maintainers  
**Type**: Observational monitoring (passive, organic)  
**Priority**: Low (opportunistic documentation)
