---
status: active
owner: dfadler1984
lastUpdated: 2025-10-14
---

# Engineering Requirements Document — Confluence Automation

Links: [`tasks.md`](./tasks.md)

Mode: Lite

## 1. Introduction/Overview

Standalone shell scripts for local Confluence automation via REST API. Focus on page maintenance (create/update) and change notifications to users.

## 2. Goals/Objectives

- Create and update Confluence pages programmatically
- Notify users when pages are created or updated
- Provide composable, single-purpose scripts following Unix Philosophy
- Use Confluence REST API directly (no MCP dependency)

## 3. Functional Requirements

### 3.1 Page Management

- **confluence-page-create.sh**: Create a new page in a space

  - Inputs: space key, title, body (markdown or storage format), optional parent page ID
  - Output: page ID and URL on success
  - Exit codes: 0 success, 1 API error, 2 validation error

- **confluence-page-update.sh**: Update an existing page

  - Inputs: page ID, new body, optional title
  - Output: updated page version and URL
  - Handles versioning automatically (increment)
  - Exit codes: 0 success, 1 API error, 2 validation error

- **confluence-page-get.sh**: Retrieve page content
  - Inputs: page ID or space key + title
  - Output: page metadata and content (JSON or plain text)
  - Exit codes: 0 success, 1 not found, 2 API error

### 3.2 Change Notifications

- **confluence-notify.sh**: Notify users about page changes
  - Inputs: page ID, user account IDs (comma-separated), notification message
  - Mechanism: add watchers and/or post a comment mentioning users
  - Output: notification status (success/failure per user)
  - Exit codes: 0 all succeeded, 1 partial failure, 2 complete failure

### 3.3 Common Helpers

- **confluence-auth.sh**: Helper for authentication token management

  - Read from `CONFLUENCE_TOKEN` and `CONFLUENCE_URL` env vars
  - Validate token and base URL
  - Source-able by other scripts

- **confluence-api.sh**: Low-level REST API wrapper
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
- Use `CONFLUENCE_TOKEN` environment variable (not CLI args)
- Validate inputs to prevent injection

### 4.3 Error Handling

- Meaningful error messages with context
- Consistent exit codes across all scripts
- Network failure handling and retries (optional `--retry` flag)

### 4.4 Testing

- Each script has colocated `.test.sh` spec
- Behavior tests with mocked API responses
- TDD workflow (Red → Green → Refactor)

## 5. Acceptance Criteria

- [ ] All scripts under `.cursor/scripts/` with `confluence-` prefix
- [ ] Each script has `--help`, `--version`, and follows exit code conventions
- [ ] All scripts < 150 lines (single responsibility)
- [ ] Common auth/API logic extracted to source-able helpers
- [ ] Each script has passing colocated tests
- [ ] README with usage examples and composition patterns
- [ ] No authentication tokens in logs or error messages

## 6. Technical Constraints

- Bash 4+ (macOS ships with 3.2, so prefer portable constructs or document requirement)
- Confluence Cloud REST API v2 preferred (v1 fallback if needed)
- Dependencies: `curl`, `jq` for JSON parsing
- Authentication: Personal Access Token or API token via env var

## 7. Dependencies

- Confluence Cloud instance with API access
- `curl` for HTTP requests
- `jq` for JSON parsing/manipulation
- `.cursor/scripts/.lib.sh` for shared helpers (strict mode, logging, error handling)

## 8. Success Metrics

- Scripts successfully create/update pages in test Confluence space
- Notifications delivered to specified users
- All tests passing
- Scripts composable in pipelines (e.g., create page → notify users)
- Zero token leaks in logs or output

## 9. Out of Scope (for initial version)

- Bulk operations (batch create/update multiple pages)
- Advanced content transformation (beyond basic markdown/storage format)
- Space management (create/delete spaces)
- Permission management
- Attachment handling
- Interactive prompts or TUI interfaces
- Search functionality (defer to future iteration)

## 10. References

- [Confluence Cloud REST API Documentation](https://developer.atlassian.com/cloud/confluence/rest/v2/intro/)
- [`.cursor/rules/shell-unix-philosophy.mdc`](../../../.cursor/rules/shell-unix-philosophy.mdc)
- [`.cursor/scripts/.lib.sh`](../../../.cursor/scripts/.lib.sh) — Shared script helpers
