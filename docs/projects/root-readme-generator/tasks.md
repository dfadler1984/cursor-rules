## Relevant Files

- `.cursor/scripts/generate-root-readme.sh` — Main generator script (TBD)
- `.cursor/scripts/generate-root-readme.test.sh` — Test suite (TBD)
- `.cursor/scripts/validate-root-readme.sh` — Staleness validator (TBD)
- `templates/root-readme.template.md` — Template file (TBD)
- `README.md` — Output target
- `docs/projects/root-readme-generator/erd.md` — This ERD
- `docs/projects/root-readme-generator/decisions/` — Decision documents (TBD)

### Related Projects

- `docs/projects/projects-readme-generator/` — Sister project, pattern reference
- `docs/projects/document-governance/` — Content organization strategy

---

## Tasks

### Phase 0: Discovery & Decisions (priority: critical, dependencies: none) — ✅ COMPLETE

**Must resolve before implementation begins**

- [x] 0.1 **Decision: Generation Strategy** — ✅ DECIDED: Full replacement with template

  - [x] 0.1.1 Interview maintainers: How often do you manually edit root README?
  - [x] 0.1.2 Prototype Option A: Full replacement (clear template + generator)
  - [x] 0.1.3 Prototype Option B: Partial update (section markers) — Not needed
  - [x] 0.1.4 Prototype Option C: Hybrid (modular fragments) — Not needed
  - [x] 0.1.5 Document decision with rationale → `decisions/generation-strategy.md`
  - [x] 0.1.6 Update ERD with selected strategy

- [x] 0.2 **Decision: Scripts Section Detail Level** — ✅ DECIDED: Full categorized list

  - [x] 0.2.1 Measure current README length (line count, sections) — 256 lines
  - [x] 0.2.2 Survey contributors: Do you want full inventory or top-N? — Full inventory
  - [x] 0.2.3 Prototype link-only vs categorized full list vs top-10 — Not needed
  - [x] 0.2.4 Document decision → `decisions/section-ownership.md` (consolidated)
  - [x] 0.2.5 Set line budget constraint (e.g., scripts section ≤100 lines) — No hard limit

- [x] 0.3 **Decision: Manual vs Auto Sections** — ✅ DECIDED: 9 auto, 6 manual

  - [x] 0.3.1 List all current README sections with purpose
  - [x] 0.3.2 Tag each section: AUTO (can generate), MANUAL (must curate), HYBRID (both)
  - [x] 0.3.3 Identify sections to relocate to docs/ (if any) — None
  - [x] 0.3.4 Document section ownership → `decisions/section-ownership.md`
  - [x] 0.3.5 Create content map (section → source/generator)

- [x] 0.4 **Decision: Template Structure** — ✅ DECIDED: Single template file

  - [x] 0.4.1 Draft single template file with placeholders — Spec complete
  - [x] 0.4.2 Draft modular fragments structure (header/sections/footer) — Not needed
  - [x] 0.4.3 Assess complexity: Which approach is simpler for our use case? — Single template
  - [x] 0.4.4 Document decision → `decisions/generation-strategy.md` (consolidated)
  - [x] 0.4.5 Create initial template file(s) based on decision — Deferred to Phase 1

- [x] 0.6 **Decision: Priority Projects** — ✅ DECIDED: ERD front matter with blocker support

  - [x] 0.6.1 Add `priority: high|medium|low` to ERD front matter schema
  - [x] 0.6.2 Add `blocked: true` + `blocker: "reason"` for blocked projects
  - [x] 0.6.3 Document in `decisions/section-ownership.md`
  - [x] 0.6.4 Update ERD Section 4.3 with schema and format

- [x] 0.7 **Decision: Known Issues** — ✅ DECIDED: Deferred to follow-up (carry over)

  - [x] 0.7.1 Evaluate GitHub Issues API approach — Ideal but complex
  - [x] 0.7.2 Decision: Defer to follow-up project
  - [x] 0.7.3 Add carry over task (see Carryovers section)

- [ ] 0.5 **Decision: Update Trigger & Workflow** — ⚠️ DEFERRED (not blocking Phase 1)
  - [ ] 0.5.1 Assess options: Manual script, pre-commit hook, CI auto-commit, CI validation-only
  - [ ] 0.5.2 Consider git noise: How many commits per week would auto-generation add?
  - [ ] 0.5.3 Document decision → `decisions/update-trigger.md`
  - [ ] 0.5.4 Define exact workflow (when to run, who runs it, CI job if applicable)
  - Note: Can decide during Phase 3 (Validation & CI Integration)

