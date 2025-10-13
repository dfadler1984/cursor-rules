## Tasks — ERD: Script Help Generation

## Relevant Files

- `.cursor/scripts/help-validate.sh`
- `.cursor/scripts/help-generate.sh`
- `.cursor/scripts/.lib.sh`
- `docs/projects/script-help-generation/erd.md`
- `docs/scripts/README.md`
- `docs/scripts/*.md`

### Notes

- Generating docs should run `--help` only and must not perform external effects.
- Prefer simple, robust parsing by enforcing a consistent help format in emitters.

- Unified coordination: `docs/projects/shell-and-script-tooling/erd.md`

## Todo

- [ ] 1.0 Create `help-validate.sh` (required sections check)

  - [ ] 1.1 Detect scripts under `.cursor/scripts/*.sh` excluding `*.test.sh`
  - [ ] 1.2 For each script, run `--help` and verify sections: Name, Synopsis, Description, Options, Exit Codes
  - [ ] 1.3 If missing sections, print a concise report and exit non-zero

- [ ] 2.0 Create `help-generate.sh` (emit markdown from `--help`)

  - [ ] 2.1 Capture `--help` output and split into sections; normalize whitespace
  - [ ] 2.2 Render `docs/scripts/<script>.md` with front matter title and anchors
  - [ ] 2.3 Build `docs/scripts/README.md` index with script names and one-line summaries
  - [ ] 2.4 Support flags: `--format md|json` (default md), `--only <glob|regex>`

- [ ] 3.0 Update `.cursor/scripts/.lib.sh` helpers

  - [ ] 3.1 Add small helpers to print standardized help headers/sections
  - [ ] 3.2 Provide option formatting helper to align flags and defaults

- [ ] 4.0 Migrate representative scripts

  - [ ] 4.1 Update `pr-create.sh`, `git-branch-name.sh`, `rules-validate.sh` to emit standardized help
  - [ ] 4.2 Ensure `--help` runs fast and without side effects

- [ ] 5.0 Documentation and linkage

  - [ ] 5.1 Add a link to `docs/scripts/README.md` from repo `README.md`
  - [ ] 5.2 Include guidance: how to regenerate docs and add help to new scripts

- [ ] 6.0 Optional CI

  - [ ] 6.1 Add a lightweight CI step to run `help-validate.sh`
  - [ ] 6.2 Fail PRs when required help sections are missing

### Unified adoption checklist (from `docs/projects/shell-and-script-tooling/erd.md`)

- [x] D1 Help/Version: adopt minimum flags and section schema
- [x] D2 Strict Mode: source `.lib.sh` and call `enable_strict_mode`
- [x] D3 Error Semantics: align exit codes and `die` usage
- [x] D4 Networkless: adopt `.lib-net.sh` seam where relevant
- [x] D5 Portability: bash + git only; optional tools degrade gracefully
- [x] D6 Test Isolation: subshell isolation, no env leakage

#### Adoption status (2025-10-13)

- D1: ✅ Complete — 36/36 scripts have standardized help using `.lib.sh` template functions (print_usage, print_options, print_option, print_examples, print_exit_codes); validated by `help-validate.sh`
- D2: ✅ Complete — All scripts use strict mode
- D3: ✅ Complete — All scripts use exit code catalog
- D4: ✅ Complete — Tests use seams
- D5: ✅ Complete — Portability policy adopted
- D6: ✅ Complete — Test isolation implemented

See: `docs/projects/shell-and-script-tooling/erd.md` D1 for detailed help documentation standards and validator
