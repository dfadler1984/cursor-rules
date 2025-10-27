---
status: active
owner: rules-maintainers
created: 2025-10-25
---

# Engineering Requirements Document — Root README Generator

Mode: Full

Links: `docs/projects/root-readme-generator/tasks.md` | `README.md`

## 1. Introduction/Overview

Automate generation of the repository root `README.md` to keep it current, accurate, and consistent. Unlike the projects README generator (which handles `docs/projects/README.md`), this tool manages the repository's main entry point.

### Problem Space

The root README is the first thing users/contributors see, but it:

- Contains many sections that could be auto-generated (scripts list, stats, links)
- Risks becoming stale as scripts/rules/projects evolve
- Mixes conceptual content (workflow overview) with concrete inventory (script list)
- Has unclear boundaries about what belongs where (root vs `docs/` vs project folders)

### Resolved Decisions (2025-10-26)

- ✅ **Generation Strategy**: Full replacement with template (see `decisions/generation-strategy.md`)
- ✅ **Section Ownership**: 9 auto-generated, 6 manual sections (see `decisions/section-ownership.md`)
- ✅ **Priority Projects**: ERD front matter with `priority: high|medium|low` + blocker support
- ✅ **Known Issues**: Deferred to follow-up project (carry over)
- ✅ **Scripts Section**: Full categorized list (38+ scripts)

### Remaining Uncertainties

- [NEEDS CLARIFICATION: Update trigger — CI validation-only, manual npm script, or pre-commit hook?]
- [ASSUMPTION: Template-based approach with simple placeholder replacement ({{PLACEHOLDER}})]
- [ASSUMPTION: Idempotent output for version control stability]
- [ASSUMPTION: Zero external dependencies beyond coreutils]

## 2. Goals/Objectives

### Primary

- Keep root README accurate with automated script inventory
- Standardize formatting and reduce manual maintenance burden
- Provide clear navigation to docs, rules, projects, and tools

### Secondary

- Surface repository health metrics (badge, test coverage, project stats)
- Auto-update "What's New" based on recent completions or releases
- Maintain stable structure for external link stability

### Non-Goals

- Not replacing manual conceptual content (workflow philosophy, design principles)
- Not handling docs/ organization (separate concern: document-governance project)
- Not generating content for rules files or project ERDs

## 3. User Stories

- As a **new contributor**, I can quickly find setup instructions, workflow overview, and where to start
- As a **maintainer**, I can regenerate the README in seconds after adding/renaming scripts
- As a **CI system**, I can validate that the README is current and flag staleness
- As an **AI agent**, I find structured links to capabilities, rules, and project documentation

## 4. Functional Requirements

### 4.1 Content Strategy (DECIDED: Full Replacement)

**Selected**: Option A - Full Replacement with Template

**Rationale**:

- Complete consistency — no drift between manual and auto sections
- Simpler implementation — single template, clear placeholders
- Predictable output — idempotent generation
- Easier testing — compare generated vs expected
- No marker maintenance overhead

**Trade-offs Accepted**:

- Manual edits will be lost on regeneration
- Manual content lives in version-controlled template
- Changes to manual content require PR to template

**Implementation**:

- Single template file: `templates/root-readme.template.md`
- Simple placeholder syntax: `{{PLACEHOLDER_NAME}}`
- Generator replaces all placeholders atomically
- Template contains both manual content and placeholder positions

### 4.2 README Structure (DECIDED)

**15 Sections** (9 auto-generated, 6 manual):

**Auto-Generated Sections** (via placeholder replacement):

1. **Health Badge** — `{{HEALTH_BADGE}}` from CI badge script
2. **Supported Environments** — `{{SUPPORTED_ENVIRONMENTS}}` from package.json + shebangs
3. **Available Rules** — `{{AVAILABLE_RULES}}` from `.cursor/rules/*.mdc` front matter
4. **Available Scripts** — `{{AVAILABLE_SCRIPTS}}` from `.cursor/scripts/*.sh` headers
5. **Available Commands** — `{{AVAILABLE_COMMANDS}}` from `intent-routing.mdc`
6. **Active Projects** — `{{ACTIVE_PROJECTS}}` from `docs/projects/*/erd.md` (status: active)
7. **Priority Projects** — `{{PRIORITY_PROJECTS}}` from ERD front matter (priority: high + blocked)
8. **Test Stats** — `{{TEST_STATS}}` from test runner output (optional)
9. **Documentation Structure** — `{{DOCS_STRUCTURE}}` from `docs/` scan

