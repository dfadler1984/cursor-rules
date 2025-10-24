# Consent State Tracking Across Turns

**Purpose**: Define how to track consent state across conversation turns to enable consistent, context-aware consent behavior.

**Created**: 2025-10-24  
**Status**: Phase 2 deliverable

## Overview

**Problem**: Currently, consent decisions are made per-turn without tracking historical consent state, leading to:

- Repeated prompts for the same operation in a workflow
- Inconsistent behavior when context switches mid-conversation
- No visibility into what's been consented to in the session

**Solution**: Track consent state across turns with clear persistence rules and reset conditions.

## State Model

### Per-Operation State

```typescript
{
  "operation": string,          // e.g., "git-commit", "edit-file", "pr-create"
  "category": string,           // e.g., "git", "file-edit", "network"
  "risk": "safe" | "moderate" | "risky",
  "consentState": "granted" | "required" | "not-applicable",
  "source": "explicit" | "allowlist" | "composite" | "exception" | "slash-command",
  "grantedAtTurn": number,      // Which turn consent was granted
  "command": string | null,     // Exact command if applicable
  "expiresAt": "workflow-end" | "session-end" | "immediate"
}
```

### Session Allowlist State

```typescript
{
  "allowlist": [
    {
      "command": string,        // Exact command verbatim
      "addedAtTurn": number,    // When granted
      "usageCount": number      // How many times executed
    }
  ],
  "grantedBy": "user-explicit",
  "sessionId": string
}
```

### Workflow Context State

```typescript
{
  "workflowId": string,         // e.g., "implement-feature-X"
  "phase": "planning" | "implementing" | "testing" | "committing",
  "consentedOperations": string[],  // Operations consented for this workflow
  "deviations": number,         // Count of deviations from plan
  "lastPlanTurn": number        // Turn number of last concrete plan
}
```

## Persistence Rules

### State Lifetime by Source

**Slash commands** (`source: "slash-command"`):

- **Persistence**: Immediate (no state tracking needed)
- **Rationale**: Each slash command invocation is fresh consent
- **Example**: `/commit` always executes full workflow without checking prior state

**Explicit consent** (`source: "explicit"`):

- **Persistence**: Until workflow end or category switch
- **Expiry conditions**:
  - New workflow started (different feature/task)
  - Major context switch (different files/components)
  - User says "stop", "wait", or similar
- **Example**: User approves "implement feature X" → subsequent edits in same workflow don't re-ask

**Session allowlist** (`source: "allowlist"`):

- **Persistence**: Session-end or explicit revocation
- **Expiry conditions**:
  - User says "Revoke consent for: <command>"
  - User says "Revoke all consent"
  - Session ends (chat closed, context cleared)
- **Example**: "Grant standing consent for: git push" → all pushes this session execute without re-asking

**Composite consent-after-plan** (`source: "composite"`):

- **Persistence**: Single implementation of that specific plan
- **Expiry conditions**:
  - Plan fully executed
  - Plan modified or deviated from
  - > 3 turns since plan
- **Example**: User approves plan → implementation executes → new plan needs fresh consent

**Read-only exception** (`source: "exception"`):

- **Persistence**: Per-invocation (no state needed)
- **Rationale**: Each imperative request is independent
- **Example**: "Run `git status`" executes → next "run `git status`" still needs imperative request

### Risk-Based Persistence

**Tier 1 (Safe)**: No state tracking needed (execute on imperative request or slash command)

**Tier 2 (Moderate)**: Track per-category, expire at workflow end

- Once consented for "file-edit" category → all edits in workflow proceed
- Once consented for "git" category → local git ops in workflow proceed
- Category switch requires fresh consent

**Tier 3 (Risky)**: Always ask, never persist consent

- Each risky operation requires explicit consent
- No "once approved, always approved" behavior
- Example: Each `git push` requires consent, even if previous push approved

## State Reset Conditions

### Immediate Reset

Triggers that immediately clear all non-allowlist consent state:

1. **User stop commands**: "stop", "wait", "cancel", "hold on"
2. **Error or failure**: Command execution failed
3. **User correction**: "that's wrong", "do it differently"
4. **Major context switch**: Different project, different feature, different files

### Workflow End Reset

Triggers that reset workflow-scoped consent (keep session allowlist):

1. **Task completion**: Tests pass, PR created, feature complete
2. **User acknowledgment**: "done", "complete", "next task"
3. **Topic change**: User asks about different feature/component
4. **Timeout**: No activity for >10 turns

### Session End Reset

Triggers that clear all consent state including allowlist:

1. **Chat closed**: User closes chat window
2. **Context cleared**: Fresh context window starts
3. **Explicit revoke all**: User says "Revoke all consent"

## Consent Decision Algorithm with State

```
INPUT: User request, Current state, Turn number, Workflow context

STEP 1: Check for slash command
  IF slash_command(request):
    RETURN execute_immediately (no state needed)

STEP 2: Check for stop/reset trigger
  IF stop_trigger(request):
    CLEAR all non-allowlist state
    RETURN require_consent

STEP 3: Check session allowlist
  IF request matches allowlist_command:
    INCREMENT usage_count
    RETURN execute_and_announce

STEP 4: Determine operation and category
  operation = classify_operation(request)
  category = get_category(operation)
  risk = get_risk_tier(operation)

STEP 5: Check risk tier
  IF risk == "safe" AND imperative_request(request):
    RETURN execute_immediately (no state needed)

  IF risk == "risky":
    RETURN always_require_consent (never persist)

STEP 6: Check existing consent state (Tier 2 - moderate)
  existing = get_state(category, workflow_context)

  IF existing AND existing.consentState == "granted":
    IF same_workflow(existing.grantedAtTurn, current_turn):
      RETURN execute (consent persists in workflow)
    ELSE:
      CLEAR existing state
      GO TO STEP 7

STEP 7: Check composite consent
  IF composite_consent_applies(request, previous_turn):
    GRANT consent
    TRACK state with source="composite", expiresAt="workflow-end"
    RETURN execute

STEP 8: Require fresh consent
  ASK consent with context (first in category, new workflow, etc.)
  IF approved:
    GRANT consent
    TRACK state with appropriate expiry
    RETURN execute
  ELSE:
    RETURN rejected

OUTPUT: Decision + Updated state
```

