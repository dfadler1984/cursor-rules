# Tasks — Confluence Automation

Links: [`erd.md`](./erd.md)

Status: Planning

## Parent Tasks

### 1. [P] Setup project structure and shared helpers

**Status:** Pending  
**Owner:** dfadler1984  
**Estimated complexity:** Small

Create basic project structure with shared authentication and API helpers that all Confluence scripts will use.

### 2. [P] Implement page management scripts

**Status:** Pending  
**Owner:** dfadler1984  
**Estimated complexity:** Medium  
**Dependencies:** Task 1

Core CRUD operations for Confluence pages (create, update, get).

### 3. [P] Implement change notification script

**Status:** Pending  
**Owner:** dfadler1984  
**Estimated complexity:** Medium  
**Dependencies:** Task 1

Notify users when pages are created or updated.

### 4. [P] Add tests for all scripts

**Status:** Pending  
**Owner:** dfadler1984  
**Estimated complexity:** Medium  
**Dependencies:** Tasks 2, 3

Colocated behavior tests for all scripts following TDD workflow.

### 5. [P] Create documentation and examples

**Status:** Pending  
**Owner:** dfadler1984  
**Estimated complexity:** Small  
**Dependencies:** Tasks 2, 3, 4

README with usage examples, composition patterns, and troubleshooting.

---

## Sub-tasks

### Task 1: Setup project structure and shared helpers

#### 1.1 Create shared authentication helper

- File: `.cursor/scripts/confluence-auth.sh`
- Read `CONFLUENCE_TOKEN` and `CONFLUENCE_URL` from env
- Validate token and base URL format
- Expose source-able functions for other scripts
- Include `--help` and `--version`

#### 1.2 Create shared API wrapper

- File: `.cursor/scripts/confluence-api.sh`
- Common REST API calls (GET, POST, PUT)
- Error handling and response parsing
- JSON manipulation with `jq`
- Source-able library functions

#### 1.3 Add tests for shared helpers

- Files: `.cursor/scripts/confluence-auth.test.sh`, `.cursor/scripts/confluence-api.test.sh`
- Test token validation
- Test API call construction
- Mock HTTP responses

---

### Task 2: Implement page management scripts

#### 2.1 Create page creation script

- File: `.cursor/scripts/confluence-page-create.sh`
- Accept: space key, title, body, optional parent page ID
- Output: page ID and URL on success
- Exit codes: 0 success, 1 API error, 2 validation error
- Follow Unix Philosophy (< 150 lines, single responsibility)

#### 2.2 Create page update script

- File: `.cursor/scripts/confluence-page-update.sh`
- Accept: page ID, new body, optional title
- Handle versioning automatically
- Output: updated version and URL
- Exit codes: 0 success, 1 API error, 2 validation error

#### 2.3 Create page retrieval script

- File: `.cursor/scripts/confluence-page-get.sh`
- Accept: page ID or space key + title
- Output: JSON or plain text (via `--format` flag)
- Exit codes: 0 success, 1 not found, 2 API error

#### 2.4 Add tests for page management scripts

- Files: `.cursor/scripts/confluence-page-create.test.sh`, etc.
- Test successful creation/update/retrieval
- Test error handling (invalid inputs, API failures)
- Mock Confluence API responses

---

### Task 3: Implement change notification script

#### 3.1 Create notification script

- File: `.cursor/scripts/confluence-notify.sh`
- Accept: page ID, user account IDs (CSV), message
- Mechanism: add watchers or post comment with mentions
- Output: notification status per user
- Exit codes: 0 all success, 1 partial failure, 2 complete failure

#### 3.2 Add tests for notification script

- File: `.cursor/scripts/confluence-notify.test.sh`
- Test single and multiple user notifications
- Test partial failure scenarios
- Mock API responses

---

### Task 4: Add tests for all scripts

#### 4.1 Ensure all scripts have colocated tests

- Verify each `confluence-*.sh` has matching `.test.sh`
- All tests passing
- Coverage of happy path and error cases

#### 4.2 Run full test suite

- Execute all Confluence script tests
- Fix any failures
- Document test runner usage

---

### Task 5: Create documentation and examples

#### 5.1 Write README

- File: `.cursor/scripts/README.md` or project-specific doc
- Installation and setup (env vars)
- Usage examples for each script
- Composition patterns (piping scripts together)
- Troubleshooting common issues

#### 5.2 Add inline documentation

- Ensure all scripts have comprehensive `--help` output
- Include examples in help text
- Document exit codes

---

## Relevant Files

- `.cursor/scripts/confluence-*.sh` — Main scripts
- `.cursor/scripts/confluence-*.test.sh` — Test specs
- `.cursor/scripts/.lib.sh` — Shared script library
- `.cursor/rules/shell-unix-philosophy.mdc` — Compliance rules
- `docs/projects/confluence-automation/erd.md` — Requirements

---

## Notes

- All scripts must follow Unix Philosophy: single responsibility, < 150 lines, composable
- Authentication tokens never logged or echoed
- Use TDD workflow: Red → Green → Refactor
- Results to stdout, logs to stderr
- All scripts support `--help` and `--version`