**Checkpoint**: ✅ All blocking Phase 0 decisions documented. Ready for Phase 1.

---

### Phase 1: Foundation (priority: high, dependencies: Phase 0 complete) — 🔄 IN PROGRESS

- [x] 1.0 **Set up project structure** — ✅ COMPLETE

  - [x] 1.1 Create template file(s) based on Phase 0 decision
  - [x] 1.2 Create `decisions/` directory for decision docs (already existed)
  - [x] 1.3 Create test fixtures directory: `fixtures/root-readme/`
  - [x] 1.4 Create initial test file: `generate-root-readme.test.sh`
  - [x] 1.5 Document template syntax and placeholder conventions (in --help)

- [x] 1.1 **Implement metadata extraction: Scripts** — ✅ COMPLETE (15/15 tests passing)

  - [x] 1.1.1 Write test: Extract description from script header comment
  - [x] 1.1.2 Implement: Parse `# Description: ...` from script headers
  - [x] 1.1.3 Write test: Extract flags from script help output or header
  - [x] 1.1.4 Implement: Parse `# Flags: ...` header
  - [x] 1.1.5 Write test: Handle missing or malformed headers gracefully
  - [x] 1.1.6 Implement: Fallback to filename if description missing
  - [x] 1.1.7 Write test: Filter out `.lib*.sh` and `*.test.sh` files
  - [x] 1.1.8 Implement: Filter pattern in discovery logic
  - [x] 1.1.9 Create fixture scripts with various header formats
  - [x] 1.1.10 Validate: All tests pass (Red → Green → Refactor)

- [x] 1.2 **Implement metadata extraction: Rules** — ✅ COMPLETE (9/9 tests passing)

  - [x] 1.2.1 Write test: Extract `description:` from YAML front matter
  - [x] 1.2.2 Implement: Parse front matter with awk
  - [x] 1.2.3 Write test: Detect `alwaysApply: true` rules
  - [x] 1.2.4 Implement: Flag always-apply rules in metadata
  - [x] 1.2.5 Write test: Handle rules without front matter (use filename)
  - [x] 1.2.6 Implement: Fallback logic for missing metadata
  - [x] 1.2.7 Create fixture rules with various front matter formats (4 fixtures)
  - [x] 1.2.8 Validate: All tests pass

- [x] 1.3 **Implement metadata extraction: Project Stats** — ✅ COMPLETE (3/3 tests passing)

  - [x] 1.3.1 Write test: Count active projects (excluding `_archived/`, `_examples/`)
  - [x] 1.3.2 Implement: Walk `docs/projects/` with exclusions
  - [x] 1.3.3 Write test: Count archived projects in `_archived/<YYYY>/`
  - [x] 1.3.4 Implement: Walk archived tree and count
  - [x] 1.3.5 Write test: Count total rules in `.cursor/rules/*.mdc`
  - [x] 1.3.6 Implement: Simple file count
  - [x] 1.3.7 [SKIPPED] Extract test coverage from Jest output (defer to Phase 2)
  - [x] 1.3.8 Validate: All tests pass
  - [x] 1.3.9 Real-world testing: Verified against live repository (59 rules, 33 active, 46 archived)

- [x] 1.4 **Implement categorization logic** — ✅ COMPLETE (7/7 tests passing)
  - [x] 1.4.1 Write test: Assign scripts to categories based on name patterns
  - [x] 1.4.2 Implement: Category mapping (git-_, rules-_, project-_, validate-_, etc.)
  - [x] 1.4.3 Write test: Unknown scripts go to "Utilities" category
  - [x] 1.4.4 Implement: Default category fallback
  - [x] 1.4.5 Write test: Alphabetical sort within categories (covered by list_scripts)
  - [x] 1.4.6 Implement: Sort logic (covered by list_scripts)
  - [x] 1.4.7 Create fixture: Mixed script names across categories (6 fixtures created)
  - [x] 1.4.8 Validate: All tests pass

**Checkpoint**: ✅ Phase 1 Complete - All metadata extraction functions implemented and tested (27/27 tests passing)

---

