---
findingId: 14
date: "2025-10-24"  # Inferred from migration
project: "rules-enforcement-investigation"
severity: "medium"  # Default for migrated findings
status: "open"      # Default for migrated findings
reviewed: false
reviewedBy: null
reviewedDate: null
sourceLogs: []      # To be filled post-migration
---

# Gap #14: Script Bypass on Error Instead of Trust-First

**Discovered**: 2025-10-22  
**Context**: consent-gates-refinement PR #155 label management  
**Severity**: Medium (violates script-first principle when tooling encounters errors)

---

## What Happened

When removing the `skip-changeset` label from PR #155, the repo script (`pr-labels.sh`) executed successfully but printed an error message:

```bash
$ bash .cursor/scripts/pr-labels.sh --pr 155 --remove skip-changeset
2025-10-22T20:29:17Z [INFO] Removing label 'skip-changeset' from PR #155
/Users/dustinfadler/Development/cursor-rules/.cursor/scripts/pr-labels.sh: line 176: success: command not found
Exit code: 127
```

**My response**: Instead of trusting the script or investigating the error, I bypassed it with direct `curl`:

```bash
$ curl -s -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/dfadler1984/cursor-rules/issues/155/labels
[]  # Empty - label was actually removed successfully
```

**What actually happened**: The script **did remove the label** (API showed empty array), but I didn't trust it because of the error message.

---

## What Should Have Happened

Per `assistant-git-usage.mdc` → Script-First Default:

1. ✅ Use the repo script first (`pr-labels.sh`)
2. ❌ **Script encountered error** → Should investigate or trust the operation
3. ❌ Instead: Bypassed with direct `curl` to "verify"

**Correct behavior**:

1. Run the script
2. If it errors but exit code suggests success, check the actual result (did it work?)
3. If the operation succeeded despite error message, note the script bug but don't bypass
4. If the operation failed, investigate the error and possibly retry or fix

**In this case**: The script successfully removed the label; the error was a cosmetic bug in the success message printing. Should have trusted the operation.

---

## Root Cause

**Pattern**: Bypass tooling when encountering errors instead of trusting/investigating

**Why it happened**:

1. **Error aversion**: Error message triggered distrust of the script
2. **Verification impulse**: Wanted to "be sure" by checking directly
3. **Missing distinction**: Didn't separate "script has cosmetic bug" from "operation failed"
4. **Habit**: When uncertain, fall back to familiar direct commands

---

## Evidence

**Command sequence**:

```bash
# 1. Used script (correct)
bash .cursor/scripts/pr-labels.sh --pr 155 --remove skip-changeset
# Exit code: 127, error message about 'success' function

# 2. Bypassed with curl (incorrect)
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/.../issues/155/labels
# Result: [] (empty, label was removed)

# 3. Conclusion: Script worked despite error message
```

**User observation**: "I noticed you didn't use the script"

**My acknowledgment**: "I encountered an error with pr-labels.sh and instead of retrying or investigating, I bypassed it with direct curl."

---

## Pattern Analysis

**Similar to**:

- Gap #12: Know the rule (ERD/tasks separation) but don't apply it
- Gap #13: Know the rule (canonical structure) but proliferate documents

**This gap**: Know the rule (script-first) but bypass when encountering errors

**Common theme**: Rules awareness ≠ consistent enforcement, especially under uncertainty

---

## Script Bug Identified

**File**: `.cursor/scripts/pr-labels.sh`  
**Line**: 176  
**Issue**: Calls `success` function which doesn't exist

**Impact**: Prints error message but operation succeeds (cosmetic bug)

**Fix needed**: Either define `success` function or remove the call

---

## Corrective Actions

### Immediate (This Instance)

- [x] Documented Gap #14
- [x] Fix `pr-labels.sh` script bug (line 176: `success` function not found) — Replaced with `log_info` (commit 268e27f)
- [ ] Test script after fix to ensure error message disappears

### Pattern Prevention

**Trust-first protocol** (when scripts error):

1. **Run the script** (script-first principle)
2. **Check exit code**:
   - Exit 0 → Operation likely succeeded, check actual result
   - Exit non-zero → Operation may have failed, investigate
3. **Verify result**: Check if the intended effect occurred (e.g., label removed)
4. **If effect achieved**: Trust the script, note the bug separately
5. **If effect not achieved**: Investigate error, don't bypass with alternative commands
6. **Report bugs**: Document script bugs but don't work around them silently

**Decision tree**:

```
Script errors → Check exit code → Check effect
├─ Effect achieved → Trust script, note bug
└─ Effect not achieved → Investigate error, ask for help
   Never: Bypass script with direct commands
```

---

## Success Criteria

This gap is resolved when:

- [ ] `pr-labels.sh` bug fixed (line 176)
- [ ] Trust-first protocol added to script usage guidance
- [ ] Zero instances of bypassing scripts with direct commands when scripts partially succeed
- [ ] Script bugs reported/fixed instead of silently worked around

---

## Meta-Observation

**Pattern discovered during**: Active use of consent gates improvements (creating PR, managing changeset)

**Timing**: Immediately after validating that slash commands bypass consent correctly

**Irony**: While validating that I follow consent rules correctly, I violated the script-first rule

**Learning**: Rule enforcement gaps occur even during active validation of other rules

---

## Related Gaps

- **Gap #12**: ERD/tasks separation (know rule, don't apply)
- **Gap #13**: Document proliferation (know rule, don't apply)
- **Gap #14**: Script bypass on error (know rule, don't trust when uncertain)

**Common root cause**: Rules awareness insufficient for consistent compliance under uncertainty or convenience pressure

---

## References

- `assistant-git-usage.mdc` → Script-First Default
- `capabilities.mdc` → What you can ask the assistant to do → Git assistance
- `.cursor/scripts/pr-labels.sh` — Script with cosmetic bug at line 176
- PR #155 — Instance where bypass occurred
