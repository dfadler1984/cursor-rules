# ERD: Investigation Documentation Structure

**Status**: ACTIVE  
**Created**: 2025-10-16  
**Parent Need**: rules-enforcement-investigation has 40 files without clear organizational structure

---

## 1. Problem Statement

The rules-enforcement-investigation project has grown to 40 markdown files across 5 directories without clear organizational principles. Documents are in wrong locations, duplicates exist, and it's unclear when to create new files vs folders.

### Specific Issues

1. **Duplicate files**: `slash-commands-decision.md` exists in both root and `test-execution/`
2. **Unclear folder purposes**: `test-execution/` mixes protocols, results, sessions, discoveries, decisions
3. **Root clutter**: 7 files in root when should have 4-5 baseline files
4. **Missing structure**: No `decisions/`, `guides/`, `protocols/`, `sessions/` folders
5. **Unclear categorization**: When does analysis warrant subfolder? Where do protocols go?
6. **No guidance**: Project-lifecycle.mdc doesn't define structure for complex investigations

### Impact

- Hard to find information (40 files, no clear pattern)
- Duplicates waste effort
- Unclear where new docs belong
- Pattern not reusable for future investigations

---

## 2. Context

### Discovery Origin

**Gap #11** discovered during rules-enforcement-investigation session 2025-10-16:

**User observation**: "Some details are being dumped into files that aren't supposed to be used for that purpose and files are being created in many places without a discernible pattern"

**Trigger**: After creating session summary, platform constraints doc, prompt templates exploration - user noticed structural drift

### Current State

**40 files** in rules-enforcement-investigation:
- Root: 7 files (should be ~4)
- `analysis/`: 6 files (flat, some should be folders)
- `archived-summaries/`: 6 files (should be `_archived/`)
- `test-execution/`: 14 files (mixed purposes)
- `tests/`: 7 files (test plans - this folder is correct)

### User Guidance Provided

**Baseline root files**:
- README.md, erd.md, tasks.md (always)
- High-level protocols like MONITORING-PROTOCOL.md (exceptions, case-by-case)

**Folder structure**:
- `findings/` - Individual gap/finding documents
- `analysis/` - Analysis docs; large topics get subfolders
- `decisions/` - Decision documents
- `guides/` - Reference guides
- `protocols/` - Test/validation protocols
- `sessions/` - Session summaries (per session, adhoc when needed)
- `test-results/` - Renamed from test-execution; ONLY test data
- `tests/` - Test plans/templates (keep as-is)
- `_archived/` - Archived root docs (renamed from archived-summaries)
- `analysis/*/\_archived/` - Archives within analysis subfolders

**Sub-projects**:
- Flat pattern (Option B): Create siblings in `docs/projects/`
- Coordination: `coordination.md` in parent tracks sub-projects
- Links: Each sub-project links to parent in README

---

## 3. Scope

### In Scope

1. **Define structure standard for investigation projects**
   - Folder purposes and contents
   - When to create subfolders vs flat files
   - When to split into sub-projects
   - Naming patterns

2. **Reorganize rules-enforcement-investigation**
   - Move 40 files to correct locations
   - Remove duplicates
   - Create coordination.md
   - Update all cross-references

3. **Create reusable guidance**
   - Update project-lifecycle.mdc with structure section
   - Document when structure applies (complex investigations)
   - Provide examples and decision trees

4. **Split into sub-projects where appropriate**
   - Identify which "pre-test discovery" docs are actually sub-projects
   - Create proper project structure for each
   - Link coordination

### Out of Scope

