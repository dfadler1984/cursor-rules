## Relevant Files

- `README.md` — Root readme to be restructured (outline only in this project)
- `docs/` — Evergreen guides and workflows
- `docs/projects/README.md` — Projects index (add this project)
- `.cursor/rules/` — Link targets; no duplication in README

### Notes

- Link-first policy for root README; keep deep details in `docs/`.
- Use descriptive anchors; avoid bare URLs.
- After this project, moves/edits will happen in a separate implementation PR.

## Tasks

- [ ] 1.0 Draft root README outline (priority: high)

  - [ ] 1.1 Define section order and one-line descriptions
  - [ ] 1.2 Identify key links to `docs/` and projects index

- [ ] 2.0 Inventory existing content (priority: high)

  - [ ] 2.1 Scan `README.md` for sections that should move to `docs/`
  - [ ] 2.2 Scan `docs/` and `.cursor/rules/` for canonical targets

- [ ] 3.0 Produce content map (source → destination) (priority: high)

  - [ ] 3.1 Create `content-map.md` with file list and target locations
  - [ ] 3.2 Note required anchor/link updates

- [ ] 4.0 Prepare migration plan (priority: medium)

  - [ ] 4.1 Order of moves and edits, with risk notes
  - [ ] 4.2 Define verification checklist (links render, anchors resolve)

- [ ] 5.0 Add project to projects index (priority: low)
  - [ ] 5.1 Update `docs/projects/README.md` with a one-line description and link
