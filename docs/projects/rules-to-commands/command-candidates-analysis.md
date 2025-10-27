# Command Candidates Analysis

**Date**: 2025-10-23  
**Purpose**: Identify rules that would work better as Cursor commands (`.cursor/commands/*.md`)

---

## Decision Framework

**Good candidates for commands:**

- Procedural workflows (step-by-step instructions)
- Creation/scaffolding tasks (templates)
- Multi-phase processes with user checkpoints
- Quick reference guides
- User-initiated workflows

**Should stay as rules:**

- Behavioral enforcement (must/should requirements)
- Quality standards and validation
- Constraints and boundaries
- Assistant decision-making logic
- Always-on guidance

---

## High-Priority Command Candidates

### 1. `/erd` — Create ERD

**Current**: `create-erd.mdc` (252 lines)

**Why command:**

- Explicit creation workflow with clarifying questions
- Template-based output (Full vs Lite modes)
- User-initiated action (not behavioral enforcement)
- Similar to existing `/project` command pattern
- Natural user interaction: "I want to create an ERD"

**Command structure:**

````markdown
# Create ERD

Creates an Engineering Requirements Document (ERD) in Lite or Full mode.

## Quick Start

**Lite Mode** (for small/simple features):

```bash
# Tell assistant: "Create lite ERD for <feature>"
```
````

**Full Mode** (default, for substantial features):

```bash
# Tell assistant: "Create ERD for <feature>"
```

## What You'll Need

The assistant will ask clarifying questions about:

- Problem/Goal
- Target User
- Scope & Non-Goals
- Core Functionality
- Non-Functional Requirements
- Architecture
- Testing & Acceptance
- Success Metrics

## Output

Creates `docs/projects/<feature>/erd.md` with:

**Full Mode**: 13 sections (Introduction, Goals, User Stories, Requirements, Architecture, etc.)

**Lite Mode**: 6 sections (Overview, Goals, Requirements, Acceptance, Risks, Rollout)

## References

- Template guidance: See `.cursor/rules/create-erd.mdc`
- After creating ERD: Use `/tasks` to generate task list

````

**Benefits:**
- Discoverable via `/erd` command
- Clear user intent (creation, not enforcement)
- Zero context cost until invoked
- Complements routing without replacing behavioral rules

---

### 2. `/tasks` — Generate Tasks from ERD

**Current**: `generate-tasks-from-erd.mdc` (232 lines)

**Why command:**
- Two-phase workflow (parent tasks → "Go" → sub-tasks)
- Explicit user checkpoint (wait for "Go")
- Template-based output
- Natural follow-up to `/erd`

**Command structure:**
```markdown
# Generate Tasks from ERD


## Usage

```bash
# After creating ERD:
# Tell assistant: "Generate tasks from ERD at docs/projects/<feature>/erd.md"
````

## Two-Phase Process

**Phase 1**: Assistant generates 4-8 high-level parent tasks and asks "Ready to generate sub-tasks? Respond with 'Go'."

**Phase 2**: After you respond "Go", assistant adds:

- Sub-tasks for each parent task
- Relevant files section
- TDD-first guidance

## Output


- Checkbox-based task tracking
- Parent/sub-task hierarchy
- Relevant files list
- TDD workflow notes

## References

- Task format: See `.cursor/rules/generate-tasks-from-erd.mdc`
- TDD guidance: See `.cursor/rules/tdd-first.mdc`

````

**Benefits:**
- Natural two-phase interaction model
- User controls progression
- Separates creation workflow from enforcement

---

### 3. `/test-plan` — Create Test Plan

**Current**: `test-plan-template.mdc` (335 lines)

**Why command:**
- Pure template (7 required sections)
- Creation workflow, not enforcement
- Used for specific user action (creating test plan)

**Command structure:**
```markdown
# Create Test Plan

Creates structured test plan with 7 required sections.

## Usage

```bash
# Tell assistant: "Create test plan for <hypothesis/feature>"
````

## Template Sections

1. **Background** — Context and hypothesis
2. **Test Design** — Control/experimental groups, scenarios
3. **Success Criteria** — Metrics and thresholds
4. **Measurement Protocol** — Data collection format
5. **Expected Outcomes** — Scenarios and implications
6. **Implementation Checklist** — Step-by-step execution
7. **Timeline & Effort** — Resource planning

## Output

Creates test plan document in appropriate location:

- Investigation tests: `docs/projects/<project>/tests/`
- Feature tests: `docs/specs/`

## References

- Full template: See `.cursor/rules/test-plan-template.mdc`
- Measurement validity: See `docs/projects/assistant-self-testing-limits/`

````

**Benefits:**
- Explicit creation workflow
- Template discoverability
- Natural user intent

---

### 4. `/investigation` — Create Investigation Project

**Current**: `investigation-structure.mdc` (123 lines)

