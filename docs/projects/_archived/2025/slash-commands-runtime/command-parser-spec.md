# Command Parser Specification

**Purpose:** Define how to detect and parse slash commands from user messages for runtime execution.

**Scope:** This is a behavioral specification for assistant logic, not code to be implemented in the repository.

---

## Detection Rules

### When to Detect Slash Commands

**Trigger:** User message starts with `/` followed by a known command word

**Pattern:** `/command [args...]`

**Known Commands:**

- `/plan <topic>` - Create plan scaffold (alias: `/p`)
- `/tasks [options]` - Manage project tasks (alias: `/t`)
- `/pr [options]` - Create pull request
- `/commit [options]` - Create conventional commit (future)
- `/branch [options]` - Generate branch name (future)

**Command Aliases:**

| Alias | Full Command | Notes                 |
| ----- | ------------ | --------------------- |
| `/p`  | `/plan`      | Quick planning        |
| `/t`  | `/tasks`     | Quick task management |

**Alias Resolution:**

- Aliases are resolved before command validation
- Help system shows both forms
- Errors reference full command name for clarity

### Detection Algorithm

1. **Trim** leading/trailing whitespace from user message
2. **Check prefix**: Does message start with `/`?
3. **Extract command word**: Characters after `/` until first space or end
4. **Resolve aliases**: Map `/p` → `/plan`, `/t` → `/tasks`
5. **Validate**: Is command word in known commands list?
6. **If yes**: Parse as slash command
7. **If no**: Treat as normal message (might be filepath or other content)

---

## Parsing Rules

### Command Structure

```
/command [--flag value] [--flag] [positional-arg...]
```

**Components:**

- **Command name**: Required, follows `/`
- **Flags**: Optional, start with `--`, may have values
- **Positional args**: Optional, any args not associated with flags

### Argument Parsing

**Quoted Arguments:**

- Single quotes: `'text with spaces'`
- Double quotes: `"text with spaces"`
- Preserve content between quotes as single argument

**Escape Sequences:**

- `\"` → literal quote in double-quoted string
- `\'` → literal quote in single-quoted string
- `\\` → literal backslash

**Examples:**

```bash
/plan checkout-flow
→ command: "plan", args: ["checkout-flow"]

/p checkout-flow
→ alias resolved to "plan", args: ["checkout-flow"]

/pr --title "Fix bug in parser" --body "Handles edge cases"
→ command: "pr", args: ["--title", "Fix bug in parser", "--body", "Handles edge cases"]

/tasks --project productivity
→ command: "tasks", args: ["--project", "productivity"]

/t --mark 2.0
→ alias resolved to "tasks", args: ["--mark", "2.0"]
```

### Parse Result Structure

Return structured object:

```typescript
interface ParseResult {
  command: string; // "plan" | "tasks" | "pr"
  args: string[]; // All arguments (flags + values + positional)
  rawInput: string; // Original input for error reporting
  flags: Record<string, string | boolean>; // Parsed flags map
  positional: string[]; // Non-flag arguments
}
```

**Example:**

```typescript
Input: "/pr --title \"Fix bug\" --draft"
Output: {
  command: "pr",
  args: ["--title", "Fix bug", "--draft"],
  rawInput: "/pr --title \"Fix bug\" --draft",
  flags: {
    title: "Fix bug",
    draft: true
  },
  positional: []
}
```

---

## Error Handling

### Unknown Command

**Input:** `/unknown-command args`

**Response:**

```
Unknown command: /unknown-command

Available commands:
  /plan <topic>        Create plan scaffold
  /tasks [options]     Manage project tasks
  /pr [options]        Create pull request

Did you mean: /plan ?
```

### Missing Required Argument

**Input:** `/plan`

**Response:**

```
Error: /plan requires a topic argument

Usage: /plan <topic>

Example: /plan checkout-flow
```

### Invalid Flag

**Input:** `/pr --invalid-flag value`

**Response:**

