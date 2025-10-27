---
project: orphaned-files
status: ACTIVE
created: 2025-10-25
owner: Repository Maintenance
mode: full
---

# Engineering Requirements Document: Orphaned Files Detection

Mode: Lite


**Project**: orphaned-files  
**Status**: ACTIVE  
**Created**: 2025-10-25  
**Owner**: Repository Maintenance

---

## 1. Problem Statement

The repository accumulates files that are no longer referenced or useful:

- **Unreferenced files**: Documents, scripts, and artifacts not linked by any other file
- **Obsolete patterns**: Files following deprecated conventions (e.g., old investigation structure before `investigation-structure.mdc`)
- **Abandoned experiments**: Test files, temporary docs, or prototypes left behind
- **Manual burden**: No automated way to detect or clean up these files

**Example**: `slash-commands-runtime-routing/` (visible in synthesis.md:572) marked as "not viable" but still present in repository.

**Why now**: Recent investigations (rules-enforcement-investigation, project-lifecycle) revealed orphaned files. Proactive cleanup prevents future confusion and reduces repository noise.

## 2. Goals

### Primary

- Detect files with zero incoming references (no other file links to them)
- Identify files using obsolete patterns (e.g., pre-`investigation-structure.mdc` layouts)
- Provide safe deletion recommendations with full context
- Create script to automate detection and optional deletion

### Secondary

- Detect partially orphaned projects (only referenced from archived projects)
- Flag files that may need archival instead of deletion
- Suggest refactoring for files with marginal utility

## 3. Current State

**Manual detection**:

- Ad-hoc grep searches for file references
- Visual inspection of `docs/projects/`
- No systematic approach

**Known orphans** (from recent investigation):

- `slash-commands-runtime-routing/` — Documented as "not viable" but not deleted
- Potentially other projects marked complete but not archived

**Reference patterns** (used to detect orphans):

- Relative paths: `docs/projects/<slug>/`, `../../<slug>/`
- Script references: `.cursor/scripts/<name>.sh`
- Rule references: `.cursor/rules/<name>.mdc`

## 4. Proposed Solutions

### Option A: Static Analysis Script (Recommended)

**Approach**:

1. Scan repository for all trackable files (`.md`, `.sh`, `.mdc`, etc.)
2. Build reference graph (which files reference which)
3. Identify nodes with zero incoming edges
4. Filter false positives (entry points, intentional standalone files)
5. Output report with deletion recommendations

**Pros**:

- Fast, deterministic
- Can run in CI as quality gate
- Safe dry-run mode
- Handles relative path variations

**Cons**:

- May miss dynamic references (constructed paths, URLs)
- Requires maintenance as repo conventions evolve

**Implementation**:

```bash
.cursor/scripts/orphaned-files-detect.sh
  --scan-dir docs/projects/
  --scan-dir .cursor/scripts/
  --scan-dir .cursor/rules/
  --exclude-pattern '_archived/**'
  --report orphaned-files-report.json
  --dry-run
```

### Option B: Git-Based Analysis

**Approach**:

1. Use `git log --all -- <file>` to check last modification date
2. Combine with reference counting from Option A
3. Flag files not modified in >6 months with zero references

**Pros**:

- Temporal signal (old + unreferenced = likely orphan)
- Reduces false positives from recent experiments

**Cons**:

- Slower (git log per file)
- Age alone doesn't mean orphaned
- Doesn't help with obsolete pattern detection

### Option C: Hybrid (Option A + Age Filter)

**Approach**:

- Start with Option A (reference graph)
- Add age filter as secondary signal
- Prioritize deletion candidates by: zero refs + old + deprecated pattern

**Pros**:

- Best signal-to-noise ratio
- Can suggest archival for old-but-referenced files

**Cons**:

- More complex script
- Requires pattern definitions for "obsolete"

**Recommendation**: Start with **Option A** (pure reference graph). Add age/pattern filters in Phase 2 if needed.

## 5. Success Criteria

### Must Have

- [ ] Script detects files with zero incoming references
- [ ] Script handles relative path variations (`../../`, `./`, absolute)
- [ ] Dry-run mode (report only, no deletion)
- [ ] Interactive deletion mode (confirm before each delete)
- [ ] JSON report output for CI integration

### Should Have

- [ ] Detect obsolete pattern usage (e.g., pre-investigation-structure.mdc layouts)
- [ ] Suggest archival for complete-but-unreferenced projects
- [ ] Whitelist for intentional standalone files (README.md, entry points)

### Nice to Have

- [ ] Age-based prioritization (old + unreferenced = higher priority)
- [ ] Visualize reference graph (which files reference which)
- [ ] CI integration (fail on new orphans introduced)

