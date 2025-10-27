# Orphaned Files Detection

**Project**: orphaned-files  
**Status**: ACTIVE  
**Created**: 2025-10-25  
**Owner**: Repository Maintenance

---

## Overview

Detect and clean up orphaned files in the repository — files that are not referenced by any other files and those that don't appear to be in use based on newer patterns.

## Goals

- Identify unreferenced files across the repository
- Detect files using obsolete patterns (e.g., old investigation structure, deprecated conventions)
- Provide safe deletion recommendations with context
- Prevent future orphan accumulation

## Quick Links

- [ERD](./erd.md) — Requirements and approach
- [Tasks](./tasks.md) — Execution checklist

## Scope

**In Scope**:

- Documentation files (`docs/`, `*.md`)
- Project files (`docs/projects/*`)
- Scripts without callers (`.cursor/scripts/`)
- Rules files (`.cursor/rules/`)

**Out of Scope**:

- Node modules and dependencies
- Git metadata
- Build artifacts (already ignored)

## Usage

```bash
# Detect orphaned files (dry-run)
bash .cursor/scripts/orphaned-files-detect.sh --dry-run

# Delete orphaned files (interactive)
bash .cursor/scripts/orphaned-files-detect.sh --delete --interactive

# Generate report
bash .cursor/scripts/orphaned-files-detect.sh --report --output orphaned-files-report.json
```

## Related

- [project-lifecycle.mdc](../../../.cursor/rules/project-lifecycle.mdc) — Project completion and archival
- [investigation-structure.mdc](../../../.cursor/rules/investigation-structure.mdc) — Expected file patterns
- [document-governance](../document-governance/) — Document lifecycle policies
