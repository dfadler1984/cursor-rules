## Tasks — Rules Condensation

**Status**: ACTIVE | Phase: Discovery | 0% Complete

---

## Phase 0: Discovery & Analysis (3-4 hours)

**Goal**: Measure baseline, identify specific duplication patterns, create consolidation map

- [ ] 0.0 Baseline measurement
  - [ ] 0.1 Count total words per rule (script or manual)
  - [ ] 0.2 Document current rule count and total word count
  - [ ] 0.3 Run context-efficiency baseline (sample attachments)
- [ ] 0.4 Duplication analysis
  - [ ] 0.5 Identify duplicated sections across rules (consent gates)
  - [ ] 0.6 Identify duplicated sections across rules (testing/TDD)
  - [ ] 0.7 Identify duplicated sections across rules (git workflows)
  - [ ] 0.8 Map overlap percentages for high-priority rules
- [ ] 0.9 Consolidation map
  - [ ] 0.10 Create merge plan for consent gate rules
  - [ ] 0.11 Create merge plan for testing rules
  - [ ] 0.12 Create merge plan for git workflow rules
  - [ ] 0.13 Document cross-reference strategy

## Phase 1: Consent Gates Consolidation (3-4 hours)

**Goal**: Single source of truth for consent guidance, links from related rules

- [ ] 1.0 Extract shared consent guidance
  - [ ] 1.1 Review `assistant-behavior.mdc` consent sections
  - [ ] 1.2 Review `intent-routing.mdc` consent patterns
  - [ ] 1.3 Review `user-intent.mdc` composite consent
  - [ ] 1.4 Identify core consent concepts (gates, allowlist, state tracking)
- [ ] 1.5 Create consolidated consent-gates.mdc (if needed) or consolidate into assistant-behavior.mdc
  - [ ] 1.6 Core consent principles
  - [ ] 1.7 Consent gates (Tier 1/2/3 operations)
  - [ ] 1.8 Session allowlist (grant/revoke/query)
  - [ ] 1.9 Consent state tracking
  - [ ] 1.10 Composite consent-after-plan
- [ ] 1.11 Update referring rules with links
  - [ ] 1.12 Replace duplicated sections in intent-routing.mdc with links
  - [ ] 1.13 Replace duplicated sections in user-intent.mdc with links
  - [ ] 1.14 Update any .caps files referencing consent
- [ ] 1.15 Validate
  - [ ] 1.16 Run rules-validate.sh
  - [ ] 1.17 Check cross-references are valid
  - [ ] 1.18 Verify attachment patterns still work

## Phase 2: Testing Rules Consolidation (4-5 hours)

**Goal**: Merge overlapping testing guidance, consolidate language-specific rules

- [ ] 2.0 Analyze testing rule overlap
  - [ ] 2.1 Map content overlap: testing.mdc vs tdd-first.mdc
  - [ ] 2.2 Map content overlap: test-quality.mdc vs test-quality-{js,sh}.mdc
  - [ ] 2.3 Identify TDD-specific content (Red/Green/Refactor, owner specs)
  - [ ] 2.4 Identify language-specific content (JS/Shell patterns)
- [ ] 2.5 Consolidate core testing guidance
  - [ ] 2.6 Merge testing.mdc + tdd-first.mdc → unified testing.mdc (with TDD section)
  - [ ] 2.7 Consolidate test-quality-{js,sh}.mdc → test-quality.mdc with language sections
  - [ ] 2.8 Extract redundant examples, keep citations to real tests
  - [ ] 2.9 Create clear section boundaries (general → TDD → quality → language-specific)
- [ ] 2.10 Update cross-references
  - [ ] 2.11 Update intent-routing.mdc test triggers
  - [ ] 2.12 Update tdd-first.caps.mdc (or deprecate if merged)
  - [ ] 2.13 Update testing.caps.mdc references
- [ ] 2.14 Validate
  - [ ] 2.15 Run rules-validate.sh
  - [ ] 2.16 Test attachment patterns (_.test._, _.spec._)
  - [ ] 2.17 Verify TDD pre-edit gate still enforced

## Phase 3: Git Workflow Consolidation (3-4 hours)

**Goal**: Single git workflow rule, separate API/script guidance if needed

