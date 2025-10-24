# Consent Decision Flowchart

**Purpose**: Quick reference flowchart for determining consent requirements for any user request.

**Created**: 2025-10-24  
**Status**: Phase 2 deliverable

## Quick Decision Tree

```
┌─────────────────────────────┐
│   User Request Received     │
└──────────┬──────────────────┘
           │
           v
     ╔═════════════════════╗
     ║ Is it a slash       ║
     ║ command?            ║
     ║ (/commit, /pr, etc) ║
     ╚══════┬══════════════╝
            │
      ┌─────┴─────┐
      │YES        │NO
      v           v
   ┌────────────┐  ╔═══════════════════╗
   │ EXECUTE    │  ║ Check for stop/   ║
   │ IMMEDIATELY│  ║ reset trigger?    ║
   │ (no prompt)│  ║ (stop, wait, etc) ║
   └────────────┘  ╚════┬══════════════╝
                        │
                  ┌─────┴─────┐
                  │YES        │NO
                  v           v
            ┌───────────┐  ╔════════════════════╗
            │ CLEAR     │  ║ Is command on      ║
            │ STATE &   │  ║ session allowlist? ║
            │ REQUIRE   │  ╚════┬═══════════════╝
            │ CONSENT   │       │
            └───────────┘  ┌────┴────┐
                           │YES      │NO
                           v         v
                     ┌────────────┐  ╔══════════════════╗
                     │ EXECUTE &  │  ║ Classify         ║
                     │ ANNOUNCE   │  ║ operation risk   ║
                     │ INCREMENT  │  ╚════┬═════════════╝
                     │ COUNT      │       │
                     └────────────┘       v
                                    ┌─────────────┐
                                    │ Tier 1      │
                                    │ (Safe)      │
                                    └──────┬──────┘
                                           │
                                      ┌────┴────┐
                                      │ Is it   │
                                      │ imperative│
                                      │ + exact │
                                      │ match?  │
                                      └────┬────┘
                                           │
                                     ┌─────┴─────┐
                                     │YES        │NO
                                     v           v
                               ┌──────────┐  ╔════════════╗
                               │ EXECUTE  │  ║ REQUIRE    ║
                               │ (announce)│  ║ CONSENT    ║
                               └──────────┘  ╚════════════╝

                                    ┌─────────────┐
                                    │ Tier 2      │
                                    │ (Moderate)  │
                                    └──────┬──────┘
                                           │
                                      ┌────┴────┐
                                      │ Check   │
                                      │ existing│
                                      │ workflow│
                                      │ consent │
                                      └────┬────┘
                                           │
                                     ┌─────┴─────┐
                                     │Granted in │
                                     │same       │
                                     │workflow   │
                                     │& category?│
                                     └─────┬─────┘
                                           │
                                     ┌─────┴─────┐
                                     │YES        │NO
                                     v           v
                               ┌──────────┐  ╔══════════════╗
                               │ EXECUTE  │  ║ Check        ║
                               │ (use     │  ║ composite    ║
                               │ existing)│  ║ consent?     ║
                               └──────────┘  ╚═══════┬══════╝
                                                     │
                                              ┌──────┴──────┐
                                              │Plan concrete│
                                              │+ consent    │
                                              │phrase +     │
                                              │immediate?   │
                                              └──────┬──────┘
                                                     │
                                              ┌──────┴──────┐
                                              │YES          │NO
                                              v             v
                                        ┌──────────┐   ┌─────────┐
                                        │ EXECUTE  │   │ REQUIRE │
                                        │ (grant & │   │ CONSENT │
                                        │ track)   │   │ (first  │
                                        └──────────┘   │ in cat) │
                                                       └─────────┘

                                    ┌─────────────┐
                                    │ Tier 3      │
                                    │ (Risky)     │
                                    └──────┬──────┘
                                           │
                                           v
                                    ┌──────────────┐
                                    │ ALWAYS       │
                                    │ REQUIRE      │
                                    │ CONSENT      │
                                    │ (never       │
                                    │ persist)     │
                                    └──────────────┘
```

## Decision Matrix

| Check                               | Priority    | If TRUE                      | If FALSE        |
| ----------------------------------- | ----------- | ---------------------------- | --------------- |
| Slash command?                      | 1 (Highest) | Execute immediately          | Continue checks |
| Stop trigger?                       | 2           | Clear state, require consent | Continue checks |
| Session allowlist?                  | 3           | Execute & announce           | Continue checks |
| Tier 1 + imperative?                | 4           | Execute (announce)           | Require consent |
| Tier 2 + existing workflow consent? | 5           | Execute (use existing)       | Check composite |
| Tier 2 + composite consent?         | 6           | Execute (grant & track)      | Require consent |
| Tier 3?                             | 7           | Always require consent       | N/A             |

## Detailed Decision Points

### 1. Slash Command Check (Highest Priority)

**Input**: User message  
**Check**: Message starts with `/` followed by known command  
**Known commands**: `/commit`, `/pr`, `/branch`, `/allowlist`, `/status`, `/diff`

**Decision**:

- ✅ **TRUE**: Execute immediately without any other checks
- ❌ **FALSE**: Continue to next check

**Rationale**: Slash command invocation IS the consent. No additional prompts needed.

### 2. Stop/Reset Trigger Check

**Input**: User message  
**Check**: Message contains stop phrases  
**Stop phrases**: "stop", "wait", "cancel", "hold on", "not yet"

**Decision**:

- ✅ **TRUE**: Clear all non-allowlist consent state, require fresh consent
- ❌ **FALSE**: Continue to next check

**Rationale**: User stop commands invalidate all existing consent.

### 3. Session Allowlist Check

