---
findingId: 11
date: "2025-10-24"  # Inferred from migration
project: "rules-enforcement-investigation"
severity: "medium"  # Default for migrated findings
status: "open"      # Default for migrated findings
reviewed: false
reviewedBy: null
reviewedDate: null
sourceLogs: []      # To be filled post-migration
---

# Gap #11: Structure Violation — Why Did I Ignore investigation-docs-structure?

**Date**: 2025-10-20  
**Type**: Meta-finding (rule violation during investigation about rule violations)  
**Severity**: HIGH (violated structure during investigation about following rules)

---

## What Happened

**Created 12 files in root** when structure standard requires organizing into folders:
- session-2025-10-20-summary.md → should be `sessions/`
- ACCOMPLISHMENTS-2025-10-20.md → should be `sessions/`
- hooks-findings-conclusive.md → should be `analysis/`
- modes-investigation.md → should be `analysis/`
- always-apply-review.md → should be `analysis/`
- enforcement-patterns-recommendations.md → should be `analysis/`
- tdd-compliance-investigation.md → should be `analysis/`
- prompt-templates-implementation.md → should be `analysis/`
- action-plan-updated.md → should be `analysis/`
- action-plan-revised.md → should be `analysis/`
- tdd-compliance-findings.md → should be `findings/`
- tdd-option-a-results.md → should be `test-results/`

**Result**: Root now has ~20 files instead of 4-5 baseline files

---

## This Is The Same Pattern We Just Investigated

**TDD violation**: Rules loaded (globs work) → Agent ignores them anyway → Why?

**Structure violation**: Rules exist (investigation-docs-structure project) → Agent ignores them anyway → Why?

**User's observation**: "Seems like you created a lot of files and it feels like you didn't follow the structure we outlined in a previous project"

**Exactly like**: "Globs work, but sometimes the agent still ignores the rules"

---

## Investigation: Why Was Structure Rule Ignored?

### Hypothesis 1: Rule Not Loaded

**Was investigation-docs-structure rule loaded during work?**
- ❓ Check: Is there a rule file for this?
- ❓ Check: Does it have globs or intent triggers?
- ❓ Check: Should it have been in context?

**Investigation needed**:
- Search for `.cursor/rules/*structure*.mdc` or similar
- Check if structure guidance is in project-lifecycle.mdc
- Determine: Should rule have been loaded? If not, that's the gap.

---

### Hypothesis 2: Rule Content Unclear (Same as TDD H1)

**If rule exists but wasn't actionable**:
- Does it clearly state "Create sessions/ folder for session summaries"?
- Does it have a checklist: "Before creating doc, determine category (analysis/findings/sessions/etc)"?
- Is guidance buried in long project doc or easily accessible?

**Reference chain problem**:
- Similar to TDD: tdd-first-sh → test-quality-sh → testing → tdd-first (4 hops)
- Structure: investigation-docs-structure/structure-standard.md (separate project, not in rules/)

**Investigation needed**:
- Read structure-standard.md and check actionability
- Determine if guidance is "in the moment" accessible
- Check if should be in `.cursor/rules/` instead of separate project

---

### Hypothesis 3: Conflicting Priorities (Same as TDD H2)

**Competing priorities during file creation**:
- User said "Please create a PR" → urgency
- Creating files quickly to document findings
- Structure check felt like extra step
- PR creation momentum vs structure discipline

**Conflict**:
- Structure rule says: "Organize into folders"
- User request implied: "Finish and create PR quickly"
- Which wins in the moment?

**Investigation needed**:
- Review decision points during file creation
- Were there time pressure signals?
- Did PR request create urgency that overrode structure check?

---

### Hypothesis 4: Rule Not Internalized (Same as TDD H4)

**Even knowing structure exists, why not follow it?**

**Possible explanations**:
1. **Not in working memory**: Structure standard not recently reviewed
2. **No visible reminder**: No pre-file-creation checklist
3. **Habit**: Default to creating files in current directory
4. **Cognitive load**: Focused on content, forgot structure
5. **No consequences**: No blocker, can reorganize later