- [ ] 3.0 Analyze git rule overlap
  - [ ] 3.1 Map content: assistant-git-usage.mdc (commits, branches, PRs)
  - [ ] 3.2 Map content: git-slash-commands.mdc (command routing)
  - [ ] 3.3 Map content: github-api-usage.caps.mdc (API tooling constraint)
  - [ ] 3.4 Identify script-first guidance vs workflow guidance
- [ ] 3.5 Consolidate git workflows
  - [ ] 3.6 Keep assistant-git-usage.mdc as primary (commits, branches, PRs, changesets)
  - [ ] 3.7 Merge git-slash-commands.mdc sections into intent-routing.mdc (or git usage)
  - [ ] 3.8 Keep github-api-usage.caps.mdc separate (lightweight attachment) or merge tooling section
  - [ ] 3.9 Trim verbose examples, replace with script citations
- [ ] 3.10 Update cross-references
  - [ ] 3.11 Update intent-routing.mdc git triggers
  - [ ] 3.12 Update assistant-git-usage.caps.mdc if kept separate
  - [ ] 3.13 Update 00-assistant-laws.mdc references
- [ ] 3.14 Validate
  - [ ] 3.15 Run rules-validate.sh
  - [ ] 3.16 Test slash command routing (/commit, /pr, /branch)
  - [ ] 3.17 Verify script-first guidance enforced

## Phase 4: Project Lifecycle Consolidation (3-4 hours)

**Goal**: Streamline project lifecycle rules, consolidate ERD/tasks guidance

- [ ] 4.0 Analyze lifecycle rule overlap
  - [ ] 4.1 Map content: project-lifecycle.mdc (general lifecycle)
  - [ ] 4.2 Map content: create-erd.mdc (ERD authoring)
  - [ ] 4.3 Map content: generate-tasks-from-erd.mdc (tasks generation)
  - [ ] 4.4 Identify ERD-specific vs general lifecycle guidance
- [ ] 4.5 Consolidate lifecycle guidance
  - [ ] 4.6 Keep project-lifecycle.mdc as primary
  - [ ] 4.7 Merge create-erd.mdc sections (ERD templates, mode selection)
  - [ ] 4.8 Merge generate-tasks-from-erd.mdc (two-phase flow, task structure)
  - [ ] 4.9 Use sub-sections: ## ERD Creation, ## Task Generation, ## Archival
- [ ] 4.10 Update cross-references
  - [ ] 4.11 Update intent-routing.mdc ERD/tasks triggers
  - [ ] 4.12 Update .caps files (create-erd.caps, generate-tasks.caps)
  - [ ] 4.13 Update project-lifecycle.caps.mdc
- [ ] 4.14 Validate
  - [ ] 4.15 Run rules-validate.sh
  - [ ] 4.16 Test ERD validation (erd-validate.sh)
  - [ ] 4.17 Test lifecycle validation (project-lifecycle-validate.sh)

## Phase 5: Rule Maintenance Consolidation (2-3 hours)

**Goal**: Merge overlapping rule authoring guidance

- [ ] 5.0 Analyze rule maintenance overlap
  - [ ] 5.1 Map content: rule-creation.mdc (authoring new rules)
  - [ ] 5.2 Map content: rule-maintenance.mdc (updating rules)
  - [ ] 5.3 Map content: rule-quality.mdc (validation standards)
  - [ ] 5.4 Map content: front-matter.mdc (metadata standards)
- [ ] 5.5 Consolidate rule guidance
  - [ ] 5.6 Merge rule-creation + rule-maintenance → rules.mdc (or keep separate if clear boundary)
  - [ ] 5.7 Merge rule-quality sections into validation checklist
  - [ ] 5.8 Keep front-matter.mdc separate (lightweight, single-purpose) or merge as section
  - [ ] 5.9 Reduce verbose examples, cite real rule files
- [ ] 5.10 Update cross-references
  - [ ] 5.11 Update intent-routing.mdc rule authoring triggers
  - [ ] 5.12 Update self-improve.mdc references
- [ ] 5.13 Validate
  - [ ] 5.14 Run rules-validate.sh
  - [ ] 5.15 Test rule validation tooling
  - [ ] 5.16 Verify front matter validation still works

## Phase 6: Code Style & Minor Consolidation (2-3 hours)

**Goal**: Trim verbosity in lower-overlap areas

- [ ] 6.0 Trim code-style.mdc
  - [ ] 6.1 Reduce verbose explanations
  - [ ] 6.2 Convert examples to concise do/don't pairs
  - [ ] 6.3 Extract redundant TypeScript patterns
