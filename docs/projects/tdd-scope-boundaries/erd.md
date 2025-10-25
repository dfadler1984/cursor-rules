---
status: active
owner: repo-maintainers
lastUpdated: 2025-10-11
---

# Engineering Requirements Document — TDD Scope Boundaries

Mode: Lite


## 1. Introduction/Overview

Fix overapplication of TDD-first rules to non-code changes (documentation, configuration, etc.) while maintaining TDD discipline for actual code changes.

**Context**: User reports the assistant treats every task as TDD-required, including documentation updates which don't need tests. Need to define clear scope boundaries for when TDD applies.

### Uncertainty / Assumptions

- [NEEDS CLARIFICATION: What specific non-code changes triggered TDD gates incorrectly?]
- Assumption: Current TDD rules in `tdd-first.mdc` define scope but may be unclear or over-broad

## 2. Goals/Objectives

- Define clear, deterministic boundaries for TDD applicability
- Maintain TDD discipline for all code changes (no exceptions)
- Exempt documentation, configs, and other non-code artifacts
- Create easy-to-reference decision tree for assistant

## 3. User Stories

- As a user, I want documentation updates to proceed without creating tests
- As a user, I want all code changes to follow TDD without exceptions
- As a maintainer, I want clear rules that eliminate ambiguity about TDD scope

## 4. Functional Requirements

### 4.1 Scope Definition

1. **TDD Required (hard gate)**:

   - Source code: `**/*.{ts,tsx,js,jsx,mjs,cjs}`
   - Shell scripts: `**/*.sh`
   - Any file that defines executable logic or behavior
   - Excludes: `node_modules/**`, `dist/**`, `build/**`, `web/dist/**`

2. **TDD Not Required**:

   - Documentation: `**/*.md`, `**/*.mdx`
   - Configuration: `**/*.json`, `**/*.yaml`, `**/*.yml`, `**/*.toml`
   - Rules: `.cursor/rules/**/*.mdc`
   - Templates: `**/*.template.*`
   - Static assets: `**/*.css`, `**/*.html` (unless logic-bearing)

3. **Ambiguous (needs clarification)**:
   - ERDs/tasks: pure documentation (no TDD)
   - GitHub workflows: declarative YAML (no TDD, but validation via linter)
   - Type-only files: `**/*.d.ts` (no executable logic, no TDD)

### 4.2 Decision Tree

```
Is the file a source file with executable logic?
├─ Yes → TDD required (Red → Green → Refactor)
└─ No → Is it documentation, config, or static?
   ├─ Yes → TDD not required, proceed with edit
   └─ Unclear → Ask once: "Does this file define behavior that should be tested?"
```

### 4.3 Implementation

1. Update `tdd-first.mdc` with explicit include/exclude globs
2. Add decision tree as reference for assistant
3. Create pre-edit scope check: "Is this file in TDD scope?"
4. Remove TDD gates from doc/config editing workflows

## 5. Non-Functional Requirements

- **Deterministic**: Same file type always yields same TDD requirement
- **No false negatives**: All code changes must trigger TDD gate
- **Clear communication**: When TDD is skipped, assistant states why ("docs/not in TDD scope")
- **Backward compatible**: Existing TDD workflows continue working

## 6. Architecture/Design

### Current State (from `tdd-first.mdc`)

- Scope: "all maintained sources" (ambiguous)
- Hard gate: "before editing any maintained source" (too broad?)
- No explicit exemptions for docs/configs

### Proposed Changes

1. **Explicit scope definition**

   ```typescript
   const TDD_SCOPE = {
     include: ["**/*.{ts,tsx,js,jsx,mjs,cjs}", "**/*.sh"],
     exclude: ["node_modules/**", "dist/**", "build/**", "web/dist/**"],
     exemptions: [
       "**/*.md",
       "**/*.json",
       "**/*.yaml",
       "**/*.yml",
       ".cursor/rules/**/*.mdc",
     ],
   };
   ```

2. **Pre-edit check**

   ```
   Before edit:
   1. Check file against TDD_SCOPE
   2. If in scope → Red → Green → Refactor
   3. If exempt → proceed with edit, note "docs/not in TDD scope"
   4. If ambiguous → ask once
   ```

3. **Status transparency**
   - In status updates, note: "TDD: in-scope" or "TDD: exempt (documentation)"

