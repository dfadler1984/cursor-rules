# Platform Constraints: Cursor UI Limitations

**Date**: 2025-10-16  
**Discovery**: Slash commands cannot work as designed in Cursor

---

## The Constraint

**Problem**: Cursor's UI intercepts messages starting with `/` before they reach the assistant.

**Evidence**: User attempted `/status` and Cursor's command palette activated, creating `.cursor/commands/status` instead of sending the message to the assistant.

**Impact**: Any rule expecting `/command` syntax will fail because the assistant never receives the message.

---

## What We Tried

### Slash Commands Rule

Created `git-slash-commands.mdc` with enforcement protocol:
- `/commit` → route to `git-commit.sh`
- `/pr` → route to `pr-create.sh`
- `/branch` → route to `git-branch-name.sh`
- `/pr-update` → route to `pr-update.sh`

**Assumption**: User messages starting with `/` would reach the assistant for rule processing.

**Reality**: Cursor treats `/something` as a UI command, not a chat message.

---

## Why This Discovery Validates Testing-Limits Project

### What Didn't Find It

❌ **Test plans** (7 comprehensive plans created)  
❌ **Prospective trials** (50 trials designed)  
❌ **Test protocols** (detailed procedures documented)  
❌ **Implementation** (rules created and validated)

### What Found It

✅ **One real usage attempt**: User typed `/status`  
✅ **Immediate discovery**: Constraint apparent in 30 seconds  
✅ **Zero testing needed**: No trials required to identify issue

### Time Saved

**Avoided waste**:
- Phase 3 testing: 3-4 hours (50 trials)
- Analysis: 1-2 hours
- Debugging why tests failed: Unknown hours
- **Total saved**: ~8-12 hours

**Actual cost**:
- One user attempt: 30 seconds
- Documentation: 30 minutes

---

## Lessons

### 1. Real Usage > Testing

Prospective testing would have run 50 trials, all failing, without understanding why. Real usage immediately revealed the platform constraint.

### 2. Platform Assumptions Are Dangerous

The rule assumed standard chat message behavior. Cursor's UI has special handling for `/` that's not documented in assistant-facing docs.

### 3. Quick Validation Catches Big Issues

One attempt to use the feature found a fundamental blocker. This validates the "test in production" / "real usage monitoring" approach.

### 4. Testing Can't Find Unknown Constraints

You can't test for what you don't know to test for. Platform-specific behaviors require discovery, not testing.

---

## Alternatives Considered

### Option 1: Different Syntax

Use `!commit` or `@commit` instead of `/commit`

**Issues**:
- Unknown if other prefixes also intercepted
- Would need testing to discover
- Adds friction vs natural language

### Option 2: Keep Intent Routing

Current approach (H1: alwaysApply) already working at 96%

**Advantages**:
- ✅ No special syntax required
- ✅ Natural language: "commit these changes"
- ✅ Already proven effective
- ✅ No platform constraints

### Option 3: Accept Limitation

Document that explicit command syntax isn't viable in Cursor

**Decision**: This option chosen

---

## Implications for Future Experiments

### Check Platform Constraints First

Before designing experiments:
1. Test basic assumption with one real attempt
2. Document any platform-specific behaviors
3. Design around constraints, not against them

### Prefer Natural Over Explicit

Natural language ("commit these changes") works better than command syntax in AI chat interfaces.

### Real Usage Validates Fastest

For UI/platform integration, one real attempt beats 50 test trials.

---

## Related

- [Testing Paradox](./README.md) — Why self-testing is limited
- [Slash Commands Decision](../rules-enforcement-investigation/slash-commands-decision.md) — Full investigation
- [Rules Enforcement Investigation](../rules-enforcement-investigation/) — Parent project

---

**Status**: Constraint documented; slash commands marked not viable  
**Recommendation**: Continue with H1 (alwaysApply + intent routing) approach  
**Evidence**: One real usage attempt > hours of planned testing

