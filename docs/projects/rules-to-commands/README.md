# Rules to Commands Conversion

**Project**: rules-to-commands  
**Status**: ACTIVE  
**Created**: 2025-10-23  
**Owner**: Dustin Fadler

---

## Overview

Review all `.cursor/rules/*.mdc` files to identify which rules would work better as Cursor commands (`.cursor/commands/*.md`). Convert creation/scaffolding workflows to commands while preserving behavioral enforcement as rules.

## Goals

1. **Identify command candidates** — Rules that are procedural workflows vs behavioral enforcement
2. **Create decision framework** — Clear criteria for command vs rule
3. **Implement high-priority commands** — Create `.cursor/commands/*.md` for top candidates
4. **Measure effectiveness** — Track usage and context efficiency improvements

## Quick Links

- [ERD](./erd.md) — Full requirements and approach
- [Tasks](./tasks.md) — Execution checklist
- [Analysis](./command-candidates-analysis.md) — Detailed review and recommendations

## Current Status

**Phase**: Analysis Complete  
**Next**: Review findings and proceed to implementation

## Key Findings

### High-Priority Command Candidates

1. `/erd` — Create ERD (from `create-erd.mdc`)
2. `/tasks` — Generate tasks from ERD (from `generate-tasks-from-erd.mdc`)
3. `/investigation` — Create investigation project (from `investigation-structure.mdc`)
4. `/test-plan` — Create test plan (from `test-plan-template.mdc`)

### Rules That Stay as Rules

All behavioral enforcement remains:

- TDD & testing standards
- Assistant behavior (consent-first, scope-check)
- Code quality (code-style, refactoring)
- Meta-rules (rule-creation, rule-maintenance)

## Decision Framework

**Commands** (user-initiated workflows):

- Procedural step-by-step instructions
- Creation/scaffolding tasks
- Template-based outputs
- Multi-phase with checkpoints

**Rules** (behavioral enforcement):

- Quality standards and validation
- Assistant decision-making logic
- Constraints and boundaries
- Always-on guidance

## Success Criteria

- Command usage >40% for creation workflows
- Workflow completion >80%
- Measurable context load reduction
- Positive user feedback

## Monitoring/Self-Improvement Status

**Category**: Proactive improvement (not failure monitoring)

**Context**: This project was triggered by pattern observation from `rule-maintenance.mdc`:

- Observed pattern: Rules contain mixed concerns (behavioral + procedural workflows)
- Pattern count: 4+ rules with creation/scaffolding workflows
- Improvement opportunity: Cursor's command system purpose-built for user-initiated workflows

**Not documented in ACTIVE-MONITORING.md because**:

- Not monitoring for failures (routing, execution, workflow issues)
- Proactive organizational improvement
- Similar to investigation-docs-structure (structure improvement, not monitoring)

**Self-Improvement Alignment**:

- Follows pattern observation workflow from `rule-maintenance.mdc`
- Creates reusable decision framework
- Improves assistant capabilities discoverability

## Related Projects

- See [ai-workflow-integration](../ai-workflow-integration/) for workflow improvements
- See [rules-enforcement-investigation](../rules-enforcement-investigation/) for compliance patterns
- See [ACTIVE-MONITORING.md](../ACTIVE-MONITORING.md) for monitoring project scope definitions

---

**Navigation**: [Projects Index](../README.md) | [ERD](./erd.md) | [Tasks](./tasks.md)
