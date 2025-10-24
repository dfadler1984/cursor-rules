# Composite Consent-After-Plan Signal Detection

**Purpose**: Improve detection of when a user's consent phrase after a plan should trigger implementation without re-prompting.

**Created**: 2025-10-24  
**Status**: Phase 2 deliverable

## Current State

**Current behavior** (from `user-intent.mdc` and `assistant-behavior.mdc`):

- If previous assistant message proposed concrete code edits
- AND user replies within one turn with a consent phrase
- THEN classify as implementation consent

**Current consent phrases**:

- "Go ahead"
- "Yes"
- "proceed"
- "sounds good"
- "do it"
- "ship it"

**Current issues**:

- "Within one turn" is ambiguous (does it mean immediately next turn? Or within same conversation?)
- "Concrete code edits" not clearly defined
- No handling of plan modifications ("do X but change Y")
- No handling of deviations ("that's fine, but also do Z")
- No confidence threshold for fuzzy matches

## Improved Signal Detection

### 1. Consent Phrase Recognition

**High-confidence phrases** (exact match, case-insensitive):

- "go ahead"
- "proceed"
- "yes"
- "yep"
- "yeah"
- "sounds good"
- "looks good"
- "do it"
- "ship it"
- "make it so"
- "let's do it"
- "let's go"
- "approved"
- "confirmed"

**Medium-confidence phrases** (fuzzy match, require confirmation):

- "ok" / "okay" (might be acknowledgment, not consent)
- "sure" (might be uncertain agreement)
- "fine" (might be reluctant)
- "that works" (might need clarification)

**Negative phrases** (explicit rejection):

- "no"
- "don't"
- "wait"
- "hold on"
- "not yet"
- "stop"
- "cancel"

### 2. Plan Concreteness Criteria

A plan is **concrete** when it includes:

1. **Target specificity**: Named files, functions, or components

   - ✅ "I'll update `parse.ts` function `handleEntry`"
   - ❌ "I'll update the parser"

2. **Change description**: Specific edits with before/after or clear action

   - ✅ "Add error handling for empty entries"
   - ❌ "Improve error handling"

3. **Scope boundary**: Clear start and end points

   - ✅ "I'll add validation to lines 23-45"
   - ❌ "I'll refactor the module"

4. **Success criteria** (optional but strong signal):
   - ✅ "Test should pass: 'handles empty entries'"
   - ❌ No mention of testing or validation

**Concreteness score**:

