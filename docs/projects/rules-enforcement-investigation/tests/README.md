# Rules Enforcement Investigation — Test Plans Index

**Project**: [rules-enforcement-investigation](../erd.md)  
**Discovery Document**: [discovery.md](../discovery.md)  
**Purpose**: Comprehensive test plans for validating rule enforcement improvements

---

## Overview

This directory contains detailed test plans for each hypothesis, experiment, and improvement proposed in the discovery document. Each test plan includes:

- **Hypothesis/objective** — What we're testing and why
- **Test design** — Control vs experimental groups, scenarios, procedures
- **Success criteria** — Quantitative metrics and thresholds
- **Measurement protocol** — How to collect and analyze data
- **Expected outcomes** — Scenarios and interpretations
- **Implementation checklist** — Step-by-step execution guide
- **Timeline & effort estimates** — Resource planning

---

## Test Plans (By Category)

### Hypotheses (Root Cause Analysis)

These tests investigate WHY rules are not being followed:

1. **[Hypothesis 1: Conditional Attachment](hypothesis-1-conditional-attachment.md)**

   - **Question**: Is conditional rule attachment (`alwaysApply: false`) causing violations?
   - **Test**: Make `assistant-git-usage.mdc` always-apply and measure improvement
   - **Effort**: 1 day
   - **Priority**: ⭐⭐⭐ HIGH (low-effort, high-impact)

2. **[Hypothesis 2: Send Gate Enforcement](hypothesis-2-send-gate-enforcement.md)**

   - **Question**: Is the send gate checked? Is it accurate? Does it block violations?
   - **Test**: A) Visibility test, B) Accuracy test, C) Blocking test, D) Visible gate experiment
   - **Effort**: 1-2 days
   - **Priority**: ⭐⭐⭐ HIGH (core enforcement mechanism)

3. **[Hypothesis 3: Query Protocol Visibility](hypothesis-3-query-protocol-visibility.md)**

   - **Question**: Are capability queries actually executed? Are results visible?
   - **Test**: A) Baseline visibility, B) Behavioral evidence, C) Add visible output, D) Timing verification
   - **Effort**: 1 day
   - **Priority**: ⭐⭐⭐ HIGH (transparency mechanism)

4. **Hypothesis 4: Intent Routing Gaps** (see Hypothesis 1 + Experiment: Slash Commands)

   - **Question**: Does keyword-based routing miss operations?
   - **Test**: Covered by H1 (indirect requests) and Slash Commands experiment
   - **Effort**: Included in other tests
   - **Priority**: ⭐⭐ MEDIUM

