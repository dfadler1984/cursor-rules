# Routing Optimization Project

**Status**: Phase 2 Complete ✅ — Ready for Phase 3 validation  
**Objective**: Improve intent routing accuracy from 68% baseline to >90% target  
**Owner**: repo-maintainers  
**Last Updated**: 2025-10-23

---

## Quick Navigation

**For Status & Progress** → [`tasks.md`](./tasks.md)  
**For Baseline Analysis** → [`analysis.md`](./analysis.md)  
**For Optimization Details** → [`optimization-proposal.md`](./optimization-proposal.md)  
**For Test Suite** → [`routing-test-suite.md`](./routing-test-suite.md)

---

## Project Overview

This project analyzes and optimizes the intent routing system that determines which rules are attached based on user requests. The work is based on extensive evidence from the rules-enforcement-investigation project (30+ commits, 16 meta-findings).

**Problem**: Current routing accuracy is 68% overall, with significant variation by intent type (60-90%). False positives and context bloat reduce efficiency.

**Solution**: Systematic optimizations to trigger patterns, decision policy, confidence scoring, and multi-intent handling.

---

## Current Status: Phase 2 Complete ✅

### ✅ Phase 1: Analysis (Complete)

**Deliverable**: [`analysis.md`](./analysis.md) — Comprehensive baseline with:

- Routing performance: 68% baseline (script usage 74%, TDD 75%, branch 61%)
- Top 10 intent patterns with accuracy rates (Implementation 75%, Guidance 90%+, etc.)
- 8 documented failure modes (Type 1: rules violated, Type 2: rules missing, Type 3: ambiguous)
- Measurement framework and success criteria

**Key Findings**:

- Implementation intents have lowest accuracy (60-75%) due to conditional attachment
- File signals sometimes override explicit intent (causes false positives)
- Multi-intent requests lack explicit handling
- Ambiguous phrasing causes misrouting (15-25% of requests)

---

### ✅ Phase 2: Optimization (Complete)

**Deliverables**:

1. **[`optimization-proposal.md`](./optimization-proposal.md)** — Comprehensive proposal with:

   - 4 key optimizations (intent override, confidence scoring, multi-intent, refined triggers)
   - Implementation plan (5 phases: 2A-2E)
   - Expected impact: +22% routing accuracy (68% → ≥90%)
   - Risk assessment and mitigation

2. **[`routing-test-suite.md`](./routing-test-suite.md)** — 25 test cases:

   - Group 1: Implementation (4 cases)
   - Group 2: Guidance (3 cases)
   - Group 3: Intent override (3 cases)
   - Group 4: Multi-intent (3 cases)
   - Group 5: Confidence disambiguation (3 cases)
   - Groups 6-10: Analysis, Testing, Refactoring, Git, Lifecycle (9 cases)

3. **Updated `.cursor/rules/intent-routing.mdc`** with:
   - **Explicit intent override tier** — Intent verbs override file signals (new tier 2)
   - **Refined triggers** — Top 10 intents expanded with exclusions, optional targets
     - Implementation: +2 verbs (build, create), +4 change terms, exclusions added
     - Testing: +2 verbs (improve, fix), exclusions added
     - Analysis: New trigger set (analyze|investigate|examine|explore|compare|evaluate|assess)
     - Refactoring: +3 verbs (restructure, simplify, optimize), pre-action gate
   - **Expanded confidence tiers** — High (95%+), Medium (60-94%), Low (<60%) with thresholds
   - **Multi-intent handling** — Plan-first default with explicit exception handling
   - **Confirmation prompt templates** — Guidance vs Implementation, Planning vs Implementing

**Optimizations Implemented**:

| Optimization                      | Expected Impact                                         | Implementation Status |
| --------------------------------- | ------------------------------------------------------- | --------------------- |
| Intent-based override (Tier 2)    | +5-10% guidance accuracy, -10-20% false positives       | ✅ Deployed           |
| Confidence-based disambiguation   | +10-15% ambiguous accuracy, -20-30% clarification loops | ✅ Deployed           |
| Multi-intent handling             | +5-10% multi-intent accuracy, -15-25% rework            | ✅ Deployed           |
| Refined triggers (top 10 intents) | +5-10% per intent type                                  | ✅ Deployed           |

**Total Expected Improvement**: 68% → ≥85% (interim), >90% (final after validation)

---

### ⏸️ Phase 3: Validation (Ready to Start)

**Tasks**:

- [ ] Run routing test suite (25 cases, manual validation)
- [ ] Deploy optimizations and monitor for 1 week
- [ ] Measure post-deployment metrics vs baseline
- [ ] Document findings and update intent-routing.mdc as needed

**Success Criteria**:

- Routing accuracy: >90% (≥23/25 tests pass)
- False positives: <5% (≤1/25 unnecessary rule attachments)
- Context efficiency: 30% reduction (3-5 → 2-3 avg rules per conversation)

**Validation Method**:

1. Send each test message in clean context
2. Observe which rules attach (via status update or behavior)
3. Compare actual vs expected
4. Mark PASS/FAIL for each case

**Decision Point**: If Phase 3 achieves <85% accuracy or >10% false positives, pause and revise optimizations.

---

## Key Insights & Evidence

### Evidence from Rules-Enforcement-Investigation

**Source**: 30+ commits analyzed, 16 meta-findings documented

