---
findingId: 19
date: "2025-10-24"  # Inferred from migration
project: "rules-enforcement-investigation"
severity: "medium"  # Default for migrated findings
status: "open"      # Default for migrated findings
reviewed: false
reviewedBy: null
reviewedDate: null
sourceLogs: []      # To be filled post-migration
---

# Gap #19: Incomplete Git Status Verification Before PR Completion

**Date**: 2025-10-23  
**Project**: core-values archival and enhancement  
**Category**: Execution (Pre-send gate compliance)

---

## What Happened

Claimed PR #164 was "ready for review and merge" with "all changes committed" when there were still uncommitted formatting changes to:
- `.changeset/enhanced-assistant-laws.md` (trailing newline)
- `.cursor/rules/assistant-git-usage.mdc` (markdown formatting/whitespace)

User merged the PR before the uncommitted changes were pushed, requiring a follow-up PR.

---

## Root Cause

**Pre-send gate violation** (`.cursor/rules/assistant-behavior.mdc`):

The checklist includes:
- ✅ Status: included? 
- But **did not verify** status accuracy with `git status`

**What should have happened**:
1. Run `git status --porcelain` before claiming completion
2. Verify working tree clean OR explicitly note uncommitted changes
3. Only claim "ready" when working tree actually clean

**What actually happened**:
1. Provided status update claiming completion
2. Did NOT verify git status
3. Assumed all changes were committed based on prior commit output

---

## Impact

- **Immediate**: User had to create follow-up PR for formatting changes
- **Workflow**: Broke atomic commit expectation (related changes split across PRs)
- **Trust**: Claimed completion inaccurately

---

## Pattern

Similar to previous gaps where assistant provided status without verification:
- Claims test passed without running test
- Claims file exists without checking
- Claims gate satisfied without running gate command

**Core issue**: Status reporting without tool-based verification

---

## Corrective Action

### Pre-send Gate Enhancement

Add explicit verification requirement to `assistant-behavior.mdc` pre-send gate:

```markdown
Pre-Send Gate:
- [ ] Status: included AND verified?
  - For git operations: run `git status --porcelain` and paste output
  - For test operations: run test and paste results
  - For file operations: confirm file paths exist
```

### Execution Protocol

Before claiming ANY completion:
1. Run verification command (`git status`, test runner, validator, etc.)
2. Paste exact output in status
3. Only claim completion if verification passes

**Example (correct)**:
```
Status: Committed all changes
Verification: `git status --porcelain` → (empty output)
Working tree clean. PR ready.
```

**Example (would have caught this)**:
```
Status: Committed changes
Verification: `git status --porcelain` → 
 M .changeset/enhanced-assistant-laws.md
 M .cursor/rules/assistant-git-usage.mdc
Working tree NOT clean. Committing formatting changes before completion.
```

---

## Rule Update Required

**File**: `.cursor/rules/assistant-behavior.mdc`  
**Section**: Compliance-first send gate  
**Change**: Add verification sub-bullets under Status item

---

## Related Gaps

- Similar verification failures in previous investigations
- Pattern: claiming completion without tool-based confirmation

---

## Follow-up PR

Creating PR with:
- Uncommitted formatting changes from PR #164
- Pre-send gate enhancement (verification requirement)
- This gap documentation

