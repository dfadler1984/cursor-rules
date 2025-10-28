# Changelog — Per-Project Changelog (Lite)

All notable changes to this project will be documented in this file.

The format is inspired by [Keep a Changelog](https://keepachangelog.com/),
adapted for project lifecycle tracking.

---

## [Unreleased]

_No unreleased changes_

---

## [Phase 5: Enhancements (Carryovers)] - 2025-10-28

### Summary

Implemented all 4 optional enhancements: backfilled archived projects, created diff script, added changelogs to active investigations, and automated GitHub Action for phase completion detection.

### Added

- Created `changelog-backfill.sh` script for archived projects (138 lines)
- Created `changelog-backfill.test.sh` with 3 passing tests
- Created `changelog-diff.sh` script for milestone comparison (97 lines)
- Created `changelog-diff.test.sh` with 3 passing tests
- Created GitHub Action workflow `changelog-phase-reminder.yml`
- Backfilled changelogs for 3 archived projects (shell-and-script-tooling, slash-commands-runtime, routing-optimization)
- Generated changelogs for 3 active investigations (multi-chat-coordination, archived-projects-audit, consent-gates-refinement)

### Changed

- Updated 2 project READMEs to reference changelogs (multi-chat-coordination, archived-projects-audit)

### Decisions

- **Backfill approach**: Symlink archived projects temporarily for changelog-update.sh compatibility
- **Diff script**: Basic implementation (extensible for future enhancements)
- **GitHub Action**: Comment-based reminder (non-blocking, helpful nudge)
- **Active projects**: Selected top 3 by file count for immediate value

---

## [Phase 4: Automatic Generation] - 2025-10-28

### Summary

Completed hybrid automatic/interactive changelog generation with pattern detection, intelligent categorization, and three operational modes.

### Added

- Created `changelog-update.sh` script (347 lines) with full implementation
- Created `changelog-update.test.sh` with 11 passing tests
- Implemented `parse_tasks_md()` function (detects phases, tasks, decisions, scope changes)
- Implemented `categorize_task()` keyword-based categorization (Create→Added, Update→Changed, etc.)
- Implemented `generate_changelog_entries()` formatter
- Added file appending logic with backup creation
- Created automation design document (`analysis/automation-design.md`)
- Added test fixtures (sample-tasks.md, sample-changelog.md)

### Changed

- Project scope expanded from "Lite" to "Full" with complete automation
- Updated `capabilities.mdc` with new script documentation
- Mode set to "full" in ERD front matter
- README updated with automation features

### Decisions

- **Hybrid approach**: Task-based + Commit-based detection (task-based fully implemented)
- **Pattern analysis**: Identified 7 detectable patterns from archived projects
- **Modes**: All three modes functional (interactive default, auto, dry-run)
- **Categorization**: Keyword-based mapping (extensible, simple to maintain)
- **Insertion point**: After [Unreleased] section with separator
- **Backup strategy**: Create .bak file before modifying CHANGELOG.md
- **Phase name cleanup**: Strip time estimates and completion markers

### Fixed

- TDD violations corrected:
  - Created `changelog-update.test.sh` (11 tests, all passing)
  - Added tests to `project-create.test.sh` (+2 tests for --with-changelog)
  - Added test to `project-archive-workflow.test.sh` (+1 test for changelog detection)
  - Added test to `validate-project-lifecycle.test.sh` (+1 test for CHANGELOG advisory)
- Test failures resolved (grep pattern matching, command substitution with set -e)
- Phase name formatting (trailing spaces, emoji handling)

---

## [Phase 1: Template & Documentation] - 2025-10-27

### Summary

Created template, documented in project-lifecycle rule, and added example to rules-enforcement-investigation project.

### Added

- Created `.cursor/templates/project-lifecycle/CHANGELOG.template.md`
- Added "Per-Project Changelog" section to `project-lifecycle.mdc`
- Created example changelog for rules-enforcement-investigation project
- Updated rules-enforcement-investigation README to reference changelog

### Decisions

- **Format**: Keep-a-Changelog inspired with project-specific categories (Added, Changed, Decisions, Removed, Fixed)
- **Optional by default**: Recommended for complex projects (>15 files), not required for all projects
- **Template approach**: Simple markdown template with placeholders, manually filled

---

## [Phase 2: Tooling & Integration] - 2025-10-27

### Summary

Updated scripts for project creation, archival, and validation to support changelogs.

### Added

- `--with-changelog` flag to `project-create.sh`
- Template copy and placeholder replacement logic
- Final changelog entry prompt in `project-archive-workflow.sh`
- Advisory check in `validate-project-lifecycle.sh` for complex projects without changelog

### Changed

- `project-create.sh` usage updated with changelog examples
- `project-archive-workflow.sh` now prompts for final entry if changelog exists
- `validate-project-lifecycle.sh` warns if complex project (>15 files) lacks changelog

### Decisions

- **Non-interactive template**: Use `sed` to replace placeholders (simple, no dependencies)
- **Archival prompt**: Interactive prompt for final entry (manual, flexible)
- **Validation level**: Warning (not error) for missing changelogs (optional feature)

---

## [Phase 3: Documentation & Rollout] - 2025-10-27

### Summary

Documented changelog feature in repository docs and created examples in active projects.

### Added

- Per-Project Changelogs section in `docs/projects/README.md`
- This changelog (dogfooding the feature)

### Changed

- Updated project structure overview to include CHANGELOG as optional artifact

### Decisions

- **Documentation location**: `docs/projects/README.md` (central projects index)
- **Example strategy**: Use rules-enforcement-investigation as primary example (already has substantial changelog)

---

## Notes

**Total Duration**: 1 day (2025-10-27)  
**Outcome**: Simple, manual changelog system for per-project tracking  
**Status**: In progress (Phase 3)
