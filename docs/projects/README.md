# Projects

A landing page for all projects, grouped by status.

## Active

- [readme-structure](./readme-structure/erd.md) — Determine root README structure and content destinations; produce outline and content map.
- [ai-workflow-integration](./ai-workflow-integration/erd.md) — Unify Cursor Rules by integrating proven workflows into a coherent, configurable ruleset.
- [rule-quality](./rule-quality/erd.md) — Consolidate, validate, and streamline the ruleset with automation and routing tests.
- [artifact-migration](./artifact-migration/erd.md) — Safe, repeatable artifact moves with reference rewrites and verification.
- [capabilities-rules](./capabilities-rules/erd.md) — Evaluate overlap between capabilities rules, encoding improvements, and delineation.
- [platform-capabilities-generic](./platform-capabilities-generic/erd.md) — Genericize Cursor-specific capabilities guidance into a vendor-agnostic rule and deprecate the old file.
- [collaboration-options](./collaboration-options/erd.md) — Collaboration surfaces with `.github/` kept config‑only; optional remote sync.
- [completion-metadata](./completion-metadata/erd.md) — ERD completion metadata, lifecycle, gates, and validation rules.
- [core-values](./core-values/erd.md) — Always‑on guardrails: Truth/Accuracy, Consistency/Transparency, Self‑Correction, Consent‑first.
- [context-efficiency-gauge](./context-efficiency-gauge/erd.md) — Text-only gauge and decision flow for chat context efficiency.
- [drawing-board](./drawing-board/erd.md) — Sandboxed prototyping space with safe triggers and logged outcomes.
- [git-usage](./git-usage/erd.md) — Safe, consistent Git flows with MCP‑backed ops and pre‑commit/test gates.
- [intent-router](./intent-router/erd.md) — Central intent router with consent/TDD gates and clear routing.
- [logging-destinations](./logging-destinations/erd.md) — Logging destination policy, redaction, config override, and safe fallbacks.
- [portability](./portability/erd.md) — Portable paths/config for artifacts and logs; relative paths and env expansion.
- [productivity](./productivity/erd.md) — Automate repetitive ops with scripts while preserving safety and TDD‑first.
- [workflows](./workflows/erd.md) — Investigate encoded, repeatable workflows for reliable assistant results.
- [github-workflows-utility](./github-workflows-utility/erd.md) — Audit current GitHub Actions, assess utility, and propose/add helpful workflows.
- [project-organization](./project-organization/erd.md) — Defaults/config for organizing project artifacts with presets and paths.
- [role-phase-mapping](./role-phase-mapping/erd.md) — Align role guidance with phases; add phase‑readiness prompts.
- [roles](./roles/erd.md) — Define roles and intent routing with per‑role posture and examples.
- [rules-folder-structure-options](./rules-folder-structure-options/erd.md) — Determine structure options for `.cursor/rules/` and a low‑risk migration plan.

- [projects-readme-generator](./projects-readme-generator/erd.md) — Automate generation of the projects index README; consistent, idempotent output.

- [script-rules](./script-rules/erd.md) — Best practices for scripts: robust help, predictable errors, parameterized config (no direct env reads).

- [shell-scripts](./shell-scripts/erd.md) — Portable shell scripts replacing Node helpers; standardized CLI suite.
- [shellcheck](./shellcheck/erd.md) — Adopt ShellCheck with a local runner, config, and optional CI.
- [split-progress](./split-progress/erd.md) — Index of split ERDs with owners, statuses, tasks, and dependencies.
- [test-coverage](./test-coverage/erd.md) — Pragmatic coverage policy (diff-aware gates or thresholds) complementing TDD.
- [script-test-hardening](./script-test-hardening/erd.md) — Harden script tests to avoid leaking environment variables; add token flags.

- [script-error-handling](./script-error-handling/erd.md) — Standardize strict mode, traps, exit codes, and shared helpers; add a validator and migrate core scripts.

- [script-help-generation](./script-help-generation/erd.md) — Standardize `--help`/`--version` across scripts and generate a docs catalog from help output.

- [tests-github-deletion](./tests-github-deletion/erd.md) — Investigate full test run deleting `.github/` and creating `tmp-scan/`; add safeguards and regression tests.

- [test-artifacts-cleanup](./test-artifacts-cleanup/erd.md) — Ensure every test run cleans temp artifacts via a safe, portable cleanup routine.

- [tdd-rules-refinement](./tdd-rules-refinement/erd.md) — Refine TDD triggers and gates to reduce misses and friction.

- [document-templates](./document-templates/erd.md) — Determine recurring docs and add minimal templates where beneficial.

- [long-term-solutions](./long-term-solutions/erd.md) — Replace manual workarounds with durable, test‑backed fixes (e.g., fix `.cursor/scripts/final-summary-generate.sh` instead of manual final summaries).

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

## Archived

- See `docs/projects/_archived/README.md`

## Skipped

- [mcp-synergy](_archived/2025/mcp-synergy/erd.md) — Archived without completion; scope deferred.
