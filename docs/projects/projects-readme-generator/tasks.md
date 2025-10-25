## Relevant Files

- `.cursor/scripts/generate-projects-readme.sh` — generator script
- `.cursor/scripts/generate-projects-readme.test.sh` — tests
- `docs/projects/README.md` — output
- `docs/projects/projects-readme-generator/erd.md` — ERD

### Notes

- Keep it POSIX; avoid bashisms if possible
- Dry-run first; ensure idempotent output and stable ordering

## Tasks

- [x] 1.0 Implement generator script (priority: high)

  - [x] 1.1 Walk `docs/projects/` excluding `_archived/` and `_examples/`
  - [x] 1.2 Extract title, status, owner from `erd.md` (front matter + H1)
  - [x] 1.3 Detect presence of `tasks.md`
  - [x] 1.4 Render Markdown table (Project | Status | ERD | Tasks)
  - [x] 1.5 Support flags: `--projects-dir`, `--out`, `--dry-run`

- [x] 2.0 Add tests for generator (priority: high)

  - [x] 2.1 Create fixtures with mixed presence of `erd.md`/`tasks.md`
  - [x] 2.2 Verify table rows, links, and sort order
  - [x] 2.3 Verify dry-run prints to stdout and does not write

- [x] 3.0 Wire npm script and docs (priority: medium)

  - [x] 3.1 Add `generate:projects-readme` to `package.json`
  - [x] 3.2 Add project README with usage documentation

- [x] 4.0 Optional integration (priority: low)

  - [x] 4.1 Add ERD validator to CI (`.github/workflows/erd-validate.yml`)
  - [x] 4.2 Create ERD migration script (`.cursor/scripts/erd-migrate-frontmatter.sh`)
  - [x] 4.3 Document ERD format requirements in project README
  - [x] 4.4 Add README staleness check to CI

## Completion Notes

Implementation complete with TDD approach (Red → Green → Refactor):

**Deliverables:**

- `.cursor/scripts/generate-projects-readme.sh` — Main generator (206 lines)
- `.cursor/scripts/generate-projects-readme.test.sh` — Test suite (6 tests, all passing)
- `npm run generate:projects-readme` — Convenience script
- `docs/projects/projects-readme-generator/README.md` — Documentation

**Features:**

- Scans project directories with smart exclusions (\_archived/, \_examples/)
- Extracts metadata from ERD YAML front matter (title, status) with fallbacks
- Generates sorted Markdown table with links and task indicators
- POSIX-compliant, idempotent output, zero external dependencies

**Test Coverage:**

- Help flag works
- Dry-run outputs to stdout without writing
- Project discovery and exclusions
- Table structure generation
- Fixture-based testing
- Graceful handling of missing erd.md

**CI Integration:**

- `.github/workflows/projects-readme-validate.yml` — Staleness check workflow
  - Triggers on changes to project ERDs, tasks, or the generator script
  - Compares fresh generation with current README
  - Fails CI if out of sync, provides clear remediation steps

**All tasks complete!**
