---
---

# Engineering Requirements Document — Improve Rules Using Grok Conversation Insights

> Archived/Reference-only. This ERD has been split; see `docs/projects/split-progress/erd.md`. Last updated: 2025-10-02.

> Note: This source ERD has been split into focused ERDs. See `docs/projects/split-progress/erd.md` for the complete list and current statuses.

Mode: Lite

Scope note: This Lite ERD focuses on rule definitions and documentation. Implementation/scaffolding is out of scope unless explicitly requested with consent.

## 1. Introduction/Overview

Use prior conversation insights (where available) to improve this repository’s existing rules. Focus on implementing missing primitives (roles, capabilities discovery, MCP execution, portability) and strengthening deterministic outputs while preserving current guardrails (Truth/Accuracy, Consistency, Self‑Correction, Consent‑first, TDD‑first).

## 2. Goals/Objectives

- Roles: Define role modes (Director, Manager, Engineer, Detective) with triggers and output postures.
- Capabilities discovery: Provide a deterministic, discoverable index of abilities from repo rules, MCP servers, and local scripts.
- Deterministic artifacts: Specify canonical file names/sections for specs, plans, and tasks.
- Terminology alignment: Prefer local rule names (Spec‑Driven, Generate Tasks from ERD) over external names.
- Collaboration options: Defer remote sync; local repo remains the source of truth.
- Preserve guardrails: Keep First/Second/Third Law, consent‑first behavior, and TDD‑first gates intact.

## Decisions

- Adopt GitHub’s official MCP server over Octokit for GitHub integration.
  - Rationale: Improve reliability and agentic fit; reduce custom maintenance.
  - Evidence: Prior conversation decisions (internal).
  - Migration notes:
    - Scope: Prefer MCP for read operations first (issues, PRs, metadata); keep Octokit code paths as fallback until parity is confirmed.
    - Risks: Auth/SSO approval required; rate limits and server availability can vary across orgs.
    - Mitigations: Detect 401/403/429 and print next steps; provide a dry-run preview before execution; degrade to read-only discovery when execution is disabled.
    - Rollback: If MCP is unavailable, continue using Octokit adapters while logging an adoption warning (no user secrets in logs).
  - Capability notes: Write operations (e.g., create/update/merge PRs) are "when supported" by the configured MCP server; default posture is read-only. For mutations, use Octokit fallback paths until MCP parity is verified.
  - Consent/Safety notes: Any MCP execution requires explicit, in-session consent for the specific action; provide a dry-run preview on request.

## 3. Functional Requirements

Evidence: Derived from prior conversation requirements (internal).

### Inline requirements and acceptance

- TDD-first with colocated specs

  - Acceptance:
    - Add/update a failing owner spec before any JS/TS edit (`foo.ts` ↔ `foo.spec.ts`).
    - Minimal implementation makes the failing test pass; then refactor while green.
    - CI blocks merges on failing tests; coverage > 0 (or configured threshold).
  - Evidence: Internal notes

- Explicit consent and minimal prompting

  - Acceptance:
    - No edits/commands without explicit consent; composite consent applies to the immediate next step only.
    - “DRY RUN:” yields plan-only, no tools or edits.
    - One clarifying question when scope/targets are ambiguous.
  - Evidence: Internal notes

- Spec-driven phased workflow (Specify → Plan → Tasks → Implement)

  - Acceptance:
    - /specify produces `docs/specs/<feature>-spec.md` (what/why; optional Mermaid diagram).
    - /plan produces `docs/plans/<feature>-plan.md` + acceptance bundle.
    - /tasks creates `tasks/tasks-<feature>.md`; TDD is gated by planned tasks.
  - Evidence: Internal notes

- Deterministic, structured outputs

  - Acceptance:
    - Artifacts exist and are cross-linked: `spec.md`, `plan.md`, `tasks-*.md`.
    - Stable, repeatable Markdown (no extraneous prose outside required sections).
  - Evidence: Internal notes