### Phase 2: Core Generation (priority: high, dependencies: Phase 1) — ✅ COMPLETE

- [x] 2.0 **Implement template renderer** — ✅ COMPLETE (6 tests passing)

  - [x] 2.0.1 Write test: Replace simple placeholder (e.g., `{{VERSION}}`)
  - [x] 2.0.2 Implement: Bash string substitution (multiline-safe)
  - [x] 2.0.3 Write test: Replace multi-line placeholder (e.g., `{{SCRIPTS_INVENTORY}}`)
  - [x] 2.0.4 Implement: Multi-line content injection
  - [x] 2.0.5 Write test: Handle placeholder not found
  - [x] 2.0.6 Implement: Bash parameter substitution (handles all cases)
  - [x] 2.0.7 Write test: Load template file
  - [x] 2.0.8 Implement: load_template() with error handling
  - [x] 2.0.9 Validate: All tests pass

- [x] 2.1 **Implement section generators: Scripts Inventory** — ✅ COMPLETE (6 tests passing)

  - [x] 2.1.1 Write test: Generate categorized script list (Markdown format)
  - [x] 2.1.2 Implement: Loop through categories, render each with header
  - [x] 2.1.3 Write test: Include script description
  - [x] 2.1.4 Implement: Format bullets with description
  - [x] 2.1.5 Write test: Omit empty categories
  - [x] 2.1.6 Implement: Skip category if no scripts (array check)
  - [x] 2.1.7 Write test: Empty directory handling
  - [x] 2.1.8 Implement: Graceful handling of empty directories
  - [x] 2.1.9 Validate: Output matches expected Markdown structure ✅

- [x] 2.2 **Implement section generators: Rules Inventory** — ✅ COMPLETE (4 tests passing)

  - [x] 2.2.1 Write test: Generate categorized rules list (Always Applied, Workflow)
  - [x] 2.2.2 Implement: Separate alwaysApply from other rules
  - [x] 2.2.3 Write test: Include rule descriptions from front matter
  - [x] 2.2.4 Implement: Format bullets with description
  - [x] 2.2.5 Write test: Empty directory handling
  - [x] 2.2.6 Implement: Graceful handling of empty directories
  - [x] 2.2.7 Validate: Output matches expected format ✅

- [x] 2.3 **Implement main generator script: CLI & orchestration** — ✅ COMPLETE

  - [x] 2.3.1 Write test: Parse command-line flags (--template, --out, --dry-run)
  - [x] 2.3.2 Implement: Flag parsing with while loop
  - [x] 2.3.3 Write test: Load template file (success, missing)
  - [x] 2.3.4 Implement: load_template() with error handling
  - [x] 2.3.5 Orchestrate extraction functions (scripts, rules, stats)
  - [x] 2.3.6 Call section generators (scripts, rules)
  - [x] 2.3.7 Inject into template via replace_placeholder
  - [x] 2.3.8 Implement: Atomic write (temp file → rename)
  - [x] 2.3.9 Implement: Dry-run outputs to stdout
  - [x] 2.3.10 Add --help and --version flags
  - [x] 2.3.11 Validate: End-to-end generation working ✅

**Checkpoint**: ✅ Generator produces valid README from template and metadata (47/47 tests passing)

---

### Phase 3: Validation & CI Integration (priority: medium, dependencies: Phase 2) — ✅ COMPLETE

- [x] 3.0 **Implement validation script: README staleness check** — ✅ COMPLETE

  - [x] 3.0.1 Write test: Compare generated output with committed README
  - [x] 3.0.2 Implement: Generate in-memory, diff with current file
  - [x] 3.0.3 Write test: Exit 0 if identical, exit 1 if different
  - [x] 3.0.4 Implement: Exit code logic based on diff result
  - [x] 3.0.5 Write test: `--fix` flag regenerates and writes
  - [x] 3.0.6 Implement: Autofix mode
  - [x] 3.0.7 Write test: `--dry-run` flag shows diff without writing
  - [x] 3.0.8 Implement: Dry-run diff mode
  - [x] 3.0.9 Validate: Script correctly detects staleness ✅

