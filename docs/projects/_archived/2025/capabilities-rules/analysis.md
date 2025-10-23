# Capabilities Rules Analysis

**Created:** 2025-10-23  
**Purpose:** Compare current capabilities encoding and propose improvements

## Current State

### capabilities.mdc Structure

**Purpose:** Catalog what users can ask the assistant to do  
**Location:** `.cursor/rules/capabilities.mdc`  
**Size:** 196 lines  
**Attachment:** `alwaysApply: true`

**Sections:**

1. Rules management
2. Validation and automation
3. Engineering docs & planning
4. Git assistance
5. Intent routing & user intent
6. Loop/Deadlock safeguards
7. Rules automation
8. **Discovery (rules, MCP, local scripts)** — lines 94-102
9. Testing & TDD
10. Shell Scripts & Unix Philosophy
11. Imports & formatting
12. Security & workspace policy
13. Project lifecycle & archival
14. CI/tooling assistance
15. Validation gates & helpers
16. How to invoke
17. Script libraries & helpers
18. Adding new capabilities
19. Platform reference

**Discovery Section Current Format:**

```markdown
### Discovery (rules, MCP, local scripts)

- Ask: `@capabilities` or "What can you do?"
- Output: grouped bullets by source (rules|mcp|local), truncated with "N more…" when long
- Safety: read-only listing; never echo secrets; execution remains consent-gated
- Sources:
  - Rules: scan `.cursor/rules/*.mdc` for names/descriptions
  - MCP: list configured servers/tools/resources and auth state
  - Local: scan `.cursor/scripts/**/*.sh` top comments for descriptions
```

### Discovery Schema (from ERD)

**Proposed canonical schema:**

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

## Comparison & Analysis

### Purpose Alignment

**capabilities.mdc:**

- ✅ Human-oriented catalog
- ✅ Grouped by functional area
- ✅ Includes concrete script paths and examples
- ⚠️ Discovery section is informal guidance, not structured

**Discovery Schema (ERD):**

- ✅ Machine-parseable structure
- ✅ Includes auth/enabled state
- ⚠️ Not actually implemented anywhere yet

### Overlap Assessment

**No duplication detected:**

- `capabilities.mdc` = static catalog of known capabilities
- Discovery section = dynamic runtime behavior guidance
- Schema = proposed structure for discovery outputs (not yet used)

**Delineation:**

- `capabilities.mdc`: "What can you do?" → static human-readable list
- Discovery guidance: "How to discover dynamically" → scan rules/MCP/scripts
- Discovery schema: "What format for dynamic discovery?" → JSON structure

### Gaps Identified

1. **Discovery schema not enforced:** The schema exists in the ERD but isn't referenced in `capabilities.mdc`
2. **No cross-reference:** `capabilities.mdc` Discovery section doesn't link to the canonical schema
3. **Truncation strategy undefined:** "N more..." mentioned but no rules (e.g., show first 10, truncate at 20?)
4. **Role-aware advice missing:** ERD mentions "role-aware guidance hooks" but not defined

## Encoding Improvements (Proposal)

### 1. Formalize Discovery Schema in capabilities.mdc

Move the authoritative schema from the ERD into `capabilities.mdc` Discovery section:

````markdown
### Discovery (rules, MCP, local scripts)

- Ask: `@capabilities` or "What can you do?"
- Output: grouped bullets by source (rules|mcp|local), truncated with "N more…" when long
- Safety: read-only listing; never echo secrets; execution remains consent-gated

**Sources:**

- Rules: scan `.cursor/rules/*.mdc` for names/descriptions
- MCP: list configured servers/tools/resources and auth state
- Local: scan `.cursor/scripts/**/*.sh` top comments for descriptions

**Discovery Schema (canonical):**

All discovery outputs MUST conform to this schema:

\```json
{
"name": "string", // Capability or tool name
"source": "rules|mcp|local", // Source type
"summary": "string", // One-line description
"authRequired": boolean, // True if requires credentials
"enabled": boolean, // True if currently available
"notes": "string?" // Optional context (e.g., "requires GITHUB_TOKEN")
}
\```

**Truncation:** Show first 10 items per source; if >10, show "... and N more"  
**Grouping:** Always group by source (Rules → MCP → Local)  
**Secrets:** Never echo token values, API keys, or credentials in discovery output
````

### 2. Truncation Strategy

**Rules:**

- Show first 10 items per source category
- If more than 10, append: "... and N more <source> items (ask for full list)"
- Example: "... and 15 more local scripts (ask for full list)"

**Rationale:** Keeps output scannable while indicating additional capabilities exist

### 3. Role-Aware Advice (Defer to Other Rules)

**Not needed in capabilities.mdc:**

- Role/phase guidance belongs in `role-phase-mapping.mdc` (if exists)
- Or `intent-routing.mdc` for routing decisions
- `capabilities.mdc` should remain role-agnostic (just list capabilities)

**Action:** Remove "role-aware advice hooks" from future encoding discussions

## Decision: Keep Separate with Clear Scopes

**Recommendation: Do not consolidate**

**Rationale:**

- `capabilities.mdc` serves as human-oriented catalog (always attached)
- Discovery section provides runtime behavior guidance for dynamic scanning
- Schema belongs in Discovery section as authoritative reference
- No duplication, clear separation of concerns

**Scopes:**

- `capabilities.mdc` → "What can the assistant do?" (static catalog)
- Discovery section → "How to discover dynamically" (runtime behavior + schema)

## Proposed Changes

### 1. Update capabilities.mdc Discovery Section

Add the canonical schema and truncation rules inline (see "Encoding Improvements" above).

### 2. Update ERD to Reference capabilities.mdc

Change capabilities-rules ERD section 6 (Architecture/Design):

- Remove duplicate schema definition
- Add pointer: "Discovery schema is canonical in `capabilities.mdc` → Discovery section"

### 3. Mark Discovery Schema as Authoritative

Add note in `rule-maintenance.mdc`:

- "Discovery schema lives in `capabilities.mdc`; other ERDs should reference it, not redefine"

## Cross-References

**Files to update:**

- `.cursor/rules/capabilities.mdc` → Add schema + truncation
- `docs/projects/capabilities-rules/erd.md` → Remove duplicate schema, add pointer
- `.cursor/rules/rule-maintenance.mdc` → Add sync note (optional)

**Related projects:**

- `platform-capabilities-generic` will reference this schema for vendor-agnostic discovery

## Next Steps

1. ✅ Analysis complete
2. [ ] Update `capabilities.mdc` Discovery section with schema + truncation
3. [ ] Update capabilities-rules ERD to point to canonical schema
4. [ ] Run validation: `.cursor/scripts/rules-validate.sh`
5. [ ] Mark tasks complete in `tasks.md`

---

**Conclusion:** No consolidation needed. Improve encoding by formalizing schema in `capabilities.mdc` and removing duplication from ERD.
