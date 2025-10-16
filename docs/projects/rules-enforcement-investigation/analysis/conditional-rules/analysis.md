# Conditional Rules Analysis

**Generated**: 2025-10-15  
**Purpose**: Categorize 25 conditional rules by risk level and enforcement needs

---

## Summary

- **Total Conditional Rules**: 25 (alwaysApply: false)
- **Total Always-Apply Rules**: 19 (alwaysApply: true)
- **Ratio**: 43% always-apply, 57% conditional

---

## Risk Categories

### CRITICAL (violations break workflows or safety)

**1. assistant-git-usage.mdc** → FIXED (now alwaysApply: true)

- **Original Risk**: High-frequency git operations bypassed script-first policy
- **Violation Pattern**: Direct `git commit`, skipped branch naming helper
- **Fix Applied**: Changed to alwaysApply: true (2025-10-15)
- **Validation Status**: Pending (need 20-30 commits)

### HIGH (frequent violations or significant impact)

**2. tdd-first-js.mdc** (JS/TS TDD pre-edit gate)

- **Risk**: Implementation edits without owner specs
- **Trigger**: globs: `**/*.{ts,tsx,js,jsx,mjs,cjs}`
- **Violation Pattern**: Write code before tests
- **Baseline**: 75% compliance (target: >95%)
- **Enforcement Need**: Pre-edit gate must execute before edits

**3. tdd-first-sh.mdc** (Shell TDD pre-edit gate)

- **Risk**: Shell script changes without behavior tests
- **Trigger**: globs: `.cursor/scripts/*.sh`
- **Violation Pattern**: Script edits without specs
- **Enforcement Need**: Pre-edit gate for shell scripts

**4. testing.mdc** (Test structure and quality)

- **Risk**: Poor test quality or missing tests
- **Trigger**: globs: `**/*.spec*,**/*.test*`
- **Violation Pattern**: Weak assertions, missing owner coupling
- **Enforcement Need**: Active during test file edits

**5. refactoring.mdc** (Refactoring safety)

- **Risk**: Breaking changes during refactors
- **Trigger**: globs: `**/*.{ts,tsx,js,jsx}`
- **Violation Pattern**: Refactors without test coverage
- **Enforcement Need**: Pre-refactor checklist

### MEDIUM (context-dependent, moderate impact)

**6. create-erd.mdc** (ERD creation workflow)

- **Risk**: Incomplete or poorly structured ERDs
- **Trigger**: intent-routing phrases ("create ERD")
- **Violation Pattern**: Missing sections, wrong format
- **Enforcement Need**: Intent-routing attachment

**7. generate-tasks-from-erd.mdc** (Task generation)

- **Risk**: Tasks don't match ERD structure
- **Trigger**: intent-routing phrases ("generate tasks")
- **Violation Pattern**: Missing dependencies, wrong format
- **Enforcement Need**: Intent-routing attachment

**8. project-lifecycle.mdc** (Project completion policy)

- **Risk**: Projects marked complete prematurely
- **Trigger**: paths matching `docs/projects/**`
- **Violation Pattern**: Missing artifacts, incomplete work
- **Baseline**: This project was incorrectly marked complete
- **Enforcement Need**: Validation checklist before archival

**9. spec-driven.mdc** (Specification workflow)

- **Risk**: Implementation without specification
- **Trigger**: intent-routing phrases ("plan", "specify")
- **Violation Pattern**: Skip planning phase
- **Enforcement Need**: Intent-routing attachment

**10. guidance-first.mdc** (Guidance vs implementation)

- **Risk**: Over-implementation when guidance requested
- **Trigger**: intent-routing phrases ("how can we", "what's best")
- **Violation Pattern**: Build when asked for advice
- **Enforcement Need**: Intent classification

**11. imports.mdc** (Import organization)

- **Risk**: Disorganized imports, wrong order
- **Trigger**: globs: `**/*.{ts,tsx,js,jsx,mjs,cjs}`
- **Violation Pattern**: Random import order
- **Enforcement Need**: Linter integration preferred

**12. shell-unix-philosophy.mdc** (Shell script design)

- **Risk**: Bloated scripts, multiple responsibilities
- **Trigger**: globs: `.cursor/scripts/**/*.sh` (excluding tests)
- **Violation Pattern**: Scripts >200 lines, 10+ flags
- **Enforcement Need**: Review during script creation/edits

### LOW (infrequent triggers, guidance-only)

