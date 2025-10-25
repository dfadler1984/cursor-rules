---
status: planning
owner: repo-maintainers
created: 2025-10-11
lastUpdated: 2025-10-11
---

# Engineering Requirements Document — Assistant Self-Improvement (Ground-Up Redesign)

Mode: Lite

We are deactivating legacy Assistant Learning (ALP) rules and scripts and rethinking assistant self-improvement from first principles. The previous design coupled logging, triggers, and enforcement tightly to repo rules. This project will design a simpler, opt-in, testable system with clear boundaries.

# Goals

- Minimize coupling: self-improvement mechanisms should not be entangled with unrelated rules.
- Make behavior explicit: small, composable primitives instead of monoliths.
- Testability first: deterministic behavior with clear seams for effects.
- Opt-in adoption: projects can enable features without repo-wide coupling.

# Non-Goals

- No auto-editing of repo files outside explicit commands.
- No background daemons or long-lived processes.

# Scope

- Deactivate and archive legacy Assistant Learning rule files and ALP scripts under this project's `legacy/` folder.
- Define a proposal for the next-generation self-improvement mechanism.
- Evaluate and implement one of two approaches: rule-adoption (current) or pivot to alternatives.

## Nested Sub-Projects

This umbrella project coordinates two alternative implementation approaches:

1. **Rule Adoption** (`approaches/rule-adoption/`)

   - Status: Draft
   - Scope: Adopt pattern-based rule improvements with always-on observation
   - Links: [`approaches/rule-adoption/erd.md`](approaches/rule-adoption/erd.md), [`approaches/rule-adoption/tasks.md`](approaches/rule-adoption/tasks.md)

2. **Pivot Alternatives** (`approaches/pivot-alternatives/`)
   - Status: Deferred (contingency plan)
   - Scope: Alternative approaches if rule-adoption proves problematic
   - Links: [`approaches/pivot-alternatives/erd.md`](approaches/pivot-alternatives/erd.md), [`approaches/pivot-alternatives/tasks.md`](approaches/pivot-alternatives/tasks.md)

# Acceptance Criteria

## Phase 1: Legacy Cleanup

- Legacy materials migrated to `docs/projects/assistant-self-improvement/legacy/`.
- References to Assistant Learning and ALP scripts removed from files outside this project.
- `tasks.md` reflects the migration and outlines next steps for the redesign.

## Phase 2: Approach Selection & Implementation

- **Rule-adoption approach completed** OR pivot triggers detected and alternative selected
- If rule-adoption: All Phase 1-4 acceptance criteria met (see [`approaches/rule-adoption/erd.md`](approaches/rule-adoption/erd.md))
- If pivot: Alternative approach implemented and validated per pivot ERD

## Overall Completion

- ✅ One approach fully implemented and validated
- ✅ Pattern observation working (always-on or alternative mode)
- ✅ Proposal surfacing working at natural checkpoints
- ✅ Consent-first behavior preserved

# Risks & Mitigations

- Wide-scope edits may break references: mitigate by repo-wide search and targeted removals.
- Script path changes: scripts are archived and no longer referenced outside this project.

# Open Questions

- What minimal subset of signals should the new system capture?
- Where should integration points live to keep effects isolated?