**Manual Sections** (encoded in template):

1. **Repository Description** — What this repository is for
2. **Unified Workflow** — Conceptual Specify → Plan → Tasks overview
3. **Setup Instructions** — Prerequisites, installation, auth
4. **What's New** — Recent changes (manual for MVP, auto later)
5. **Changelog & Versioning** — Link to CHANGELOG.md
6. **Workspace Security** — Link to security policy
7. **Contributing** — How to contribute

Full specification in `decisions/section-ownership.md`.

### 4.3 Auto-Generated Sections (Details)

**1. Scripts Inventory** (DECIDED: Full categorized list)

- Source: `.cursor/scripts/*.sh` (excluding `.lib*.sh`, `*.test.sh`)
- Extract: Description from `# Description: ...` header
- Extract: Flags from `# Flags: ...` or `--help` output
- Categories (derived from filename prefixes):
  - **Git Workflows**: `git-*`, `pr-*`, `checks-*`
  - **Rules Management**: `rules-*`
  - **Project Lifecycle**: `project-*`, `archive-*`, `final-summary-*`
  - **Validation**: `validate-*`, `*-validate*`, `shellcheck-*`, `lint-*`
  - **CI & Health**: `security-*`, `health-*`, `compliance-*`
  - **Utilities**: Everything else
- Format: Categorized bullets with description
- Link to: `docs/scripts/README.md` for full details

**2. Rules Inventory**

- Source: `.cursor/rules/*.mdc`
- Extract: `description:` from YAML front matter
- Flag: `alwaysApply: true` rules (show first)
- Categories:
  - Always Applied (alwaysApply: true)
  - Workflow & Process
  - Code Quality
  - Git & CI
  - Testing & TDD
  - Documentation
  - Security
- Format: Categorized bullets with description
- Link to: `.cursor/rules/` directory

**3. Commands Inventory**

- Source: `intent-routing.mdc` (slash commands section)
- Source: `git-slash-commands.mdc`
- Categories:
  - Git Operations (`/commit`, `/pr`, `/branch`, etc.)
  - Workflow (`/plan`, `/tasks`, etc.)
  - Session Management (`/allowlist`)
- Format: Categorized bullets with description
- Link to: Full command reference rules

**4. Active Projects**

- Source: `docs/projects/*/erd.md`
- Filter: `status: active` in front matter
- Extract: Project name, description (first H1 or description field)
- Count: Parse `tasks.md` for completion % (done/total)
- Format: Bullets with name, description, completion %
- Link to: `docs/projects/README.md`

**5. Priority Projects** (DECIDED: ERD front matter with blocker support)

- Source: `docs/projects/*/erd.md` front matter
- Filter 1: `priority: high` (any status)
- Filter 2: `blocked: true` (separate section)
- Extract: `blocker:` or `blockers:` field
- Format:

  ```markdown
  **High Priority** ({{COUNT}}):

  - **[name]** — [description] [completion %]

  **Blocked** ({{COUNT}} need unblocking):

  - **[name]** (priority: high) — [description]
    - ⚠️ Blocker: [reason from front matter]
  ```

- ERD front matter schema:
  ```yaml
  ---
  priority: high # high|medium|low
  blocked: true
  blocker: "Specific reason"
  # or:
  blockers:
    - "Reason 1"
    - "Reason 2"
  ---
  ```

**6. Supported Environments**

- Source: `package.json` engines field
- Source: Script shebangs (bash/sh/zsh detection)
- Source: CI matrix (`.github/workflows/*.yml`)
- Format:
  ```markdown
  - Node.js {{VERSION}}
  - Bash 4+ or Zsh 5+
  - macOS {{VERSION}} (primary), Linux (CI)
  ```

