---
---

---
title: Project Organization Defaults and Configurability
slug: project-organization
status: Proposed
owner: rules-maintainers
created: 2025-10-02
tags:
  - repo-structure
  - projects
  - erd
  - docs
summary: Define sensible defaults for organizing ERDs, specs, plans, tasks, and decisions with configurable paths.
---

Mode: Full

## Overview

This ERD proposes a sensible default structure for organizing project artifacts (ERDs, specs, plans, tasks, decisions, and generated artifacts), with a simple configuration model to adapt paths and naming conventions per repository.

## Problem Statement

Our current approach uses top-level documents in `docs/` with the substring `erd-` in filenames. As more initiatives appear, discoverability and colocation degrade (related tasks/decisions drift into separate folders). We need:

- A discoverable, scalable structure where all artifacts for a project live together
- A clear separation between reusable guidance/templates versus project-specific content
- Lightweight automation and configuration to scaffold and index projects consistently

## Goals

- Define a default, coherent folder structure for projects and their artifacts
- Keep project-specific content colocated; keep reusable guidance in a global area
- Provide a minimal, repo-local configuration to override defaults without code changes
- Enable automation: simple scaffolding, indexing, and migration scripts

## Non-Goals

- Defining the full content templates in detail (we include small starting templates only)
- Building and committing automation/scripts in this ERD (tracked as follow-up tasks)
- Enforcing one true structure for every repo; this ERD specifies defaults + config

## Stakeholders

- Repository maintainers and contributors who create/consume ERDs, specs, plans, and tasks
- Automation tooling that scaffolds, indexes, or migrates project artifacts

## Proposed Default Structure

Colocate project artifacts under `projects/<project-slug>/`, and reserve `docs/` for reusable guidance, patterns, and rules.

```text
projects/
  <project-slug>/
    index.md            # front matter: owner, status, tags, created, links, summary
    erd.md              # the project ERD (this document's counterpart for that project)
    spec.md             # owner spec(s) describing desired behavior
    plan.md             # plan of execution, milestones
    tasks/
      001-<task>.md
      002-<task>.md
    decisions/          # ADRs
      adr-0001-<title>.md
    artifacts/          # generated outputs (diagrams, exports)

docs/
  patterns/             # reusable ERD/spec templates, guides
  rules/                # repository rules and standards
  references/           # cross-project references, indices
```

### Rationale

- Discoverability: everything related to a project is in one place.
- Extensibility: natural homes for `decisions/` and `artifacts/` avoid filename sprawl.
- Automation: straightforward scaffolding and indexing by folder convention.
- Configurability: simple path overrides preserve flexibility across repos.

## Configuration Model

Provide a small configuration block (default location: `.cursor/config.json`, section `structure`). Repos can also place this in another JSON file if preferred (reference path in `.cursor/config.json`).

```json
{
  "structure": {
    "preset": "projects",
    "paths": {
      "projectsRoot": "projects",
      "globalDocsRoot": "docs",
      "projectIndexFile": "index.md",
      "erdFile": "erd.md",
      "specFile": "spec.md",
      "planFile": "plan.md",
      "tasksDir": "tasks",
      "decisionsDir": "decisions",
      "artifactsDir": "artifacts",
      "patternsDir": "patterns",
      "rulesDir": "rules",
      "referencesDir": "references"
    },
    "naming": {
      "projectSlug": "kebab",
      "taskPrefix": "NNN-",
      "adrPrefix": "adr-####-"
    }
  }
}
```

Notes:

- `preset` allows future alternative structures (e.g., domain-driven variants).
- `naming` keys guide scaffolding; numbers/zero-padding enable stable ordering.

## Minimal Templates (Front Matter)

### `projects/<slug>/index.md`

```markdown
---
title: <Project Title>
slug: <project-slug>
status: Proposed
owner: <github-handle-or-team>
created: <YYYY-MM-DD>
tags: [project]
links:
  - repo: <url>
summary: <one-paragraph overview>
---
```

### `projects/<slug>/tasks/NNN-<task>.md`

```markdown
---
id: NNN-<task-slug>
status: pending
owner: <handle>
acceptance: <bullet list of verifiable outcomes>
related: [spec, plan, PRs]
---

## Context

## Steps
```