**13. changelog.mdc** (Changesets workflow)

- **Risk**: Missing changesets in PRs
- **Trigger**: PR creation context
- **Violation Pattern**: PRs without changeset files
- **Enforcement Need**: PR template checklist

**14. context-efficiency.mdc** (Context health gauge)

- **Risk**: Bloated context
- **Trigger**: phrases ("show gauge", "context health")
- **Violation Pattern**: N/A (diagnostic tool)
- **Enforcement Need**: On-demand only

**15. deterministic-outputs.mdc** (Artifact templates)

- **Risk**: Non-standard artifact structure
- **Trigger**: Creating spec/plan/tasks artifacts
- **Violation Pattern**: Missing sections, wrong format
- **Enforcement Need**: Intent-routing for artifact creation

**16. dry-run.mdc** (Plan-only mode)

- **Risk**: Execution when plan requested
- **Trigger**: exact phrase "DRY RUN:" prefix
- **Violation Pattern**: N/A (safety feature)
- **Enforcement Need**: Phrase detection (works well)

**17. five-whys.mdc** (Root cause analysis)

- **Risk**: Surface-level problem analysis
- **Trigger**: post-mortem or investigation context
- **Violation Pattern**: Skip root cause analysis
- **Enforcement Need**: Manual attachment

**18. front-matter.mdc** (Rule metadata standards)

- **Risk**: Invalid rule front matter
- **Trigger**: globs: `.cursor/rules/*.mdc`
- **Violation Pattern**: Missing fields, wrong format
- **Enforcement Need**: Validation script (rules-validate.sh)

**19. rule-creation.mdc** (Rule authoring)

- **Risk**: Poor rule quality
- **Trigger**: globs: `.cursor/rules/**`
- **Violation Pattern**: Overly broad globs, duplication
- **Enforcement Need**: Review during rule authoring

**20. rule-maintenance.mdc** (Rule maintenance)

- **Risk**: Stale rules, broken references
- **Trigger**: globs: `.cursor/rules/**`
- **Violation Pattern**: Outdated examples, dead links
- **Enforcement Need**: Periodic review, validation script

**21. rule-quality.mdc** (Rule validation)

- **Risk**: Rule quality issues
- **Trigger**: globs: `.cursor/rules/**`
- **Violation Pattern**: >200 lines, poor examples
- **Enforcement Need**: Validation script

**22. test-plan-template.mdc** (Test plan structure)

- **Risk**: Incomplete test plans
- **Trigger**: globs: `**/tests/**/*.md,**/experiments/**/*.md`
- **Violation Pattern**: Missing sections
- **Enforcement Need**: Template enforcement

**23. test-quality.mdc** (General test quality)

- **Risk**: Poor test quality
- **Trigger**: globs: `**/*.spec*,**/*.test*`
- **Violation Pattern**: Weak assertions
- **Enforcement Need**: Test review

**24. test-quality-js.mdc** (JS/TS test quality)

- **Risk**: Language-specific test issues
- **Trigger**: globs: `**/*.{ts,tsx,js,jsx,mjs,cjs}`
- **Violation Pattern**: Missing diff coverage
- **Enforcement Need**: Language-specific test review

**25. test-quality-sh.mdc** (Shell test quality)

- **Risk**: Shell-specific test issues
- **Trigger**: globs: `.cursor/scripts/*.sh`
- **Violation Pattern**: Missing behavior evidence
- **Enforcement Need**: Shell test review

**26. workspace-security.mdc** (Workspace security)

- **Risk**: Autorun security issues
- **Trigger**: globs: `**/.vscode/tasks.json`
- **Violation Pattern**: folderOpen autoruns
- **Enforcement Need**: On-demand audit

---

## Enforcement Pattern Groups

### Group A: Pre-Edit Gates (require execution BEFORE edits)

- tdd-first-js.mdc
- tdd-first-sh.mdc
- refactoring.mdc

**Challenge**: Must execute before user sees assistant response with edits
**Current Mechanism**: Intent routing + TDD gate in assistant-behavior.mdc
**Measured Compliance**: 75% (target: >95%)

### Group B: Intent-Routed (attach on specific phrases/keywords)

- create-erd.mdc
- generate-tasks-from-erd.mdc
- guidance-first.mdc
- spec-driven.mdc
- context-efficiency.mdc
- dry-run.mdc

