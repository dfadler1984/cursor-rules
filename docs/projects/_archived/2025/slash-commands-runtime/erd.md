---
status: completed
owner: rules-maintainers
lastUpdated: 2025-10-23
---

# Engineering Requirements Document — Slash Commands Runtime (Lite)

Links: `.cursor/rules/intent-routing.mdc` | `docs/projects/slash-commands-runtime/tasks.md` | `docs/projects/intent-router/` (archived)

## 1. Introduction/Overview

Implement runtime execution semantics for slash commands beyond documentation, enabling `/plan`, `/tasks`, and `/pr` to trigger workflows with proper consent gates and state management.

## 2. Goals/Objectives

- Define execution semantics for documented slash commands (`/plan`, `/tasks`, `/pr`)
- Implement consent gates and non-interactive execution where appropriate
- Provide clear success/error feedback for each command
- Enable composable workflows (e.g., `/plan X` followed by `/tasks` from that plan)

## 3. Functional Requirements

### 3.1 Slash Command Parsing

- Detect slash commands at message start: `/command [args]`
- Parse command name and arguments with proper escaping
- Provide helpful error messages for unknown commands or invalid syntax

### 3.2 Supported Commands

**`/plan <topic>`**

- Route to `spec-driven.mdc`
- Request consent before creating files
- Produce plan scaffold under `docs/plans/` or project-specific location
- Output: plan file path and next steps

**`/tasks`**

- Route to `project-lifecycle.mdc` (Task List Process)
- Detect current project context from open files or require explicit project arg
- Manage/update tasks non-interactively when safe (mark complete, add items)
- Output: tasks updated confirmation and summary

**`/pr [options]`**

- Route to `assistant-git-usage.mdc`
- Use `.cursor/scripts/pr-create.sh` with non-interactive flags
- Request consent with exact command before execution
- Support: `--title`, `--body`, `--base`, `--head` flags
- Output: PR URL or fallback compare URL

### 3.3 State Management

- Track active workflows (e.g., plan created, ready for tasks generation)
- Provide context hints for next logical command
- Clear workflow state on completion or explicit reset

### 3.4 Error Handling

- Unknown command → suggest closest match or list available commands
- Missing required args → print usage for that command
- Execution failures → surface script exit codes and error messages clearly

## 4. Acceptance Criteria

- Each command (`/plan`, `/tasks`, `/pr`) executable with documented args
- Consent requested before file creation or external commands
- Error messages are actionable and include usage hints
- Integration tests validate command parsing → execution → output
- Documentation updated in `intent-routing.mdc` with runtime behavior notes

## 5. Risks/Edge Cases

- Ambiguous context for `/tasks` (multiple projects open) → require explicit project arg
- Concurrent workflow state conflicts → prefer stateless execution; only track minimal hints
- `/pr` failures due to missing `GITHUB_TOKEN` → clear error with setup guidance

## 6. Rollout Note

- Owner: rules-maintainers
- Comms: Update `intent-routing.mdc` with runtime semantics section
- Dependencies: Blocked on completion of `role-phase-mapping` and `split-progress` for automated enforcement (optional enhancement)

## 7. Testing

**Unit-level (parsing)**

- `/plan checkout flow` → parsed as command="plan", args=["checkout", "flow"]
- `/tasks` → command="tasks", args=[]
- `/pr --title "Fix bug"` → command="pr", args=["--title", "Fix bug"]
- `/unknown` → error with suggestion

**Integration (execution)**

- `/plan test-feature` → creates `docs/plans/test-feature.md` after consent
- `/tasks` (in project context) → updates task checkboxes
- `/pr --title "Test" --body "Description"` → calls pr-create.sh with consent

**Error paths**

- `/plan` (no topic) → usage error
- `/pr` (no GITHUB_TOKEN) → clear setup guidance
- `/tasks` (ambiguous context) → request project arg

---

Owner: rules-maintainers

Spun off from: `docs/projects/intent-router/` (archived 2025-10-11)