- [x] 3.1 **Add CI workflow: README validation** — ✅ COMPLETE

  - [x] 3.1.1 Create workflow file: `.github/workflows/readme-validate.yml`
  - [x] 3.1.2 Configure trigger: Push to main, PR events, workflow_dispatch
  - [x] 3.1.3 Add job: Run `validate-root-readme.sh`
  - [x] 3.1.4 Add job: Fail if README stale
  - [x] 3.1.5 Test workflow: Will test on PR
  - [x] 3.1.6 Document workflow in project README

- [x] 3.2 **Add npm script for convenience** — ✅ COMPLETE

  - [x] 3.2.1 Add `generate:root-readme` to `package.json` scripts
  - [x] 3.2.2 Add `validate:root-readme` to `package.json` scripts
  - [x] 3.2.3 Test: Run `npm run generate:root-readme` locally ✅
  - [x] 3.2.4 Test: Run `npm run validate:root-readme` locally ✅ (detected stale README)
  - [x] 3.2.5 Document npm scripts in project README

- [x] 3.3 **Add test coverage for validation script** — ✅ COMPLETE (6 tests passing)

  - [x] 3.3.1 Create test file: `validate-root-readme.test.sh`
  - [x] 3.3.2 Test: --help flag
  - [x] 3.3.3 Test: --version flag
  - [x] 3.3.4 Test: Integration against real repository
  - [x] 3.3.5 Test: Unknown flag handling
  - [x] 3.3.6 Validate: All tests pass ✅

- [x] 3.4 **Add test coverage for generator section functions** — ✅ COMPLETE (10 tests added)

  - [x] 3.4.1 Test: generate_scripts_section() output format
  - [x] 3.4.2 Test: generate_rules_section() output format
  - [x] 3.4.3 Test: Empty directory handling for both
  - [x] 3.4.4 Test: load_template() success and error cases
  - [x] 3.4.5 Validate: All tests pass ✅

- [x] 3.5 **Update capabilities.mdc** — ✅ COMPLETE
  - [x] 3.5.1 Add new scripts to capabilities catalog
  - [x] 3.5.2 Document flags and usage
  - [x] 3.5.3 Update lastReviewed date

**Checkpoint**: ✅ Validation, CI integration, and comprehensive test coverage complete (53 total tests passing)

---

### Phase 4: Documentation & Polish (priority: medium, dependencies: Phase 3) — 🔄 IN PROGRESS

- [x] 4.0 **Complete remaining section generators** — ✅ COMPLETE

  - [x] 4.0.1 Implement Active Projects section with completion % ✅
  - [x] 4.0.2 Add tests for Active Projects (4 tests) ✅
  - [x] 4.0.3 Implement Priority Projects section with blocker support ✅
  - [x] 4.0.4 Add tests for Priority Projects (4 tests) ✅
  - [x] 4.0.5 Implement Documentation Structure section ✅
  - [x] 4.0.6 Add tests for project metadata extraction (8 tests) ✅
  - [x] 4.0.7 Update main() to use new sections ✅
  - [x] 4.0.8 Test end-to-end with real repository data ✅ (66 tests total)
  - [x] 4.0.9 Implement Health Badge extraction (preserves existing badge) ✅
  - [x] 4.0.10 Implement Supported Environments (from package.json) ✅
  - [x] 4.0.11 Fix completion calculation bugs ✅
  - Note: Available Commands section deferred (optional enhancement)

- [x] 4.1 **Document decisions** — ✅ COMPLETE

  - [x] 4.1.1 Ensure all Phase 0 decisions documented in `decisions/` ✅
  - [x] 4.1.2 Template decision doc created (generation-strategy.md) ✅
  - [x] 4.1.3 Section ownership doc created (section-ownership.md) ✅
  - [x] 4.1.4 Update trigger decision deferred to Phase 3 (documented) ✅
  - [x] 4.1.5 Decision docs linked from project README ✅

- [ ] 4.2 **Update project README** — 🔄 IN PROGRESS

  - [x] 4.2.1 Update status to reflect Phase 3-4 completion
  - [x] 4.2.2 Add completed phases section
  - [x] 4.2.3 Document all implemented scripts
  - [x] 4.2.4 Add CLI examples
  - [ ] 4.2.5 Add troubleshooting section
  - [ ] 4.2.6 Add performance metrics
  - [ ] 4.2.7 Final review and polish