- [ ] 6.4 Consolidate imports + dependencies
  - [ ] 6.5 Merge imports.mdc + dependencies.mdc if >50% overlap (check first)
  - [ ] 6.6 Or keep separate, trim verbose sections
- [ ] 6.7 Trim platform-capabilities.mdc
  - [ ] 6.8 Remove deprecated cursor-platform-capabilities.mdc content
  - [ ] 6.9 Consolidate platform guidance if split across files
- [ ] 6.10 Validate
  - [ ] 6.11 Run rules-validate.sh
  - [ ] 6.12 Check code style enforcement still works

## Phase 7: Validation & Measurement (2-4 hours)

**Goal**: Verify no functionality loss, measure impact

- [ ] 7.0 Comprehensive validation
  - [ ] 7.1 Run rules-validate.sh (all rules)
  - [ ] 7.2 Run rules-attach-validate.sh (attachment patterns)
  - [ ] 7.3 Check all cross-references resolve correctly
  - [ ] 7.4 Test sample workflows (commit, PR, testing, ERD)
- [ ] 7.5 Impact measurement
  - [ ] 7.6 Count final words per rule (compare to baseline)
  - [ ] 7.7 Document final rule count (compare to baseline)
  - [ ] 7.8 Calculate word count reduction percentage
  - [ ] 7.9 Run context-efficiency on sample attachments (compare to baseline)
- [ ] 7.10 Documentation
  - [ ] 7.11 Update rules README with consolidation notes
  - [ ] 7.12 Document deprecated rules (if any)
  - [ ] 7.13 Update CHANGELOG.md with consolidation summary
  - [ ] 7.14 Create final summary in findings.md

## Phase 8: Rollout & Cleanup (1-2 hours)

**Goal**: Merge changes, monitor for issues, clean up deprecated files

- [ ] 8.0 Pre-merge checklist
  - [ ] 8.1 All validation passing
  - [ ] 8.2 Changeset created
  - [ ] 8.3 PR description complete with before/after metrics
- [ ] 8.4 Post-merge monitoring
  - [ ] 8.5 Watch for broken rule attachments in active projects
  - [ ] 8.6 Monitor context efficiency scores
  - [ ] 8.7 Collect feedback on rule clarity
- [ ] 8.8 Cleanup
  - [ ] 8.9 Remove deprecated rule files (if any were fully merged)
  - [ ] 8.10 Archive legacy .caps files (if consolidated)
  - [ ] 8.11 Update tooling (rules-list.sh, rules-validate.sh) if needed

## Carryovers

(Items deferred or blocked)

---

## Relevant Files

**Rules to consolidate**:

- `.cursor/rules/assistant-behavior.mdc`
- `.cursor/rules/intent-routing.mdc`
- `.cursor/rules/user-intent.mdc`
- `.cursor/rules/testing.mdc`
- `.cursor/rules/tdd-first.mdc`
- `.cursor/rules/test-quality.mdc`
- `.cursor/rules/test-quality-js.mdc`
- `.cursor/rules/test-quality-sh.mdc`
- `.cursor/rules/assistant-git-usage.mdc`
- `.cursor/rules/git-slash-commands.mdc`
- `.cursor/rules/github-api-usage.caps.mdc`
- `.cursor/rules/project-lifecycle.mdc`
- `.cursor/rules/create-erd.mdc`
- `.cursor/rules/generate-tasks-from-erd.mdc`
- `.cursor/rules/rule-creation.mdc`
- `.cursor/rules/rule-maintenance.mdc`
- `.cursor/rules/rule-quality.mdc`
- `.cursor/rules/front-matter.mdc`
- `.cursor/rules/code-style.mdc`
- `.cursor/rules/imports.mdc`
- `.cursor/rules/dependencies.mdc`
- `.cursor/rules/platform-capabilities.mdc`

**Validation scripts**:

- `.cursor/scripts/rules-validate.sh`
- `.cursor/scripts/rules-attach-validate.sh`
- `.cursor/scripts/rules-list.sh`
- `.cursor/scripts/context-efficiency-score.sh`

**Related projects**:

- `docs/projects/rules-enforcement-investigation/` — Evidence of duplication
- `docs/projects/context-efficiency/` — Measurement framework
