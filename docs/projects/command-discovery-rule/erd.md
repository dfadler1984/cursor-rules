---
status: active
owner: repo-maintainers
created: 2025-10-22
---

# Engineering Requirements Document — Command Discovery Rule

## 1. Problem Statement

Deleted `commands.caps.mdc` because it was a static, redundant catalog that duplicated information from scripts and command files. However, we still need a way for users to discover:

- What slash commands are available (`/branch`, `/commit`, `/pr`, etc.)
- What each command does
- What scripts back each command
- How to use commands properly

**Current gap**: No dynamic mechanism for command discovery after deleting the static file.

## 2. Goals

### Primary

- Create a rule that enables dynamic command discovery when users ask
- Surface command information from actual sources (`.cursor/commands/*.md`, script headers)
- Avoid duplicating command documentation

### Secondary

- Make command discovery contextual (show relevant commands based on conversation)
- Include script details (what they do, parameters, examples)

## 3. Current State

**What exists**:

- Command files: `.cursor/commands/branch.md`, `commit.md`, `pr.md`
- Scripts: `.cursor/scripts/git-branch-name.sh`, `git-commit.sh`, `pr-create.sh`
- Consent policy in `assistant-behavior.mdc` → "Slash commands = explicit consent"

**What's missing**:

- Rule to guide discovery behavior
- Pattern for surfacing commands dynamically
- Integration with `@capabilities` discovery

## 4. Proposed Solutions

### Option A: Lightweight Discovery Rule

**Approach**:

- Create `command-discovery.mdc` with triggers and patterns
- When user asks "what commands?" → read `.cursor/commands/*.md` and surface
- Include script details from headers
- Keep rule under 100 lines

**Pros**:

- Simple, focused rule
- Uses existing command files as source of truth
- No duplication

**Cons**:

- Requires reading multiple files on demand
- Could be slow if many command files exist

### Option B: Extend `capabilities.mdc`

**Approach**:

- Add command discovery section to existing `capabilities.mdc`
- Document pattern for surfacing commands
- Reference `.cursor/commands/` directory

**Pros**:

- Consolidates discovery in one place
- Already have `@capabilities` pattern

**Cons**:

- Makes `capabilities.mdc` larger
- Mixes general capabilities with commands

### Option C: Intent Routing Extension

**Approach**:

- Add command discovery trigger to `intent-routing.mdc`
- Route "what commands?" → read and surface `.cursor/commands/*.md`
- No new rule file

**Pros**:

- Uses existing routing infrastructure
- Minimal new code

**Cons**:

- Adds more to already-large routing rule
- Command discovery is distinct from intent routing

## 5. Success Criteria

### Must Have

- [ ] User can ask "what commands are available?" and get accurate list
- [ ] Command descriptions come from actual source files (no duplication)
- [ ] Slash commands (`/branch`, `/commit`, `/pr`) are surfaced
- [ ] Script backing each command is identified

### Should Have

- [ ] Command discovery includes usage examples
- [ ] Script parameters and flags are explained
- [ ] Contextual commands (show relevant ones based on conversation)

### Nice to Have

- [ ] Interactive command help (ask follow-ups about specific commands)
- [ ] Script source code snippets for complex commands

## 6. Non-Goals

- Not creating a new static command catalog (we just deleted that)
- Not documenting every possible script (focus on slash commands)
- Not building a CLI help system (this is for AI assistant discovery)

## 7. Dependencies & Constraints

**Dependencies**:

- Existing command files in `.cursor/commands/*.md`
- Script documentation in headers (`.cursor/scripts/*.sh`)
- Consent policy in `assistant-behavior.mdc`

**Constraints**:

- Rule should be <100 lines (per `rule-quality.mdc`)
- Must not duplicate content from command files
- Should integrate with existing `@capabilities` pattern

## 8. Open Questions

1. Should command discovery be in a new rule or extend an existing one?
2. How detailed should script documentation be in discovery responses?
3. Should we surface all commands or just slash commands?
4. What triggers should invoke command discovery (just "what commands?" or more)?
5. Should this integrate with `.cursor/scripts/capabilities-sync.sh`?

## 9. Timeline

**Phase 1**: 1-2 hours — Design & draft rule

- Decide on approach (new rule vs extend existing)
- Write rule with discovery patterns
- Define triggers

**Phase 2**: 1 hour — Implementation & testing

- Test discovery with various user queries
- Ensure script details surface correctly
- Validate no duplication

**Phase 3**: 0.5 hours — Documentation & validation

- Update related rules if needed
- Run `rules-validate.sh`
- Update `capabilities.mdc` if command discovery rule is separate

**Total**: 2-3 hours

## 10. Related Work

**Related rules**:

- `capabilities.mdc` — General capabilities discovery
- `assistant-behavior.mdc` — Slash command consent policy
- `intent-routing.mdc` — Routing patterns

**Related files**:

- `.cursor/commands/branch.md`, `commit.md`, `pr.md`
- `.cursor/scripts/git-branch-name.sh`, `git-commit.sh`, `pr-create.sh`

**Context**:

- Deleted `commands.caps.mdc` to avoid static duplication
- Need dynamic discovery to replace it
