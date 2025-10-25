---
status: active
owner: dfadler1984
created: 2025-10-14
lastUpdated: 2025-10-24
---

# Engineering Requirements Document: PR Creation Script Decomposition

Mode: Full

## 1. Introduction/Overview

The current `pr-create.sh` script (303 lines, 14 flags) violates Unix Philosophy principles by handling multiple responsibilities: git context derivation, template management, body composition, PR creation, and label application. This project decomposes it into focused, composable utilities (each < 150 lines, 4-6 flags) that follow the "do one thing well" principle.

**Problem:** Monolithic script is difficult to test, maintain, and reuse. The current script already includes a deprecation notice suggesting focused alternatives but lacks the implementation.

**Goal:** Replace `pr-create.sh` with five focused utilities that compose naturally via pipes and sequential calls while maintaining 100% feature parity.

## 2. Goals/Objectives

1. **Decompose** `pr-create.sh` into five focused scripts, each < 150 lines
2. **Maintain** 100% feature parity with current script
3. **Improve** testability via focused owner tests per utility
4. **Enable** reusability of git-context and body-composition utilities
5. **Simplify** maintenance by reducing flag interdependencies
6. **Document** composition patterns for common workflows
7. **Provide** migration path for existing users

## 3. User Stories

1. As a **developer**, I want to derive git context (owner/repo/head/base) as a reusable utility so I can use it in multiple scripts.

2. As a **developer**, I want to compose PR bodies with templates separately so I can preview/modify before creating the PR.

3. As a **script author**, I want to create PRs via a minimal API wrapper so I can integrate PR creation into custom workflows.

4. As a **developer**, I want to apply labels to existing PRs independently so I can label PRs created through any mechanism.

5. As a **convenience user**, I want a high-level wrapper that orchestrates the utilities so I can create PRs with one command for simple workflows.

6. As a **test author**, I want focused scripts so I can write targeted unit tests without complex mocking.

## 4. Functional Requirements

### FR1: Git Context Utility (`git-context.sh`)

1. Extract `owner`, `repo`, `head`, `base` from git remote and branch state
2. Support `--format json|env` output (default: env for sourcing)
3. Allow overrides via `--owner`, `--repo`, `--head`, `--base` flags
4. Fail gracefully with clear errors when not in a git repository
5. Output clean results to stdout, logs to stderr
6. Size target: ~60 lines

### FR2: Body Composition Utility (`pr-body-compose.sh`)

1. Discover PR template from `.github/pull_request_template.md` or `.github/PULL_REQUEST_TEMPLATE/` (first file alphabetically)
2. Accept user body via stdin or `--body` flag
3. Support explicit template path via `--template PATH`
4. Support `--no-template` to skip template discovery
5. Support `--append TEXT` to add context section
6. Compose template + user body + appended text with clear section markers
7. Output composed markdown to stdout
8. Size target: ~80-100 lines

### FR3: GitHub PR Creation Utility (`github-pr-create.sh`)

1. Create GitHub PR via POST to `/repos/{owner}/{repo}/pulls` API
2. Accept `--title`, `--body`, `--owner`, `--repo`, `--head`, `--base` flags (all required or derivable)
3. Support `--dry-run` to print JSON payload without API call
4. Require `GH_TOKEN` environment variable
5. Output GitHub API response JSON to stdout
6. Log errors and fallback compare URL to stderr on failure
7. Size target: ~80-100 lines

### FR4: GitHub PR Label Utility (`github-pr-label.sh`)

1. Apply labels to existing PR via POST to `/repos/{owner}/{repo}/issues/{number}/labels` API
2. Accept `--pr NUMBER`, `--owner`, `--repo`, `--label NAME` (repeatable)
3. Require `GH_TOKEN` environment variable
4. Support multiple labels via repeated `--label` flags
5. Output GitHub API response JSON to stdout
6. Size target: ~60-80 lines

### FR5: Convenience Wrapper (`pr-create.sh`)

1. Orchestrate utilities for common workflows
2. Delegate to focused utilities (call git-context → pr-body-compose → github-pr-create → github-pr-label)
3. Provide simplified interface for common cases
4. Support `--title`, `--body`, `--label` flags minimum
5. Mark as "convenience wrapper" (not required, utilities preferred)
6. Size target: ~100-120 lines

