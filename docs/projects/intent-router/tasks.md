## Tasks — ERD: Intent Router

## Relevant Files

- `docs/projects/intent-router/erd.md`
- `.cursor/rules/intent-routing.mdc`

## Todo

- [x] 1.0 Draft ERD skeleton with parsing/routing/gates
- [x] 2.0 Add example parses and clarify-on-ambiguity policy
- [x] 3.0 Link ERD from README and progress doc
- [x] 4.0 Maintain ERD "Last updated" date on future edits

## Gaps — Actionable

- [x] Document slash commands routing in `.cursor/rules/intent-routing.mdc` (cover `/plan`, `/tasks`, `/pr` mapping and consent gates)
- [x] Define router handoff contract shape in `.cursor/rules/intent-routing.mdc` (`{intent, targets, rule, gates, consentState}`) and reference in Integration Points
- [x] Add advisory note on role–phase mapping and split-progress prioritization in `.cursor/rules/intent-routing.mdc`
- [x] Add explicit trigger mapping for plan/specify/analyze → `spec-driven` in `.cursor/rules/intent-routing.mdc`
- [x] Remove duplicated `**/tasks/*.md` signal line in `.cursor/rules/intent-routing.mdc`

## Gaps — Blocked

- [ ] Add drawing-board triggers and integration notes in `.cursor/rules/intent-routing.mdc`
  - Blocked by: complete `docs/projects/drawing-board/erd.md` and its corresponding rule
- [ ] Implement automated enforcement for role–phase mapping and split-progress within routing decisions
  - Blocked by: complete `docs/projects/role-phase-mapping/erd.md` and `docs/projects/split-progress/erd.md`
- [ ] Support slash command runtime handling (execution semantics beyond documentation)
  - Blocked by: create and complete a new project for slash-commands runtime (e.g., `docs/projects/slash-commands/erd.md`)
