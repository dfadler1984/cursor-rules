# Command Discovery Rule

**Status**: ACTIVE  
**Phase**: Planning  
**Completion**: ~0%

---

## Overview

Create a rule that enables dynamic command discovery to replace the deleted static `commands.caps.mdc` file.

**Problem**: Users need to discover what slash commands are available (`/branch`, `/commit`, `/pr`) and what they do, but we don't want to maintain a static catalog that duplicates script documentation.

**Solution**: Create a lightweight rule that surfaces commands dynamically by reading from source files (`.cursor/commands/*.md`, script headers).

## Documents

- [**ERD**](./erd.md) — Requirements, options, and approach
- [**Tasks**](./tasks.md) — Execution checklist and progress tracking

## Context

This project emerged from removing `commands.caps.mdc` during the [tdd-scope-boundaries](../tdd-scope-boundaries/) project when we realized:

1. Static command catalogs duplicate documentation
2. Command discovery should be dynamic
3. Information should come from actual source files

## Goals

- [ ] Users can ask "what commands are available?" and get accurate answers
- [ ] Command descriptions come from `.cursor/commands/*.md` (no duplication)
- [ ] Slash commands and their backing scripts are clearly identified
- [ ] Rule stays <100 lines and follows repo quality standards

## Quick Start

See [tasks.md](./tasks.md) for execution steps.

## Related

- [tdd-scope-boundaries](../tdd-scope-boundaries/) — Where this need was discovered
- `.cursor/commands/` — Source files for command documentation
- `.cursor/rules/capabilities.mdc` — General capabilities discovery
