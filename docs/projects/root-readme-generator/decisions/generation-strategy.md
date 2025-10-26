# Decision: Generation Strategy

**Date**: 2025-10-26  
**Decider**: @dfadler1984  
**Status**: Decided

## Context

Need to choose between three generation approaches:

- **Option A**: Full replacement
- **Option B**: Partial update (section markers)
- **Option C**: Hybrid (template + manual fragments)

## Decision

**Full Replacement (Option A)** with template-based generation.

## Rationale

### Advantages

- Complete consistency — no drift between manual and auto sections
- Simpler implementation — single template, clear placeholders
- Predictable output — same input always produces same output
- Easier testing — compare generated vs expected output
- No marker maintenance overhead

### Trade-offs Accepted

- Manual edits will be lost on regeneration
- Less flexibility for one-off tweaks
- Requires template updates for structural changes

### Mitigation Strategy

- Template serves as "source of truth" for manual content
- Manual sections (like workflow philosophy) live in template
- Template is version-controlled and reviewable
- Changes to manual content = PR to update template

## Implementation Plan

1. Create single template file: `templates/root-readme.template.md`
2. Use simple placeholder syntax: `{{PLACEHOLDER_NAME}}`
3. Generator replaces all placeholders with generated content
4. Output written atomically (temp file → rename)

## Sections Strategy

Template will encode:

- Manual sections (conceptual content that changes rarely)
- Placeholder positions (where generated content goes)
- Section ordering (stable structure for external links)

See `section-ownership.md` for detailed section breakdown.

## Validation Approach

- `validate-root-readme.sh` compares generated output with committed README
- CI fails if they differ (staleness detection)
- Developer workflow: regenerate README after adding scripts/rules

## Related Decisions

- Section ownership: `section-ownership.md` (next)
- Template structure: Will be refined in Phase 1
- Update trigger: Deferred to Phase 0 (task 0.5)
