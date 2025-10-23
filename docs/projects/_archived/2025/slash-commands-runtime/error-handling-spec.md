# Error Handling & Help System

**Purpose:** Unified error handling and help for all slash commands

**Status:** Implementation specification for assistant behavior

---

## Principles

**Error messages should be:**

1. **Actionable** - Tell user exactly how to fix the problem
2. **Clear** - Use plain language, avoid jargon
3. **Helpful** - Suggest alternatives or related commands
4. **Consistent** - Follow same format across all commands

---

## Error Types & Responses

### 1. Unknown Command

**Trigger:** User types `/unknown-command`

**Detection:** Command word not in known commands list

**Response format:**

```
Unknown command: /unknown-command

Available commands:
  /plan <topic>        Create plan scaffold
  /tasks [options]     Manage project tasks
  /pr [options]        Create pull request

Did you mean: /plan ?
(if Levenshtein distance ≤ 2)
```

**Fuzzy matching** (optional):

- Calculate edit distance between unknown command and known commands
- If closest match has distance ≤ 2, suggest it
- Examples:
  - `/palr` → Did you mean: /plan ?
  - `/task` → Did you mean: /tasks ?
  - `/pr-create` → Did you mean: /pr ?

### 2. Missing Required Arguments

**Trigger:** Required argument not provided

**Detection:** Parse result missing required field

**Response format:**

```
Error: /<command> requires <argument>

Usage: /<command> <argument-pattern>

Example: /<command> <example-value>

Tip: <helpful hint>
```

**Examples:**

**/plan without topic:**

```
Error: /plan requires a topic argument

Usage: /plan <topic>

Example: /plan checkout-flow

Tip: Use kebab-case for consistency
```

**/tasks --mark without ID:**

```
Error: --mark requires a task ID

Usage: /tasks --mark <task-id>

Example: /tasks --mark 2.0

Tip: Use /tasks --list to see available task IDs
```

### 3. Invalid Argument Format

**Trigger:** Argument doesn't match expected pattern

**Detection:** Validation fails (e.g., task ID format, invalid characters)

**Response format:**

```
Error: Invalid <argument-type>: <value>

Expected format: <pattern>

Examples:
  <valid-example-1>
  <valid-example-2>

Current input: <what-user-provided>
```

**Examples:**

**Invalid task ID:**

```
Error: Invalid task ID format: abc-123

Expected format: N.N or N.N.N (numeric sections separated by dots)

Examples:
  1.0
  2.3
  3.1.2

Current input: abc-123
```

**Invalid topic (special characters):**

```
Error: Topic contains invalid characters: /

Topics should use kebab-case (letters, numbers, hyphens only).

Valid examples:
  checkout-flow
  user-auth-v2
  api-refactor

Current input: topic/with/slashes
```

### 4. Missing Prerequisites

**Trigger:** Required tool/file/state not present

**Detection:** Validation check fails before execution

**Response format:**

```
Error: <prerequisite> not found

<explanation-of-what's-missing>

Fix:
<numbered-steps-to-resolve>

Then try again: <original-command>
```

**Examples:**

**No GitHub token (warning, not error):**

```
Warning: GITHUB_TOKEN not set

The PR creation script requires a GitHub token for API access.
Without it, the script will fall back to printing a compare URL.

Options:
1. Set token: export GITHUB_TOKEN=<your-token>
   Get token: https://github.com/settings/tokens
2. Continue with fallback (manual PR creation)

Proceed? (Yes/No)
```

**Not in git repository:**

```
Error: Not in a git repository

Cannot create PR outside a git repository.

Fix:
1. Navigate to a git repository directory
2. Or initialize: git init

Then try: /pr again
```

**Project not found:**

```
Error: Project not found: invalid-slug

Available projects:
  - productivity
  - slash-commands-runtime
  - rules-enforcement-investigation
  [... up to 10 most recent ...]

Use: /tasks --project <valid-slug>
```

### 5. Ambiguous Context

**Trigger:** Multiple valid interpretations, can't auto-detect

**Detection:** Multiple matches found, need user clarification

**Response format:**

```
Error: <ambiguity-description>

<context-details>

Please specify: <clarification-needed>

Examples:
  <option-1-example>
  <option-2-example>
```

**Examples:**

**Multiple projects detected:**

```
Error: Cannot determine project context

Multiple projects detected in current session:
  - productivity
  - slash-commands-runtime

Please specify: /tasks --project <slug>

Examples:
  /tasks --project productivity
  /tasks --project slash-commands-runtime --mark 2.0
```

**Ambiguous operation:**

```
Error: Conflicting operations requested

You specified both:
  --mark 2.0 (mark task complete)
  --add "New task" (add new task)

Only one operation allowed per command.

Choose one:
  /tasks --mark 2.0
  /tasks --add "New task"
  /tasks --list
```

### 6. Execution Failures

