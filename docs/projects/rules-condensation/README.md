# Rules Condensation

**Goal**: Eliminate redundancy, reduce verbosity, and consolidate overlapping guidance across `.cursor/rules/` to improve rule clarity and reduce assistant context overhead.

## Quick Links

- [Engineering Requirements](./erd.md)

## Overview

The current rule set contains significant duplication and verbosity that increases context consumption and can lead to confusion. This project identifies and eliminates:

1. **Cross-rule redundancy** — Same guidance stated in multiple rules
2. **Internal verbosity** — Unnecessarily long explanations and examples
3. **Overlapping scopes** — Multiple rules covering the same domain
4. **Stale content** — Deprecated patterns still documented

## Target Areas

Based on rules-enforcement-investigation findings:

### High Priority (Most Overlap)

- **Consent gates** — `assistant-behavior.mdc`, `intent-routing.mdc`, `user-intent.mdc`
- **Git workflows** — `assistant-git-usage.mdc`, `git-slash-commands.mdc`, `github-api-usage.caps.mdc`
- **Testing suite** — `testing.mdc`, `tdd-first.mdc`, `test-quality.mdc`, `test-quality-js.mdc`, `test-quality-sh.mdc`

### Medium Priority

- **Project lifecycle** — `project-lifecycle.mdc`, `create-erd.mdc`, `generate-tasks-from-erd.mdc`
- **Rule maintenance** — `rule-creation.mdc`, `rule-maintenance.mdc`, `rule-quality.mdc`
- **Script guidance** — `shell-unix-philosophy.mdc`, `capabilities.mdc`

### Low Priority

- **Code style** — `code-style.mdc`, `imports.mdc`, `dependencies.mdc`
- **Platform docs** — `platform-capabilities.mdc`, `cursor-platform-capabilities.mdc`

## Success Metrics

- **Word count reduction**: Target 30-40% reduction across all rules
- **Rule consolidation**: Reduce total rule count by 10-15% through mergers
- **Validation**: Zero functionality loss (all current guidance still accessible)
- **Assistant performance**: Measurable improvement in context efficiency scores

## Status

**Phase**: Planning  
**Progress**: 0%

