# Decision Documents

This directory contains decision documents for key architectural and design choices in the Root README Generator project.

## Purpose

Document the reasoning behind major decisions to:

- Provide context for future maintainers
- Make trade-offs explicit
- Enable informed changes when requirements evolve

## Decision Process

Each decision document should include:

1. **Context**: What prompted this decision?
2. **Options Considered**: What alternatives were evaluated?
3. **Decision**: What was chosen?
4. **Rationale**: Why this option over others?
5. **Consequences**: What are the implications (positive and negative)?
6. **Status**: Proposed, Accepted, Deprecated, Superseded

## High Priority Decisions (Phase 0)

These decisions **block implementation** and must be resolved first:

1. **Generation Strategy** (`generation-strategy.md`)

   - Options: Full replacement, partial update, hybrid
   - Criteria: Manual edit frequency, risk tolerance, complexity
   - Status: TBD

2. **Scripts Detail Level** (`scripts-detail-level.md`)

   - Options: Full inventory, top 10, link-only
   - Criteria: README length constraint, contributor needs
   - Status: TBD

3. **Section Ownership** (`section-ownership.md`)

   - Options: Which sections auto vs manual
   - Criteria: Editorial value, change frequency
   - Status: TBD

4. **Template Structure** (`template-structure.md`)

   - Options: Single template, modular fragments
   - Criteria: Complexity budget, testability
   - Status: TBD

5. **Update Trigger** (`update-trigger.md`)
   - Options: CI auto-commit, manual script, pre-commit hook
   - Criteria: Git noise tolerance, freshness requirements
   - Status: TBD

## Medium Priority Decisions (Phase 1-2)

These refine the design but don't block initial implementation:

- Categorization source (manual mapping vs header extraction)
- Quick links selection criteria
- "What's New" content source
- Staleness tolerance level
- Version display strategy

## Template

Use this template for new decision documents:

```markdown
# Decision: [Title]

**Status**: [Proposed | Accepted | Deprecated | Superseded]  
**Date**: YYYY-MM-DD  
**Deciders**: [Names or roles]  
**Related**: [Links to other decisions or issues]

## Context

[What is the situation/problem requiring a decision?]

## Options Considered

### Option A: [Name]

**Description**: [What is this approach?]

**Pros**:

- [Advantage 1]
- [Advantage 2]

**Cons**:

- [Disadvantage 1]
- [Disadvantage 2]

### Option B: [Name]

[Same structure as Option A]

## Decision

[What option was chosen?]

## Rationale

[Why was this option selected over others? What were the deciding factors?]

## Consequences

**Positive**:

- [Benefit 1]
- [Benefit 2]

**Negative**:

- [Trade-off 1]
- [Trade-off 2]

**Neutral**:

- [Implication 1]

## Implementation Notes

[Any specific guidance for implementing this decision]

## Review Date

[Optional: When should this decision be revisited?]
```

## Related

- **ERD**: [`../erd.md`](../erd.md) — Full requirements with open questions
- **Tasks**: [`../tasks.md`](../tasks.md) — Task breakdown (Phase 0 focuses on decisions)
