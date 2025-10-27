# Synthesis Work Plan

**Status**: DRAFT — Ready to execute after validation period  
**Estimated Effort**: 4-6 hours  
**Prerequisites**: H1 validation complete (30 commits), H2/H3 monitoring data available

---

## Current Data Summary

### H1: AlwaysApply (VALIDATED)

**Fix**: `assistant-git-usage.mdc` → `alwaysApply: true`

**Results** (30 commits):

- Script usage: **74% → 100%** (+26 points) ✅
- TDD compliance: **75% → 100%** (+25 points) ✅
- Overall: **68% → 86%** (+18 points) ✅

**Status**: ✅ **VALIDATED — Exceeds 90% target**

**Conclusion**: AlwaysApply is highly effective for critical git operations rules

### H2: Visible Gate (MONITORING)

**Fix**: Added explicit "OUTPUT this checklist" requirement to send gate

**Results** (Checkpoint 1):

- Gate visibility: **0% → 100%** (+100 points)
- Compliance impact: TBD (need more operations)

**Status**: ⏸️ Monitoring — Need 10-20 responses with various operations

**Preliminary**: Explicit output requirements create accountability

### H3: Query Visibility (MONITORING)

**Fix**: Added "OUTPUT: Checked capabilities.mdc for X: [result]" requirement

**Results**:

- Query visibility: Expected 0% → ~100% (same pattern as H2)
- Compliance impact: TBD (need more git operations)

**Status**: ⏸️ Monitoring — Passive accumulation

**Preliminary**: Transparency in script selection process

### Slash Commands (RESOLVED)

**Finding**: Runtime routing wrong — Cursor uses `/` for prompt templates, not runtime routing

**Status**: ✅ Platform constraint documented

**Follow-up**: Prompt templates unexplored (lower priority given H1 at 100%)

---

## Synthesis Phases

### Phase 1: Data Collection (Current — Passive)

**What**: Continue normal repository work, accumulate validation data

**Checkpoints**:

- ✅ H1: 30 commits analyzed (100% script usage, 100% TDD)
- ⏸️ H2: Need 10-20 responses with gate items (git ops, terminal commands, edits)
- ⏸️ H3: Need 10-20 git operations for query visibility measurement

**Timeline**: 1-2 weeks of natural work

**Exit Criteria**:

- H1: ✅ Already validated (100% compliance exceeds 90% target)
- H2: 10+ responses with diverse gate items observed
- H3: 10+ git operations with visible queries observed

### Phase 2: Analysis (After Data Collection)

**Estimated**: 2-3 hours

**Tasks**:

1. **Measure H2 effectiveness** (~30 min)

   - Count gate visibility rate (expect ~100%)
   - Measure compliance impact per gate item:
     - Script usage before/after
     - TDD gate before/after
     - Consent prompts before/after
   - Document: Which gate items improve compliance? Which don't?

2. **Measure H3 effectiveness** (~30 min)

   - Count query visibility rate (expect ~100%)
   - Compare script usage: already 100%, so measure sustained compliance
   - Document: Does visible query prevent future degradation?

3. **Combined effect analysis** (~1 hour)

   - H1 alone: +26 points (74% → 100%)
   - H1 + H2: TBD (measure if gate adds value on top of H1)
   - H1 + H3: TBD (likely redundant since H1 already 100%)
   - Document: Additive effects or diminishing returns?

4. **Cost-benefit analysis** (~30 min)
   - Context cost: H1 adds ~3k tokens (alwaysApply: true for git-usage)
   - UX cost: H2 adds visible gate output (is it noisy?)
   - UX cost: H3 adds visible query output (is it helpful?)
   - Value: Compliance 68% → 86%+ (target met)
   - Trade-offs: Which patterns worth keeping permanently?

### Phase 3: Decision Tree Creation (After Analysis)

**Estimated**: 1-2 hours

**Deliverable**: Enforcement pattern decision framework

**Structure**:

```
When choosing enforcement pattern for a rule:

1. Is the rule critical (violations have immediate negative impact)?
   ├─ YES → Consider alwaysApply (if <20 rules use it)
   │   └─ Context cost: ~3-4k tokens per rule
   └─ NO → Use conditional attachment + intent routing

2. Does the rule require tool/command selection?
   ├─ YES → Add visible query output ("Checked X for Y: [result]")
   │   └─ UX cost: 1 line per operation; transparency benefit high
   └─ NO → Skip query visibility

3. Does the rule have a pre-action checklist?
   ├─ YES → Add explicit OUTPUT requirement for checklist
   │   └─ UX cost: ~5 lines per action; accountability benefit high
   └─ NO → Skip gate visibility

4. Can the rule be enforced via CI/linting?
   ├─ YES → Prefer external validation (most reliable)
   │   └─ Examples: branch naming, commit format, test colocation
   └─ NO → Rely on assistant enforcement patterns above

5. Is the rule about guidance vs hard requirements?
   ├─ Guidance → Keep conditional; attach only when user requests
   └─ Hard requirements → Use patterns 1-4 above
```

