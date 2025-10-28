---
status: completed
completed: 2025-10-28
mode: full
owner: rules-maintainers
created: 2025-10-27
lastUpdated: 2025-10-28
---

# Engineering Requirements Document — Per-Project Changelog

Mode: Full (expanded from Lite)

## 1. Problem Statement

Projects lack a clear, structured changelog showing what changed over time. When returning to a project after weeks or months, there's no quick way to see:

- What was accomplished in each session
- Key decisions and turning points
- Evolution of approach or scope
- What's different from initial plan

**Why now**: As projects grow in complexity (investigation projects with 50+ files), a per-project changelog provides essential context for understanding project history without reading every session summary.

## 2. Goals

### Primary

- Provide a simple, consistent format for per-project changelogs
- Track major changes, decisions, and milestones within each project
- Make project history scannable and useful for returning contributors

### Secondary

- Optional automation to generate changelog entries from task completion
- Integration with project archival workflow (finalize changelog on archive)
- Link to root `CHANGELOG.md` for repository-wide context

## 3. Current State

**What exists**:

- Root `CHANGELOG.md` (repository-wide, managed by Changesets)
- Project `tasks.md` files (track task completion, not project evolution)
- Session summaries in investigation projects (chronological, but verbose)

**Gaps**:

- No per-project change tracking
- Project evolution is scattered across session files, commit history, task updates
- No standard format for "what's changed" at project level

## 4. Proposed Solution

### Simple Manual Changelog System

**Approach**:

1. Add `CHANGELOG.md` to each project directory (optional artifact)
2. Follow Keep-a-Changelog format with project-specific categories
3. Manual maintenance by default (low complexity, immediate value)
4. Template for consistency across projects
5. Guidance in `project-lifecycle.mdc` for when/how to use

**Format** (Keep-a-Changelog inspired):

```markdown
# Changelog — <Project Title>

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added

- New features or capabilities

### Changed

- Changes to existing functionality

### Decisions

- Key decisions and rationale

### Removed

- Removed features or approaches

## [Phase N] - YYYY-MM-DD

### Summary

Brief phase summary

### Added

- ...

### Changed

- ...

### Decisions

- ...
```

**Categories** (project-specific):

- **Added**: New features, approaches, artifacts
- **Changed**: Scope changes, refactors, approach pivots
- **Decisions**: Key decisions with rationale
- **Removed**: Deprecated approaches, out-of-scope items
- **Fixed**: Corrections to findings, protocols, or artifacts

**When to update**:

- End of significant work sessions
- After major decisions or scope changes
- Before phase transitions
- During project completion/archival

## 5. Success Criteria

### Must Have

- [ ] Template for per-project `CHANGELOG.md`
- [ ] Documentation in `project-lifecycle.mdc` (when to use, how to format)
- [ ] Example changelog in an active project
- [ ] Integration with archival workflow (finalize entry on archive)

### Should Have

- [x] Script to stub changelog from project creation
- [x] Validation: check changelog exists for completed projects
- [ ] Automatic generation script with pattern detection

### Nice to Have

- [ ] Link project changelog entries to root `CHANGELOG.md`
- [ ] GitHub Action to remind on phase completion

## 6. Non-Goals

- Auto-generating all entries (manual is fine for Lite)
- Replacing session summaries (changelog is high-level, sessions are detailed)
- Changing root `CHANGELOG.md` workflow (Changesets stays as-is)
- Backfilling changelogs for all archived projects (optional enhancement)

## 7. Dependencies & Constraints

**Dependencies**:

- Project lifecycle conventions (`project-lifecycle.mdc`)
- Archival workflow scripts (`project-archive-workflow.sh`)

**Constraints**:

- Must not interfere with existing Changesets workflow
- Should be optional (not all projects need detailed changelogs)
- Keep simple enough for manual maintenance

## 8. Approach

### Phase 1: Template & Documentation (2 hours) ✅ COMPLETE

1. Create `CHANGELOG.md` template in `.cursor/templates/project-lifecycle/`
2. Update `project-lifecycle.mdc` with changelog guidance
3. Add example changelog to an active investigation project (e.g., `rules-enforcement-investigation`)

### Phase 2: Tooling & Integration (3 hours) ✅ COMPLETE

4. Update `project-create.sh` to optionally stub `CHANGELOG.md`
5. Update `project-archive-workflow.sh` to prompt for final changelog entry
6. Add validation: check completed projects have changelog or explicit skip

### Phase 3: Documentation & Rollout (1 hour) ✅ COMPLETE

7. Document in README and project-lifecycle docs
8. Create example in 1-2 active projects
9. Announce in repository docs

### Phase 4: Automatic Generation (8-10 hours) 🔄 IN PROGRESS

10. Implement hybrid detection script (`changelog-update.sh`)
    - Parse tasks.md for phase/task completion patterns
    - Parse git log for conventional commits
    - Detect ERD status changes
    - Extract decision markers (D1:, Decision:, etc.)
    - Detect scope changes (Migrated, Superseded, Deferred, Carryovers)
11. Add interactive mode for user review/editing
12. Add auto mode for batch generation
13. Test with multiple archived projects
14. Document automation workflow

**Total effort**: ~14-16 hours (original 6 hours + 8-10 hours automation)

## 9. Open Questions

1. **Required vs Optional**: Should all projects have a changelog, or only complex ones?

   - **Recommendation**: Optional by default, required for investigations (>15 files)

2. **Granularity**: How detailed should entries be?

   - **Recommendation**: High-level only (phases, major decisions, scope changes)

3. **Backfill**: Should we backfill changelogs for archived projects?
   - **Recommendation**: No; apply to new/active projects only

## 10. Related Work

- [Changelog Automation](./_archived/2025/changelog-automation/) — Root CHANGELOG implementation
- [Project Lifecycle](./project-lifecycle/) — Project structure and conventions
- [Document Governance](./document-governance/) — Document standards
- [Keep a Changelog](https://keepachangelog.com/) — Format inspiration

## 11. References

- `assistant-git-usage.mdc` → Changesets workflow
- `project-lifecycle.mdc` → Project structure and completion
- `.cursor/scripts/project-archive-workflow.sh` → Archival automation
