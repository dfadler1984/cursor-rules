# Engineering Requirements Document: Portability Taxonomy

**Project**: portability  
**Status**: ACTIVE  
**Created**: 2025-10-23  
**Owner**: cursor-rules

---

## 1. Problem Statement

The cursor-rules repository contains a mix of portable (general-purpose, reusable) and project-specific (cursor-rules-specific) rules, scripts, and commands. There is currently no clear taxonomy or organizational system to distinguish between these categories, making it difficult to:

- Identify which artifacts can be reused in other projects
- Maintain portable vs project-specific code separately
- Extract a reusable toolkit for external use
- Document portability intent for future contributors

## 2. Goals

### Primary

- Define clear taxonomy for portable vs project-specific artifacts
- Establish organizational system to mark portability status
- Enable filtering/querying by portability category
- Document portability assumptions and requirements

### Secondary

- Enable future extraction of portable toolkit
- Improve onboarding clarity (what applies where)
- Reduce maintenance confusion

## 3. Current State

- No formal portability classification
- ~50+ rules in `.cursor/rules/` (mix of portable and project-specific)
- ~40+ scripts in `.cursor/scripts/` (mix of portable and project-specific)
- Some artifacts are hybrid (portable pattern, project-specific implementation)
- No metadata or organizational signal for portability

## 4. Proposed Solutions

### Option A: Metadata Tags (Recommended)

**Approach**: Add `portability` field to front matter for rules/scripts

```yaml
---
portability: portable | project-specific | hybrid
portabilityNotes: "Optional explanation of assumptions/requirements"
---
```

**Pros**:

- Minimal disruption (no file moves)
- Clear documentation at source
- Queryable via scripts
- Gradual adoption possible

**Cons**:

- Requires metadata discipline
- No physical separation

**Implementation**:

1. Define front-matter schema extension
2. Update validation scripts
3. Backfill existing artifacts
4. Add filtering to listing tools

### Option B: Folder Separation

**Approach**: Physical split into `.cursor/portable/` and `.cursor/project/`

**Pros**:

- Physical clarity
- Natural publishing boundary

**Cons**:

- High disruption (100+ file moves)
- Breaks existing references
- Complex migration

### Option C: Hybrid (Metadata + Namespace)

**Approach**: Metadata + naming convention (`@portable/`, `@project/`)

**Pros**:

- Filename-level clarity
- Metadata backup

**Cons**:

- Namespace pollution
- Medium renaming disruption

## 5. Success Criteria

### Must Have

- [ ] Clear taxonomy definition (portable/project-specific/hybrid)
- [ ] Organizational system implemented
- [ ] 10+ core portable rules marked
- [ ] Documentation of portability assumptions
- [ ] Validation tooling updated

### Should Have

- [ ] All rules categorized
- [ ] All scripts categorized
- [ ] Filtering/querying capability
- [ ] Migration guide for future extraction

### Nice to Have

- [ ] Automated portability checks
- [ ] Extraction tooling for portable subset
- [ ] Published portable toolkit (npm/repo)

## 6. Non-Goals

- Immediate extraction into separate repo/package
- Complete restructuring of `.cursor/` folder
- Retroactive portability guarantees for all code

## 7. Dependencies & Constraints

**Dependencies**:

- Front-matter validation scripts (`rules-validate.sh`)
- Rules listing tools (`rules-list.sh`)
- Documentation in `capabilities.mdc`

**Constraints**:

- Must not break existing rule attachment logic
- Must not break existing script paths
- Must be incrementally adoptable

## 8. Open Questions

1. Should hybrid artifacts be marked at package level or line level?
2. What's the threshold for "portable" (zero config vs parameterizable)?
3. Should portability metadata be required or optional initially?
4. How do we handle rules that reference project-specific examples but have portable patterns?

## 9. Timeline

**Phase 1**: Definition & Schema (2-3 hours)

- Define taxonomy
- Update front-matter schema
- Update validation scripts

**Phase 2**: Backfill Core Artifacts (3-4 hours)

- Mark 10-15 core portable rules
- Mark 5-10 portable scripts
- Document assumptions

**Phase 3**: Full Backfill (4-6 hours)

- Categorize remaining rules
- Categorize remaining scripts
- Add filtering to tools

**Total**: 9-13 hours

## 10. Related Work

- [rule-creation.mdc](../../.cursor/rules/rule-creation.mdc) — Rule authoring standards
- [front-matter.mdc](../../.cursor/rules/front-matter.mdc) — Front matter structure
- [capabilities.mdc](../../.cursor/rules/capabilities.mdc) — Capabilities listing
- [rules-validate.sh](../../.cursor/scripts/rules-validate.sh) — Validation tooling
