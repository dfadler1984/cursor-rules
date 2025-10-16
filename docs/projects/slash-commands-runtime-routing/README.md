# Slash Commands: Runtime Routing Attempt

**Parent**: [rules-enforcement-investigation](../rules-enforcement-investigation/)  
**Related**: [assistant-self-testing-limits](../assistant-self-testing-limits/)  
**Status**: NOT VIABLE (platform constraint)  
**Created**: 2025-10-16 (split from parent)

---

## Overview

Attempted to implement runtime routing via slash commands (e.g., user types `/commit` in chat, assistant routes to `git-commit.sh`).

**Hypothesis**: Explicit slash commands would create stronger forcing function than intent routing.

**Outcome**: ❌ NOT VIABLE - Cursor's `/` prefix is for prompt templates, not runtime message routing.

---

## Key Discovery

**Platform constraint**: Cursor intercepts `/` before messages reach assistant

- User types `/status` → Cursor creates `.cursor/commands/status` (prompt template file)
- This is **correct Cursor behavior** per [Cursor 1.6 docs](https://cursor.com/changelog/1-6)
- Our approach was wrong: tried runtime routing; Cursor uses prompt templates

**Time saved**: One real usage attempt (30 seconds) found design mismatch that 50 test trials (8-12 hours) would have missed.

---

## Documents

- **[discovery.md](discovery.md)** - Pre-test analysis and design
- **Decision**: [../rules-enforcement-investigation/decisions/slash-commands.md](../rules-enforcement-investigation/decisions/slash-commands.md)
- **Test plan**: [../rules-enforcement-investigation/tests/experiment-slash-commands.md](../rules-enforcement-investigation/tests/experiment-slash-commands.md)
- **Protocol**: [../rules-enforcement-investigation/protocols/slash-commands-phase3.md](../rules-enforcement-investigation/protocols/slash-commands-phase3.md) (not executed)
- **Platform analysis**: [../assistant-self-testing-limits/platform-constraints.md](../assistant-self-testing-limits/platform-constraints.md)

---

## Contribution to Parent

**Primary finding**: Runtime routing approach wrong; prompt template approach unexplored.

**Meta-findings**:
- Gap #8: Testing paradox (self-testing has observer bias)
- Gap #10: Analytical error (overcorrected to "not viable")

**Pattern identified**: Read platform docs before implementing; real usage > prospective testing.

---

## Future Direction

**Unexplored**: Cursor's actual prompt template design

See [../rules-enforcement-investigation/analysis/prompt-templates/exploration.md](../rules-enforcement-investigation/analysis/prompt-templates/exploration.md) for potential future approach.

---

## Status

**Phase**: Complete (not viable)  
**Outcome**: Runtime routing abandoned; prompt templates remain option  
**Current approach**: H1 (alwaysApply) at 96% compliance sufficient