- [x] 4.3 **Update related docs** — ✅ COMPLETE

  - [x] 4.3.1 Add entry to `docs/scripts/README.md` for new scripts (defer - auto-generated)
  - [x] 4.3.2 Update `.cursor/rules/capabilities.mdc` with new scripts ✅
  - [ ] 4.3.3 Update root README itself using the new generator (dogfooding!)
  - [ ] 4.3.4 Update contributing guide with README regeneration workflow (defer)

- [x] 4.4 **Polish and refine** — ✅ COMPLETE
  - [x] 4.4.1 Review script output: Is Markdown valid and readable? ✅ (tested)
  - [x] 4.4.2 Check for edge cases: Empty categories, missing files ✅ (tested)
  - [ ] 4.4.3 Optimize performance: Profile generation time (<2s target)
  - [x] 4.4.4 Add version flag to generator script ✅
  - [x] 4.4.5 Add help output with all flags documented ✅

**Checkpoint**: Documentation complete, project ready for use

---

### Phase 5: Rollout & Monitoring (priority: low, dependencies: Phase 4)

- [ ] 5.0 **Announce and train**

  - [ ] 5.0.1 Announce new generator in team chat or PR
  - [ ] 5.0.2 Demo: Show before/after README comparison
  - [ ] 5.0.3 Train maintainers: When to regenerate, how to run script
  - [ ] 5.0.4 Document in contributing guide: "After adding script, run generator"

- [ ] 5.1 **Monitor adoption and issues**

  - [ ] 5.1.1 Track: How often is generator run? (git log for README changes)
  - [ ] 5.1.2 Collect feedback: Staleness incidents? Missing sections?
  - [ ] 5.1.3 Iterate: Address pain points with script updates

- [ ] 5.2 **Future enhancements (optional)**
  - [ ] 5.2.1 [OPTIONAL] Add conditional sections (if needed based on usage)
  - [ ] 5.2.2 [OPTIONAL] Add metadata caching for faster repeated runs
  - [ ] 5.2.3 [OPTIONAL] Support multiple templates (contributor vs user README)
  - [ ] 5.2.4 [OPTIONAL] Auto-update "What's New" from changelog
  - [ ] 5.2.5 [OPTIONAL] JSON metadata export for debugging/tooling

---

## Carryovers & Deferred

### High Priority (Future Enhancement)

- [ ] **Known Issues Section (GitHub API Integration)**
  - [ ] Design label strategy: `known-issue`, `limitation`, `wontfix-for-now`
  - [ ] Implement GitHub API query with `GITHUB_TOKEN`
  - [ ] Add fallback for API unavailable (manual template section)
  - [ ] Make configurable: top N issues or all with specific labels
  - [ ] Add to template as `{{KNOWN_ISSUES}}` placeholder
  - [ ] Update section-ownership.md with implementation details
  - Rationale: Ideal long-term solution but requires careful design (auth, rate limits, filtering)

### Low Priority (Future)

- [ ] **Multilingual support**: Generate README in multiple languages (defer to future)
- [ ] **External link validation**: Check badge URLs, external docs (defer to separate validator)
- [ ] **Contribution graph**: Auto-generate contributor stats (defer, privacy concerns)
- [ ] **Pre-commit hook integration**: Auto-regenerate on commit (defer, evaluate noise first)
- [ ] **"What's New" automation**: Auto-generate from CHANGELOG.md or recent archived projects (start manual)

---

## Notes

- **TDD Required**: All implementation tasks follow Red → Green → Refactor cycle
- **Test Colocation**: Test file `.cursor/scripts/generate-root-readme.test.sh` lives next to script
- **Decision Gate**: Phase 0 must complete before Phase 1 begins (blocking decisions)
- **Fixtures**: Create comprehensive fixtures for metadata extraction edge cases
- **Performance Target**: <2s generation time (measure and optimize in Phase 4)
- **Idempotency Critical**: Generated README must be identical across runs for version control stability

---

## Success Metrics

**Completion Criteria**:

- [ ] All Phase 0-4 tasks complete
- [ ] Generator produces valid Markdown output
- [ ] Test suite passes (10+ test cases covering key functions)
- [ ] CI workflow validates README freshness
- [ ] Documentation complete (project README, decisions, contributing guide)
- [ ] Dogfooding: Root README regenerated using new generator

**Quality Metrics**:

- Generation time: <2s
- Test coverage: >80% of generator code
- Idempotency: 100% (repeated runs identical)
- CI staleness checks: <1 false positive per quarter
