---
status: active
owner: repo-maintainers
lastUpdated: 2025-10-21
phase: planning
---

# Engineering Requirements Document: Rules & Documentation Quality Detection

Mode: Full

## 1. Problem Statement

Currently, quality issues across `.cursor/rules/` and `docs/` must be detected manually:

- **Duplication**: Same guidance appears in multiple files, creating maintenance burden and drift risk
- **Conflicts**: Contradictory guidance exists across rules/docs, confusing users and assistants
- **Staleness**: References to moved/deleted files, outdated examples, old dates go unnoticed

These issues accumulate over time, degrading documentation quality and increasing cognitive load. Manual review is time-consuming and error-prone.

## 2. Goals

### Primary

- Detect duplicate content blocks across rules and documentation (≥3 lines identical or semantically similar)
- Identify conflicting guidance patterns (contradictions between files)
- Flag outdated references (broken links, stale dates, deprecated patterns)
- Provide actionable reports for remediation
- Run in CI and locally with exit codes for gates

### Secondary

- Suggest consolidation opportunities (merge similar rules)
- Track quality metrics over time (trend analysis)
- Integrate with existing `rules-validate.sh` workflow

## 3. Current State

**Existing validation** (`rules-validate.sh`):

- Front matter validation (required fields)
- Cross-reference validation (broken links)
- Stale date detection (`lastReviewed` > 90 days)
- Format validation (YAML parsing)

**Gaps**:

