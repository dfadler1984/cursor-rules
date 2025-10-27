# Comparison Framework — AI Workflow Integration

## Scope

Evaluate `ai-dev-tasks`, `spec-kit`, and `claude-task-master` to inform targeted updates to our Cursor Rules without introducing external runtime dependencies.

## Evaluation Criteria

- Setup & Integration
  - How does it install/configure? Any editor/CLI coupling?
  - Slash‑commands support (agent exposure), optionality, portability, and phrase‑trigger fallback
- Artifacts & Templates
  - PRD/ERD structure and prompts; plan/tasks linkage
  - Two‑phase task flow; clarity for junior developers
  - Cross‑linking between spec/plan/tasks at file tops
- Tasks Model
  - Dependencies and priority semantics; parallelizable markers `[P]`
  - Relevant files discipline and TDD coupling
- Decision Gates & Uncertainty
  - Uncertainty markers in ERDs; `/analyze` gate before implementation
- Logging & Progress
  - Reflective logs vs runtime logging; operational metrics (elapsed, token I/O)
  - Redaction/privacy safeguards; storage locations (docs‑only)
- Acceptance & Validation
  - Clear acceptance checks; ease of spot‑checks and dry‑runs
- Licensing & Reuse
  - License compatibility; what to borrow (citations) vs re‑implement
- Configuration & Toggles
  - Opt‑in flags via `.cursor/config.json` with unchanged defaults vs unified defaults; regression risk
- Rollout & Ops Readiness
  - Phased rollout complexity; reversibility; documentation/communication needs

## Artifacts to Produce

- ERD (done)
- Proposed rule diffs (paths + short descriptions)
- Logging enhancements outline (Operation block + Dependency Impact)
- Acceptance checks outline for a demo dry‑run

## Decision Notes

Use `discussions.md` to capture concrete decisions, alternatives considered, and open questions.
