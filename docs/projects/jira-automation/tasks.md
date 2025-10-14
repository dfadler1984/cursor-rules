# Tasks — Jira Automation

Links: [`erd.md`](./erd.md)

Status: Planning

## Parent Tasks

### 1. [P] Setup project structure and shared helpers

**Status:** Pending  
**Owner:** dfadler1984  
**Estimated complexity:** Small

Create basic project structure with shared authentication and API helpers that all Jira scripts will use.

### 2. [P] Implement issue creation and retrieval scripts

**Status:** Pending  
**Owner:** dfadler1984  
**Estimated complexity:** Medium  
**Dependencies:** Task 1

Core operations for creating and retrieving Jira issues.

### 3. [P] Implement issue update and transition scripts

**Status:** Pending  
**Owner:** dfadler1984  
**Estimated complexity:** Medium  
**Dependencies:** Task 1

Update issue fields and transition issues through workflow states.

### 4. [P] Implement issue commenting script

**Status:** Pending  
**Owner:** dfadler1984  
**Estimated complexity:** Small  
**Dependencies:** Task 1

Add comments to existing issues.

### 5. [P] Add tests for all scripts

**Status:** Pending  
**Owner:** dfadler1984  
**Estimated complexity:** Medium  
**Dependencies:** Tasks 2, 3, 4

Colocated behavior tests for all scripts following TDD workflow.

### 6. [P] Create documentation and examples

**Status:** Pending  
**Owner:** dfadler1984  
**Estimated complexity:** Small  
**Dependencies:** Tasks 2, 3, 4, 5

README with usage examples, composition patterns, and troubleshooting.

---

## Sub-tasks

### Task 1: Setup project structure and shared helpers

#### 1.1 Create shared authentication helper

- File: `.cursor/scripts/jira-auth.sh`
- Read `JIRA_TOKEN` and `JIRA_URL` from env
- Validate token and base URL format
- Expose source-able functions for other scripts
- Include `--help` and `--version`

#### 1.2 Create shared API wrapper

- File: `.cursor/scripts/jira-api.sh`
- Common REST API calls (GET, POST, PUT)
- Error handling and response parsing
- JSON manipulation with `jq`
- Source-able library functions

#### 1.3 Add tests for shared helpers

- Files: `.cursor/scripts/jira-auth.test.sh`, `.cursor/scripts/jira-api.test.sh`
- Test token validation
- Test API call construction
- Mock HTTP responses

---

### Task 2: Implement issue creation and retrieval scripts

#### 2.1 Create issue creation script

- File: `.cursor/scripts/jira-issue-create.sh`
- Accept: project key, issue type, summary, optional description/fields
- Support custom fields via `--field name=value`
- Output: issue key and URL on success
- Exit codes: 0 success, 1 API error, 2 validation error
- Follow Unix Philosophy (< 150 lines, single responsibility)

#### 2.2 Create issue retrieval script

- File: `.cursor/scripts/jira-issue-get.sh`
- Accept: issue key
- Optional `--fields` filter
- Output: JSON or plain text (via `--format` flag)
- Exit codes: 0 success, 1 not found, 2 API error

#### 2.3 Add tests for creation and retrieval scripts

- Files: `.cursor/scripts/jira-issue-create.test.sh`, `.cursor/scripts/jira-issue-get.test.sh`
- Test successful creation/retrieval
- Test custom fields
- Test error handling (invalid inputs, API failures)
- Mock Jira API responses

---

### Task 3: Implement issue update and transition scripts

#### 3.1 Create issue update script

- File: `.cursor/scripts/jira-issue-update.sh`
- Accept: issue key, field updates (summary, description, assignee, labels, priority)
- Support multiple field updates
- Output: issue key and confirmation
- Exit codes: 0 success, 1 API error, 2 validation error

#### 3.2 Create transition listing script

- File: `.cursor/scripts/jira-issue-transitions-list.sh`
- Accept: issue key
- Output: available transition IDs, names, target states
- Exit codes: 0 success, 1 not found, 2 API error

#### 3.3 Create issue transition script

- File: `.cursor/scripts/jira-issue-transition.sh`
- Accept: issue key, target state or transition ID
- Auto-detect transitions if state name provided
- Output: new status and confirmation
- Exit codes: 0 success, 1 invalid transition, 2 API error

#### 3.4 Add tests for update and transition scripts

- Files: `.cursor/scripts/jira-issue-update.test.sh`, etc.
- Test field updates
- Test transition detection and execution
- Test invalid transition handling
- Mock API responses

---

### Task 4: Implement issue commenting script

#### 4.1 Create commenting script

- File: `.cursor/scripts/jira-issue-comment.sh`
- Accept: issue key, comment body
- Output: comment ID on success
- Exit codes: 0 success, 1 API error, 2 validation error

#### 4.2 Add tests for commenting script

- File: `.cursor/scripts/jira-issue-comment.test.sh`
- Test comment creation
- Test error handling
- Mock API responses

---

### Task 5: Add tests for all scripts

#### 5.1 Ensure all scripts have colocated tests

- Verify each `jira-*.sh` has matching `.test.sh`
- All tests passing
- Coverage of happy path and error cases

#### 5.2 Run full test suite

- Execute all Jira script tests
- Fix any failures
- Document test runner usage

---

### Task 6: Create documentation and examples

#### 6.1 Write README

- File: `.cursor/scripts/README.md` or project-specific doc
- Installation and setup (env vars)
- Usage examples for each script
- Composition patterns (piping scripts together)
- Workflow examples (create → transition → comment)
- Troubleshooting common issues

#### 6.2 Add inline documentation

- Ensure all scripts have comprehensive `--help` output
- Include examples in help text
- Document exit codes and field names

---

## Relevant Files

- `.cursor/scripts/jira-*.sh` — Main scripts
- `.cursor/scripts/jira-*.test.sh` — Test specs
- `.cursor/scripts/.lib.sh` — Shared script library
- `.cursor/rules/shell-unix-philosophy.mdc` — Compliance rules
- `docs/projects/jira-automation/erd.md` — Requirements

---

## Notes

- All scripts must follow Unix Philosophy: single responsibility, < 150 lines, composable
- Authentication tokens never logged or echoed
- Use TDD workflow: Red → Green → Refactor
- Results to stdout, logs to stderr
- All scripts support `--help` and `--version`
- Consider workflow composition: create issue → transition → comment pipelines