- Restructuring simple projects (most don't need this complexity)
- Creating automation for structure validation
- Backfilling structure to archived projects

---

## 4. Requirements

### Functional

**R1: Clear folder purposes**
- Each folder has defined purpose
- Clear criteria for what belongs where
- Examples of each type

**R2: Decision framework**
- When to create new file vs update existing
- When to create subfolder in analysis/
- When to split into sub-project
- Naming patterns for each category

**R3: Reorganization plan**
- File-by-file mapping (current location → new location)
- Duplicate resolution
- Cross-reference updates
- Validation that nothing lost

**R4: Guidance documentation**
- Update project-lifecycle.mdc
- Create structure template/example
- Document when this structure applies

### Non-Functional

- **Minimal disruption**: No broken links after reorganization
- **Clear migration**: Document what moved where
- **Reusable**: Pattern applies to future complex investigations
- **Simple when possible**: Don't over-structure simple projects

---

## 5. Acceptance Criteria

1. ✅ rules-enforcement-investigation reorganized to new structure
2. ✅ All 40 files in correct locations
3. ✅ No duplicates remain
4. ✅ coordination.md tracks sub-projects
5. ✅ All cross-references updated and valid
6. ✅ project-lifecycle.mdc updated with structure guidance
7. ✅ Sub-projects created where appropriate
8. ✅ Each sub-project links to parent
9. ✅ Navigation clear (can find any doc quickly)
10. ✅ Pattern documented for reuse

---

## 6. Approach

### Phase 1: Design Structure Standard

**Deliverable**: Structure definition document

**Define**:
- Root baseline (README, erd, tasks, + exceptions)
- Folder purposes (findings/, analysis/, decisions/, etc.)
- Subfolder criteria (when analysis topic needs folder)
- Sub-project criteria (when to split to separate project)
- Naming patterns
- File type → location mapping

### Phase 2: Create Reorganization Plan

**Deliverable**: Migration mapping document

**For each current file**:
- Current location
- Intended location
- Rationale
- Cross-references to update
- Duplicate handling

### Phase 3: Identify Sub-Projects

**Candidate sub-projects**:
- h1-conditional-attachment
- h2-send-gate-investigation  
- h3-query-visibility
- slash-commands-experiment (already partially exists via assistant-self-testing-limits)

**For each**:
- Determine if substantial enough for sub-project
- Define scope and deliverables
- Create coordination entry

### Phase 4: Execute Reorganization

**Steps**:
1. Create new folder structure
2. Move files to new locations
3. Update cross-references
4. Create coordination.md
5. Validate no broken links
6. Update parent README

### Phase 5: Document Pattern

**Update project-lifecycle.mdc**:
- Add "Complex Investigation Structure" section
- Define folder purposes
- Provide decision framework
- Link to rules-enforcement-investigation as example

### Phase 6: Create Sub-Projects (if appropriate)

**For each identified sub-project**:
1. Create project directory
2. Create ERD (scope and requirements)
3. Create tasks.md
4. Migrate relevant files
5. Create README with parent link
6. Add to coordination.md

---

## 7. Success Metrics

**Findability**: Can locate any document within 2 clicks from README  
**Clarity**: Each folder's purpose obvious from name and contents  
**Reusability**: Pattern documented for next complex investigation  
**Completeness**: All 40 files accounted for, none lost  
**Validity**: All cross-references resolve correctly

---

## 8. Dependencies

- rules-enforcement-investigation current files
- project-lifecycle.mdc (will be updated)
- User decisions on edge cases

---

## 9. Risks

**Risk**: Breaking links during reorganization  
**Mitigation**: Test all references after moves; use relative paths

**Risk**: Over-structuring (too many folders)  
**Mitigation**: Follow "only create folder when 3+ files" rule

**Risk**: Losing context during splits  
**Mitigation**: Clear coordination.md; sub-projects link to parent

**Risk**: Making simple projects complex  
**Mitigation**: Document when this structure applies (only complex investigations)

---

## 10. Timeline

- **Phase 1**: 1-2 hours (design structure standard)
- **Phase 2**: 1 hour (create reorganization plan)
- **Phase 3**: 30 minutes (identify sub-projects)
- **Phase 4**: 2-3 hours (execute reorganization)
- **Phase 5**: 1 hour (document pattern)
- **Phase 6**: 2-4 hours (create sub-projects if appropriate)
- **Total**: 7.5-11.5 hours

---

## 11. Related

- [rules-enforcement-investigation](../rules-enforcement-investigation/) - Project to be reorganized
- Gap #11 - Documentation structure not defined
- [project-lifecycle.mdc](/.cursor/rules/project-lifecycle.mdc) - Will be updated with structure guidance