**7. Test Stats** (Optional)

- Source: Test runner output (if available)
- Extract: Coverage %, test file count
- Format: `Coverage: {{PCT}}% ({{COUNT}} test files)`

**8. Documentation Structure**

- Source: Scan `docs/` directories
- Count: Active projects, archived projects, rules, scripts
- Format:
  ```markdown
  - **Scripts**: [link]
  - **Projects**: [link] ({{ACTIVE}} active, {{ARCHIVED}} archived)
  - **Rules**: [link] ({{COUNT}} rules)
  - **Guides**: [link]
  ```

### 4.4 Data Sources

**File Inventory**:

- `.cursor/scripts/*.sh` → script descriptions, flags, examples
- `.cursor/rules/*.mdc` → rule names, descriptions, globs
- `docs/projects/` → active/archived project counts
- `capabilities.mdc` → canonical capabilities list
- `VERSION` → current version
- `CHANGELOG.md` → recent entries
- `package.json` → dependencies, npm scripts

**Metadata Extraction**:

- Script headers: `# Description: ...`, `# Usage: ...`, `# Flags: ...`
- Rule front matter: `description:`, `globs:`, `alwaysApply:`
- ERD front matter: `status:`, `owner:`, `created:`
- [QUESTION: Standardize header comment patterns for reliable extraction?]

### 4.5 CLI Interface

**Proposed Script**: `.cursor/scripts/generate-root-readme.sh`

**Flags**:

- `--template <path>` — Path to template file (default: `templates/root-readme.template.md`)
- `--out <path>` — Output file (default: `README.md`)
- `--dry-run` — Print to stdout without writing
- `--strategy <full|partial|hybrid>` — Generation strategy (if we support multiple)
- `--scripts-section <full|top-10|link-only>` — Script inventory detail level
- `--help` — Usage and flags
- `--version` — Script version

**Examples**:

```bash
# Generate with defaults
./.cursor/scripts/generate-root-readme.sh

# Dry-run preview
./.cursor/scripts/generate-root-readme.sh --dry-run

# Use custom template
./.cursor/scripts/generate-root-readme.sh --template ./custom-template.md

# Link-only scripts section
./.cursor/scripts/generate-root-readme.sh --scripts-section link-only
```

### 4.6 Template Structure

**Proposed Files**:

```
templates/
├── root-readme.template.md    # Main template with placeholders
├── sections/
│   ├── header.md              # Project title, badges, intro
│   ├── workflow-overview.md   # Manual: unified workflow
│   ├── footer.md              # Manual: license, contributing
└── fragments/
    ├── scripts-inventory.sh   # Generator for scripts section
    ├── stats-summary.sh       # Generator for stats
    └── quick-links.sh         # Generator for core links
```

**Placeholder Syntax** (if template-based):

```markdown
<!-- AUTO_SCRIPTS_INVENTORY -->
<!-- AUTO_STATS_SUMMARY -->
<!-- AUTO_QUICK_LINKS -->
<!-- AUTO_HEALTH_BADGE -->
```

[QUESTION: Use simple string replacement or more sophisticated templating?]

### 4.7 Categorization & Organization

**Script Categories** (for inventory section):

- **Git Workflows**: `git-commit.sh`, `git-branch-name.sh`, `pr-create.sh`, `pr-update.sh`, `checks-status.sh`
- **Rules Management**: `rules-list.sh`, `rules-validate.sh`, `rules-autofix.sh`, etc.
- **Project Lifecycle**: `project-create.sh`, `project-complete.sh`, `project-archive-*.sh`, `final-summary-generate.sh`
- **Validation**: `erd-validate.sh`, `validate-artifacts.sh`, `test-colocation-validate.sh`, `shellcheck-run.sh`
- **CI & Health**: `security-scan.sh`, `lint-workflows.sh`, `health-badge-generate.sh`, `compliance-dashboard.sh`
- **Utilities**: `git-context.sh`, `tooling-inventory.sh`, `links-check.sh`

[QUESTION: Use manual category mapping or extract from script headers?]

### 4.8 Validation & Freshness

