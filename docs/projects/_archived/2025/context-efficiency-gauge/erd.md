---
status: merged
owner: rules-maintainers
merged_into: docs/projects/chat-performance-and-quality-tools/erd.md#15-context-efficiency-gauge-presentation-layer
archive_date: 2025-10-11
---

# Engineering Requirements Document — Context Efficiency Gauge (Lite) — Merged

## 1. Introduction/Overview

This project has been folded into `docs/projects/chat-performance-and-quality-tools`.

Authoritative content now lives in:

- `docs/projects/chat-performance-and-quality-tools/erd.md` → section "15. Context Efficiency Gauge (Presentation Layer)"

The original overview is preserved below for reference:

Provide a lightweight, text-only gauge and decision aid that helps users judge whether their current chat context is efficient for getting work done, and when to start a new chat. Outputs are human-readable lines and ASCII banners; no graphics or external tooling required.

## 2. Goals/Objectives

- Offer a concise “Context Efficiency Gauge” line (1–5) per reply when enabled.
- Provide an ASCII “dashboard” banner and a decision-flow banner.
- Keep the solution zero-dependency and portable (plain Markdown/Text).

## 3. User Stories

- As a developer, I can quickly see if context is lean or bloated.
- As a maintainer, I can advise teammates when to open a fresh chat.
- As a user, I get a clear, text-only visual without special rendering.

## 4. Functional Requirements

1. Context Efficiency Gauge (heuristic)

   - Scale: 1–5 (1 = bloated; 5 = lean)
   - Consider signals: scope focus, number of rules attached, search breadth, clarification loops/contradictions, latency spikes.
   - Output line example: "Context Efficiency Gauge: 4/5 (lean) — narrow scope, few rules, minimal searches"

2. ASCII Dashboard (monospace-safe)
   - Provide a compact banner suitable for code-fenced rendering.
   - Example:

```text
┌───────────────────────────────┐
│ CONTEXT EFFICIENCY — DASHBOARD │
├───────────────────────────────┤
│ Gauge: [####-] 4/5 (lean)     │
└───────────────────────────────┘
```

3. Decision Flow (ASCII)
   - Rule of thumb: start a new chat when ≥2 signals are true.
   - Example (text-only):

```text
┌───────────────────────────────────────────────┐
│ SHOULD I START A NEW CHAT?                    │
├───────────────────────────────────────────────┤
│ 1) Is the task scope narrow and concrete?     │
│    - No → New chat (seed exact file + change) │
│    - Yes → 2) ≥2 clarification loops?         │
│             - Yes → New chat                  │
│             - No → 3) Broad searches/many     │
│                    rules attached?            │
│                    - Yes → New chat           │
│                    - No → 4) Latency spikes?  │
│                           - Yes → New chat    │
│                           - No → Stay here    │
└───────────────────────────────────────────────┘
```

## 5. Non-Functional Requirements

- Text-only; no external CLI/tools required.
- Privacy-preserving; no token counts or sensitive telemetry surfaced.
- Fast to scan; minimal cognitive load.

## 6. Architecture/Design

- Presentation-only: lines and ASCII blocks included in assistant replies or docs.
- Heuristics are qualitative; avoid hard dependencies on runtime metrics.
- Optional: a repository doc page may centralize examples for easy preview.

## 7. Data Model and Storage

- None. Content is generated text; examples live in Markdown.

## 8. API/Contracts

- None. Human-facing outputs only.

## 9. Integrations/Dependencies

- None. Mermaid snippet is optional and degrades to ASCII.

## 10. Edge Cases and Constraints

- Some views may not preserve box-drawing characters without a code fence.
- Mermaid may not render in all contexts; ASCII remains the canonical fallback.

## 11. Testing & Acceptance

- Acceptance:
  - Gauge line format is documented and example provided.
  - ASCII dashboard and decision-flow examples render clearly in a Markdown preview.
  - Decision rule (≥2 signals → new chat) is stated.

## 12. Rollout & Ops

- Phase 1: Add ERD and tasks; optionally link from README.
- Phase 2 (optional): Add a `docs/` page consolidating examples.

## 13. Success Metrics

- Fewer clarification loops before choosing to start a new chat.
- Increased self-service decisions using the decision-flow banner.

## 14. Open Questions

- Always-on gauge vs explicit opt-in per session?
- Threshold tweak: should 1 strong signal (e.g., persistent latency spikes) suffice?
