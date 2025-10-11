## Relevant Files

- .cursor/rules/capabilities.mdc
- docs/projects/capabilities-rules/erd.md

## Todo

- [ ] 1.0 Merge schema and examples from Capabilities Discovery ERD into this ERD
- [ ] 2.0 Update split-progress and README links (done)
- [ ] 3.0 Remove `docs/projects/capabilities-discovery/` folder

### Notes

- Discovery is read-only and consent-safe; any rule edits must follow rule maintenance cadence.

## Tasks

- [ ] 1.0 Compare rules across purpose, triggers, outputs, safety/consent
  - [ ] 1.1 Extract overlaps and gaps; list clear delineation options
- [ ] 2.0 Propose encoding improvements (schema, truncation, role-aware advice)
  - [ ] 2.1 Draft a normalized item schema and example entries
- [ ] 3.0 Decide: keep both with scopes or consolidate; document decision
  - [ ] 3.1 If consolidating, add deprecation header and pointer in superseded file
- [ ] 4.0 Apply selected changes to rules and update cross-references
  - [ ] 4.1 Update `lastReviewed` metadata and run validation script
