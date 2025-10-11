---
status: active
owner: rules-maintainers
---

# Engineering Requirements Document — AI Workflow Integration

Mode: Full

## 1. Introduction/Overview

Unify and improve our Cursor Rules by integrating proven workflows from three sources:
`snarktank/ai-dev-tasks` (PRD→tasks prompts), `github/spec-kit` (Spec‑Driven Development with slash‑commands), and `eyaltoledano/claude-task-master` (task/dependency model, research, progress/logging). The outcome is a coherent, configurable ruleset that preserves our consent‑first, TDD‑first defaults while offering optional capabilities (slash‑commands, task dependencies/priority, enhanced logging/metrics).

## 2. Goals/Objectives

- Align ERD/spec → plan → tasks flow with Spec‑Driven patterns (optional slash‑commands).
- Preserve our two‑phase tasks generation and task‑list process; add optional dependencies/priority and parallelizable markers.
- Enhance self‑improvement logs with operational context (elapsed time, token I/O, dependency impact).
- Keep configuration opt‑in via `.cursor/config.json`; default behavior unchanged.
- Maintain repo portability (no external services; docs-first artifacts).
- A changelog per project would be nice.

## 3. User Stories

- As a repo maintainer, I want consistent ERD→plan→tasks artifacts so contributors can onboard quickly.
- As a developer, I want task lists that reflect dependencies/priority so I can safely pick the next task.
- As a product/tech lead, I want reflective learning logs capturing outcomes and bottlenecks to evolve rules.

## 4. Functional Requirements

1. ERD Creation

   - Add explicit uncertainty markers: `[NEEDS CLARIFICATION: …]` when inputs are ambiguous.
   - Include a brief, numbered Clarifications section; resolve or explicitly defer items before `/implement`.
   - Optionally recognize slash‑commands (`/specify`, `/clarify`, `/plan`) in addition to phrase triggers.
   - Output path remains `docs/projects/<feature>/erd.md`.

2. Tasks Generation from ERD

   - Preserve two‑phase flow: parent tasks → wait for “Go” → detailed sub‑tasks.
   - Optional fields: `dependencies: [ids]`, `priority: high|medium|low` per Taskmaster.
   - Optional marker `[P]` for parallelizable tasks per Spec Kit.
   - Maintain `Relevant Files` section and TDD-first guidance.

3. Task List Process

   - Enforce one sub‑task at a time with approval pauses.
   - Respect dependencies and priorities when selecting next work.
   - Maintain commit protocol and “Relevant Files” accuracy.
   - Note: running "process tasks" does not result in the assistant checking off completed tasks; completion remains an explicit, separate step.

4. Spec‑Driven Workflow Integration

   - Document optional slash‑commands: `/specify`, `/clarify`, `/plan`, `/tasks`, `/analyze`, `/implement` (slash takes precedence over phrases when present).
   - Add an analysis gate before implementation (Spec Kit `/analyze`).
   - Cross‑link artifacts (spec/plan/tasks) at file tops.

5. Self‑Improvement Logs

   - Keep current logging approach; add optional “Operation” block: elapsed time, token I/O (if available), units processed.
   - Add “Dependency Impact” notes: which tasks/sections were affected.
   - Respect redaction and fallback directories.

6. Defaults & Configuration

- Defaults remain unchanged by default; features are opt‑in via `.cursor/config.json`.
- Slash‑commands may be enabled as an option; phrase triggers remain supported.
- Tasks may include optional `dependencies`, `priority`, and `[P]` markers.
- Self‑improvement logging retains current behavior; optional Operation/Dependency Impact can be enabled.

7. DEPRECATED - Framework Selection & Scaffolding (Integrated)

   - Configuration: allow choosing Spec‑Driven planning framework via repo config.
     - Example (in `.cursor/config.json`):
       ```json
       {
         "specDriven": {
           "framework": "spec-kit|ai-dev-tasks",
           "projectBaseDir": "docs"
         }
       }
       ```
   - Scaffolding command (docs-level): `/start-project` prompts for project name and framework; supports a temporary `--framework` flag.
   - Monorepo support: nearest `.cursor/config.json` wins for subprojects (no name auto-suggest).
   - Guidance only; no external installs or network required.

8. Deterministic Artifact Templates & Validation (Integrated)

   - Canonical minimal templates for Spec, Plan, and Tasks with sibling cross-links and a machine-checkable Acceptance Bundle.
   - Required headings (minimum):

     ```markdown
     # <feature> Spec

     ## Overview

     ## Goals

     ## Functional Requirements

     ## Acceptance Criteria

     ## Risks/Edge Cases

     [Links: Plan | Tasks]
     ```

     ```markdown
     # <feature> Plan

     ## Steps

     ## Acceptance Bundle

     ## Risks

     [Links: Spec | Tasks]
     ```

     ```markdown
     # Tasks — <feature>

     ## Relevant Files

     ## Todo
     ```

   - Acceptance Bundle keys (Plan): `targets`, `exactChange`, `successCriteria`, optional `constraints`, `runInstructions`; include `ownerSpecs` when JS/TS edits are planned.
   - Default locations (configurable): Specs under `docs/specs/`, Plans under `docs/plans/`, Tasks under `tasks/` (see Project Organization for structure presets and overrides).
   - Validation (optional, local-only): check required headings, sibling links, kebab-case `<feature>` consistency, and presence of `ownerSpecs` for JS/TS.