### FR6: Feature Parity

All current `pr-create.sh` functionality must be achievable via utility composition:

- Template discovery and injection
- Body composition with context sections
- PR creation with auto-detected git context
- Label application
- Dry-run mode
- Custom owner/repo/head/base
- Error handling with fallback URLs

## 5. Non-Functional Requirements

### Performance

- **Latency:** Each utility completes in < 2 seconds for typical inputs
- **Composition overhead:** Piped workflow adds < 500ms vs monolithic script
- **API rate limits:** Respect GitHub rate limits (5000/hour with token)

### Reliability

- **Error handling:** Each utility fails fast with clear error messages
- **Idempotency:** Utilities are safe to retry (dry-run first when possible)
- **Fallback:** Provide compare URLs when PR creation fails

### Maintainability

- **Code size:** Each utility < 150 lines (target), < 200 lines (hard limit)
- **Flag count:** Each utility ≤ 6 flags (target), ≤ 8 flags (hard limit)
- **Responsibility:** Single, clearly-stated purpose per utility
- **Test coverage:** Each utility has focused owner tests

### Security

- **Token handling:** Never log or expose `GH_TOKEN`
- **Input validation:** Sanitize all inputs before API calls
- **JSON escaping:** Use `.lib.sh` `json_escape` helper for all JSON payloads

### Portability

- **Shell:** Bash 4.0+ (existing constraint)
- **Dependencies:** `curl`, `jq` (optional for JSON parsing), git
- **OS:** macOS, Linux (existing constraint)

## 6. Architecture/Design

### Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Convenience Wrapper                       │
│                     pr-create.sh                             │
│  (Orchestrates utilities for common workflows)               │
└──────────┬──────────────────────────────────────────────────┘
           │ calls
           ▼
┌──────────────────────┐  ┌──────────────────────┐  ┌──────────────────────┐
│   git-context.sh     │  │ pr-body-compose.sh   │  │ github-pr-create.sh  │
│  (git metadata)      │  │ (template + body)    │  │  (POST /pulls)       │
└──────────────────────┘  └──────────────────────┘  └──────────────────────┘
                                                     │
                                                     ▼
                                          ┌──────────────────────┐
                                          │ github-pr-label.sh   │
                                          │ (POST /issues/labels)│
                                          └──────────────────────┘

Dependencies:
- All scripts: .lib.sh (shared helpers)
- github-*: GH_TOKEN env var
- git-context: git CLI
- github-pr-label: jq (for PR number extraction from URL)
```

### Composition Patterns

**Pattern 1: Minimal PR (no template)**

```bash
eval "$(git-context.sh)"
github-pr-create.sh --title "Fix typo" --body "Simple fix" \
  --owner "$OWNER" --repo "$REPO" --head "$HEAD" --base "$BASE"
```

**Pattern 2: PR with template**

```bash
eval "$(git-context.sh)"
body=$(pr-body-compose.sh --body "Added feature X")
github-pr-create.sh --title "Add feature X" --body "$body" \
  --owner "$OWNER" --repo "$REPO" --head "$HEAD" --base "$BASE"
```

**Pattern 3: Full workflow with labels**

```bash
eval "$(git-context.sh)"
body=$(pr-body-compose.sh --body "Docs only")
pr_json=$(github-pr-create.sh --title "Update docs" --body "$body" \
  --owner "$OWNER" --repo "$REPO" --head "$HEAD" --base "$BASE")
pr_number=$(echo "$pr_json" | jq -r '.number')
github-pr-label.sh --pr "$pr_number" --owner "$OWNER" --repo "$REPO" \
  --label skip-changeset
```

**Pattern 4: Convenience wrapper**

```bash
pr-create.sh --title "Add feature X" --body "Context..." --label skip-changeset
```

### Design Decisions

1. **Pure utilities over wrapper:** Utilities are the primary interface; wrapper is optional convenience
2. **Env format for git-context:** Enables easy sourcing (`eval "$(git-context.sh)"`)
3. **Stdin + flags for pr-body-compose:** Supports both piped and CLI workflows
4. **JSON output for GitHub utilities:** Enables composition and programmatic access to PR URLs/numbers
5. **Separate label script:** Labels can be applied to PRs created via any mechanism

## 7. Data Model and Storage

### Git Context Data

```bash
# Output format (env)
OWNER=dfadler1984
REPO=cursor-rules
HEAD=feat/pr-decomposition
BASE=main