- Role emulation for guidance (Director/Manager/Engineer/Detective)

  - Acceptance:
    - Prompts can select a role; outputs adapt (ideation vs planning vs TDD vs investigation).
    - Default to the user’s context if no role is given; provide a one-line status update per step.
  - Evidence: Internal notes

- MCP integrations for planning/execution (local-first fallback)

  - Acceptance:
    - GitHub MCP: Conventional Commits for commits/PRs; read-only default during testing.
    - Optional Jira/Figma/Confluence when configured; degrade gracefully if unavailable.
  - Evidence: Internal notes

- Multi-project portability (globals + per-project overrides)

  - Acceptance:
    - Global defaults in config; repo-level overrides apply without code changes.
    - Paths respect `artifacts.*Dir`; absolute paths rejected with guidance.
  - Evidence: Internal notes

- Self-reflection logging and proactive rule optimization
  - Acceptance:
    - Write learning logs to `docs/assistant-learning-logs/*.md` on key outcomes/corrections.
    - Propose rule refinements when patterns of failures/reworks recur.
  - Evidence: `docs/grok-descriptions/conversation-extraction/merged/88118950-e798-4e3c-ab79-1050e593dede/requirements.md`

### Traceability

- Decision → internal prior decisions
- TDD-first → internal prior requirements
- Explicit consent → internal prior requirements
- Spec-driven workflow → internal prior requirements
- Deterministic outputs → internal prior requirements
- Role emulation → internal prior requirements
- MCP integrations → internal prior requirements
- Portability → internal prior requirements
- Self-reflection logging → internal prior requirements

### Cross-conversation consensus

- Confirmed across conversations `88118950-e798-4e3c-ab79-1050e593dede`, `bed486d5-1a87-4761-9767-e7ec9d362d7c`, and `f183855e-64ae-4257-b546-4069cf18a236`:

  - TDD-first with colocated specs
  - Explicit consent and minimal prompting
  - Spec-driven phased workflow (Specify → Plan → Tasks → Implement)
  - Deterministic, structured outputs
  - Role emulation (Director/Manager/Engineer/Detective)
  - MCP integrations with local-first fallback
  - Multi-project portability (globals + overrides)
  - Self-reflection logging and proactive optimization

- Additional evidence: internal notes

- Decisions:
  - No additional decisions identified in the other conversations; current MCP decision remains authoritative.

1. roles.mdc

- Define roles: Director, Manager, Engineer, Detective.
- Triggers: Phrase‑based routing (e.g., “create ERD”, “plan tasks”, “implement”, “debug”), with a single clarifying question on ambiguity.
- Posture: Per‑role verbosity, consent style, and safety emphasis.
- Transitions: Clear rules to switch roles on new signals; default to Engineer when uncertain.
- Examples: Include 1–2 prompt→role examples for each role.

  - Examples:
    - Director
      - Input: "Create an ERD for checkout flow"
      - Output posture: Ask 1 clarifying question; produce `docs/specs/checkout-flow-spec.md` skeleton in output only; do not write files without explicit consent
    - Manager
      - Input: "Plan tasks for checkout flow"
      - Output posture: Sequence steps with an acceptance bundle; show `tasks/tasks-checkout-flow.md` content in output; do not write files without explicit consent
    - Engineer
      - Input: "Implement price rounding in cart"
      - Output posture: TDD gate first (owner spec path + failing assertion), then minimal implementation plan
    - Detective
      - Input: "Why is the build failing on CI?"
      - Output posture: Summarize failure, cite evidence path(s), propose smallest next diagnostic step

2. capabilities.mdc §Discovery (listing-only; distinct from roles)

- Trigger: "@capabilities", "What can you do?"; purpose is onboarding/awareness, not execution.
- Clarify: Ask scope first (planning, coding, MCP?) and current role if unknown.
- List (grouped output):
  - Rules: Scan `.cursor/rules/*.mdc` for named behaviors (e.g., Spec‑Driven: create ERD; TDD‑First: write failing tests first).
  - MCP: Query active servers for available tools/resources; show name and 1‑line purpose; warn if unauthenticated.
