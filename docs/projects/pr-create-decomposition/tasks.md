# Tasks — PR Create Decomposition

**Status:** Planning  
**Owner:** dfadler1984  
**Parent Project:** None (standalone Unix Philosophy decomposition)

## Relevant Files

- `docs/projects/pr-create-decomposition/erd.md`
- `.cursor/scripts/pr-create.sh` (303 lines, current monolith)
- `.cursor/scripts/.lib.sh` (shared helpers)

## Context

This project decomposes the monolithic `pr-create.sh` (303 lines, 14 flags) into five focused Unix Philosophy utilities. Each utility will be < 150 lines with a single responsibility and composable via pipes/sequential calls.

**Goal:** Replace pr-create.sh with focused utilities while maintaining 100% feature parity.

## Todo

### Phase 1: Git Context Utility

- [ ] 1.0 Create `git-context.sh` (TDD-first)
  - [ ] 1.1 Write failing owner spec (`git-context.test.sh`)
  - [ ] 1.2 Implement env format output (owner, repo, head, base)
  - [ ] 1.3 Add JSON format support (`--format json`)
  - [ ] 1.4 Add override flags (`--owner`, `--repo`, `--head`, `--base`)
  - [ ] 1.5 Add error handling for non-git repos
  - [ ] 1.6 Run focused tests: `bash .cursor/scripts/tests/run.sh -k git-context -v`

### Phase 2: Body Composition Utility

- [ ] 2.0 Create `pr-body-compose.sh` (TDD-first)
  - [ ] 2.1 Write failing owner spec (`pr-body-compose.test.sh`)
  - [ ] 2.2 Implement template discovery (`.github/pull_request_template.md`)
  - [ ] 2.3 Add stdin and `--body` flag support
  - [ ] 2.4 Add `--template PATH` for explicit template
  - [ ] 2.5 Add `--no-template` flag
  - [ ] 2.6 Add `--append TEXT` for context section
  - [ ] 2.7 Run focused tests: `bash .cursor/scripts/tests/run.sh -k pr-body-compose -v`

### Phase 3: GitHub PR Creation Utility

- [ ] 3.0 Create `github-pr-create.sh` (TDD-first)
  - [ ] 3.1 Write failing owner spec (`github-pr-create.test.sh`)
  - [ ] 3.2 Implement GitHub API POST to `/pulls`
  - [ ] 3.3 Add required flags (`--title`, `--body`, `--owner`, `--repo`, `--head`, `--base`)
  - [ ] 3.4 Add `--dry-run` support
  - [ ] 3.5 Add `GH_TOKEN` validation
  - [ ] 3.6 Add error handling and fallback compare URL
  - [ ] 3.7 Run focused tests: `bash .cursor/scripts/tests/run.sh -k github-pr-create -v`

### Phase 4: GitHub PR Label Utility

- [ ] 4.0 Create `github-pr-label.sh` (TDD-first)
  - [ ] 4.1 Write failing owner spec (`github-pr-label.test.sh`)
  - [ ] 4.2 Implement GitHub API POST to `/issues/{number}/labels`
  - [ ] 4.3 Add flags (`--pr NUMBER`, `--owner`, `--repo`, `--label NAME` repeatable)
  - [ ] 4.4 Add `GH_TOKEN` validation
  - [ ] 4.5 Add multiple label support
  - [ ] 4.6 Run focused tests: `bash .cursor/scripts/tests/run.sh -k github-pr-label -v`

### Phase 5: Convenience Wrapper

- [ ] 5.0 Create `pr-create.sh` wrapper (TDD-first)
  - [ ] 5.1 Write failing owner spec (`pr-create.test.sh`)
  - [ ] 5.2 Orchestrate utilities (git-context → pr-body-compose → github-pr-create → github-pr-label)
  - [ ] 5.3 Add simplified flags (`--title`, `--body`, `--label`)
  - [ ] 5.4 Add flag delegation to utilities
  - [ ] 5.5 Add error propagation
  - [ ] 5.6 Run focused tests: `bash .cursor/scripts/tests/run.sh -k pr-create -v`

### Phase 6: Integration & Documentation

- [ ] 6.0 Integration testing
  - [ ] 6.1 Create `pr-create-integration.test.sh`
  - [ ] 6.2 Test full workflow (git-context → body-compose → pr-create → label)
  - [ ] 6.3 Test error handling across utility boundaries
  - [ ] 6.4 Test dry-run end-to-end
  - [ ] 6.5 Run all tests: `bash .cursor/scripts/tests/run.sh -v`