## 7. Data Model and Storage

### TDD Scope Decision

```typescript
{
  "file": "path/to/file.ext",
  "tddRequired": boolean,
  "reason": "source-code|shell-script|documentation|configuration|static-asset",
  "decision": "auto|clarified"
}
```

## 8. API/Contracts

### Scope Check Output

```json
{
  "file": "docs/projects/example/erd.md",
  "tddRequired": false,
  "reason": "documentation",
  "exemptionRule": "**/*.md"
}
```

## 9. Integrations/Dependencies

- Related: `tdd-first.mdc` (core TDD rules)
- Related: `testing.mdc` (test structure when TDD applies)
- Related: `code-style.mdc` (applies to code files)
- Scripts: Consider adding `.cursor/scripts/tdd-scope-check.sh <file>` for validation

## 10. Edge Cases and Constraints

- **Markdown with embedded code**: `.md` files with code blocks (TDD exempt, but code blocks could have logic?)
- **Config generators**: Scripts that generate configs (TDD required for script, not generated output)
- **Type-only files**: `.d.ts` files with no runtime behavior (TDD not required)
- **Hybrid files**: Files mixing logic and docs (e.g., README with inline examples)

## 11. Testing & Acceptance

### Test Cases

1. **Source code**: Edit `src/parse.ts` → TDD gate triggers
2. **Shell script**: Edit `.cursor/scripts/validate.sh` → TDD gate triggers
3. **Documentation**: Edit `docs/projects/example/erd.md` → no TDD gate, proceed
4. **Configuration**: Edit `.github/workflows/ci.yml` → no TDD gate, proceed
5. **Rules**: Edit `.cursor/rules/testing.mdc` → no TDD gate, proceed
6. **Ambiguous**: Edit `.d.ts` file → ask once, then proceed based on answer

### Acceptance Criteria

#### Scope Definition (Core)

- [ ] Documented: explicit include/exclude globs for TDD scope
- [ ] Implemented: pre-edit scope check before applying TDD gate
- [ ] Tested: TDD scope test suite with ≥10 file types
- [ ] Validated: zero false negatives (all code changes follow TDD)
- [ ] Validated: zero false positives (docs don't trigger TDD gate)

#### Nested Sub-Project

This project includes rules-refinement for enforcement:

**Rules Refinement** (`rules-refinement/`)

- Status: Lite ERD
- Scope: Make TDD triggers/gates explicit and reliable
- Links: [`rules-refinement/erd.md`](rules-refinement/erd.md), [`rules-refinement/tasks.md`](rules-refinement/tasks.md)
- Dependency: Requires scope boundaries (this project) defined first

#### Overall Completion

- [ ] ✅ TDD scope boundaries clearly defined (which files need TDD)
- [ ] ✅ Scope check script working (`.cursor/scripts/tdd-scope-check.sh`)
- [ ] ✅ Rules refinement complete (triggers/gates explicit and testable)
- [ ] ✅ Monitoring period complete (1 week, zero false negatives/positives)

## 12. Rollout & Ops

1. Update `tdd-first.mdc` with explicit scope definition
2. Add decision tree and examples to rule
3. Test with real workflows covering code + docs
4. Monitor for 1 week to catch edge cases
5. Adjust based on feedback

## 13. Success Metrics

### Objective Measures

- **False negatives**: Zero code changes skip TDD gate
- **False positives**: Zero doc/config edits trigger TDD gate (target: 0)
- **Ambiguity rate**: % of edits requiring clarification (target: <5%)
- **User satisfaction**: User reports TDD gates now trigger appropriately

### Qualitative Signals

- Assistant correctly skips TDD for docs/configs
- All code changes still follow Red → Green → Refactor
- No confusion about when TDD applies

## 14. Open Questions

1. **Markdown with logic**: How to handle `.md` files with embedded code examples (e.g., shell snippets)?
2. **Config generators**: Should scripts that generate configs follow TDD for the generator logic?
3. **Type-only files**: Should `.d.ts` files ever require tests?
4. **GitHub workflows**: Should YAML workflow files have any validation beyond linting?
5. **Future extensions**: What about other file types (CSS modules with logic, HTML with embedded JS)?

---

Owner: repo-maintainers  
Created: 2025-10-11  
Motivation: TDD-first overapplied to documentation/config changes; need clear scope boundaries while maintaining discipline for code
