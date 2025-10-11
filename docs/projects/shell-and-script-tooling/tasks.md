## Tasks — Shell & Script Tooling (Unified)

## Relevant Files

- `docs/projects/shell-and-script-tooling/erd.md`

## Todo

- [x] 1.0 Create unified project scaffold (ERD + tasks) with references
- [x] 2.0 Add this project to `docs/projects/README.md` under Active
- [x] 3.0 For each source project, add a backlink to this ERD
  - [x] 3.1 `bash-scripts/tasks.md` → add link to unified project
  - [x] 3.2 `shell-scripts/tasks.md` → add link to unified project
  - [x] 3.3 `scripts-unix-philosophy/tasks.md` → add link to unified project
  - [x] 3.4 `script-rules/tasks.md` → add link to unified project
  - [x] 3.5 `script-help-generation/tasks.md` → add link to unified project
  - [x] 3.6 `script-error-handling/tasks.md` → add link to unified project
  - [x] 3.7 `script-test-hardening/tasks.md` → add link to unified project
  - [x] 3.8 `shellcheck/tasks.md` → add link to unified project
  - [x] 3.9 `networkless-scripts/tasks.md` → add link to unified project
- [ ] 4.0 Derive first cross-cutting decisions (help/version flags, strict mode, error semantics)
  - [ ] 4.1 Decide help/version flags minimums and section schema (align with help-generation)
  - [ ] 4.2 Decide strict-mode baseline and traps (align with error-handling)
  - [ ] 4.3 Decide error semantics and exit code catalog alignment
  - [ ] 4.4 Decide networkless effects seam defaults (align with networkless-scripts)
- [ ] 5.0 Record adoption notes in source projects for each decision
  - [ ] 5.1 Add decision backlinks to affected source `tasks.md`
  - [ ] 5.2 Track adoption status per source project
