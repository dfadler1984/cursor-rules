## Relevant Files

- `.cursor/scripts/tests/run.sh` — entry point for script tests (reference for wiring)
- `.gitignore` — ensure temp root and artifacts are ignored

- `docs/projects/testing-coordination/erd.md`

## Tasks

- [ ] 1.0 Establish temp root and ignore rules (priority: high)

  - [ ] 1.1 Create `./.tmp/` convention and document usage
  - [ ] 1.2 Add `.tmp/` and common artifacts to `.gitignore`

- [ ] 2.0 Implement cleanup script (priority: high)

  - [ ] 2.1 Add `.cursor/scripts/cleanup-test-artifacts.sh` with safe allow‑list
  - [ ] 2.2 Support `--dry-run` and `--verbose`
  - [ ] 2.3 Idempotency: repeated runs make no changes

- [ ] 3.0 Wire into local and CI flows (priority: medium)

  - [ ] 3.1 Invoke cleanup before and after local tests
  - [ ] 3.2 Add CI step to run cleanup pre/post test job

- [ ] 4.0 Validation and safeguards (priority: high)
  - [ ] 4.1 Add guard rails to prevent deletion outside allowed paths
  - [ ] 4.2 Add focused tests for cleanup resolver (TDD‑first)
  - [ ] 4.3 Document troubleshooting and dry‑run usage

### Notes

- Keep deletion scoped to the temp root and known generated paths like `coverage/`.
- Prefer `rm -rf -- one-two` style with explicit path variables; avoid unbound globs.
