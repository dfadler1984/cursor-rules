# Portability Analysis — AI Workflow Integration

**Purpose**: Document which artifacts and features are portable across Fortune 500 projects vs cursor-rules-specific implementation details.

**Context**: User needs to deploy this workflow across multiple Fortune 500 environments with different tech stacks, tooling, and compliance requirements.

---

## Enterprise Workflow (Full-Featured — Portable Across Fortune 500)

ALL these elements are needed for Fortune 500 work and must be portable:

### 1. Planning Artifacts (Minimal Templates)

**ERD — Minimal Version** (portable):

```markdown
## Problem/Goal

- 3-5 bullets

## Requirements

- 5-10 functional items

## Acceptance Criteria

- 3-5 measurable checks

## Tasks

- Parent task 1
  - Sub-task 1.1
  - Sub-task 1.2
```

**Why minimal**: Most teams need ONE planning doc, not 14 ERD sections. Consolidate into essentials.

### 2. Two-Phase Tasks Generation

**Portable pattern**:

1. Generate parent tasks (4-8 high-level items)
2. Wait for "Go" confirmation
3. Generate detailed sub-tasks

**Value**: Prevents overwhelm; allows course correction before detail work.

### 3. TDD Coupling (If Code)

**Portable pattern**:

- List test files that prove requirements work
- Include run commands to verify

**Acceptance Bundle** (portable subset):

```json
{
  "targets": ["file/path"],
  "exactChange": "one sentence what changed",
  "successCriteria": ["test that passes"],
  "runInstructions": ["command to verify"]
}
```

### 4. Basic Validator

**Portable checks**:

- Required sections exist
- Cross-links resolve
- Acceptance criteria present

**Implementation**: ~100-line shell script or Node.js tool

---

## Cursor-Rules-Specific (Non-Portable)

These elements are tightly coupled to cursor-rules repository conventions:

### 1. Full ERD Structure (14 Sections)

**Cursor-rules convention**:

- Introduction, Goals, User Stories, Functional Requirements, Non-Functional Requirements, Architecture/Design, Data Model, API/Contracts, Integrations, Edge Cases, Testing & Acceptance, Rollout & Ops, Success Metrics, Open Questions

**Why not portable**: Too heavyweight for most repos. Teams prefer lighter planning docs.

**Portable alternative**: Consolidate into 4-6 sections (Problem, Requirements, Acceptance, Tasks).

### 2. Lifecycle Stages (7 Stages with Hard Gates)

**Cursor-rules convention**:

- Scoping → Implementation → Validation → Synthesis → Approval → Complete (Active) → Complete (Archived)
- Pre-closure checklist with 8 hard gates
- Validation periods with measurement protocols

**Why not portable**: Most repos need: `Active` → `Done`. Maybe add `Archived`.

**Portable alternative**: Two states (Active, Complete) with optional archival.

### 3. Complex Scripts & Automation

**Cursor-rules-specific scripts**:

- `project-create.sh`, `project-status.sh`, `project-complete.sh`
- `final-summary-generate.sh`, `project-archive-workflow.sh`
- `project-lifecycle-validate.sh`, `project-lifecycle-validate-scoped.sh`

**Why not portable**: Assumes cursor-rules folder structure, front matter format, archival conventions.

**Portable alternative**: Single scaffold script + basic validator.

### 4. Slash Commands Integration

**Current state**: `/specify`, `/clarify`, `/plan`, `/tasks`, `/analyze`, `/implement`

**Portability**: Agent-specific (Cursor/Claude feature). Not universally supported.

**Portable alternative**: Document as optional extension; primary triggers are phrase-based.

### 5. Logging & Self-Improvement Protocol

**Cursor-rules convention**:

- Operation blocks (elapsed time, token I/O)
- Dependency Impact tracking
- Structured improvement logs with triggers

**Why not portable**: Most repos don't need this level of introspection.

**Portable alternative**: Optional extension for teams doing process improvement.

### 6. Dependencies, Priority, Parallelizable Markers

**Current integration**: `dependencies: [ids]`, `priority: high|medium|low`, `[P]` markers

**Portability**: Useful for complex projects, but adds overhead for simple ones.

**Portable alternative**: Optional extension; start with flat task lists.

---

## Extraction Strategy

### Phase 1: Create Portable Toolkit (Separate Project)

**Deliverables**:

1. Minimal ERD template (4-6 sections)
2. Minimal tasks template (two-phase generation guidance)
3. Basic acceptance bundle schema
4. Simple validator script (~100 lines)
5. README with quick-start guide

**Size target**: 5 files, < 500 lines total, zero configuration to start.

### Phase 2: Document Extensions (Layered Complexity)

**Level 1 — Minimal** (any repo):

- ERD template, tasks template, validator
- Time to adopt: 15 minutes

**Level 2 — Standard** (teams):

- Add Spec/Plan split
- Add acceptance bundle with TDD coupling
- Time to adopt: 1 hour

**Level 3 — Enterprise** (formal processes):

- Add lifecycle stages
- Add validation periods
- Add automation scripts
- Time to adopt: 4-8 hours

### Phase 3: Mark Artifacts with Portability Metadata

Use `portability` front matter field (per `portability/erd.md` taxonomy):

- `portable`: Works in any repo with minimal changes
- `project-specific`: Tied to cursor-rules conventions
- `hybrid`: Portable pattern, repo-specific implementation

---

## Recommendations

### For ai-workflow-integration (Complete)

- ✅ Document unified defaults (no toggles)
- ✅ Clarify what's standardized vs optional
- ✅ Mark project complete with this portability analysis

### For portable-workflow-toolkit (Next)

- Create new project with minimal templates
- Extract validator script
- Document 3-tier adoption (Minimal → Standard → Enterprise)
- Validate against 2-3 external repos (different languages/structures)

### For cursor-rules (Ongoing)

- Use portability taxonomy to mark rules/scripts
- Separate portable utilities from repo-specific tooling
- Create `.cursor/portable/` for reusable components
- Document cursor-rules-specific conventions explicitly

---

## Success Criteria

**Portable toolkit is successful if**:

- 5 files, < 500 lines total
- Works in new repo with < 15 minutes setup
- No configuration required to start
- Clear path to add complexity incrementally
- Validated in 2+ external repos (different domains)

**ai-workflow-integration is successful if**:

- Unified defaults documented
- Portability analysis complete
- Clear separation between core (portable) and extensions (cursor-rules-specific)
- Foundation laid for extraction project

---

## Related Documents

- [Portability Taxonomy](../../../portability/erd.md) — Front matter classification system
- [Project Organization](../../../project-organization/erd.md) — Structure conventions (cursor-rules-specific)
- [Document Templates](../../../document-templates/erd.md) — Template discovery (cursor-rules-specific)
- [AI Workflow Integration ERD](./erd.md) — Full integration specification
