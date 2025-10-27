# Document Governance Policy

**Status**: ACTIVE  
**Phase**: 1 (Policy Definition)  
**Completion**: ~0%

---

## Overview

Define and enforce governance policy for project documentation to prevent proliferation while maintaining flexibility for legitimate needs.

## Problem

Projects accumulate documents without clear guidelines, leading to inconsistent structures and difficulty navigating. We need approved document categories and a consent gate for unapproved types.

## Goals

1. Define approved document categories by project type
2. Create consent gate before creating unapproved documents
3. Provide decision tree for choosing correct document type
4. Add validation tooling (optional)

## Quick Links

- [ERD](./erd.md) — Full requirements and approach

## Approach

**Phase 1**: Define approved categories and decision tree  
**Phase 2**: Implement rule with consent gate  
**Phase 3**: Add validation tooling (optional)

## Key Artifacts

**To be created**:

- `.cursor/rules/document-governance.mdc` — Policy rule with approved categories
- `.cursor/scripts/validate-document-governance.sh` — Audit script (Phase 3)

## Related Projects

- [investigation-structure](../investigation-docs-structure/) — Investigation organization standards
- [project-lifecycle-docs-hygiene](../project-lifecycle-docs-hygiene/) — Documentation completeness
- [rules-enforcement-investigation](../rules-enforcement-investigation/) — Enforcement patterns study

## Timeline

- **Phase 1**: 2-3 hours (policy definition)
- **Phase 2**: 2-3 hours (rule implementation)
- **Phase 3**: 1-2 hours (validation tooling)
- **Total**: 5-8 hours