## 6. Non-Goals

- Deleting files automatically without human review
- Tracking non-text files (images, binaries) in Phase 1
- Detecting semantic obsolescence ("this doc is outdated but still referenced")
- Recovering accidentally deleted files (use `git` for that)

## 7. Dependencies & Constraints

**Dependencies**:

- Bash 4+ (associative arrays for graph building)
- Standard Unix tools: `find`, `grep`, `sed`
- Repository structure conventions (relative paths, markdown links)

**Constraints**:

- Must preserve intentional standalone files (entry points like `README.md`)
- Must not delete files with dynamic references (risk: constructed paths in scripts)
- Should run fast enough for CI (<30s for full repo scan)

## 8. Implementation Notes

### Reference Patterns to Detect

**Markdown links**:

```regex
\[([^\]]+)\]\(([^)]+)\)
```

**Script invocations** (in shell or markdown):

```regex
\.cursor/scripts/[a-z0-9\-]+\.sh
bash \.cursor/scripts/[a-z0-9\-]+\.sh
```

**Rule references** (in markdown or rules):

```regex
\.cursor/rules/[a-z0-9\-]+\.mdc
@[a-z0-9\-]+  # Rule references in chat
```

**Project directory references**:

```regex
docs/projects/[a-z0-9\-]+/
```

### False Positives to Handle

- **Entry points**: `README.md`, `docs/projects/README.md` (intentional roots)
- **Generated files**: May not have explicit references (e.g., `CHANGELOG.md`)
- **External references**: Links from outside the repository (documentation sites, etc.)
- **Implicit references**: Files loaded by convention (e.g., `package.json` doesn't need links)

### Whitelist Strategy

Create `.orphaned-files-whitelist.txt`:

```
README.md
docs/projects/README.md
CHANGELOG.md
VERSION
.cursor/rules/capabilities.mdc  # Queried by @capabilities, not linked
```

## 9. Open Questions

1. **How to handle partial orphans?**  
   Files referenced only by archived projects — delete or keep?  
   **Decision**: Flag separately; suggest archival if the file's project is complete.

2. **Dynamic references?**  
   Scripts that construct paths (`PROJECT_DIR=docs/projects/$SLUG`) won't show up in static analysis.  
   **Mitigation**: Whitelist known dynamic patterns; manual review for edge cases.

3. **CI integration threshold?**  
   Fail on any new orphan, or allow N orphans?  
   **Decision**: Phase 2 concern; start with reporting only.

## 10. Timeline

**Phase 1: Detection Script** — 3 hours

- Build reference graph from markdown links
- Identify zero-reference files
- Output JSON report
- Dry-run mode

**Phase 2: Safe Deletion** — 2 hours

- Interactive deletion mode
- Whitelist support
- Obsolete pattern detection (pre-investigation-structure.mdc)

**Phase 3: CI Integration** — 2 hours

- Add to CI workflow
- Fail on new orphans (configurable threshold)
- Archive suggestions for complete projects

**Total**: ~7 hours

## 11. Related Work

- [project-lifecycle.mdc](../../../.cursor/rules/project-lifecycle.mdc) — Completion and archival policies
- [investigation-structure.mdc](../../../.cursor/rules/investigation-structure.mdc) — Expected file organization (useful for detecting obsolete patterns)
- [document-governance](../document-governance/) — Document lifecycle and retirement
- [rules-enforcement-investigation](../rules-enforcement-investigation/) — Context for why this project is needed (orphan discovery)

## 12. Validation

**How to verify the script works**:

1. **Positive test** (detect known orphan):

   - Create `docs/projects/test-orphan/README.md` (don't reference it anywhere)
   - Run script → should detect `test-orphan/` as orphaned
   - Delete test file

2. **Negative test** (don't flag referenced files):

   - Verify `docs/projects/orphaned-files/erd.md` (this file) is NOT flagged
   - Reason: This ERD is linked from `README.md`

3. **Whitelist test**:

   - Add entry point (e.g., `docs/projects/README.md`) to whitelist
   - Run script → should not flag it despite being a natural entry point

4. **False positive check**:
   - Manually review first 10 detections
   - Confirm they are truly orphaned (no hidden references)

## 13. Risk Assessment

**Low Risk**:

- Detection itself is read-only
- Dry-run mode prevents accidental deletion

**Medium Risk**:

- Dynamic references (constructed paths) may cause false positives
- Mitigation: Whitelist + manual review before deletion

**High Risk**:

- Deleting files that are externally referenced (e.g., from Confluence, Jira, or other repos)
- Mitigation: Interactive mode; require explicit confirmation per file