- Local: Scan `.cursor/scripts/**/*.sh` top comments (e.g., `# Description:`) and tag as manual.
- Advise: Tailor a short “next best step” to the active role (e.g., Director → lead Specify; Engineer → TDD gate).
- Reflect: Log the query context (timestamp, scope, gaps) and propose capability candidates when gaps are detected.
- Output format: Deterministic bullets with source labels; no execution or secrets; degrade gracefully when MCP unavailable.
- Output schema (per item): `{ name, source: 'rules'|'mcp'|'local', summary, authRequired: boolean, enabled: boolean, notes? }`. Cap list to a reasonable length (e.g., max 50) with "N more…" indicator.
- Safety: Discovery is allowed even when MCP execution is disabled; never print tokens/headers or secret-like values.
- Caching: Optional short‑lived cache; recompute on explicit request.

3. deterministic-outputs.mdc (or additions to front‑matter/spec‑driven)

- Artifacts and locations:
  - Specs: `docs/specs/<feature>-spec.md` with sections: Overview, Goals, Functional Requirements, Acceptance Criteria.
  - Plans: `docs/plans/<feature>-plan.md` with steps and an acceptance bundle.
  - Tasks: `tasks/tasks-<feature>.md` with one active sub‑task at a time.
- Contracts: Minimum required headings; sibling cross‑links; note originating rule names.

- Templates and conventions:

  - Spec required headings: `# Title`, `## Overview`, `## Goals`, `## Functional Requirements`, `## Acceptance Criteria`, `## Risks/Edge Cases`
  - Plan required headings: `# Title`, `## Steps`, `## Acceptance Bundle`, `## Risks`
  - Tasks file: top-level "Relevant Files" list and a single active sub-task policy
  - Filenames use kebab-case; `<feature>` must match across spec/plan/tasks
  - Cross-links: each artifact links to its siblings at the top
  - No freeform mode when an artifact is requested: respond only with the specified file format unless the user opts out
  - Include an `## Assumptions/Unknowns` subsection to qualify uncertainty and capture follow-ups
  - Enforce house style: adhere to `markdown_spec` and `citing_code` for code refs vs code blocks

```markdown
# <feature> Spec

## Overview

## Goals

## Functional Requirements

## Acceptance Criteria

## Risks/Edge Cases

[Links: Plan | Tasks]
```

```markdown
# <feature> Plan

## Steps

## Acceptance Bundle

## Risks

[Links: Spec | Tasks]
```

```markdown
# Tasks — <feature>

## Relevant Files

- `docs/specs/<feature>-spec.md`
- `docs/plans/<feature>-plan.md`

## Todo

- [ ] First actionable sub-task (only one active)
```

- Acceptance bundle schema (minimum):

  - targets: list of file paths/components
  - exactChange: one-sentence imperative description
  - successCriteria: measurable checks (e.g., test passes, output text)
  - constraints: optional perf/compat notes
  - runInstructions: command(s) to verify
  - For JS/TS changes, include owner spec path(s) per TDD-first (pre-edit gate)

```json
{
  "targets": ["src/parse.ts", "src/parse.spec.ts"],
  "exactChange": "Validate CSV-only globs in parse.ts",
  "successCriteria": ["Spec 'rejects bracketed globs' passes"],
  "constraints": ["No new dependencies"],
  "runInstructions": [
    "yarn test src/parse.spec.ts -t 'rejects bracketed globs'"
  ],
  "ownerSpecs": ["src/parse.spec.ts"]
}
```

- Validation rules:
  - Reject artifacts missing required headings
  - Ensure cross-links resolve to existing sibling paths
  - Verify kebab-case filename consistency across the trio
  - Imports harmony: any helper/templates referenced by `imports.mdc` are governed by these contracts and must not diverge
  - JS/TS code tasks must include owner spec path(s) in acceptance bundles; the validator checks presence and alignment

4. intent naming alignment

- Replace external framework names with local terms:
  - Spec‑Driven Development (spec‑driven)
  - Generate Tasks from ERD (generate‑tasks‑from‑erd)