**Staleness Detection**:

- Compare generated output with current `README.md`
- Flag if discrepancies exceed threshold (e.g., >5 lines different)
- Exit non-zero for CI integration

**Validation Script**: `.cursor/scripts/validate-root-readme.sh`

- Checks: Generated output matches committed README
- Flags: `--fix` (auto-regenerate if stale), `--dry-run`

**CI Integration**:

- Workflow: `.github/workflows/readme-validate.yml`
- Trigger: On push to `main`, PR to `main`
- Action: Run validation, fail if stale

[QUESTION: Acceptable drift tolerance? Require exact match or allow manual tweaks?]

## 5. Non-Functional Requirements

### Performance

- Generation completes in <2s (including script scanning, metadata extraction)
- Dry-run mode for fast preview (<500ms)

### Portability

- POSIX shell compatible (sh/bash/zsh)
- No external dependencies beyond coreutils (grep, sed, awk, find)
- Works on macOS (primary), Linux (CI)

### Reliability

- Gracefully handles missing metadata (fallback to defaults)
- Validates template structure before generation
- Atomic writes (temp file → rename) to prevent corruption

### Maintainability

- Clear separation of concerns (metadata extraction, rendering, I/O)
- Testable components (fixtures for extraction, dry-run for rendering)
- Documented assumptions and parsing patterns

## 6. Architecture/Design

### High-Level Flow

```
Input Sources → Metadata Extraction → Template Rendering → Validation → Output
```

**Components**:

1. **Metadata Extractors** (separate functions or scripts)

   - `extract_script_metadata()` — Scan `.cursor/scripts/`, parse headers
   - `extract_rules_metadata()` — Scan `.cursor/rules/`, parse front matter
   - `extract_project_stats()` — Count active/archived projects
   - `extract_health_metrics()` — Read latest health score, test coverage

2. **Template Renderer**

   - Reads template file
   - Replaces placeholders with generated content
   - Handles conditional sections (e.g., skip scripts section if empty)

3. **Validators**

   - Structure validation: Required sections present, links valid
   - Freshness validation: Compare with committed README
   - Format validation: Markdown syntax, link targets exist

4. **Output Writer**
   - Atomic write pattern (write to `.README.md.tmp` → rename)
   - Dry-run mode outputs to stdout
   - Preserve file permissions if overwriting

### Design Decisions Needed

**Decision 1: Monolithic Script vs Modular**

- Option A: Single large script (200-400 lines)
  - Pros: Simpler invocation, fewer files
  - Cons: Harder to test, violates Unix Philosophy (>150 lines)
- Option B: Main orchestrator + helper scripts
  - Pros: Testable units, follows Unix Philosophy, composable
  - Cons: More files, orchestration complexity
- [RECOMMENDATION: Option B if >200 lines, Option A if <150 lines]

**Decision 2: Template Engine**

- Option A: Simple string replacement (sed/awk)
  - Pros: No dependencies, fast, predictable
  - Cons: Limited logic, no conditionals
- Option B: Lightweight templating (e.g., envsubst, mustache.sh)
  - Pros: Conditionals, loops, cleaner syntax
  - Cons: External dependency or custom implementation
- [RECOMMENDATION: Start with Option A, upgrade if needed]

**Decision 3: Error Handling**

- Strict mode: Fail fast on any missing source file
- Permissive mode: Warn and skip missing sections
- [QUESTION: Which mode for production? Strict for CI, permissive for local?]

## 7. Data Model and Storage

### Input Data

**Scripts Metadata** (extracted from headers):

```json
{
  "path": ".cursor/scripts/git-commit.sh",
  "name": "git-commit",
  "description": "Compose Conventional Commits",
  "category": "git-workflows",
  "flags": ["--type", "--scope", "--description", "--dry-run"],
  "usage": "git-commit.sh --type feat --description '...'",
  "version": "1.0.0"
}
```

**Rules Metadata** (extracted from front matter):

```json
{
  "path": ".cursor/rules/tdd-first.mdc",
  "name": "tdd-first",
  "description": "TDD-First — Three Laws, R/G/R, Specific→Generic",
  "alwaysApply": true,
  "globs": ["**/*.ts", "**/*.tsx", "**/*.js"]
}
```

