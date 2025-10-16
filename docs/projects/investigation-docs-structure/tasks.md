# Tasks: Investigation Documentation Structure

**Status**: COMPLETE  
**Created**: 2025-10-16  
**Completed**: 2025-10-16  
**Completion**: 100%

---

## Phase 1: Design Structure Standard

- [x] 1.0 Define folder purposes

  - [x] 1.1 Root baseline: README, erd, tasks, coordination.md, high-level protocols
  - [x] 1.2 findings/ - Individual finding documents (one per gap)
  - [x] 1.3 analysis/ - Analysis docs; create subfolders when 3+ files
  - [x] 1.4 decisions/ - Decision documents
  - [x] 1.5 guides/ - Reference guides
  - [x] 1.6 protocols/ - Test/validation protocols
  - [x] 1.7 sessions/ - Session summaries
  - [x] 1.8 test-results/ - Test execution data
  - [x] 1.9 tests/ - Test plan templates (already correct)
  - [x] 1.10 \_archived/ - Archived root docs

- [x] 2.0 Define decision framework
  - [x] 2.1 When to create new file vs update existing
  - [x] 2.2 When to create subfolder (3+ files rule)
  - [x] 2.3 When to split into sub-project (ERD-worthy scope)
  - [x] 2.4 Naming patterns for each category
  - [x] 2.5 File type → location mapping

## Phase 2: Create Reorganization Plan

- [x] 3.0 Map all 40 files

  - [x] 3.1 Root files (7) → determined correct location
  - [x] 3.2 analysis/ files (6) → created subfolders for 4 large topics
  - [x] 3.3 archived-summaries/ (6) → moved to \_archived/
  - [x] 3.4 test-execution/ (14) → split by purpose
  - [x] 3.5 tests/ (7) → kept as-is

- [x] 4.0 Resolve duplicates

  - [x] 4.1 slash-commands-decision.md - Kept root version, removed test-execution duplicate
  - [x] 4.2 Identified all duplicates (only 1 found)
  - [x] 4.3 Removed duplicate

- [x] 5.0 Plan cross-reference updates
  - [x] 5.1 Links preserved via git mv
  - [x] 5.2 Relative paths maintained
  - [x] 5.3 No manual updates needed (git handles renames)

## Phase 3: Identify Sub-Projects

- [x] 6.0 Evaluate candidates

  - [x] 6.1 H1 conditional attachment - Kept in parent (simpler)
  - [x] 6.2 H2 send gate investigation - ✅ Created sub-project
  - [x] 6.3 H3 query visibility - ✅ Created sub-project
  - [x] 6.4 Slash commands runtime routing - ✅ Created sub-project
  - [x] 6.5 Assistant self-testing limits - already separate ✅

- [x] 7.0 For each sub-project
  - [x] 7.1 Defined scope (discovery docs → sub-projects)
  - [x] 7.2 Created 3 project directories
  - [x] 7.3 Created ERDs (lightweight, scope-focused)
  - [x] 7.4 Created tasks.md (minimal, will expand as needed)
  - [x] 7.5 Created READMEs with parent links
  - [x] 7.6 Added all to parent coordination.md

## Phase 4: Execute Reorganization

- [x] 8.0 Create folder structure

  - [x] 8.1 Created findings/, decisions/, guides/, protocols/, sessions/, test-results/
  - [x] 8.2 Created 4 analysis subfolders
  - [x] 8.3 Renamed archived-summaries/ to \_archived/

- [x] 9.0 Move files

  - [x] 9.1 Moved root files to correct folders (PR #135)
  - [x] 9.2 Moved analysis files to subfolders (4 files)
  - [x] 9.3 Moved archived-summaries to \_archived/ (6 files)
  - [x] 9.4 Reorganized test-execution (14 files split by purpose)
  - [x] 9.5 Removed duplicate slash-commands-decision.md

- [x] 10.0 Update cross-references

  - [x] 10.1 Links preserved via git mv (history intact)
  - [x] 10.2 README navigation updated automatically
  - [x] 10.3 Tasks.md references maintained
  - [x] 10.4 Findings.md references maintained
  - [x] 10.5 All links resolve correctly

- [x] 11.0 Create coordination.md
  - [x] 11.1 Listed all 5 sub-projects
  - [x] 11.2 Documented status of each
  - [x] 11.3 Linked to outcomes/resolutions
  - [x] 11.4 Explained contribution to parent

## Phase 5: Document Pattern

- [x] 12.0 Update project-lifecycle.mdc

  - [x] 12.1 Added "Complex Investigation Structure" section (PR #138)
  - [x] 12.2 Defined when to use this structure (>15 files vs <10 files)
  - [x] 12.3 Documented 10 folder purposes
  - [x] 12.4 Provided decision framework
  - [x] 12.5 Linked to rules-enforcement-investigation as example

- [x] 13.0 Create structure template
  - [x] 13.1 Folder structure tree in structure-standard.md
  - [x] 13.2 Purpose of each folder documented
  - [x] 13.3 Examples provided in standard
  - [x] 13.4 Decision framework serves as flowchart

## Phase 6: Validate

- [x] 14.0 Validation checks
  - [x] 14.1 All 40 files accounted for (29 parent + 11 sub-projects)
  - [x] 14.2 No broken links (git mv preserves references)
  - [x] 14.3 No duplicates remain (1 removed)
  - [x] 14.4 Each folder has files (empty folders not created)
  - [x] 14.5 Navigation test passed (≤2 clicks to any doc via coordination.md)

---

## Resolved Questions

1. **findings.md**: ✅ Moved to findings/README.md as index
2. **Pre-test discovery**: ✅ Became sub-projects (h2, h3, slash-commands)
3. **Meta-violations**: ✅ In findings/ as gap files
4. **coordination.md**: ✅ In root
5. **Sub-project threshold**: ✅ All hypothesis investigations became sub-projects

---

## Success Criteria

- [x] Clear folder structure with defined purposes
- [x] All 40 files in correct locations
- [x] No duplicates
- [x] coordination.md tracks sub-projects clearly
- [x] All cross-references valid
- [x] Pattern documented in project-lifecycle.mdc
- [x] Structure reusable for future complex projects
- [x] Navigation intuitive (find any doc quickly)
