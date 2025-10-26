## Relevant Files

- `.cursor/scripts/generate-root-readme.sh` — Main generator script (TBD)
- `.cursor/scripts/generate-root-readme.test.sh` — Test suite (TBD)
- `.cursor/scripts/validate-root-readme.sh` — Staleness validator (TBD)
- `templates/root-readme.template.md` — Template file (TBD)
- `README.md` — Output target
- `docs/projects/root-readme-generator/erd.md` — This ERD
- `docs/projects/root-readme-generator/decisions/` — Decision documents (TBD)

### Related Projects

- `docs/projects/_archived/2025/projects-readme-generator/` — Sister project, pattern reference
- `docs/projects/document-governance/` — Content organization strategy

---

## Tasks

### Phase 0: Discovery & Decisions (priority: critical, dependencies: none)

**Must resolve before implementation begins**

- [ ] 0.1 **Decision: Generation Strategy**

  - [ ] 0.1.1 Interview maintainers: How often do you manually edit root README?
  - [ ] 0.1.2 Prototype Option A: Full replacement (clear template + generator)
  - [ ] 0.1.3 Prototype Option B: Partial update (section markers)
  - [ ] 0.1.4 Prototype Option C: Hybrid (modular fragments)
  - [ ] 0.1.5 Document decision with rationale → `decisions/generation-strategy.md`
  - [ ] 0.1.6 Update ERD with selected strategy

- [ ] 0.2 **Decision: Scripts Section Detail Level**

  - [ ] 0.2.1 Measure current README length (line count, sections)
  - [ ] 0.2.2 Survey contributors: Do you want full inventory or top-N?
  - [ ] 0.2.3 Prototype link-only vs categorized full list vs top-10
  - [ ] 0.2.4 Document decision → `decisions/scripts-detail-level.md`
  - [ ] 0.2.5 Set line budget constraint (e.g., scripts section ≤100 lines)

- [ ] 0.3 **Decision: Manual vs Auto Sections**

  - [ ] 0.3.1 List all current README sections with purpose
  - [ ] 0.3.2 Tag each section: AUTO (can generate), MANUAL (must curate), HYBRID (both)
  - [ ] 0.3.3 Identify sections to relocate to docs/ (if any)
  - [ ] 0.3.4 Document section ownership → `decisions/section-ownership.md`
  - [ ] 0.3.5 Create content map (section → source/generator)

- [ ] 0.4 **Decision: Template Structure**

  - [ ] 0.4.1 Draft single template file with placeholders
  - [ ] 0.4.2 Draft modular fragments structure (header/sections/footer)
  - [ ] 0.4.3 Assess complexity: Which approach is simpler for our use case?
  - [ ] 0.4.4 Document decision → `decisions/template-structure.md`
  - [ ] 0.4.5 Create initial template file(s) based on decision

- [ ] 0.5 **Decision: Update Trigger & Workflow**
  - [ ] 0.5.1 Assess options: Manual script, pre-commit hook, CI auto-commit, CI validation-only
  - [ ] 0.5.2 Consider git noise: How many commits per week would auto-generation add?
  - [ ] 0.5.3 Document decision → `decisions/update-trigger.md`
  - [ ] 0.5.4 Define exact workflow (when to run, who runs it, CI job if applicable)

**Checkpoint**: All Phase 0 decisions documented before proceeding to Phase 1

---

### Phase 1: Foundation (priority: high, dependencies: Phase 0 complete)

- [ ] 1.0 **Set up project structure**

  - [ ] 1.1 Create template file(s) based on Phase 0 decision
  - [ ] 1.2 Create `decisions/` directory for decision docs
  - [ ] 1.3 Create test fixtures directory: `fixtures/root-readme/`
  - [ ] 1.4 Create initial test file: `generate-root-readme.test.sh`
  - [ ] 1.5 Document template syntax and placeholder conventions

- [ ] 1.1 **Implement metadata extraction: Scripts**

  - [ ] 1.1.1 Write test: Extract description from script header comment
  - [ ] 1.1.2 Implement: Parse `# Description: ...` from script headers
  - [ ] 1.1.3 Write test: Extract flags from script help output or header
  - [ ] 1.1.4 Implement: Parse `# Flags: ...` or call `script --help`
  - [ ] 1.1.5 Write test: Handle missing or malformed headers gracefully
  - [ ] 1.1.6 Implement: Fallback to filename if description missing
  - [ ] 1.1.7 Write test: Filter out `.lib*.sh` and `*.test.sh` files
  - [ ] 1.1.8 Implement: Filter pattern in discovery logic
  - [ ] 1.1.9 Create fixture scripts with various header formats
  - [ ] 1.1.10 Validate: All tests pass (Red → Green → Refactor)

- [ ] 1.2 **Implement metadata extraction: Rules**

  - [ ] 1.2.1 Write test: Extract `description:` from YAML front matter
  - [ ] 1.2.2 Implement: Parse front matter with grep/sed/awk
  - [ ] 1.2.3 Write test: Detect `alwaysApply: true` rules
  - [ ] 1.2.4 Implement: Flag always-apply rules in metadata
  - [ ] 1.2.5 Write test: Handle rules without front matter (use filename)
  - [ ] 1.2.6 Implement: Fallback logic for missing metadata
  - [ ] 1.2.7 Create fixture rules with various front matter formats
  - [ ] 1.2.8 Validate: All tests pass

