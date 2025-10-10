# Engineering Requirements Document — Capabilities Rules Evaluation

Mode: Full

## 1. Introduction/Overview

Evaluate the relationship and value between two rules — `capabilities-discovery.mdc` and `capabilities.mdc` — and determine whether both are needed, how to better encode details, and what unique value (if any) `capabilities-discovery.mdc` provides.

## 2. Goals/Objectives

- Decide whether both rules are necessary or if they should be consolidated or more clearly delineated
- Identify improvements to encode capabilities details deterministically (structure, sources, output)
- Articulate the specific value of `capabilities-discovery.mdc` beyond the static catalog in `capabilities.mdc`

## 3. Questions to Answer

1. Do we need both rules: `.cursor/rules/capabilities-discovery.mdc` and `.cursor/rules/capabilities.mdc`?
2. Can we better encode some of these details (schema, sources, truncation, role-aware advice)?
3. What is the distinct value provided by `.cursor/rules/capabilities-discovery.mdc`?

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
- Output shape (candidate schema)
  - name, source (rules|mcp|local), summary, authRequired, enabled, notes (optional)
- Delineation proposal (candidate)
  - `capabilities.mdc`: human-oriented catalog of “what you can ask the assistant to do” (static, curated)
  - `capabilities-discovery.mdc`: discovery workflow and schema for assembling a live list (deterministic, tool-aware, safe)

## 7. Data Model and Storage

- Markdown rules and docs only; no databases
- Discovery output is presented in chat; no persistent data is required

## 8. Acceptance Criteria

- A short comparison table or bullets capturing purpose, triggers, outputs, and differences
- A concrete recommendation: keep both with scopes, or consolidate with a deprecation pointer
- A proposed encoding schema and truncation strategy
- A clear statement of the value of `capabilities-discovery.mdc`

## 9. Risks/Edge Cases

- Overlap causing user confusion — mitigate via deprecation header or explicit scopes
- Drift between static catalog and discovery guidance — mitigate via a “sync” note in `rule-maintenance.mdc`

## 10. Links

- `.cursor/rules/capabilities-discovery.mdc`
- `.cursor/rules/capabilities.mdc`
- `docs/projects/intent-router/erd.md` (routing context)
- `docs/projects/rule-quality/erd.md` (consolidation guidance)
