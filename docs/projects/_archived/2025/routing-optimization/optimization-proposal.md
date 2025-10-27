# Routing Optimization — Phase 2 Proposal

**Date**: 2025-10-23  
**Status**: Proposed optimizations for implementation

---

## Executive Summary

This document proposes targeted optimizations to improve intent routing accuracy from 68% baseline to >90% target, reduce false positives to <5%, and improve context efficiency by 30%.

**Approach**: Incremental improvements to `intent-routing.mdc` based on evidence from 30+ commits and 16 meta-findings.

**Priority**: Focus on high-frequency, high-impact patterns (Implementation, Testing, Guidance) which represent 60-70% of all intents.

---

## 1. Intent-Based Override of File Signals

### 1.1 Problem Statement

**Current Behavior**:

- File signal (`*.test.ts`) attaches implementation rules (testing.mdc, tdd-first.mdc)
- User asks guidance question while editing test file
- Implementation rules attached; guidance request missed
- Result: Wrong rule set, user gets implementation advice instead of guidance

**Evidence**:

- Pattern observed in analysis: file signals override explicit intent
- Decision policy (intent-routing.mdc line 145-154) doesn't prioritize explicit intent over file signals

**Impact**:

- Estimated 10-20% of guidance requests misrouted when file signal present
- False positive rate increased (unnecessary rules attached)

### 1.2 Proposed Solution

**Add explicit intent override tier** to decision policy:

```markdown
## Decision policy (weights)

1. Exact phrase triggers (highest)
   - `DRY RUN:` prefix takes precedence over all other triggers
2. **Explicit intent verbs (new tier)**
   - Guidance patterns ("how", "what", "should we") override file signals
   - Implementation patterns ("implement", "add", "fix") confirm file signals
3. Composite consent-after-plan (recent plan + consent phrase)
4. Keyword fallback (word-boundary intent words) if phrases not found
5. File/context signals (downgraded priority)
6. If still ambiguous, ask one clarifying question
```

**Implementation**:

- Add "Explicit intent override" section to intent-routing.mdc
- Document precedence: intent verbs > file signals
- Examples: "How should I test X?" in `foo.test.ts` → attach guidance-first, not testing

### 1.3 Expected Impact

- **Accuracy**: +5-10% for guidance requests
- **False positives**: -10-20% (fewer unnecessary rule attachments)
- **Context efficiency**: Reduced avg rules from 3-5 → 2.5-4 per conversation

### 1.4 Validation

**Test cases**:

1. Open `*.test.ts` + ask "How should I structure this?" → Expect: guidance-first (not testing)
2. Open `*.test.ts` + say "Implement login test" → Expect: testing + tdd-first (confirmed)
3. Open `*.md` + ask "Should we add X?" → Expect: guidance-first (no file signal conflict)

**Success criteria**: ≥18/20 test cases route correctly (90%)

---

## 2. Confidence-Based Disambiguation

### 2.1 Problem Statement

**Current Behavior**:

- Ambiguous phrasing causes misrouting
- "We need to handle X" unclear: guidance or implementation?
- Current handling: guess or attach multiple rule sets
- Result: Wrong rules attached OR excessive context bloat

**Evidence**:

