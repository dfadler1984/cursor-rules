# Projects

A landing page for all projects, grouped by status.

## Active

- [ai-workflow-integration](./ai-workflow-integration/erd.md) — Unify Cursor Rules by integrating proven workflows into a coherent, configurable ruleset.
- [chat-performance-and-quality-tools](./chat-performance-and-quality-tools/erd.md) — Tools to estimate token usage/headroom and maintain effective chats.
- [rule-quality](./rule-quality/erd.md) — Consolidate, validate, and streamline the ruleset with automation and routing tests.
- [capabilities-rules](./capabilities-rules/erd.md) — Evaluate overlap between capabilities rules, encoding improvements, and delineation.
- [platform-capabilities-generic](./platform-capabilities-generic/erd.md) — Genericize Cursor-specific capabilities guidance into a vendor-agnostic rule and deprecate the old file.
- [collaboration-options](./collaboration-options/erd.md) — Collaboration surfaces with `.github/` kept config‑only; optional remote sync.
- [core-values](./core-values/erd.md) — Always‑on guardrails: Truth/Accuracy, Consistency/Transparency, Self‑Correction, Consent‑first.

- [intent-router](./intent-router/erd.md) — Central intent router with consent/TDD gates and clear routing.
- [productivity](./productivity/erd.md) — Automate repetitive ops with scripts while preserving safety and TDD‑first.
- [github-workflows-utility](./github-workflows-utility/erd.md) — Audit current GitHub Actions, assess utility, and propose/add helpful workflows.
- [role-phase-mapping](./role-phase-mapping/erd.md) — Align role guidance with phases; add phase‑readiness prompts.
- [roles](./roles/erd.md) — Define roles and intent routing with per‑role posture and examples.
- [rules-folder-structure-options](./rules-folder-structure-options/erd.md) — Determine structure options for `.cursor/rules/` and a low‑risk migration plan.
- [projects-readme-generator](./projects-readme-generator/erd.md) — Automate generation of the projects index README; consistent, idempotent output.
- [split-progress](./split-progress/erd.md) — Index of split ERDs with owners, statuses, tasks, and dependencies.
- [document-templates](./document-templates/erd.md) — Determine recurring docs and add minimal templates where beneficial.
- [long-term-solutions](./long-term-solutions/erd.md) — Replace manual workarounds with durable, test‑backed fixes (e.g., fix `.cursor/scripts/final-summary-generate.sh` instead of manual final summaries).

## Grouped projects

- [project-lifecycle-docs-hygiene](./project-lifecycle-docs-hygiene/erd.md)

  - [project-organization](./project-organization/erd.md)
  - [workflows](./workflows/erd.md)
  - [readme-structure](./readme-structure/erd.md)
  - [completion-metadata](./completion-metadata/erd.md)

- [shell-and-script-tooling](./shell-and-script-tooling/erd.md)

  - [bash-scripts](./bash-scripts/erd.md)
  - [shell-scripts](./shell-scripts/erd.md)
  - [scripts-unix-philosophy](./scripts-unix-philosophy/erd.md)
  - [script-rules](./script-rules/erd.md)
  - [script-help-generation](./script-help-generation/erd.md)
  - [script-error-handling](./script-error-handling/erd.md)
  - [script-test-hardening](./script-test-hardening/erd.md)
  - [shellcheck](./shellcheck/erd.md)
  - [networkless-scripts](./networkless-scripts/erd.md)

- [testing-coordination](./testing-coordination/erd.md)

  - [tdd-rules-refinement](./tdd-rules-refinement/erd.md)
  - [test-coverage](./test-coverage/erd.md)
  - [test-artifacts-cleanup](./test-artifacts-cleanup/erd.md)
  - [tests-github-deletion](./tests-github-deletion/erd.md)
  - [script-test-hardening](./script-test-hardening/erd.md) — related/overlap

- [git-usage-suite](./git-usage-suite/erd.md)

  - [git-usage](./git-usage/erd.md)
  - [github-workflows-utility](./github-workflows-utility/erd.md)
  - [tests-github-deletion](./tests-github-deletion/erd.md)

- [tooling-portability-migration](./tooling-portability-migration/erd.md)
  - [tooling-discovery](./tooling-discovery/erd.md)
  - [portability](./portability/erd.md)
  - [artifact-migration](./artifact-migration/erd.md)

## Completed

- [assistant-learning](_archived/2025/assistant-learning/final-summary.md) — Assistant Learning Protocol for structured reflection logs, triggers, storage, and aggregation.
- [project-lifecycle](_archived/2025/project-lifecycle/final-summary.md) — Completion via status tagging/indexing; optional archive policy and templates.
- [framework-selection](_archived/2025/framework-selection/erd.md) — Superseded; content integrated into AI Workflow Integration.
- [deterministic-outputs](_archived/2025/deterministic-outputs/erd.md) — Superseded; content integrated into AI Workflow Integration.
- [pr-template-automation](_archived/2025/pr-template-automation/final-summary.md) — Default PR template injection in script + docs.
- [tdd-first](_archived/2025/tdd-first/final-summary.md) — Enforce Red → Green → Refactor with owner specs and effects seams.
- [skip-changeset-opt-in](_archived/2025/skip-changeset-opt-in/final-summary.md) — Make skip-changeset labeling opt-in via explicit flag.
- [rule-maintenance](_archived/2025/rule-maintenance/final-summary.md) — Cadence and validator to keep rules healthy with actionable reports.
- [rules-validate-script](_archived/2025/rules-validate-script/final-summary.md) — Completed.
- [project-erd-front-matter](_archived/2025/project-erd-front-matter/final-summary.md) — Minimal ERD front matter standard and examples.
- [auto-merge-bot-changeset-version](_archived/2025/auto-merge-bot-changeset-version/final-summary.md) — Auto‑enable GitHub Auto‑merge on Changesets “Version Packages” PRs; dual triggers + manual dispatch.
- [pr-create-script](_archived/2025/pr-create-script/erd.md) — Improve PR creation: template control and body replace/append modes.
- [changelog-automation](_archived/2025/changelog-automation/final-summary.md) — Automated changelog via Changesets; version sync; bot PR flow.
- [alp-logging](_archived/2025/alp-logging/final-summary.md) — ALP logging consistency: triggers, status formats, aggregation/archival, redaction.
- [project-lifecycle-hardening](_archived/2025/project-lifecycle-hardening/final-summary.md) — Completed.
- [context-efficiency-gauge](_archived/2025/context-efficiency-gauge/erd.md) — Merged into Chat Performance and Quality Tools.

## Archived

- See `docs/projects/_archived/README.md`

## Skipped

- [mcp-synergy](_archived/2025/mcp-synergy/erd.md) — Archived without completion; scope deferred.
