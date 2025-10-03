---
---

## ERD Split Progress

### Index

| ERD                                      | Owner              | Status        | Tasks                                                                       | Dependencies             |
| ---------------------------------------- | ------------------ | ------------- | --------------------------------------------------------------------------- | ------------------------ |
| `docs/projects/core-values/erd.md`            | rules-maintainers  | New (drafted) | `docs/projects/core-values/tasks.md`                       | —                        |
| `docs/projects/intent-router/erd.md`          | rules-maintainers  | New (drafted) | `docs/projects/intent-router/tasks.md`                   | core-values              |
| `docs/projects/roles/erd.md`                  | rules-maintainers  | In progress   | `docs/projects/roles/tasks.md`                                   | core-values              |
| `docs/projects/spec-driven/erd.md`            | rules-maintainers  | In progress   | `docs/projects/spec-driven/tasks.md`                       | intent-router, tdd-first |
| `docs/projects/deterministic-outputs/erd.md`  | rules-maintainers  | In progress   | `docs/projects/deterministic-outputs/tasks.md`   | spec-driven              |
| `docs/projects/rule-maintenance/erd.md`       | rules-maintainers  | New (drafted) | `docs/projects/rule-maintenance/tasks.md`             | deterministic-outputs    |
| `docs/projects/rules-validate-script/erd.md`  | rules-maintainers  | Lite ERD      | `docs/projects/rule-maintenance/tasks.md`             | rule-maintenance         |
| `docs/projects/tdd-first/erd.md`              | rules-maintainers  | New (drafted) | `docs/projects/tdd-first/tasks.md`                           | core-values              |
| `docs/projects/assistant-learning/erd.md`     | rules-maintainers  | Complete      | `docs/projects/assistant-learning/tasks.md`         | core-values              |
| `docs/projects/logging-destinations/erd.md`   | assistant-learning | Draft         | —                                                                           | assistant-learning       |
| `docs/projects/capabilities-discovery/erd.md` | rules-maintainers  | New (drafted) | `docs/projects/capabilities-discovery/tasks.md` | core-values              |
| `docs/projects/mcp-synergy/erd.md`            | rules-maintainers  | In progress   | `docs/projects/mcp-synergy/tasks.md`                       | capabilities-discovery   |
| `docs/projects/bash-scripts/erd.md`           | rules-maintainers  | New (drafted) | `docs/projects/bash-scripts/tasks.md`                     | core-values              |
| `docs/projects/shell-scripts/erd.md`          | eng-tools          | Complete      | `docs/projects/shell-scripts/tasks.md`                   | bash-scripts             |
| `docs/projects/project-organization/erd.md`   | rules-maintainers  | Proposed      | —                                                                           | core-values              |
| `docs/projects/portability/erd.md`            | rules-maintainers  | In progress   | `docs/projects/portability/tasks.md`                       | project-organization     |
| `docs/projects/collaboration-options/erd.md`  | rules-maintainers  | New (drafted) | `docs/projects/collaboration-options/tasks.md`   | core-values              |
| `docs/projects/drawing-board/erd.md`          | rules-maintainers  | New (drafted) | `docs/projects/drawing-board/tasks.md`                   | core-values              |
| `docs/projects/framework-selection/erd.md`    | rules-maintainers  | New (drafted) | `docs/projects/framework-selection/tasks.md`       | —                        |
| `docs/projects/role-phase-mapping/erd.md`     | rules-maintainers  | New (drafted) | `docs/projects/role-phase-mapping/tasks.md`         | roles                    |
| `docs/projects/git-usage/erd.md`              | rules-maintainers  | New (drafted) | `docs/projects/git-usage/tasks.md`                           | core-values              |

- Tasks: `docs/projects/split-progress/tasks.md`

- **Source ERD (reference only)**: `docs/projects/rules-grok-alignment/erd.md`

  - **Status**: Being decomposed into separate ERDs; keep for historical context and remaining ideas.

- **Assistant Learning Protocol (ALP)**: `docs/projects/assistant-learning/erd.md`

  - **Tasks**: `docs/projects/assistant-learning/tasks.md`
  - **Status**: Complete (optional MCP backends deferred)

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

- **Capabilities Discovery**: `docs/projects/capabilities-discovery/erd.md`

  - **Tasks**: `docs/projects/capabilities-discovery/tasks.md`
  - **Status**: New (drafted)

- **Spec‑Driven Workflow**: `docs/projects/spec-driven/erd.md`

  - **Tasks**: `docs/projects/spec-driven/tasks.md`
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

- **Drawing Board (Ideation/Prototyping)**: `docs/projects/drawing-board/erd.md`

  - **Tasks**: `docs/projects/drawing-board/tasks.md`
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

- **Bash Script Standards**: `docs/projects/bash-scripts/erd.md`

  - **Tasks**: `docs/projects/bash-scripts/tasks.md`
  - **Status**: New (drafted)

Notes:

- As new ERDs are created from the source doc, add them here with a link and create a `tasks/tasks-<feature>.md` file to track progress.
