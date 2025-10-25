---
status: active  
owner: Dustin Fadler
created: 2025-10-23  
lastUpdated: 2025-10-24
---

# Engineering Requirements Document: Rules to Commands Conversion

Mode: Lite


## 1. Problem Statement

**Pattern Observation Context**: This project was triggered by pattern observation per `rule-maintenance.mdc`:

- Observed: 4+ rules contain creation/scaffolding workflows (not behavioral enforcement)
- Evidence: `create-erd.mdc`, `generate-tasks-from-erd.mdc`, `investigation-structure.mdc`, `test-plan-template.mdc`
- Opportunity: Cursor's command system (`.cursor/commands/*.md`) purpose-built for user-initiated workflows

The `.cursor/rules/` directory contains 60+ rule files that serve multiple purposes:

1. **Behavioral enforcement** (must/should requirements, quality standards)
2. **Creation workflows** (ERD creation, task generation, test plans)
3. **Templates and scaffolding** (project structure, investigation setup)

**Problem**: Creation workflows living as rules cause:

- Context bloat (loaded when not needed)
- Poor discoverability (users don't know workflows exist)
- Routing complexity (intent detection to attach creation rules)
- Mixed concerns (behavior + templates in same system)

**Opportunity**: Cursor's `/` command system (`.cursor/commands/*.md`) is purpose-built for user-initiated workflows.

## 2. Goals

### Primary

1. **Identify command candidates** — Clear criteria for what should be command vs rule
2. **Convert high-priority workflows** — Move creation/scaffolding to commands
3. **Preserve behavioral rules** — Keep enforcement logic in rules system
4. **Improve discoverability** — Users find workflows via `/` prefix
5. **Reduce context load** — Commands load on-demand, not automatically

### Secondary

1. **Measure adoption** — Track command usage over 20-30 operations
2. **Document patterns** — Create reusable decision framework
3. **Enable iteration** — Easy to add more commands based on usage

## 3. Current State

**Rules system** (`.cursor/rules/*.mdc`):

- 60+ rule files
- Mix of behavioral + procedural content
- Auto-attached via routing logic
- Always in context (for AlwaysApply) or conditionally attached

**Commands system** (`.cursor/commands/*.md`):

- Currently only `/project` command exists
- User-initiated via `/` prefix
- Zero context cost until invoked
- Purpose-built for workflows

**Example existing command**: `/project` creates new project structure (README, ERD, tasks)

## 4. Proposed Solution

### Decision Framework

**Convert to Command** when rule is:

- ✅ User-initiated workflow (not assistant-initiated)
- ✅ Creation/scaffolding task (generates files from template)
- ✅ Multi-phase process (with user checkpoints)
- ✅ Template-based output (predictable structure)
- ✅ Natural `/` invocation ("I want to create X")

**Keep as Rule** when rule is:

- ✅ Behavioral enforcement (must/should requirements)
- ✅ Quality standards (code style, testing, imports)
- ✅ Assistant decision logic (routing, intent classification)
- ✅ Validation and constraints (TDD gates, scope checks)
- ✅ Always-on guidance (applies continuously)

### High-Priority Conversions

1. **`/erd`** (from `create-erd.mdc`, 252 lines)

   - Clarifying questions workflow
   - Full vs Lite mode selection
   - Template generation

2. **`/tasks`** (from `generate-tasks-from-erd.mdc`, 232 lines)

   - Two-phase (parent tasks → "Go" → sub-tasks)
   - Natural follow-up to `/erd`
   - Clear user checkpoint

3. **`/investigation`** (from `investigation-structure.mdc`, 123 lines)

   - Complex project scaffolding
   - Folder structure creation
   - Specialized version of `/project`

4. **`/test-plan`** (from `test-plan-template.mdc`, 335 lines)
   - 7-section template
   - Hypothesis testing structure
   - Measurement protocol guidance

### Implementation Approach

**Phase 1: Create Commands**

1. Create `.cursor/commands/` directory (if not exists)
2. Create command files (`erd.md`, `tasks.md`, `investigation.md`, `test-plan.md`)
3. Extract workflow guidance from rules into command templates
4. Add usage examples and cross-references

**Phase 2: Update Rules**

1. Slim down original rules (remove template/workflow content)
2. Keep behavioral enforcement and validation
3. Add references to commands where appropriate
4. Update routing logic if needed

**Phase 3: Measure & Iterate**

1. Track command usage over 20-30 operations
2. Collect user feedback
3. Measure context efficiency improvements
4. Add more commands based on patterns

## 5. Success Criteria

### Must Have

- [ ] Decision framework documented with clear criteria
- [ ] 4 high-priority commands created and functional
- [ ] Original rules updated (behavioral only, reference commands)
- [ ] Commands discoverable via `/` prefix in Cursor
- [ ] Documentation includes usage examples

### Should Have

- [ ] Command usage >40% for creation workflows
- [ ] Workflow completion rate >80%
- [ ] Measurable context load reduction
- [ ] User feedback collected

### Nice to Have

- [ ] Additional commands identified from usage patterns
- [ ] Command templates reusable for future additions
- [ ] Integration with existing `/project` command

## 6. Non-Goals

- Replacing all rules with commands (behavioral rules stay)
- Changing routing logic substantially (commands are parallel system)
- Deprecating template rules immediately (gradual transition)
- Creating commands for edge case workflows (focus on high-usage)

## 7. Dependencies & Constraints

**Dependencies:**

- Cursor's `/` command system (`.cursor/commands/*.md`)
- Existing rule files (source material)
- Project structure conventions

**Constraints:**

- Commands must follow Cursor's format
- Rules still needed for behavioral enforcement
- Can't force command usage (user-initiated only)
- Must maintain backward compatibility during transition

**Technical Notes:**

- Commands are prompt templates (not runtime routing)
- `/` prefix loads template into chat
- Assistant still executes workflow (command provides guidance)

## 8. Open Questions

1. Should original rules be deprecated after commands created? → **No**, slim down but keep behavioral parts
2. How to handle users who still use natural language instead of commands? → **Both work**, commands just improve discoverability
3. Should we add command suggestions in rule enforcement messages? → **Good idea**, e.g., "Consider using `/erd` command"

## 9. Timeline

**Phase 1: Analysis** — 2 hours (COMPLETE)

- Review all rules
- Create decision framework
- Identify candidates

**Phase 2: Implementation** — 4-6 hours

- Create 4 high-priority commands
- Update original rules
- Add documentation

**Phase 3: Validation** — 1-2 weeks

- Measure command usage
- Collect feedback
- Iterate based on data

**Total**: ~1 day implementation + 1-2 weeks measurement

## 10. Related Work

- [ai-workflow-integration](../_archived/2025/ai-workflow-integration/) — Workflow improvements
- [investigation-docs-structure](../investigation-docs-structure/) — Structure patterns
- Existing `/project` command — Reference implementation
- [Cursor Commands Documentation](https://cursor.com/docs/agent/chat/commands) — Platform docs
**Links**: [README](./README.md) | [Tasks](./tasks.md) | [Analysis](./command-candidates-analysis.md)
