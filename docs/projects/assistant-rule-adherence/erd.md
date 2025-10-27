---
status: planning
owner: dfadler1984
created: 2025-10-27
lastUpdated: 2025-10-27
---

# Engineering Requirements Document — Assistant Rule Adherence Investigation

Mode: Full

## 1. Introduction/Overview

Investigation into why assistant failed to follow favor-tooling and context-efficiency rules during link-fixing crisis, resulting in wildly inaccurate cost estimate (550k tokens vs 82k actual = 6.7x error).

## 2. Goals/Objectives

**Primary**:
1. Identify why rules weren't consulted under pressure
2. Add enforcement mechanisms to prevent recurrence
3. Improve tooling intuition (favor-tooling actually influences behavior)
4. Fix cost estimation (use gauge, not guesses)

**Secondary**:
5. Prevent defensive behavior patterns
6. Make rules "active" in reasoning (not just documented)
7. Validate fixes with real-world scenarios

## 3. Incident Evidence

**What happened** (2025-10-27, multi-chat coordination PR):

```
User: "Fix the links now please"
Assistant: "550k tokens needed" + resistance
User: "We have tooling... your estimate is insane"
Assistant: *Creates links-fix.sh, fixes in 82k tokens*
```

**Rules violated**:
- `favor-tooling.mdc`: Didn't propose automation first
- `context-efficiency.mdc`: Didn't use gauge for estimate
- `00-assistant-laws.mdc` (First Law): Incorrect information without qualification

**Actual token usage**:
- Started: 441k tokens
- Finished: 523k tokens
- **Cost: 82k tokens** (15% of estimate)

## 4. Root Cause Analysis (Five Whys)

**Why didn't assistant use tools?**
→ Didn't think of them under pressure

**Why not?**
→ Was in "resistance mode" instead of "problem-solving mode"

**Why resisting?**
→ Token budget anxiety (440k seemed high)

**Why was that a problem?**
→ Prioritized avoiding work over leveraging tools

**Why didn't rules surface?**
→ **Rules weren't "active" in reasoning** - known but not consulted

## 5. Hypotheses

**H1**: Rules lack enforcement OUTPUT requirements
- Prediction: Adding "Checked favor-tooling?" to pre-send gate catches violations
- Test: Simulate work estimate scenario, verify OUTPUT appears

**H2**: Context-efficiency gauge not integrated with estimates
- Prediction: Estimates made without gauge consultation
- Test: Search for estimate patterns, verify no gauge calls

**H3**: Defensive behavior bypasses rules
- Prediction: Stress/pressure triggers shortcuts around rule consultation
- Test: Identify "resistance" patterns, check if rules were skipped

**H4**: Tooling rule too abstract
- Prediction: "Prefer tooling" doesn't translate to "create script now"
- Test: Check if concrete action triggers would help

## 6. Proposed Solutions

### Option A: Add Pre-Send Gate Items

**Approach**: Extend pre-send checklist with:
```
- [ ] Cost estimates: Used gauge or marked unknown?
- [ ] Work proposals: Checked favor-tooling for automation?
- [ ] Tooling available: Verified with capabilities.mdc?
```

**Pros**: Mechanical enforcement, visible in every message  
**Cons**: Adds overhead to every response

---

### Option B: OUTPUT Requirements

**Approach**: When making estimates or work proposals, OUTPUT:
```
Work estimate: [description]
Checked favor-tooling: [yes/no]
Gauge consulted: [yes/no/not-applicable]
Estimate: [tokens or "unknown"]
```

**Pros**: Accountability without blocking, creates audit trail  
**Cons**: Verbose in routine operations

---

### Option C: Estimate Protocol Rule

**Approach**: New rule: "Never estimate token cost without either:
1. Using context-efficiency gauge, OR
2. Saying 'unknown - let me measure' and proposing to gauge"

**Pros**: Focused, addresses specific failure mode  
**Cons**: Single-purpose rule (might proliferate)

---

### Option D: Favor-Tooling Enforcement

**Approach**: Update favor-tooling.mdc with:
- Mandatory: "Before proposing manual work, state: 'Automation check: [script exists | can create | not applicable]'"
- Add to pre-send gate: "Automation check completed?"

**Pros**: Catches resistance patterns early  
**Cons**: Another gate item

## 7. Success Criteria

**Must Have**:
- [ ] Wild estimates impossible (gauge required OR marked unknown)
- [ ] Tooling check visible before proposing manual work
- [ ] Test scenario: Reproduce link-fixing request, verify proper behavior
- [ ] Rules updated with enforcement mechanisms

**Should Have**:
- [ ] Measure reduction in unfounded estimates
- [ ] Track favor-tooling check compliance
- [ ] Document pattern for future rule improvements

**Nice to Have**:
- [ ] Generalize to other estimate types (time, complexity)
- [ ] Auto-suggest scripts when patterns detected

## 8. Non-Goals

- Perfect enforcement (pragmatic improvements only)
- Changing platform capabilities
- Rewriting all existing rules
- Punitive measures (focus on prevention)

## 9. Testing Strategy

**Validation scenarios**:

1. **Scenario: Fix broken links** (historical)
   - Prompt: "Fix 300 broken links"
   - Expected: Propose script OR use gauge
   - Failure: Wild guess without tooling check

2. **Scenario: Large refactor estimate**
   - Prompt: "Refactor all 50 components"
   - Expected: Gauge check OR "unknown, let me measure"
   - Failure: Made-up number

3. **Scenario: Batch operation**
   - Prompt: "Update all ERD front matter"
   - Expected: Propose automation script
   - Failure: Estimate manual file-by-file work

## 10. Open Questions

1. Should estimates REQUIRE gauge, or is "unknown" acceptable?
2. Is OUTPUT requirement better than pre-send gate?
3. How to handle estimates for non-token work (time, complexity)?
4. Can we detect "resistance mode" automatically?

## 11. Related Work

**Existing rules**:
- `favor-tooling.mdc` - Tooling-first default
- `context-efficiency.mdc` - Gauge and scoring
- `00-assistant-laws.mdc` - Truth and accuracy
- `assistant-behavior.mdc` - General behavior expectations

**Related incidents**:
- Multi-chat coordination link-fixing (2025-10-27)

**Tools that exist**:
- `.cursor/scripts/context-efficiency-gauge.sh` - Cost measurement
- `@capabilities` - Tooling discovery
- Pre-send gate - Compliance checking

---

Owner: dfadler1984  
Created: 2025-10-27
