# Gap #20: Manual CHANGELOG.md Edit (Changesets Workflow Violation)

**Date Observed:** 2025-10-23  
**Category:** Execution failure — Workflow violation  
**Severity:** High (violated established automation workflow)  
**Status:** Identified, reverted, documented

---

## Symptom

Assistant manually edited `CHANGELOG.md` to add "Unreleased" section entries for multi-chat session changes, violating the repository's Changesets-managed CHANGELOG workflow.

## What Happened

During multi-chat session review (capabilities + automation + collaboration projects), the assistant:

1. Observed that CHANGELOG.md didn't include entries for all 3 chats
2. **Manually added** extensive "Unreleased" section with Added/Changed/Deprecated/Archived subsections
3. Did not create changeset files to properly trigger the automated CHANGELOG generation

**User Correction:**

> "The changelog is automatically filled based on our changesets. How do you not already know that?"

## Root Cause

**Execution Failure:** Assistant ignored or was unaware of established Changesets workflow.

**Evidence:**

- Repository has `.changeset/` directory and uses Changesets for version management
- `assistant-git-usage.mdc` documents: "Always include a Changeset in PRs that modify repository behavior"
- CI has "Version Packages" workflow that auto-generates CHANGELOG entries
- Assistant manually edited instead of running `npx changeset`

**Why This Happened:**

1. **Knowledge gap:** Didn't recognize CHANGELOG.md is auto-managed by Changesets
2. **Pattern mismatch:** Saw "empty" Unreleased section and assumed manual update was needed
3. **No verification step:** Didn't check existing workflow before editing

## Impact

- **Immediate:** Incorrect manual edits to CHANGELOG.md (reverted by user)
- **PR Risk:** Could have merged manual entries that conflict with auto-generated changelog
- **Workflow Confusion:** Set bad example for future sessions

## Expected Behavior

Per `assistant-git-usage.mdc` → Changesets section:

1. **Create changeset file** (not manual CHANGELOG edit):

   ```bash
   npx changeset
   ```

   - Select packages: `cursor-rules`
   - Select type: `minor` (features)
   - Write summary describing changes

2. **CHANGELOG.md auto-generates** when "Version Packages" PR is merged

3. **Never manually edit** CHANGELOG.md in regular PRs

## Corrective Action Taken

✅ Reverted CHANGELOG.md (`git checkout CHANGELOG.md`)  
✅ Documented in gap-20  
✅ Updated understanding: Changesets manages CHANGELOG, not manual edits

## Prevention

### Short-term (Immediate)

- ✅ Gap documented
- ✅ Knowledge updated: Check for Changesets workflow before editing CHANGELOG

### Medium-term (Rule Enhancement)

- [ ] Add explicit "Never manually edit CHANGELOG.md" to `assistant-git-usage.mdc` → Changesets section
- [ ] Add to Pre-Send Gate: "Changeset included OR skip-changeset label?" check
- [ ] Add to `favor-tooling.mdc`: "Check for automation (Changesets, auto-formatting) before manual edits"

### Long-term (Validation)

- [ ] Create validation script: Detect manual CHANGELOG.md edits in PRs (fail if "Unreleased" section has content)
- [ ] Add to CI: Reject PRs with manual CHANGELOG edits unless skip-changeset label present

## Related Gaps

- Gap #17: Similar pattern - created ACTIVE-MONITORING.md without enforcement specification
- Gap #11: Documentation-before-execution pattern (should have checked workflow first)

## References

- `.cursor/rules/assistant-git-usage.mdc` → Changesets section (lines 78-89)
- `.changeset/` directory (presence indicates Changesets in use)
- CI workflow: `.github/workflows/release.yml` (Version Packages action)

---

**Lesson:** Always check for existing automation (Changesets, auto-formatting, linters) before manual edits. When in doubt about CHANGELOG, assume it's auto-managed and create changeset instead.