- Add a brief mapping note in guidance‑first to keep terminology consistent.

5. spec-driven.mdc (automated planning and progress awareness)

- Triggers: "create ERD", "break down", "plan tasks", "generate plan", mentions of "acceptance bundle" or "steps"
  - Trigger precedence: Slash commands (`/specify`, `/plan`, `/tasks`) take precedence over phrase triggers when both are present. On ambiguity, ask one clarifying question.
  - Invocation: Users type slash commands directly in the Cursor chat. Outputs follow the deterministic artifact templates; operations that create files are guarded by consent.
- Phases:
  - Specify: capture requirements and risks (ERD/spec)
  - Plan: produce a sequenced plan with an acceptance bundle
  - Tasks: drive execution with a single active sub-task policy and status updates
- Deliverables:
  - ERD/spec at `docs/specs/<feature>-spec.md`
  - Plan at `docs/plans/<feature>-plan.md`
  - Tasks at `tasks/tasks-<feature>.md`
- Progress rules:
  - Only one sub-task active at a time; check off immediately upon completion
  - Status updates summarize what changed, what’s next, and any blockers
- MCP progress sync (optional):
  - When enabled, surface summaries of open tasks/tickets from configured MCP servers in status updates and plan context
- Phase checks:
  - At each phase boundary, ask a brief readiness confirmation (e.g., “Proceed to Plan?”) unless the user’s command is explicit
- Scaffolding:
  - `/start-project` scaffolds the required directories using configured `artifacts.*Dir` values from portability
- TDD coupling:
  - Any code-changing step must create/update the owner spec first (Red), then implement (Green), then refactor while staying Green
  - JS/TS changes must include the owner spec path(s) in the acceptance bundle
- Role mapping:
  - Director → Specify; Manager → Plan/Review; Engineer → Implement/Tasks; Detective → Investigate blockers
- Consent/clarity gates:
  - Ask one targeted clarifying question when targets/acceptance are ambiguous
  - Proceed without extra confirmation when the user issues explicit action verbs (implement/add/fix/refactor/update)
- Integrations:
  - Reference `generate-tasks-from-erd.mdc` for breakdown
  - Reference `guidance-first.mdc` for clarify-first posture in Specify/Plan

6. tdd-first.mdc (support test-driven development)

- Triggers: any request to implement/add/fix/refactor/update code; any mention of tests/specs/assertions
- Pre-edit gate:
  - Red: add or update a failing/meaningful owner spec colocated with the source file
  - Green: implement the minimal change to pass
  - Refactor: clean up while keeping tests green
- Effects seam:
  - Isolate IO/env/time/random behind injected dependencies; test pure resolvers first
- Colocation and naming:
  - Owner spec path: same folder as source, `<file>.spec.ts` (or .tsx/.js/.jsx)
  - Behavior-focused titles; avoid brittle implementation details
- JS/TS hard gate:
  - For any edit under `**/*.{ts,tsx,js,jsx}` (excluding node_modules/dist/build/web/dist), require listing the owner spec path(s) before implementation
- Integration with planning:

  - Acceptance bundles for code tasks must include owner spec paths and a one-line failing assertion description

- Configuration and multi-project patterns:

  - `tdd.ownerSpecPattern`: default `<file>.spec.(ts|tsx|js|jsx)`; overrideable per project
  - `tdd.effectsSeamRequired`: default `true`; when enabled, enforce injection seams for IO/env/time/random
  - `testing.coverage.minThreshold`: optional numeric; when set, surface coverage results and enforce threshold in acceptance checks
  - Colocation is default; allow explicit overrides for frameworks while preserving owner mapping

- Integration with testing quality:
  - Reference `testing.mdc` (consolidated structure, naming, and quality) for guidance
  - Property-based tests (QuickCheck-style) are optional for edge-case exploration where valuable

7. logging protocol reinforcement

