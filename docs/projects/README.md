# Projects

A landing page for all projects, grouped by status.

## Active

- [ai-workflow-integration](./ai-workflow-integration/erd.md) — Unify Cursor Rules by integrating proven workflows into a coherent, configurable ruleset.
- [capabilities-rules](./capabilities-rules/erd.md) — Evaluate overlap between capabilities rules, encoding improvements, and delineation.
- [platform-capabilities-generic](./platform-capabilities-generic/erd.md) — Genericize Cursor-specific capabilities guidance into a vendor-agnostic rule and deprecate the old file.
- [collaboration-options](./collaboration-options/erd.md) — Collaboration surfaces with `.github/` kept config‑only; optional remote sync.
- [core-values](./core-values/erd.md) — Always‑on guardrails: Truth/Accuracy, Consistency/Transparency, Self‑Correction, Consent‑first.
- [rules-enforcement-investigation](./rules-enforcement-investigation/erd.md) — Investigate how rules are processed and enforced; test slash commands vs intent routing for compliance.
- [routing-optimization](./routing-optimization/erd.md) — Deep dive on intent routing behavior and optimization opportunities.
- [consent-gates-refinement](./consent-gates-refinement/erd.md) — Fix consent gating and exception issues for smoother UX without compromising safety.
- [tdd-scope-boundaries](./tdd-scope-boundaries/erd.md) — Define clear TDD applicability boundaries to prevent overapplication to docs/configs.
- [project-lifecycle-coordination](./project-lifecycle-coordination/erd.md) — Improve project lifecycle adherence with simple tooling for automatic coordination.

- [slash-commands-runtime](./slash-commands-runtime/erd.md) — Runtime execution semantics for slash commands (`/plan`, `/tasks`, `/pr`) with consent gates.
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

- [script-refinement](./script-refinement/erd.md) — Optional Unix Philosophy polish (P3 priority, deferred from shell-and-script-tooling)

- [testing-coordination](./testing-coordination/erd.md)

  - [tdd-rules-refinement](./tdd-rules-refinement/erd.md)
  - [test-coverage](./test-coverage/erd.md)
  - [test-artifacts-cleanup](./test-artifacts-cleanup/erd.md)

- [git-usage-suite](./git-usage-suite/erd.md)

  - [git-usage](./git-usage/erd.md)
  - [github-workflows-utility](./github-workflows-utility/erd.md)

- [tooling-portability-migration](./tooling-portability-migration/erd.md)
  - [tooling-discovery](./tooling-discovery/erd.md)
  - [portability](./portability/erd.md)
  - [artifact-migration](./artifact-migration/erd.md)

## Completed

- [chat-performance-and-quality-tools](_archived/2025/chat-performance-and-quality-tools/final-summary.md) — Chat performance tools: Context Efficiency Gauge, 7 guides, token estimation, headroom calculation. Deliverables: `.cursor/docs/guides/chat-performance/`, `.cursor/scripts/chat-performance/`.
- [intent-router](_archived/2025/intent-router/final-summary.md) — Central intent router with consent/TDD gates and clear routing.
- [rule-quality](_archived/2025/rule-quality/final-summary.md) — Consolidate, validate, and streamline the ruleset with automation and routing tests.
- [shell-scripts](_archived/2025/shell-scripts/final-summary.md) — Shell scripts suite with portable CLI tooling.
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
- [tests-github-deletion](_archived/2025/tests-github-deletion/final-summary.md) — Test environment isolation investigation; resolved via D6 subshell isolation.
- [shell-and-script-tooling](_archived/2025/shell-and-script-tooling/final-summary.md) — Shell script infrastructure with D1-D6 standards, validators, Unix Philosophy orchestrators. Child projects: bash-scripts, script-rules, script-help-generation, script-error-handling, script-test-hardening, shellcheck, networkless-scripts, scripts-unix-philosophy (all archived 2025-10-14).

## Archived

- See `docs/projects/_archived/README.md`

## Skipped

- [mcp-synergy](_archived/2025/mcp-synergy/erd.md) — Archived without completion; scope deferred.