## 5. Non-Functional Requirements

- Performance: Rule resolution remains fast; no external network calls required.
- Reliability: No change to code build/test processes; artifacts are Markdown only.
- Security/Privacy: Preserve existing redaction in logs; no secrets stored in rules.
- Usability: Outputs remain concise and scannable; junior‑friendly.

## 6. Architecture/Design

- Impacted rules:
  - `create-erd.mdc` (uncertainty markers, optional slash‑command note)
  - `erd-full.md`, `erd-lite.md` (add short Uncertainty/Assumptions subsection)
  - `generate-tasks-from-erd.mdc` (optional fields)
  - `project-lifecycle.mdc` (Task List Process subsection: dependency/priority‑aware next step)
  - `spec-driven.mdc` (slash‑commands, `/analyze` gate, cross‑links)
- Flow: User can choose phrase triggers or slash‑commands. Tasks remain two‑phase with pauses and TDD coupling.

## 7. Data Model and Storage

- Artifacts: `erd.md`, `tasks.md` under `docs/projects/<feature>/`.
- Logs: `assistant-logs/` (default) or configured `logDir`.
- No databases; all text artifacts in repo.

## 8. API/Contracts

- None required. Optional alignment with agent slash‑commands; no runtime API dependencies.

## 9. Integrations/Dependencies

- Inspiration only (no hard dependency):
  - `snarktank/ai-dev-tasks` prompts/templates
  - `github/spec-kit` SDD methodology and slash‑commands
  - `eyaltoledano/claude-task-master` task schema ideas (deps/priority) and progress cues

## 10. Edge Cases and Constraints

- Offline or agents without slash‑commands: phrase triggers remain primary.
- Teams that prefer minimalism can keep new ERD/spec artifacts lightweight.
- Licensing: maintain our rules; do not copy proprietary content verbatim.

## 11. Testing & Acceptance

- Acceptance (docs-level):
  - Creating a new ERD triggers uncertainty markers when prompts are ambiguous.
  - Clarifications section exists; either cleared or explicitly deferred with rationale before `/implement`.
  - Generating tasks (phase 1) yields only parent tasks; phase 2 adds sub‑tasks.
  - Task‑list process enforces one‑sub‑task gating and dependency‑aware next selection (highest‑priority unblocked; tie → shortest critical path).
  - Logging entries include the Operation block (best‑effort) and Dependency Impact.
  - Spec‑driven rule lists slash‑commands and `/analyze` gate.
- Spot checks:
  - Validate rule front‑matter and references compile with our validation script.
  - Dry‑run a demo feature across the three phases and verify artifacts + logs.

## 12. Rollout & Ops

- Phase 0: Update rules with optional sections (no toggles).
- Phase 1: Enable unified defaults in a demo branch; collect feedback; adjust wording.
- Phase 2: Document unified defaults in README.
- Rollback: Not applicable; unified defaults are docs-only.

## 13. Success Metrics

- Time to generate ERD/Tasks reduced (qualitative) with fewer back‑and‑forths.
- Fewer plan/task mismatches reported during execution.
- Increased usage of tasks with dependencies/priority where appropriate.
- Learning logs include concise operational context improving iteration quality.

## 14. Open Questions

- Do these align well with ai-workflow-integration?

```
.cursor/rules/create-erd.mdc
.cursor/rules/erd-full.md
.cursor/rules/erd-lite.mdx
.cursor/rules/generate-tasks-from-erd.mdc
.cursor/rules/project-lifecycle.mdc
.cursor/rules/spec-driven.mdc
.cursor/scripts/erd-validate.sh
.cursor/scripts/project-lifecycle-validate.sh
docs/plans/sample-feature-plan.md
docs/projects/README.md
```

# Engineering Requirements Document — Spec‑Driven Workflow (Lite) — Integrated

Links: `.cursor/rules/spec-driven.mdc` | `docs/projects/ai-workflow-integration/tasks.md` | `docs/projects/split-progress/erd.md`

## 1. Introduction/Overview

Specify the phased workflow: Specify (ERD/spec) → Plan → Tasks, with deterministic artifacts and progress rules.

## 2. Goals/Objectives

- Deterministic artifact templates and cross-links
- Single active sub-task policy with status updates
- Slash commands preference over phrase triggers when both present

## 3. Functional Requirements

- Generate `docs/specs/<feature>-spec.md`, `docs/plans/<feature>-plan.md`, `projects/<feature>/tasks/tasks-<feature>.md`
- Required headings and acceptance bundle schema for Plans
- Phase boundary confirmations unless explicit verbs are used

## 4. Acceptance Criteria

- Templates documented for Spec, Plan, and Tasks
- Acceptance bundle schema present and example provided
- Progress rules and integrations with TDD-first noted

## 5. Risks/Edge Cases

- Over-constraining templates; keep minimal required sections

## 6. Rollout Note

- Owner: rules-maintainers
- Comms: Link from README and progress doc

## 7. Testing

- Create sample trio and validate required sections and cross-links
