# Integration Guide — Slash Commands Runtime

**Purpose:** Document how to integrate runtime semantics into `intent-routing.mdc`

**Status:** Implementation guidance

---

## Changes Required to intent-routing.mdc

### Section: Slash Commands (lines ~126-147)

**Current state:** Lists slash commands with routing destinations

**Add:** Runtime behavior documentation after the command list

**New subsection to add:**

```markdown
### Runtime Semantics

**Detection:**

- Commands detected when message starts with `/` + known command word
- Known commands: `/plan`, `/tasks`, `/pr` (future: `/commit`, `/branch`)
- See: `docs/projects/slash-commands-runtime/command-parser-spec.md`

**Execution Flow:**

1. **Parse** command and arguments (handle quoted strings, escape sequences)
2. **Validate** syntax and prerequisites
3. **Request consent** with exact operations (slash command = explicit consent per assistant-behavior.mdc)
4. **Execute** workflow with attached rules
5. **Display** results and suggest next steps

**Command Specifications:**

- `/plan` - See: `docs/projects/slash-commands-runtime/plan-command-spec.md`
- `/tasks` - See: `docs/projects/slash-commands-runtime/tasks-command-spec.md`
- `/pr` - See: `docs/projects/slash-commands-runtime/pr-command-spec.md`

**Error Handling:**

- See: `docs/projects/slash-commands-runtime/error-handling-spec.md`

**Testing:**

- Parser: Command detection, argument parsing, validation
- Integration: End-to-end workflows with mocked file/script operations
- See: Each command spec for test scenarios
```

---

## Changes Required to git-slash-commands.mdc

**Current state:** Describes prompt template system (not runtime routing)

**Action:** Add deprecation notice or clarification

**Suggested addition (at top):**

```markdown
## Relationship to Runtime Execution

**Two systems coexist:**

1. **Prompt Templates** (`.cursor/commands/` directory)

   - User-initiated guidance via `/` prefix in Cursor
   - Loads template content for reference
   - Status: READY FOR IMPLEMENTATION (this file)

2. **Runtime Execution** (Assistant behavior)
   - Detects `/command` patterns in messages
   - Executes workflows with consent gates
   - Status: ACTIVE (see slash-commands-runtime project)

**When to use each:**

- Templates: User wants guidance on script usage
- Runtime: User wants immediate execution (e.g., `/pr --title "..."`)

**See:** `docs/projects/slash-commands-runtime/` for runtime implementation details
```

---

## Command Syntax Documentation

### Consolidated Command Reference

**Add to intent-routing.mdc or create separate reference:**

```markdown
## Slash Command Reference

### /plan

**Purpose:** Create plan scaffold following spec-driven workflow

**Syntax:**
```

/plan <topic>

```

**Arguments:**
- `topic` - Plan name (kebab-case recommended)

**Output:**
- File: `docs/plans/<topic>-plan.md` (or project-specific)
- Template: Steps, Acceptance Bundle, Risks sections

**Examples:**
```

/plan checkout-flow
/plan user-authentication

```

**See:** `docs/projects/slash-commands-runtime/plan-command-spec.md`

---

### /tasks

**Purpose:** Manage project tasks (list, mark complete, add new)

**Syntax:**
```

/tasks [--project <slug>] [--mark <id>] [--add "description"] [--list]

```

**Options:**
- `--project <slug>` - Specify project (default: auto-detect)
- `--mark <id>` - Mark task complete (e.g., "2.0")
- `--add "description"` - Add new task
- `--list` - List tasks (default)

**Examples:**
```

/tasks
/tasks --project productivity
/tasks --mark 2.0
/tasks --add "Write integration tests"

```

**See:** `docs/projects/slash-commands-runtime/tasks-command-spec.md`

---

### /pr

**Purpose:** Create pull request via GitHub API

**Syntax:**
```

/pr [--title "text"] [--body "text"] [--base <branch>] [--head <branch>]

```

**Options:**
- `--title "text"` - PR title (default: derive from commits)
- `--body "text"` - PR body (default: use template)
- `--base <branch>` - Base branch (default: auto-detect)
- `--head <branch>` - Head branch (default: current)

**Prerequisites:**
- Git repository
- GITHUB_TOKEN environment variable (recommended)

**Examples:**
```

/pr
/pr --title "Add feature X"
/pr --title "Fix bug" --body "Handles edge case"

````

**See:** `docs/projects/slash-commands-runtime/pr-command-spec.md`

---

## Error Handling Reference

**Add cross-reference:**

```markdown
### Error Handling

**Unknown command:**
- Suggests closest match (Levenshtein distance ≤ 2)
- Lists available commands

**Missing arguments:**
- Shows usage with examples
- Provides expected format

**Execution failures:**
- Surfaces error with troubleshooting steps
- References relevant documentation

**See:** `docs/projects/slash-commands-runtime/error-handling-spec.md`
````

---

## Consent Gate Clarification

**Update assistant-behavior.mdc reference:**

```markdown
### Slash Commands and Consent

**Per intent-routing.mdc line 128:**

Slash command invocation = explicit consent to execute workflow.

**Behavior:**

- No additional "Proceed?" prompt after slash command detected
- Still show transparency message: "This will: ..."
- Execute workflow immediately after transparency message

**Example:**
```

User: /pr --title "Add feature X"
