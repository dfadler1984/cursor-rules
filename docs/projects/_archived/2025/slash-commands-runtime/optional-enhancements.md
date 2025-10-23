# Optional Enhancements — Slash Commands Runtime

**Purpose:** Future improvements beyond MVP

**Status:** COMPLETED (feasible items implemented, infeasible items documented)

**Note:** Core functionality (tasks 1.0-7.0) is complete. Optional enhancements evaluated for technical feasibility and completed where practical.

---

## 8.1 Workflow State Tracking ✅

**Status:** ALREADY IMPLEMENTED

**Goal:** Remember context across commands to provide smarter suggestions

**Technical Reality:** Assistant naturally maintains conversation history within a session, enabling contextual suggestions without explicit state management.

**Example scenarios:**

1. **Plan → Tasks flow:**

   ```
   User: /plan checkout-flow
   Assistant: ✓ Plan created: docs/plans/checkout-flow-plan.md

   [State stored: last_plan = "checkout-flow"]

   User: /tasks
   Assistant: Would you like to generate tasks from the "checkout-flow" plan? (Yes/No)
   ```

2. **Tasks → PR flow:**

   ```
   User: /tasks --mark 5.0
   Assistant: ✓ All tasks complete for productivity project!

   [State stored: project_complete = "productivity"]

   User: /pr
   Assistant: Creating PR for productivity project completion? (Yes/No)
   ```

**Implementation notes:**

- ✅ Already working via conversation history
- ✅ Each command spec includes "Next Steps" suggestions
- ✅ Context-aware suggestions based on recent commands
- ✅ No explicit state storage needed

**Examples in current specs:**

- `/plan` → suggests `/tasks` after plan creation
- `/tasks` (all complete) → suggests `/pr` for completion
- `/pr` (success) → suggests labels, reviews, checks

**Complexity:** Low (leverages existing conversation context)

**Value:** High (implemented at no additional cost)

**Conclusion:** Feature already functional, formalized in command specifications.

---

## 8.2 Command Aliases ✅

**Status:** IMPLEMENTED

**Goal:** Allow shorter aliases for frequently used commands

**Proposed aliases:**

| Alias | Full Command    | Rationale             |
| ----- | --------------- | --------------------- |
| `/p`  | `/plan`         | Quick planning        |
| `/t`  | `/tasks`        | Quick task management |
| `/pr` | (already short) | No alias needed       |

**Usage examples:**

```
/p checkout-flow    → Same as /plan checkout-flow
/t --mark 2.0       → Same as /tasks --mark 2.0
```

**Implementation notes:**

- Map aliases → full commands in parser
- Help system shows both forms
- Aliases optional (full commands always work)

**Complexity:** Low (simple mapping in parser)

**Value:** Moderate (convenience for power users, no learning burden)

**Implementation:** Added to `command-parser-spec.md` with alias mapping rules

**Conclusion:** Implemented. Aliases available for use, help system documents both forms.

---

## 8.3 Auto-completion Hints ❌

**Status:** NOT FEASIBLE (platform limitation)

**Goal:** Suggest arguments as user types command

**Technical Reality:** Assistant does not have access to partial input. Only complete messages (after Enter) are visible.

**Example interactions:**

```
User types: /plan
Assistant:
  /plan <topic>

  Example: /plan checkout-flow

  Recent topics:
    - user-authentication
    - api-refactor
```

```
User types: /tasks --project prod
Assistant:
  Did you mean: productivity ?

  Available projects:
    - productivity
    - slash-commands-runtime
    - rules-enforcement-investigation
```

```
User types: /pr --title "Add
Assistant:
  (waiting for closing quote)

  Tip: Use quotes for multi-word titles
```

**Why not feasible:**

```
User types: /plan checkou... [still typing]
Assistant: [CANNOT SEE - no message sent yet]

User types: /plan checkout-flow [presses Enter]
Assistant: [NOW VISIBLE - but already complete]
```

**Platform limitation:** Assistant only receives complete messages after user sends them. Real-time completion would require Cursor UI-level features.

**Alternatives (already implemented):**

- ✅ Fuzzy matching on typos (error-handling-spec.md)
- ✅ Post-send suggestions ("Did you mean...?")
- ✅ Help hints after errors
- ✅ Usage examples in error messages

**Recommendation for Cursor:** Implement completion at UI level (like VSCode command palette) using command specs as source.

**Conclusion:** Not feasible for assistant behavior. Requires platform-level implementation.

---

## 8.4 Additional Future Enhancements

### Command History

**Goal:** Recall previous commands with arrow keys or `/history`

**Example:**

```
User: /history
Assistant:
  Recent commands:
  1. /plan checkout-flow (5 minutes ago)
  2. /tasks --mark 2.0 (2 minutes ago)
  3. /pr --title "Add feature X" (just now)

  Re-run: /history <number>
```

**Value:** Moderate (convenience, fewer typos on repeated commands)

### Batch Operations

**Goal:** Run multiple commands in sequence

**Example:**

```
User: /batch
  /plan checkout-flow
  /tasks --project productivity
  /pr --title "Complete checkout flow"
/end
```
