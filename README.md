# Cursor Rules — Shell Scripts Suite

[![Repository Health](https://img.shields.io/badge/health-100-brightgreen)](https://github.com/dfadler1984/cursor-rules/actions/runs/18852109433)

This repository includes a suite of standalone shell scripts to assist with rules management, Git workflows, PR creation, and repo hygiene. Scripts target macOS with bash and prefer POSIX sh where feasible.

## Unified Workflow (No Configuration Required)

This repository uses a **unified workflow** integrating proven practices from ai-dev-tasks, github/spec-kit, and claude-task-master. All features are standardized — no toggles or configuration needed.

### Core Workflow: Specify → Plan → Tasks → Analyze → Implement

1. **Specify**: Create ERD with uncertainty markers and clarifications
2. **Plan**: Generate acceptance bundle with targets, exact changes, success criteria
3. **Tasks**: Two-phase generation (parents → "Go" → sub-tasks) with dependencies/priority
4. **Analyze**: Mandatory cross-check of ERD→plan→tasks coverage before implementation
5. **Implement**: TDD-first with owner specs and effects seams

### Standardized Features

- **Slash Commands** (first-class): `/specify`, `/clarify`, `/plan`, `/tasks`, `/analyze`, `/implement`
  - Phrase triggers remain as fallback
- **Task Metadata**: `dependencies`, `priority`, `[P]` markers included by default
- **Logging**: Operation blocks and Dependency Impact in all improvement logs
- **Artifacts**: Cross-linked ERD, Plan, Tasks with standard templates

### Quick References

- Commands overview: `.cursor/rules/git-slash-commands.mdc`
- Capabilities catalog: `.cursor/rules/capabilities.mdc`
- ERD creation: `.cursor/rules/create-erd.mdc`
- Tasks generation: `.cursor/rules/generate-tasks-from-erd.mdc`
- Spec-driven workflow: `.cursor/rules/spec-driven.mdc`

### Legacy Notes

- Assistant learning logs deprecated; see `docs/projects/assistant-self-improvement/legacy/`

## Setup

### Prerequisites

- Node.js 18+
- Bash 4+ or Zsh 5+
- macOS (primary), Linux (CI)

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/dfadler1984/cursor-rules.git
   cd cursor-rules
   ```

2. Install dependencies:

   ```bash
   yarn install
   ```

3. Make scripts executable (if needed):

   ```bash
   chmod +x .cursor/scripts/*.sh
   ```

### Authentication

Some scripts require authentication tokens:

- **GitHub API** (`pr-create.sh`, `pr-update.sh`, `checks-status.sh`):
  - Set `GITHUB_TOKEN` or `GH_TOKEN` environment variable
  - Fine-grained or classic tokens supported
  - Minimum scope: `repo` (classic) or `Contents: Read`, `Pull requests: Write` (fine-grained)
  - For orgs with SSO: approve token for the org

For detailed auth setup, see [`docs/workspace-security.md`](./docs/workspace-security.md)

## Available Rules

**Always Applied** (active in all chats):

- `00-assistant-laws.mdc` — AI Assistant Laws (highest-priority behavioral contract)
- `assistant-behavior.mdc` — Core behavioral guidance for AI assistant interactions
- `assistant-git-usage.mdc` — Assistant Git usage — commits, branch naming, changesets, and commit gates (tests/lint/types)
- `capabilities.mdc` — Discoverable capabilities for the repo's AI assistant
- `code-style.mdc` — Coding Standards for JS/TS
- `dependencies.mdc` — Dependency selection policy
- `direct-answers.mdc` — Direct answers — root-cause-first responses to direct questions
- `favor-tooling.mdc` — Favor tooling over manual steps; use detective mode only when signals warrant it
- `github-api-usage.mdc` — GitHub API automation (Octokit) — usage and troubleshooting
- `github-config-only.mdc` — GitHub config boundaries — keep .github/ generic (no feature-specific content)
- `global-defaults.mdc` — Global defaults — consent-first, status updates, TDD pre-edit gate, source-of-truth citations
- `intent-routing.mdc` — Always-on intent router attaching rules via phrases, keywords, and signals
- `scope-check.mdc` — Protocol for detecting vague/oversized requests; clarify/split and seek consent
- `script-execution.mdc` — Local script execution policy — prefer direct exec; ask before chmod
- `security.mdc` — Secrets handling and command execution safety rules
- `self-improve.mdc` — Pattern-based rule improvement with consent-gated proposals
- `user-intent.mdc` — User intent classification and handling strategies

**Workflow {{AVAILABLE_RULES}} Process**:

- `assistant-behavior.caps.mdc` — Capabilities for assistant behavior (consent-first, status updates, minimal prompts)
- `assistant-git-usage.caps.mdc` — Capabilities for Git workflows (commits, branches, PRs, local gates)
- `changelog.mdc` — Changelog {{AVAILABLE_RULES}} Versioning — Changesets workflow, CI behavior, and assistant usage
- `context-efficiency.mdc` — Context Efficiency Gauge — qualitative heuristics and decision aid for chat context health
- `coordinator-chat-phase2.mdc` — Coordinator chat behavior for multi-chat coordination (Phase 2 - WebSocket)
- `coordinator-chat.mdc` — Coordinator chat behavior for multi-chat coordination system
- `create-erd.caps.mdc` — Capabilities for ERD authoring (Full default, Lite optional)
- `create-erd.mdc` — Engineering Requirements Document (ERD) creation workflow and template for Cursor
- `cursor-platform-capabilities.mdc` — "[DEPRECATED] Cursor platform capabilities — see platform-capabilities.mdc"
- `deterministic-outputs.mdc` — Deterministic, structured outputs — Spec/Plan/Tasks templates, acceptance bundle, and validation rules
- `direct-answers.caps.mdc` — Capabilities for direct answers (root-cause-first format)
- `dry-run.mdc` — Respond with plan-only when message starts with "DRY RUN:"
- `five-whys.mdc` — Five Whys — root-cause-first responses and corrective rule updates
- `front-matter.mdc` — Front matter structure and usage standards for Cursor Rules
- `generate-tasks-from-erd.caps.mdc` — Capabilities for generating a task list from an ERD (two‑phase with deps/priority/[P])
- `generate-tasks-from-erd.mdc` — Generate a step-by-step, junior-friendly tasks document from an ERD
- `git-slash-commands.mdc` — Prompt templates for Git operations (user-initiated workflow guidance)
- `github-api-usage.caps.mdc` — Capabilities for GitHub API automation (PR creation via script)
- `guidance-first.mdc` — Handle guidance requests by asking questions before proposing implementation
- `imports.mdc` — Import placement and ordering for TS/JS modules
- `intent-routing.caps.mdc` — Capabilities for intent routing (signals → minimal rule attachment)
- `investigation-structure.mdc` — Investigation project documentation structure and organization standards
- `platform-capabilities.mdc` — Platform capabilities — docs as source of truth and citations (vendor-agnostic)
- `project-lifecycle.caps.mdc` — Capabilities for project lifecycle (completion checklist, summaries, status)
- `project-lifecycle.mdc` — Project lifecycle — completion policy and validation (canonical; ERDs link here)
- `refactoring.mdc` — Refactoring workflow and safeguards
- `rule-creation.mdc` — How to create and update project rules for this repo
- `rule-maintenance.mdc` — Rule maintenance cadence, validation, and conflict resolution for this repo
- `rule-quality.mdc` — Rule validation checklist and detail balance for this repo
- `shell-unix-philosophy.mdc` — Unix Philosophy enforcement for shell scripts — single responsibility, small {{AVAILABLE_RULES}} focused, composition-ready
- `spec-driven.mdc` — Spec-Driven workflow — Specify → Plan → Tasks with deterministic artifacts and TDD coupling
- `tdd-first-js.mdc` — TDD‑First — JS/TS extension (focused runs, owner mapping, diff coverage)
- `tdd-first-sh.mdc` — TDD‑First — Shell extension (focused harness, owner coupling, behavior evidence)
- `tdd-first.caps.mdc` — Capabilities for TDD-first (Three Laws; nano/micro/milli cycles; owner specs)
- `tdd-first.mdc` — TDD-First — Three Laws, R/G/R, Specific→Generic; owner specs; effects seam; logging at Red/Green
- `test-plan-template.mdc` — Standard structure template for test plans and experimental designs
- `test-quality-js.mdc` — Test Quality — JS/TS (coverage>0 or diff gates, owner coupling, sabotage checks)
- `test-quality-sh.mdc` — Test Quality — Shell (behavior evidence, focused harness, owner coupling)
- `test-quality.caps.mdc` — Capabilities for proactive attachment of test-quality guidance
- `test-quality.mdc` — Practical test-quality (language-agnostic core: owner coupling, meaningful failure, sabotage checks)
- `testing.caps.mdc` — Capabilities for proactive attachment of testing guidance
- `testing.mdc` — Testing conventions — meaningful assertions against owner modules; pointers to TDD cycles
- `worker-chat-phase2.mdc` — Worker chat behavior for multi-chat coordination (Phase 2 - WebSocket)
- `worker-chat.mdc` — Worker chat behavior for multi-chat coordination system
- `workspace-security.caps.mdc` — Capabilities for Cursor Workspace Trust and autorun prevention
- `workspace-security.mdc` — Cursor Workspace Trust and autorun prevention policy (no folder-open autoruns)

📚 **Full catalog**: See [`.cursor/rules/`](./.cursor/rules/)

## Available Scripts

### Git Workflows

- `.cursor/scripts/checks-status.sh` — checks-status
- `.cursor/scripts/git-branch-name.sh` — git-branch-name
- `.cursor/scripts/git-commit.sh` — git-commit
- `.cursor/scripts/git-context.sh` — git-context
- `.cursor/scripts/pr-changeset-sync.sh` — pr-changeset-sync
- `.cursor/scripts/pr-create-simple.sh` — pr-create-simple
- `.cursor/scripts/pr-create.sh` — pr-create
- `.cursor/scripts/pr-label.sh` — pr-label
- `.cursor/scripts/pr-labels.sh` — pr-labels
- `.cursor/scripts/pr-update.sh` — pr-update
- `.cursor/scripts/pr-validate-description.sh` — pr-validate-description

### Rules Management

- `.cursor/scripts/rules-attach-validate.sh` — rules-attach-validate
- `.cursor/scripts/rules-autofix.sh` — rules-autofix
- `.cursor/scripts/rules-list.sh` — rules-list
- `.cursor/scripts/rules-validate-format.sh` — rules-validate-format
- `.cursor/scripts/rules-validate-frontmatter.sh` — rules-validate-frontmatter
- `.cursor/scripts/rules-validate-refs.sh` — rules-validate-refs
- `.cursor/scripts/rules-validate-staleness.sh` — rules-validate-staleness
- `.cursor/scripts/rules-validate.sh` — rules-validate
- `.cursor/scripts/rules-validate.spec.sh` — rules-validate.spec

### Project Lifecycle

- `.cursor/scripts/archive-detect-complete.sh` — archive-detect-complete
- `.cursor/scripts/archive-fix-links.sh` — archive-fix-links
- `.cursor/scripts/final-summary-generate.sh` — final-summary-generate
- `.cursor/scripts/project-archive-ready.sh` — project-archive-ready
- `.cursor/scripts/project-archive-workflow.sh` — project-archive-workflow
- `.cursor/scripts/project-archive.sh` — project-archive
- `.cursor/scripts/project-complete.sh` — project-complete
- `.cursor/scripts/project-create.sh` — project-create
- `.cursor/scripts/project-docs-organize.sh` — project-docs-organize
- `.cursor/scripts/project-lifecycle-migrate.sh` — project-lifecycle-migrate
- `.cursor/scripts/project-lifecycle-validate-scoped.sh` — project-lifecycle-validate-scoped
- `.cursor/scripts/project-lifecycle-validate-sweep.sh` — project-lifecycle-validate-sweep
- `.cursor/scripts/project-lifecycle-validate.sh` — project-lifecycle-validate
- `.cursor/scripts/project-status.sh` — project-status

### Validation

- `.cursor/scripts/deep-rule-and-command-validate.sh` — deep-rule-and-command-validate
- `.cursor/scripts/erd-validate.sh` — erd-validate
- `.cursor/scripts/error-validate.sh` — error-validate
- `.cursor/scripts/help-validate.sh` — help-validate
- `.cursor/scripts/lint-workflows.sh` — lint-workflows
- `.cursor/scripts/routing-validate.sh` — routing-validate
- `.cursor/scripts/shellcheck-run.sh` — shellcheck-run
- `.cursor/scripts/test-colocation-validate.sh` — test-colocation-validate
- `.cursor/scripts/validate-artifacts-smoke.sh` — validate-artifacts-smoke
- `.cursor/scripts/validate-artifacts.sh` — validate-artifacts
- `.cursor/scripts/validate-investigation-structure.sh` — validate-investigation-structure
- `.cursor/scripts/validate-project-lifecycle.sh` — validate-project-lifecycle
- `.cursor/scripts/validate-root-readme.sh` — Validate that README.md is up-to-date with generator

### CI {{AVAILABLE_SCRIPTS}} Health

- `.cursor/scripts/compliance-dashboard.sh` — compliance-dashboard
- `.cursor/scripts/health-badge-generate.sh` — health-badge-generate
- `.cursor/scripts/security-scan.sh` — security-scan

### Utilities

- `.cursor/scripts/capabilities-sync.sh` — capabilities-sync
- `.cursor/scripts/changelog-backfill.sh` — changelog-backfill
- `.cursor/scripts/changelog-diff.sh` — changelog-diff
- `.cursor/scripts/changelog-update.sh` — changelog-update
- `.cursor/scripts/changesets-automerge-dispatch.sh` — changesets-automerge-dispatch
- `.cursor/scripts/check-branch-names.sh` — check-branch-names
- `.cursor/scripts/check-script-usage.sh` — check-script-usage
- `.cursor/scripts/check-tdd-compliance.sh` — check-tdd-compliance
- `.cursor/scripts/context-efficiency-format.sh` — context-efficiency-format
- `.cursor/scripts/context-efficiency-gauge.sh` — context-efficiency-gauge
- `.cursor/scripts/context-efficiency-score.sh` — context-efficiency-score
- `.cursor/scripts/erd-add-mode-line.sh` — erd-add-mode-line
- `.cursor/scripts/erd-fix-empty-frontmatter.sh` — erd-fix-empty-frontmatter
- `.cursor/scripts/erd-migrate-frontmatter.sh` — erd-migrate-frontmatter
- `.cursor/scripts/generate-projects-readme.sh` — generate-projects-readme
- `.cursor/scripts/generate-root-readme.sh` — Generate repository root README.md from template
- `.cursor/scripts/links-check.sh` — links-check
- `.cursor/scripts/links-fix.sh` — links-fix
- `.cursor/scripts/monitoring-finding-create.sh` — monitoring-finding-create
- `.cursor/scripts/monitoring-log-create.sh` — monitoring-log-create
- `.cursor/scripts/monitoring-migrate-legacy.sh` — monitoring-migrate-legacy
- `.cursor/scripts/monitoring-review.sh` — monitoring-review
- `.cursor/scripts/network-guard.sh` — network-guard
- `.cursor/scripts/preflight.sh` — preflight
- `.cursor/scripts/repo-health-badge.sh` — repo-health-badge
- `.cursor/scripts/setup-remote.sh` — setup-remote
- `.cursor/scripts/tdd-scope-check.sh` — tdd-scope-check
- `.cursor/scripts/template-fill.sh` — template-fill
- `.cursor/scripts/test-colocation-migrate.sh` — test-colocation-migrate
- `.cursor/scripts/tooling-inventory.sh` — tooling-inventory

📚 **Complete Inventory**: See [`docs/scripts/README.md`](./docs/scripts/README.md)

## Available Commands

[Commands section pending]

📚 **Full reference**: See [`.cursor/rules/git-slash-commands.mdc`](./.cursor/rules/git-slash-commands.mdc)

## Active Projects

- **artifact-migration** — Engineering Requirements Document — Artifact Migration System [0% complete]
- **assistant-self-testing-limits** — Engineering Requirements Document — Assistant Self-Testing Limits [100% complete]
- **blocking-tdd-enforcement** — Engineering Requirements Document — Blocking TDD Enforcement (Lite) [25% complete]
- **command-discovery-rule** — Engineering Requirements Document — Command Discovery Rule [0% complete]
- **confluence-automation** — Engineering Requirements Document — Confluence Automation [N/A complete]
- **consent-gates-monitoring** — Engineering Requirements Document — Consent Gates Monitoring [6% complete]
- **cursor-modes** — Engineering Requirements Document — Cursor Modes Integration [0% complete]
- **git-usage-suite** — Engineering Requirements Document — Git Usage Suite (Lite) [0% complete]
- **git-usage** — Engineering Requirements Document — Git Usage via MCP (Lite) [33% complete]
- **github-workflows-utility** — Engineering Requirements Document — GitHub Workflows Utility (Lite) [0% complete]
- **investigation-docs-structure** — Engineering Requirements Document — Investigation Documentation Structure [100% complete]
- **jira-automation** — Engineering Requirements Document — Jira Automation [N/A complete]
- **long-term-solutions** — Engineering Requirements Document — Long‑term Solutions (Lite) [0% complete]
- **pr-create-decomposition** — Engineering Requirements Document: PR Creation Script Decomposition [0% complete]
- **pre-commit-shell-executable** — Engineering Requirements Document — Pre-commit Shell Executable Bit (Lite) [0% complete]
- **project-auto-archive-action** — Engineering Requirements Document — Project Auto Archive Action [66% complete]
- **project-lifecycle-docs-hygiene** — Engineering Requirements Document — Project lifecycle {{ACTIVE_PROJECTS}} docs hygiene (Umbrella) [9% complete]
- **project-organization** — Engineering Requirements Document — Project Organization Defaults and Configurability [0% complete]
- **roles** — Engineering Requirements Document — Roles {{ACTIVE_PROJECTS}} Intent Routing (Lite) [14% complete]
- **root-readme-generator** — Engineering Requirements Document — Root README Generator [59% complete]
- **rules-docs-quality-detection** — Engineering Requirements Document: Rules {{ACTIVE_PROJECTS}} Documentation Quality Detection [0% complete]
- **rules-enforcement-investigation** — Engineering Requirements Document — Rules Enforcement {{ACTIVE_PROJECTS}} Effectiveness Investigation [90% complete]
- **rules-folder-structure-options** — Engineering Requirements Document — Rules Folder Structure Options (Lite) [0% complete]
- **rules-grok-alignment** — Engineering Requirements Document — Improve Rules Using Grok Conversation Insights [0% complete]
- **script-organization-by-feature** — Engineering Requirements Document: Shell Scripts Organization by Feature [0% complete]
- **script-refinement** — Engineering Requirements Document — Script Refinement (Optional Polish) [0% complete]
- **split-progress** — Engineering Requirements Document — Split Progress [42% complete]
- **tdd-scope-boundaries** — Engineering Requirements Document — TDD Scope Boundaries [57% complete]
- **test-artifacts-cleanup** — Engineering Requirements Document — Test Artifacts Cleanup on Every Run [0% complete]
- **test-coverage** — Engineering Requirements Document — Test Coverage (Lite) [0% complete]
- **testing-coordination** — Engineering Requirements Document — Testing Coordination (Unified) [33% complete]
- **tooling-discovery** — Engineering Requirements Document — Tooling Discovery [0% complete]
- **workflows** — Engineering Requirements Document — Workflows (Lite) [0% complete]

📚 **All projects**: See [`docs/projects/README.md`](./docs/projects/README.md)

## Priority Projects

No priority or blocked projects

## Tests

Run the test suite:

```bash
# All tests
yarn test

# Specific test file
yarn test path/to/test

# Watch mode
yarn test --watch

# Coverage
yarn test --coverage
```



## Documentation

- **Scripts**: [`docs/scripts/README.md`](./docs/scripts/README.md)
- **Projects**: [`docs/projects/README.md`](./docs/projects/README.md) (33 active, 46 archived)
- **Rules**: [`.cursor/rules/`](./.cursor/rules/) (63 rules)
- **Guides**: [`docs/guides/`](./docs/guides/)

## What's New

- **2025-10-26**: Phase 0 complete for root-readme-generator project
- **2025-10-25**: Added root-readme-generator project for automated README generation
- See [`CHANGELOG.md`](./CHANGELOG.md) for full history

## How to mark a project completed

1. Add front matter to the project ERD (`docs/projects/<name>/erd.md`):

   ```yaml
   ---
   status: completed
   completed: YYYY-MM-DD
   owner: <you>
   ---
   ```

2. Ensure the Project Completion Checklist is satisfied (`docs/projects/project-lifecycle/completion-checklist.template.md`).
3. Add a brief final summary using the template (`docs/projects/project-lifecycle/final-summary.template.md`).
4. Update `docs/projects/README.md`: move the project from Active to Completed. If archiving, move the project folder to `docs/projects/_archived/<YYYY>/<name>/` and update the Completed link.

## Changelog & Versioning

This repository uses [Changesets](https://github.com/changesets/changesets) for versioning:

- Add changeset: `npx changeset`
- Version bump: `npx changeset version`
- Publish: Automated via GitHub Actions after PR approval

See [`CHANGELOG.md`](./CHANGELOG.md) for the full version history.

## Workspace Security

This repository follows strict workspace trust policies:

- No folder-open autoruns (no `runOn: "folderOpen"` in tasks)
- Explicit consent for command execution
- Scripts run via explicit user action only

See [`docs/workspace-security.md`](./docs/workspace-security.md) for the full security policy.

## Contributing

Contributions welcome! Please:

1. Follow the spec-driven workflow (Specify → Plan → Tasks)
2. Use TDD approach (Red → Green → Refactor)
3. Add tests for new scripts
4. Run validation before committing:

   ```bash
   # Validate rules
   ./.cursor/scripts/rules-validate.sh

   # Run tests
   yarn test

   # Lint workflows
   ./.cursor/scripts/lint-workflows.sh
   ```

5. Create Conventional Commits:

   ```bash
   ./.cursor/scripts/git-commit.sh --type feat --description "..."
   ```

6. Open PR via script:

   ```bash
   ./.cursor/scripts/pr-create.sh --title "..." --body "..."
   ```

See [`.cursor/rules/assistant-git-usage.mdc`](./.cursor/rules/assistant-git-usage.mdc) for commit and PR guidelines.

---

**Generated**: 2025-10-28T14:12:29Z  
**Version**: 0.23.0