- Logs are for reflection/learning and post‑mortems only; never used to argue or bias decisions.
- Keep current single‑entry Markdown format and configurable directory.

  - Fallback directory: If `logDir` is not writable, write logs to `docs/assistant-learning-logs/` and surface a single warning.

  - Sample entry (redacted):
    - Filename: `assistant-logs/log-2025-10-01T17-03-00Z-law-correction.md`
    - Body:
      ```markdown
      Timestamp: 2025-10-01T17:03:00Z
      Outcome: Law correction applied
      What Worked: Clarified absolute path policy
      Improvements: Add good/bad examples
      Proposed Rule Changes: Update portability.mdc examples
      ```

8. core-values.mdc (instill core values)

- Triggers and guardrails:
  - Always-on overlay: Truth/Accuracy, Consistency/Transparency, Self-Correction/Accountability
  - Pause on likely contradictions; prefer a single clarifying question over risky action
- Verification and uncertainty:
  - Verify key claims with available tools; state assumptions; qualify uncertainty explicitly
  - Default to reversible steps when confidence is low
- Consent-first protocol:
  - Do not create/edit files, run commands, or change todos without explicit user direction
  - Composite consent-after-plan allowed for immediate next step only
- Self-correction protocol:
  - Acknowledge → state what was wrong → provide the correction → note impact; propose smallest corrective step
- Through-inaction safeguards:
  - If a likely error or unsafe path is visible, flag it and propose a safer alternative
- Logging tie-in:
  - On corrections or ethics-related blocks, write a reflection entry (redacted) per logging protocol

9. productivity.mdc (maximize productivity)

- Triggers: requests to streamline, speed up, or reduce friction; repeated operational steps
- Principles:
  - Minimal prompting: ask one targeted question when needed; otherwise act
  - Automate grunt work: prefer scripts/tools over manual repetition
  - TDD-first reduces rework; small, incremental changes
- Integrations:
  - Git usage automation (conventional commits, branch naming, PR creation) with safe defaults
  - Spec-driven planning to avoid rework; deterministic outputs for reuse
  - MCP for external operations when enabled
- Safeguards:
  - Never trade correctness for speed; respect core values and consent-first
  - Surface high-signal summaries; keep optional details collapsible or linked

10. rule-maintenance.mdc

- Cadence: Define a review schedule (e.g., monthly) to scan for contradictions/outdated content
- Health metrics: Maintain multi-dimensional `healthScore` (content, usability, maintenance) with thresholds for action
- Validation: Provide a light validator spec (required front-matter fields, date formats, cross-reference checks)
  - Validator CLI: `node scripts/rules/validate-rules.ts --fix=false` should print a JSON summary with counts and exit non-zero when any count > 0. A `--fix=true` mode may autofix formatting-only issues without changing semantics.
- DRY references: Require delegating shared logic to core rules; discourage duplication
- Aggregation: Use learning logs to propose rule-change candidates; include owner rule and evidence links
- Ownership: Track owner/maintainer per rule and escalate stale rules in reports

- Maintenance flow (`/review-rules`):

  - Scope: check front matter presence/validity, detect contradictions/duplication, flag stale `lastReviewed`
  - Output: write a report to `docs/reviews/review-<ISO8601>.md` with counts and actionable next steps
  - Cadence: configurable (e.g., monthly); allow ad-hoc runs on demand

- Validator outputs (minimum):
  - Counts for: missing required fields, invalid dates, unresolved references
  - Exit status non-zero when any count > 0; summary printed with category counts

11. mcp-synergy.mdc

- Triggers: Define when to invoke MCP-backed tools (e.g., data fetch during Specify/Plan, repo ops) with explicit consent.
- Safety: Redact secrets; never echo headers like Authorization; warn and degrade gracefully if auth/config is missing.
- Execution boundary: Keep MCP calls at effect boundaries; link to Capabilities rule §Discovery for listing, while this rule governs execution.
- Portability: Endpoints and servers configured in `.cursor/config.json`; no hard-coded URLs.

