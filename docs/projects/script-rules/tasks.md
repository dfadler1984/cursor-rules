## Tasks — ERD: Script Rules

## Relevant Files

- `.cursor/scripts/script-rules-validate.sh`
- `.cursor/scripts/.lib.sh`
- `docs/projects/script-rules/erd.md`
- `docs/projects/script-help-generation/erd.md`

### Notes

- Parameterize configuration at the boundary: resolve env once, pass as args.
- Help must be side-effect free and fast; exit early on invalid input.

## Todo

- [ ] 1.0 Create `.cursor/scripts/script-rules-validate.sh`

  - [ ] 1.1 Check scripts expose `-h|--help` and `--version`
  - [ ] 1.2 Verify safety prologue: `set -euo pipefail` or explicit `trap` handlers
  - [ ] 1.3 Detect direct env access in logic (allow boundary resolution only)
  - [ ] 1.4 Ensure error paths use a uniform `die` helper and exit codes are documented

- [ ] 2.0 Extend `.cursor/scripts/.lib.sh` helpers

  - [ ] 2.1 Add `die`, `require_param`, and `resolve_env_default`
  - [ ] 2.2 Provide `print_help` helpers aligning with the help schema

- [ ] 3.0 Integrate with Help Generation & Validation

  - [ ] 3.1 Reuse `help-validate.sh` to enforce help structure
  - [ ] 3.2 Link outputs under `docs/scripts/` where applicable

- [ ] 4.0 Migrate representative scripts

  - [ ] 4.1 Update 2–3 scripts to pass new validator and demonstrate parameterization
  - [ ] 4.2 Ensure `--help` runs with no side effects and under 200ms

- [ ] 5.0 Documentation

  - [ ] 5.1 Add "Script Rules" section to repository `README.md` with quickstart
  - [ ] 5.2 Cross-link from `docs/projects/README.md` and `docs/scripts/README.md`