- 3-4 criteria met: High (proceed on consent phrase)
- 2 criteria met: Medium (ask confirmation)
- 0-1 criteria met: Low (don't treat as concrete plan)

### 3. Turn Proximity Detection

**Definition of "within one turn"**:

**Immediate next turn** (highest confidence):

- User message directly follows assistant plan
- No intervening messages
- No context switches
- Same topic/task

**Same workflow** (medium confidence):

- User message within 1-3 turns of plan
- Same topic maintained
- No major context switches
- May have had clarifying questions in between

**Stale plan** (low confidence, don't apply):

- > 3 turns since plan
- Different topic discussed
- New request started
- Previous plan superseded

### 4. Plan Modification Detection

**Modification indicators**:

**Approval with change** (requires re-confirmation):

- "yes, but [change]"
- "sounds good, except [modification]"
- "do it, but also [addition]"
- "proceed, but skip [subtraction]"
- → Acknowledge modification, present updated plan, ask "Proceed with this adjusted version?"

**Partial approval** (requires clarification):

- "do the first part"
- "just do X"
- "not sure about Y"
- → Ask: "Should I proceed with [specified subset] only?"

**Approval with question** (answer first, then proceed):

- "yes, but will this affect Z?"
- "sounds good, does this handle edge case W?"
- → Answer question, then ask: "Satisfied with the answer? Proceed with the original plan?"

### 5. Deviation Handling

**Plan deviation scenarios**:

**During execution** (user notices something):

- Implementation starts
- User: "wait, that's wrong" or "actually, do it differently"
- → Stop immediately, acknowledge, ask for correction

**After partial execution** (plan midway):

- Some changes made
- User: "change direction: [new approach]"
- → Summarize what's done, ask: "Keep existing changes and add [new], or revert and start fresh?"

**Plan complete, user adds more** (scope expansion):

- Original plan executed
- User: "also do [additional work]"
- → Treat as new request (not composite consent continuation)

## Detection Algorithm

```
INPUT: User message, Previous assistant message, Turn proximity

STEP 1: Check turn proximity
  IF turns_since_plan > 3 OR topic_changed:
    RETURN not_composite_consent

STEP 2: Check plan concreteness
  score = count_met_criteria(previous_message)
  IF score < 2:
    RETURN not_composite_consent

STEP 3: Detect consent phrase
  phrase_confidence = match_consent_phrase(user_message)

  IF phrase_confidence == "high":
    GO TO STEP 4
  ELIF phrase_confidence == "medium":
    ASK "Just to confirm, you want me to proceed with the plan?"
    IF user confirms: GO TO STEP 4
    ELSE: RETURN not_composite_consent
  ELSE:
    RETURN not_composite_consent

STEP 4: Check for modifications
  has_modification = detect_modification_indicators(user_message)

  IF has_modification:
    PRESENT updated plan with modifications
    ASK "Proceed with this adjusted version?"
    RETURN wait_for_confirmation
  ELSE:
    RETURN composite_consent_confirmed

OUTPUT: composite_consent_confirmed | not_composite_consent | wait_for_confirmation
```

## Implementation Guidance

### In `assistant-behavior.mdc`

Update the composite consent-after-plan section (line 142-145) to reference this document and include:

1. High-confidence consent phrase list
2. Concreteness criteria summary
3. Turn proximity definition (immediate next turn)
4. Link to full signal detection document

### In `user-intent.mdc`

Update the composite signals section (line 52-54) to:

1. Reference consent phrase list
2. Define "concrete code edits" with criteria
3. Specify "within one turn" as immediate next turn
4. Add handling for modifications and deviations

### In `intent-routing.mdc`

Update composite consent-after-plan routing (line 73) to:

1. Check concreteness score before routing
2. Handle medium-confidence phrases with confirmation
3. Detect modifications and re-route to plan adjustment
4. Track deviation scenarios

## Test Scenarios

### Scenario 1: High Confidence, Immediate Consent

**Turn 1** (Assistant):

```
I'll update parse.ts line 45 to handle empty entries:
- Add null check before processing
- Return early with error message
Test: "handles empty entries" should pass
Proceed?
```

**Turn 2** (User): "go ahead"

**Expected**: Execute immediately without re-asking

### Scenario 2: Medium Confidence, Requires Confirmation

**Turn 1** (Assistant): [concrete plan]
**Turn 2** (User): "ok"

**Expected**: "Just to confirm, you want me to proceed with the plan?"

### Scenario 3: Consent with Modification

**Turn 1** (Assistant): "I'll update parse.ts and add tests. Proceed?"
**Turn 2** (User): "yes, but skip the tests for now"

**Expected**:

- Acknowledge modification
- Present adjusted plan: "I'll update parse.ts (skip tests for now)"
- Ask: "Proceed with this adjusted version?"

### Scenario 4: Low Concreteness

**Turn 1** (Assistant): "I can improve the parser. Want me to?"
**Turn 2** (User): "sounds good"

**Expected**: Don't treat as composite consent (plan not concrete enough)

### Scenario 5: Stale Plan

**Turn 1** (Assistant): [concrete plan]
**Turn 2** (User): "what about X?"
**Turn 3** (Assistant): [answers about X]
**Turn 4** (User): "how does Y work?"
**Turn 5** (Assistant): [explains Y]
**Turn 6** (User): "ok proceed"

**Expected**: Don't treat as composite consent (>3 turns, stale plan)

### Scenario 6: Plan Deviation Mid-Execution

**Turn 1** (Assistant): [concrete plan] "Proceed?"
**Turn 2** (User): "yes"
**During execution**: User: "wait, do it differently: [new approach]"

**Expected**:

- Stop immediately
- Summarize what's done
- Ask for correction guidance

## Success Criteria

Implementation is successful when:

1. **High-confidence consents execute without re-asking** (target: 95%+ accuracy)
2. **Medium-confidence consents get confirmation** (no false positives)
3. **Modifications detected and handled appropriately** (no silent plan changes)
4. **Stale plans rejected** (no action on out-of-context consent)
5. **User feedback positive**: "feels natural", "doesn't over-prompt"

## Related

- See `.cursor/rules/assistant-behavior.mdc` → Composite consent-after-plan
- See `.cursor/rules/user-intent.mdc` → Implementation Requests → Composite signals
- See `.cursor/rules/intent-routing.mdc` → Composite consent-after-plan
- See `consent-gates-refinement/risk-tiers.md` for operation risk classification