- Networking and execution policy:
  - Default deny: no outbound calls without explicit user consent in-session for the specific action
  - Rate limits and failures: detect 401/403/422; print next steps; backoff on 429
  - Dry mode: provide a “show request” preview before execution when requested
  - Auditing: record a minimal execution note to `logDir` (timestamp, server, tool, status) without secrets
  - Scopes: allow per-server enable/disable via `mcp.servers`; discovery allowed even if execution is disabled

12. portability.mdc

- Globals vs overrides: Establish global defaults with per-project overrides via `.cursor/config.json`.
- Paths: Prefer relative paths and env-var expansion; avoid absolute references.
- Source of truth: Local repo rules are canonical.
- Integration: Reference `front-matter.mdc` for metadata knobs and cross-rule references to avoid duplication.

- Configuration keys (documented defaults):

  - `logDir`: `./assistant-logs/`
  - `artifacts.specsDir`: `docs/specs`
  - `artifacts.plansDir`: `docs/plans`
  - `artifacts.tasksDir`: `tasks`
  - `mcp.servers`: array of server identifiers enabled for execution; if absent, discovery is allowed but execution is gated with a warning
  - `capabilities.sources`: `{ rules: true, mcp: true, local: true }`

- Path policy:

  - All configured paths are relative to the repository root
  - Support `${ENV_VAR}` expansion when present
  - Reject absolute paths and print actionable guidance
  - Clarification: This applies to configuration values only. Command invocations and tool arguments may use absolute paths.

  - Examples:
    - Good:
      - `"tasksDir": "tasks"`
      - `"plansDir": "${PLANS_DIR:-docs/plans}"`
    - Bad:
      - `"tasksDir": "/abs/path/to/tasks"`
  - Error example: "Absolute path rejected in config key 'artifacts.tasksDir'. Use a repo-relative path like 'tasks/'."

- Fallbacks:

  - When target directories are missing, create them on write or print explicit next steps; read-only listing operations never fail hard
  - If environment variables referenced in paths are missing, fall back to defaults and warn

- OS/Environment notes:

  - Target macOS by default; avoid embedding OS-specific paths or shell-dependent assumptions in rule outputs

- Cross-rule integration:

  - Deterministic outputs respect `artifacts.*Dir`
  - Logging protocol writes to `logDir`
  - Capabilities discovery respects `capabilities.sources` and lists MCP per `mcp.servers` availability

- Example config (non-binding):

```json
{
  "logDir": "./assistant-logs/",
  "artifacts": {
    "specsDir": "docs/specs",
    "plansDir": "docs/plans",
    "tasksDir": "tasks"
  },
  "mcp": { "servers": ["github", "atlassian"] },
  "capabilities": { "sources": { "rules": true, "mcp": true, "local": true } }
}
```

## 4. Acceptance Criteria

- New rule files drafted with front matter and references:

  - `.cursor/rules/roles.mdc`

  - `.cursor/rules/deterministic-outputs.mdc` (or integrated updates to front‑matter/spec‑driven)
  - `.cursor/rules/collaboration-options.mdc` (optional)
  - `.cursor/rules/mcp-synergy.mdc`
  - `.cursor/rules/portability.mdc`

- Guidance/intent rules reference the above and remove external naming.
- Deterministic artifact contracts documented; example paths validated.
- Validation passes (no missing references); repository conventions unchanged.
- Naming alignment: Use `roles.mdc` (not `capabilities.mdc`) for role behaviors; fold any `imports`-style output template details into `deterministic-outputs.mdc`.

- Portability checks:

  - Changing `artifacts.*Dir` updates the write locations for new ERD/spec/plan/tasks artifacts
  - With no `mcp.servers` configured, capabilities discovery lists MCP tools with a warning; MCP execution rules degrade gracefully
  - Overriding `logDir` causes new reflection logs to be written under the configured directory
  - Absolute paths in config are rejected; `${ENV_VAR}` path segments expand when defined, otherwise defaults are used with a warning
  - Smoke test across two repositories (defaults vs overrides) yields identical behaviors with paths adjusted per configuration