- [ ] 1.3 **Implement metadata extraction: Project Stats**

  - [ ] 1.3.1 Write test: Count active projects (excluding `_archived/`, `_examples/`)
  - [ ] 1.3.2 Implement: Walk `docs/projects/` with exclusions
  - [ ] 1.3.3 Write test: Count archived projects in `_archived/<YYYY>/`
  - [ ] 1.3.4 Implement: Walk archived tree and count
  - [ ] 1.3.5 Write test: Count total rules in `.cursor/rules/*.mdc`
  - [ ] 1.3.6 Implement: Simple file count with glob
  - [ ] 1.3.7 [OPTIONAL] Extract test coverage from Jest output (if available)
  - [ ] 1.3.8 Validate: All tests pass

- [ ] 1.4 **Implement categorization logic**
  - [ ] 1.4.1 Write test: Assign scripts to categories based on name patterns
  - [ ] 1.4.2 Implement: Category mapping (git-_, rules-_, project-_, validate-_, etc.)
  - [ ] 1.4.3 Write test: Unknown scripts go to "Utilities" category
  - [ ] 1.4.4 Implement: Default category fallback
  - [ ] 1.4.5 Write test: Alphabetical sort within categories
  - [ ] 1.4.6 Implement: Sort logic
  - [ ] 1.4.7 Create fixture: Mixed script names across categories
  - [ ] 1.4.8 Validate: All tests pass

**Checkpoint**: Metadata extraction functions complete and tested

---

### Phase 2: Core Generation (priority: high, dependencies: Phase 1)

- [ ] 2.0 **Implement template renderer**

  - [ ] 2.0.1 Write test: Replace simple placeholder (e.g., `{{VERSION}}`)
  - [ ] 2.0.2 Implement: String replacement with sed or awk
  - [ ] 2.0.3 Write test: Replace multi-line placeholder (e.g., `{{SCRIPTS_INVENTORY}}`)
  - [ ] 2.0.4 Implement: Multi-line content injection
  - [ ] 2.0.5 Write test: Handle placeholder not found (error or skip?)
  - [ ] 2.0.6 Implement: Error handling based on Phase 0 decision
  - [ ] 2.0.7 [IF CONDITIONALS DECIDED] Write test: Conditional section rendering
  - [ ] 2.0.8 [IF CONDITIONALS DECIDED] Implement: Simple if/unless logic
  - [ ] 2.0.9 Validate: All tests pass

- [ ] 2.1 **Implement section generators: Scripts Inventory**

  - [ ] 2.1.1 Write test: Generate categorized script list (Markdown format)
  - [ ] 2.1.2 Implement: Loop through categories, render each with header
  - [ ] 2.1.3 Write test: Include script description and key flags
  - [ ] 2.1.4 Implement: Format bullets with description + flags
  - [ ] 2.1.5 Write test: Omit empty categories
  - [ ] 2.1.6 Implement: Skip category if no scripts
  - [ ] 2.1.7 Write test: Top-N mode (if applicable based on Phase 0)
  - [ ] 2.1.8 Implement: Limit to top N scripts per category or overall
  - [ ] 2.1.9 Validate: Output matches expected Markdown structure

- [ ] 2.2 **Implement section generators: Stats Summary**

  - [ ] 2.2.1 Write test: Render stats as bullet list or table
  - [ ] 2.2.2 Implement: Format active projects, rules count, test coverage
  - [ ] 2.2.3 Write test: Handle missing stats (e.g., test coverage unavailable)
  - [ ] 2.2.4 Implement: Graceful fallback (omit line or show "N/A")
  - [ ] 2.2.5 Validate: Output matches expected format

- [ ] 2.3 **Implement section generators: Quick Links**

  - [ ] 2.3.1 Define quick links list (based on Phase 0 decision)
  - [ ] 2.3.2 Write test: Generate Markdown links to top rules/docs
  - [ ] 2.3.3 Implement: Format bullet list with relative links
  - [ ] 2.3.4 Write test: Validate link targets exist (optional but recommended)
  - [ ] 2.3.5 Implement: Link validation logic
  - [ ] 2.3.6 Validate: Output includes expected links

- [ ] 2.4 **Implement section generators: Health Badge**

  - [ ] 2.4.1 Write test: Extract health score from latest run or badge script
  - [ ] 2.4.2 Implement: Call `health-badge-generate.sh` or parse existing badge
  - [ ] 2.4.3 Write test: Generate shields.io badge markdown
  - [ ] 2.4.4 Implement: Format badge with score and workflow link
  - [ ] 2.4.5 Validate: Badge markdown is correct

