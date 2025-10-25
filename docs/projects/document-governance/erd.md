---
status: active  
owner: @dfadler1984
created: 2025-10-23  
lastUpdated: 2025-10-24
---

# Engineering Requirements Document: Document Governance Policy

Mode: Lite


## 1. Problem Statement

Projects are accumulating documents without clear governance. The assistant creates files freely, leading to:

- Inconsistent project structures
- Duplicate/overlapping documents
- Difficulty navigating projects
- Unclear which documents are appropriate for which project types

We need a policy that defines approved document categories and requires consent before creating unapproved document types.

## 2. Goals

### Primary

- Define approved document categories for different project types
- Create a consent gate that triggers before creating unapproved documents
- Establish clear criteria for when each document type is appropriate
- Prevent document proliferation while maintaining flexibility for valid needs

### Secondary

- Add validation tooling to audit projects for unapproved documents
- Provide guidance for migrating/consolidating existing documents
- Document rationale for each approved category

## 3. Current State

**Existing guidance** (in `/project` command and `investigation-structure.mdc`):

- Minimum set: `erd.md`, `tasks.md`, `README.md`
- Optional set: `discussions.md`, `findings/`, `analysis/`, `sessions/`, `test-results/`, `decisions/`, `protocols/`, `guides/`
- Distinction between simple projects (3-5 files) and investigations (15+ files)

**Gaps**:

- No enforcement mechanism for these guidelines
- Assistant doesn't ask before creating new document types
- No clear approval process for legitimate new document needs
- Unclear criteria for when optional documents are appropriate

## 4. Proposed Solutions

### Option A: Rule-Based Consent Gate (Preferred)

**Approach**: Create `.cursor/rules/document-governance.mdc` that:

- Lists approved document types by project category (simple/investigation/specialized)
- Requires assistant to check approval list before file creation
- Triggers consent prompt with justification for unapproved types
- Provides decision tree for choosing correct document type

**Pros**:

- Real-time prevention at creation
- Educational (assistant explains why alternatives might be better)
- Flexible (can approve one-time exceptions)

**Cons**:

- Adds cognitive overhead to file creation
- Requires assistant to check list consistently

### Option B: Validation-Only Approach

**Approach**: Post-hoc validation script that audits projects

- Flags unapproved documents in project reports
- Runs in CI or on-demand
- No prevention, only detection

**Pros**:

- No interruption to workflow
- Simple to implement

**Cons**:

- Documents already created before detection
- Requires manual cleanup

### Option C: Hybrid (Rule + Validation)

**Approach**: Combine both

- Rule provides consent gate (preventive)
- Validator catches violations (detective)
- Validator output feeds rule improvements

**Pros**:

- Defense in depth
- Continuous improvement feedback loop

**Cons**:

- More complex to maintain

## 5. Success Criteria

### Nested Sub-Projects

This umbrella project coordinates document standards across topics:

1. **Templates** (`templates/`)

   - Status: Active (Lite ERD)
   - Scope: Standard templates for ERD/spec/plan/tasks/ADRs
   - Links: [`templates/erd.md`](templates/erd.md), [`templates/tasks.md`](templates/tasks.md)

2. **README Structure** (`readme/`)

   - Status: Active (Full ERD)
   - Scope: Root README organization and content mapping
   - Links: [`readme/erd.md`](readme/erd.md), [`readme/tasks.md`](readme/tasks.md)

3. **Lifecycle Metadata** (`lifecycle/`)
   - Status: Active (Full ERD)
   - Scope: ERD completion metadata and lifecycle tracking
   - Links: [`lifecycle/erd.md`](lifecycle/erd.md), [`lifecycle/tasks.md`](lifecycle/tasks.md)

### Must Have (Policy Phase)

- [ ] Approved document categories defined for simple projects
- [ ] Approved document categories defined for investigation projects
- [ ] Consent gate triggers before creating unapproved documents
- [ ] Assistant provides justification and alternatives when requesting approval
- [ ] Policy integrated into assistant behavior (rule or gate)

### Should Have (Validation Phase)

- [ ] Validation script that audits projects for compliance
- [ ] Migration guidance for existing projects
- [ ] Decision tree for choosing correct document type
- [ ] Examples of good/bad document structures

### Nice to Have (Enhancement Phase)

- [ ] Auto-suggest consolidation when similar documents exist
- [ ] Template snippets for approved document types
- [ ] Metrics on document type usage across projects

### Nested Project Completion

- [ ] Templates project: Inventory complete, template drafts created
- [ ] README project: Content map complete, README outline approved
- [ ] Lifecycle project: Metadata schema defined, validator rules specified

## 6. Non-Goals

- Retroactively enforcing policy on archived projects
- Preventing all flexibility (legitimate new types should be approvable)
- Creating documents just to fill categories (only create when needed)
- Standardizing document content (focus on types, not internal structure)

## 7. Dependencies & Constraints

**Dependencies**:

- Assistant must check document approval before file creation
- Existing project lifecycle and investigation structure guidance
- Pre-send gate compliance (from `assistant-behavior.mdc`)

**Constraints**:

- Must not block legitimate document needs
- Should guide toward existing categories before approving new ones
- Policy should be enforceable in multiple ways (rule + tooling)

## 8. Open Questions

1. Should approval be session-scoped or require adding to permanent allowlist?
2. How to handle legacy projects that violate the policy?
3. Should certain document types require specific project phases (e.g., `final-summary.md` only at completion)?
4. How to distinguish between "document type" and "document instance" (e.g., multiple analysis docs might be fine)?

## 9. Timeline

**Phase 1**: 2-3 hours — Policy definition

- Define approved categories
- Create decision tree
- Document criteria

**Phase 2**: 2-3 hours — Rule implementation

- Create `document-governance.mdc`
- Integrate with pre-send gate
- Add examples

**Phase 3**: 1-2 hours — Validation tooling (optional)

- Create audit script
- Test against existing projects
- Document findings

**Total**: 5-8 hours

## 10. Related Work

- [project-lifecycle.mdc](../../.cursor/rules/project-lifecycle.mdc) — Project completion and structure
- [investigation-structure.mdc](../../.cursor/rules/investigation-structure.mdc) — Investigation project organization
- [assistant-behavior.mdc](../../.cursor/rules/assistant-behavior.mdc) — Pre-send gate and consent
- `/project` command — Current project creation guidance
- [rules-enforcement-investigation](../rules-enforcement-investigation/) — Studied enforcement patterns
