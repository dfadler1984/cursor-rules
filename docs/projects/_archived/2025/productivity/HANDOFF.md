# Handoff Document — Automation Pair (Productivity + Slash Commands Runtime)

**Created:** 2025-10-23  
**For:** New chat session  
**Projects:** `productivity` → `slash-commands-runtime`

## Overview

Complete two related automation projects that streamline repetitive operations while preserving safety guardrails.

### Project 1: Productivity & Automation (Lite)

- **Goal:** Document automation guidance and script usage patterns
- **Complexity:** Low (3 tasks, mostly documentation)
- **Deliverable:** Examples and guidance for when to use scripts vs manual steps

### Project 2: Slash Commands Runtime (Lite)

- **Goal:** Implement runtime execution for `/plan`, `/tasks`, `/pr` commands
- **Complexity:** Medium-High (8 tasks, includes parser + execution + testing)
- **Deliverable:** Working slash command system with proper consent gates

## Why These Projects Are Paired

1. **Dependency:** Slash commands should follow automation patterns established in productivity guidance
2. **Shared context:** Both leverage `.cursor/scripts/` tooling (git, PR creation, preflight)
3. **Consistent UX:** Automation philosophy should be consistent across manual scripts and slash commands

## Prerequisites

- None blocked; both can start immediately
- Recommended: Complete `productivity` first to establish patterns, then `slash-commands-runtime`

## Key Files to Review

### Productivity Project

- [`docs/projects/productivity/erd.md`](./erd.md) — Requirements
- [`.cursor/rules/favor-tooling.mdc`](../../../.cursor/rules/favor-tooling.mdc) — Tooling-first philosophy
- [`.cursor/scripts/git-*.sh`](../../../.cursor/scripts/) — Example automation scripts

### Slash Commands Project

- [`docs/projects/slash-commands-runtime/erd.md`](../slash-commands-runtime/erd.md) — Requirements
- [`.cursor/rules/intent-routing.mdc`](../../../.cursor/rules/intent-routing.mdc) — Current slash command mappings
- [`.cursor/scripts/pr-create.sh`](../../../.cursor/scripts/pr-create.sh) — Example of script `/pr` will call

## Acceptance Criteria

### Productivity

- [ ] Example automations documented (branch naming, commit, PR create, preflight)
- [ ] Status update guidance (brief, high-signal) documented
- [ ] Guidance for when to use scripts vs manual steps
- [ ] Links added to README and progress docs

### Slash Commands Runtime

- [ ] Command parser implemented (handle quoted args, escape sequences)
- [ ] `/plan` command working (route to spec-driven.mdc, request consent, create file)
- [ ] `/tasks` command working (detect context, mark complete, list tasks)
- [ ] `/pr` command working (call pr-create.sh with consent, display URL)
- [ ] Error handling (unknown commands, missing args, execution failures)
- [ ] Documentation updated in `intent-routing.mdc`
- [ ] Integration tests for all commands

## Suggested Approach

### Phase 1: Productivity (Quick Win)

1. **Read current automation scripts** to understand patterns
2. **Document common automation scenarios** with examples
3. **Add guidance** on when to automate vs manual
4. **Update cross-references** in README

**Estimated effort:** 1-2 focused sessions

### Phase 2: Slash Commands Runtime (Technical Implementation)

1. **Design command parser interface** (parse `/command args` format)
2. **Implement `/plan` first** (simplest, file creation only)
3. **Implement `/tasks`** (context detection, task updates)
4. **Implement `/pr`** (script invocation, URL parsing)
5. **Add error handling** for all failure modes
6. **Write integration tests** for each command
7. **Update intent-routing.mdc** with runtime semantics

**Estimated effort:** 4-6 focused sessions

## Risk Notes

### Productivity

- **Low risk:** Documentation-only changes
- **Watch for:** Over-automation leading to hidden behavior

### Slash Commands Runtime

- **Medium risk:** Runtime execution requires careful consent gates
- **Watch for:**
  - Ambiguous context for `/tasks` (multiple projects open)
  - Missing `GITHUB_TOKEN` for `/pr` failures
  - Concurrent workflow state conflicts

## Related Projects

- **Dependencies:** None blocking
- **Influences:** Both align with `favor-tooling.mdc` philosophy
- **Cross-references:** `assistant-git-usage.mdc`, `spec-driven.mdc`, `project-lifecycle.mdc`

## Starting the Session

### Opening Prompt Template

```
I'm working on the Automation Pair (productivity + slash-commands-runtime projects).

Context:
- Read: docs/projects/productivity/HANDOFF.md
- Projects: docs/projects/productivity/ and docs/projects/slash-commands-runtime/

Starting with productivity project (documentation + examples), then slash-commands-runtime (implementation).

Let's begin with Phase 1: Review existing automation scripts and document patterns.
```

## Questions to Resolve

1. **Productivity:** Where should automation examples live? In the ERD, separate guide, or inline in scripts?
2. **Slash commands:** Should we track workflow state (plan → tasks suggestion) or keep stateless?
3. **Slash commands:** Do we need command aliases (e.g., `/p` for `/plan`)?

## Success Metrics

- Productivity: Clear guidance exists for when/how to use automation
- Slash commands: All 3 commands (`/plan`, `/tasks`, `/pr`) working with proper consent gates
- Tests: Integration tests pass for all command paths
- Documentation: `intent-routing.mdc` updated with runtime semantics

---

**Next Steps:** Start new chat, paste opening prompt template, review handoff doc context.
