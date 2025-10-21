# Hooks Findings — CONCLUSIVE

**Date**: 2025-10-20  
**Status**: Investigation complete - hooks not viable due to organization policy

---

## Executive Summary

**Hooks are NOT available** for enforcement in this repository due to organization policy restrictions on experimental features.

- ✅ Hooks exist and are documented in Cursor 1.7+
- ✅ Hooks would be ideal for automated enforcement (TDD, file validation)
- ❌ Hooks require experimental feature flag
- ❌ **Organization policy blocks enabling experimental flags**
- ❌ **Result: Hooks cannot be used**

**Investigation proceeds with validated, available patterns**: alwaysApply (96% compliance), commands/prompt templates, and external validation (CI/pre-commit).

---

## Root Cause: Organization Policy Restriction

### Cursor Output Channel Message

```
[2025-10-20T21:03:15.405Z] Project hooks disabled (experiment flag not enabled)
```

**Discovered**: After 5 restarts and multiple configuration attempts, checked Cursor's output channel and found this definitive message.

**Meaning**:

- Hooks are an **experimental feature** in Cursor
- Require opt-in via experimental feature flag
- Flag setting is **controlled by organization policy**
- Organization does not allow enabling unapproved experiments
- Therefore: **hooks cannot be enabled**

---

## Testing Summary

### Exhaustive Testing Performed (2025-10-20)

**Configurations tested**:

1. Inline commands (`echo`, `date`) ❌
2. `/tmp/` paths ❌
3. Workspace-relative paths (`.cursor/`) ❌
4. With `file_path` field (glob patterns) ❌
5. Without `file_path` field ❌
6. Executable scripts (matching docs quickstart format) ❌
7. Multiple hook types (`afterFileEdit`, `stop`) ❌
8. 5 complete Cursor restarts ❌

**Final working configuration** (correct per docs):

`.cursor/hooks.json`:

```json
{
  "version": 1,
  "hooks": {
    "afterFileEdit": [
      {
        "command": "./hooks/test-hook.sh"
      }
    ],
    "stop": [
      {
        "command": "./hooks/stop-hook.sh"
      }
    ]
  }
}
```

`.cursor/hooks/test-hook.sh`:

```bash
#!/usr/bin/env bash
echo "Hook triggered at $(date)" >> .cursor/hook-test.log
```

**Result**: Configuration correct, scripts executable, but hooks never triggered due to experiment flag being disabled.

---

## What We Learned

### Documentation vs Reality

**Documented** ([Cursor 1.7 Changelog](https://cursor.com/changelog/1-7)):

- ✅ Hooks exist as beta feature
- ✅ Support `afterFileEdit`, `stop`, and other lifecycle events
- ✅ Can run custom scripts at specific points
- ✅ Placed at `.cursor/hooks.json` (project), `~/.cursor/hooks.json` (user), or `/etc/cursor/hooks.json` (enterprise)

**Reality**:

- ⚠️ Hooks require experimental feature flag
- ❌ Flag not available in settings UI (or hidden by org policy)
- ❌ Cannot be enabled due to organization restrictions
- ✅ Feature exists but is gated behind experiments

### Key Discoveries

1. **Schema requirements**:

   - `file_path` field is optional (when omitted, hooks trigger on any file)
   - Must use executable script paths, not inline shell commands
   - Relative paths are from hooks.json location

2. **Experiment flag**:

   - Discovered via output channel logging
   - Not exposed in Settings UI (at least not visible with org restrictions)
   - Blocks all hook types (not just `afterFileEdit`)

3. **Testing paradox validated again**:
   - Real usage testing (1 hour) found definitive answer
   - Prevented days of building around unavailable features
   - Same pattern as slash commands discovery

---

## Impact on Investigation

### Original Hope for Hooks

Hooks would have been **ideal** for automated enforcement:

**TDD enforcement** (`afterFileEdit`):

- ✅ Run after every file edit automatically
- ✅ Check for colocated spec file
- ✅ Block or warn if spec missing
- ✅ Near-100% enforcement without context cost

**Git operations** (`stop` or custom hooks):

- ✅ Validate commit messages
- ✅ Check branch naming
- ✅ Enforce script usage

**Scalability**:

- ✅ No context cost (scripts run externally)
- ✅ Unlimited rules (not limited by token budget)
- ✅ Deterministic checks (file existence, naming patterns)

### Reality: Must Use Alternative Patterns

Since hooks are unavailable, investigation proceeds with:

1. **AlwaysApply** (validated at 96%):

   - Context cost: ~2k tokens per rule
   - Effective but limited scalability
   - Primary pattern for critical rules

2. **Commands/Prompt templates** (unexplored):

   - User-initiated workflows
   - Discoverability via `/` prefix
   - No context cost

3. **External validation** (100% when implemented):
   - CI/pre-commit hooks
   - Deterministic checks
   - Final enforcement gate

---

## Recommendations

### For This Repository

1. ✅ **Use alwaysApply** for 5-7 critical rules (git-usage, TDD rules)
2. ⏸️ **Explore prompt templates** for user-initiated git operations
3. ✅ **Expand external validation** (CI/pre-commit) for deterministic checks
4. ✅ **Improve intent routing** for medium-risk conditional rules
5. ❌ **Do not rely on hooks** - not available due to org policy

### For Future

- **Monitor Cursor releases**: When hooks graduate from experimental to stable, they become viable
- **Advocate with organization**: If hooks prove valuable elsewhere, request experiment approval
- **Document limitation**: Note in investigation that hooks were considered but org-restricted

---

## Meta-Lessons

### Investigation Methodology

**What worked**:

- ✅ Real-world testing over theory
- ✅ Checking Cursor's output channel for error messages
- ✅ Consulting official documentation for correct schema
- ✅ Exhaustive configuration testing before concluding

**What could improve**:

- ⚠️ Check for experiment flags earlier (before extensive testing)
- ⚠️ Verify feature availability before deep investigation
- ⚠️ Consult output channels/logs immediately when features don't work

### Testing Paradox Validated

**Third validation** of testing paradox (after slash commands, and initial hooks attempts):

- Real usage testing (1 hour) → found definitive org policy restriction
- Prospective testing would have missed this (can't know org policy without trying)
- Quick tests saved days of building around unavailable features

---

## References

- [Cursor 1.7 Changelog - Hooks Introduction](https://cursor.com/changelog/1-7)
- [Cursor Hooks Documentation](https://cursor.com/docs/agent/hooks)
- [GitButler: Deep Dive into Cursor Hooks](https://blog.gitbutler.com/cursor-hooks-deep-dive)
- [Cursor Community Forum: Hooks Not Detected](https://forum.cursor.com/t/cursor-hooks-not-detected/135709)

---

**Status**: Hooks investigation complete  
**Conclusion**: Not viable due to organization experimental feature restrictions  
**Next**: Proceed with alwaysApply review and modes investigation
