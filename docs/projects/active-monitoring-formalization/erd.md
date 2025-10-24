---
status: planning
mode: full
owner: repo-maintainers
created: 2025-10-24
lastUpdated: 2025-10-24
---

# Engineering Requirements Document — Active Monitoring Formalization

Mode: Full

## 1. Introduction/Overview

**Problem**: `ACTIVE-MONITORING.md` exists as an ad-hoc coordination mechanism but lacks formal structure, lifecycle management, and clear workflows for how monitored items are created, reviewed, and closed.

**Proposed Solution**: Formalize the active monitoring system with documented structure, templates, review workflows, and integration patterns with investigation projects. Define where findings go, when items close, and how to handle multi-project monitoring.

**Context**: Created from Gap #17/17b (ACTIVE-MONITORING.md created without enforcement mechanism). This project formalizes the mechanism itself.

## 2. Goals/Objectives

### Primary

- Document formal structure for ACTIVE-MONITORING.md (required fields, lifecycle states)
- Define where monitoring findings get documented (individual projects vs ACTIVE-MONITORING.md)
- Create review/closure workflows for monitored items
- Establish templates for monitoring protocols and finding documentation

### Secondary

- Integration guidance with investigation projects (when to use monitoring vs dedicated project)
- Metrics for monitoring effectiveness (average time to closure, findings conversion rate)
- Automation opportunities (auto-detection of scope conflicts, stale monitoring alerts)

## 3. User Stories

- As an **assistant**, I want clear guidance on where to document findings so that I put them in the correct project without user correction
- As a **maintainer**, I want monitored items to have closure criteria so that monitoring doesn't accumulate indefinitely
- As a **future investigator**, I want structured finding documents so that I can understand what was monitored and why
- As an **assistant during investigation**, I want to know when my finding belongs to an active monitoring scope vs a new gap

## 4. Functional Requirements

### Document Structure (ACTIVE-MONITORING.md)

1. **Required fields per monitored project**:

   - Status (🔄 Active, ✅ Complete, ⏸️ Paused)
   - Started date (YYYY-MM-DD)
   - Duration / End criteria
   - Findings path (where to document)
   - Naming pattern (how to name finding files)
   - Scope (what this project monitors)
   - Out of scope (what belongs elsewhere)
   - Cross-reference (where to redirect if wrong scope)

2. **Lifecycle states**:

   - Active: Currently monitoring
   - Paused: Temporarily suspended
   - Complete: Monitoring finished, findings documented
   - Archived: Moved to project's historical section

3. **Decision tree section**: Quick routing guide (symptom → category → project)

### Finding Documentation Workflow

1. **Detection**: When observing issue during work, check ACTIVE-MONITORING.md
2. **Categorization**: Use decision tree to determine project
3. **Documentation**: Follow project's findings path and naming pattern
4. **OUTPUT requirement**: "Observed: [X] | Category: [Y] | Project: [Z] | Document in: [path]"

### Review & Closure

1. **Review checkpoint**: When to review monitored items (time-based or finding-count-based)
2. **Closure criteria**: When monitoring ends (success criteria met, project complete, scope changed)
3. **Post-closure**: Where completed monitoring records go (project findings/ or archive)

## 5. Non-Functional Requirements

- **Usability**: Decision tree resolves scope in <30 seconds
- **Maintainability**: Clear when to add/remove/update monitored projects
- **Discoverability**: Referenced from investigation OUTPUT requirements (self-improve.mdc)
- **Compliance**: Enforced via pre-send gate (assistant-behavior.mdc line 292)

## 6. Architecture/Design

### Core Components

**ACTIVE-MONITORING.md** (Index):

- Table of currently monitored projects
- Decision tree for routing findings
- Quick reference (symptom → project)

**Project-Specific Monitoring**:

- Each project defines its findings location
- Projects own their scope boundaries
- Cross-references point to related projects

**Templates**:

- `monitoring-protocol.template.md` — How to structure monitoring in a project
- `finding-template.md` — Standard finding document structure
- `review-checklist.md` — Periodic review checklist

**Integration Points**:

- `self-improve.mdc` (lines 201-208): Requires ACTIVE-MONITORING.md check before documenting
- `assistant-behavior.mdc` (line 292): Pre-send gate verifies monitoring check
- Investigation projects: Reference ACTIVE-MONITORING.md in coordination.md

### Lifecycle Flow

```
New Project Needs Monitoring
    ↓
Add to ACTIVE-MONITORING.md (Status: Active)
    ↓
Define: Scope, Findings Path, Duration
    ↓
During Monitoring: Document findings per project pattern
    ↓
Review Checkpoint (periodic or finding-count trigger)
    ↓
Closure Decision (criteria met? scope changed? project complete?)
    ↓
Update Status (Complete or Paused)
    ↓
Archive Monitoring Record (move to project/monitoring-history.md)
```

## 7. Data Model and Storage

### ACTIVE-MONITORING.md Schema

**Per-Project Entry**:

```markdown
### <project-slug>

| Field           | Value                                      |
| --------------- | ------------------------------------------ |
| Status          | 🔄 Active / ✅ Complete / ⏸️ Paused        |
| Started         | YYYY-MM-DD                                 |
| Duration        | <time-based> OR <criteria-based>           |
| Findings Path   | docs/projects/<slug>/findings/             |
| Pattern         | gap-##-<name>.md OR ## Finding #N: <title> |
| Scope           | What this project monitors (bullets)       |
| Out of Scope    | What belongs elsewhere (bullets)           |
| Cross-Reference | Where to redirect if wrong scope           |
```

### Finding Document Template

**Standard structure** (individual file):

