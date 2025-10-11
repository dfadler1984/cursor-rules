## Tasks — Slash Commands Runtime

## Relevant Files

- `docs/projects/slash-commands-runtime/erd.md` — Canonical ERD (Lite)
- `.cursor/rules/intent-routing.mdc` — Intent routing and command mapping
- `.cursor/scripts/pr-create.sh` — PR creation script (used by `/pr`)

## Tasks

- [ ] 1.0 Define command parser interface (priority: high)

  - [ ] 1.1 Extract command name and arguments from message
  - [ ] 1.2 Handle quoted arguments and escape sequences
  - [ ] 1.3 Return structured parse result: {command, args, rawInput}

- [ ] 2.0 Implement `/plan` command (priority: high) (depends on: 1.0)

  - [ ] 2.1 Route to `spec-driven.mdc` workflow
  - [ ] 2.2 Request consent before creating plan file
  - [ ] 2.3 Infer plan path from topic or use default `docs/plans/<topic>.md`
  - [ ] 2.4 Output plan path and next steps after creation

- [ ] 3.0 Implement `/tasks` command (priority: high) (depends on: 1.0)

  - [ ] 3.1 Route to `project-lifecycle.mdc` (Task List Process)
  - [ ] 3.2 Detect project context from open files or require explicit `--project` arg
  - [ ] 3.3 Support: mark complete, add item, list tasks
  - [ ] 3.4 Output tasks summary after updates

- [ ] 4.0 Implement `/pr` command (priority: high) (depends on: 1.0)

  - [ ] 4.1 Route to `assistant-git-usage.mdc`
  - [ ] 4.2 Build command line for `.cursor/scripts/pr-create.sh` from args
  - [ ] 4.3 Request consent with exact command before execution
  - [ ] 4.4 Parse and display PR URL or compare URL fallback

- [ ] 5.0 Error handling and help (priority: medium) (depends on: 2.0, 3.0, 4.0)

  - [ ] 5.1 Unknown command → suggest closest match or list available
  - [ ] 5.2 Missing args → print usage for that command
  - [ ] 5.3 Execution failures → surface clear error with remediation steps

- [ ] 6.0 Integration with intent-routing (priority: medium) (depends on: 2.0, 3.0, 4.0)

  - [ ] 6.1 Update `intent-routing.mdc` with runtime semantics section
  - [ ] 6.2 Document command syntax and examples
  - [ ] 6.3 Add consent gate patterns for each command

- [ ] 7.0 Testing (priority: medium) (depends on: 5.0)

  - [ ] 7.1 Add unit tests for command parser
  - [ ] 7.2 Add integration tests for each command (with mocked file/script calls)
  - [ ] 7.3 Add error path tests (missing args, unknown commands, execution failures)

- [ ] 8.0 Optional enhancements (priority: low)
  - [ ] 8.1 Workflow state tracking (e.g., plan created → suggest `/tasks`)
  - [ ] 8.2 Command aliases (e.g., `/p` for `/plan`)
  - [ ] 8.3 Auto-completion hints for command args

## Notes

- Blocked on `role-phase-mapping` and `split-progress` projects for automated enforcement (optional enhancement, not a blocker for core functionality)
- Spun off from `docs/projects/intent-router/` archived items
