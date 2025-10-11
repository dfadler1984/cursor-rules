---
title: Assistant Self-Improvement (Ground-Up Redesign)
owner: repo-maintainers
status: planning
start: 2025-10-11
last: 2025-10-11
tags: [assistant, self-improvement, redesign, deprecation]
---

# Context

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

# Acceptance Criteria

- Legacy materials migrated to `docs/projects/assistant-self-improvement/legacy/`.
- References to Assistant Learning and ALP scripts removed from files outside this project.
- `tasks.md` reflects the migration and outlines next steps for the redesign.

# Risks & Mitigations

- Wide-scope edits may break references: mitigate by repo-wide search and targeted removals.
- Script path changes: scripts are archived and no longer referenced outside this project.

# Open Questions

- What minimal subset of signals should the new system capture?
- Where should integration points live to keep effects isolated?