**Output**: Markdown decision tree with examples for each branch

### Phase 4: Categorize 25 Conditional Rules (After Decision Tree)

**Estimated**: 1-2 hours

**Input**: List of 25 `alwaysApply: false` rules from discovery tasks 0.2.1

**Process**: Apply decision tree to each rule

**Output Format**:

```markdown
## Critical Rules → AlwaysApply Candidates

1. **assistant-git-usage.mdc** ✅ Already converted

   - Violations: High impact (bypass git standards)
   - Cost: ~3k tokens
   - Recommendation: Keep alwaysApply: true

2. **[Rule name]**
   - Violations: [frequency] / [impact]
   - Cost: [estimated tokens]
   - Recommendation: [alwaysApply | visible gate | routing | CI]

## High-Value Conditional Rules → Visible Gates

[Rules that benefit from query visibility or gate checklists]

## Low-Risk Conditional Rules → Current State

[Rules that work fine with conditional attachment]
```

**Validation**: Total alwaysApply rules should stay <25 (context budget)

### Phase 5: Documentation (Final)

**Estimated**: 1 hour

**Deliverables**:

1. **`synthesis.md`** — Main synthesis document

   - H1/H2/H3 results summary
   - Decision tree
   - Categorized recommendations for 25 rules
   - Implementation priorities


   - H1: Validated at 100%
   - H2: [Results after monitoring]
   - H3: [Results after monitoring]
   - Combined effectiveness


   - Check off Phase 6D items
   - Add any carryovers (prompt templates, optional follow-ups)

4. **Update `README.md`** — Reflect completion
   - Status: Complete (pending user approval)
   - Link to synthesis document
   - Final metrics

---

## Synthesis Outline (Tentative Structure)

**File**: `synthesis.md`

### 1. Executive Summary (1-2 paragraphs)

What we investigated, what we found, what changed

### 2. Validated Results

#### H1: AlwaysApply

- Data: 30 commits, 74% → 100%
- Conclusion: Highly effective for critical rules
- Scalability: Viable for ~20 rules max

#### H2: Visible Gate

- Data: [X responses, Y visibility rate, Z compliance impact]
- Conclusion: [Effective | Marginally helpful | Not significant]
- Recommendation: [Keep | Refine | Remove]

#### H3: Query Visibility

- Data: [X operations, Y visibility rate, Z compliance impact]
- Conclusion: [Sustains compliance | Redundant with H1 | Helpful transparency]
- Recommendation: [Keep | Optional | Remove]

### 3. Enforcement Pattern Decision Tree

[Tree from Phase 3 above]

### 4. Recommendations for 25 Conditional Rules

[Categorized list from Phase 4 above]

### 5. Implementation Priorities

**Immediate** (no-brainers):

- [Rules that clearly need alwaysApply]

**High-value** (good ROI):

- [Rules that benefit from visible gates/queries]

**Future** (lower priority):

- [Optional improvements, prompt templates]

**No action needed**:

- [Rules working fine as-is]

### 6. Meta-Lessons

- Testing paradox validated (real usage > prospective trials)
- Investigation-first saves time (don't assume, investigate)
- Simple fixes often best (one-line changes can be highly effective)
- Rules about rules are hard (self-referential violations during investigation)

---

## Exit Criteria for Synthesis Phase

**Ready to synthesize when**:

1. ✅ H1: 30 commits analyzed (100% compliance validated)
2. ⏸️ H2: 10-20 responses with diverse gate items
3. ⏸️ H3: 10-20 git operations with queries
4. ⏸️ Sufficient confidence in H2/H3 effectiveness (or determination that H1 is sufficient alone)

**Synthesis complete when**:

1. All 5 phases above executed
2. Decision tree created and validated
3. All 25 conditional rules categorized with recommendations
5. User review and approval obtained

---

## Current Status

**Data Collection**: ✅ H1 complete | ⏸️ H2/H3 monitoring  
**Analysis**: Not started (awaiting H2/H3 data)  
**Decision Tree**: Not started  
**Categorization**: Not started  
**Documentation**: Not started

**Next**: Continue normal work; check back after 10-20 more responses/operations