**Trigger:** Script/operation fails during execution

**Detection:** Non-zero exit code, exception, or error state

**Response format:**

```
✗ <operation> failed

Error: <error-message>

<error-details-or-output>

Troubleshooting:
<numbered-list-of-common-causes-and-fixes>

See: <reference-to-relevant-docs>
```

**Examples:**

**PR creation script failed:**

```
✗ PR creation failed (exit code: 1)

Error: Failed to create pull request via GitHub API

Script output:
  Error 422: Validation Failed
  - base: "main" does not exist
  - head: "feature-branch" does not exist

Troubleshooting:
1. Verify base branch exists: git branch -a | grep main
2. Push head branch to origin: git push -u origin feature-branch
3. Check repository access and token permissions
4. Verify GITHUB_TOKEN is valid: curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user

See: assistant-git-usage.mdc → PR creation (curl + GitHub API)
```

**Task file modification failed:**

```
✗ Failed to update tasks file

Error: Permission denied: docs/projects/productivity/tasks.md

Possible causes:
1. File is read-only: chmod +w docs/projects/productivity/tasks.md
2. File is open in another process: close and try again
3. Directory permissions: check parent directory permissions

Try: ls -la docs/projects/productivity/
```

---

## Help System

### Global Help

**Trigger:** User types `/help` or requests command list

**Response:**

```
Available Slash Commands:

Planning & Specification:
  /plan <topic>             Create plan scaffold following spec-driven workflow
                            Example: /plan checkout-flow

Task Management:
  /tasks [options]          Manage project tasks
    --project <slug>        Specify project (default: auto-detect)
    --mark <id>             Mark task as complete (e.g., 2.0)
    --add "description"     Add new task
    --list                  List all tasks (default)
                            Example: /tasks --project productivity --mark 2.0

Git & Pull Requests:
  /pr [options]             Create pull request
    --title "text"          PR title (default: derive from commits)
    --body "text"           PR body (default: use template)
    --base <branch>         Base branch (default: auto-detect)
    --head <branch>         Head branch (default: current branch)
                            Example: /pr --title "Add feature X"

Getting Help:
  /help                     Show this help message
  /help <command>           Show detailed help for specific command
                            Example: /help plan

Related Documentation:
  - Spec-driven workflow: spec-driven.mdc
  - Task management: project-lifecycle.mdc
  - Git usage: assistant-git-usage.mdc
  - All capabilities: capabilities.mdc
```

### Command-Specific Help

**Trigger:** User types `/help <command>`

**Response format:**

```
Command: /<command>

Description:
<brief-description-of-what-command-does>

Usage:
  /<command> <required> [optional]

Arguments:
  <arg1>     <description>
  <arg2>     <description>

Options:
  --flag     <description>

Examples:
  <example-1-with-explanation>
  <example-2-with-explanation>

Related:
  - <related-command-1>
  - <related-doc-1>
```

**Example (`/help plan`):**

```
Command: /plan

Description:
  Create a plan scaffold following the spec-driven workflow.
  Plans include steps, acceptance bundle, and risk sections.

Usage:
  /plan <topic>

Arguments:
  topic      Plan name (use kebab-case, e.g., checkout-flow)

File Output:
  docs/plans/<topic>-plan.md (or project-specific if in project context)

Examples:
  /plan checkout-flow
    Creates: docs/plans/checkout-flow-plan.md

  /plan user-authentication
    Creates: docs/plans/user-authentication-plan.md

Next Steps After /plan:
  1. Fill in plan sections
  2. Generate tasks: /tasks
  3. Begin implementation with TDD-first

Related:
  - /tasks - Generate and manage tasks
  - spec-driven.mdc - Full workflow documentation
  - tdd-first.mdc - Implementation guidelines
```

**Example (`/help tasks`):**

```
Command: /tasks

Description:
  Manage project tasks: list status, mark complete, or add new tasks.
  Auto-detects project from open files or uses explicit --project flag.

Usage:
  /tasks [--project <slug>] [--mark <id>] [--add "description"] [--list]

Options:
  --project <slug>       Specify project explicitly
  --mark <id>            Mark task as complete (e.g., 1.0, 2.3)
  --add "description"    Add new task
  --list                 List all tasks (default if no other options)

Examples:
  /tasks
    Auto-detect project, list all tasks with status

  /tasks --project productivity
    List tasks for productivity project

  /tasks --mark 2.0
    Mark task 2.0 as complete in current project

  /tasks --add "Write integration tests"
    Add new task to current project

Task ID Format:
  N.N or N.N.N (e.g., 1.0, 2.3, 3.1.2)

Related:
  - /plan - Create plan before generating tasks
  - project-lifecycle.mdc - Task management process
  - project-status.sh - Script to check project status
```

**Example (`/help pr`):**

