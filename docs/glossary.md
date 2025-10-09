# Glossary

## Owner spec

- The colocated test file that "owns" a source file's behavior (e.g., `src/foo.spec.ts` for `src/foo.ts`).
- Required by TDD‑First before editing JS/TS sources.
- See: `docs/projects/tdd-first/erd.md`.

## Acceptance bundle

- A machine‑checkable block in a Plan describing: targets, exactChange, successCriteria, constraints, runInstructions, and ownerSpecs.
- Used to connect planning → execution deterministically.
- See: `docs/projects/ai-workflow-integration/erd.md`, `docs/projects/deterministic-outputs/erd.md`.

## Projects layout

- Preferred structure to colocate artifacts per project under `projects/<slug>/` while keeping reusable guidance under `docs/`.
- Migration is staged; validators read paths from config.
- See: `docs/projects/project-organization/erd.md`.

## Intent router

- Logic that normalizes inputs into intents and applies consent/TDD gates before actions.
- See: `docs/projects/intent-router/erd.md`.

## Roles

- Output postures for Director, Manager, Engineer, Detective. Influence gating and phrasing.
- See: `docs/projects/roles/erd.md`.

## Deterministic outputs

- Contracts and validators for Spec/Plan/Tasks artifacts and their cross‑links.
- See: `docs/projects/deterministic-outputs/erd.md`.

## Learning logs (ALP)

- Structured entries written on deterministic triggers; private by default with safe fallback.
- See: `docs/projects/assistant-learning/erd.md`, `docs/projects/logging-destinations/erd.md`.

## Capabilities discovery

- Read‑only index of abilities from rules, MCP, and local scripts using a canonical schema.
- Schema owner: `docs/projects/capabilities-discovery/erd.md`.

## MCP synergy

- Safe, consent‑first usage of MCP servers with discovery by default and execution gated.
- See: `docs/projects/mcp-synergy/erd.md`.

## Script standards vs suite

- Standards: repository‑wide bash style and safety rules.
- Suite: curated helper scripts under `.cursor/scripts/` adopting the standards.
- See: `docs/projects/bash-scripts/erd.md`, `docs/projects/shell-scripts/erd.md`.
