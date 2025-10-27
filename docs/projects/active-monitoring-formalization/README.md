# Active Monitoring Formalization

**Status**: ACTIVE — Planning Phase  
**Owner**: repo-maintainers  
**Created**: 2025-10-24

---

## Overview

Formalize the active monitoring system to provide clear structure, lifecycle management, and workflows for how monitored items are created, reviewed, and closed.

**Problem**: `ACTIVE-MONITORING.md` exists but lacks formal structure and lifecycle management  
**Solution**: Document requirements, create templates, define workflows, integrate with investigation projects

---

## Quick Links

- **[ERD](erd.md)** — Requirements and approach
- **[ACTIVE-MONITORING.md](../ACTIVE-MONITORING.md)** — Current monitoring coordination file

---

## Key Questions

1. Where should findings be documented? (individual projects vs ACTIVE-MONITORING.md)
2. When does a monitored item close? (closure criteria)
3. How to handle multi-project monitoring? (scope conflicts, cross-references)
4. What templates are needed? (monitoring protocol, finding document, review checklist)
5. When does monitoring become a dedicated investigation? (threshold)

---

## Project Artifacts

**Planning** (Current Phase):

- ✅ ERD created with requirements and open questions
- ⏸️ Tasks to be generated from ERD
- ⏸️ Templates to be created (Phase 2)

**Deliverables** (Upcoming):

- Formal structure documentation
- Templates (monitoring protocol, finding document, review checklist)
- Review workflow guide
- Integration patterns

---

## Related

- **Gap #17/17b**: Created ACTIVE-MONITORING.md without enforcement (origin of this project)
- **rules-enforcement-investigation**: Uses ACTIVE-MONITORING.md for execution monitoring
- **routing-optimization**: Uses ACTIVE-MONITORING.md for routing monitoring
- **investigation-structure.mdc**: Structure guidance for complex projects