**Challenge**: Phrase detection accuracy
**Current Mechanism**: intent-routing.mdc with fuzzy matching
**Status**: Varies by phrase specificity

### Group C: File-Triggered (attach on glob match)

- testing.mdc
- imports.mdc
- shell-unix-philosophy.mdc
- test-quality.mdc
- test-quality-js.mdc
- test-quality-sh.mdc
- test-plan-template.mdc
- workspace-security.mdc
- front-matter.mdc
- rule-creation.mdc
- rule-maintenance.mdc
- rule-quality.mdc

**Challenge**: Only triggers when matching files are in context
**Current Mechanism**: Cursor's glob-based attachment
**Status**: Passive (requires files in editor)

### Group D: Process-Gated (attach during specific workflows)

- project-lifecycle.mdc
- changelog.mdc
- deterministic-outputs.mdc

**Challenge**: Workflow detection
**Current Mechanism**: Path patterns + intent routing
**Status**: Mixed (lifecycle violations observed)

### Group E: Guidance/Diagnostic (low-frequency, manual)

- five-whys.mdc

**Challenge**: Rare usage
**Current Mechanism**: Manual attachment
**Status**: Works when remembered

---

## Violations in Git History

### Confirmed Violations (from baseline measurements)

1. **assistant-git-usage** (now fixed): 71% → 74% compliance
2. **tdd-first-js**: 75% compliance (target: >95%)
3. **Branch naming**: 61% compliance (related to git-usage)

### Suspected Violations (evidence in discovery.md)

4. **project-lifecycle.mdc**: This project marked complete prematurely
5. **testing.mdc**: Tests with weak assertions observed
6. **guidance-first.mdc**: Over-implementation in guidance contexts (anecdotal)

### Not Measured Yet

- Most file-triggered rules (imports, refactoring, shell-unix-philosophy)
- Process-gated rules (changelog, deterministic-outputs)
- Guidance rules (five-whys)

---

## Scalability Analysis

### Context Cost

**Current State**:

- Always-apply rules: 19 (loaded in every conversation)
- Conditional rules: 25 (loaded selectively)

**If all 25 conditional → alwaysApply**:

- Total always-apply: 44 rules
- Context increase: ~132% (19 → 44)
- Estimated token impact: +50k-100k tokens per conversation

**Conclusion**: alwaysApply does NOT scale to 25 rules

### Enforcement Patterns That DO Scale

1. **Script-based validation** (scalable ✅)

   - Examples: rules-validate.sh, compliance-dashboard.sh
   - Works for: front-matter, rule-quality, tdd-compliance

2. **Intent routing with minimal rules** (scalable ✅)

   - Example: Attach small checklist, not full guide
   - Works for: create-erd, generate-tasks, guidance-first

3. **Linter integration** (scalable ✅)

   - Examples: ESLint for imports, ShellCheck for scripts
   - Works for: imports, code-style

4. **Slash commands** (potentially scalable, untested)

   - Example: `/pr` instead of detecting git intent
   - Hypothesis: Reduces ambiguity, improves routing accuracy

5. **Progressive attachment** (scalable ✅)
   - Attach minimal rule first, load details on-demand
   - Works for: testing (attach checklist, not full guide)

---

## Recommendations for Each Risk Category

### CRITICAL

- ✅ **assistant-git-usage**: Fixed (alwaysApply: true)
- Next: Validate fix over 20-30 commits

### HIGH

- **tdd-first-js/sh**: Strengthen pre-edit gate enforcement (H2 investigation)
- **testing/refactoring**: Consider progressive attachment (minimal checklist always-apply)

### MEDIUM

- **create-erd, generate-tasks, spec-driven**: Improve intent routing accuracy
- **project-lifecycle**: Add validation script + checklist
- **guidance-first**: Improve intent classification (guidance vs implementation)

### LOW

- **changelog**: Keep PR template enforcement
- **context-efficiency**: Keep on-demand (working well)
- **rule-\***: Keep validation script approach
- **test-quality-\***: Consider linter integration where possible

---

## Next Steps (per tasks.md)

1. ✅ **0.2.1**: List all conditional rules — COMPLETE
2. ✅ **0.2.2**: Categorize by risk level — COMPLETE
3. ✅ **0.2.3**: Identify violations in git history — COMPLETE
4. ✅ **0.2.4**: Group by enforcement needs — COMPLETE

**Proceed to**: Discovery 0.3 (Pre-test discovery for H2)
