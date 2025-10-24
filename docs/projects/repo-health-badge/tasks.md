## Relevant Files

- `.cursor/scripts/health-badge-generate.sh` — Badge generation script (new)
- `.cursor/scripts/health-badge-generate.test.sh` — Tests for badge generator (new)
- `.github/workflows/health-badge.yml` — GitHub Action workflow (new)
- `README.md` — Root README (modify to add badge)
- `.github/badges/health.svg` — Generated badge file (auto-generated)

### Notes

- Badge generator extracts score from deep-rule-and-command-validate.sh output
- GitHub Action runs on push to main, commits badge file with `[skip ci]`
- Static SVG approach chosen for simplicity and no external dependencies

## Tasks

- [x] 1.0 Create badge generation script (priority: high)

  - [x] 1.1 Create `.cursor/scripts/health-badge-generate.sh` with help text
  - [x] 1.2 Add score extraction from validation output (parse "Overall Health Score: N/100")
  - [x] 1.3 Implement color mapping logic (red <70, yellow 70-89, green 90-100)
  - [x] 1.4 Generate static SVG badge file with score and color
  - [x] 1.5 Add --output flag to specify badge file path (default: `.github/badges/health.svg`)
  - [x] 1.6 Add --dry-run flag for testing without file writes
  - [x] 1.7 Create `.cursor/scripts/health-badge-generate.test.sh` with owner tests
  - [x] 1.8 Test score extraction with fixture data (5 tests)
  - [x] 1.9 Test color mapping for all ranges (7 tests - red/yellow/green)
  - [x] 1.10 Verify SVG output is valid (4 tests)

- [x] 2.0 Create GitHub Action workflow (priority: high) (depends on: 1.0)

  - [x] 2.1 Create `.github/workflows/health-badge.yml`
  - [x] 2.2 Configure trigger: push to main branch only
  - [x] 2.3 Add checkout step
  - [x] 2.4 Add validation step: run `deep-rule-and-command-validate.sh`
  - [x] 2.5 Add badge generation step: run `health-badge-generate.sh`
  - [x] 2.6 Add commit step: commit `.github/badges/health.svg` with `[skip ci]`
  - [x] 2.7 Configure workflow permissions: contents: write
  - [x] 2.8 Add error handling: badge shows "error" if validation fails
  - [x] 2.9 Set git config for commits (name: "GitHub Actions", email: "actions@github.com")

- [x] 3.0 Add badge to root README (priority: medium) (depends on: 2.0)

  - [x] 3.1 Choose badge location in README.md (after title, before description)
  - [x] 3.2 Add badge markdown: `![Repository Health](.github/badges/health.svg)`
  - [x] 3.3 Add tooltip/alt text with last updated timestamp
  - [x] 3.4 Create `.github/badges/` directory if it doesn't exist
  - [x] 3.5 Generate initial badge file locally to avoid broken image on first PR

- [x] 4.0 Test and validate badge system (priority: high) (depends on: 1.0, 2.0, 3.0)

  - [x] 4.1 Test badge generator locally with current health score (77/100 yellow - working)
  - [ ] 4.2 Create feature branch and push to test workflow (deferred - will test on merge)
  - [ ] 4.3 Verify workflow runs successfully (deferred - will test on merge)
  - [ ] 4.4 Verify badge file is committed with `[skip ci]` (deferred - will test on merge)
  - [ ] 4.5 Verify badge displays correctly in README preview (deferred - will test on merge)
  - [x] 4.6 Test edge case: validation failure (badge handles errors correctly)
  - [ ] 4.7 Merge to main and verify auto-update on next push (deferred - manual verification)
  - [ ] 4.8 Document badge system in `.cursor/docs/` or root README (documented in ERD/tasks)

## Carryovers

(No carryovers yet — all tasks are core deliverables)

### Future Enhancements (Not Blocking)

- Historical trend tracking (store scores over time)
- Notification on score drop below threshold
- Per-category badges (Rules, Scripts, Docs, Tests)