- No duplicate content detection
- No conflict detection (contradictions)
- No semantic similarity analysis
- Limited to `.cursor/rules/` (doesn't scan `docs/`)

**Baseline metrics** (as of 2025-10-21):

- Rules: ~50 files in `.cursor/rules/`
- Docs: ~200+ markdown files in `docs/`
- Existing validator: 366 lines, covers structure only

## 4. Proposed Solutions

### Option A: Extend rules-validate.sh (Incremental)

**Approach**: Add duplicate/conflict detection to existing script

**Pros**:

- Familiar workflow (same script developers already use)
- Reuses existing infrastructure (front matter parsing, reference checking)
- Lower learning curve

**Cons**:

- Script getting large (366 lines → 600+ lines)
- Shell scripting limits sophisticated text analysis
- Harder to add advanced features (semantic similarity)

**Implementation**:

- Add `--check-duplicates` flag
- Add `--check-conflicts` flag
- Simple line-based comparison (MD5 hashing of content blocks)
- Pattern-based conflict detection (hardcoded contradiction patterns)

### Option B: New Standalone Validation Suite (Modular)

**Approach**: Create separate scripts following Unix philosophy

**Pros**:

- Single responsibility per script
- Easier to test and maintain
- Can compose tools (`rules-validate.sh | rules-duplicates.sh | rules-conflicts.sh`)
- Follows `shell-unix-philosophy.mdc` guidelines

**Cons**:

- More files to maintain
- Need coordination script or Makefile
- Users must run multiple commands

**Implementation**:

- `rules-duplicates.sh` — Detect duplicate content blocks
- `rules-conflicts.sh` — Detect contradictory guidance
- `rules-references.sh` — Extend reference validation to docs
- Wrapper script for convenience: `rules-quality-check.sh --all`

### Option C: Purpose-Built Tool (Node/TypeScript)

**Approach**: Build dedicated tool with advanced analysis

**Pros**:

- Access to NLP libraries (semantic similarity)
- Better text processing (tokenization, stemming)
- Can output structured data (JSON)
- Faster for large file sets

**Cons**:

- Adds Node.js dependency
- Higher complexity
- More maintenance overhead
- Longer development time

**Implementation**:

- Use existing repo tooling (`@changesets/cli` already requires Node)
- Libraries: `unified`, `remark`, `cosine-similarity`
- CLI: `src/quality-detector/index.ts`

### Recommended: Option B (Modular Suite)

**Rationale**:

- Aligns with `shell-unix-philosophy.mdc` (single responsibility, composable)
- Incremental delivery (can ship duplicate detection first)
- Testable via existing shell test harness
- No new dependencies
- Easy to integrate into CI

**Fallback to Option C if**:

- Semantic similarity becomes requirement (not just text matching)
- Performance becomes bottleneck (>1000 files)
- JSON output strongly preferred by consumers

## 5. Success Criteria

### Must Have

- [ ] Detects exact duplicate content blocks (≥3 consecutive lines)
- [ ] Reports line numbers and file paths for duplicates
- [ ] Flags broken cross-references in `docs/` (extend existing validator)
- [ ] Runs in <5 seconds for current repo size (~250 files)
- [ ] Exit code 0 (pass) or 1 (issues found) for CI integration
- [ ] `--format text|json` output options

### Should Have

- [ ] Detects near-duplicate content (≥80% similarity over 5+ lines)
- [ ] Identifies contradictory guidance patterns (common contradictions list)
- [ ] Suggests consolidation opportunities (files with >50% overlap)
- [ ] Reports stale content beyond `lastReviewed` (unreferenced files >180 days)

### Nice to Have

- [ ] Semantic similarity analysis (cosine similarity on embeddings)
- [ ] Quality score per file (composite metric)
- [ ] Trend tracking (quality over time)
- [ ] Auto-fix mode (merge duplicates interactively)

## 6. Non-Goals

- **Not replacing existing validator**: Extends, does not replace `rules-validate.sh`
- **Not linting prose**: This is about guidance duplication/conflicts, not grammar/style
- **Not enforcing opinions**: Detects issues, doesn't auto-merge or delete content
- **Not version control integration**: Focuses on current state, not diff analysis (future enhancement)

## 7. Dependencies & Constraints

**Dependencies**:

- Existing `rules-validate.sh` (reference for patterns)
- Shell test harness (`.cursor/scripts/tests/run.sh`)
- Markdown files in `.cursor/rules/` and `docs/`

**Constraints**:

- Must run on macOS and Linux (repo CI)
- Must not require additional package installs (shell/standard tools only)
- Must respect `.gitignore` (don't scan `node_modules/`, `dist/`)
- Performance: <10 seconds for 500 files (2x growth headroom)

**Assumptions**:

- Duplicate detection: exact line matching is sufficient for MVP
- Conflict detection: pattern-based (e.g., "always X" vs "never X" in different files)
- Users run locally before commit (pre-commit hook candidate)

## 8. Open Questions

1. **Threshold for "duplicate"**: 3 lines? 5 lines? Configurable?

   - **Proposed**: Start with 3 lines, make configurable via flag `--min-lines N`

2. **Scope**: Rules only, or rules + docs?

   - **Proposed**: Phase 1 rules only, Phase 2 add `docs/` (scoped to project docs first)

3. **Conflict patterns**: Hardcode common ones or allow custom list?

   - **Proposed**: Hardcode top 5-10 patterns, allow `--patterns-file` for custom

4. **Output format**: Text only, or JSON for tooling?

   - **Proposed**: Both (`--format text|json`), default text for human readability

5. **Integration point**: Pre-commit hook or CI only?

   - **Proposed**: CI mandatory, pre-commit hook optional (document in README)

6. **Whitespace handling**: Ignore whitespace diffs or exact match?
   - **Proposed**: Normalize whitespace (trim, collapse multiple spaces) before comparison

## 9. Timeline

**Phase 1: Duplicate Detection** (~4 hours)

- Script: `rules-duplicates.sh` with exact line matching
- Tests: Shell test suite with fixtures
- Documentation: Usage examples in script header
- Integration: CI workflow step

**Phase 2: Conflict Detection** (~3 hours)

- Script: `rules-conflicts.sh` with pattern matching
- Patterns: Top 10 common contradictions (hardcoded)
- Tests: Fixtures with known conflicts
- Documentation: Pattern list in script

**Phase 3: Extended Reference Validation** (~2 hours)

- Extend `rules-validate.sh` or new `rules-references.sh`
- Scan `docs/projects/*/` for broken links
- Flag unreferenced files (stale content)
- Tests: Broken link fixtures

**Phase 4: Integration & Docs** (~1 hour)

- Wrapper script: `rules-quality-check.sh --all`
- CI integration: Add to workflows
- Documentation: Update `docs/scripts/README.md`
- Pre-commit hook example

**Total Estimate**: ~10 hours

**Checkpoints**:

- Phase 1 complete: Can detect duplicates, CI failing on issues
- Phase 2 complete: Can detect conflicts, patterns documented
- Phase 3 complete: Reference validation covers docs/
- Phase 4 complete: Integrated into workflow, documented

## 10. Related Work

**Existing tooling**:

- [rules-validate.sh](../../../.cursor/scripts/rules-validate.sh) — Front matter and reference validation
- [rules-list.sh](../../../.cursor/scripts/rules-list.sh) — Rule inventory
- [links-check.sh](../../../.cursor/scripts/links-check.sh) — Broken link detection (may be reusable)

**Related projects**:

- [rules-enforcement-investigation](../rules-enforcement-investigation/) — Rule compliance testing
- [assistant-self-improvement](../assistant-self-improvement/) — Rule improvement workflow

**Related rules**:

- [rule-maintenance.mdc](../../../.cursor/rules/rule-maintenance.mdc) — Maintenance cadence
- [rule-quality.mdc](../../../.cursor/rules/rule-quality.mdc) — Quality standards
- [shell-unix-philosophy.mdc](../../../.cursor/rules/shell-unix-philosophy.mdc) — Script design principles

**References**:

- Duplicate detection: `comm`, `diff`, MD5 hashing for fingerprinting
- Conflict detection: Pattern matching via `grep -E` with contradiction patterns
- Text similarity: Jaccard index for near-duplicates (if needed in Phase 2+)