```
Error: Unknown flag --invalid-flag for /pr command

Valid flags for /pr:
  --title TEXT      PR title (required)
  --body TEXT       PR body (optional)
  --base BRANCH     Base branch (optional)
  --head BRANCH     Head branch (optional)

Example: /pr --title "Add feature X" --body "Description"
```

---

## Integration with Consent Gates

### Execution Flow

1. **Parse** command → validate syntax
2. **Route** to appropriate workflow (attach relevant rules)
3. **Request consent** with exact operations to be performed
4. **Execute** only after explicit consent

### Consent Prompt Format

```
Slash command detected: /pr --title "Add feature X"

This will:
  1. Push current branch to origin (if needed)
  2. Call: .cursor/scripts/pr-create.sh --title "Add feature X" --body "..."
  3. Display PR URL or compare URL fallback

Proceed?
```

**User must respond:** "Yes" / "Proceed" / "Go ahead" to continue

---

## Command-Specific Parsing

### `/plan <topic>`

**Syntax:** `/plan <topic>`

**Required:**

- `topic` - Plan name (kebab-case recommended)

**Optional:** None for MVP

**Example:**

```
/plan checkout-flow
→ Create docs/plans/checkout-flow.md or project-specific plan file
```

### `/tasks [options]`

**Syntax:** `/tasks [--project <slug>] [--mark <task-id>] [--list]`

**Optional:**

- `--project <slug>` - Specify project (default: auto-detect from open files)
- `--mark <task-id>` - Mark task as complete (e.g., "1.0", "2.3")
- `--list` - List all tasks with status

**Examples:**

```
/tasks
→ Auto-detect project, show summary

/tasks --project productivity
→ Show tasks for productivity project

/tasks --mark 2.0
→ Mark task 2.0 as complete in current project
```

### `/pr [options]`

**Syntax:** `/pr [--title <text>] [--body <text>] [--base <branch>] [--head <branch>]`

**Optional:**

- `--title <text>` - PR title (default: derive from commit messages)
- `--body <text>` - PR body (default: use template)
- `--base <branch>` - Base branch (default: auto-detect)
- `--head <branch>` - Head branch (default: current branch)

**Examples:**

```
/pr
→ Create PR with auto-detected title/body from commits

/pr --title "Add feature X"
→ Create PR with specific title

/pr --title "Fix bug" --body "Handles edge case in parser"
→ Create PR with title and body
```

---

## Testing Strategy

### Unit Tests (Parse Logic)

Test parsing without execution:

```typescript
describe("Command Parser", () => {
  it("parses simple command", () => {
    expect(parse("/plan checkout-flow")).toEqual({
      command: "plan",
      args: ["checkout-flow"],
      rawInput: "/plan checkout-flow",
      flags: {},
      positional: ["checkout-flow"],
    });
  });

  it("parses quoted arguments", () => {
    expect(parse('/pr --title "Fix bug"')).toEqual({
      command: "pr",
      args: ["--title", "Fix bug"],
      rawInput: '/pr --title "Fix bug"',
      flags: { title: "Fix bug" },
      positional: [],
    });
  });

  it("rejects unknown command", () => {
    expect(() => parse("/unknown")).toThrow("Unknown command: /unknown");
  });
});
```

### Integration Tests (End-to-End)

Test command detection → routing → execution:

1. **Detect** slash command in message
2. **Attach** appropriate rules (spec-driven.mdc, project-lifecycle.mdc, assistant-git-usage.mdc)
3. **Request** consent with exact operations
4. **Execute** workflow (mocked file/script calls)
5. **Verify** output matches expectations

---

## Implementation Notes

**This is guidance for assistant behavior, not code to write.**

The assistant should:

1. Detect slash commands at message start
2. Parse arguments using the rules above
3. Route to appropriate workflow rules
4. Request consent before execution
5. Provide clear error messages on failures

**No new repository code needed** - this is behavioral logic for the assistant to follow.

---

**Status:** Draft specification for task 1.0 (Define command parser interface)

**Next Steps:**

1. Review and refine this spec
2. Implement detection behavior in assistant responses
3. Add integration tests validating command workflows