5. **Hypothesis 5: Habit Bias** (observational)
   - **Question**: Does model training override stated rules?
   - **Test**: Observational across all other tests (can't test directly)
   - **Effort**: N/A (qualitative analysis)
   - **Priority**: ⭐ LOW (no direct test available)

---

### Experiments (Structural Improvements)

These tests validate proposed improvements:

1. **[Experiment: Slash Command Gating](experiment-slash-commands.md)**

   - **Proposal**: Require `/commit`, `/pr`, `/branch` for high-risk git operations
   - **Test**: Phase 1 baseline → Phase 2 implementation → Phase 3 testing → Phase 4 comparison
   - **Effort**: 1-2 days
   - **Priority**: ⭐⭐⭐ HIGH (strong forcing function candidate)

2. **Experiment: Visible Gate Output** (covered in Hypothesis 2, Test D)

   - **Proposal**: Require visible pre-send gate checklist in every response
   - **Test**: See Hypothesis 2 → Test D
   - **Effort**: Included in H2
   - **Priority**: ⭐⭐⭐ HIGH

3. **Experiment: Query Output Requirement** (covered in Hypothesis 3, Test C)
   - **Proposal**: Require visible "Checked capabilities.mdc" output
   - **Test**: See Hypothesis 3 → Test C
   - **Effort**: Included in H3
   - **Priority**: ⭐⭐⭐ HIGH

---

### Supporting Infrastructure

These provide measurement and monitoring capabilities:

1. **[Measurement Framework](measurement-framework.md)**
   - **Purpose**: Automated compliance monitoring and baseline establishment
   - **Components**:
     - Script usage rate checker
     - TDD compliance checker
     - Branch naming checker
     - Compliance dashboard
   - **Effort**: 1-2 days
   - **Priority**: ⭐⭐⭐ HIGH (enables all other tests)

---

## Test Execution Order (Recommended)

### Phase 1: Infrastructure & Baseline (Week 1)

**Priority**: Establish measurement and baseline before improvements

1. ✅ **Measurement Framework** (1-2 days)

   - Build all compliance checkers
   - Establish baseline metrics
   - Document current state

2. **Hypothesis 1: Baseline** (0.5 day)
   - Run control group (50 trials)
   - Part of H1 test, but needed for all comparisons

---

### Phase 2: Low-Hanging Fruit (Week 1-2)

**Priority**: Quick wins with high impact

3. ✅ **Hypothesis 1: Conditional Attachment** (0.5 day)

   - Apply change: `alwaysApply: true`
   - Run experimental group (50 trials)
   - Compare to baseline

4. **Hypothesis 3: Query Visibility** (1 day)
   - Test A: Baseline visibility
   - Test C: Add visible output requirement
   - Measure improvement

---

### Phase 3: Core Mechanisms (Week 2)

**Priority**: Understand and fix fundamental enforcement

5. **Hypothesis 2: Send Gate** (1-2 days)
   - Test A: Is gate visible?
   - Test B: Is gate accurate?
   - Test C: Does gate block?
   - Test D: Add visible gate (if needed)

---

### Phase 4: Advanced Improvements (Week 3)

**Priority**: Test stronger forcing functions

6. **Experiment: Slash Commands** (1-2 days)
   - Phase 1: Baseline (use H1 baseline)
   - Phase 2: Implement slash commands
   - Phase 3: Test with/without commands
   - Phase 4: Comparative analysis

---

### Phase 5: Integration & Validation (Week 3-4)

**Priority**: Combine improvements and validate holistically

7. **Integration Test** (2-3 days)
   - Combine: Always-apply + Visible queries + Slash commands
   - Run comprehensive test suite
   - Measure cumulative improvement
   - Validate no negative interactions

---

## Success Metrics Summary

| Test                           | Primary Metric       | Baseline | Target                 | Success Threshold             |
| ------------------------------ | -------------------- | -------- | ---------------------- | ----------------------------- |
| **H1: Conditional Attachment** | Script usage rate    | ~70%     | >90%                   | +20 pts improvement           |
| **H2: Send Gate**              | Gate visibility      | ~0-10%   | 100%                   | Gate visible in all responses |
| **H3: Query Visibility**       | Query output visible | ~0-20%   | 100%                   | +80 pts improvement           |
| **Exp: Slash Commands**        | Routing accuracy     | ~70%     | >95%                   | +25 pts improvement           |
| **Measurement Framework**      | Baseline established | N/A      | All metrics documented | Complete dashboard            |

**Overall Goal**: Achieve >90% compliance across all metrics

---

## Data Collection Standards

All tests use standardized data collection:

### CSV Format

```csv
test_id,scenario,group,timestamp,rule_attached,script_used,query_visible,consent_requested,notes
H1-001,"commit these changes",control,2025-10-15T14:30:00,yes,yes,no,no,""
H1-002,"save this work",control,2025-10-15T14:31:00,no,no,no,no,"missed routing"
```

### YAML Reports

```yaml
test: hypothesis-1-conditional-attachment
date: 2025-10-15
group: experimental
metrics:
  script_usage_rate: 91.2
  rule_attachment_rate: 100.0
  false_positive_rate: 5.0
comparison:
  baseline_usage: 73.5
  improvement: 17.7
  success: true
```

---

## Risk Register

### High Risks

| Risk                                           | Impact | Mitigation                                   | Owner                 |
| ---------------------------------------------- | ------ | -------------------------------------------- | --------------------- |
| Rule changes break functionality               | HIGH   | Backup all rules; revert on issues           | Test executor         |
| Tests create observer effect (assistant knows) | MEDIUM | Mix announced/unannounced trials             | Test executor         |
| Baseline insufficient (too few samples)        | MEDIUM | Use ≥50 trials per scenario                  | Measurement framework |
| CI integration fails PRs incorrectly           | HIGH   | Set conservative thresholds; manual override | CI team               |

### Medium Risks

| Risk                            | Impact | Mitigation                                      | Owner                |
| ------------------------------- | ------ | ----------------------------------------------- | -------------------- |
| Context bloat from always-apply | MEDIUM | Monitor token counts; optimize if >10% increase | H1 test              |
| Slash commands frustrate users  | MEDIUM | User feedback survey; refine prompts            | Slash cmd experiment |
| Visible output creates noise    | MEDIUM | Use concise format; survey users                | H2, H3 tests         |

---

## Test Artifacts

Each test should produce:

1. **Test log** (CSV): Raw trial data
2. **Analysis report** (YAML): Metrics and comparison
3. **Summary** (Markdown): Findings and recommendations
4. **Backup files**: Original rules before changes

**Storage Structure**:

```
tests/
  data/
    baseline/
      script-usage-baseline.csv
      tdd-compliance-baseline.csv
    h1-conditional-attachment/
      control-group.csv
      experimental-group.csv
      comparison.yaml
      summary.md
    h2-send-gate/
      test-a-visibility.csv
      test-b-accuracy.csv
      test-c-blocking.csv
      test-d-visible-gate.csv
      comparison.yaml
      summary.md
```

---

## Timeline Overview

### Conservative Estimate (Sequential)

- Week 1: Measurement framework + H1 (3 days)
- Week 2: H3 + H2 (4 days)
- Week 3: Slash commands experiment (2 days)
- Week 4: Integration test + reporting (3 days)
- **Total**: 4 weeks

### Aggressive Estimate (Parallel)

- Week 1: Measurement + H1 + H3 (5 days, parallel after measurement)
- Week 2: H2 + Slash commands (5 days, parallel)
- Week 3: Integration + reporting (3 days)
- **Total**: 3 weeks

**Recommended**: Conservative sequential approach for first iteration; parallel after learning

---

## Next Steps

1. **Review test plans** — Ensure all stakeholders understand approach
2. **Prioritize tests** — Confirm execution order
3. **Set up infrastructure** — Create test data directories, backup original rules
4. **Start with measurement framework** — Establish baseline before any changes
5. **Execute Phase 1** — H1 (conditional attachment) as first validation
6. **Iterate** — Refine tests based on findings; adjust priorities

---

## Questions & Discussion

For questions about test plans, file issues or discuss in:

- **Project ERD**: [erd.md](../erd.md)
- **Tasks**: [tasks.md](../tasks.md)
- **Discovery**: [discovery.md](../discovery.md)

---

**Status**: Test plans ready for execution  
**Owner**: rules-enforcement-investigation  
**Last Updated**: 2025-10-15  
**Version**: 1.0