### `projects/<slug>/decisions/adr-####-<title>.md`

```markdown
---
adr: ####
status: Accepted
context: <problem and forces>
decision: <what and why>
consequences: <trade-offs>
---
```

## Alternatives Considered

1. Flat `docs/erd-*.md` files (status quo)
   - Pros: Simple, no new folders. Cons: Harder to scale; weak colocation with tasks/decisions.
2. Domain-first folders (e.g., `domain/<domain>/...`)
   - Pros: Great for large domains. Cons: Overhead for small repos; conflates domain boundaries with project lifecycle.
3. One-folder-per-phase (e.g., `erds/`, `specs/`, `plans/`)
   - Pros: Phase clarity. Cons: Splits a single project across many locations.

## Risks and Mitigations

- Risk: Fragmentation across repos using different presets
  - Mitigation: Keep the default simple, document presets, provide a migration tool.
- Risk: Overhead for tiny projects
  - Mitigation: Allow single-file projects: `projects/<slug>/index.md` only; expand as needed.

## Migration Strategy (from `docs/erd-*.md`)

1. For each existing ERD, define `<project-slug>`.
2. Create `projects/<project-slug>/` with `index.md` and move the ERD to `erd.md`.
3. If related tasks/decisions exist, move them under `tasks/` and `decisions/`.
4. Leave a backlink stub in the old `docs/erd-*.md` with a link to the new location (optional, temporary).
5. Update any indices to reference `projects/`.

### Migration Plan — Phase 2 (Adopt `projects/<slug>/` with backwards-compatible links)

Scope:

- New initiatives MUST start in `projects/<slug>/`.
- Existing `docs/erd-*.md` remain read-only reference until migrated; add link stubs.

Plan:

1. Validators and tools read paths from `.cursor/config.json` (`structure.paths.*`), supporting both legacy and projects layouts during the transition.
2. Indexing (`docs/projects/split-progress/erd.md`) lists both legacy ERDs and projects, preferring projects when both exist.
3. For each legacy ERD:
   - Create `projects/<slug>/` (see Proposed Default Structure) and move content to `erd.md`.
   - Move related artifacts (`spec.md`, `plan.md`, `tasks/`, `decisions/`) when present; otherwise create placeholders.
   - In the legacy `docs/erd-*.md`, replace the body with a short stub linking to the new canonical location.
   - Optionally, apply lifecycle metadata (see `docs/projects/completion-metadata/erd.md`) to mark the legacy ERD as `Superseded` with `superseded_by` pointing to the project ERD id.
4. Automation (optional, future): add a scaffolding/migrate script to reduce manual work; ensure dry-run preview.

Safeguards:

- Do not delete legacy files until indices and links are updated and validated.
- Keep relative links; avoid absolute paths. Respect `structure.paths` overrides.
- Run validators after each migration to catch broken links or missing sections.

Success Criteria:

- New work appears only under `projects/<slug>/`.
- Indices and validators prefer projects locations and remain green.
- Legacy ERDs clearly link to their canonical project pages or are superseded via metadata.

## Acceptance Criteria

- New projects can be scaffolded into `projects/<slug>/` with `index.md`, `erd.md`, `spec.md`, `plan.md`, and empty `tasks/`, `decisions/`, `artifacts/`.
- Configuration keys in `.cursor/config.json` (or equivalent) control the actual paths; changing `projectsRoot` or filenames is reflected by automation.
- A simple index (manual or generated) lists all project slugs and their statuses.
- Migration of at least one existing ERD from `docs/erd-*.md` to `projects/<slug>/erd.md` is demonstrated with links updated.

## Open Questions

- Should project tasks remain Markdown or adopt a lightweight YAML+Markdown hybrid for better tooling?
- Do we want multiple specs per project (`specs/` directory) or keep a single `spec.md` until complexity warrants a split?
- Where should cross-project dependency/relationship maps live (`docs/references/` vs per-project `artifacts/`)?

## Next Steps (Suggested Tasks)

- Define the configuration keys in `.cursor/config.json` under `structure`.
- Add minimal scaffolding scripts: `scripts/create-project.sh`, `scripts/new-task.sh`, `scripts/new-adr.sh`.
- Migrate one representative ERD to validate the structure and update indices.
