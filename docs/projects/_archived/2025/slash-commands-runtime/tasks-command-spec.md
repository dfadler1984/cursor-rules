# `/tasks` Command Implementation

**Purpose:** Manage project tasks when user types `/tasks [options]`

**Status:** Implementation specification for assistant behavior

---

## Command Syntax

```
/tasks [--project <slug>] [--mark <id>] [--list] [--add <description>]
```

**All arguments optional:**

- `--project <slug>` - Specify project (default: auto-detect from open files)
- `--mark <id>` - Mark task as complete (e.g., "1.0", "2.3")
- `--list` - List all tasks with status (default if no other flags)
- `--add <description>` - Add new task (requires project context)

---

## Detection & Routing

### 1. Detect Command

**Pattern:** Message starts with `/tasks` (with or without options)

**Examples:**

```
/tasks                              → Valid (auto-detect project, list tasks)
/tasks --project productivity       → Valid (explicit project)
/tasks --mark 2.0                   → Valid (mark task complete)
/tasks --list                       → Valid (explicit list)
/tasks --add "Document examples"    → Valid (add new task)
```

### 2. Route to Workflow

**Attach rule:** `project-lifecycle.mdc` (Task List Process section)

**Trigger:** `/tasks` command detected

---

## Execution Flow

### Step 1: Parse Options

**Parse command:**

```typescript
Input: "/tasks --project productivity --mark 2.0"
→ {
    command: "tasks",
    project: "productivity",
    mark: "2.0",
    list: false,
    add: null
  }
```

**Defaults:**

- If no options: `--list` is implied
- If `--mark` or `--add`: project auto-detection required (or explicit `--project`)

### Step 2: Detect Project Context

**Auto-detection logic:**

1. Check open/focused files for project path pattern:
   - `docs/projects/<slug>/` → project slug is `<slug>`
2. Check recently edited files (in session)
3. If ambiguous or not found: require explicit `--project` flag

**Examples:**

```
Open file: docs/projects/productivity/erd.md
/tasks
→ Auto-detect: productivity project

Open file: README.md (root)
/tasks
→ Error: Cannot auto-detect project, use --project <slug>

Multiple projects in session
/tasks --mark 2.0
→ Error: Ambiguous project context, use --project <slug>
```

**Error (ambiguous context):**

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

### Step 3: Validate Project & Tasks File

**Check project exists:**

```bash
Path: docs/projects/<slug>/tasks.md
```

**If not found:**

```
Error: Project not found: <slug>

Available projects:
  - productivity
  - slash-commands-runtime
  - rules-enforcement-investigation
  [... list up to 10 active projects ...]

Use: /tasks --project <valid-slug>
```

**If tasks.md missing:**

```
Error: Tasks file not found: docs/projects/<slug>/tasks.md

This project exists but has no tasks file.

Would you like to:
1. Create tasks.md with basic structure
2. Choose a different project

Reply with "1" or "2" to continue.
```

### Step 4: Execute Operation

#### Operation: List Tasks (default)

**Read tasks file:**

```bash
docs/projects/<slug>/tasks.md
```

**Parse tasks:**

- Count total tasks: `- [ ]` or `- [x]`
- Count completed: `- [x]`
- Extract task IDs and descriptions
- Calculate completion percentage

**Output format:**

```
Project: <slug>
Status: active (from ERD front matter)
Tasks: 5 total, 3 completed (60%)

## Completed
- [x] 1.0 Define command parser interface
- [x] 2.0 Implement `/plan` command
- [x] 3.0 Implement `/tasks` command

## Pending
- [ ] 4.0 Implement `/pr` command
- [ ] 5.0 Error handling and help

Next suggested action: Complete task 4.0
```

**Respect task hierarchy:**

- Show parent tasks with sub-tasks indented
- Show completion status for parent (all children complete = parent complete)

#### Operation: Mark Task Complete

**Syntax:** `/tasks --mark <task-id>`

**Process:**

1. Parse task ID (e.g., "2.0", "3.1.2")
2. Find matching task in tasks.md
3. Replace `- [ ]` with `- [x]` for that task
4. Request consent before making change

**Consent prompt:**

```
Slash command: /tasks --mark 2.0

This will:
  File: docs/projects/<slug>/tasks.md
  Change: Mark task 2.0 as complete
    - [ ] 2.0 Implement `/plan` command
    →
    - [x] 2.0 Implement `/plan` command

Proceed?
```

**After marking complete:**

```
✓ Task 2.0 marked complete in <slug> project

Updated tasks:
  Completed: 4/10 (40% → 50%)

Next suggested action: Begin task 3.0
```

**Error (task not found):**

```
Error: Task 2.0 not found in docs/projects/<slug>/tasks.md

Available tasks:
  - [ ] 1.0 Define command parser interface
  - [x] 3.0 Implement `/tasks` command
  - [ ] 4.0 Implement `/pr` command

Use: /tasks --mark <valid-task-id>
```

**Error (already complete):**

```
Task 2.0 is already marked complete.

Would you like to:
1. Mark it incomplete (un-check)
2. View task details
3. Cancel

Reply with "1", "2", or "3".
```

