# Hooks Exploration: Validating Cursor's Lifecycle Enforcement

**Purpose**: Systematically explore Cursor hooks to understand capabilities, limitations, and applicability to rules enforcement

**Status**: IN PROGRESS  
**Started**: 2025-10-16

---

## Overview

**Hooks** (`.cursor/hooks.json`) provide lifecycle-based automation in Cursor, allowing scripts to run at specific points in the agent's workflow.

**Sources**:

- [Cursor Hooks Documentation](https://cursor.com/docs/agent/hooks)
- [Cursor Commands Documentation](https://cursor.com/docs/agent/chat/commands)
- [GitButler Hooks Deep Dive](https://blog.gitbutler.com/cursor-hooks-deep-dive)

---

## Hook Types (From Documentation)

### 1. `afterFileEdit`

**Trigger**: After any file is edited by the agent

**Use cases** (from docs):

- Auto-formatting or linting
- Running tests
- Validation checks
- Documentation generation

**Example**:

```json
{
  "version": 1,
  "hooks": {
    "afterFileEdit": [
      {
        "command": "npm run lint && npm test",
        "description": "Lint and test after edits"
      }
    ]
  }
}
```

**Questions to answer**:

- ❓ Does it run for EVERY file edit (including rule files, docs)?
- ❓ Can it access the file path that was edited?
- ❓ Can it block/warn if checks fail?
- ❓ Does it run asynchronously (non-blocking)?
- ❓ What happens if the command fails?

---

### 2. `stop`

**Trigger**: When the agent stops (completes a task)

**Use cases** (from docs):

- Notifications
- Cleanup tasks
- Session logging

**Example**:

```json
{
  "version": 1,
  "hooks": {
    "stop": [
      {
        "command": "osascript -e 'display notification \"Task completed\" with title \"Cursor\"'",
        "description": "Notify on completion"
      }
    ]
  }
}
```

**Questions to answer**:

- ❓ What defines "stop"? (user stop? natural completion?)
- ❓ Can it access agent output/results?
- ❓ Does it run before or after response is shown?

---

### 3. Command Blocking (From GitButler article)

**Capability**: Block sensitive commands

**Questions to answer**:

- ❓ How is this configured?
- ❓ Can it block based on patterns?
- ❓ Is this a separate hook type or part of other hooks?

---

### 4. Access Controls (From GitButler article)

**Capability**: Restrict changes to critical files/directories

**Questions to answer**:

- ❓ How is this configured?
- ❓ Can it whitelist/blacklist paths?
- ❓ Is this a separate hook type?

---

### 5. Prompt Validation (From GitButler article)

**Capability**: Analyze/sanitize prompts before processing

**Questions to answer**:

- ❓ What hook type enables this?
- ❓ Can prompts be modified or only logged?
- ❓ Can it block prompts?

---

## Test Plan

### Test 1: Basic `afterFileEdit` Hook

**Objective**: Validate that afterFileEdit runs when agent edits a file

**Setup**:

```json
{
  "version": 1,
  "hooks": {
    "afterFileEdit": [
      {
        "command": "echo 'Hook triggered!' >> /tmp/cursor-hook-test.log",
        "description": "Log to verify hook runs"
      }
    ]
  }
}
```

**Test steps**:

1. Create `.cursor/hooks.json` with above config
2. Ask agent to edit a test file
3. Check `/tmp/cursor-hook-test.log` for output
4. Document: Did hook run? When? How many times?

**Expected outcome**: Hook runs and creates log entry

**Actual outcome** (2025-10-16): ❌ Hook did NOT trigger

**Test steps executed**:

1. Created `.cursor/hooks.json` with logging hook
2. Created test file using `write` tool
3. Edited test file using `search_replace` tool
4. Checked `/tmp/cursor-hook-test.log` - file does not exist

**Hypotheses for why hook didn't trigger**:

1. **Restart required**: Cursor may need restart/reload to pick up hooks.json
2. **Tool limitations**: Hooks may not trigger for tool-based edits (write/search_replace)
3. **Mode-specific**: Hooks may only work in Agent mode (not Chat mode)
4. **Configuration error**: Hook format may be incorrect
5. **Permission issues**: Command may need different privileges
6. **Platform limitation**: Hooks may not work in current Cursor version

**Next test**: Need to test with manual file edits or different trigger mechanism

---

### Test 2: TDD Gate with `afterFileEdit`

**Objective**: Validate that hooks can enforce TDD pre-edit gate

**Setup**:

```json
{
  "version": 1,
  "hooks": {
    "afterFileEdit": [
      {
        "command": "bash .cursor/scripts/check-tdd-gate.sh",
        "description": "Verify spec file exists for implementation"
      }
    ]
  }
}
```

**Script** (`.cursor/scripts/check-tdd-gate.sh`):

```bash
#!/usr/bin/env bash
# Check if edited file has corresponding spec file

# TODO: Get edited file path from hook
# TODO: Determine if it's an implementation file
# TODO: Check for spec file existence
# TODO: Exit 0 if ok, exit 1 if violation

echo "TDD gate check triggered"
```

**Questions**:

- ❓ How does the script get the edited file path?
- ❓ Can hooks pass arguments to commands?
- ❓ What happens if script exits 1?

**Expected outcome**: Script runs, can access file path, can detect violations

**Actual outcome**: [TO BE TESTED]

---

### Test 3: Script-First Enforcement

**Objective**: Use hooks to enforce script-first for git operations

**Challenge**: Git commands happen BEFORE file edits (commit message, branch name)

**Questions**:

- ❓ Is there a `beforeCommand` hook?
- ❓ Can hooks intercept git commands?
- ❓ Or do we need different approach?

**Hypothesis**: Hooks may not help with git-usage rule (operates at wrong lifecycle point)

---

### Test 4: Multiple Hooks

**Objective**: Validate that multiple hooks can coexist

**Setup**:

```json
{
  "version": 1,
  "hooks": {
    "afterFileEdit": [
      {
        "command": "echo 'Hook 1' >> /tmp/cursor-hooks.log",
        "description": "First hook"
      },
      {
        "command": "echo 'Hook 2' >> /tmp/cursor-hooks.log",
        "description": "Second hook"
      }
    ]
  }
}
```

**Expected outcome**: Both hooks run in order

**Actual outcome**: [TO BE TESTED]

---

### Test 5: Hook Failure Handling

**Objective**: Understand what happens when hook command fails

**Setup**:

```json
{
  "version": 1,
  "hooks": {
    "afterFileEdit": [
      {
        "command": "exit 1",
        "description": "Failing hook"
      }
    ]
  }
}
```

**Questions**:

- ❓ Does failure block agent response?
- ❓ Is failure shown to user?
- ❓ Do subsequent hooks run?

**Expected outcome**: [UNKNOWN - need to test]

**Actual outcome**: [TO BE TESTED]

---

### Test 6: Stop Hook Behavior

**Objective**: Understand when and how stop hook runs

**Setup**:

```json
{
  "version": 1,
  "hooks": {
    "stop": [
      {
        "command": "date >> /tmp/cursor-stop-hook.log",
        "description": "Log stop events"
      }
    ]
  }
}
```

**Test variations**:

1. Natural task completion
2. User stops agent manually
3. Agent hits error

**Expected outcome**: Stop hook runs at task end

**Actual outcome**: [TO BE TESTED]

---

## Limitations to Document

### Potential limitations (to verify):

1. **Lifecycle coverage**:

   - ❓ Can hooks cover git operations? (happen before file edits)
   - ❓ Can hooks validate user requests? (before agent acts)

2. **Context awareness**:

   - ❓ Do hooks know what file was edited?
   - ❓ Do hooks have access to agent state?

3. **User experience**:

   - ❓ Are hooks visible to user?
   - ❓ Do failed hooks interrupt workflow?

4. **Scope**:
   - ❓ Do hooks run for ALL file edits (including .cursor/ files)?
   - ❓ Can hooks be scoped to specific paths?

---

## Comparison Matrix (To Complete After Testing)

| Feature             | AlwaysApply            | Hooks            | External (CI)        |
| ------------------- | ---------------------- | ---------------- | -------------------- |
| **Coverage**        | All contexts           | File edits only  | Pre-commit/push      |
| **Timing**          | During agent reasoning | After agent acts | After local commit   |
| **Enforcement**     | Awareness-based (80%)  | Automated (??%)  | Automated (100%)     |
| **Context cost**    | ~2k tokens/rule        | 0 tokens         | 0 tokens             |
| **User visibility** | Implicit               | ???              | Explicit (blocks)    |
| **Scalability**     | Limited (~5 rules)     | Unlimited        | Unlimited            |
| **Applicability**   | Any rule type          | File edits only  | Artifact checks only |

---

## Applicability to Our Rules

### Critical Rules

**assistant-git-usage** (script-first for git):

- ❓ Hooks timing: Git happens before edits
- Likely: **Hooks NOT applicable** (wrong lifecycle point)
- Stick with: alwaysApply (validated at 80%) or commands (`/commit`)

### High-Risk Rules

**tdd-first-js** (TDD pre-edit gate):

- ✅ Hooks timing: Perfect (afterFileEdit)
- ✅ Deterministic check: File exists or not
- Likely: **Hooks HIGHLY applicable**
- Test: Can enforce 100% compliance

**tdd-first-sh** (Shell TDD):

- ✅ Same as tdd-first-js
- Likely: **Hooks HIGHLY applicable**

**testing** (test quality):

- ⚠️ Hooks timing: Can run after edit
- ❓ Non-deterministic: Quality is subjective
- Likely: **Hooks PARTIALLY applicable** (can check existence, not quality)

**refactoring** (refactoring safety):

- ⚠️ Hooks timing: Can run after edit
- ❓ Complex check: Did tests run? Did they pass?
- Likely: **Hooks PARTIALLY applicable**

---

## Next Steps

1. **Create test hooks.json** (simple logging hook)
2. **Run tests 1-6** systematically
3. **Document actual behavior** (vs expected)
4. **Identify limitations** discovered during testing
5. **Update comparison matrix** with real data
6. **Revise recommendations** for each rule based on findings

---

**Status**: Test plan complete, ready to execute  
**Next**: Create test hooks configuration and run Test 1