**Proven Effectiveness**:

- ✅ **AlwaysApply** → +26 points (74% → 100% script usage)
- ✅ **Visible gates** → 0% → 100% visibility (transparency)
- ✅ **Explicit OUTPUT** requirements → 100% compliance
- 📊 **Conditional attachment** → 68% baseline (improvement opportunity)

**Failure Patterns Identified**:

1. **Type 1**: Rules exist but violated → Conditional attachment problem
2. **Type 2**: Rules missing, can't follow → Guidance not codified
3. **Type 3**: Ambiguous intent misrouted → Disambiguation needed

### Top Optimization Opportunities

| Pattern                | Baseline | Target | Strategy                                |
| ---------------------- | -------- | ------ | --------------------------------------- |
| Implementation intents | 75%      | 90%    | Refined triggers, exclusions            |
| Document creation      | 60%      | 85%    | Structure rule now exists (Gap #11 fix) |
| Guidance requests      | 90%+     | 95%+   | Intent override tier                    |
| File signal conflicts  | ~70%     | 90%+   | Intent override tier                    |
| Multi-intent requests  | ~70%     | 85%+   | Explicit handling                       |
| Ambiguous phrasing     | ~60%     | 80%+   | Confidence scoring                      |

---

## Related Work

### Rules-Enforcement-Investigation

**Project**: [rules-enforcement-investigation](../rules-enforcement-investigation/)  
**Key Deliverables**:

- [findings/README.md](../rules-enforcement-investigation/findings/README.md) — 16 meta-findings
- [analysis/synthesis.md](../rules-enforcement-investigation/analysis/synthesis.md) — Decision tree, 25-rule categorization
- [BASELINE-REPORT.md](../rules-enforcement-investigation/BASELINE-REPORT.md) — Compliance metrics

**Relevance**: Provides all baseline data, evidence of what works (AlwaysApply, visible gates), and failure patterns.

### Related Rules

- `.cursor/rules/intent-routing.mdc` — Updated with optimizations
- `.cursor/rules/user-intent.mdc` — Intent classification patterns
- `.cursor/rules/guidance-first.mdc` — Guidance vs implementation handling

---

## Timeline

| Phase   | Duration | Status      | Completion Date |
| ------- | -------- | ----------- | --------------- |
| Phase 1 | 2-3 hrs  | ✅ Complete | 2025-10-23      |
| Phase 2 | 4-6 hrs  | ✅ Complete | 2025-10-23      |
| Phase 3 | 1 week   | ⏸️ Ready    | TBD             |

**Total Effort**: 6-10 hours for analysis + optimization (complete), 1 week monitoring for validation (pending)

---

## Success Metrics

### Targets (from ERD)

| Metric             | Baseline  | Phase 2 Goal | Phase 3 Target | Current Status |
| ------------------ | --------- | ------------ | -------------- | -------------- |
| Routing accuracy   | 68%       | ≥85%         | >90%           | TBD (Phase 3)  |
| False positives    | TBD       | <10%         | <5%            | TBD (Phase 3)  |
| Context efficiency | 3-5 rules | 2.5-4 rules  | 2-3 rules      | TBD (Phase 3)  |
| Time to route      | TBD       | ≥90%         | >95%           | TBD (Phase 3)  |

### Validation Checkpoints

**Phase 2 Checkpoint** (before Phase 3):

- Run 10 sample test cases
- Expect ≥8/10 pass (80% as sanity check)
- If <80%, revise optimizations

**Phase 3 Final Validation**:

- Run full 25-case test suite
- Expect ≥23/25 pass (92% accuracy)
- Monitor in production for 1 week
- Collect ≥50 real messages, re-measure

---

## Next Steps

### Immediate (Phase 3 Start)

1. **Run Phase 2 Checkpoint**:

   - Select 10 representative test cases from routing-test-suite.md
   - Run manual validation
   - If ≥8/10 pass → proceed to full Phase 3
   - If <8/10 pass → revise optimizations

2. **Deploy to Production**:

   - Changes already in `.cursor/rules/intent-routing.mdc`
   - Monitor for regressions during normal work
   - Collect routing data for 1 week

3. **Run Full Test Suite**:
   - All 25 test cases
   - Document pass/fail for each
   - Calculate routing accuracy and false positive rate

### Follow-Up (Post-Phase 3)

- **If successful** (≥90% accuracy, <5% FP):

  - Document final results in `findings.md`
  - Update ERD with "Complete" status
  - Share insights with team

- **If partially successful** (85-89% accuracy):

  - Identify specific failure patterns
  - Propose targeted fixes
  - Re-test affected patterns

- **If unsuccessful** (<85% accuracy):
  - Analyze root causes
  - Consider alternative approaches (AlwaysApply for more rules, external validation)
  - Consult with maintainer on priorities

---

## Questions or Issues?

**For task status** → See [`tasks.md`](./tasks.md)  
**For technical details** → See [`optimization-proposal.md`](./optimization-proposal.md)  
**For test cases** → See [`routing-test-suite.md`](./routing-test-suite.md)  
**For evidence** → See [`analysis.md`](./analysis.md)

---

**Status**: Phase 2 complete, Phase 3 ready to start ✅  
**Next**: Run Phase 2 checkpoint (10 test cases) before full validation  
**Target**: >90% routing accuracy, <5% false positives
