# Changelog

## 0.14.0

### Minor Changes

- [#155](https://github.com/dfadler1984/cursor-rules/pull/155) [`cd52c09`](https://github.com/dfadler1984/cursor-rules/commit/cd52c094822b1ec8bb18d32c3443c6c47560a7dd) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Implement slash command consent bypass and session allowlist visibility

  **Core consent improvements:**

  - Slash commands (`/commit`, `/branch`, `/pr`, `/allowlist`) now bypass consent gate entirely
  - Added `/allowlist` cursor command to display active session consent grants
  - Documented grant/revoke syntax for session allowlist management
  - Added natural language triggers for allowlist queries

  **Impact:** Eliminates over-prompting on slash commands. Typing `/commit` is direct consent; no "Proceed?" prompt needed.

## 0.13.2

### Patch Changes

- [#153](https://github.com/dfadler1984/cursor-rules/pull/153) [`6d84112`](https://github.com/dfadler1984/cursor-rules/commit/6d841127c4483d6d2f0d60437f81164d0c367684) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Define TDD scope boundaries, add slash command consent, and remove static command catalog

  - **TDD Scope**: Narrowed tdd-first.mdc to code files only (_.ts, _.tsx, _.js, _.jsx, _.mjs, _.cjs, \*.sh)
  - **TDD Validation**: Added tdd-scope-check.sh script with comprehensive test suite (24 assertions passing)
  - **Slash Commands**: Added explicit consent policy - /branch, /commit, /pr execute immediately without "Proceed?" prompts
  - **Command Discovery**: Removed static commands.caps.mdc; created project for dynamic discovery solution

## 0.13.1

### Patch Changes

- [#150](https://github.com/dfadler1984/cursor-rules/pull/150) [`833f326`](https://github.com/dfadler1984/cursor-rules/commit/833f326d263157150f4e0209641539a8afbff55a) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Add context efficiency gauge command and rules/docs quality detection project

  - New `/gauge` command for checking context health and efficiency
  - New project: rules-docs-quality-detection with full ERD and task breakdown
  - Project targets: duplicate detection, conflict detection, and stale content flagging

## 0.13.0

### Minor Changes

- [#149](https://github.com/dfadler1984/cursor-rules/pull/149) [`a8934e2`](https://github.com/dfadler1984/cursor-rules/commit/a8934e21e6a5b6c6b0fcfff5021b4bb42ffc0377) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Complete rules-enforcement-investigation with validated findings and synthesis

  **Investigation Complete (Active)**: H1 validated at 100% compliance (+26 points, exceeds 90% target). Created comprehensive synthesis with enforcement pattern decision tree and categorized all 25 conditional rules.

  **Key Findings**:

  - AlwaysApply for critical rules: 74% → 100% script usage (+26 points)
  - Visible OUTPUT requirements: 0% → 100% visibility
  - Advisory guidance violated 6 times during investigation (validates findings)
  - Decision tree created for choosing enforcement patterns
  - 14 meta-findings documented (6 rule improvements applied, 8 proposed)

  **Deliverables**:

  - Measurement tools (4 compliance checkers + dashboard)
  - Synthesis document (664 lines with decision tree and categorization)
  - Test plan template (reusable structure)
  - Investigation-structure rule (complex investigation organization)
  - Phase 6G: 6 rule improvements tracked as carryover work

  See docs/projects/rules-enforcement-investigation/analysis/synthesis.md for complete findings.

## 0.12.2

### Patch Changes

- [#147](https://github.com/dfadler1984/cursor-rules/pull/147) [`4281c79`](https://github.com/dfadler1984/cursor-rules/commit/4281c79a77f7fb1313d014ee7659a5ad44fe3b57) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Complete H1 validation for rules-enforcement-investigation. Primary fix (git-usage → alwaysApply: true) validated at 100% compliance (+26 points), exceeding 90% target. Project status updated, synthesis plan created for Phase 6D.

## 0.12.1

### Patch Changes

- [#145](https://github.com/dfadler1984/cursor-rules/pull/145) [`27636f8`](https://github.com/dfadler1984/cursor-rules/commit/27636f83e173745d01be8262753f8a2088cc831e) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Complete hooks, modes, and TDD compliance investigation with prompt templates implementation.

  **Key findings**:

  - Hooks NOT viable (organization policy blocks experiment flag)
  - TDD compliance 92% (was 83% due to measurement error)
  - AlwaysApply NOT needed for TDD rules (globs work, 92% sufficient)
  - Prompt templates implemented (5 templates: commit, pr, branch, test, status)

  **Changes**:

  - Improved TDD compliance checker (filters doc-only changes)
  - Added missing test (setup-remote.test.sh)
  - Updated git-slash-commands.mdc (alwaysApply: false, template guidance)
  - Created `.cursor/commands/` templates for discoverability

  **Investigation deliverables**: 12 comprehensive analysis documents in `docs/projects/rules-enforcement-investigation/`

  **Compliance**: 96% git-usage, 92% TDD, >92% overall (exceeds 90% target)

## 0.12.0

### Minor Changes

- [#143](https://github.com/dfadler1984/cursor-rules/pull/143) [`8b1fdbc`](https://github.com/dfadler1984/cursor-rules/commit/8b1fdbc6c73552c4436afab47d3ea54ebedc7d0a) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Complete H1 validation for rules-enforcement-investigation (80% compliance), deliver assistant-self-testing-limits project (100%), and discover Cursor hooks as potential enforcement pattern. Investigation progress: ~50% → ~60%.

## 0.11.3

### Patch Changes

- [#140](https://github.com/dfadler1984/cursor-rules/pull/140) [`c0ef836`](https://github.com/dfadler1984/cursor-rules/commit/c0ef8363304039dfd74c3c0246283485a970e0b5) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Add complex investigation structure guidance to project-lifecycle

  - docs: Added "Complex Investigation Structure" section to project-lifecycle.mdc
  - Defines when to use complex structure (>15 files, multiple hypotheses) vs simple projects
  - Documents 10 folder types: findings/, analysis/, decisions/, guides/, protocols/, sessions/, test-results/, tests/, \_archived/
  - Explains decision framework and sub-projects pattern
  - Links to rules-enforcement-investigation example and full standard

  Addresses Gap #11 from rules-enforcement-investigation.

## 0.11.2

### Patch Changes

- [#138](https://github.com/dfadler1984/cursor-rules/pull/138) [`09241a8`](https://github.com/dfadler1984/cursor-rules/commit/09241a8b394e18239025bccf415e37f3eb8bd658) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Add complex investigation structure guidance to project-lifecycle

  - docs: Added "Complex Investigation Structure" section to project-lifecycle.mdc
  - Defines when to use complex structure (>15 files, multiple hypotheses) vs simple projects
  - Documents 10 folder types: findings/, analysis/, decisions/, guides/, protocols/, sessions/, test-results/, tests/, \_archived/
  - Explains decision framework and sub-projects pattern
  - Links to rules-enforcement-investigation example and full standard

  Addresses Gap #11 from rules-enforcement-investigation.

## 0.11.1

### Patch Changes

- [#135](https://github.com/dfadler1984/cursor-rules/pull/135) [`733c98c`](https://github.com/dfadler1984/cursor-rules/commit/733c98c481717af83bc59bce88f6ad925636b9bd) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Reorganize investigation documentation structure

  - refactor: Reorganized rules-enforcement-investigation from 40 files in 5 directories to 10 purpose-driven folders
  - feat: Created 3 sub-projects (h2-send-gate-investigation, h3-query-visibility, slash-commands-runtime-routing)
  - feat: Added coordination.md to track sub-projects
  - feat: Created investigation-docs-structure project with reusable structure standard
  - docs: Gap #11 documented - investigation documentation structure not defined

  Structure changes: findings/, decisions/, guides/, protocols/, sessions/, test-results/, analysis subfolders, \_archived/. All files preserved via git mv.

## 0.11.0

### Minor Changes

- [#132](https://github.com/dfadler1984/cursor-rules/pull/132) [`2e33155`](https://github.com/dfadler1984/cursor-rules/commit/2e331552dd2cc3352133b22817ad8991062d70f3) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Implement slash commands enforcement pattern and document assistant self-testing limits

  - feat: Created git-slash-commands.mdc with enforcement protocol for /commit, /pr, /branch, /pr-update
  - feat: Updated intent-routing.mdc to route slash commands at highest priority
  - feat: Created assistant-self-testing-limits project documenting testing paradox
  - fix: Added process-order trigger to self-improve.mdc (Gap #7)
  - docs: Updated rules-enforcement-investigation with Gaps #7 and #8

  Decision: Slash commands Phase 3 testing deferred - H1 (alwaysApply) already achieving 96% compliance (target >90%). Testing paradox identified: assistants cannot objectively measure own behavior without observer bias.

## 0.10.1

### Patch Changes

- [#130](https://github.com/dfadler1984/cursor-rules/pull/130) [`cf849ad`](https://github.com/dfadler1984/cursor-rules/commit/cf849ad8267433568642f148bca7bdd5cb0b4844) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Add project document organizer script and reorganize investigation docs

  - Created reusable project-docs-organize.sh with investigation/minimal patterns
  - Reorganized rules-enforcement-investigation docs (34 → 7 root files, 81% reduction)
  - Added H3 visible query output requirement to script-first protocol
  - Documented meta-violation as validation data

## 0.10.0

### Minor Changes

- [#128](https://github.com/dfadler1984/cursor-rules/pull/128) [`394d9ff`](https://github.com/dfadler1984/cursor-rules/commit/394d9ff66eeeae313e461e029d8fe08674cf9550) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Rules enforcement investigation progress and 6 rule improvements

  - Add lifecycle stages and pre-closure checklist to project-lifecycle.mdc
  - Add ERD scope definition and acceptance criteria format to create-erd.mdc
  - Add task structure guidance to generate-tasks-from-erd.mdc
  - Add investigation gap flagging to self-improve.mdc
  - Add visible gate output requirement to assistant-behavior.mdc
  - Complete Discovery and Review phases of rules-enforcement investigation
  - Execute H2 Test A (0% gate visibility baseline) and Test D Checkpoint 1 (100% visibility confirmed)

## 0.9.3

### Patch Changes

- [#125](https://github.com/dfadler1984/cursor-rules/pull/125) [`79284ee`](https://github.com/dfadler1984/cursor-rules/commit/79284eeacead24e5b24a0ef25fd39638ffb6c522) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Comprehensive rule maintenance and cleanup

  - Remove duplicate and deprecated ALP content from assistant-behavior.mdc (320→282 lines)
  - Fix date in 00-assistant-laws.mdc
  - Remove deprecated logging-protocol.caps reference from create-erd.caps.mdc
  - Consolidate duplicate content in create-erd.mdc (242→127 lines)
  - Delete deprecated logging-protocol.caps.mdc

  All 57 rules now pass validation with green health scores.

## 0.9.2

### Patch Changes

- [#122](https://github.com/dfadler1984/cursor-rules/pull/122) [`0415dbb`](https://github.com/dfadler1984/cursor-rules/commit/0415dbb97a9b1514f6918846b2704d977a9e950b) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Consolidate rules-enforcement-investigation docs and document 6 rule gaps. Fix assistant-git-usage.mdc conditional attachment issue and add compliance measurement framework.

## 0.9.1

### Patch Changes

- [#119](https://github.com/dfadler1984/cursor-rules/pull/119) [`2d47b53`](https://github.com/dfadler1984/cursor-rules/commit/2d47b534e319d1b296b33fefa4abfe78329052cf) Thanks [@dfadler1984](https://github.com/dfadler1984)! - feat: archive shell-and-script-tooling and 8 child projects

  Complete archival of shell script infrastructure project suite (9 projects total). All objectives achieved:

  - **Infrastructure complete**: D1-D6 standards implemented across 45 production scripts
  - **ShellCheck integration**: Zero errors, zero warnings, CI enforced
  - **Orchestrators**: 3 major scripts refactored (839 lines reduced, 48% average)
  - **Focused alternatives**: 10 single-responsibility scripts created
  - **Testing**: 56 tests passing, comprehensive coverage
  - **Enforcement**: Unix Philosophy rule prevents future violations

  Follow-up work (P3 optional refinements) moved to active `script-refinement` project.

## 0.9.0

### Minor Changes

- [#116](https://github.com/dfadler1984/cursor-rules/pull/116) [`f654233`](https://github.com/dfadler1984/cursor-rules/commit/f65423388d1abd12da715b97a035749307789249) Thanks [@dfadler1984](https://github.com/dfadler1984)! - refactor: convert major scripts to Unix Philosophy orchestrators

  Convert 3 major monolithic scripts to thin orchestrators achieving 48% average line reduction:

  - **rules-validate.sh**: 497 → 301 lines (40% reduction) - delegates to 5 focused validators
  - **context-efficiency-gauge.sh**: 342 → 124 lines (64% reduction) - delegates to score + format scripts
  - **pr-create.sh**: deprecated with notice, recommends focused alternatives

  **New script extracted:**

  - `context-efficiency-format.sh` (282 lines) - formats efficiency scores in 4 modes

  **Total reduction:** 414 lines removed while maintaining full backward compatibility.

  **Testing:** All 56 tests passing, no regressions.

  Remaining optional work (P3 priority) deferred to new `script-refinement` project.

## 0.8.0

### Minor Changes

- [#114](https://github.com/dfadler1984/cursor-rules/pull/114) [`7782a84`](https://github.com/dfadler1984/cursor-rules/commit/7782a8488396b5b4d0760c7fd0fa469181748d47) Thanks [@dfadler1984](https://github.com/dfadler1984)! - feat: Unix Philosophy extraction - 9 focused scripts + enforcement rule

  Complete Unix Philosophy compliance infrastructure for shell scripts:

  - **9 new focused scripts** (all TDD-tested, D1-D6 compliant):

    - Rules validation: `rules-validate-frontmatter.sh`, `rules-validate-refs.sh`, `rules-validate-staleness.sh`, `rules-validate-format.sh`, `rules-autofix.sh`
    - GitHub automation: `git-context.sh`, `pr-create-simple.sh`, `pr-label.sh`
    - Context efficiency: `context-efficiency-score.sh`

  - **Enforcement rule**: `.cursor/rules/shell-unix-philosophy.mdc` prevents future violations

  - **ShellCheck integration**: Complete with `.shellcheckrc`, zero errors/warnings across 104 scripts

  - **Documentation updates**: Corrected script counts (44 production, 55 tests) and status across all project docs

  - **Infrastructure complete**: All validators passing (help, error, network, ShellCheck, tests)

  This provides focused, single-responsibility alternatives to monolithic scripts while maintaining backward compatibility. Originals remain functional; orchestration updates are optional future work.

## 0.7.2

### Patch Changes

- [#111](https://github.com/dfadler1984/cursor-rules/pull/111) [`b09ba1c`](https://github.com/dfadler1984/cursor-rules/commit/b09ba1c61f90a9155d00dae7c79a363b6604fa09) Thanks [@dfadler1984](https://github.com/dfadler1984)! - # Fix shell-and-script-tooling documentation accuracy

  ## Documentation Corrections

  Corrected script counts and project status across shell-and-script-tooling documentation to match actual implementation.

  ### Script Count Corrections

  - Fixed script count from 36 to 37 throughout all documentation
  - Added setup-remote.sh to documented scripts (dependency checking utility)
  - Updated network usage from 4 to 5 scripts (added setup-remote.sh)
  - Corrected test count from 52 to 46 (consistent across all docs)

  ### Files Updated

  **shell-and-script-tooling project:**

  - `docs/projects/shell-and-script-tooling/erd.md` - All count references corrected
  - `docs/projects/shell-and-script-tooling/tasks.md` - Added Task 19.0 (source project reconciliation), corrected counts
  - `docs/projects/shell-and-script-tooling/PROGRESS.md` - Updated compliance dashboard and counts
  - `.changeset/shell-script-tooling-complete.md` - Updated to reflect accurate counts

  **tests-github-deletion project:**

  - `docs/projects/tests-github-deletion/erd.md` - Marked completed (2025-10-13), added resolution summary
  - `docs/projects/tests-github-deletion/tasks.md` - Marked all tasks complete, added resolution summary

  ### New Content

  - Added Task 19.0: Source project task reconciliation (8 subtasks for aligning individual project tasks)
  - Added "Known Issues & Documentation Notes" section documenting decisions (e.g., .shellcheckrc not needed)
  - Documented that tests-github-deletion project is resolved and ready for archival

  ### Verification

  All validators still pass with corrected counts:

  - `help-validate.sh`: 37 scripts validated ✅
  - `error-validate.sh`: 37 scripts validated, 0 warnings ✅
  - Full test suite: 46/46 tests passing ✅

## 0.7.1

### Patch Changes

- [#109](https://github.com/dfadler1984/cursor-rules/pull/109) [`9725260`](https://github.com/dfadler1984/cursor-rules/commit/97252605e69f7547cdef07e9a0111f26299816e1) Thanks [@dfadler1984](https://github.com/dfadler1984)! - # Complete shell-and-script-tooling project (100%)

  ## Shell Script Standards & Tooling

  Complete all remaining work for the shell-and-script-tooling unified project, achieving 100% standards compliance across all 36 maintained scripts and full adoption tracking across 8 source projects.

  ### Phase 4: Help Documentation (100% Complete)

  - Fixed 4 remaining scripts to pass `help-validate.sh`:
    - `pr-create.sh`: Added Options section with template functions
    - `pr-update.sh`: Added Options, Examples, Exit Codes sections
    - `changesets-automerge-dispatch.sh`: Added Options, Examples, Exit Codes sections + strict mode
    - `checks-status.sh`: Added Examples, Exit Codes sections
  - **Result**: All 36/36 scripts now have complete help documentation

  ### Phase 3: Adoption Tracking (100% Complete)

  - Updated 8 source projects with D1-D6 adoption status and backlinks
  - All projects document 100% adoption of cross-cutting decisions (D1-D6)

  ### Phase 6: Documentation & CI (100% Complete)

  - Created comprehensive `MIGRATION-GUIDE.md` (373 lines) with step-by-step instructions
  - Added CI enforcement via `.github/workflows/shell-validators.yml`
  - Validators run on every PR: help and error validation block on failure

  ### Standards Compliance

  All 36 scripts now comply with all 6 cross-cutting decisions:

  - **D1** (100%): Help/Version with Options, Examples, Exit Codes sections
  - **D2** (100%): Strict mode (`set -euo pipefail`)
  - **D3** (100%): Standardized exit codes (EXIT_USAGE, EXIT_CONFIG, etc.)
  - **D4** (100%): Test isolation (tests use seams/fixtures)
  - **D5** (100%): Portability (bash + git only, graceful degradation)
  - **D6** (100%): Environment isolation (subshell isolation in tests)

  ### Files Changed

  - Modified: 4 scripts, 8 source project tasks.md, 3 project docs, 1 README
  - Added: shell-validators.yml CI workflow, MIGRATION-GUIDE.md

  See: `docs/projects/shell-and-script-tooling/` for full project documentation.

## 0.7.0

### Minor Changes

- [#107](https://github.com/dfadler1984/cursor-rules/pull/107) [`f297af6`](https://github.com/dfadler1984/cursor-rules/commit/f297af6fc15467cd025756bf795e36729f06b6c0) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Add Context Efficiency Gauge for chat context health monitoring

  Implements task 1.0 from chat-performance-and-quality-tools project:

  - New rule: `context-efficiency.mdc` with 1-5 scoring rubric
  - New script: `context-efficiency-gauge.sh` (zero-dependency bash)
  - Test suite: 22 tests, all passing
  - Intent routing: "show gauge" and other natural phrases
  - Integration: Automatic display in status updates when score ≤3

  Provides qualitative heuristics to assess context health using observable signals (scope clarity, rules count, clarification loops, user issues) without requiring token counts.

## 0.6.0

### Minor Changes

- [#105](https://github.com/dfadler1984/cursor-rules/pull/105) [`4d8664d`](https://github.com/dfadler1984/cursor-rules/commit/4d8664de430055d895f81cb5c22f27175c327cb2) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Add Context Efficiency Gauge for chat context health monitoring

  Implements task 1.0 from chat-performance-and-quality-tools project:

  - New rule: `context-efficiency.mdc` with 1-5 scoring rubric
  - New script: `context-efficiency-gauge.sh` (zero-dependency bash)
  - Test suite: 22 tests, all passing
  - Intent routing: "show gauge" and other natural phrases
  - Integration: Automatic display in status updates when score ≤3

  Provides qualitative heuristics to assess context health using observable signals (scope clarity, rules count, clarification loops, user issues) without requiring token counts.

## 0.5.1

### Patch Changes

- [#103](https://github.com/dfadler1984/cursor-rules/pull/103) [`4196ff9`](https://github.com/dfadler1984/cursor-rules/commit/4196ff970e0fbecb7c0beedf91b59166c720d1f6) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Add four new projects: routing-optimization, consent-gates-refinement, tdd-scope-boundaries, and project-lifecycle-coordination

## 0.5.0

### Minor Changes

- [#99](https://github.com/dfadler1984/cursor-rules/pull/99) [`e0a8e25`](https://github.com/dfadler1984/cursor-rules/commit/e0a8e25630e4b6ab7ec18736c535bd049184462f) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Deactivate legacy Assistant Learning (ALP) and migrate to a new `assistant-self-improvement` project.

  - Add `docs/projects/assistant-self-improvement/` with `erd.md`, `tasks.md`
  - Archive ALP rules/scripts under `legacy/` (rules + `alp-*.sh` tests)
  - Remove `.cursor/rules/assistant-learning*.mdc` and purge ALP references from active rules/docs
  - Mark related ERDs as `status: skipped`:
    - `assistant-learning-hard-gate`, `alp-smoke`, `logging-destinations`
  - Disable ALP GitHub workflows (`alp-aggregate.yml`, `alp-smoke.yml`)

  Notes:

  - ALP scripts are no longer available under `.cursor/scripts/`
  - No CI aggregation/smoke runs for ALP

## 0.4.0

### Minor Changes

- [#97](https://github.com/dfadler1984/cursor-rules/pull/97) [`c5c1841`](https://github.com/dfadler1984/cursor-rules/commit/c5c184106d6b463e7fc5caf7d09c4c6ae4bd14ed) Thanks [@dfadler1984](https://github.com/dfadler1984)! - feat: align lifecycle validators, tests, docs; add wrappers

  - Validators: add scoped/sweep wrappers; polish messages; BSD awk compatibility
  - Tests: archive workflow post-move default; generator minimal assertions; scoped validator env/grep fix
  - Docs: make lifecycle rule canonical; update ERD/tasks; post-move default
  - Templates: keep final-summary minimal (generator fills title/date/links)
  - Misc: ALP entries and related project scaffolds added

## 0.3.24

### Patch Changes

- [#95](https://github.com/dfadler1984/cursor-rules/pull/95) [`a9ed433`](https://github.com/dfadler1984/cursor-rules/commit/a9ed433dbc0055bb0d079cd8d67f5a51970702bd) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Archive ALP Logging project via full-folder move and add a generated final summary. Update ALP behavior/learning rules and docs with status formats, event glossary, noise control, fallback handling, aggregation/archival steps, and a Logs Quickstart.

## 0.3.23

### Patch Changes

- [#93](https://github.com/dfadler1984/cursor-rules/pull/93) [`89fb625`](https://github.com/dfadler1984/cursor-rules/commit/89fb625b0489fef05d658eccca329e0604e8d1c0) Thanks [@dfadler1984](https://github.com/dfadler1984)! - docs(ai-workflow): consolidate framework-selection and deterministic-outputs into ai-workflow-integration; archive originals

## 0.3.22

### Patch Changes

- [#91](https://github.com/dfadler1984/cursor-rules/pull/91) [`17804a7`](https://github.com/dfadler1984/cursor-rules/commit/17804a73314f20f7b9a06775afce4e6c2a952438) Thanks [@dfadler1984](https://github.com/dfadler1984)! - docs(projects): archive changelog-automation; update Completed index

## 0.3.21

### Patch Changes

- [#89](https://github.com/dfadler1984/cursor-rules/pull/89) [`3859c6a`](https://github.com/dfadler1984/cursor-rules/commit/3859c6a84ae4bbcfbe0ae28f2f424a2149ad21f9) Thanks [@dfadler1984](https://github.com/dfadler1984)! - docs: add ALP logging project (erd, tasks, discussion); update pr-create usage guidance; dedupe PR template; archive pr-create-script project

## 0.3.20

### Patch Changes

- [#87](https://github.com/dfadler1984/cursor-rules/pull/87) [`168eb41`](https://github.com/dfadler1984/cursor-rules/commit/168eb419df6d80abed9692a121162ed85dc67919) Thanks [@dfadler1984](https://github.com/dfadler1984)! - docs(projects): archive auto-merge-bot-changeset-version via git mv; add final summary

## 0.3.19

### Patch Changes

- [#85](https://github.com/dfadler1984/cursor-rules/pull/85) [`c478ab0`](https://github.com/dfadler1984/cursor-rules/commit/c478ab036e955150a90ad3a48b064d4a3f5bc5e3) Thanks [@dfadler1984](https://github.com/dfadler1984)! - ci: changeset to re-trigger release flow and validate auto-merge permissions

## 0.3.18

### Patch Changes

- [#84](https://github.com/dfadler1984/cursor-rules/pull/84) [`12bb8fd`](https://github.com/dfadler1984/cursor-rules/commit/12bb8fd83a4af34b0c9a3c65e1546f7a227ffdcd) Thanks [@dfadler1984](https://github.com/dfadler1984)! - ci: attach jobs to AUTO_MERGE_TOKEN environment so env-scoped PAT is available

- [#82](https://github.com/dfadler1984/cursor-rules/pull/82) [`150b168`](https://github.com/dfadler1984/cursor-rules/commit/150b1688d92f93a8c9a5b3ea62b1330e87918456) Thanks [@dfadler1984](https://github.com/dfadler1984)! - ci: add test changeset to trigger Changesets release PR and validate auto-merge

## 0.3.17

### Patch Changes

- [#79](https://github.com/dfadler1984/cursor-rules/pull/79) [`01440be`](https://github.com/dfadler1984/cursor-rules/commit/01440be23cfca1346a8cb5b25c4fbe88a09b2cc1) Thanks [@dfadler1984](https://github.com/dfadler1984)! - ci: use AUTO_MERGE_TOKEN for enable-pull-request-automerge

  Switch the auto-merge workflow to a PAT-backed secret so the gh CLI
  and action have permission to enable auto-merge on Changesets PRs.

## 0.3.16

### Patch Changes

- [#77](https://github.com/dfadler1984/cursor-rules/pull/77) [`c2efdd9`](https://github.com/dfadler1984/cursor-rules/commit/c2efdd932455d85656efaf572f65e9ae6c21dc5b) Thanks [@dfadler1984](https://github.com/dfadler1984)! - ci: fix Changesets auto-merge by exporting GH_TOKEN and using github.token

  This ensures the `enable-pull-request-automerge` action's gh CLI has the
  required token and reliably enables auto-merge on Changesets release PRs.

## 0.3.15

### Patch Changes

- [#75](https://github.com/dfadler1984/cursor-rules/pull/75) [`10f43cb`](https://github.com/dfadler1984/cursor-rules/commit/10f43cb1f2b23576a535c35aaf7b406fabc33953) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Use a PAT-backed secret for enabling PR auto-merge.

  - Update `.github/workflows/changesets-auto-merge.yml` to use `secrets.AUTO_MERGE_TOKEN` instead of `secrets.GITHUB_TOKEN` to avoid GraphQL permission errors when enabling auto-merge.

## 0.3.14

### Patch Changes

- [#73](https://github.com/dfadler1984/cursor-rules/pull/73) [`51861ea`](https://github.com/dfadler1984/cursor-rules/commit/51861eac456b4bcb63e2fcc8a4734dcd9b89d313) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Remove legacy auto-merge workflow.

  - Delete `.github/workflows/auto-merge-changesets.yml` to avoid duplicate runs and the deprecated `gh pr merge` path. Keep a single source of truth in `changesets-auto-merge.yml`.

## 0.3.13

### Patch Changes

- [#71](https://github.com/dfadler1984/cursor-rules/pull/71) [`b2d7558`](https://github.com/dfadler1984/cursor-rules/commit/b2d75582ad9a24da6655b5a84865a177297b616f) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Switch Changesets auto-merge to use squash method.

  - Update `.github/workflows/changesets-auto-merge.yml` to `merge-method: squash` in both jobs so Version Packages PRs produce a single clean commit when merged.

## 0.3.12

### Patch Changes

- [#69](https://github.com/dfadler1984/cursor-rules/pull/69) [`1f0646f`](https://github.com/dfadler1984/cursor-rules/commit/1f0646f689dcf64784bac93a624d97ee87c69b20) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Add helper script to manually dispatch the Changesets auto-merge workflow.

  - `.cursor/scripts/changesets-automerge-dispatch.sh` — triggers `changesets-auto-merge.yml` with `pr=<number>`

## 0.3.11

### Patch Changes

- [#67](https://github.com/dfadler1984/cursor-rules/pull/67) [`2d9e110`](https://github.com/dfadler1984/cursor-rules/commit/2d9e110c4a4cba2c3f9b7d09b1c364f4a6874f38) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Reintroduce Changesets auto-merge MVP using `workflow_run` + optional `workflow_dispatch`.

  - Enable Auto-merge when the `Changesets` workflow completes successfully
  - Keep manual `workflow_dispatch pr=<number>` for backfill on existing release PRs

## 0.3.10

### Patch Changes

- [#65](https://github.com/dfadler1984/cursor-rules/pull/65) [`841b1a0`](https://github.com/dfadler1984/cursor-rules/commit/841b1a0b77af868378197b4caef4bff5a51dc6c0) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Refine Changesets auto-merge to MVP: `workflow_run` (Changesets) + optional manual dispatch.

  - Enable Auto-merge after the Changesets workflow completes successfully
  - Keep `workflow_dispatch pr=<number>` for backfill on existing release PRs
  - Single job resolves the target PR (title/head + bot) and enables Auto-merge (squash)

## 0.3.9

### Patch Changes

- [#63](https://github.com/dfadler1984/cursor-rules/pull/63) [`c4ab8d7`](https://github.com/dfadler1984/cursor-rules/commit/c4ab8d75347317c0e9bc43bba48196fc5d9b5be7) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Simplify Changesets auto-merge to a minimal, reliable workflow.

  - Use `workflow_run` on `Changesets` (types: completed) to enable Auto-merge
  - Keep optional `workflow_dispatch pr=<number>` for backfill on existing PRs
  - Single job: resolve target PR (title/head + bot) and enable Auto-merge (squash)

## 0.3.8

### Patch Changes

- [#61](https://github.com/dfadler1984/cursor-rules/pull/61) [`5c90593`](https://github.com/dfadler1984/cursor-rules/commit/5c9059311609ebe4e7d5b2d111f9e10c22d24382) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Improve Changesets auto-merge reliability by reacting to the release workflow completion.

  - Add `workflow_run` trigger for the `Changesets` workflow (types: completed)
  - On success, find the open “Version Packages” PR and enable Auto-merge
  - Keep manual `workflow_dispatch` for backfill

## 0.3.7

### Patch Changes

- [#59](https://github.com/dfadler1984/cursor-rules/pull/59) [`28212e1`](https://github.com/dfadler1984/cursor-rules/commit/28212e1557126fb466404e7d440fdd3705ab56cc) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Add a reliable workflow to auto‑enable GitHub Auto‑merge for Changesets “Version Packages” PRs.

  - Dual triggers (`pull_request`, `pull_request_target`) with strict scope (title/head + author)
  - Manual `workflow_dispatch` to backfill enabling auto‑merge on an existing release PR
  - Permissions: `pull-requests: write`, `contents: read`
  - Logs targeted PR details for observability (title/head/author)

## 0.3.6

### Patch Changes

- [#57](https://github.com/dfadler1984/cursor-rules/pull/57) [`f1e535b`](https://github.com/dfadler1984/cursor-rules/commit/f1e535b507614c3815cba67be7a6b5710004ba0d) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Fix manual dispatch for enabling auto-merge on Changesets release PRs.

  - Use `github.rest.pulls.list` in `actions/github-script@v7`
  - Add guard to fail fast when no release PR is found

## 0.3.5

### Patch Changes

- [#55](https://github.com/dfadler1984/cursor-rules/pull/55) [`aa095a2`](https://github.com/dfadler1984/cursor-rules/commit/aa095a2c13c0bc1b027c17c7d4938ecd5762590a) Thanks [@dfadler1984](https://github.com/dfadler1984)! - docs(cursor-modes): add ERD and tasks for Cursor modes integration

  Includes `docs/projects/cursor-modes/erd.md` and `docs/projects/cursor-modes/tasks.md` with citations to:

  - Plan Mode announcement (product blog)
  - Agent/Ask/Manual docs hub
  - Changelog entry for Custom Modes

## 0.3.4

### Patch Changes

- [#53](https://github.com/dfadler1984/cursor-rules/pull/53) [`ac9a8dc`](https://github.com/dfadler1984/cursor-rules/commit/ac9a8dcd620d21137444945ae11ff5995f3fec1d) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Harden Changesets auto-merge enablement for release PRs.

  - Switch workflow to `pull_request_target` to ensure sufficient permissions
  - Add `workflow_dispatch` to enable auto-merge on an existing release PR (e.g., PR #52)
  - Keeps scope limited to titles starting with "Version Packages" or `changeset-release/*`

## 0.3.3

### Patch Changes

- [#51](https://github.com/dfadler1984/cursor-rules/pull/51) [`c4579f5`](https://github.com/dfadler1984/cursor-rules/commit/c4579f5101e3d3bc57bd1a5081400040bf73fbab) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Enable auto-merge for Changesets release PRs via GitHub Actions.

  - Add `.github/workflows/auto-merge-changesets.yml` using `peter-evans/enable-pull-request-automerge@v3`
  - Auto-enables PR auto-merge for titles starting with "Version Packages" after required checks pass
  - Requires repo setting "Allow auto-merge" and branch protection checks

## 0.3.2

### Patch Changes

- [#49](https://github.com/dfadler1984/cursor-rules/pull/49) [`cbdca41`](https://github.com/dfadler1984/cursor-rules/commit/cbdca41f068bda0c13ddc4808d6ba1b94b0e39cf) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Finalize project-erd-front-matter (archive + final summary) and strengthen ERD validation.

  - ERD set to completed; final summary generated; archived folder + index updated
  - Validator enforces status|owner|lastUpdated for project ERDs; tests added
  - pr-create auto-replace for full bodies (## Summary) with tests
  - Assistant behavior rule: fix PR link example formatting

## 0.3.1

### Patch Changes

- [#46](https://github.com/dfadler1984/cursor-rules/pull/46) [`0a4436e`](https://github.com/dfadler1984/cursor-rules/commit/0a4436ebefe9dbe1c5ed3a9bf9e8f312cfa3d277) Thanks [@dfadler1984](https://github.com/dfadler1984)! - docs: fold spec-driven into ai-workflow-integration; update references; remove old docs

## 0.3.0

### Minor Changes

- [#44](https://github.com/dfadler1984/cursor-rules/pull/44) [`64b5871`](https://github.com/dfadler1984/cursor-rules/commit/64b5871248b338683457de872be61d5010997304) Thanks [@dfadler1984](https://github.com/dfadler1984)! - ALP: add auto summary→mark→archive hook, portability fix in aggregator, tests for threshold/logger/triggers, and docs updates (mandatory trigger logging + ≥3‑incidents improvement threshold).

## 0.2.2

### Patch Changes

- [#42](https://github.com/dfadler1984/cursor-rules/pull/42) [`362ab23`](https://github.com/dfadler1984/cursor-rules/commit/362ab23b706880c15302c86508e43d7faf80e311) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Sync ERD/tasks with router rules; add outbound message checklist; require ANSI-C quoting/heredoc for multi-line PR bodies in PR scripts.

## 0.2.1

### Patch Changes

- [#40](https://github.com/dfadler1984/cursor-rules/pull/40) [`e745820`](https://github.com/dfadler1984/cursor-rules/commit/e7458208bf5eb12956f6f8789253d2f8e7a0bfbf) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Archive rules-validate-script; limit link checker to relative links; update tests; add URL formatting rule; default to including a Changeset for PRs.

## 0.2.0

### Minor Changes

- [#38](https://github.com/dfadler1984/cursor-rules/pull/38) [`6406de5`](https://github.com/dfadler1984/cursor-rules/commit/6406de5e819fe79c0d6b8f75c9bbe477cb85a76a) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Enhance rules validator: add JSON output, missing-references failure, 90-day staleness warnings/strict mode, autofix for formatting-only issues, and review report generation; update docs/capabilities; add CI; archive rule-maintenance project.

## 0.1.0

### Minor Changes

- [#36](https://github.com/dfadler1984/cursor-rules/pull/36) [`08003e2`](https://github.com/dfadler1984/cursor-rules/commit/08003e2a7cefdc4ebbb2864afbd01dd32b318824) Thanks [@dfadler1984](https://github.com/dfadler1984)! - feat(pr-create): add --label and --docs-only flags

  - Dry-run now includes a `labels` array when label flags are present
  - After successful PR creation, labels are added via the Issues API
  - Tests cover default/no labels, multiple labels, and `--docs-only` alias
  - ERD/tasks updated under `docs/projects/skip-changeset-opt-in`

## 0.0.5

### Patch Changes

- [#30](https://github.com/dfadler1984/cursor-rules/pull/30) [`297448b`](https://github.com/dfadler1984/cursor-rules/commit/297448bec1a807b89d1a2869cd78781aa4f61b5d) Thanks [@dfadler1984](https://github.com/dfadler1984)! - Mock checks-status tests to avoid live GitHub API/token; add generic PR
  template; update assistant git rule to require a Changeset by default.

- [#32](https://github.com/dfadler1984/cursor-rules/pull/32) [`3308166`](https://github.com/dfadler1984/cursor-rules/commit/33081661fce078f42c01ea73ff026580a85d338f) Thanks [@dfadler1984](https://github.com/dfadler1984)! - docs: archive TDD-First; add test-coverage, pr-create-script, skip-changeset-opt-in projects; dedupe TDD rules

- [#29](https://github.com/dfadler1984/cursor-rules/pull/29) [`06e0b48`](https://github.com/dfadler1984/cursor-rules/commit/06e0b48cb777a5346fe682b9209aa13ac1957c41) Thanks [@dfadler1984](https://github.com/dfadler1984)! - chore: intent-routing docs and tasks improvements; add links-check script and project ERD front matter tasks. No runtime changes.

- [#33](https://github.com/dfadler1984/cursor-rules/pull/33) [`4a884fd`](https://github.com/dfadler1984/cursor-rules/commit/4a884fd254b80f62e9e88190741dba0aea070c09) Thanks [@dfadler1984](https://github.com/dfadler1984)! - docs(rules): update assistant behavior/capabilities; update projects README

## 0.0.4

### Patch Changes

- [#25](https://github.com/dfadler1984/cursor-rules/pull/25) [`3972974`](https://github.com/dfadler1984/cursor-rules/commit/3972974de0880d754489ba8e992cb617e28bf9e1) Thanks [@dfadler1984](https://github.com/dfadler1984)! - fix: correct duplicate JSON in .changeset/config.json to unblock changesets action

## 0.0.3

### Patch Changes

- [#25](https://github.com/dfadler1984/cursor-rules/pull/25) [`3972974`](https://github.com/dfadler1984/cursor-rules/commit/3972974de0880d754489ba8e992cb617e28bf9e1) Thanks [@dfadler1984](https://github.com/dfadler1984)! - fix: correct duplicate JSON in .changeset/config.json to unblock changesets action

- [#24](https://github.com/dfadler1984/cursor-rules/pull/24) [`a129980`](https://github.com/dfadler1984/cursor-rules/commit/a129980087f2cb05edf1eb63d5c3d91ab78f556a) Thanks [@dfadler1984](https://github.com/dfadler1984)! - chore: seed initial changeset to re-enable automated changelog and version PR

## 0.0.2

### Patch Changes

- [#13](https://github.com/dfadler1984/cursor-rules/pull/13) [`fc29369`](https://github.com/dfadler1984/cursor-rules/commit/fc293690dbbe50eeaf063e0a07eafb36fd8dd9b4) Thanks [@dfadler1984](https://github.com/dfadler1984)! - chore: demo linked changelog entries with GitHub formatter

## 0.0.1

### Patch Changes

- 564cdf4: chore: retry smoke run to validate changesets action
- 9e1d5e0: docs: smoke test changeset to verify Version Packages PR and VERSION sync

All notable changes to this project will be documented in this file.
Generated via Changesets from PR-authored changesets. `VERSION` is canonical.