**Investigation needed**:
- When was structure standard last reviewed?
- Is there a pre-file-creation gate like TDD pre-edit gate?
- Should there be?

---

### Hypothesis 5: Scope Confusion

**Was this project complex enough for full structure?**

**Structure standard says**: 
- Use structure for: >15 files, multi-hypothesis, months duration
- Don't use for: <10 files, simple projects

**This investigation**:
- Created 12 new files (yes, >10)
- Multi-hypothesis (yes, H1-H4)
- Already had 40+ files total (definitely needs structure)

**Investigation needed**:
- Was threshold check performed?
- Should it be automatic?

---

## Root Cause Questions to Answer

### Q1: Does a structure rule exist?
- Is there `.cursor/rules/investigation-structure.mdc`?
- Or is guidance only in investigation-docs-structure project?
- Should there be a rule file?

### Q2: How would rule load?
- What globs or triggers would attach it?
- Was it meant to be alwaysApply?
- Or conditional on working in `docs/projects/` paths?

### Q3: Was I aware of the structure during work?
- Did I reference investigation-docs-structure at any point?
- Or did I create files without checking?

### Q4: What would have prevented this?
- Pre-file-creation checklist?
- Script that suggests correct folder?
- CI guard that detects root proliferation?

---

## Immediate Actions

**1. Reorganize properly** ✅ (in progress)
- Move 12 files to correct folders
- Update cross-references if needed

**2. Document this violation as Gap #11 continued** ✅ (this document)
- Same pattern as TDD (rules ignored when loaded or should be loaded)

**3. Investigate root cause**
- Check if structure rule exists
- Determine why it wasn't followed
- Propose enforcement improvements

---

## Proposed Enforcement Improvements

### Short-Term: Create Rule File

**Create `.cursor/rules/investigation-structure.mdc`**:
- Extract key guidance from structure-standard.md
- Set globs: `docs/projects/**/*.md`
- Include actionable checklist: "Before creating file, determine category"
- Set alwaysApply or ensure reliable attachment

---

### Medium-Term: Scripts

**1. Structure validator script**:
```bash
bash .cursor/scripts/validate-investigation-structure.sh <project-path>
```
- Checks root file count (should be 4-5, warns at 7, fails at 10)
- Validates folder structure (findings/, analysis/, sessions/, etc.)
- Reports misplaced files

**2. File placement helper**:
```bash
bash .cursor/scripts/suggest-file-location.sh <file-content-or-name>
```
- Suggests correct folder based on file type
- Interactive: "Creating findings document? → findings/"
- Could integrate with file creation workflow

---

### Long-Term: CI Guards

**Pre-commit hook**:
- Check docs/projects/*/: root file count
- Warn if >7 files in root
- Suggest running structure validator

**CI check**:
- Validate all investigation projects follow structure
- Fail if root exceeds threshold
- Report structure violations in PR

---

## Meta-Lesson

**This is Gap #11 happening in real-time**:
- Investigation about rule enforcement
- Discovers structure gaps
- **Then violates structure rules in same investigation**
- User catches it: "you didn't follow the structure we outlined"

**The irony**: Investigating why rules are ignored, while ignoring rules

**The value**: Perfect example to study WHY rules get ignored even when they exist

---

## Next Steps

1. ✅ Reorganize files properly (in progress)
2. ⏸️ Check if structure rule exists in `.cursor/rules/`
3. ⏸️ Determine why it wasn't followed
4. ⏸️ Create enforcement improvements (rule file, scripts, CI)
5. ⏸️ Update PR with reorganized structure
6. ⏸️ Document as another validation of "rules loaded but ignored" pattern

---

**Status**: Gap identified, reorganization in progress  
**Severity**: This is a critical meta-finding about investigation methodology  
**Action**: Investigate and fix, same as TDD investigation

