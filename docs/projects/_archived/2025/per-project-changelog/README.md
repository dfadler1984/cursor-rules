# Per-Project Changelog

**Status**: COMPLETE (All Enhancements)  
**Completed**: 2025-10-28  
**Mode**: Full (expanded from Lite)  
**Created**: 2025-10-27  
**Owner**: rules-maintainers

---

## Overview

Implements a simple, consistent per-project changelog system to track what changed in each project over time. Provides context for contributors returning to projects after weeks or months.

## Problem

Projects lack structured changelogs showing evolution, decisions, and milestones. History is scattered across session summaries, commits, and task updates—making it hard to quickly understand what's changed.

## Solution

**Approach**: Hybrid automatic/manual per-project `CHANGELOG.md` system with Keep-a-Changelog inspired format

**Key Features**:

- **Automatic generation** from tasks.md, git commits, and decisions via `changelog-update.sh`
- **Intelligent categorization** (keyword-based: Create→Added, Update→Changed, Fix→Fixed)
- **Three modes**: dry-run (preview), interactive (review before append), auto (append without prompts)
- Simple template for manual updates when needed
- High-level tracking (phases, decisions, scope changes)
- Optional by default, recommended for complex investigations
- Integrated with project archival workflow

## Artifacts

- **ERD**: [erd.md](./erd.md) — Requirements and approach
- **Tasks**: [tasks.md](./tasks.md) — Implementation tracking (100% complete)
- **Template**: `.cursor/templates/project-lifecycle/CHANGELOG.template.md` ✅
- **Script**: `.cursor/scripts/changelog-update.sh` ✅
- **Tests**: `.cursor/scripts/changelog-update.test.sh` ✅ (11 passing tests)
- **Design**: [analysis/automation-design.md](./analysis/automation-design.md)

## Phases

1. **Template & Documentation** (2 hours) ✅ — Create template, update docs, add example
2. **Tooling & Integration** (3 hours) ✅ — Update creation/archival scripts, add validation
3. **Documentation & Rollout** (1 hour) ✅ — Document, create examples, announce
4. **Automatic Generation** (8-10 hours) ✅ — Implement pattern detection, categorization, and auto-generation

**Total**: ~14-16 hours (expanded from 6 hours to include automation)

## Success Criteria

- Template for per-project changelogs
- Documentation in `project-lifecycle.mdc`
- Example in active investigation project
- Integration with archival workflow

## Related Projects

- [Changelog Automation](./_archived/2025/changelog-automation/) — Root CHANGELOG (Changesets)
- [Document Governance](./document-governance/) — Document standards
- [Project Lifecycle](./project-lifecycle/) — Project structure

## References

- [Keep a Changelog](https://keepachangelog.com/) — Format inspiration
- `project-lifecycle.mdc` — Project structure guidance
- `.cursor/scripts/project-archive-workflow.sh` — Archival automation
