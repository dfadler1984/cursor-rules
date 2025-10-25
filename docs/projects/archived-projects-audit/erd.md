---
status: active  
owner: Repository Maintainers
created: 2025-10-23  
lastUpdated: 2025-10-24
---

# Engineering Requirements Document: Archived Projects Audit

Mode: Lite


## 1. Problem Statement

Archived projects in `docs/projects/_archived/2025/` may have incomplete task checklists or missing artifact migrations. This creates:

- Uncertainty about project completion state
- Potential for lost work (rules/scripts not migrated to canonical locations)
- Unclear handoff state for archived projects

**Why now**: Recent archival activity revealed potential gaps in archival workflow execution.

## 2. Goals

### Primary

- Validate all archived projects have complete task checklists (required tasks checked, optional tasks explicitly handled)
- Verify all project artifacts migrated to expected locations (rules → `.cursor/rules/`, scripts → `.cursor/scripts/`)
- Document any gaps and create remediation plan

### Secondary

- Validate archival methodology (if few findings, review audit criteria)
- Create reusable audit checklist for future archival reviews
- Identify patterns in incomplete archival (process improvements)

## 3. Current State

**Archived projects (2025)**:

- ~20+ projects in `docs/projects/_archived/2025/`
- Unknown completion state
- Unknown artifact migration state

**Existing validation**:

- `.cursor/scripts/project-lifecycle-validate-scoped.sh` — validates structure/artifacts
- No systematic post-archival audit process

## 4. Proposed Solutions

### Approach: Phased Audit with Methodology Validation

**Phase 1: Sample Review (5 most recent projects)**

1. Define audit criteria
2. Manually audit 5 projects
3. Document findings
4. **If <3 findings**: Review audit criteria for gaps (may be too lenient)
5. Refine methodology based on Phase 1 results

**Phase 2: Full Audit (remaining projects)**

1. Apply refined methodology
2. Batch remediation of issues
3. Create reusable checklist

**Rationale**: Sample-first approach validates methodology before full audit.

## 5. Success Criteria

### Must Have

- [x] Audit criteria defined (checklist)
- [x] 5 sample projects reviewed
- [x] Methodology validated (findings threshold check)
- [ ] All archived projects reviewed
- [ ] Incomplete final summaries identified
- [ ] Incomplete final summaries backfilled from git history
- [ ] Validation rules updated to catch unfilled templates
- [ ] Remediation plan created for gaps
- [ ] Gaps remediated or carryover tasks created

### Should Have

- [x] Reusable audit checklist created
- [ ] Process improvements identified
- [ ] Patterns documented

### Nice to Have

- [ ] Automated audit script
- [ ] Pre-archival validation improvements

## 6. Audit Criteria

### Task Completion

- [ ] All required tasks (non-optional) are checked
- [ ] Optional tasks are either:
  - Checked (completed), OR
  - Moved to `## Carryovers` section, OR
  - Explicitly marked as deferred/skipped with rationale

### Artifact Migration

- [ ] Rule files mentioned in tasks → exist in `.cursor/rules/` (or marked as skipped)
- [ ] Script files mentioned in tasks → exist in `.cursor/scripts/` (or marked as skipped)
- [ ] Documentation artifacts → exist in expected `docs/` locations
- [ ] Tests → colocated with implementations (or marked as deferred)

### Archival Artifacts

- [ ] Completion summary exists (any naming: `COMPLETION-SUMMARY.md`, `final-summary.md`, `PROJECT-SUMMARY.md`)
- [ ] **Completion summary is filled** (not placeholder template)
  - Template markers like `<One-paragraph summary>` or `<list>` indicate unfilled
  - Must have project-specific content
- [ ] Final `tasks.md` state preserved (checked items reflect actual completion)
- [ ] `README.md` shows completion status
- [ ] ERD updated with completion date and outcome

### Cross-References

- [ ] Rules reference correct file paths
- [ ] Scripts exist where referenced
- [ ] No broken internal links

## 7. Methodology Validation Threshold

**If Phase 1 (5 projects) yields <3 total findings**:

- Review audit criteria for gaps
- Check if criteria are too lenient
- Verify sample selection wasn't biased toward well-completed projects
- Adjust methodology before Phase 2

**Possible adjustments**:

- Stricter task completion definition
- Deeper artifact verification (content checks, not just existence)
- Additional criteria (cross-references, link validity)

## 8. Non-Goals

- Auditing active projects (only archived 2025 projects)
- Re-doing completed work (only verify migration happened)
- Changing archival process (document improvements, implement separately)

## 9. Dependencies & Constraints

**Dependencies**:

- `.cursor/scripts/project-lifecycle-validate-scoped.sh` for automated checks
- Git history for artifact migration verification

**Constraints**:

- Manual audit required (no full automation exists yet)
- ~20+ projects to review (estimate 10-15 min per project)

## 10. Open Questions

1. Should we review `_archived/<pre-2025>` projects? (Future scope)
2. What defines "required" vs "optional" task? (Use explicit marking in tasks.md)
3. How to handle partially-completed tasks with working implementation? (Count as complete if functionality exists)

## 11. Timeline

**Phase 1 (Sample)**: ~2 hours

- Define audit checklist: 15 min
- Review 5 projects: 75 min (15 min each)
- Methodology validation: 30 min

**Phase 2 (Full Audit)**: ~4-5 hours

- Review remaining ~15-17 projects: 3-4 hours
- Document patterns: 30 min
- Remediation planning: 30 min

**Phase 3 (Remediation)**: Variable (depends on findings)

**Total Estimate**: 6-7 hours + remediation time

## 12. Related Work

- [project-lifecycle.mdc](../../.cursor/rules/project-lifecycle.mdc) — Lifecycle guidance
- [investigation-structure.mdc](../../.cursor/rules/investigation-structure.mdc) — Complex project organization
- `.cursor/scripts/project-lifecycle-validate-scoped.sh` — Automated validation
- `.cursor/scripts/project-archive-workflow.sh` — Archival workflow
