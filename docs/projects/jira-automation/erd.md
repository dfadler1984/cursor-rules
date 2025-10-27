---
status: active
owner: dfadler1984
lastUpdated: 2025-10-14
---

# Engineering Requirements Document — Jira Automation


Mode: Lite

## 1. Introduction/Overview

Standalone shell scripts for local Jira automation via REST API. Focus on issue lifecycle management: create, update, transition, and comment on issues.

## 2. Goals/Objectives

- Create Jira issues programmatically
- Update issue fields (summary, description, assignee, labels, etc.)
- Transition issues through workflow states
- Add comments to issues
- Provide composable, single-purpose scripts following Unix Philosophy
- Use Jira REST API directly (no MCP dependency)

## 3. Functional Requirements

### 3.1 Issue Creation

- **jira-issue-create.sh**: Create a new issue
  - Inputs: project key, issue type, summary, optional description/fields
  - Output: issue key and URL on success
  - Support custom fields via `--field name=value` repeatable flag
  - Exit codes: 0 success, 1 API error, 2 validation error

### 3.2 Issue Updates

- **jira-issue-update.sh**: Update existing issue fields

  - Inputs: issue key, field updates (summary, description, assignee, labels, priority, etc.)
  - Output: issue key and updated fields confirmation
  - Support multiple field updates in one call
  - Exit codes: 0 success, 1 API error, 2 validation error

- **jira-issue-get.sh**: Retrieve issue details
  - Inputs: issue key
  - Output: issue metadata and fields (JSON or plain text)
  - Optional `--fields` filter to limit output
  - Exit codes: 0 success, 1 not found, 2 API error

### 3.3 Issue Transitions

- **jira-issue-transition.sh**: Move issue through workflow

  - Inputs: issue key, target state or transition ID
  - Output: new status and transition confirmation
  - Auto-detect available transitions if target state provided
  - Exit codes: 0 success, 1 invalid transition, 2 API error

- **jira-issue-transitions-list.sh**: List available transitions for an issue
  - Input: issue key
  - Output: transition IDs, names, and target states (JSON or plain text)
  - Exit codes: 0 success, 1 not found, 2 API error

### 3.4 Comments

- **jira-issue-comment.sh**: Add comment to an issue
  - Inputs: issue key, comment body
  - Output: comment ID on success
  - Exit codes: 0 success, 1 API error, 2 validation error

### 3.5 Common Helpers

- **jira-auth.sh**: Helper for authentication token management

  - Read from `JIRA_TOKEN` and `JIRA_URL` env vars
  - Validate token and base URL
  - Source-able by other scripts

- **jira-api.sh**: Low-level REST API wrapper
  - Common API calls (GET, POST, PUT)
  - Error handling and response parsing
  - Source-able library functions

## 4. Non-Functional Requirements

### 4.1 Unix Philosophy Compliance

- Single responsibility per script (< 150 lines target, warn at 200, fail at 300)
- Results to stdout, logs to stderr
- Composable via pipes and exit codes
- Non-interactive by default (all inputs via flags/env)
- `--help` and `--version` support

### 4.2 Security

- Never log or echo authentication tokens
- Use `JIRA_TOKEN` environment variable (not CLI args)
- Validate inputs to prevent injection

### 4.3 Error Handling

- Meaningful error messages with context
- Consistent exit codes across all scripts
- Network failure handling and retries (optional `--retry` flag)
- Graceful handling of invalid transitions and field validation errors

### 4.4 Testing

- Each script has colocated `.test.sh` spec
- Behavior tests with mocked API responses
- TDD workflow (Red → Green → Refactor)

## 5. Acceptance Criteria

- [ ] All scripts under `.cursor/scripts/` with `jira-` prefix
- [ ] Each script has `--help`, `--version`, and follows exit code conventions
- [ ] All scripts < 150 lines (single responsibility)
- [ ] Common auth/API logic extracted to source-able helpers
- [ ] Each script has passing colocated tests
- [ ] README with usage examples and composition patterns
- [ ] No authentication tokens in logs or error messages

## 6. Technical Constraints

- Bash 4+ (macOS ships with 3.2, so prefer portable constructs or document requirement)
- Jira Cloud REST API v3 preferred (v2 fallback if needed)
- Dependencies: `curl`, `jq` for JSON parsing
- Authentication: Personal Access Token or API token via env var

## 7. Dependencies

- Jira Cloud instance with API access
- `curl` for HTTP requests
- `jq` for JSON parsing/manipulation
- `.cursor/scripts/.lib.sh` for shared helpers (strict mode, logging, error handling)

## 8. Success Metrics

- Scripts successfully create/update issues in test Jira project
- Transitions work correctly across workflow states
- Comments posted successfully
- All tests passing
- Scripts composable in pipelines (e.g., create issue → transition → comment)
- Zero token leaks in logs or output

## 9. Out of Scope (for initial version)

- Bulk operations (batch create/update multiple issues)
- JQL search functionality (defer to future iteration)
- Project management (create/delete projects)
- Sprint management (Scrum/Kanban operations)
- Attachment handling
- Advanced custom field types (beyond text/number/select)
- Interactive prompts or TUI interfaces
- Issue linking (may add in future iteration)

## 10. References

- [Jira Cloud REST API Documentation](https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/)
- [`.cursor/rules/shell-unix-philosophy.mdc`](../../../.cursor/rules/shell-unix-philosophy.mdc)
- [`.cursor/scripts/.lib.sh`](../../../.cursor/scripts/.lib.sh) — Shared script helpers
