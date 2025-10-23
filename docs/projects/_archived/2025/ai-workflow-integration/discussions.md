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

- Our rules are file-based (no runtime deps). Slash-commands are now first-class with phrase fallbacks.

Artifacts & Templates

- ERD: `create-erd.mdc` + templates (`erd-full.md`, `erd-lite.md`).
- Tasks: `generate-tasks-from-erd.mdc` (two-phase) + `project-lifecycle.mdc` (Task List Process subsection).

Tasks Model

- No explicit dependencies/priority in tasks today; single-subtask-at-a-time enforced.

Logging & Progress

- Reflective logs: `assistant-learning.mdc` (authoritative). Operation/Dependency Impact captured.

Licensing & Reuse

- We cite ai-dev-tasks for inspiration. No embedded external content.

Unified Defaults

- All workflow enhancements are now standardized (no configuration needed).

## Baseline & Scope (Task 1.3)

Scope

- Integrate optional enhancements only; defaults unchanged. No external runtime dependencies.

Anchors

- ERD: `docs/projects/ai-workflow-integration/erd.md`
- Comparison Framework: `docs/projects/ai-workflow-integration/comparison-framework.md`

Unified Workflow

- Slash‑commands are first‑class: `/constitution`, `/specify`, `/clarify`, `/plan`, `/tasks`, `/analyze`, `/implement` (slash > phrase precedence).
- Tasks include `dependencies`, `priority`, and `[P]` for parallelization (different‑file tasks only; group safe parallel sets in tasks.md).
- Learning logs include Operation block and Dependency Impact by default (values may be N/A if not available).

Out of Scope

- Implementing agent‑specific installers or CLIs.
- Binding to a single vendor's workflow (slash‑commands remain agent-agnostic).

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

  3.2 Slash‑command support in `spec-driven.mdc`

- Implemented: Commands documented with precedence (slash > phrase), clarifying questions on ambiguity.

  3.3 `/analyze` gate

- Add a brief analysis step before `/implement` to validate coverage/consistency across ERD/plan/tasks. Trigger expansion when shared‑file coupling is high or sub‑task count > N; record "why expand".

  3.4 `constitution.md` feasibility

- Optional: project‑level principles file under `memory/constitution.md`. Keep as opt‑in; reference if present.

## Taskmaster Evaluation (Task 4.0)

4.1 Task structure (`docs/task-structure.md`)

- Pros: explicit `dependencies`, `priority`, `subtasks`, `testStrategy`; tagged task lists; next‑task selection.
- Adoption: added `dependencies: []` and `priority: high|medium|low` fields to tasks output; `[P]` parallelizable tag included.

  4.2 Additions to `generate-tasks-from-erd.mdc`

- Kept two‑phase flow; added standard deps/priority fields and usage guidance. Defined next‑task selection: highest‑priority unblocked; tie → shortest critical path.

  4.3 Operational metrics patterns (`src/progress/*`, `mcp-server/src/logger.js`)

- Idea: enhance assistant learning logs with an “Operation” block capturing elapsed time and token I/O (if agent exposes), mirroring progress bars’ utility without runtime coupling.

  4.4 Logging enhancements

- Added "Operation" (elapsed, token I/O, units processed) and "Dependency Impact" to log schema; retained redaction and fallback behavior.

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
- `project-lifecycle.mdc` (Task List Process): gate next sub‑task on commit protocol completion; explicit dependency/priority next‑selection.
- `assistant-learning.mdc`: explicit Operation block even if values N/A; example usage of `alp-logger.sh`.
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

## Logging Enhancements (Protocol updates)

Summary

- Always-on learning logs; consent-aware; redaction enforced.
- Persist to `assistant-logs/` (default), fallback to `docs/assistant-learning-logs/` with a one-line reason when used.
- Add Operation and Dependency Impact sections to each entry.
- Extend improvement triggers and capture signals derived from Taskmaster’s `self_improve.mdc`.

Triggers (expanded)

- NewPattern≥3 | RepeatedFeedback | CommonBug | NewLibrary | EmergingPractice | CoverageSignal
- Existing: TDD Red/Green, Task Completed, Analyze Completed, Rule Added/Updated, Routing Corrected, Safety Near-Miss

Schema additions

- ImprovementTrigger: one of the expanded triggers above
- Signals: concrete evidence (file paths, PR reviews, links)
- PatternSummary: 1–2 lines describing the recognized pattern/gap
- Scope: files=n, modules=n
- Decision: AddRule | ModifyRule | DeprecateRule
- QualityCheck: actionable/specific, current refs, consistent enforcement (quick pass/fail note)
- References: upstream docs/links used
- ReviewAfter: YYYY-MM-DD (schedule follow-up)
- Operation: Elapsed, TokenIn, TokenOut, Units; optional SamplesReviewed, CoverageDelta
- Dependency Impact: RulesAffected, DocsAffected, AffectedTasks, Unblocked, Added/Removed
- Research Notes: one‑line summary when research ping used before a risky sub‑task

Storage & persistence

- Primary: `assistant-logs/` per `.cursor/config.json: logDir`
- Fallback (non-writable primary): `docs/assistant-learning-logs/` with a one-line fallback reason noted in the entry

Example
Timestamp: 2025-10-03T14:12:01Z
Event: Analyze Completed
Owner: ai-workflow-integration
What Changed: Verified ERD→Spec coverage; flagged 1 gap and 2 [P] tasks
Next Step: Fill spec for FR-3 and reprioritize tasks by effort
Links: docs/projects/ai-workflow-integration/erd.md
Learning: Coverage map up-front avoids rework later

ImprovementTrigger: EmergingPractice
Signals:

- docs/projects/.../discussions.md (3 mentions)
- PR reviews citing task selection issues
  PatternSummary: Prefer ready + high-priority tasks; mark [P] when coupling is low
  Scope: files=2, modules=1
  Decision: ModifyRule
  QualityCheck: actionable ✅ current refs ✅ consistent ✅
  References: spec-kit/spec-driven.md, ai-dev-tasks/generate-tasks.md
  ReviewAfter: 2025-10-17

Operation:

- Elapsed: 3m12s
- TokenIn: N/A
- TokenOut: N/A
- Units: 2 rules updated
- SamplesReviewed: 5
- CoverageDelta: N/A

Dependency Impact:

- RulesAffected: .cursor/rules/generate-tasks-from-erd.mdc, .cursor/rules/task-list-process.mdc
- DocsAffected: docs/projects/ai-workflow-integration/tasks.md
- AffectedTasks: 2.0, 5.0
- Unblocked: 3.0
- Added/Removed: N/A

## Todos

- [ ] Deep dive claude-task-master `.cursor/rules/` and extract self-improvement/logging patterns
- [ ] Review `ai-dev-tasks/create-prd.md` and capture reusable ERD/spec prompts
- [ ] Ensure our spec workflow aligns with `spec-kit/spec-driven.md` (routing, phases, analyze gate)