# Output format (json)
{
  "owner": "dfadler1984",
  "repo": "cursor-rules",
  "head": "feat/pr-decomposition",
  "base": "main"
}
```

### PR Body Composition

```markdown
# Input: Template (.github/pull_request_template.md)

## Summary

[User fills this in]

## Changes

- [Change 1]

# Input: User body (--body flag)

Added feature X with Y capability

# Output: Composed body

## Summary

[User fills this in]

## Changes

- [Change 1]

## Context

Added feature X with Y capability
```

### GitHub API Payloads

**PR Creation:**

```json
{
  "title": "Add feature X",
  "body": "...",
  "base": "main",
  "head": "feat/feature-x"
}
```

**Label Application:**

```json
{
  "labels": ["skip-changeset", "documentation"]
}
```

## 8. API/Contracts

### `git-context.sh`

**Input:** Flags or git state

```bash
git-context.sh [--format json|env] [--owner X] [--repo Y] [--head Z] [--base W]
```

**Output (stdout):** Key=value pairs (env) or JSON object
**Exit codes:** 0 (success), 1 (not in git repo), 2 (invalid args)

### `pr-body-compose.sh`

**Input:** Template path, user body, append text

```bash
pr-body-compose.sh [--template PATH] [--no-template] [--body TEXT] [--append TEXT]
# Or via stdin:
echo "User body" | pr-body-compose.sh --template PATH
```

**Output (stdout):** Composed markdown body
**Exit codes:** 0 (success), 1 (template not found), 2 (invalid args)

### `github-pr-create.sh`

**Input:** PR metadata + GH_TOKEN env

```bash
GH_TOKEN=xxx github-pr-create.sh --title T --body B --owner O --repo R --head H --base B [--dry-run]
```

**Output (stdout):** GitHub API response JSON
**Exit codes:** 0 (success), 1 (API error), 2 (invalid args), 3 (missing GH_TOKEN)

### `github-pr-label.sh`

**Input:** PR number + labels + GH_TOKEN env

```bash
GH_TOKEN=xxx github-pr-label.sh --pr NUM --owner O --repo R --label L1 [--label L2 ...]
```

**Output (stdout):** GitHub API response JSON
**Exit codes:** 0 (success), 1 (API error), 2 (invalid args), 3 (missing GH_TOKEN)

### `pr-create.sh` (wrapper)

**Input:** Simplified flags

```bash
pr-create.sh --title T [--body B] [--label L] [--dry-run]
```

**Output (stdout):** GitHub API response JSON or dry-run payload
**Exit codes:** 0 (success), 1 (utility failure), 2 (invalid args)

## 9. Integrations/Dependencies

### Internal Dependencies

- **`.lib.sh`:** All scripts source shared helpers (`log_*`, `die`, `json_escape`, `require_cmd`)
- **Utilities:** Wrapper calls git-context, pr-body-compose, github-pr-create, github-pr-label

### External Dependencies

- **Git CLI:** Required by git-context.sh
- **curl:** Required by github-pr-create.sh and github-pr-label.sh
- **jq:** Optional (for parsing JSON in composition patterns); required for wrapper label extraction
- **GitHub API:** `https://api.github.com/repos/{owner}/{repo}/pulls` and `/issues/{number}/labels`

### Environment Variables

- **`GH_TOKEN`** or **`GITHUB_TOKEN`:** Required for GitHub API calls
- **Permissions:** Classic token with `repo` scope, or fine-grained token with `Contents: Read`, `Pull requests: Write`

### Configuration

- **Template paths:** `.github/pull_request_template.md` or `.github/PULL_REQUEST_TEMPLATE/*.md`
- **Git remote:** `origin` (hardcoded; can be parameterized in future)

## 10. Edge Cases and Constraints

### Edge Cases

1. **No git repository:** git-context.sh must fail gracefully with clear error
2. **No remote named 'origin':** git-context.sh must handle missing remote
3. **Template not found:** pr-body-compose.sh proceeds without template, logs warning
4. **Multiple templates:** pr-body-compose.sh picks first file alphabetically for determinism
5. **Empty body:** Valid; github-pr-create.sh accepts empty body
6. **Label on failed PR:** github-pr-label.sh should fail if PR doesn't exist
7. **SSO approval required:** GitHub API returns 401; log clear message about SSO approval
8. **Rate limit exceeded:** GitHub API returns 403; log rate limit reset time