## State Visibility

### For User

**Query commands**:

- `/allowlist` or "Show active allowlist" → Display session allowlist with usage counts
- "What have I consented to?" → Display current workflow consent state
- "Clear consent state" → Reset all non-allowlist consent

**Output format**:

```
Session Allowlist:
- git push (used 3 times)
- .cursor/scripts/pr-create.sh (used 1 time)

Current Workflow: "implement-feature-X"
- Consented operations: file-edit (granted turn 45), git-local (granted turn 52)
- No risky operations consented

To revoke: "Revoke consent for: <command>" or "Revoke all consent"
```

### For Assistant

**Status updates should include**:

- "Using session allowlist: git push"
- "Using workflow consent for file edits (granted turn 45)"
- "First git command in workflow, asking consent"
- "Risky operation, always requires consent"

**Transparency principle**: User should always know why consent was requested or skipped.

## Implementation Guidance

### Assistant Behavior

1. **Track state mentally** (no persistent storage across sessions)

   - Remember granted consent within conversation
   - Reset state at workflow boundaries
   - Clear risky operations immediately after use

2. **Be explicit about state**

   - Announce when using existing consent: "Using workflow consent for file edits"
   - Announce when requiring fresh consent: "New workflow, need consent for git operations"
   - Announce state resets: "Workflow complete, clearing consent state"

3. **Respect state boundaries**
   - Don't carry consent across major context switches
   - Always ask for risky operations
   - Honor session allowlist until revoked

### Rules Updates

Update the following rules to reference consent state tracking:

1. **assistant-behavior.mdc** → Add "Consent State Tracking" section
2. **intent-routing.mdc** → Update consent routing to check state
3. **user-intent.mdc** → Add state considerations to intent classification

## Edge Cases

### Case 1: Workflow Deviation

**Scenario**: User consents to plan A → mid-execution asks for plan B

**Handling**:

- Clear existing workflow consent state
- Treat plan B as new workflow
- Require fresh consent for plan B operations

### Case 2: Long Workflow

**Scenario**: Multi-hour workflow with 50+ turns

**Handling**:

- Maintain workflow consent state as long as same task
- Periodic confirmation: "Still working on feature X, consent still valid?"
- Reset if user confirms task complete

### Case 3: Partial Session Allowlist Revocation

**Scenario**: User granted 5 commands, wants to revoke 1

**Handling**:

- Support per-command revocation: "Revoke consent for: git push"
- Keep other commands in allowlist
- Announce updated allowlist

### Case 4: Context Window Boundary

**Scenario**: Approaching context limit, need to refresh

**Handling**:

- Before context refresh, ask: "Save session allowlist for next context?"
- If yes, include allowlist in handoff summary
- If no, treat new context as fresh session

### Case 5: Failed Operation

**Scenario**: Operation consented → execution fails

**Handling**:

- Keep workflow consent (failure doesn't invalidate consent)
- Retry same operation: no re-ask (already consented)
- Modified retry (different approach): ask fresh consent

## Test Scenarios

### Scenario 1: Category Persistence

**Turn 1**: User: "Implement feature X"  
**Turn 2**: Assistant asks consent for file edits  
**Turn 3**: User: "yes"  
**Turn 4**: Assistant edits file A (granted)  
**Turn 5**: Assistant edits file B (should not re-ask)

**Expected**: File edit consent persists in workflow

### Scenario 2: Category Switch

**Turn 1-5**: File edits (consented)  
**Turn 6**: Assistant: "Now I'll commit"  
**Expected**: Ask consent for git category (new category)

### Scenario 3: Risky Operation Doesn't Persist

**Turn 1**: User: "Push to remote"  
**Turn 2**: Assistant asks consent  
**Turn 3**: User: "yes"  
**Turn 4**: Assistant pushes (granted)  
**Turn 5**: User: "Push again"  
**Turn 6**: Assistant should ask consent again (risky = always ask)

**Expected**: No persistence for risky operations

### Scenario 4: Session Allowlist Persistence

**Turn 1**: User: "Grant standing consent for: git push"  
**Turn 2-50**: Multiple pushes execute without re-asking  
**Turn 51**: User: "Revoke consent for: git push"  
**Turn 52**: Next push requires consent

**Expected**: Allowlist persists until revoked

### Scenario 5: Workflow Reset

**Turn 1-10**: Implement feature X (file edits consented)  
**Turn 11**: User: "Actually, let's work on feature Y instead"  
**Turn 12**: Assistant should ask consent for file edits (new workflow)

**Expected**: Workflow context switch clears consent state

## Success Metrics

1. **Reduced redundant prompts**: ≤1 consent prompt per category per workflow
2. **Safety maintained**: 100% consent rate for risky operations
3. **User clarity**: ≥90% of users understand consent state (via feedback)
4. **Allowlist usage**: ≥50% of repeat commands use session allowlist

## Related

- See `.cursor/rules/assistant-behavior.mdc` for consent-first behavior
- See `consent-gates-refinement/risk-tiers.md` for risk classification
- See `consent-gates-refinement/composite-consent-signals.md` for composite consent detection
- See `consent-gates-refinement/erd.md` Section 7 for data model