- Soft phrasing ("should consider", "we probably need") misinterpreted
- Observed in rules-authoring scenarios (Gap #11 finding)

**Impact**:

- Estimated 15-25% of ambiguous requests misrouted
- User clarification loops increase time to route

### 2.2 Proposed Solution

**Implement confidence tiers with explicit prompts**:

```markdown
## Confidence tiers (expanded)

### High Confidence (95%+)

- Exact phrase match (e.g., "implement feature X")
- Strong synonym match with context confirmation
- Action: Attach rules immediately, proceed

### Medium Confidence (60-94%)

- Fuzzy match: edit distance ≤2 around key phrases
- Synonyms with partial context: "build" vs "implement"
- Soft phrasing with action terms: "should we implement X?"
- Action: Ask 1-line confirmation with explicit options
- Format: "Are you asking for [guidance on approaches] or [implementation of X]?"

### Low Confidence (<60%)

- Vague phrasing: "we need better X"
- Missing target or scope: "fix the errors"
- Conflicting signals: guidance verb + implementation context
- Action: Ask clarifying question, do not attach rules until answered
```

**Confirmation prompt templates**:

```markdown
### Medium Confidence Prompts

**Guidance vs Implementation**:
"Are you looking for guidance on approaches, or would you like me to implement something specific?"

**Planning vs Implementing**:
"Should I create a plan/spec first, or implement directly?"

**Multi-intent**:
"I see you mentioned both planning and implementing. Should I start with the plan?"
```

### 2.3 Expected Impact

- **Accuracy**: +10-15% for ambiguous requests
- **Clarification loops**: -20-30% (faster to correct route)
- **User experience**: Improved (explicit options vs guessing)

### 2.4 Validation

**Test cases**:

1. "We need better error handling" → Medium confidence → Ask guidance vs implementation
2. "Should we consider using Redis?" → Medium confidence → Ask guidance vs implementation
3. "Implement caching layer" → High confidence → Attach implementation rules immediately

**Success criteria**:

- ≥90% medium-confidence prompts correctly formatted
- ≥80% users confirm intent without additional clarification

---

## 3. Multi-Intent Handling

### 3.1 Problem Statement

**Current Behavior**:

- User says "Plan and implement X"
- Unclear which to do first
- Current: sometimes attach both rule sets, sometimes pick one
- Result: Confusion, rework, or wrong approach

**Evidence**:

- No explicit handling in intent-routing.mdc
- Observed in project work: plan requested but implementation started

**Impact**:

- Estimated 10-15% of requests contain multiple intents
- Rework cost when wrong order chosen

### 3.2 Proposed Solution

**Add explicit multi-intent handling**:

```markdown
## Multi-Intent Requests

When user message contains multiple intents:

### Detection Patterns

- "Plan and implement X"
- "Create spec then build Y"
- "Design and code Z"
- "Analyze and fix W"

### Default Resolution: Plan-First

1. Detect multiple intents
2. Default to planning/analysis phase first
3. Ask confirmation: "Should I start with [plan/spec/analysis], then [implement/build/fix]?"
4. Attach rules for first phase only
5. After completion, ask to proceed to second phase

### Exception: User Explicit Order

- "Implement first, then document" → Honor user's order
- "Skip planning, just build X" → Proceed to implementation
```

### 3.3 Expected Impact

- **Accuracy**: +5-10% for multi-intent requests
- **Rework**: -15-25% (correct order chosen upfront)
- **User satisfaction**: Improved (explicit confirmation)

### 3.4 Validation

**Test cases**:

1. "Plan and implement login" → Ask: "Start with plan, then implement?"
2. "Create ERD and generate tasks" → Proceed (known two-phase flow)
3. "Implement first, then test" → Honor user order (no confirmation)

**Success criteria**: ≥18/20 multi-intent cases correctly disambiguated

---

## 4. Refined Triggers for Top 10 Intents

### 4.1 Implementation (Rank #1, 75% accuracy → target 90%)

**Current triggers** (intent-routing.mdc):

```
- Triggers: <verb> + <change-term>
  - Verbs: implement|add|fix|update
  - Change terms: feature|bug|logic|behavior
```

**Proposed refinements**:

```markdown
- Implementation / Fix bug
  - Triggers: <verb> + <change-term> + [optional: target]
    - Verbs: implement|add|fix|update|build|create
    - Change terms: feature|bug|logic|behavior|functionality|component|module|service
    - Targets (optional): in <file>|for <component>|to <module>
  - Exclusions: "should we implement" (guidance), "plan to implement" (planning)
  - Composite signals:
    - Previous plan + consent phrase → route to implementation
    - File signal (_.ts, _.js) + implementation verb → confirm intent
  - Attach: tdd-first.mdc, code-style.mdc, testing.mdc
  - Pre-action gate: TDD pre-edit confirmation (per assistant-behavior.mdc)
```

**Validation**: Expect ≥90% accuracy with broader verbs and exclusions

### 4.2 Document Creation (Rank #2, 60% → target 85%)

**Current triggers**: None (file creation implicit)

**Proposed triggers**:

```markdown
- Document Creation (Investigation Projects)
  - Triggers: File creation in docs/projects/<slug>/
  - Auto-attach: investigation-structure.mdc (if project has >15 files)
  - Pre-action checklist: "Before creating file, determine category"
  - Categories: sessions/, findings/, analysis/, test-results/, decisions/
  - Threshold warnings:
    - 5-7 root files: "Consider organizing into folders"
    - 8+ root files: "Root exceeds threshold; run structure validator"
```

**Note**: Already improved with investigation-structure.mdc creation; monitor effectiveness

### 4.3 Git Operations (Rank #3, 100% → maintain)

**Current**: Fixed with alwaysApply: true for assistant-git-usage.mdc

**Proposed**: No changes (100% compliance achieved)

### 4.4 Analysis (Rank #4, 70% → target 85%)

**Current triggers**: None (implicit, ad-hoc)

**Proposed triggers**:

```markdown
- Analysis / Investigation
  - Triggers: <verb> + <analysis-term>
    - Verbs: analyze|investigate|examine|explore|compare|evaluate
    - Analysis terms: pattern|behavior|performance|issue|root cause|impact|options
  - Attach: guidance-first.mdc (ask before implementing)
  - Composite: If analysis → implementation, confirm transition
  - Related: May attach spec-driven.mdc if "analyze requirements" or similar
```

### 4.5 Testing (Rank #5, 75% → target 90%)

**Current triggers**:

```
- Create tests
  - Triggers: <verb> + <test-term>
    - Verbs: create|generate|add|write
    - Test terms: test|tests|spec|specs|unit test|jest
```

**Proposed refinements**:

```markdown
- Create tests / Testing
  - Triggers: <verb> + <test-term> + [optional: target]
    - Verbs: create|generate|add|write|improve|fix
    - Test terms: test|tests|spec|specs|unit test|jest|coverage|assertion|assertions
    - Targets (optional): for <module>|in <file>
  - File signals: _.test.ts, _.spec.ts → confirm testing intent
  - Attach: testing.mdc, tdd-first.mdc, test-quality.mdc
  - Exclusions: "how to test" (guidance), "test plan" (planning)
```

### 4.6 Guidance Requests (Rank #6, 90%+ → maintain)

**Current**: Working well with guidance-first.mdc

**Proposed**: Minor refinement for file signal override (covered in Section 1)

### 4.7 Planning (Rank #7, 85% → target 90%)

**Current triggers**: ERD and tasks-from-ERD work well

**Proposed**: Add general planning trigger

```markdown
- Planning / Specification
  - Triggers: <verb> + <plan-term>
    - Verbs: plan|specify|analyze|outline|draft|design
    - Plan terms: plan|spec|specification|analysis|acceptance bundle|requirements|design
  - Exclusions: "review plan" (analysis), "implement the plan" (implementation)
  - Attach: spec-driven.mdc, guidance-first.mdc
  - Related: create-erd.mdc (if "ERD" mentioned), generate-tasks-from-erd.mdc (if "tasks" mentioned)
```

### 4.8 Rule Maintenance (Rank #8, 80% → target 90%)

**Current**: Works reasonably well

**Proposed**: Add safeguard for scope confirmation

```markdown
- Rules authoring/maintenance
  - Triggers: <verb> + <rules-term>
    - Verbs: write|update|maintain|create|fix
    - Rules terms: rule|rules|front matter|rules validation|rule file
  - Attach: front-matter.mdc, rule-creation.mdc, rule-maintenance.mdc, rule-quality.mdc
  - **Safeguard (strengthened)**: Treat soft phrasing as plan-only
    - "we probably need a rule" → Ask: "Should I create rule proposal, or create the rule now?"
    - "should consider updating rule" → Ask: "Which rule, and what change?"
  - Scope confirmation (MUST): Before repo-wide edits, ask: "Target: single file or repo-wide?"
```

### 4.9 Refactoring (Rank #9, 75% → target 85%)

**Current triggers**:

```
- Refactoring
  - Triggers: <refactor-verb>
    - Verbs: refactor|extract|rename|reorganize
```

**Proposed refinements**:

```markdown
- Refactoring
  - Triggers: <refactor-verb> + [optional: target]
    - Verbs: refactor|extract|rename|reorganize|restructure|simplify|optimize
    - Targets (optional): <file>|<function>|<class>|<module>
  - Attach: refactoring.mdc, testing.mdc
  - Pre-action gate: Confirm tests exist before refactoring
  - TDD note: Refactoring should keep tests green (no TDD pre-edit unless changing behavior)
```

### 4.10 Project Lifecycle (Rank #10, 70% → target 85%)

**Current triggers**: Archive/complete/finalize work

**Proposed refinements**:

```markdown
- Project lifecycle (actions)
  - Triggers: <verb> + <lifecycle-term> with project target
    - Verbs: archive|archiving|finalize|complete|close|finish
    - Lifecycle terms: project|investigation|phase
    - Targets: path (docs/projects/<slug>) or bare slug
  - Attach: project-lifecycle.mdc
  - Scope confirmation: If slug ambiguous, ask: "Did you mean docs/projects/<slug>?"
  - On attach, propose helper:
    - Archive: suggest dry-run first (`--dry-run` flag)
    - Finalize: suggest final-summary-generate.sh
    - Validate: suggest project-lifecycle-validate-scoped.sh
```

---

## 5. Implementation Plan

### 5.1 Phase 2A: Trigger Refinements (1-2 hours)

**Tasks**:

1. Update intent-routing.mdc with refined triggers for top 10 intents
2. Add explicit intent override tier (Section 1)
3. Add exclusions for ambiguous patterns (guidance vs implementation)
4. Update few-shot examples with new patterns

**Validation**:

- Review updated triggers against 20 sample messages
- Expect ≥16/20 correct routing (80% as interim checkpoint)

### 5.2 Phase 2B: Confidence Scoring (1-2 hours)

**Tasks**:

1. Add confidence tiers section to intent-routing.mdc
2. Document confirmation prompt templates
3. Add medium-confidence examples (soft phrasing, synonyms)
4. Update fuzzy matching section with confidence thresholds

**Validation**:

- Test with 10 ambiguous messages
- Expect ≥9/10 correct confidence tier assignments (90%)

### 5.3 Phase 2C: Multi-Intent Handling (1 hour)

**Tasks**:

1. Add multi-intent detection patterns
2. Document default resolution (plan-first)
3. Add confirmation prompt templates
4. Add exception handling (user explicit order)

**Validation**:

- Test with 10 multi-intent messages
- Expect ≥9/10 correct handling (90%)

### 5.4 Phase 2D: Test Suite Creation (2-3 hours)

**Tasks**:

1. Create `routing-validate.sh` script
2. Document ≥20 test cases covering:
   - Top 10 intent patterns (2 cases each minimum)
   - Edge cases (ambiguous, multi-intent, conflicting signals)
   - File signal override scenarios
3. Implement automated validation (expected vs actual rules attached)
4. Add to CI workflow (optional)

**Success criteria**:

- ≥18/20 test cases pass (90% accuracy)
- False positive rate <5% (≤1 unnecessary rule per 20 cases)

### 5.5 Phase 2E: Redundancy Reduction (1-2 hours)

**Tasks**:

1. Audit intent-routing.mdc for duplicate content
2. Replace duplicated guidance with cross-references
3. Consolidate related patterns (implementation + testing)
4. Apply progressive attachment principle (thin rules first)

**Expected**:

- Reduce intent-routing.mdc size by 10-15% (~25-35 lines)
- Improve scannability and maintenance

---

## 6. Success Metrics & Validation

### 6.1 Target Metrics (from ERD)

| Metric             | Baseline  | Target | Phase 2 Goal              |
| ------------------ | --------- | ------ | ------------------------- |
| Routing accuracy   | 68%       | >90%   | ≥85% (interim checkpoint) |
| False positives    | TBD       | <5%    | <10% (interim)            |
| Context efficiency | 3-5 rules | 2-3    | 2.5-4 rules (interim)     |
| Time to route      | TBD       | >95%   | ≥90% first response       |

### 6.2 Validation Approach

**Before deploying**:

1. Review each optimization against ≥10 sample messages
2. Measure accuracy: (correct routes) / (total messages) × 100%
3. Measure false positives: (unnecessary rules) / (total rules) × 100%
4. If metrics meet interim goals (≥85% accuracy, <10% FP), proceed to deployment

**After deployment**:

1. Monitor for 1 week during normal work
2. Collect ≥50 messages across diverse intents
3. Re-measure metrics and compare to baseline
4. Target: >90% accuracy, <5% false positives by end of Phase 3

---

## 7. Risk Assessment & Mitigation

### 7.1 Risks

**Risk 1: Over-optimization complexity**

- Adding too many rules/tiers may increase confusion
- Mitigation: Keep changes minimal; one tier at a time

**Risk 2: False positives increase**

- Broader verbs may match unintended patterns
- Mitigation: Add explicit exclusions; validate with test suite

**Risk 3: Context bloat**

- More rules in routing logic may increase token cost
- Mitigation: Use progressive attachment; cross-reference instead of duplicating

**Risk 4: Regression in current patterns**

- Changes may break existing working triggers
- Mitigation: Test against baseline cases; compare before/after

### 7.2 Rollback Plan

If Phase 2 optimizations cause regressions:

1. Revert changes to intent-routing.mdc
2. Re-baseline metrics
3. Identify specific broken patterns
4. Re-implement one optimization at a time with targeted fixes

---

## 8. Next Steps

**Immediate**:

1. Review this proposal with maintainer (user approval)
2. Begin Phase 2A: Trigger refinements
3. Validate interim checkpoint (≥85% accuracy, <10% FP)

**After approval**:

1. Implement Phases 2A-2E sequentially
2. Create test suite (routing-validate.sh)
3. Deploy and monitor for 1 week
4. Proceed to Phase 3: Validation & measurement

**Decision point**: If interim checkpoint fails (accuracy <85% or FP >10%), pause and reassess before proceeding.

---

**Status**: Proposal ready for review  
**Estimated effort**: 6-10 hours for full Phase 2 implementation  
**Expected outcome**: Routing accuracy 68% → ≥85% (interim), >90% (final)