### Constraints

1. **Size limits:** Each utility < 150 lines (target), < 200 lines (hard limit)
2. **Flag limits:** Each utility ≤ 6 flags (target), ≤ 8 flags (hard limit)
3. **Shell compatibility:** Bash 4.0+ only (no POSIX requirement)
4. **GitHub API:** Subject to rate limits (5000/hour with token, 60/hour without)
5. **Template format:** Markdown only; no other formats supported
6. **Branch naming:** Must follow repo conventions (enforced by pre-push hook)

### Known Limitations

1. **No GitHub Enterprise support:** Hardcoded `api.github.com`; parameterization left for future
2. **No draft PR support:** Would require `--draft` flag; deferred
3. **No PR update support:** Separate `pr-update.sh` script exists; not in scope
4. **No PR number inference:** Wrapper requires explicit PR number for labeling; no HEAD-based lookup

## 11. Testing & Acceptance

### Test Strategy

**TDD-First (per `tdd-first-sh.mdc`):**

1. Write failing owner test for each utility (Red)
2. Implement minimal code to pass (Green)
3. Refactor while keeping tests green
4. Run focused tests: `bash .cursor/scripts/tests/run.sh -k <script-name> -v`

### Owner Tests

Each utility requires a colocated `.test.sh` file:

1. **`git-context.test.sh`**

   - Test env format output parsing
   - Test JSON format output
   - Test override flags
   - Test behavior outside git repo
   - Test missing remote handling

2. **`pr-body-compose.test.sh`**

   - Test template discovery (both paths)
   - Test body composition with template
   - Test no-template mode
   - Test append flag
   - Test stdin input
   - Test missing template warning

3. **`github-pr-create.test.sh`**

   - Test dry-run output format
   - Test missing GH_TOKEN error
   - Test JSON payload escaping
   - Test fallback URL generation
   - Mock API calls for success/failure cases

4. **`github-pr-label.test.sh`**

   - Test single label
   - Test multiple labels
   - Test missing PR number error
   - Test missing GH_TOKEN error
   - Mock API calls

5. **`pr-create.test.sh`** (wrapper)
   - Test utility orchestration
   - Test flag delegation
   - Test error propagation from utilities

### Integration Tests

Create `pr-create-integration.test.sh` to test composition patterns:

- Full workflow (git-context → body-compose → pr-create → label)
- Error handling across utility boundaries
- Dry-run end-to-end

### Acceptance Criteria

**Script Creation:**

- [ ] `git-context.sh` created and < 100 lines
- [ ] `pr-body-compose.sh` created and < 120 lines
- [ ] `github-pr-create.sh` created and < 120 lines
- [ ] `github-pr-label.sh` created and < 100 lines
- [ ] `pr-create.sh` wrapper created and < 150 lines

**Feature Parity:**

- [ ] All flags from original script supported via utilities
- [ ] Template discovery and injection works identically
- [ ] Body composition matches original behavior
- [ ] Label application works identically
- [ ] Dry-run mode works identically
- [ ] Error messages and fallback URLs match quality of original

**Testing:**

- [ ] Owner tests pass for all utilities
- [ ] Integration tests pass for composition patterns
- [ ] Test coverage: exit codes, stdout/stderr separation, flag handling

**Documentation:**

- [ ] Each utility has `--help` with examples
- [ ] Composition patterns documented in project README or wrapper help
- [ ] Migration guide from old script to utilities

**Quality Gates:**

- [ ] ShellCheck passes for all scripts
- [ ] Help validation passes: `.cursor/scripts/help-validate.sh`
- [ ] Error validation passes: `.cursor/scripts/error-validate.sh`
- [ ] Unix Philosophy validation: scripts are focused, composable, < 150 lines

## 12. Rollout & Ops

### Rollout Plan

**Phase 1: Create utilities (TDD-first)**

1. Create `git-context.sh` + tests
2. Create `pr-body-compose.sh` + tests
3. Create `github-pr-create.sh` + tests
4. Create `github-pr-label.sh` + tests
5. Run focused tests after each utility completion