- MCP checks:

  - Without explicit consent, execution requests are not sent; dry preview shows request details
  - With missing/invalid auth, the assistant prints guidance and does not send the request
  - When rate-limited (429), the assistant backs off and surfaces retry guidance
  - Audit notes are written to `logDir` without any sensitive headers or tokens

- Maintenance checks:

  - A monthly review run produces a report of outdated rules or contradictions
  - Rules missing required front matter or invalid dates are flagged by the validator
  - Learning-log aggregation emits a list of proposed rule changes with links to source entries
  - Rules with `healthScore` below threshold are marked for owner follow-up

- Deterministic outputs checks:

  - New specs/plans/tasks include required headings and cross-links to siblings
  - Filenames use matching `<feature>` in kebab-case across all three artifacts
  - Acceptance bundle includes targets, exactChange, successCriteria, and runInstructions

- Planning checks:

  - A planning request produces all three artifacts with required headings and cross-links
  - Exactly one active sub-task is marked at any time; status updates accompany changes
  - Code-changing tasks include owner spec/test paths and follow Red→Green→Refactor

- TDD checks:

  - For JS/TS edits, the owner spec is added/updated first and fails before implementation
  - The minimal implementation passes the failing test, followed by refactor while keeping green
  - Effects are isolated behind seams; tests cover pure resolvers
  - When `testing.coverage.minThreshold` is set, acceptance requires the threshold be met in the relevant scope
  - Phase boundaries include confirmatory prompts unless explicit commands are given

- Core values checks:

  - On detected contradictions, the assistant pauses and asks one clarifying question before acting
  - When confidence is low, the assistant proposes a reversible step and states assumptions
  - Corrections follow the self-correction protocol and generate a redacted reflection entry in `logDir`

- Productivity checks:
  - Repeated operational steps are proposed as automations (scripts or rule-driven)
  - Status updates are concise and high-signal, with optional deeper details when helpful
  - Git operations follow conventional commits and safe defaults when invoked

## Quality Gates

- Lint, type-check, and tests must pass before commit/push (CI-enforced).
- Conventional Commits are required for all commits and PR titles.
- Lockfile policy: when `package.json` changes, update and commit the lockfile in the same PR.
- Read-only defaults for MCP during testing; mutations require explicit consent.
- Coverage floor > 0 by default; configurable higher threshold via `testing.coverage.minThreshold`.

  - Enforcement status:
    - Hooks/CI: Policy currently documented; enforcement wiring may vary by repo. If present, see `.github/workflows/ci.yml` and `.cursor/scripts/git-*.sh`.
    - Guidance: Treat as policy unless enforcement hooks are detected; prefer reversible steps when uncertain.

## 5. Risks/Edge Cases

- Ambiguous role triggers; mitigate with one clarifying question default.
- MCP availability drift; warn and degrade gracefully during discovery.
- Over‑constraining artifacts; keep section requirements minimal.

## 6. Rollout Note

- Flag: rules-improvements-from-grok
- Owner: rules-maintainers
- Target: 2025‑10‑08
- Comms: Update `README.md` with links to new rules and artifact contracts.

## 7. Testing

- Roles: Dry‑run prompt examples to verify trigger→role mapping and posture.
- Discovery: Run capabilities discovery in a repo with/without MCP auth to confirm safety and grouping.
- Artifacts: Create a minimal sample spec/plan/tasks and confirm required headings and cross‑links.
- Validation: Ensure existing validation scripts (if present) succeed after additions.

  - Minimal run example:
    - Focused Jest: `yarn test src/parse.spec.ts -t "rejects bracketed globs"`
    - ESLint (print config): `npx eslint --print-config src/parse.ts | cat`
    - Note: Paths are illustrative placeholders; adjust to the target repo structure.

---

### Open Questions / Incoming Data Hooks (to be refined with new docs)

- Role nuances: Any additional roles or custom postures needed?
- Capabilities sources: Specific MCP servers/tools to prioritize?
- Artifact variants: Additional required sections for certain feature types?
- Collaboration: Preferred remote sync provider(s) and enablement criteria?
- Coverage target: agree a threshold beyond >0 (e.g., 60–80%).