```
Command: /pr

Description:
  Create a pull request via GitHub API or fallback to compare URL.
  Integrates with .cursor/scripts/pr-create.sh.

Usage:
  /pr [--title "text"] [--body "text"] [--base <branch>] [--head <branch>]

Options:
  --title "text"    PR title (default: derive from commit messages)
  --body "text"     PR body (default: use PR template)
  --base <branch>   Base branch (default: auto-detect, usually "main")
  --head <branch>   Head branch (default: current branch)

Prerequisites:
  - Git repository
  - GITHUB_TOKEN environment variable (recommended)
  - Committed changes

Examples:
  /pr
    Create PR with auto-detected title and template body

  /pr --title "Add feature X"
    Create PR with specific title

  /pr --title "Fix bug" --body "Handles edge case in parser"
    Create PR with title and custom body

Authentication:
  Set token: export GITHUB_TOKEN=<your-token>
  Get token: https://github.com/settings/tokens
  Without token: Script prints compare URL for manual PR creation

Related:
  - pr-create.sh - Underlying script
  - pr-label.sh - Add labels after creation
  - checks-status.sh - Monitor CI checks
  - assistant-git-usage.mdc - Full PR workflow
```

---

## Error Recovery Patterns

### Suggest Fix + Retry

**Pattern:** Error is fixable with simple action

**Format:**

```
Error: <problem>

Fix: <exact-command-to-run>

Then retry: <original-command>
```

**Example:**

```
Error: Branch not pushed to origin

Fix: git push -u origin feature-branch

Then retry: /pr --title "Add feature X"
```

### Offer Alternatives

**Pattern:** Multiple valid paths forward

**Format:**

```
<issue-description>

Options:
1. <option-1-description>
   Command: <command-1>

2. <option-2-description>
   Command: <command-2>

3. Cancel

Reply with "1", "2", or "3".
```

**Example:**

```
Uncommitted changes detected.

Options:
1. Commit changes first (recommended)
   Command: git add -A && git commit -m "..."

2. Continue anyway (PR won't include these changes)
   Command: /pr --title "..." (proceed as-is)

3. Cancel

Reply with "1", "2", or "3".
```

### Progressive Disclosure

**Pattern:** Complex error, show summary first

**Format:**

```
✗ <operation> failed

Summary: <one-line-explanation>

Details: (expand)

Troubleshooting:
1. <most-common-fix>
2. <second-most-common-fix>

[Show full output] (link or expand)
```

**Example:**

```
✗ PR creation failed

Summary: GitHub API returned 422 Validation Failed

Details:
  Error: base branch "main" does not exist
  Error: head branch "feature-branch" has no commits

Troubleshooting:
1. Verify base branch: git branch -a | grep main
   If missing: git fetch origin main
2. Push commits: git push -u origin feature-branch
3. Check repository settings and permissions

[Show full API response]
```

---

## Testing Strategy

### Unit Tests (Error Detection & Formatting)

```typescript
describe("Error handling", () => {
  it("detects unknown command", () => {
    const result = detectCommand("/unknown");
    expect(result.error).toBe("Unknown command: /unknown");
  });

  it("suggests closest match", () => {
    const suggestion = suggestCommand("palr", ["plan", "tasks", "pr"]);
    expect(suggestion).toBe("plan");
  });

  it("formats missing argument error", () => {
    const error = formatMissingArgError("plan", "topic");
    expect(error).toContain("Error: /plan requires a topic argument");
    expect(error).toContain("Example:");
  });

  it("formats invalid format error", () => {
    const error = formatInvalidFormatError("task ID", "abc", "N.N");
    expect(error).toContain("Invalid task ID format: abc");
    expect(error).toContain("Expected format: N.N");
  });
});
```

### Integration Tests (Error Scenarios)

1. **Unknown command → suggestion:**

   - Input: `/palr checkout-flow`
   - Detect unknown command
   - Calculate closest match
   - Display error with suggestion

2. **Missing argument → usage:**

   - Input: `/plan` (no topic)
   - Detect missing required argument
   - Display usage with example

3. **Execution failure → troubleshooting:**
   - Input: `/pr` (script fails)
   - Capture exit code and stderr
   - Parse error message
   - Display troubleshooting steps

---

## Implementation Notes

**This is behavioral guidance for the assistant, not code to implement.**

When errors occur:

1. Detect error type (unknown command, missing arg, invalid format, prerequisite, ambiguous, execution failure)
2. Format error message following patterns above
3. Provide actionable fix or alternatives
4. Include examples and related documentation references

**Consistency:**

- All error messages start with `Error:` or `Warning:` or `✗`
- Success messages start with `✓` or `ℹ`
- Use numbered lists for steps/options
- Include "Try again" or "Retry" guidance

**No repository code needed** - this is assistant behavior specification.

---

**Status:** Draft specification for task 5.0 (Error handling and help)

**Completed:** 2025-10-23

**Next:** Task 6.0 - Integration with intent-routing
