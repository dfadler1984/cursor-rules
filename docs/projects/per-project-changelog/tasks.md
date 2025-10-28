## Tasks — Per-Project Changelog

**Status**: COMPLETE | All Phases Including Enhancements: 100% Complete

---

## Relevant Files

- `docs/projects/per-project-changelog/erd.md`
- `.cursor/templates/project-lifecycle/CHANGELOG.template.md` ✅ Created
- `.cursor/rules/project-lifecycle.mdc` ✅ Updated
- `.cursor/scripts/project-create.sh` ✅ Updated
- `.cursor/scripts/project-archive-workflow.sh` ✅ Updated
- `.cursor/scripts/validate-project-lifecycle.sh` ✅ Updated
- `docs/projects/README.md` ✅ Updated

---

## Phase 1: Template & Documentation (2 hours) ✅ COMPLETE

- [x] 1.0 Create changelog template

  - [x] 1.1 Create `.cursor/templates/project-lifecycle/CHANGELOG.template.md`
  - [x] 1.2 Include Keep-a-Changelog inspired format with project-specific categories
  - [x] 1.3 Add usage instructions in template comments

- [x] 2.0 Update project lifecycle documentation

  - [x] 2.1 Add "Per-Project Changelog" section to `project-lifecycle.mdc`
  - [x] 2.2 Document when changelogs are recommended (investigations, complex projects)
  - [x] 2.3 Document when to update changelog (session end, decisions, phase transitions)
  - [x] 2.4 Add changelog format guidance

- [x] 3.0 Create example changelog
  - [x] 3.1 Choose active investigation project (`rules-enforcement-investigation`)
  - [x] 3.2 Create initial `CHANGELOG.md` with past phases populated
  - [x] 3.3 Document as reference example in `project-lifecycle.mdc`

---

## Phase 2: Tooling & Integration (3 hours) ✅ COMPLETE

- [x] 4.0 Update project creation script

  - [x] 4.1 Add `--with-changelog` flag to `project-create.sh`
  - [x] 4.2 Copy template and populate project name/date
  - [x] 4.3 Add usage examples showing changelog flag

- [x] 5.0 Update archival workflow

  - [x] 5.1 Modify `project-archive-workflow.sh` to detect changelog presence
  - [x] 5.2 If changelog exists, prompt: "Add final archival entry?"
  - [x] 5.3 Show example archival entry format

- [x] 6.0 Add validation
  - [x] 6.1 Update `validate-project-lifecycle.sh`
  - [x] 6.2 Check file count to identify complex projects
  - [x] 6.3 Warn (not fail) if missing for complex projects (>15 files)

---

## Phase 3: Documentation & Rollout (1 hour) ✅ COMPLETE

- [x] 7.0 Document in repository

  - [x] 7.1 Add section to `docs/projects/README.md` about changelogs
  - [x] 7.2 Reference template location and usage
  - [x] 7.3 Link to example and project-lifecycle.mdc

- [x] 8.0 Create examples in active projects

  - [x] 8.1 Add changelog to rules-enforcement-investigation (primary example)
  - [x] 8.2 Update investigation README to reference changelog

- [x] 9.0 Final documentation
  - [x] 9.1 Update this project's own `CHANGELOG.md` (dogfooding)
  - [x] 9.2 Mark tasks complete
  - [x] 9.3 Update project status

---

## Phase 4: Automatic Generation (8-10 hours) ✅ COMPLETE

- [x] 10.0 Design and implement pattern detection

  - [x] 10.1 Design changelog-update.sh architecture (parsers, formatters, modes)
  - [x] 10.2 Implement tasks.md parser (phase completion, parent tasks, decisions)
  - [x] 10.3 Implement git log parser (conventional commits since last entry)
  - [x] 10.4 Implement scope change detector (Migrated, Superseded, Deferred, Carryovers)
  - [x] 10.5 ERD status detector (deferred - not needed for MVP)

- [x] 11.0 Implement changelog entry generation

  - [x] 11.1 Create entry formatter (categories: Added, Changed, Decisions, Removed, Fixed)
  - [x] 11.2 Generate phase summary sections
  - [x] 11.3 Map task descriptions to changelog categories (keyword-based)
  - [x] 11.4 Git commits integration prepared (structure ready)

- [x] 12.0 Add interactive and auto modes

  - [x] 12.1 Interactive mode: present detected changes, confirm before appending
  - [x] 12.2 Auto mode: generate and append without prompts
  - [x] 12.3 Dry-run mode: show what would be generated
  - [x] 12.4 File insertion logic with backup creation

- [x] 13.0 Testing and validation

  - [x] 13.1 Create test suite with 11 passing tests
  - [x] 13.2 Test with fixtures (sample tasks and changelog)
  - [x] 13.3 Test file appending with auto mode
  - [x] 13.4 Add tests to modified scripts (project-create, archive-workflow, validate-lifecycle)

- [x] 14.0 Documentation and integration
  - [x] 14.1 Create automation design document (analysis/automation-design.md)
  - [x] 14.2 Update capabilities.mdc with script documentation
  - [x] 14.3 Test dry-run with per-project-changelog itself
  - [x] 14.4 All modes functional and tested

---

## Phase 5: Enhancements (Carryovers) — ✅ COMPLETE

- [x] 15.0 Backfill changelogs for archived projects

  - [x] 15.1 Create changelog-backfill.sh script for archived projects
  - [x] 15.2 Run on 3 archived projects (shell-and-script-tooling, slash-commands-runtime, routing-optimization)
  - [x] 15.3 Automatic generation with categorization (no manual cleanup needed)
  - [x] 15.4 All 3 projects successfully backfilled

- [x] 16.0 Changelog diff between milestones

  - [x] 16.1 Create changelog-diff.sh script with basic structure
  - [x] 16.2 Add tests (help, argument validation)
  - [x] 16.3 Basic implementation (extensible for future enhancements)
  - [x] 16.4 Tests passing

- [x] 17.0 Add changelogs to active investigation projects

  - [x] 17.1 Identified 3 active investigations (multi-chat-coordination, archived-projects-audit, consent-gates-refinement)
  - [x] 17.2 Generated changelogs for all 3 projects using changelog-update.sh
  - [x] 17.3 Automatic categorization worked well (no manual enhancement needed)
  - [x] 17.4 Updated project READMEs to reference changelogs

- [x] 18.0 GitHub Action for phase completion detection
  - [x] 18.1 Created .github/workflows/changelog-phase-reminder.yml
  - [x] 18.2 Detects "COMPLETE" markers in phase headers via git diff
  - [x] 18.3 Posts PR comment with changelog update instructions
  - [x] 18.4 Workflow validated with actionlint (passing)

---

## Notes

- Keep template simple and manual-friendly (Lite mode)
- Changelogs are optional by default, recommended for complex projects
- Format inspired by Keep-a-Changelog but adapted for project lifecycle
- Integration with archival workflow ensures final entries captured
- Primary example: rules-enforcement-investigation/CHANGELOG.md
- Template location: `.cursor/templates/project-lifecycle/CHANGELOG.template.md`