**Why command:**
- Scaffolding workflow (create folders/files)
- Template-based structure
- User-initiated project creation
- Similar to `/project` but specialized

**Command structure:**
```markdown
# Create Investigation Project

Creates structured investigation project with proper folder organization.

## Usage

```bash
# Tell assistant: "Create investigation project for <topic>"
````

## When to Use

**Use investigation structure** when:

- Multi-hypothesis investigation
- Substantial documentation (>15 files)
- Need for findings/analysis/test-results organization

**Use simple structure** when:

- Simple projects (<10 files)
- Single hypothesis or straightforward feature

## Structure Created

```
docs/projects/<slug>/
├── README.md
├── erd.md
├── findings/
├── analysis/
├── sessions/
├── test-results/
├── decisions/
├── protocols/
└── guides/
```

## References

- Full structure standard: See `.cursor/rules/investigation-structure.mdc`
- Simple projects: Use `/project` command instead

```

**Benefits:**
- Clear when to use investigation vs simple structure
- Scaffolding workflow
- Natural complement to `/project`

---

## Medium-Priority Command Candidates

### 5. `/spec` — Spec-Driven Workflow

**Current**: `spec-driven.mdc` (111 lines), `deterministic-outputs.mdc` (134 lines)

**Why command:**
- Multi-phase workflow (Specify → Plan → Tasks)
- Multiple user checkpoints
- Template-based outputs
- Natural slash command flow (`/specify`, `/plan`, `/tasks`, `/analyze`)

**Note**: This is partially covered by existing slash command references, but could be unified into single command flow.

---

## Rules That Should Stay as Rules

### Behavioral/Enforcement (Keep as Rules)

**TDD & Testing:**
- `tdd-first.mdc` — TDD pre-edit gate (enforcement)
- `testing.mdc` — Testing conventions (standards)
- `test-quality.mdc` — Quality standards (enforcement)
- `test-quality-js.mdc`, `test-quality-sh.mdc` — Language-specific enforcement

**Assistant Behavior:**
- `assistant-behavior.mdc` — Consent-first, status updates (behavioral)
- `guidance-first.mdc` — Handling guidance requests (behavioral)
- `user-intent.mdc` — Intent classification (routing logic)
- `intent-routing.mdc` — Routing rules (behavioral)
- `scope-check.mdc` — Validation protocol (enforcement)

**Code Quality:**
- `code-style.mdc` — Functional/declarative standards (enforcement)
- `refactoring.mdc` — Refactoring workflow (standards)
- `imports.mdc` — Import organization (standards)
- `shell-unix-philosophy.mdc` — Shell script principles (standards)

**Meta-Rules:**
- `rule-creation.mdc` — How to create rules (meta)
- `rule-maintenance.mdc` — Pattern-driven updates (meta)
- `rule-quality.mdc` — Validation checklist (meta)
- `front-matter.mdc` — Front matter standards (meta)

**Git (Mixed):**
- `assistant-git-usage.mdc` — Keep as rule (enforcement of script-first)
- `git-slash-commands.mdc` — Already describes command templates (documentation)

**Other:**
- `project-lifecycle.mdc` — Project completion policies (enforcement)
- `workspace-security.mdc` — Security policies (enforcement)
- `security.mdc` — Security standards (enforcement)
- `dependencies.mdc` — Dependency policies (enforcement)

---

## Implementation Priority

### Phase 1: High-Impact Commands
1. `/erd` — Most requested, clear workflow
2. `/tasks` — Natural follow-up to ERD
3. `/investigation` — Complements `/project`

### Phase 2: Template Commands
4. `/test-plan` — Specialized but valuable

### Phase 3: Unified Workflows
5. `/spec` workflow — Unify existing slash command references

---

## Success Criteria

Commands should be created when:
- ✅ Workflow is user-initiated (not assistant-initiated)
- ✅ Template-based output exists
- ✅ Multiple steps with user checkpoints
- ✅ Natural discoverability via `/` prefix
- ✅ Reduces context load (loaded on-demand)

Commands should NOT replace:
- ❌ Behavioral enforcement rules
- ❌ Quality standards and validation
- ❌ Assistant decision-making logic
- ❌ Always-on guidance

---

## Measurement Plan

After implementing commands, track over 20-30 operations:
- Command usage rate (how often users type `/command`)
- Workflow completion rate (started → finished)
- User feedback (helpful? discoverable?)
- Context efficiency (rules load reduced?)

**Success thresholds:**
- Command usage >40% for creation workflows
- Workflow completion >80%
- Positive user feedback
- Measurable context load reduction

---

## Related

- See `git-slash-commands.mdc` for existing command template pattern
- See `/project` command as reference implementation
- See [Cursor Commands Documentation](https://cursor.com/docs/agent/chat/commands) for platform details

```
