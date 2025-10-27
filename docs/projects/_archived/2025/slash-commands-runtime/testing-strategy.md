# Testing Strategy — Slash Commands Runtime

**Purpose:** Validation approach for slash command behavior

**Status:** Test scenarios and validation strategies

---

## Testing Scope

Since slash commands are **assistant behavioral specifications** (not code to implement), testing means:

1. **Validation scenarios** - Expected behaviors for each command
2. **Integration patterns** - How commands interact with rules and scripts
3. **Error path coverage** - All error conditions documented with expected responses

---

## Test Scenarios by Command

### Command Parser (Task 1.0)

**Unit-level validation:**

```typescript
// Detection
Input: "/plan checkout-flow"
Expected: { command: "plan", args: ["checkout-flow"], rawInput: "..." }

Input: "/unknown-command"
Expected: Error "Unknown command: /unknown-command"

// Quoted arguments
Input: '/pr --title "Fix bug in parser"'
Expected: { command: "pr", title: "Fix bug in parser" }

// Escape sequences
Input: '/pr --body "Line 1\nLine 2"'
Expected: Body contains real newline character
```

**Validation method:**

- Manual testing: Send command, verify parse result
- Document: Expected input → output mappings
- Coverage: Valid commands, unknown commands, quoted args, escape sequences

**Test locations:**

- See: `command-parser-spec.md` → Testing Strategy section

---

### /plan Command (Task 2.0)

**Integration scenarios:**

1. **Basic plan creation:**

   ```
   Input: /plan checkout-flow
   Expected:
   - Attach spec-driven.mdc rule
   - Request consent with file path
   - Create docs/plans/checkout-flow-plan.md
   - Display success message with next steps
   ```

2. **Project-aware path:**

   ```
   Context: Open file in docs/projects/productivity/
   Input: /plan automation-examples
   Expected:
   - Create docs/projects/productivity/plans/automation-examples-plan.md
   ```

3. **Missing topic:**

   ```
   Input: /plan
   Expected: Error with usage example
   ```

4. **File already exists:**
   ```
   Input: /plan existing-topic
   Expected: Warning with options (open, rename, overwrite)
   ```

**Validation method:**

- Execute command in assistant
- Verify file created with correct template
- Check consent prompt appears
- Validate error messages match spec

**Test locations:**

- See: `plan-command-spec.md` → Testing Strategy section

---

### /tasks Command (Task 3.0)

**Integration scenarios:**

1. **List tasks (auto-detect project):**

   ```
   Context: docs/projects/productivity/erd.md open
   Input: /tasks
   Expected:
   - Auto-detect project: productivity
   - Display task list with completion %
   - Show next suggested action
   ```

2. **Mark task complete:**

   ```
   Input: /tasks --project productivity --mark 2.0
   Expected:
   - Request consent
   - Display updated completion %
   ```

3. **Add new task:**

   ```
   Input: /tasks --add "Write integration tests"
   Expected:
   - Determine next task ID
   - Request consent
   ```

4. **Ambiguous context:**
   ```
   Context: Multiple projects open
   Input: /tasks
   Expected: Error requiring explicit --project flag
   ```

**Validation method:**

- Open project files, execute command
- Verify auto-detection works
- Check file modifications match spec
- Validate error messages

**Test locations:**

- See: `tasks-command-spec.md` → Testing Strategy section

---

### /pr Command (Task 4.0)

**Integration scenarios:**

1. **Create PR (full automation):**

   ```
   Context: Git repo, GITHUB_TOKEN set, clean status
   Input: /pr --title "Add feature X"
   Expected:
   - Validate prerequisites
   - Build pr-create.sh command
   - Request consent
   - Execute script
   - Parse PR URL from output
   - Display success with next steps
   ```

2. **Fallback (no token):**

   ```
   Context: No GITHUB_TOKEN
   Input: /pr
   Expected:
   - Warning about fallback
   - Execute script
   - Display compare URL
   - Show token setup instructions
   ```

3. **Uncommitted changes:**

   ```
   Context: Dirty working tree
   Input: /pr
   Expected:
   - Warning with uncommitted files list
   - Offer options (commit first, continue, cancel)
   ```

4. **Script failure:**
   ```
   Context: Invalid branch
   Input: /pr
   Expected:
   - Capture error output
   - Display troubleshooting steps
   - Reference documentation
   ```

**Validation method:**

- Set up git repo with/without token
- Execute command in different states
- Verify script called with correct args
- Check error handling

**Test locations:**

- See: `pr-command-spec.md` → Testing Strategy section

---

### Error Handling (Task 5.0)

**Error path scenarios:**

1. **Unknown command:**

   ```
   Input: /palr checkout-flow
   Expected:
   - Detect unknown command
   - Calculate closest match (edit distance ≤ 2)
   - Suggest: "Did you mean: /plan ?"
   ```

2. **Missing required argument:**

   ```
   Input: /plan
   Expected:
   - Error message
   - Usage with examples
   - Tip about format
   ```