**Project Stats**:

```json
{
  "active_count": 15,
  "archived_count": 42,
  "total_rules": 38,
  "test_coverage_pct": 85,
  "health_score": 100
}
```

### Output Structure

**Generated README Sections**:

1. Header (title, badges)
2. Unified Workflow Overview (manual or template)
3. Scripts Inventory (auto-generated, categorized)
4. Tests (manual or auto)
5. Auth & Dependencies (manual or auto)
6. Quick Links (auto-generated)
7. Docs & Rules (auto-generated index)
8. What's New (manual or auto from changelog)
9. Changelog & Versioning (manual or link)
10. Footer (contributing, license)

[QUESTION: Final section order and which are required vs optional?]

## 8. API/Contracts

### Script Interface

**Input**: Command-line flags, file system state  
**Output**: Markdown document (stdout or file)  
**Exit Codes**:

- 0: Success (generated or validated)
- 1: Validation failure (stale or invalid template)
- 2: Missing required inputs (template file, VERSION file)
- 3: I/O error (cannot write output)

### Template Contract

**Placeholders** (if template-based):

- `{{HEALTH_BADGE}}` — Repository health badge markdown
- `{{SCRIPTS_INVENTORY}}` — Full scripts list or top N
- `{{STATS_SUMMARY}}` — Active projects, rules, coverage
- `{{QUICK_LINKS}}` — Top rules, docs, recent completions
- `{{VERSION}}` — Current version from VERSION file
- `{{GENERATED_DATE}}` — ISO 8601 timestamp

**Conditionals** (if needed):

- `{{#if SCRIPTS_FULL}}` ... `{{/if}}` — Show full inventory or link-only
- `{{#unless CHANGELOG_EMPTY}}` ... `{{/unless}}` — Skip empty sections

[QUESTION: Support conditionals or keep template simple?]

## 9. Integrations/Dependencies

### Internal Dependencies

- `.cursor/scripts/health-badge-generate.sh` — Health score (if reusing)
- `.cursor/scripts/generate-projects-readme.sh` — Pattern reference
- `capabilities.mdc` — Canonical capabilities list
- `VERSION` — Version string
- `CHANGELOG.md` — Recent changes

### Optional External Tools

- `jq` — JSON processing (if metadata exported as JSON)
- `actionlint` — Workflow validation (for CI integration checks)

### CI Integration

- Workflow: `.github/workflows/readme-validate.yml` (new)
- Trigger: Push to main, PR events
- Action: Validate README freshness, fail if stale

## 10. Edge Cases and Constraints

### Edge Cases

1. **Missing Metadata**

   - Script without description header → use filename as description
   - Rule without description → use "Rule: <name>"
   - Empty categories → omit section or show "No scripts in category"

2. **Large Script Count**

   - 38+ scripts → categorize and show top N, link to full list
   - Threshold: If scripts section >100 lines, switch to link-only mode

3. **Concurrent Edits**

   - Manual edit to README + auto-generation → merge conflict
   - Mitigation: Clear section markers, validation warnings

4. **Template Changes**

   - Template structure evolves → versioning needed?
   - Backward compatibility: Old placeholders still work?

5. **Malformed Headers**
   - Script header missing or non-standard format
   - Fallback: Skip or use minimal metadata

### Constraints

1. **File Size**

   - Root README target: <500 lines (readability)
   - If approaching limit, link to detailed docs instead

2. **Update Frequency**

   - Manual: After adding/removing scripts or rules
   - Automated: On merge to main (CI workflow)
   - Balance: Fresh vs noisy commits

3. **Audience Prioritization**

   - New contributors need: Setup, quick start, workflow overview
   - Existing users need: Scripts reference, docs links
   - AI agents need: Structured links, capabilities catalog
   - [QUESTION: Which audience is primary for content order?]

4. **Link Stability**
   - External tools may link to README anchors
   - Section headers should remain stable across generations
   - Anchors: Use stable IDs, avoid auto-numbering

