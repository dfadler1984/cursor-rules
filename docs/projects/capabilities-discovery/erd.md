---
---

# Engineering Requirements Document — Capabilities Discovery (Lite)

[Links: Glossary](../../docs/glossary.md)

Links: `.cursor/rules/capabilities-discovery.mdc` | `docs/projects/capabilities-discovery/tasks.md` | `docs/projects/split-progress/erd.md`

## 1. Introduction/Overview

Provide a deterministic, discoverable index of abilities from repo rules, MCP servers, and local scripts.

## 2. Goals/Objectives

- List capabilities grouped by source (rules, MCP, local)
- Ask scope first; tailor next step per active role
- Redact secrets; discovery is read-only by default

## 3. Functional Requirements

- Scan `.cursor/rules/*.mdc` and local scripts for descriptors
- Query configured MCP servers for tools/resources; degrade gracefully if unauthenticated
- Output deterministic JSON-ish bullets with capped length

### 3.1 Canonical Discovery Schema (authoritative)

All discovery outputs MUST conform to this schema. Other ERDs (e.g., MCP Synergy) MUST reference this section and not redefine fields.

```json
{
  "name": "string",
  "source": "rules|mcp|local",
  "summary": "string",
  "authRequired": true,
  "enabled": true,
  "notes": "string?"
}
```

Rules:

- `name`: kebab-case identifier.
- `source`: one of `rules`, `mcp`, `local`.
- `summary`: ≤ 120 chars.
- `authRequired`: true if execution requires credentials; discovery remains read-only.
- `enabled`: true if available in the current environment/config.
- `notes`: optional; ≤ 140 chars; include deprecation/warnings.

## 4. Acceptance Criteria

- Includes schema `{ name, source, summary, authRequired, enabled, notes? }`
- Handles missing auth by surfacing a warning without erroring
- Provides a role-aware "next best step"

## 5. Risks/Edge Cases

- Large capability sets; cap output and indicate remainder
- MCP availability drift; discovery must not mutate

## 6. Rollout Note

- Owner: rules-maintainers
- Comms: Link from README and progress doc

## 7. Testing

- Run discovery with/without MCP auth and verify grouping and safety

## 8. Examples

Sample capability item (schema-filled):

```json
{
  "name": "rules-list",
  "source": "local",
  "summary": "List .cursor/rules with front matter",
  "authRequired": false,
  "enabled": true
}
```

Unauthenticated discovery:

"MCP servers detected but unauthenticated. Listing tool names only; enable auth for execution previews."

---

Owner: rules-maintainers

Last updated: 2025-10-02