**Phase 2: Create wrapper**

1. Create `pr-create.sh` wrapper that orchestrates utilities
2. Write wrapper tests
3. Run integration tests

**Phase 3: Documentation**

1. Update wrapper `--help` with composition examples
2. Create migration guide for existing users
3. Update repo documentation to recommend utilities

**Phase 4: Deprecation**

1. Keep original `pr-create.sh` as `pr-create-legacy.sh` for reference
2. Update `pr-create.sh` to new wrapper implementation
3. Monitor for issues; rollback plan is to restore legacy script

**Phase 5: Cleanup**

1. After 30 days of stable usage, archive legacy script
2. Remove deprecation notices from new utilities

### Feature Flags

- Not applicable; script deployment is atomic (commit + push)

### Migrations

- No database migrations required
- Users must update their aliases/CI scripts to use new script names (if calling utilities directly)
- Wrapper maintains CLI compatibility for common workflows

### Monitoring

**Success indicators:**

- Scripts complete successfully (exit 0)
- GitHub API calls return 201 (PR created) or 200 (labels added)
- No fallback compare URLs logged (indicates API failures)

**Failure indicators:**

- Exit codes 1 (API failure), 2 (invalid args), 3 (missing token)
- Stderr logs show errors or fallback URLs
- GitHub API rate limit warnings

**Observability:**

- All utilities log to stderr via `.lib.sh` helpers
- Errors include context (script name, operation, API endpoint)
- Dry-run mode available for testing without side effects

### Rollback Plan

If critical issues arise:

1. Revert to `pr-create-legacy.sh` (original script)
2. Update aliases/CI to point to legacy script
3. Investigate and fix issues in new utilities
4. Re-deploy after fixes and additional testing

## 13. Success Metrics

### Quantitative Metrics

1. **Script size reduction:** 303 lines → 5 scripts totaling ~400-500 lines (but each < 150)
2. **Flag reduction per script:** 14 flags → max 6 flags per utility
3. **Test coverage:** 0 tests → 5 owner tests + 1 integration test
4. **Reusability:** `git-context.sh` used by ≥ 2 other scripts within 60 days
5. **Composition adoption:** ≥ 50% of PR creations use direct utilities vs wrapper after 90 days

### Qualitative Metrics

1. **Maintainability:** Contributors report easier understanding and modification
2. **Testability:** New tests can be added without complex mocking
3. **Composability:** Users create custom workflows by piping utilities
4. **Documentation quality:** `--help` and examples are clear and sufficient

### Validation

- Run Unix Philosophy size check: `wc -l .cursor/scripts/{git-context,pr-body-compose,github-pr-create,github-pr-label,pr-create}.sh`
- All scripts should be < 150 lines
- Run flag count check: each script has ≤ 6 flags
- Test suite passes: `bash .cursor/scripts/tests/run.sh -k pr-create -v`

## 14. Open Questions

1. **GitHub Enterprise support:** Should we parameterize API base URL for GHE? (Decision: defer to future project)

2. **Draft PR support:** Should `github-pr-create.sh` support `--draft` flag? (Decision: defer; low demand)

3. **PR number inference:** Should wrapper infer PR number from HEAD branch for labeling? (Decision: defer; adds complexity)

4. **Template precedence:** If multiple templates exist under `PULL_REQUEST_TEMPLATE/`, use first alphabetically or allow user to choose interactively? (Decision: first alphabetically for determinism)

5. **Wrapper necessity:** Is the wrapper needed, or should we promote direct utility usage only? (Decision: provide wrapper for convenience, but document utilities as primary)

6. **Legacy script fate:** Keep `pr-create-legacy.sh` permanently or remove after stable period? (Decision: remove after 30 days stable usage)

7. **Output format for git-context:** Should JSON format be default instead of env? (Decision: env is default for easy sourcing; JSON is opt-in)

8. **Error recovery:** Should utilities auto-retry on transient GitHub API failures? (Decision: no auto-retry; user can retry manually or use wrapper with retry logic)

---

**Next Steps:**

1. Review and approve ERD
2. Generate tasks document: `/tasks` or `generate-tasks-from-erd.mdc`
3. Begin TDD implementation: Start with `git-context.sh`
