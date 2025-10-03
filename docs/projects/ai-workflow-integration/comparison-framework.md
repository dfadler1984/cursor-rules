# Comparison Framework — AI Workflow Integration

## Scope

Evaluate `ai-dev-tasks`, `spec-kit`, and `claude-task-master` to inform targeted updates to our Cursor Rules without introducing external runtime dependencies.

## Evaluation Criteria

- Setup & Integration
  - How does it install/configure? Any editor/CLI coupling?
  - Slash‑commands support (agent exposure), optionality, and portability
- Artifacts & Templates
  - PRD/ERD structure and prompts; plan/tasks linkage
  - Two‑phase task flow; clarity for junior developers
- Tasks Model
  - Dependencies and priority semantics; parallelizable markers `[P]`
  - Relevant files discipline and TDD coupling
- Logging & Progress
  - Reflective logs vs runtime logging; operational metrics (elapsed, token I/O)
  - Redaction/privacy safeguards; storage locations
- Licensing & Reuse
  - License compatibility; what to borrow (citations) vs re‑implement
- Configuration & Toggles
  - Minimal, opt‑in flags; sensible defaults; no behavioral regressions

## Artifacts to Produce

- ERD (done)
- Updated `tasks.md` with sub‑tasks and dependencies/priority markers (optional)
- Proposed rule diffs (paths + short descriptions)
- Logging enhancements outline (Operation block + Dependency Impact)

## Decision Notes

Use `discussions.md` to capture concrete decisions, alternatives considered, and open questions.
