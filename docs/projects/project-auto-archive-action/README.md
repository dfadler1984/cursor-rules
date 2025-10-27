# Project Auto Archive Action

Automate project archival with zero-touch GitHub Action. When a project is complete, the action automatically archives it, fixes links, updates the README, and auto-merges.

## Status

**Active** — Phases 1-3 complete, awaiting real-world validation

## Quick Overview

**Problem**: Manual archival is repetitive (run scripts, fix links, update README, commit, PR, merge)

**Solution**: GitHub Action that:

1. Detects completed projects after PR merge
2. Archives them to `_archived/<YYYY>/`
3. Fixes broken links automatically
4. Regenerates projects README
5. Creates PR with auto-merge enabled
6. Zero human intervention required

## Completion Criteria

A project is ready for auto-archive when **ALL three** are true:

1. ✅ **All tasks checked** — No `- [ ]` in main task sections
2. ✅ **Carryovers resolved** — No `## Carryovers` section OR section is empty
3. ✅ **Final summary written** — `final-summary.md` file exists

## Workflow

```
User: Completes final task + writes final-summary.md
  ↓
User: Merges PR to main
  ↓
Action: Runs on push to main
  ↓
Action: Detects completed projects
  ↓
Action: Archives projects (batch)
  ├─ Move to _archived/<YYYY>/
  ├─ Update ERD status to "completed"
  └─ Fix broken links
  ↓
Action: Regenerate projects README
  ↓
Action: Create PR (bot/auto-archive-<timestamp>)
  ├─ Comprehensive description
  ├─ Labels: auto-merge, bot
  └─ Enable auto-merge
  ↓
GitHub: Auto-merge when CI passes
  ↓
Done! 🎉
```

## Implementation Plan

### Phase 1: Scripts (TDD)

**New Scripts:**

- `archive-detect-complete.sh` — Detect projects meeting all 3 criteria
- `archive-fix-links.sh` — Fix broken links after move
- Tests for both scripts

### Phase 2: GitHub Workflow

**New Workflow:**

- `.github/workflows/project-auto-archive.yml`
- Orchestrates: detect → archive → fix → PR → auto-merge
- Pattern: Similar to `changesets.yml` auto-merge bot

### Phase 3: Assistant Integration

**Rules Update:**

- Add final-summary prompt when tasks complete
- Update `.cursor/rules/project-lifecycle.mdc`
- Document zero-touch workflow

### Phase 4: Validation

**Testing:**

- Create test project
- Verify auto-archive runs
- Verify auto-merge completes

## Dependencies

**Existing Scripts (Reuse):**

- `.cursor/scripts/project-archive.sh` — Move to archive
- `.cursor/scripts/generate-projects-readme.sh` — Regenerate README

**New Scripts (Create):**

- `.cursor/scripts/archive-detect-complete.sh`
- `.cursor/scripts/archive-fix-links.sh`

**GitHub Token:**

- Requires: `contents: write`, `pull-requests: write`
- Auto-provided: `GITHUB_TOKEN` in Actions

## Error Handling

**Action Fails When:**

- Archive script errors
- Link fixer fails
- README generation errors
- Git conflicts
- PR creation fails

**Action Skips When:**

- No completed projects found (no-op, exit 0)
- Project has unchecked tasks
- Project has pending carryovers
- Project missing final-summary.md

**Atomic Behavior:**

- All-or-nothing per batch
- One failure = no PR created
- Prevents partial archives

## Similar Patterns

This follows the same pattern as:

- **Changesets bot** — Auto-merge version PRs ([`.github/workflows/changesets.yml`](../../../.github/workflows/changesets.yml))
- **Health badge** — Auto-update and merge badge PRs
- **Auto-merge dispatch** — Trigger auto-merge on changesets PRs

## Benefits

- **Zero manual steps** after project completion
- **Consistent archival** (no forgotten cleanup)
- **Link integrity** (auto-fix prevents 404s)
- **Batch efficiency** (multiple projects in one PR)
- **Audit trail** (PR description documents all changes)

## Related

- **ERD**: [`erd.md`](./erd.md) — Full requirements
- **Tasks**: [`tasks.md`](./tasks.md) — Implementation tracking
- **Similar**: [`.github/workflows/changesets.yml`](../../../.github/workflows/changesets.yml) — Auto-merge pattern