- [ ] 7.0 Documentation
  - [ ] 7.1 Add `--help` to all utilities with examples
  - [ ] 7.2 Document composition patterns in wrapper help
  - [ ] 7.3 Create migration guide from old script to utilities
  - [ ] 7.4 Update repo documentation to recommend utilities

### Phase 7: Quality Gates

- [ ] 8.0 Validation
  - [ ] 8.1 Run ShellCheck: `.cursor/scripts/shellcheck-run.sh`
  - [ ] 8.2 Run help validator: `.cursor/scripts/help-validate.sh`
  - [ ] 8.3 Run error validator: `.cursor/scripts/error-validate.sh`
  - [ ] 8.4 Verify Unix Philosophy compliance (< 150 lines, ≤ 6 flags per script)
  - [ ] 8.5 Verify all owner tests pass

### Phase 8: Deprecation & Cleanup

- [ ] 9.0 Deprecation
  - [ ] 9.1 Archive original script as `pr-create-legacy.sh`
  - [ ] 9.2 Update `pr-create.sh` to new wrapper implementation
  - [ ] 9.3 Monitor for issues (30 days)
  - [ ] 9.4 Remove legacy script after stable period

## Acceptance Criteria

**Script Creation:**
- [ ] All 5 scripts created and executable
- [ ] Each script < 150 lines
- [ ] Each script has ≤ 6 flags

**Feature Parity:**
- [ ] All flags from original script supported
- [ ] Template discovery works identically
- [ ] Body composition matches original
- [ ] Label application works identically
- [ ] Dry-run mode works identically

**Testing:**
- [ ] All owner tests pass
- [ ] Integration tests pass
- [ ] Test coverage for exit codes, stdout/stderr, flags

**Quality:**
- [ ] ShellCheck passes
- [ ] Help validation passes
- [ ] Error validation passes
- [ ] Unix Philosophy validation passes

## Notes

- Follow TDD-First (Red → Green → Refactor) for all implementations
- Use `.lib.sh` helpers for consistency (`log_*`, `die`, `json_escape`)
- Keep stdout clean (results only), logs to stderr
- Test in isolation using focused test runs

## Real-World Issues to Address (From Phase 3 Monitoring)

### Issue #1: Changeset Intent Contradiction (2025-10-23)

**Source**: routing-optimization Phase 3 real-world validation  
**Context**: PR #159 creation  
**Severity**: Medium

**Problem**:
- User requested: "create a pr with changeset"
- Actual behavior: Changeset created ✅, but skip-changeset label applied ❌
- Result: Contradictory state (has changeset + skip-changeset label)

**Root Cause**:
- Current `pr-create.sh` either:
  - Auto-applies skip-changeset as default
  - Lacks logic to detect changeset files and prevent contradictory labels
  - Missing explicit label control for "with changeset" intent

**Requirements for Decomposed Scripts**:

**Phase 4 (github-pr-label.sh):**
- [ ] Add `--remove-label NAME` flag for removing labels
- [ ] Add `--ensure-no-label NAME` flag (idempotent: remove if present, succeed if absent)
- [ ] Support reading labels from PR to check current state

**Phase 5 (pr-create.sh wrapper):**
- [ ] Add `--with-changeset` flag (explicit user intent)
  - Detect changeset files in commit (`.changeset/*.md`)
  - If found + `--with-changeset` requested: ensure NO skip-changeset label
  - If not found + `--with-changeset` requested: warn user
- [ ] Add changeset detection logic:
  - Check git diff for `.changeset/*.md` files
  - OR scan committed files in HEAD for changeset directory
- [ ] Label application logic:
  - Default: no labels (don't assume skip-changeset)
  - Explicit: `--label skip-changeset` if user wants to skip
  - Validation: error if `--with-changeset` + `--label skip-changeset` both present

**Test Cases to Add**:
```bash
# Test: Changeset present + with-changeset flag → no skip-changeset label
# Test: Changeset absent + with-changeset flag → warning
# Test: Explicit skip-changeset label → applied regardless of changeset presence
# Test: with-changeset + skip-changeset both → error (contradiction)
```

**References**:
- `docs/projects/routing-optimization/phase3-findings.md` — Finding #1
- `docs/projects/routing-optimization/tasks.md` — Phase 3 corrective actions
- PR #159 — Real-world example

