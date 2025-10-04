## Relevant Files

- `.github/pull_request_template.md` — Default template
- `.github/PULL_REQUEST_TEMPLATE/*` — Optional alternative templates
- `.cursor/rules/github-api-usage.caps.mdc` — Script usage rules (to update)
- `.cursor/scripts/pr-create.sh` — PR creation helper (to update)

## Tasks

- [x] 1.0 Update rules: require template injection by default (priority: high)

  - [x] 1.1 Add default/template flags doc to `github-api-usage.caps.mdc`
  - [x] 1.2 Note fallback order and `--no-template` opt-out

- [x] 2.0 Enhance PR script to inject template by default (priority: high)

  - [x] 2.1 Detect template path (prefer `.github/pull_request_template.md`; fallback to first in `.github/PULL_REQUEST_TEMPLATE/`)
  - [x] 2.2 Add `--no-template`, `--template <path>`, `--body-append <text>` flags
  - [x] 2.3 Compose body: `TEMPLATE + optional\n\n## Context\n<append>`
  - [x] 2.4 Handle missing file/read errors with clear messages

- [ ] 3.0 Retrofit existing open PRs created via script (priority: medium)

  - [ ] 3.1 Update PR #20 to include template at top
  - [ ] 3.2 Update any other open PRs (if applicable)

- [ ] 4.0 Documentation (priority: low)
  - [ ] 4.1 README: mention template auto-injection behavior and flags
  - [ ] 4.2 Add examples to `.cursor/scripts/` README (if present)

### Notes

- Keep `.github/` config-only; templates remain generic.
- Avoid breaking existing usage; flags are additive.
- If both `--template` and `--no-template` passed, prefer `--no-template`.
