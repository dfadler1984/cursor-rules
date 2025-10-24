---
status: active
owner: repo-maintainers
lastUpdated: 2025-10-11
---

# Engineering Requirements Document — Routing Optimization

## 1. Introduction/Overview

Conduct a deep dive on the current intent routing implementation to identify and fix inefficiencies, improve accuracy, and optimize the user experience.

**Context**: Routing is working "ok" but has room for improvement. Need to analyze current behavior, identify patterns of misrouting or unnecessary friction, and propose targeted optimizations.

### Uncertainty / Assumptions

- [NEEDS CLARIFICATION: What specific routing failures or delays have you observed?]
- Assumption: Current routing logic is in `intent-routing.mdc` (archived) and may need successor implementation

## 2. Goals/Objectives

- Analyze current routing behavior across common use cases
- Identify patterns of misrouting, over-attachment, or missed signals
- Reduce routing latency and context bloat
- Improve accuracy of intent detection
- Minimize false positives (attaching rules when not needed)

## 3. User Stories

- As a user, I want the assistant to quickly and accurately detect my intent without unnecessary clarification loops
- As a user, I want minimal context bloat from irrelevant rule attachments
- As a maintainer, I want clear signals when routing fails or needs adjustment

## 4. Functional Requirements

### 4.1 Analysis Phase

1. Audit recent conversations for routing decisions (correct/incorrect/delayed)
2. Identify high-frequency intent patterns and their routing outcomes
3. Measure: time-to-correct-route, false-positive rate, context overhead
4. Document common failure modes (ambiguous signals, conflicting triggers, etc.)

### 4.2 Optimization Phase

1. Refine trigger patterns for top 10 most-used intents
2. Implement disambiguation logic for overlapping triggers
3. Add confidence scoring for medium-certainty matches
4. Create routing test suite with expected outcomes
5. Reduce redundant rule content via better cross-references

## 5. Non-Functional Requirements

- Routing decision should complete within first assistant response
- False positive rate < 5% (attaching wrong rules)
- Context overhead: attach minimum necessary rule set
- Backward compatible: existing explicit triggers must continue working

## 6. Architecture/Design

### Current State

- Intent detection via `intent-routing.mdc` patterns
- Phrase matching + keyword fallback + file signals
- No quantitative confidence scoring
- No post-hoc validation of routing accuracy

### Proposed Improvements

- **Confidence tiers**: High (exact phrase) → Medium (fuzzy) → Low (ambiguous)
- **Disambiguation prompts**: Single clarifying question for medium confidence
- **Routing validation**: Script to check intent → rules mapping
- **Metrics dashboard**: Track routing accuracy over time (manual or automated)

## 7. Data Model and Storage

### Routing Metrics (optional tracking)

```typescript
{
  "timestamp": "ISO-8601",
  "intent": "implement|plan|test|refactor|...",
  "trigger": "explicit-verb|consent-after-plan|file-signal",
  "confidence": "high|medium|low",
  "rulesAttached": ["tdd-first.mdc", "testing.mdc"],
  "outcome": "correct|false-positive|missed|delayed"
}
```

## 8. API/Contracts

### Routing Decision Output

```json
{
  "intent": "implement",
  "targets": ["file/path.ts"],
  "rules": ["tdd-first", "code-style"],
  "gates": ["consent", "tdd-owner-spec"],
  "consentState": "required"
}
```

## 9. Integrations/Dependencies

- Related: `intent-routing.mdc` (archived)
- Related: `user-intent.mdc` (classification patterns)
- Related: `guidance-first.mdc` (guidance vs implementation routing)
- Scripts: Consider adding `.cursor/scripts/routing-validate.sh`

## 10. Edge Cases and Constraints

- **Ambiguous phrasing**: "We need to X" (guidance or implementation?)
- **Multi-intent requests**: User asks for plan + implementation in one message
- **Context switching**: User changes intent mid-conversation
- **Composite signals**: Previous plan + consent phrase (consent-after-plan)

## 11. Testing & Acceptance

### Test Cases

1. Explicit verbs: "implement X" → attach tdd-first, testing
2. Guidance questions: "How should I X?" → attach guidance-first, NOT tdd-first
3. Composite consent: Previous plan + "go ahead" → route to implementation
4. File signals: Open .test.ts file → attach testing rules
5. Ambiguous: "We need better error handling" → ask clarification, don't auto-attach

### Acceptance Criteria

- [ ] Documented: baseline routing accuracy from recent conversations
- [ ] Analyzed: top 10 intent patterns with success/failure rates
- [ ] Implemented: confidence-based disambiguation for medium matches
- [ ] Tested: routing test suite with ≥20 cases covering edge cases
- [ ] Validated: false-positive rate reduced by ≥50% from baseline

## 12. Rollout & Ops

1. Run baseline analysis on recent conversations (manual review)
2. Implement optimizations in phases (trigger refinement → confidence scoring → validation)
3. Add routing test suite to CI (optional)
4. Monitor false-positive rate for 1 week post-deployment

## 13. Success Metrics

### Objective Measures

- **Routing accuracy**: % of correct intent detections (target: >90%)
- **False positives**: % of unnecessary rule attachments (target: <5%)
- **Context efficiency**: Average # of rules attached per conversation (target: reduce by 30%)
- **Time to route**: % of intents routed in first response (target: >95%)

### Qualitative Signals

- User reports faster, more accurate responses
- Fewer clarification loops for clear intents
- Reduced "why did you attach this rule?" questions

## 14. Open Questions

### Resolved in Phase 2 ✅

1. ~~**Measurement**: How to automatically measure routing accuracy without manual review?~~
   - **Resolved**: Manual validation with test suite (25 cases); automated script proposed for future
2. ~~**Confidence scoring**: What heuristics best predict correct routing?~~
   - **Resolved**: High (95%+), Medium (60-94%), Low (<60%) thresholds; fuzzy matching + soft phrasing detection
3. ~~**Fallback behavior**: When confidence is low, should we ask or default to minimal rules?~~
   - **Resolved**: Ask clarifying question, do not attach rules until answered
4. ~~**Multi-intent**: How to handle requests with multiple intents (e.g., "plan and implement")?~~
   - **Resolved**: Plan-first default with explicit exceptions; confirmation prompt for composite intents

### Remaining Open Questions

5. **Related to slash-commands**: Should high-ambiguity operations require slash commands for clarity?
   - **Status**: Deferred (slash commands runtime routing not viable; prompt templates unexplored)

### Minor Enhancements (Non-Blocking)

6. **Guidance trigger explicitness** (Gap identified in Phase 2 validation):
   - **Issue**: Guidance patterns documented in decision policy tier 2, but no dedicated "Guidance Requests" trigger section
   - **Current behavior**: Works correctly (guidance-first.mdc attached via intent classification)
   - **Recommendation**: Add explicit Guidance trigger section for consistency and documentation clarity
   - **Impact**: Low (routing functional, documentation improvement only)
   - **Priority**: Optional enhancement for Phase 3 or post-deployment

---

Owner: repo-maintainers  
Created: 2025-10-11  
Motivation: Routing working "ok" but has optimization opportunities; need deep dive to improve accuracy and efficiency
