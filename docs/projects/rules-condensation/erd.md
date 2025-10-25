---
project: rules-condensation
status: ACTIVE
created: 2025-10-25
owner: dfadler1984
---

# Engineering Requirements Document: Rules Condensation

Mode: Full

**Project**: rules-condensation  
**Status**: ACTIVE  
**Created**: 2025-10-25  
**Owner**: dfadler1984

---

## 1. Problem Statement

The current rule set (`.cursor/rules/*.mdc`) contains significant redundancy and verbosity:

- **Cross-rule duplication**: Consent gate guidance appears in 5+ rules
- **Internal verbosity**: Some rules are 3-4x longer than necessary
- **Overlapping scopes**: Testing guidance split across 5 separate files
- **Context overhead**: Large rule attachments slow assistant response time
- **Maintenance burden**: Updates require changes across multiple files

**Evidence from rules-enforcement-investigation**:

- consent-gates guidance duplicated across `assistant-behavior`, `intent-routing`, `user-intent`
- TDD guidance repeated in `testing`, `tdd-first`, multiple `.caps` files
- Git workflows spread across `assistant-git-usage`, `git-slash-commands`, `github-api-usage.caps`

**Why now**: Context efficiency issues and maintenance complexity are creating operational friction.

## 2. Goals

### Primary

- **Reduce verbosity**: Cut total word count across all rules by 30-40% without losing guidance
- **Eliminate duplication**: Single source of truth for each concept (link instead of repeat)
- **Consolidate overlaps**: Merge rules with >60% content overlap
- **Maintain functionality**: Zero loss of current guidance (all accessible after refactor)

### Secondary

- **Improve navigation**: Clear rule boundaries and cross-references
- **Reduce context load**: Smaller rule attachments for faster assistant responses
- **Simplify maintenance**: Fewer update touchpoints per concept

## 3. Current State

**Total rules**: ~45 files in `.cursor/rules/`  
**Estimated total words**: ~50,000 words  
**Known redundancies**:

- Consent gates: 5+ rules with overlapping guidance
- Testing: 5 files (testing, tdd-first, test-quality, test-quality-js, test-quality-sh)
- Git: 3+ files with workflow guidance
- Project lifecycle: 3 files with overlapping task/ERD guidance

**Validation**: `rules-validate.sh` passes, but no tooling for detecting duplication

## 4. Proposed Solutions

### Option A: Aggressive Consolidation (Recommended)

**Approach**:

1. **Merge heavily overlapping rules** (>60% content overlap)
2. **Extract shared content to "core" rules**, link from specializations
3. **Convert verbose sections to tables/checklists**
4. **Replace examples with citations to real code**

**Example**:

- Merge `testing.mdc`, `tdd-first.mdc` → `testing.mdc` (with TDD section)
- Extract consent gates to `consent-gates.mdc` ← linked from `assistant-behavior`, `intent-routing`
- Consolidate `test-quality-{js,sh}.mdc` → single `test-quality.mdc` with language sections

**Pros**:

- Maximum word count reduction (30-40%)
- Clear single source of truth
- Fewer files to maintain

**Cons**:

- Larger per-file refactor effort
- Risk of breaking existing attachments if not careful

### Option B: Conservative Deduplication

**Approach**:

1. **Identify duplicated sections** across rules
2. **Replace duplicates with cross-references** (links)
3. **Trim verbose explanations** within each rule
4. **Keep current file structure** intact

**Pros**:

- Lower refactor risk
- Preserves existing attachment patterns

**Cons**:

- Smaller word count reduction (~20%)
- Still maintains multiple files per domain

### Option C: Hybrid Approach

**Approach**:

1. **Aggressive consolidation** for high-overlap areas (consent, testing, git)
2. **Conservative deduplication** for lower-overlap areas (code style, platform docs)
3. **Incremental rollout** by domain

**Pros**:

- Balances effort vs impact
- Lower risk through phased approach

**Cons**:

- Longer timeline
- Mixed refactor patterns

## 5. Success Criteria

### Must Have

- [ ] Total word count reduced by ≥30% (from ~50K to ~35K words)
- [ ] Zero functionality loss (all current guidance accessible via links or merged content)
- [ ] All existing `rules-validate.sh` checks pass
- [ ] Validation suite confirms no broken cross-references

### Should Have

- [ ] Total rule count reduced by 10-15% (from ~45 to ~38-40 files)
- [ ] Context efficiency scores improve (measured via `context-efficiency-score.sh`)
- [ ] Update touchpoints per concept reduced by ≥50%

### Nice to Have

- [ ] Automated duplication detection tooling
- [ ] Pre-commit hook to warn on rule verbosity
- [ ] Rule dependency graph visualization

## 6. Non-Goals

- **Not rewriting rule semantics**: Keep current guidance, just condense delivery
- **Not changing attachment mechanisms**: Rules can still be attached via globs/triggers
- **Not refactoring scripts**: Focus on `.mdc` files only (scripts are separate project)

## 7. Dependencies & Constraints

**Dependencies**:

- `rules-validate.sh` — Must pass after all changes
- `rules-attach-validate.sh` — Verify attachment patterns still work
- Existing projects — Must not break in-flight work referencing rules

**Constraints**:

- Must maintain backward compatibility for rule attachments
- Cannot break existing cross-references without updating links
- Must preserve all current guidance (zero information loss)

## 8. Recommended Approach

**Option A (Aggressive Consolidation)** with phased rollout:

**Phase 1**: High-overlap domains (consent, testing, git)  
**Phase 2**: Medium-overlap domains (project lifecycle, rule maintenance)  
**Phase 3**: Low-overlap domains (code style, platform docs)

**Rationale**: Maximum impact in Phase 1 (where duplication is highest), lower risk through incremental deployment.

## 9. Open Questions

1. **Attachment patterns**: Will merging rules break existing glob patterns in other projects?
2. **Capability files**: Should `.caps.mdc` files be merged into main rules or kept separate for lightweight attachment?
3. **Validation**: What additional validation tooling is needed to prevent future duplication?
4. **Rollout**: Should we branch per-phase or do all changes on single branch?

## 10. Timeline

**Phase 1**: 8-12 hours — Consent gates, testing, git (high-overlap areas)  
**Phase 2**: 6-8 hours — Project lifecycle, rule maintenance (medium-overlap)  
**Phase 3**: 4-6 hours — Code style, platform docs (low-overlap)  
**Validation**: 2-4 hours — Cross-reference checks, attachment validation, context efficiency measurement

**Total**: 20-30 hours (depending on approach)

## 11. Related Work

- [rules-enforcement-investigation](../rules-enforcement-investigation/) — Evidence of duplication and overlap
- [context-efficiency](../../.cursor/rules/context-efficiency.mdc) — Measurement framework for success criteria
- [rule-maintenance.mdc](../../.cursor/rules/rule-maintenance.mdc) — Existing maintenance guidance to be consolidated
