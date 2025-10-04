# Tasks — Project Lifecycle Hardening (Parent Level)

## Parent Tasks

- [x] Create canonical templates under `.cursor/templates/project-lifecycle/` [P]
- [x] Update `project-lifecycle` rule to encode usage and completion policy
- [x] Implement scoped CI validator + tests under `.cursor/scripts/`
- [x] Update `docs/projects/README.md` with Active/Completed index entries
- [x] Migrate existing `project-lifecycle` experiment to use canonical templates
- [x] Define and document archival path `docs/projects/_archived/<YYYY>/<project>/`
- [x] Add retrospective/metrics requirements to closeout flow
- [x] Add guidance for finalizing PR titles to land in `CHANGELOG.md`

## Relevant Files

- `.cursor/templates/project-lifecycle/*.template.md`
- `.cursor/rules/project-lifecycle.mdc`
- `.cursor/scripts/validate-project-lifecycle.sh`
- `.cursor/scripts/validate-project-lifecycle.test.sh`
- `docs/projects/README.md`
- `docs/projects/project-lifecycle/`
- `docs/projects/_archived/`