## 11. Testing & Acceptance

### Test Plan

**Unit Tests** (`.cursor/scripts/generate-root-readme.test.sh`):

1. **Metadata Extraction**

   - Parse script headers correctly
   - Handle missing/malformed headers
   - Extract flags and usage examples

2. **Template Rendering**

   - Replace placeholders accurately
   - Handle conditionals (if supported)
   - Escape special characters in content

3. **Categorization**

   - Scripts sorted into correct categories
   - Category headers included only if non-empty
   - Alphabetical sort within categories

4. **Dry-Run Mode**

   - Outputs to stdout, does not write file
   - Idempotent output (repeated runs identical)

5. **Validation**
   - Detects staleness (generated ≠ committed)
   - Flags missing required sections
   - Validates internal links

**Fixture Strategy**:

```
fixtures/
├── scripts/          # Sample scripts with various header formats
├── rules/            # Sample rules with front matter
├── template.md       # Test template
└── expected/
    └── README.md     # Expected output for comparison
```

**Integration Tests**:

- Run against real repo state (dry-run)
- Validate output structure, link targets
- Performance test: <2s generation time

### Acceptance Criteria

**Must Have**:

- [ ] Script generates valid Markdown output
- [ ] Dry-run mode works, outputs to stdout
- [ ] Scripts inventory section lists all non-test, non-lib scripts
- [ ] Health badge included and linked to latest CI run
- [ ] Stats summary shows accurate counts (projects, rules)
- [ ] Generated README passes Markdown linting
- [ ] Idempotent: Repeated runs produce identical output
- [ ] Test suite passes (6+ test cases)

**Should Have**:

- [ ] Categorized scripts inventory (not flat list)
- [ ] Quick links section with top 5-10 rules
- [ ] Template support for customization
- [ ] Validation script detects staleness
- [ ] CI workflow fails if README stale

**Nice to Have**:

- [ ] Multiple generation strategies (full/partial/hybrid)
- [ ] Auto-update "What's New" from changelog
- [ ] Conditional sections (skip if empty)
- [ ] JSON metadata export for debugging

## 12. Rollout & Ops

### Rollout Plan

**Phase 1: Foundation** (Week 1)

- Decide generation strategy (full/partial/hybrid)
- Create template structure
- Implement metadata extractors (scripts, rules)

**Phase 2: Core Generation** (Week 2)

- Implement main generator script
- Add test suite
- Dry-run validation against current README

**Phase 3: Integration** (Week 3)

- Add npm script `generate:root-readme`
- Create validation script
- CI workflow for staleness check

**Phase 4: Documentation** (Week 4)

- Update contributing guide
- Add project README with usage
- Update root README using generator (dogfooding)

### Operational Considerations

**Manual Workflow**:

```bash
# After adding new script
npm run generate:root-readme

# Validate before commit
./.cursor/scripts/validate-root-readme.sh

# Commit
git add README.md
git commit -m "docs: regenerate root README"
```

**CI Workflow**:

```yaml
# .github/workflows/readme-validate.yml
name: Validate Root README
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Validate README freshness
        run: ./.cursor/scripts/validate-root-readme.sh
```

**Maintenance**:

- Review template quarterly for content drift
- Update categorization as scripts grow
- Adjust generation strategy if pain points emerge

## 13. Success Metrics

### Quantitative

- README regeneration time: <2s
- Staleness incidents: <1 per quarter
- Broken links in README: 0 (validated)
- Test coverage: >80% of generator code

### Qualitative

- Contributor feedback: "Easy to find what I need"
- Maintenance burden: "Regenerate instead of manual edit"
- Consistency: "Always up to date"

## 14. Open Questions

### ✅ Resolved (2025-10-26)

1. **Generation Strategy**: ✅ Full replacement with template

   - Decision: Option A (Full Replacement)
   - See: `decisions/generation-strategy.md`

2. **Scripts Section Detail Level**: ✅ Full categorized list

   - Decision: Show all 38+ scripts organized by category
   - Link to `docs/scripts/README.md` for full details

