# Tasks: Investigation Documentation Structure

**Status**: ACTIVE  
**Created**: 2025-10-16  
**Completion**: 0%

---

## Phase 1: Design Structure Standard

- [ ] 1.0 Define folder purposes
  - [ ] 1.1 Root baseline: README, erd, tasks, findings (summary or index?)
  - [ ] 1.2 findings/ - Individual finding documents (one per gap)
  - [ ] 1.3 analysis/ - Analysis docs; when to create subfolders
  - [ ] 1.4 decisions/ - Decision documents
  - [ ] 1.5 guides/ - Reference guides  
  - [ ] 1.6 protocols/ - Test/validation protocols
  - [ ] 1.7 sessions/ - Session summaries
  - [ ] 1.8 test-results/ - Test execution data
  - [ ] 1.9 tests/ - Test plan templates (already correct)
  - [ ] 1.10 _archived/ - Archived root docs

- [ ] 2.0 Define decision framework
  - [ ] 2.1 When to create new file vs update existing
  - [ ] 2.2 When to create subfolder (3+ files rule?)
  - [ ] 2.3 When to split into sub-project
  - [ ] 2.4 Naming patterns for each category
  - [ ] 2.5 File type → location mapping

## Phase 2: Create Reorganization Plan

- [ ] 3.0 Map all 40 files
  - [ ] 3.1 Root files (7) → determine correct location
  - [ ] 3.2 analysis/ files (6) → flat vs subfolders
  - [ ] 3.3 archived-summaries/ (6) → move to _archived/
  - [ ] 3.4 test-execution/ (14) → split by purpose
  - [ ] 3.5 tests/ (7) → keep as-is

- [ ] 4.0 Resolve duplicates
  - [ ] 4.1 slash-commands-decision.md (root vs test-execution) → pick canonical
  - [ ] 4.2 Identify any other duplicates
  - [ ] 4.3 Merge or archive duplicates

- [ ] 5.0 Plan cross-reference updates
  - [ ] 5.1 List all internal links
  - [ ] 5.2 Calculate new paths after moves
  - [ ] 5.3 Create update checklist

## Phase 3: Identify Sub-Projects

- [ ] 6.0 Evaluate candidates
  - [ ] 6.1 H1 conditional attachment - is this sub-project worthy?
  - [ ] 6.2 H2 send gate investigation - separate project?
  - [ ] 6.3 H3 query visibility - separate project?
  - [ ] 6.4 Slash commands / prompt templates - separate project?
  - [ ] 6.5 Assistant self-testing limits - already separate ✅

- [ ] 7.0 For each sub-project
  - [ ] 7.1 Define scope (what moves to sub-project)
  - [ ] 7.2 Create project directory in docs/projects/
  - [ ] 7.3 Create ERD
  - [ ] 7.4 Create tasks.md
  - [ ] 7.5 Create README with parent link
  - [ ] 7.6 Add to parent coordination.md

## Phase 4: Execute Reorganization

- [ ] 8.0 Create folder structure
  - [ ] 8.1 Create findings/, decisions/, guides/, protocols/, sessions/, test-results/
  - [ ] 8.2 Create analysis subfolders where needed
  - [ ] 8.3 Rename archived-summaries/ to _archived/

- [ ] 9.0 Move files
  - [ ] 9.1 Move root files to correct folders
  - [ ] 9.2 Move analysis files (create subfolders if needed)
  - [ ] 9.3 Move archived-summaries to _archived/
  - [ ] 9.4 Reorganize test-execution into appropriate folders
  - [ ] 9.5 Remove duplicate files

- [ ] 10.0 Update cross-references
  - [ ] 10.1 Update links in all moved files
  - [ ] 10.2 Update README navigation
  - [ ] 10.3 Update tasks.md references
  - [ ] 10.4 Update findings.md references
  - [ ] 10.5 Validate all links resolve

- [ ] 11.0 Create coordination.md
  - [ ] 11.1 List all sub-projects
  - [ ] 11.2 Document status of each
  - [ ] 11.3 Link to outcomes/resolutions
  - [ ] 11.4 Explain how each contributes to parent

## Phase 5: Document Pattern

- [ ] 12.0 Update project-lifecycle.mdc
  - [ ] 12.1 Add "Complex Investigation Structure" section
  - [ ] 12.2 Define when to use this structure (vs simple projects)
  - [ ] 12.3 Document folder purposes
  - [ ] 12.4 Provide decision framework
  - [ ] 12.5 Link to rules-enforcement-investigation as example

- [ ] 13.0 Create structure template
  - [ ] 13.1 Folder structure tree
  - [ ] 13.2 Purpose of each folder
  - [ ] 13.3 Examples of what goes where
  - [ ] 13.4 Decision flowchart

## Phase 6: Validate

- [ ] 14.0 Validation checks
  - [ ] 14.1 All 40 files accounted for
  - [ ] 14.2 No broken links (run links-check.sh)
  - [ ] 14.3 No duplicates remain
  - [ ] 14.4 Each folder has 1+ files (no empty folders)
  - [ ] 14.5 Navigation test (can find any doc in ≤2 clicks)

---

## Open Questions

1. **findings.md**: Keep in root as summary/index, or move to findings/ as README?
2. **Pre-test discovery**: Are these sub-projects or analysis docs?
3. **Meta-violations**: findings/ or test-results/?
4. **coordination.md**: In root or separate folder?
5. **Sub-project threshold**: How substantial to warrant separate project?

---

## Success Criteria

- [ ] Clear folder structure with defined purposes
- [ ] All 40 files in correct locations
- [ ] No duplicates
- [ ] coordination.md tracks sub-projects clearly
- [ ] All cross-references valid
- [ ] Pattern documented in project-lifecycle.mdc
- [ ] Structure reusable for future complex projects
- [ ] Navigation intuitive (find any doc quickly)

