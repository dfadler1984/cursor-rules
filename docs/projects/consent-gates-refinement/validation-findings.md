# Consent Gates Validation Findings

**Purpose**: Document consent gate behavior observations during Phase 3 validation monitoring  
**Monitoring Period**: 2025-10-24 to ~2025-11-07 (1-2 weeks)  
**Status**: 🔄 Active monitoring

## Monitoring Scope

**In Scope**:

- Over-prompting instances (unnecessary consent requests)
- Under-prompting instances (risky operations without consent)
- Session allowlist behavior (grant/revoke/query)
- Composite consent detection accuracy
- State tracking issues (consent persistence, reset conditions)
- Category switch behavior

**Out of Scope**:

- Intent routing issues (which rules attach) → See `routing-optimization`
- Rule execution issues (following TDD/testing rules) → See `rules-enforcement-investigation`
- Workflow automation issues → See relevant project

## Validation Metrics

### Target Metrics

| Metric                     | Target | Current | Notes                                |
| -------------------------- | ------ | ------- | ------------------------------------ |
| Over-prompting reduction   | >50%   | TBD     | Compare to pre-refinement baseline   |
| Under-prompting incidents  | 0      | TBD     | Zero risky ops without consent       |
| Allowlist usage rate       | >50%   | TBD     | % of repeat commands using allowlist |
| Composite consent accuracy | >90%   | TBD     | % of "go ahead" correctly recognized |
| State tracking issues      | <5     | TBD     | Number of unexpected state resets    |

### Qualitative Signals

- User reports fewer unnecessary prompts
- Risky operations feel appropriately gated
- Session allowlist is easy to understand and use
- Consent state behavior is predictable

## Findings Log

### Finding #1: Example Template (Remove after first real finding)

**Date**: YYYY-MM-DD  
**Category**: Over-prompting | Under-prompting | Allowlist | Composite Consent | State Tracking | Other

**Observation**:
Brief description of what happened

**Expected Behavior**:
What should have happened per the specifications

**Actual Behavior**:
What actually happened

**Evidence**:

- Commands/requests involved
- Console output or logs
- Relevant turn numbers

**Root Cause**:
Analysis of why this occurred

**Severity**:

- 🔴 Critical (safety issue, risky op without consent)
- 🟡 Medium (over-prompting, UX friction)
- 🟢 Low (edge case, rare occurrence)

**Proposed Fix**:
What needs to change to address this

**Related**:

- Links to test scenarios in `consent-test-suite.md`
- Links to specifications (`risk-tiers.md`, `composite-consent-signals.md`, etc.)
- Related findings (if any)

---

## Summary Statistics

**To be updated during monitoring period**:

- Total findings: TBD
- Critical (🔴): TBD
- Medium (🟡): TBD
- Low (🟢): TBD

**By Category**:

- Over-prompting: TBD
- Under-prompting: TBD
- Session allowlist: TBD
- Composite consent: TBD
- State tracking: TBD
- Other: TBD

## Recommendations

**To be populated after monitoring period**:

1. High-priority fixes (based on critical findings)
2. Medium-priority improvements (based on medium findings)
3. Documentation updates needed
4. Test suite additions
5. Optional enhancements (nice-to-have)

## Related Documents

- **Project**: `consent-gates-refinement/`
- **ERD**: `consent-gates-refinement/erd.md`
- **Tasks**: `consent-gates-refinement/tasks.md`
- **Phase 2 Summary**: `consent-gates-refinement/phase2-summary.md`
- **Test Suite**: `consent-gates-refinement/consent-test-suite.md`
- **Specifications**:
  - `consent-gates-refinement/risk-tiers.md`
  - `consent-gates-refinement/composite-consent-signals.md`
  - `consent-gates-refinement/consent-state-tracking.md`
  - `consent-gates-refinement/consent-decision-flowchart.md`
- **Active Monitoring**: `docs/projects/ACTIVE-MONITORING.md`

---

**Monitoring Protocol**:

1. Observe consent gate behavior during normal work
2. Document any deviations from expected behavior immediately
3. Use the finding template above for each observation
4. Update summary statistics weekly
5. After monitoring period: compile recommendations and update specifications as needed
