# Tasks — Test Run Deletes `.github/` and adds `tmp-scan/`

## Investigation Checklist

- [ ] Reproduce locally using `npm run test:scripts`
- [ ] Capture before/after directory snapshot focusing on `.github/` and `tmp-scan/`
- [ ] Identify which test file triggers the change (bisect via focused runs)
- [ ] Review `.cursor/scripts/tests/run.sh` and any cleanup helpers for `rm -rf` calls
- [ ] Search for patterns like `rm -rf .github` or `tmp-scan` in scripts/tests
- [ ] Verify CWD assumptions; ensure tests run from repo root
- [ ] Check for environment variables that redirect temp paths
- [ ] Confirm no CI job or pre/post hooks are mutating `.github/`

## Remediation Tasks

- [ ] Replace unsafe deletions with guarded functions (deny-list critical paths)
- [ ] Route temp outputs to `./.tmp/` or system temp with unique prefixes
- [ ] Add regression test: running the suite does not delete `.github/`
- [ ] Document fix and safeguards in ERD notes
- [ ] Cleanup: ensure created temp dirs are removed after tests

## Repro Steps

1. Ensure a fresh clone with `.github/` present
2. Run:
   - `npm run test:scripts`
3. Observe whether `.github/` is removed and whether `tmp-scan/` appears at repo root
4. If not reproduced, expand to full test command used in CI (if different)

## Notes

- Test entry in package.json: `test:scripts` → `.cursor/scripts/tests/run.sh -v`
- Prefer focused runs with `-k <keyword>` once the suspect file is found
