## Tasks — Project lifecycle & docs hygiene (Umbrella)

## Relevant Files

- `docs/projects/project-lifecycle-docs-hygiene/erd.md`

## Todo

- [x] 1.0 Create umbrella project scaffold (ERD + tasks) with references
- [ ] 2.0 Add this project to `docs/projects/README.md` under Active
- [ ] 3.0 For each source project, add a backlink to this ERD
  - [ ] 3.1 `project-organization/tasks.md` → add link to umbrella project
  - [ ] 3.2 `workflows/tasks.md` → add link to umbrella project
  - [ ] 3.3 `readme-structure/tasks.md` → add link to umbrella project
  - [ ] 3.4 `completion-metadata/tasks.md` → add link to umbrella project
- [ ] 4.0 Define cross-cutting validation checklist (README sections, lifecycle tags, completion metadata present)
- [ ] 5.0 Record adoption notes in source projects for each decision

## Validation checklist (initial)

- [ ] Root README contains agreed sections (overview, quickstart, links to docs/rules)
- [ ] Projects index lists active projects with one-line summaries
- [ ] Each project ERD includes objectives, scope, acceptance, and owners
- [ ] Each project has `tasks.md` with actionable items and backlinks (if referenced by umbrella)
- [ ] Completion metadata present where required (status tags, final summary)
- [ ] Links use descriptive anchors; no bare URLs
- [ ] `.github/` remains configuration-only; feature docs live under `docs/`
