# Tasks — Command Discovery Rule

**Status**: ACTIVE | Phase: Planning | 0% Complete

---

## Phase 1: Design & Planning

- [ ] 1.0 Decide on approach

  - [ ] 1.1 Review options (new rule vs extend existing vs routing)
  - [ ] 1.2 Choose approach based on constraints (rule size, duplication)
  - [ ] 1.3 Document decision rationale

- [ ] 1.5 Define discovery patterns

  - [ ] 1.5.1 List trigger phrases ("what commands?", "available commands", etc.)
  - [ ] 1.5.2 Define response format (list? grouped? detailed?)
  - [ ] 1.5.3 Decide scope (all commands? slash commands only? scripts?)

- [ ] 1.7 Design rule structure
  - [ ] 1.7.1 Draft rule outline (sections, examples)
  - [ ] 1.7.2 Define integration points (capabilities.mdc, intent-routing.mdc)
  - [ ] 1.7.3 Plan front matter (globs, alwaysApply, description)

## Phase 2: Implementation

- [ ] 2.0 Write rule file

  - [ ] 2.1 Create rule file with chosen approach
  - [ ] 2.2 Add discovery triggers and patterns
  - [ ] 2.3 Document how to surface commands from source files
  - [ ] 2.4 Add examples of discovery responses

- [ ] 2.5 Test discovery behavior

  - [ ] 2.5.1 Test "what commands are available?"
  - [ ] 2.5.2 Test "what does /branch do?"
  - [ ] 2.5.3 Test "show me git commands"
  - [ ] 2.5.4 Verify script details surface correctly

- [ ] 2.7 Validate against constraints
  - [ ] 2.7.1 Check rule length (<100 lines per rule-quality.mdc)
  - [ ] 2.7.2 Verify no duplication with command files
  - [ ] 2.7.3 Run rules-validate.sh

## Phase 3: Integration & Documentation

- [ ] 3.0 Update related rules

  - [ ] 3.1 Update capabilities.mdc if new rule created
  - [ ] 3.2 Update intent-routing.mdc if routing added
  - [ ] 3.3 Cross-reference assistant-behavior.mdc for slash commands

- [ ] 3.5 Validation & cleanup
  - [ ] 3.5.1 Run rules-validate.sh --autofix
  - [ ] 3.5.2 Test end-to-end discovery flow
  - [ ] 3.5.3 Document any open questions or future improvements

## Related Files

- `.cursor/commands/branch.md`, `commit.md`, `pr.md`
- `.cursor/rules/capabilities.mdc`
- `.cursor/rules/assistant-behavior.mdc`
- `.cursor/rules/intent-routing.mdc`
