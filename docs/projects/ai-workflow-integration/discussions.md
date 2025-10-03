# Discussions

Purpose: Deep-dive notes comparing and integrating:

- ai-dev-tasks (PRD/tasks templates)
- github/spec-kit (SDD + slash commands)
- claude-task-master (task model, progress/logging, research)

Working topics:

- Criteria to compare (setup, slash commands, tasks structure, dependencies, logging)
- Candidate improvements to our rules
- Risks and adoption plan

## Baseline Mapping (Task 1.2)

Setup & Integration

- Our rules are file-based (no runtime deps). Optional slash-commands not yet documented.

Artifacts & Templates

- ERD: `create-erd.mdc` + templates (`erd-full.md`, `erd-lite.md`).
- Tasks: `generate-tasks-from-erd.mdc` (two-phase) + `task-list-process.mdc`.

Tasks Model

- No explicit dependencies/priority in tasks today; single-subtask-at-a-time enforced.

Logging & Progress

- Reflective logs: `assistant-learning-log.mdc` + `logging-protocol.mdc` (strong). No token/time operation block yet.

Licensing & Reuse

- We cite ai-dev-tasks for inspiration. No embedded external content.

Configuration & Toggles

- Feature flags for proposed additions not yet in `.cursor/config.json`.

## Baseline & Scope (Task 1.3)

Scope

- Integrate optional enhancements only; defaults unchanged. No external runtime dependencies.

Anchors

- ERD: `docs/projects/ai-workflow-integration/erd.md`
- Comparison Framework: `docs/projects/ai-workflow-integration/comparison-framework.md`

Unified Workflow

- Slash‑commands are first‑class: `/specify`, `/clarify`, `/plan`, `/tasks`, `/analyze`, `/implement`.
- Tasks include `dependencies`, `priority`, and optional `[P]` for parallelization.
- Learning logs include an Operation block and Dependency Impact by default (values may be N/A if not available).

Out of Scope (initial)

- Implementing agent‑specific installers or CLIs.
- Binding to a single vendor’s workflow beyond optional slash‑commands.

## ai-dev-tasks Evaluation (Task 2.0)

2.1 `create-prd.md`

- Strengths: clear clarifying‑questions discipline; junior‑friendly structure; easy file prompting.
- Gaps vs ours: we already target ERD with engineering sections; action: keep our ERD, borrow the explicit clarifications tone and citation link.

  2.2 `generate-tasks.md`

- Strengths: explicit two‑phase (parents → “Go” → sub‑tasks) matches our model.
- Gaps vs ours: ours already adds TDD emphasis and relevant files; action: no change beyond reaffirming two‑phase flow and citations.

  2.3 `process-task-list.md`

- Strengths: one‑sub‑task‑at‑a‑time with approvals; commit discipline.
- Gaps vs ours: our commit protocol and gates are already stricter; action: keep ours; add a line about dependency/priority‑aware next selection if enabled.

  2.4 Import strategy

- Borrow language and cite sources; keep our rule formats and locations.
- Do not embed external content; link to upstream raw files for provenance.

## Spec Kit Evaluation (Task 3.0)

3.1 `spec-driven.md` and `templates/commands/*`

- Strengths: clear `/constitution`, `/specify`, `/clarify`, `/plan`, `/tasks`, `/analyze`, `/implement` lifecycle; good templates.
- Adoption plan: document these as optional slash‑commands in `spec-driven.mdc` without changing default triggers.

  3.2 Optional slash‑command support in `spec-driven.mdc`

- Proposal: Mention available commands and precedence (slash > phrase), ask one clarifying question on ambiguity.

  3.3 `/analyze` gate

- Add a brief analysis step before `/implement` to validate coverage/consistency across ERD/plan/tasks.

  3.4 `constitution.md` feasibility

- Optional: project‑level principles file under `memory/constitution.md`. Keep as opt‑in; reference if present.

## Taskmaster Evaluation (Task 4.0)

4.1 Task structure (`docs/task-structure.md`)

- Pros: explicit `dependencies`, `priority`, `subtasks`, `testStrategy`; tagged task lists; next‑task selection.
- Adoption: add optional `dependencies: []` and `priority: high|medium|low` fields to our tasks output; optionally allow `[P]` parallelizable tag.

  4.2 Minimal additions to `generate-tasks-from-erd.mdc`

- Keep two‑phase flow; add a short optional note explaining deps/priority fields and when to use them.

  4.3 Operational metrics patterns (`src/progress/*`, `mcp-server/src/logger.js`)

- Idea: enhance assistant learning logs with an “Operation” block capturing elapsed time and token I/O (if agent exposes), mirroring progress bars’ utility without runtime coupling.

  4.4 Logging enhancements

- Add “Operation” (elapsed, token I/O, units processed) and “Dependency Impact” to our log schema; retain redaction and fallback behavior.

## Stakeholder Review (Task 6.2)

Summary

- Unified flow is coherent: ERD → Plan → Tasks → Analyze → Implement with slash‑commands first‑class.
- Tasks standardize `dependencies`, `priority`, and optional `[P]` for parallelization.
- Logging protocol clarified: prefer `assistant-logs/`, fallback with reason noted, write via `alp-logger.sh`.
- Routing/behavior tightened: soft phrasing is plan‑only; add preflight/tooling‑first and verification‑before‑assertion checks.

Wording tweaks to apply (tracked and/or done)

- `create-erd.mdc`: consolidate `[NEEDS CLARIFICATION]` list before generation; ensure writes stay under `docs/projects/<feature>/`.
- `spec-driven.mdc`: note slash‑command precedence; Analyze must list discrepancies or “No discrepancies found”.
- `generate-tasks-from-erd.mdc`: when dependencies exist, propose only ready tasks; prefer highest priority.
- `task-list-process.mdc`: gate next sub‑task on commit protocol completion; explicit dependency/priority next‑selection.
- `logging-protocol.mdc`: explicit Operation block even if values N/A; example usage of `alp-logger.sh`.
- `intent-routing.mdc`: soft‑phrase safeguard; scope confirmation for repo‑wide edits.
- `assistant-behavior.mdc`: micro‑checks to announce tool and paste validator output before asserting status.
- `favor-tooling.mdc`: add preflight checklist and example for logging via `alp-logger.sh`.

## Adoption Plan

Phased rollout

- Announce unified workflow in README (done) with links to rules and example at `docs/projects/_examples/unified-flow/`.
- Keep unified wording changes; remove any legacy mentions in future edits rather than bulk-removal now.
- Use unified flow on the next new feature to validate end-to-end, then confirm as default in team comms.

Operational notes

- Slash-commands are first-class; Analyze is mandatory before implement.
- Tasks must include `dependencies`/`priority` where relevant; use `[P]` only when truly parallelizable.
- Logs: default to `assistant-logs/`; if fallback used, note reason in entry; write via `alp-logger.sh`.

Review window

- 1–2 days for feedback; collect refinements and schedule a light follow-up pass if needed.
