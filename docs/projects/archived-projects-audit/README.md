# Archived Projects Audit

**Status**: ACTIVE  
**Phase**: 2 Complete → 3 Starting  
**Completion**: ~40% (Phase 1-2: ✅)

Systematic audit of archived projects to verify task completion and artifact migration.

---

## Quick Links

- [ERD](./erd.md) — Requirements and approach
- [Audit Checklist](./audit-checklist.md) — Reusable criteria
- [Findings](./findings/) — Issues discovered

---

## Problem

Archived projects may have:

- Incomplete task checklists
- Missing artifact migrations (rules/scripts not moved)
- Unclear completion state

## Approach

**Phase 1**: Sample 5 projects, validate methodology  
**Phase 2**: Full audit of remaining projects  
**Phase 3**: Remediation and process improvements

**Methodology validation**: If Phase 1 yields <3 findings, review audit criteria for gaps.

---

## Progress Tracking

### Phase 1: Sample Review ✅

- [x] Project setup
- [x] Define audit checklist
- [x] Audit 5 sample projects (10 findings)
- [x] Validate methodology (✅ PASS: effective)

### Phase 2: Template Validation ✅

- [x] Check Phase 1 for unfilled templates (2 found)
- [x] Backfill incomplete templates
- [x] Enhance validation script (placeholder detection)
- [ ] Document enhancement in project-lifecycle.mdc

### Phase 3: Full Audit

- [ ] Audit remaining projects (~15-17)
- [ ] Backfill any additional incomplete templates
- [ ] Document patterns

### Phase 4: Remediation

- [ ] Fix critical gaps
- [ ] Create process improvements

---

## Sample Projects (Phase 1)

Selected 5 most recently archived projects:

1. `slash-commands-runtime`
2. `productivity`
3. `collaboration-options`
4. `ai-workflow-integration`
5. `core-values`

---

## Related

- [project-lifecycle.mdc](../../../.cursor/rules/project-lifecycle.mdc)
- [Project Archive Workflow](../../../.cursor/scripts/project-archive-workflow.sh)
- [Project Lifecycle Validation](../../../.cursor/scripts/project-lifecycle-validate-scoped.sh)