3. **Invalid format:**

   ```
   Input: /tasks --mark invalid-id
   Expected:
   - Error explaining expected format
   - Examples of valid IDs
   - Suggestion to list tasks
   ```

4. **Execution failure:**
   ```
   Input: /pr (script fails)
   Expected:
   - Parse stderr
   - Display numbered troubleshooting steps
   - Reference docs
   ```

**Validation method:**

- Deliberately trigger each error type
- Verify message format matches spec
- Check suggestions are helpful

**Test locations:**

- See: `error-handling-spec.md` → Testing Strategy section

---

## Integration Test Matrix

| Command               | Context            | Expected Outcome                                          | Validates          |
| --------------------- | ------------------ | --------------------------------------------------------- | ------------------ |
| `/plan checkout-flow` | No project         | Create `docs/plans/checkout-flow-plan.md`                 | Basic creation     |
| `/plan example`       | In productivity/   | Create `docs/projects/productivity/plans/example-plan.md` | Project-aware      |
| `/plan`               | Any                | Error: missing topic                                      | Required args      |
| `/tasks`              | One project open   | List tasks for that project                               | Auto-detection     |
| `/tasks`              | Multiple projects  | Error: ambiguous context                                  | Context validation |
| `/tasks --mark 2.0`   | Valid project      | Mark task 2.0 complete                                    | Task modification  |
| `/tasks --add "Test"` | Valid project      | Add new task                                              | Task creation      |
| `/pr --title "X"`     | Git repo + token   | Create PR, show URL                                       | Full automation    |
| `/pr`                 | Git repo, no token | Show compare URL                                          | Fallback           |
| `/pr`                 | Not git repo       | Error: not in repo                                        | Prerequisite check |
| `/unknown`            | Any                | Suggest closest match                                     | Error recovery     |

---

## Validation Checklist

For each command:

- [ ] **Detection** works (parser identifies command correctly)
- [ ] **Argument parsing** handles quoted strings, flags, positional args
- [ ] **Validation** catches missing/invalid arguments
- [ ] **Consent request** shows before modifications
- [ ] **Execution** follows spec (files created, scripts called, etc.)
- [ ] **Output** matches expected format (success messages, next steps)
- [ ] **Error handling** provides actionable guidance

For integration:

- [ ] **Rule attachment** correct (spec-driven, project-lifecycle, assistant-git-usage)
- [ ] **Context detection** works (project, git repo, open files)
- [ ] **Cross-command flow** natural (plan → tasks → pr)
- [ ] **Consent gates** respect slash command = explicit consent policy

---

## Manual Testing Workflow

### Setup

1. Open Cursor workspace
2. Ensure repository scripts are executable
3. Set `GITHUB_TOKEN` if testing `/pr`

### Test Each Command

**For /plan:**

```
1. Type: /plan test-feature
2. Verify: Consent prompt shows
3. Confirm: "Proceed"
4. Check: File created in docs/plans/
5. Validate: Template structure correct
```

**For /tasks:**

```
1. Open file in docs/projects/productivity/
2. Type: /tasks
3. Verify: Auto-detects productivity project
4. Check: Task list displays with %
5. Type: /tasks --mark 1.0
6. Confirm: Task 1.0 marked complete
```

**For /pr:**

```
1. Ensure git repo + token set
2. Type: /pr --title "Test PR"
3. Verify: Consent shows script command
4. Confirm: "Proceed"
5. Check: PR URL displayed
6. Validate: Next steps shown
```

---

## Regression Testing

When updating command specs:

1. **Re-validate core scenarios** - Each command's happy path
2. **Check error paths** - Unknown command, missing args, failures
3. **Verify integration** - Rule attachment, context detection
4. **Test consent behavior** - Transparency messages, bypass logic

---

## Documentation as Tests

**Key principle:** Each spec file includes test scenarios

**Locations:**

- `command-parser-spec.md` → Unit tests
- `plan-command-spec.md` → Integration tests
- `tasks-command-spec.md` → Integration tests
- `pr-command-spec.md` → Integration tests
- `error-handling-spec.md` → Error path tests

**Coverage:** All scenarios documented = test suite defined

---

## Success Criteria

**Command execution:**

- ✓ All commands parse arguments correctly
- ✓ Validation catches all documented error cases
- ✓ Consent requests appear before modifications
- ✓ Execution follows documented flow
- ✓ Output matches expected format

**Integration:**

- ✓ Rules attach at correct times
- ✓ Context detection works (project, git, files)
- ✓ Commands suggest next steps naturally
- ✓ Error messages are actionable

**Error handling:**

- ✓ Unknown commands suggest alternatives
- ✓ Missing args show usage examples
- ✓ Execution failures provide troubleshooting

---

**Status:** Complete test strategy documented

**Completed:** 2025-10-23

**Next:** Task 8.0 - Optional enhancements (workflow state, aliases, completion hints)
