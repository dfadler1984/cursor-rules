## Relevant Files

- .cursor/rules/capabilities.mdc
- docs/projects/capabilities-rules/erd.md

## Todo

- [x] 1.0 ~~Merge schema and examples from Capabilities Discovery ERD into this ERD~~ (N/A - folder already removed)
- [x] 2.0 Update split-progress and README links
- [x] 3.0 ~~Remove `docs/projects/capabilities-discovery/` folder~~ (already removed)

### Notes

- Discovery is read-only and consent-safe; any rule edits must follow rule maintenance cadence.

## Tasks

- [x] 1.0 Compare rules across purpose, triggers, outputs, safety/consent
- [x] 2.0 Propose encoding improvements (schema, truncation, role-aware advice)
  - [x] 2.1 Draft a normalized item schema and example entries → Added to capabilities.mdc
- [x] 3.0 Decide: keep both with scopes or consolidate; document decision
- [x] 4.0 Apply selected changes to rules and update cross-references
  - [x] 4.1 Update capabilities.mdc Discovery section with canonical schema
  - [x] 4.2 Update ERD to reference canonical schema location
  - [x] 4.3 Update `lastReviewed` metadata and run validation script → Validation passed