**Input**: Requested command, Session allowlist state  
**Check**: Exact command match in allowlist

**Decision**:

- ✅ **TRUE**: Execute, announce ("Using session allowlist: <command>"), increment usage count
- ❌ **FALSE**: Continue to next check

**Rationale**: User granted standing consent for this session.

### 4. Risk Tier Classification

**Input**: Operation type, Command  
**Output**: Tier 1 (Safe) | Tier 2 (Moderate) | Tier 3 (Risky)

**Classification**:

- **Tier 1**: Read-only, local, no side effects
- **Tier 2**: Local modifications, reversible, no remote effects
- **Tier 3**: Remote operations, destructive, security-sensitive

### 5. Tier 1 (Safe) - Imperative Check

**Input**: User message, Command  
**Check**: Imperative phrasing ("run ...", "show ...") + exact command match

**Decision**:

- ✅ **TRUE**: Execute (announce command before execution)
- ❌ **FALSE**: Require consent

**Examples**:

- "Run `git status`" → Execute
- "Show me the branches" → Require consent (not exact command)

### 6. Tier 2 (Moderate) - Workflow Consent Check

**Input**: Category, Current workflow state, Turn number  
**Check**: Consent granted for this category in current workflow

**Decision**:

- ✅ **TRUE**: Execute (announce "Using workflow consent for <category> (granted turn N)")
- ❌ **FALSE**: Continue to composite consent check

**Workflow boundaries**:

- Same task/feature
- < 10 turns since last activity
- No major context switch

### 7. Tier 2 (Moderate) - Composite Consent Check

**Input**: Previous turn, Current message, Plan concreteness  
**Check**: Previous turn has concrete plan + current message has consent phrase + immediate next turn

**Concreteness criteria** (need ≥2):

1. Target specificity (named files/functions)
2. Change description (specific edits)
3. Scope boundary (clear start/end)
4. Success criteria (test expectations)

**High-confidence consent phrases**:

- "go ahead", "proceed", "yes", "yep", "yeah"
- "sounds good", "looks good", "do it", "ship it"

**Medium-confidence phrases** (confirm first):

- "ok", "okay", "sure", "fine"

**Decision**:

- ✅ **TRUE** (high confidence): Execute, grant consent, track state
- ⚠️ **MEDIUM**: Ask "Just to confirm, you want me to proceed with the plan?"
- ❌ **FALSE**: Require consent

**Modifications**:

- "yes, but [change]" → Update plan, ask "Proceed with this adjusted version?"

### 8. Tier 3 (Risky) - Always Require Consent

**Input**: Operation type  
**Check**: Is operation risky?

**Decision**: Always require explicit consent, never persist consent

**Rationale**: Safety first. Each risky operation needs explicit approval.

## State Management

### When to Track State

**Track consent state for**:

- Tier 2 (Moderate) operations when granted
- Session allowlist commands when granted
- Composite consent when plan approved

**Don't track state for**:

- Slash commands (each invocation is fresh)
- Tier 1 (Safe) operations (each is independent)
- Tier 3 (Risky) operations (never persist)

### When to Clear State

**Immediate clear** (all non-allowlist state):

- Stop trigger detected
- Error or failure
- User correction
- Major context switch

**Workflow end clear** (workflow state only):

- Task completion
- User acknowledgment ("done", "next")
- Topic change
- > 10 turns of inactivity

**Session end clear** (everything including allowlist):

- Chat closed
- Context window boundary
- Explicit "Revoke all consent"

## Status Update Templates

### Using Existing Consent

```
Using workflow consent for file edits (granted turn 45)
Editing src/parse.ts...
```

### Using Session Allowlist

```
Using session allowlist: git push
Pushing to origin/main...
```

### Requesting Fresh Consent

```
First git command in workflow, need consent:
- git add -A
- git commit -m "feat: add parser"

Proceed?
```

### Risky Operation

```
Risky operation (requires consent every time):
- git push --force

This will overwrite remote history. Proceed?
```

## Quick Reference Cheat Sheet

| Scenario                        | Decision                | Rationale                |
| ------------------------------- | ----------------------- | ------------------------ |
| User types `/commit`            | Execute immediately     | Slash command = consent  |
| User says "Run `git status`"    | Execute (announce)      | Tier 1 + imperative      |
| Second file edit in workflow    | Execute (use existing)  | Tier 2 workflow consent  |
| First git command in workflow   | Ask consent             | Tier 2 first in category |
| User says "go ahead" after plan | Execute (grant & track) | Composite consent        |
| Any `git push`                  | Always ask              | Tier 3 risky             |
| User says "stop"                | Clear state             | Stop trigger             |
| Command on allowlist            | Execute & announce      | Session allowlist        |

## Validation Checklist

Before making consent decision, verify:

- [ ] Checked for slash command first (highest priority)
- [ ] Checked for stop/reset triggers
- [ ] Checked session allowlist
- [ ] Classified operation risk tier correctly
- [ ] Checked existing workflow consent for Tier 2
- [ ] Checked composite consent for Tier 2
- [ ] Always asking for Tier 3 risky operations
- [ ] Planned to announce consent source in status update

## Related Documents

- **Risk Tiers**: `consent-gates-refinement/risk-tiers.md`
- **Composite Consent**: `consent-gates-refinement/composite-consent-signals.md`
- **State Tracking**: `consent-gates-refinement/consent-state-tracking.md`
- **Rules Implementation**: `.cursor/rules/assistant-behavior.mdc`

## Revision History

- 2025-10-24: Initial creation (Phase 2 deliverable)
- Incorporates all consent mechanisms (slash commands, allowlist, composite, exceptions, state tracking)
