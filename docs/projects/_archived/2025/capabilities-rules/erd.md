# Engineering Requirements Document — Capabilities Rules Evaluation

Mode: Full

## 1. Introduction/Overview

Evaluate the relationship and value of `capabilities.mdc` (now includes a Discovery section), and determine how to better encode details.

## 2. Goals/Objectives

- Identify improvements to encode capabilities details deterministically (structure, sources, output)

## 3. Questions to Answer

1. Can we better encode some of these details (schema, sources, truncation, role-aware advice) inside `capabilities.mdc`?

## 4. Functional Requirements

1. Comparative analysis
   - Summarize each rule’s purpose, triggers, output format, and safety/consent stance
   - Identify overlap and gaps; propose delineation or consolidation
2. Encoding improvements
   - Propose a deterministic item schema and sources of truth (rules, MCP, local scripts)
   - Define truncation behavior and role-aware guidance hooks
3. Decision & follow-ups
   - Record a decision (keep both with clear scopes vs consolidate)
   - If consolidating or deprecating, add a deprecation header and pointer in the superseded file

## 5. Non-Functional Requirements

- Keep outputs concise and scannable; avoid duplication across rules
- Preserve consent-first execution; discovery remains read-only and safe
- Maintain easy maintenance: clear front matter and cross-references

## 6. Architecture/Design

- Sources
  - Rules: scan `.cursor/rules/*.mdc` for names/one-liners
  - MCP: enumerate configured servers/tools (read-only state only)
  - Local scripts: read top comments (e.g., `# Description:`) and tag as manual
- Output shape: see **canonical Discovery Schema** in `.cursor/rules/capabilities.mdc` → Discovery section
- `capabilities.mdc`: human-oriented catalog with Discovery section (includes schema, sources, truncation rules)

### Discovery Schema Reference

**The authoritative Discovery Schema lives in:**  
`.cursor/rules/capabilities.mdc` → Discovery (rules, MCP, local scripts) → Discovery Schema (canonical)

Other ERDs (e.g., MCP Synergy, platform-capabilities-generic) should reference that section, not redefine the schema.

## 7. Data Model and Storage

- Markdown rules and docs only; no databases
- Discovery output is presented in chat; no persistent data is required

## 8. Acceptance Criteria

- A short comparison table or bullets capturing purpose, triggers, outputs, and differences
- A proposed encoding schema and truncation strategy (now lives in `capabilities.mdc`)

## 9. Risks/Edge Cases

- Overlap causing user confusion — mitigate via deprecation header or explicit scopes
- Drift between static catalog and discovery guidance — mitigate via a “sync” note in `rule-maintenance.mdc`

## 10. Links

- `.cursor/rules/capabilities.mdc`
- `docs/projects/intent-router/erd.md` (routing context)
- `docs/projects/rule-quality/erd.md` (consolidation guidance)
