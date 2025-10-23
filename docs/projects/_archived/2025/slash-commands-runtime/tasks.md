## Tasks — Slash Commands Runtime

## Relevant Files

- `docs/projects/slash-commands-runtime/erd.md` — Canonical ERD (Lite)
- `.cursor/rules/intent-routing.mdc` — Intent routing and command mapping
- `.cursor/scripts/pr-create.sh` — PR creation script (used by `/pr`)

## Tasks

- [x] 1.0 Define command parser interface (priority: high)

  - [x] 1.1 Extract command name and arguments from message
    - Detection rules: message starts with `/` + known command
    - Command validation against known commands list
  - [x] 1.2 Handle quoted arguments and escape sequences
    - Single/double quote support
    - Escape sequences: `\"`, `\'`, `\\`
  - [x] 1.3 Return structured parse result: {command, args, rawInput}
    - Includes flags map and positional args
  - **Deliverable:** `docs/projects/slash-commands-runtime/command-parser-spec.md`

- [x] 2.0 Implement `/plan` command (priority: high) (depends on: 1.0)

  - [x] 2.1 Route to `spec-driven.mdc` workflow
    - Attach rule when `/plan` detected (highest priority)
  - [x] 2.2 Request consent before creating plan file
    - Consent prompt shows exact file path and template structure
    - Requires explicit "Yes/Proceed/Go ahead" response
  - [x] 2.3 Infer plan path from topic or use default `docs/plans/<topic>.md`
    - Project-aware: uses `docs/projects/<slug>/plans/` when in project context
    - Global: uses `docs/plans/` otherwise
  - [x] 2.4 Output plan path and next steps after creation
    - Success message with file path
    - Suggestions for `/tasks` command and TDD workflow
  - **Deliverable:** `docs/projects/slash-commands-runtime/plan-command-spec.md`

- [x] 3.0 Implement `/tasks` command (priority: high) (depends on: 1.0)

  - [x] 3.1 Route to `project-lifecycle.mdc` (Task List Process)
    - Attach rule when `/tasks` detected
  - [x] 3.2 Detect project context from open files or require explicit `--project` arg
    - Auto-detect from `docs/projects/<slug>/` pattern in open files
    - Require explicit `--project` flag if ambiguous or not found
  - [x] 3.3 Support: mark complete, add item, list tasks
    - `--mark <id>` to complete tasks
    - `--add "description"` to add new tasks
    - `--list` (default) to show status
  - [x] 3.4 Output tasks summary after updates
    - Completion percentage
    - Next suggested action
  - **Deliverable:** `docs/projects/slash-commands-runtime/tasks-command-spec.md`

- [x] 4.0 Implement `/pr` command (priority: high) (depends on: 1.0)

  - [x] 4.1 Route to `assistant-git-usage.mdc`
    - Attach rule when `/pr` detected (HIGHEST PRIORITY - bypasses normal consent gate)
  - [x] 4.2 Build command line for `.cursor/scripts/pr-create.sh` from args
    - Map `/pr` flags to script flags (--title, --body, --base, --head)
    - Handle multiline bodies with ANSI-C quoting
  - [x] 4.3 Request consent with exact command before execution
    - Show transparency message (slash command = explicit consent)
    - Display what will happen (push, create PR, URL)
  - [x] 4.4 Parse and display PR URL or compare URL fallback
    - Success: PR URL with next steps (labels, reviews, checks)
    - Fallback: Compare URL with manual instructions
    - Failure: Error output with troubleshooting
  - **Deliverable:** `docs/projects/slash-commands-runtime/pr-command-spec.md`

- [x] 5.0 Error handling and help (priority: medium) (depends on: 2.0, 3.0, 4.0)

  - [x] 5.1 Unknown command → suggest closest match or list available
    - Fuzzy matching with Levenshtein distance ≤ 2
    - List all available commands
  - [x] 5.2 Missing args → print usage for that command
    - Clear error message with expected format
    - Examples of valid usage
  - [x] 5.3 Execution failures → surface clear error with remediation steps
    - Numbered troubleshooting steps
    - Common causes and fixes
    - Reference to relevant documentation
  - **Deliverable:** `docs/projects/slash-commands-runtime/error-handling-spec.md`

- [x] 6.0 Integration with intent-routing (priority: medium) (depends on: 2.0, 3.0, 4.0)

  - [x] 6.1 Update `intent-routing.mdc` with runtime semantics section
    - Added "Runtime Semantics" subsection after slash commands list
    - Documented detection, execution flow, and consent gate behavior
  - [x] 6.2 Document command syntax and examples
    - Command specifications with arguments and options
    - Examples for each command
  - [x] 6.3 Add consent gate patterns for each command
    - Clarified slash command invocation = explicit consent
    - Documented transparency message behavior
    - Exception handling for missing prerequisites
  - **Deliverable:** Updated `.cursor/rules/intent-routing.mdc` + `integration-guide.md`

- [x] 7.0 Testing (priority: medium) (depends on: 5.0)

  - [x] 7.1 Add unit tests for command parser
    - Documented test scenarios for detection, parsing, validation
    - Expected inputs and outputs for all command types
  - [x] 7.2 Add integration tests for each command (with mocked file/script calls)
    - End-to-end flows for /plan, /tasks, /pr
    - Context detection and rule attachment validation
  - [x] 7.3 Add error path tests (missing args, unknown commands, execution failures)
    - All error types documented with expected responses
    - Integration test matrix covering failure modes
  - **Deliverable:** `docs/projects/slash-commands-runtime/testing-strategy.md`

- [x] 8.0 Optional enhancements (priority: low) [COMPLETED]
  - [x] 8.1 Workflow state tracking (e.g., plan created → suggest `/tasks`)
    - ✅ Already implemented via conversation history
    - ✅ Formalized in command specs with "Next Steps" sections
    - ✅ Context-aware suggestions based on recent commands
  - [x] 8.2 Command aliases (e.g., `/p` for `/plan`)
    - ✅ Implemented in command-parser-spec.md
    - ✅ Aliases: `/p` → `/plan`, `/t` → `/tasks`
    - ✅ Documented in help system
  - [x] 8.3 Auto-completion hints for command args
    - ❌ Not feasible (platform limitation - no partial input access)
    - ✅ Documented alternatives (fuzzy matching, post-send suggestions)
    - ✅ Recommendation for Cursor UI implementation provided
  - **Deliverable:**
    - `docs/projects/slash-commands-runtime/optional-enhancements.md` (updated with implementation status)
    - `docs/projects/slash-commands-runtime/command-parser-spec.md` (added alias support)
  - **Status:** Feasible items implemented, infeasible items documented with alternatives

## Notes

- Blocked on `role-phase-mapping` and `split-progress` projects for automated enforcement (optional enhancement, not a blocker for core functionality)
- Spun off from `docs/projects/intent-router/` archived items