3. **Template Location**: ✅ Single template file

   - Decision: `templates/root-readme.template.md`
   - Simple placeholder replacement with `{{PLACEHOLDER}}`

4. **Manual vs Auto Sections**: ✅ 9 auto, 6 manual

   - Decision: Documented in `decisions/section-ownership.md`
   - Template encodes manual content + placeholder positions

5. **Priority Projects**: ✅ ERD front matter with blocker support

   - Decision: `priority: high|medium|low` + `blocked: true` + `blocker: "reason"`
   - See: Section 4.3 (Priority Projects)

6. **Known Issues**: ✅ Deferred to follow-up project
   - Decision: Not in MVP, captured as carry over
   - Future: GitHub Issues API integration

### High Priority (Still Blocking)

1. **Update Trigger**: CI validation-only, manual script, or pre-commit hook?
   - Criteria: Git noise tolerance, freshness requirements
   - Impact: Contributor workflow, automation level
   - Options:
     - A: Manual `npm run generate:root-readme` (lowest noise)
     - B: CI validation with `--fail-if-stale` (no auto-commits)
     - C: Pre-commit hook auto-regenerates (highest automation)

### Medium Priority (Design Refinement)

6. **Categorization Source**: Manual mapping or extract from script headers?

   - Criteria: Accuracy, maintenance burden
   - Impact: Metadata extraction complexity

7. **Quick Links Selection**: Top N rules by what metric?

   - Options: Manual curation, reference frequency, always-apply rules
   - Impact: Link section usefulness

8. **"What's New" Source**: Manual, changelog-based, or project-based?

   - Options: Manual edits, parse CHANGELOG.md, recent archived projects
   - Impact: Freshness, automation level

9. **Staleness Tolerance**: Exact match or allow drift?

   - Options: Fail on any difference, allow manual tweaks, marker-based diffing
   - Impact: CI noise, flexibility

10. **Version in README**: Show VERSION file content or git tag?
    - Options: Read VERSION, git describe, package.json version
    - Impact: Synchronization, source of truth

### Low Priority (Future Enhancements)

11. **Templating Engine**: Simple replacement or sophisticated logic?

    - Options: sed/awk, envsubst, custom mustache-like
    - Impact: Complexity, conditional section support

12. **Metadata Caching**: Cache extracted metadata between runs?

    - Options: No cache, JSON cache file, in-memory only
    - Impact: Performance, staleness risks

13. **Multilingual Support**: Generate README in multiple languages?

    - Options: Single English, i18n with templates per language
    - Impact: Complexity, maintenance burden

14. **External Link Validation**: Check links to docs, badges, etc.?

    - Options: No validation, validate internal only, full external check
    - Impact: CI time, reliability

15. **Contribution Graph**: Auto-generate contributor stats?
    - Options: No, GitHub API integration, all-contributors format
    - Impact: Privacy, API dependencies

## 15. References & Related Work

### Internal References

- Existing project: `docs/projects/projects-readme-generator/` — Pattern to follow
- Related project: `docs/projects/document-governance/` — Content organization strategy
- Rule: `.cursor/rules/shell-unix-philosophy.mdc` — Script design principles
- Rule: `.cursor/rules/capabilities.mdc` — Metadata source

### External Patterns

- [Standard Readme](https://github.com/RichardLitt/standard-readme) — README structure convention
- [Awesome README](https://github.com/matiassingers/awesome-readme) — README examples and patterns
- [Keep a Changelog](https://keepachangelog.com/) — Changelog format (for "What's New")

### Design Inspirations

- projects-readme-generator: Discovery pattern, metadata extraction
- git-commit.sh: CLI flag parsing, dry-run mode
- rules-validate.sh: Validation approach, exit codes

---

## Next Steps

**Before starting implementation**, resolve High Priority open questions (1-5) by:

1. User/maintainer interview or survey
2. Prototype 2-3 approaches with current README
3. Decision document in `docs/projects/root-readme-generator/decisions/`

**After decisions made**, proceed with:

1. Phase 1: Foundation (template + metadata extractors)
2. Test suite setup with fixtures
3. TDD cycle: Red → Green → Refactor for each component
