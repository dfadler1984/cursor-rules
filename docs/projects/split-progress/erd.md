---
---

## ERD Split Progress

### Index

| ERD                                                                | Owner              | Status        | Tasks                                                              | Dependencies             |
| ------------------------------------------------------------------ | ------------------ | ------------- | ------------------------------------------------------------------ | ------------------------ |
| `docs/projects/core-values/erd.md`                                 | rules-maintainers  | New (drafted) | `docs/projects/core-values/tasks.md`                               | —                        |
| `docs/projects/intent-router/erd.md`                               | rules-maintainers  | New (drafted) | `docs/projects/intent-router/tasks.md`                             | core-values              |
| `docs/projects/roles/erd.md`                                       | rules-maintainers  | In progress   | `docs/projects/roles/tasks.md`                                     | core-values              |
| `docs/projects/ai-workflow-integration/erd.md`                     | rules-maintainers  | In progress   | `docs/projects/ai-workflow-integration/tasks.md`                   | intent-router, tdd-first |
| `docs/projects/deterministic-outputs/erd.md`                       | rules-maintainers  | In progress   | `docs/projects/deterministic-outputs/tasks.md`                     | spec-driven              |
| `docs/projects/rule-maintenance/erd.md`                            | rules-maintainers  | New (drafted) | `docs/projects/rule-maintenance/tasks.md`                          | deterministic-outputs    |
| `docs/projects/rules-validate-script/erd.md`                       | rules-maintainers  | Lite ERD      | `docs/projects/rule-maintenance/tasks.md`                          | rule-maintenance         |
| `docs/projects/tdd-first/erd.md`                                   | rules-maintainers  | New (drafted) | `docs/projects/tdd-first/tasks.md`                                 | core-values              |
| `docs/projects/_archived/2025/assistant-learning/final-summary.md` | rules-maintainers  | Complete      | `docs/projects/_archived/2025/assistant-learning/final-summary.md` | core-values              |
| `docs/projects/_archived/2025/logging-destinations/erd.md`         | assistant-learning | Archived      | —                                                                  | —                        |
| `docs/projects/capabilities-rules/erd.md`                          | rules-maintainers  | Active        | `docs/projects/capabilities-rules/tasks.md`                        | core-values              |
| `docs/projects/mcp-synergy/erd.md`                                 | rules-maintainers  | In progress   | `docs/projects/mcp-synergy/tasks.md`                               | capabilities-discovery   |
| `docs/projects/bash-scripts/erd.md`                                | rules-maintainers  | New (drafted) | `docs/projects/bash-scripts/tasks.md`                              | core-values              |
| `docs/projects/shell-scripts/erd.md`                               | eng-tools          | Complete      | `docs/projects/shell-scripts/tasks.md`                             | bash-scripts             |
| `docs/projects/project-organization/erd.md`                        | rules-maintainers  | Proposed      | —                                                                  | core-values              |
| `docs/projects/portability/erd.md`                                 | rules-maintainers  | In progress   | `docs/projects/portability/tasks.md`                               | project-organization     |
| `docs/projects/collaboration-options/erd.md`                       | rules-maintainers  | New (drafted) | `docs/projects/collaboration-options/tasks.md`                     | core-values              |
| `docs/projects/framework-selection/erd.md`                         | rules-maintainers  | New (drafted) | `docs/projects/framework-selection/tasks.md`                       | —                        |
| `docs/projects/role-phase-mapping/erd.md`                          | rules-maintainers  | New (drafted) | `docs/projects/role-phase-mapping/tasks.md`                        | roles                    |
| `docs/projects/git-usage/erd.md`                                   | rules-maintainers  | New (drafted) | `docs/projects/git-usage/tasks.md`                                 | core-values              |

- Tasks: `docs/projects/split-progress/tasks.md`

- **Source ERD (reference only)**: `docs/projects/rules-grok-alignment/erd.md`

  - **Status**: Being decomposed into separate ERDs; keep for historical context and remaining ideas.

- **Assistant Self-Improvement (replaces ALP)**: `docs/projects/assistant-self-improvement/erd.md`

  - **Status**: Planning

- **Deterministic, Structured Outputs**: `docs/projects/deterministic-outputs/erd.md`

  - **Tasks**: `docs/projects/deterministic-outputs/tasks.md`
  - **Status**: In progress (validator prototype & rollout items open)

- **Shell Scripts Suite**: `docs/projects/shell-scripts/erd.md`

  - **Tasks**: `docs/projects/shell-scripts/tasks.md`
  - **Status**: Complete

- **Portability and Paths**: `docs/projects/portability/erd.md`

  - **Tasks**: `docs/projects/portability/tasks.md`
  - **Status**: In progress (examples and cross-links added)

- **MCP Synergy**: `docs/projects/mcp-synergy/erd.md`

  - **Tasks**: `docs/projects/mcp-synergy/tasks.md`
  - **Status**: In progress (discovery/execution examples added)

- **Roles & Intent Routing**: `docs/projects/roles/erd.md`

  - **Tasks**: `docs/projects/roles/tasks.md`
  - **Status**: In progress (examples and links added)

- **Capabilities Rules**: `docs/projects/capabilities-rules/erd.md`

  - **Tasks**: `docs/projects/capabilities-rules/tasks.md`
  - **Status**: New (drafted)

- **Spec‑Driven Workflow (integrated)**: `docs/projects/ai-workflow-integration/erd.md`

  - **Tasks**: `docs/projects/ai-workflow-integration/tasks.md`
  - **Status**: In progress (filled templates and bundle example)

- **TDD‑First**: `docs/projects/tdd-first/erd.md`

  - **Tasks**: `docs/projects/tdd-first/tasks.md`
  - **Status**: New (drafted)

- **Core Values**: `docs/projects/core-values/erd.md`

  - **Tasks**: `docs/projects/core-values/tasks.md`
  - **Status**: New (drafted)

- **Productivity & Automation**: `docs/projects/productivity/erd.md`

  - **Tasks**: `docs/projects/productivity/tasks.md`
  - **Status**: New (drafted)

- **Rule Maintenance & Validator**: `docs/projects/rule-maintenance/erd.md`

  - **Tasks**: `docs/projects/rule-maintenance/tasks.md`
  - **Status**: New (drafted)

- **Collaboration Options**: `docs/projects/collaboration-options/erd.md`

  - **Tasks**: `docs/projects/collaboration-options/tasks.md`
  - **Status**: New (drafted)

- **Intent Router**: `docs/projects/intent-router/erd.md`

  - **Tasks**: `docs/projects/intent-router/tasks.md`
  - **Status**: New (drafted)

- **Framework Selection**: `docs/projects/framework-selection/erd.md`

  - **Tasks**: `docs/projects/framework-selection/tasks.md`
  - **Status**: New (drafted)

- **Role–Phase Mapping**: `docs/projects/role-phase-mapping/erd.md`

  - **Tasks**: `docs/projects/role-phase-mapping/tasks.md`
  - **Status**: New (drafted)

- **Git Usage via MCP**: `docs/projects/git-usage/erd.md`

  - **Tasks**: `docs/projects/git-usage/tasks.md`
  - **Status**: New (drafted)

Notes:

- As new ERDs are created from the source doc, add them here with a link and create a `tasks/tasks-<feature>.md` file to track progress.
