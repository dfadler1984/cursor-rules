## Tasks — Orphaned Files Detection

**Status**: ACTIVE | Phase: 1 | 0% Complete

---

## Phase 1: Detection Script (3 hours)

**Goal**: Build reference graph and detect zero-reference files

- [ ] 1.0 Script foundation

  - [ ] 1.1 Create `.cursor/scripts/orphaned-files-detect.sh`
  - [ ] 1.2 Add CLI flags: `--scan-dir`, `--dry-run`, `--report`, `--output`
  - [ ] 1.3 Add help text and usage examples
  - [ ] 1.4 Validate script executability and shebang

- [ ] 1.5 Reference graph builder

  - [ ] 1.6 Scan target directories for trackable files (`.md`, `.sh`, `.mdc`)
  - [ ] 1.7 Extract markdown links: `[text](path)`
  - [ ] 1.8 Extract script references: `.cursor/scripts/<name>.sh`
  - [ ] 1.9 Extract rule references: `.cursor/rules/<name>.mdc`, `@<rule-name>`
  - [ ] 1.10 Normalize paths (resolve `../../`, `./`, handle absolute paths)
  - [ ] 1.11 Build adjacency list: file → [files it references]
  - [ ] 1.12 Compute reverse map: file → [files that reference it]

- [ ] 1.13 Orphan detection

  - [ ] 1.14 Identify files with zero incoming references
  - [ ] 1.15 Filter out whitelisted files (entry points, generated files)
  - [ ] 1.16 Output list of orphan candidates

- [ ] 1.17 JSON report

  - [ ] 1.18 Format: `{ "orphans": [{ "path": "...", "type": "...", "size": ... }], "stats": {...} }`
  - [ ] 1.19 Include file type, size, last modified date
  - [ ] 1.20 Include total count and breakdown by type

- [ ] 1.21 Dry-run validation
  - [ ] 1.22 Run script with `--dry-run` on full repository
  - [ ] 1.23 Manually review first 10 detections for false positives
  - [ ] 1.24 Verify known orphan (`slash-commands-runtime-routing/`) is detected

---

## Phase 2: Safe Deletion (2 hours)

**Goal**: Interactive deletion with whitelist support

- [ ] 2.0 Whitelist support

  - [ ] 2.1 Create `.orphaned-files-whitelist.txt` (or use config in script)
  - [ ] 2.2 Add default whitelist: `README.md`, `CHANGELOG.md`, `VERSION`, entry points
  - [ ] 2.3 Read whitelist from file or CLI flag
  - [ ] 2.4 Filter orphans against whitelist before reporting

- [ ] 2.5 Interactive deletion mode

  - [ ] 2.6 Add `--delete` flag with confirmation prompt
  - [ ] 2.7 Add `--interactive` flag (confirm each file before delete)
  - [ ] 2.8 Add `--batch` flag (delete all without prompts, requires explicit confirmation)
  - [ ] 2.9 Show file preview before deletion (first 10 lines or summary)
  - [ ] 2.10 Implement deletion with safety checks (backup or git status check)

- [ ] 2.11 Obsolete pattern detection

  - [ ] 2.12 Define patterns for obsolete structure (e.g., pre-`investigation-structure.mdc`)
  - [ ] 2.13 Flag files using old conventions (e.g., root-level session summaries)
  - [ ] 2.14 Suggest reorganization instead of deletion for fixable patterns

- [ ] 2.15 Archival suggestions
  - [ ] 2.16 Detect complete-but-unreferenced projects (check `tasks.md` completion %)
  - [ ] 2.17 Suggest running archival workflow instead of deletion
  - [ ] 2.18 Output archival commands for candidate projects

---

## Phase 3: CI Integration (2 hours)

**Goal**: Automate detection in CI and prevent new orphans

- [ ] 3.0 CI workflow

  - [ ] 3.1 Create `.github/workflows/orphaned-files-check.yml`
  - [ ] 3.2 Run script on every PR
  - [ ] 3.3 Fail if new orphans introduced (compare against baseline)
  - [ ] 3.4 Upload report as artifact

- [ ] 3.5 Baseline management

  - [ ] 3.6 Generate initial baseline: `orphaned-files-baseline.json`
  - [ ] 3.7 Store baseline in repository (or as GitHub Actions cache)
  - [ ] 3.8 Update baseline manually after approved deletions

- [ ] 3.9 Reporting enhancements

  - [ ] 3.10 Add `--format` flag: `json|text|markdown|github-comment`
  - [ ] 3.11 Generate markdown summary for PR comments
  - [ ] 3.12 Include diff: new orphans vs baseline

- [ ] 3.13 Configuration
  - [ ] 3.14 Add `.orphaned-files.config.json` for scan dirs, whitelist, thresholds
  - [ ] 3.15 Allow override via CLI flags
  - [ ] 3.16 Document configuration options in script help

---

## Validation Checklist

- [ ] Positive test: Detect intentionally created orphan file
- [ ] Negative test: Do not flag this project (`orphaned-files/erd.md` is referenced)
- [ ] Whitelist test: Entry points (e.g., `docs/projects/README.md`) excluded
- [ ] False positive check: Manual review of first 10 detections
- [ ] Performance test: Full repo scan completes in <30s
- [ ] Dry-run safety: No files deleted in `--dry-run` mode
- [ ] Interactive mode: Confirmation prompts work correctly
- [ ] Batch mode: Explicit confirmation required before mass deletion

---

## Relevant Files

- **Script**: `.cursor/scripts/orphaned-files-detect.sh` (to be created)
- **Config**: `.orphaned-files-whitelist.txt` (to be created)
- **Test data**: Create `docs/projects/test-orphan/` for positive test (delete after)
- **CI workflow**: `.github/workflows/orphaned-files-check.yml` (Phase 3)

---

## Carryovers

_(Items moved from tasks when project scope changes or deferred)_

---

## Completion Criteria

Project is complete when:

1. Script detects orphaned files with high accuracy (low false positive rate)
2. Interactive deletion mode allows safe cleanup
3. CI integration prevents new orphans from accumulating
4. Documentation is updated with usage examples
5. Validation tests pass (positive, negative, whitelist, false positive check)

**How to mark complete**:

```bash
# Validate project lifecycle
bash .cursor/scripts/project-lifecycle-validate-scoped.sh orphaned-files

# Generate final summary
bash .cursor/scripts/final-summary-generate.sh --project orphaned-files --year 2025

# Mark project as COMPLETE in erd.md front matter
```