#### Operation: Add Task

**Syntax:** `/tasks --add "Task description"`

**Process:**

1. Parse task description from quoted string
2. Determine next task ID (e.g., if last is 3.0, next is 4.0)
3. Append to tasks.md under `## Todo` section
4. Request consent before adding

**Consent prompt:**

```
Slash command: /tasks --add "Add integration tests"

This will:
  File: docs/projects/<slug>/tasks.md
  Add: - [ ] 4.0 Add integration tests

Proceed?
```

**After adding:**

```
✓ Task added to <slug> project

Added:
  - [ ] 4.0 Add integration tests

Total tasks: 10 → 11
```

**Optional (future):**

- Support sub-task creation: `/tasks --add "Sub-task description" --parent 3.0`
- Support priority: `/tasks --add "..." --priority high`

---

## Integration with Other Commands

### After completing all tasks

**Detect:** All tasks in `tasks.md` marked complete

**Suggest:**

```
✓ All tasks complete for <slug> project!

Next steps:
1. Run validation: bash .cursor/scripts/project-lifecycle-validate-scoped.sh <slug>
2. Complete project: bash .cursor/scripts/project-complete.sh <slug>
3. Generate summary: bash .cursor/scripts/final-summary-generate.sh --project <slug> --year <YYYY>

Or use: /complete to orchestrate full completion workflow
```

### Integration with `/plan`

**Pattern:** User created plan, now listing tasks

**Detect:** Plan file exists, tasks file doesn't

**Suggest:**

```
Plan exists but no tasks yet.

Would you like to:
1. Generate tasks from plan: (manual process - read plan and create tasks)
2. Create empty tasks file

Reply with "1" or "2" to continue.
```

---

## Error Handling

### No Project Context

**Input:** `/tasks` (no project detectable)

**Response:**

```
Error: Cannot determine project context

Open a file in a project directory or specify explicitly:

Usage: /tasks --project <slug>

Example: /tasks --project productivity
```

### Invalid Task ID Format

**Input:** `/tasks --mark invalid-id`

**Response:**

```
Error: Invalid task ID format: invalid-id

Task IDs should follow pattern: N.N or N.N.N
  Examples: 1.0, 2.3, 3.1.2

Use: /tasks --list to see available tasks
```

### Multiple Operations Requested

**Input:** `/tasks --mark 2.0 --add "New task"`

**Response:**

```
Error: Only one operation allowed per command

Choose one:
  /tasks --mark 2.0
  /tasks --add "New task"
  /tasks --list
```

---

## Testing Strategy

### Unit Tests (Parse & Validate)

```typescript
describe("/tasks command", () => {
  it("parses project flag", () => {
    const result = parseTasksCommand("/tasks --project productivity");
    expect(result.project).toBe("productivity");
  });

  it("parses mark flag", () => {
    const result = parseTasksCommand("/tasks --mark 2.0");
    expect(result.mark).toBe("2.0");
  });

  it("defaults to list when no flags", () => {
    const result = parseTasksCommand("/tasks");
    expect(result.list).toBe(true);
  });

  it("detects project from file path", () => {
    const project = detectProjectContext(["docs/projects/productivity/erd.md"]);
    expect(project).toBe("productivity");
  });

  it("errors on ambiguous context", () => {
    expect(() =>
      detectProjectContext([
        "docs/projects/productivity/erd.md",
        "docs/projects/slash-commands-runtime/tasks.md",
      ])
    ).toThrow("Ambiguous project context");
  });
});
```

### Integration Tests (End-to-End)

1. **List tasks:**

   - Detect `/tasks` or `/tasks --list`
   - Auto-detect project from open files
   - Read tasks.md
   - Parse and format task list
   - Output with completion percentage

2. **Mark task complete:**

   - Parse `/tasks --mark 2.0`
   - Find task in tasks.md
   - Request consent
   - Update file (replace `[ ]` with `[x]`)
   - Output success message

3. **Add task:**
   - Parse `/tasks --add "Description"`
   - Determine next task ID
   - Request consent
   - Append to tasks.md
   - Output success message

---

## Implementation Notes

**This is behavioral guidance for the assistant, not code to implement.**

When the assistant sees `/tasks [options]`:

1. Parse command options
2. Detect or require project context
3. Validate project and tasks file exist
4. Execute operation (list/mark/add)
5. Request consent for modifications
6. Output results and suggest next actions

**Project context detection:**

- Check focused/open files for `docs/projects/<slug>/` pattern
- Check recently edited files in session
- Require explicit `--project` if ambiguous

**Task file format:**

- Tasks are checkboxes: `- [ ]` (pending) or `- [x]` (completed)
- Task IDs follow pattern: N.N or N.N.N (e.g., 1.0, 2.3, 3.1.2)
- Hierarchical structure supported (parent/sub-tasks)

**No repository code needed** - this is assistant behavior specification.

---

**Status:** Draft specification for task 3.0 (Implement `/tasks` command)

**Completed:** 2025-10-23

**Next:** Task 4.0 - Implement `/pr` command
