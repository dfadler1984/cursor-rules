# Create Project

Create a new project with proper structure and artifacts.

## Quick Start

```bash
# Create project directory
mkdir -p docs/projects/<project-slug>

# Create ERD (Engineering Requirements Document)
# Use template or start from scratch
```

## Project Structure

**Minimum (all projects)**:
- `erd.md` — Engineering requirements, scope, approach
- `tasks.md` — Phase checklists and execution tracking
- `README.md` — Entry point and navigation

**Optional (as needed)**:
- `discussions.md` — Open questions and decision log
- `findings.md` — Outcomes and retrospective (simple projects)
- `findings/` — Individual findings (complex projects, 5+ findings)
- `analysis/` — Deep analysis documents
- `sessions/` — Session summaries (`YYYY-MM-DD.md`)
- `test-results/` — Test execution data
- `decisions/` — Formal decision documents
- `protocols/` — Test and validation protocols
- `guides/` — Reference guides

## ERD Template

Create `erd.md` with these sections:

```markdown
# Engineering Requirements Document: <Title>

**Project**: <slug>  
**Status**: ACTIVE  
**Created**: YYYY-MM-DD  
**Owner**: <team/person>

---

## 1. Problem Statement

What problem are we solving? Why now?

## 2. Goals

### Primary
- Main objectives (must-have outcomes)

### Secondary
- Nice-to-have outcomes

## 3. Current State

What exists today? What's the baseline?

## 4. Proposed Solutions

### Option A: <Name>
**Approach**: ...
**Pros**: ...
**Cons**: ...

### Option B: <Name>
**Approach**: ...
**Pros**: ...
**Cons**: ...

## 5. Success Criteria

### Must Have
- [ ] Criterion 1
- [ ] Criterion 2

### Should Have
- [ ] Criterion 3

### Nice to Have
- [ ] Criterion 4

## 6. Non-Goals

What is explicitly out of scope?

## 7. Dependencies & Constraints

What do we depend on? What limits our options?

## 8. Open Questions

1. Question 1?
2. Question 2?

## 9. Timeline

**Phase 1**: X hours - Description
**Phase 2**: Y hours - Description
**Total**: Z hours

## 10. Related Work

- Link to related projects
- Link to relevant rules/docs
```

## Generate Tasks

After creating ERD, generate task list:

```bash
# Use assistant to generate tasks from ERD
# Command: "Generate tasks from ERD at docs/projects/<slug>/erd.md"
```

Or manually create `tasks.md`:

```markdown
## Tasks — <Project Title>

**Status**: ACTIVE | Phase: <phase> | <X>% Complete

---

## Phase 1: <Name>

- [ ] 1.0 Task group
  - [ ] 1.1 Subtask
  - [ ] 1.2 Subtask

## Phase 2: <Name>

- [ ] 2.0 Task group
  - [ ] 2.1 Subtask
```

## Investigation Projects

For multi-hypothesis investigations (>15 files), follow structure from `investigation-structure.mdc`:

**Folders to create**:
- `findings/` — Gap documents (`gap-##-<name>.md`)
- `analysis/` — Deep analysis
- `sessions/` — Session summaries (`YYYY-MM-DD.md`)
- `test-results/` — Test data (organize by hypothesis)
- `decisions/` — Decision documents
- `protocols/` — Test protocols
- `guides/` — Reference guides

**Keep root minimal** (≤7 files): `README.md`, `erd.md`, `tasks.md`, optional `coordination.md`

## Validation

After creating project structure:

```bash
# Validate project structure (if investigation)
bash .cursor/scripts/validate-investigation-structure.sh docs/projects/<slug>

# Validate ERD structure
bash .cursor/scripts/erd-validate.sh docs/projects/<slug>/erd.md

# Validate lifecycle artifacts
bash .cursor/scripts/project-lifecycle-validate-scoped.sh <slug>
```

## Examples

### Simple Project

```
docs/projects/simple-feature/
  ├── README.md
  ├── erd.md
  └── tasks.md
```

### Complex Investigation

```
docs/projects/complex-investigation/
  ├── README.md
  ├── erd.md
  ├── tasks.md
  ├── coordination.md
  ├── findings/
  │   ├── README.md
  │   ├── gap-01-issue.md
  │   └── gap-02-issue.md
  ├── analysis/
  │   └── topic-analysis.md
  ├── sessions/
  │   ├── 2025-10-20.md
  │   └── 2025-10-21.md
  ├── test-results/
  │   └── h1/
  ├── decisions/
  │   └── approach-decision.md
  └── protocols/
      └── test-protocol.md
```

## Project Naming

**Pattern**: `<scope>-<topic>`

**Examples**:
- `shell-test-organization` (scope: shell, topic: test organization)
- `rules-enforcement-investigation` (scope: rules, topic: enforcement investigation)
- `pr-create-decomposition` (scope: pr-create, topic: decomposition)

**Avoid**:
- Dates in slugs (use creation date in ERD front matter)
- Generic names (`project-1`, `investigation`)
- Underscores (use hyphens)

## Lifecycle

**Active**: Project in progress
```markdown
**Status**: ACTIVE  
**Phase**: <current-phase>  
**Completion**: ~<percentage>%
```

**Complete**: Project finished
```markdown
**Status**: COMPLETE  
**Completed**: YYYY-MM-DD  
**Outcome**: <summary>
```

**Archived**: Moved to `_archived/<YYYY>/`
```bash
# Archive completed project
bash .cursor/scripts/project-archive-workflow.sh --project <slug> --year <YYYY>
```

## See Also

- [project-lifecycle.mdc](../.cursor/rules/project-lifecycle.mdc) — Full lifecycle guidance
- [create-erd.mdc](../.cursor/rules/create-erd.mdc) — ERD authoring details
- [generate-tasks-from-erd.mdc](../.cursor/rules/generate-tasks-from-erd.mdc) — Task generation
- [investigation-structure.mdc](../.cursor/rules/investigation-structure.mdc) — Complex project organization

