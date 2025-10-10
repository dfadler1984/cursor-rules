## Relevant Files

- `.cursor/scripts/generate-projects-readme.sh` — generator script
- `.cursor/scripts/generate-projects-readme.test.sh` — tests
- `docs/projects/README.md` — output
- `docs/projects/projects-readme-generator/erd.md` — ERD

### Notes

- Keep it POSIX; avoid bashisms if possible
- Dry-run first; ensure idempotent output and stable ordering

## Tasks

- [ ] 1.0 Implement generator script (priority: high)

  - [ ] 1.1 Walk `docs/projects/` excluding `_archived/` and `_examples/`
  - [ ] 1.2 Extract title, status, owner from `erd.md` (front matter + H1)
  - [ ] 1.3 Detect presence of `tasks.md`
  - [ ] 1.4 Render Markdown table (Project | Status | ERD | Tasks)
  - [ ] 1.5 Support flags: `--projects-dir`, `--out`, `--dry-run`

- [ ] 2.0 Add tests for generator (priority: high)

  - [ ] 2.1 Create fixtures with mixed presence of `erd.md`/`tasks.md`
  - [ ] 2.2 Verify table rows, links, and sort order
  - [ ] 2.3 Verify dry-run prints to stdout and does not write

- [ ] 3.0 Wire npm script and docs (priority: medium)

  - [ ] 3.1 Add `generate:projects-readme` to `package.json`
  - [ ] 3.2 Add short usage note to `docs/projects/README.md` header

- [ ] 4.0 Optional integration (priority: low)

  - [ ] 4.1 Add lightweight validation hook in project lifecycle scripts
  - [ ] 4.2 Consider CI check to ensure README is up to date


