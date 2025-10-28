# Changelog — Shell And Script Tooling

All notable changes to this project will be documented in this file.

The format is inspired by [Keep a Changelog](https://keepachangelog.com/),
adapted for project lifecycle tracking.

---

## Usage Instructions

**When to update**:

- End of significant work sessions
- After major decisions or scope changes
- Before phase transitions
- During project completion/archival

**Categories**:

- **Added** — New features, approaches, artifacts
- **Changed** — Scope changes, refactors, approach pivots
- **Decisions** — Key decisions with rationale
- **Removed** — Deprecated approaches, out-of-scope items
- **Fixed** — Corrections to findings, protocols, or artifacts

**Tips**:

- Keep entries high-level (not every commit)
- Link to detailed session summaries or findings when relevant
- Focus on "what changed" and "why" (not implementation details)
- Use past tense for completed work

---

## [Unreleased]

### Added

- _New features or capabilities added to the project_

### Changed

- _Changes to existing functionality, scope, or approach_

### Decisions

- _Key decisions made with rationale_

### Removed

- _Features, approaches, or items removed from scope_

### Fixed

- _Corrections to findings, protocols, or artifacts_

---


---

## [Phase X] - 2025-10-27

### Summary

TODO: Add phase summary

### Added

- 1.0 Create unified project scaffold (ERD + tasks) with references
- 2.0 Add this project to `docs/projects/README.md` under Active
- 3.0 For each source project, add a backlink to this ERD
- 4.0 Derive cross-cutting decisions and portability policy
- 5.0 Implement `.lib.sh` enhancements
- 6.0 Implement network effects seam (D4)
- 7.0 Implement ShellCheck runner (D5)
- 9.0 Create validators for cross-cutting decisions
- 10.0 Record adoption status in source projects (COMPLETE ✅)
- 17.0 CI integration
- 19.0 Source project task reconciliation — ✅ COMPLETE

### Changed

- 8.0 Migrate all network-using scripts to networkless standard
- 16.0 Documentation updates
- 18.0 Organize scripts into subdirectories — **MIGRATED to script-refinement Task 3.0**
- 20.0 Refactor existing Unix Philosophy violators — **✅ MAJOR WORK COMPLETE (2025-10-14)**

### Fixed

- 13.0 Fix test runner environment leakage ⚠️ RESOLVED
- 14.0 Fix tmp-scan creation
- 15.0 Investigate .github/ deletion ✅ RESOLVED

### Decisions

-   - [x] 4.1 D1: Help/version flags minimums and section schema
-   - [x] 4.2 D2: Strict-mode baseline and traps
-   - [x] 4.3 D3: Error semantics and exit code catalog
-   - [x] 4.4 D4: Networkless effects seam defaults
-   - [x] 4.5 D5: Dependency portability policy
-   - [x] 4.6 D6: Test isolation and environment hygiene (added 2025-10-13)
-   - [x] 13.6.4 Documented in ERD D6: scripts keep seams, tests use subshell isolation ✅
## [Phase 1] - 2025-01-01

### Summary

_Brief phase summary: what was accomplished and key outcomes_

### Added

- Created project structure (ERD, tasks, README)
- Initial template and documentation

### Changed

- _Scope or approach changes during this phase_

### Decisions

- _Key decisions made during this phase_

---

## Template Notes

**Replace placeholders**:

- `Shell And Script Tooling` → Your project title
- `2025-01-01` → Actual dates
- `[Phase N]` → Actual phase names/numbers

**Remove**:

- This "Usage Instructions" section after first use
- This "Template Notes" section
- Empty categories (if no entries for that category in a phase)

**Phase naming**:

- Use descriptive names: `[Phase 1: Discovery]`, `[Phase 2: Implementation]`
- Or simple numbers: `[Phase 1]`, `[Phase 2]`
- Match phase names from your `tasks.md` file

**Unreleased section**:

- Keep this section for ongoing work
- Move entries to a dated phase section when phase completes
- Always have an `[Unreleased]` section at the top (even if empty)
