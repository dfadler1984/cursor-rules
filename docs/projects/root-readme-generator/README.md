# Root README Generator

Automates generation and validation of the repository root `README.md` to keep it current, accurate, and consistent.

## Status

**Active** — In planning phase (Phase 0: Discovery & Decisions)

**Completion**: ~0% (Decision phase)

## Overview

The root README is the repository's main entry point, but it risks becoming stale as scripts, rules, and projects evolve. This project aims to automate generation of sections like scripts inventory, stats summary, and quick links while preserving manually curated content like workflow philosophy and setup guides.

### Goals

- Keep root README accurate with automated script inventory
- Standardize formatting and reduce manual maintenance
- Provide clear navigation to docs, rules, projects, and tools
- Surface repository health metrics

### Non-Goals

- Not replacing manual conceptual content (workflow overview, design principles)
- Not handling docs/ organization (see: `document-governance` project)
- Not generating content for rules files or project ERDs

## Current Phase: Discovery & Decisions

**Before implementation begins**, we must resolve these critical questions:

### Key Decisions Needed

1. **Generation Strategy**: Full replacement, partial update, or hybrid?

   - How often do we manually edit root README?
   - Risk tolerance for lost edits vs consistency?

2. **Scripts Section Detail**: Full inventory (38+ scripts), top 10, or link-only?

   - Current README length constraint?
   - Contributor needs: reference vs quick-start?

3. **Manual vs Auto Sections**: Which sections remain manual?

   - Editorial value vs change frequency
   - Section ownership (manual, auto, hybrid)

4. **Template Structure**: Single template or modular fragments?

   - Complexity budget
   - Testability and composition needs

5. **Update Trigger**: CI auto-commit, manual script, or pre-commit hook?
   - Git noise tolerance
   - Freshness requirements

See `erd.md` Section 14 for full list of open questions.

## Architecture (Proposed)

### High-Level Flow

```
Input Sources → Metadata Extraction → Template Rendering → Validation → Output
```

### Components

1. **Metadata Extractors**

   - `extract_script_metadata()` — Scan `.cursor/scripts/`, parse headers
   - `extract_rules_metadata()` — Scan `.cursor/rules/`, parse front matter
   - `extract_project_stats()` — Count active/archived projects
   - `extract_health_metrics()` — Read health score, test coverage

2. **Template Renderer**

   - Reads template file
   - Replaces placeholders with generated content
   - Handles conditional sections (if needed)

3. **Validators**

   - Structure validation: Required sections present
   - Freshness validation: Compare with committed README
   - Link validation: Ensure targets exist

4. **Output Writer**
   - Atomic write pattern (temp file → rename)
   - Dry-run mode outputs to stdout
   - Preserve file permissions

## Proposed Scripts

- `.cursor/scripts/generate-root-readme.sh` — Main generator
- `.cursor/scripts/validate-root-readme.sh` — Staleness checker
- `.cursor/scripts/generate-root-readme.test.sh` — Test suite

### CLI Interface (Draft)

```bash
# Generate with defaults
./.cursor/scripts/generate-root-readme.sh

# Dry-run preview
./.cursor/scripts/generate-root-readme.sh --dry-run

# Use custom template
./.cursor/scripts/generate-root-readme.sh --template ./custom.md

# Validate README freshness
./.cursor/scripts/validate-root-readme.sh

# Autofix if stale
./.cursor/scripts/validate-root-readme.sh --fix
```

## Data Sources

- `.cursor/scripts/*.sh` → Script descriptions, flags, categories
- `.cursor/rules/*.mdc` → Rule names, descriptions, always-apply status
- `docs/projects/` → Active/archived project counts
- `capabilities.mdc` → Canonical capabilities list
- `VERSION` → Current version
- `CHANGELOG.md` → Recent entries (for "What's New")
- Health badge: Latest CI run or `health-badge-generate.sh` output

## Related Projects

- **Sister Project**: [`projects-readme-generator`](../projects-readme-generator/) — Pattern reference for docs/projects/README.md generation
- **Content Strategy**: [`document-governance`](../document-governance/) — Defines what belongs where (root vs docs/ vs project folders)

## Next Steps

**Phase 0: Discovery & Decisions** (Current)

1. Interview maintainers about manual edit frequency
2. Prototype 2-3 generation strategies
3. Document decisions in `decisions/` directory
4. Update ERD with selected approaches

**After Phase 0 Complete**:

- Phase 1: Foundation (template + metadata extractors)
- Phase 2: Core generation (renderer + section generators)
- Phase 3: Validation & CI integration
- Phase 4: Documentation & polish

## Documentation

- **ERD**: [`erd.md`](./erd.md) — Full requirements, architecture, open questions
- **Tasks**: [`tasks.md`](./tasks.md) — Detailed task breakdown with TDD approach
- **Decisions**: `decisions/` (TBD) — Decision documents for key choices

## Contributing

This project is in the **planning phase**. If you have opinions on the key decisions above, please:

1. Review the open questions in `erd.md` Section 14
2. Share feedback via issue or discussion
3. Help prototype generation strategies

Once Phase 0 decisions are made, implementation will follow TDD approach (Red → Green → Refactor).

## Success Criteria

- [ ] All Phase 0 decisions documented
- [ ] Generator produces valid Markdown output
- [ ] Test suite passes (10+ test cases)
- [ ] CI workflow validates README freshness
- [ ] Dogfooding: Root README regenerated using new generator
- [ ] Generation time: <2s
- [ ] Idempotent output (repeated runs identical)

---

**Last Updated**: 2025-10-25  
**Project Status**: Phase 0 (Discovery & Decisions)