```markdown
# Finding #N: <Title> OR Gap #N: <Title>

**Date**: YYYY-MM-DD
**Project**: <slug>
**Category**: [routing|execution|workflow|other]
**Severity**: [critical|high|medium|low]

## Issue

<What was observed>

## Evidence

<Concrete examples, logs, commits>

## Impact

<Effect on project/quality/compliance>

## Root Cause

<Analysis of why it happened>

## Proposed Fix

<Recommended actions>

## Related

<Links to related gaps, projects, rules>
```

## 8. API/Contracts

### Assistant Integration Contract

**self-improve.mdc** (investigation section) MUST:

1. Consult ACTIVE-MONITORING.md before documenting findings
2. OUTPUT: "Observed: [X] | Category: [Y] | Project: [checked ACTIVE-MONITORING.md → Z]"
3. Document in project-specified location

**assistant-behavior.mdc** (pre-send gate) MUST:

1. Check: "Monitoring: checked ACTIVE-MONITORING.md? (if documenting finding)"
2. Verify OUTPUT was shown
3. FAIL if finding documented in wrong project

### Project Registration Contract

**To add monitoring to a project**:

1. Add entry to ACTIVE-MONITORING.md with all required fields
2. Create findings directory/file in project
3. Document scope boundaries clearly
4. Define closure criteria

## 9. Integrations/Dependencies

### Related Projects

- **rules-enforcement-investigation**: Execution monitoring (owns many Gap #N findings)
- **routing-optimization**: Intent routing monitoring (owns Finding #N findings)
- **investigation-docs-structure**: Provides structure guidance for investigation projects

### Rules Integration

- **self-improve.mdc** (lines 201-208): ACTIVE-MONITORING.md check requirement
- **assistant-behavior.mdc** (line 292): Pre-send gate monitoring check
- **investigation-structure.mdc**: References for multi-file findings structure

### Scripts Integration

- `project-create.sh`: Should optionally create monitoring setup
- `project-lifecycle-validate-scoped.sh`: Could validate monitoring metadata
- Future: `monitoring-review.sh` for periodic review automation

## 10. Edge Cases and Constraints

### Edge Cases

1. **Finding spans multiple projects**: Document in primary project, cross-reference from others
2. **Unclear category**: Use decision tree; if still unclear, ask one clarifying question
3. **Multiple active investigations with overlapping scope**: Define precedence (newer project takes priority OR first-registered)
4. **Project completes but monitoring continues**: Mark project Complete (Active), keep monitoring entry Active

### Constraints

- ACTIVE-MONITORING.md should remain scannable (≤300 lines, collapsed details in project-specific monitoring-history.md)
- Decision tree must resolve 90%+ cases without clarification
- No more than 5 concurrent active monitoring projects (maintain focus)
- Findings must link back to ACTIVE-MONITORING.md entry for traceability

## 11. Testing & Acceptance

The solution is complete when:

- ACTIVE-MONITORING.md structure is documented with required fields and lifecycle states defined
- Review workflow exists (when to review, closure criteria, post-closure handling)
- Templates created for monitoring protocols and finding documents
- Integration documented (how projects register, how assistant uses it, enforcement via gates)
- Decision tree validated (tested on 10+ real findings, >90% correct routing)
- Assistant can correctly categorize findings and document in correct project without user correction
- Monitored items have clear closure criteria and don't accumulate indefinitely
- Stale monitoring detection mechanism exists (duration exceeded, no findings in N days)

## 12. Rollout Plan

### Phase 1: Documentation (Week 1)

- Document formal structure requirements (section templates, required fields)
- Create decision tree expansion (more categories, clearer symptoms)
- Write review workflow guide (when/how to review, closure decision tree)

### Phase 2: Templates (Week 1)

- Create monitoring protocol template (for projects to copy)
- Create finding document template (standard structure)
- Create review checklist template (periodic validation)

### Phase 3: Integration (Week 2)

- Update existing monitored projects to match formal structure
- Validate decision tree with historical findings (should route correctly)
- Document integration with project-create.sh (optional monitoring setup)

### Phase 4: Automation (Future)

- Script to detect stale monitoring (no findings in 30 days, duration exceeded)
- Script to validate ACTIVE-MONITORING.md structure
- Auto-detection of scope conflicts (finding documented in wrong project)

## 13. Success Metrics

- **Correct routing**: >95% of findings documented in correct project without user correction
- **Closure rate**: 100% of monitored items have explicit closure criteria
- **Review compliance**: Monitored items reviewed within defined intervals (no stale entries >60 days)
- **Template adoption**: 100% of new monitoring uses templates (no ad-hoc structures)
- **Scope clarity**: 0 cross-project documentation confusion incidents after deployment

## 14. Open Questions

1. Should ACTIVE-MONITORING.md live in `docs/projects/` or `.cursor/docs/`?

   - Current: `docs/projects/` (alongside projects)
   - Alternative: `.cursor/docs/` (alongside rules documentation)
   - Consideration: Project vs meta-process documentation

2. How many concurrent monitoring projects is too many?

   - Proposed: 5 maximum (maintain focus)
   - Alternative: Unlimited (trust maintainers to manage)

3. Should findings always be individual files or allow single-file with sections?

   - Current: routing-optimization uses single file, rules-enforcement uses individual files
   - Proposed: ≤5 findings → single file; >5 findings → individual files directory
   - Follows same pattern as investigation-structure.mdc

4. When does monitoring become a dedicated investigation project?

   - Proposed: >15 findings OR >10 files created → convert to investigation project
   - Alternative: Always use monitoring; never convert

5. Should there be a "monitoring-history.md" in each project for closed monitoring periods?
   - Proposed: Yes, archive completed monitoring records there
   - Alternative: Delete from ACTIVE-MONITORING.md when complete
