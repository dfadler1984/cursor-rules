# Platform Constraints: Cursor UI Limitations

**Date**: 2025-10-16  
**Discovery**: Slash commands cannot work as designed in Cursor

---

## The Constraint

**Problem**: Cursor's `/` prefix is for **prompt templates**, not runtime message routing.

**Evidence**: User attempted `/status` and Cursor correctly created `.cursor/commands/status` to store a prompt template, as designed.

**How Cursor Slash Commands Actually Work** (per [Cursor 1.6 changelog](https://cursor.com/changelog/1-6)):

- Commands are stored in `.cursor/commands/[command].md`
- Type `/` in Agent input → opens dropdown of available commands
- Select command → loads **prompt template** content and sends it to assistant
- Used for reusable prompts (e.g., "run linter", "fix compile errors", "create PR with conventional commits")

**What We Misunderstood**:

- ❌ Thought: `/commit` would be sent as a message to assistant for runtime routing
- ✅ Reality: `/commit` triggers UI to load a prompt template from `.cursor/commands/commit.md`

**Impact**: Any rule expecting runtime routing via `/command` syntax cannot work because:

1. The `/` prefix triggers Cursor's command system (UI-level)
2. It loads a **static prompt template**, not a runtime route
3. The assistant never sees `/command` as a message to process
4. This is **correct platform behavior**, not a bug

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

### What SHOULD Have Found It

🔍 **Reading platform docs first**: [Cursor 1.6 changelog](https://cursor.com/changelog/1-6) clearly explains slash commands are prompt templates, not runtime routes

**Lesson**: Check official documentation before implementing platform features. Would have saved implementation time.

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

### 4. Read Platform Docs First

**What happened**: Implemented feature without checking official docs  
**Cost**: ~4 hours implementation + 2 hours test protocol design  
**Benefit**: Created reusable investigation artifacts

**What should happen**: Check [Cursor changelog](https://cursor.com/changelog/1-6) and [docs](https://cursor.com/docs/agent/chat/commands) before implementing  
**Cost**: 10 minutes reading  
**Benefit**: Immediate understanding of platform constraints

**Lesson**: Documentation > implementation > testing. Read first, then decide if implementation aligns with platform design.

### 5. Testing Can't Find Design Mismatches

You can't test for what you don't know to test for. Platform-specific behaviors require understanding platform design, not testing.

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

### Read Documentation First

**Before designing any platform integration**:

1. **Read official docs**: Check changelog, documentation, API references
2. **Understand platform design**: How does the platform intend the feature to work?
3. **Validate assumptions**: Does your approach align with platform design?
4. **Test basic assumption**: One real attempt to confirm understanding
5. **Document constraints**: Note platform-specific behaviors

**Order matters**: Docs → Understanding → Design → Test

### Check Platform Constraints First

After reading documentation:

1. Test basic assumption with one real attempt
2. Document any platform-specific behaviors discovered
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

## References

- [Cursor 1.6 Changelog - Custom Slash Commands](https://cursor.com/changelog/1-6) - Official announcement (September 12, 2025)
- [Cursor Docs - Commands](https://cursor.com/docs/agent/chat/commands) - Documentation for slash commands feature

---

**Status**: Constraint documented; slash commands marked not viable for runtime routing  
**Root Cause**: Misunderstood platform feature design (prompt templates vs runtime routes)  
**Recommendation**: Continue with H1 (alwaysApply + intent routing) approach at 96% compliance  
**Evidence**: One real usage attempt > hours of planned testing  
**Meta-lesson**: Read platform docs before implementing features