- [ ] 2.5 **Implement main generator script: CLI & orchestration**
  - [ ] 2.5.1 Write test: Parse command-line flags (--template, --out, --dry-run, etc.)
  - [ ] 2.5.2 Implement: Flag parsing with getopts or manual loop
  - [ ] 2.5.3 Write test: Load template file
  - [ ] 2.5.4 Implement: Read template, validate structure
  - [ ] 2.5.5 Write test: Call metadata extractors
  - [ ] 2.5.6 Implement: Orchestrate extraction functions
  - [ ] 2.5.7 Write test: Render sections
  - [ ] 2.5.8 Implement: Call section generators, inject into template
  - [ ] 2.5.9 Write test: Write output (atomic write pattern)
  - [ ] 2.5.10 Implement: Write to temp file, then rename
  - [ ] 2.5.11 Write test: Dry-run outputs to stdout, does not write file
  - [ ] 2.5.12 Implement: Dry-run conditional logic
  - [ ] 2.5.13 Write test: Idempotency (repeated runs produce same output)
  - [ ] 2.5.14 Implement: Stable ordering, deterministic content
  - [ ] 2.5.15 Validate: Full end-to-end test with fixtures

**Checkpoint**: Generator produces valid README from template and metadata

---

### Phase 3: Validation & CI Integration (priority: medium, dependencies: Phase 2)

- [ ] 3.0 **Implement validation script: README staleness check**

  - [ ] 3.0.1 Write test: Compare generated output with committed README
  - [ ] 3.0.2 Implement: Generate in-memory, diff with current file
  - [ ] 3.0.3 Write test: Exit 0 if identical, exit 1 if different
  - [ ] 3.0.4 Implement: Exit code logic based on diff result
  - [ ] 3.0.5 Write test: `--fix` flag regenerates and writes
  - [ ] 3.0.6 Implement: Autofix mode
  - [ ] 3.0.7 Write test: `--dry-run` flag shows diff without writing
  - [ ] 3.0.8 Implement: Dry-run diff mode
  - [ ] 3.0.9 Validate: Script correctly detects staleness

- [ ] 3.1 **Add CI workflow: README validation**

  - [ ] 3.1.1 Create workflow file: `.github/workflows/readme-validate.yml`
  - [ ] 3.1.2 Configure trigger: Push to main, PR events
  - [ ] 3.1.3 Add job: Run `validate-root-readme.sh`
  - [ ] 3.1.4 Add job: Fail if README stale
  - [ ] 3.1.5 Test workflow: Push to test branch, verify it runs
  - [ ] 3.1.6 Document workflow in project README

- [ ] 3.2 **Add npm script for convenience**
  - [ ] 3.2.1 Add `generate:root-readme` to `package.json` scripts
  - [ ] 3.2.2 Add `validate:root-readme` to `package.json` scripts
  - [ ] 3.2.3 Test: Run `npm run generate:root-readme` locally
  - [ ] 3.2.4 Test: Run `npm run validate:root-readme` locally
  - [ ] 3.2.5 Document npm scripts in project README

**Checkpoint**: Validation and CI integration working

---

### Phase 4: Documentation & Polish (priority: medium, dependencies: Phase 3)

- [ ] 4.0 **Create project README**

  - [ ] 4.0.1 Draft README with overview, quick start, features
  - [ ] 4.0.2 Add usage examples (all CLI flags)
  - [ ] 4.0.3 Document template syntax and placeholder conventions
  - [ ] 4.0.4 Add troubleshooting section (common errors)
  - [ ] 4.0.5 Link to ERD, tasks, decisions/
  - [ ] 4.0.6 Review and finalize

- [ ] 4.1 **Document decisions**

  - [ ] 4.1.1 Ensure all Phase 0 decisions documented in `decisions/`
  - [ ] 4.1.2 Add template decision doc (if not already created)
  - [ ] 4.1.3 Add categorization decision doc (if manual mapping used)
  - [ ] 4.1.4 Add update trigger decision doc
  - [ ] 4.1.5 Link decision docs from project README

- [ ] 4.2 **Update related docs**

  - [ ] 4.2.1 Add entry to `docs/scripts/README.md` for new scripts
  - [ ] 4.2.2 Update `.cursor/rules/capabilities.mdc` with new scripts
  - [ ] 4.2.3 Update root README itself using the new generator (dogfooding!)
  - [ ] 4.2.4 Update contributing guide with README regeneration workflow

- [ ] 4.3 **Polish and refine**
  - [ ] 4.3.1 Review script output: Is Markdown valid and readable?
  - [ ] 4.3.2 Run linter on generated README (if applicable)
  - [ ] 4.3.3 Check for edge cases: Empty categories, missing files, long lines
  - [ ] 4.3.4 Optimize performance: Profile generation time (<2s target)
  - [ ] 4.3.5 Add version flag to generator script
  - [ ] 4.3.6 Add help output with all flags documented

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

- [ ] **Multilingual support**: Generate README in multiple languages (defer to future)
- [ ] **External link validation**: Check badge URLs, external docs (defer to separate validator)
- [ ] **Contribution graph**: Auto-generate contributor stats (defer, privacy concerns)
- [ ] **Pre-commit hook integration**: Auto-regenerate on commit (defer, evaluate noise first)

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
