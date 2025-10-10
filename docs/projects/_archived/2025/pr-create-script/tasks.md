## Tasks — ERD: PR Create Script

## Relevant Files

- `.cursor/scripts/pr-create.sh`
- `docs/projects/pr-create-script/erd.md`

## Todo

- [x] 1.0 Document replace vs append behavior and flags in ERD
- [x] 2.0 Provide README usage examples for replace (`--replace-body`) and append (`--body`/`--body-append`) including heuristic note
- [x] 3.0 Verify quote-safe handling for multiline `--body` in README examples (advise ANSI-C quoting `$'...'` when needed)
- [ ] 4.0 Optional: Add shell tests for compose behavior (dry-run payload assertions)
- [x] 5.0 Clean up `.github/pull_request_template.md` duplication (docs/config hygiene)
