# Portability Taxonomy

**Status**: ACTIVE  
**Phase**: Definition  
**Completion**: ~0%

---

## Problem

The cursor-rules repository contains a mix of portable (general-purpose) and project-specific artifacts without a clear system to distinguish them. This makes it hard to:

- Identify reusable components
- Extract a portable toolkit
- Maintain separate concerns
- Onboard new contributors

## Solution

Implement a metadata-based taxonomy system:

1. **Define taxonomy**: portable | project-specific | hybrid
2. **Add front matter fields**: `portability` and `portabilityNotes`
3. **Backfill existing artifacts**: rules, scripts, commands
4. **Enable filtering**: update listing/validation tools

## Taxonomy

### Portable

Reusable in other projects with minimal assumptions. Works with configuration/parameters.

**Examples**: `tdd-first.mdc`, `git-commit.sh`, `code-style.mdc`

### Project-Specific

Tightly coupled to cursor-rules structure/workflows. Not directly reusable.

**Examples**: `project-lifecycle.mdc`, `rules-validate.sh`, `project-archive-workflow.sh`

### Hybrid

Portable pattern/approach, but current implementation has project-specific assumptions.

**Examples**: `capabilities.mdc` (pattern portable, content specific), `erd-validate.sh` (validation pattern portable, schema specific)

## Phases

**Phase 1: Definition & Schema** (2-3 hours)

- Define taxonomy criteria
- Update front-matter schema
- Update validation tooling

**Phase 2: Backfill Core Artifacts** (3-4 hours)

- Mark 10-15 core portable rules
- Mark 5-10 portable scripts
- Mark key project-specific artifacts

**Phase 3: Full Backfill & Tooling** (4-6 hours)

- Categorize remaining artifacts
- Add filtering to listing tools
- Document migration path

## Quick Links

- **ERD**: [erd.md](./erd.md) — Full requirements
- **Tasks**: [tasks.md](./tasks.md) — Execution checklist
- **Related Rules**:
  - [front-matter.mdc](../../.cursor/rules/front-matter.mdc)
  - [rule-creation.mdc](../../.cursor/rules/rule-creation.mdc)
  - [capabilities.mdc](../../.cursor/rules/capabilities.mdc)

## Decisions

- **Organization**: Metadata tags (Option A) over folder separation for minimal disruption
- **Schema**: Two fields: `portability` (required) and `portabilityNotes` (optional)
- **Adoption**: Incremental backfill starting with core portable rules

## Open Questions

1. Should hybrid artifacts mark portability at package/file level or line level?
2. What's the threshold for "portable"? (zero-config vs parameterizable)
3. Should portability metadata be required immediately or phased in?
4. How to handle rules with portable patterns but project-specific examples?

## Next Steps

1. Define taxonomy criteria (what qualifies as portable?)
2. Update `front-matter.mdc` with new fields
3. Update `rules-validate.sh` to check new fields
4. Start backfilling core portable rules (TDD, testing, git workflows)
