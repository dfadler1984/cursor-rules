# Tasks — Project Auto Archive Action

## Relevant Files

- `.cursor/scripts/archive-detect-complete.sh` — Completion detection script
- `.cursor/scripts/archive-detect-complete.test.sh` — Detection tests
- `.cursor/scripts/archive-fix-links.sh` — Link fixing script
- `.cursor/scripts/archive-fix-links.test.sh` — Link fixing tests
- `.github/workflows/project-auto-archive.yml` — GitHub Action workflow
- `.cursor/rules/project-lifecycle.mdc` — Updated with auto-archive integration
- `docs/projects/project-auto-archive-action/erd.md` — Requirements

## Phase 1: Detection & Link Fixing Scripts [P]

**Dependencies**: None  
**Estimated**: 4-6 hours

- [x] 1.0 Create completion detection script (priority: high)

  - [ ] 1.1 Create `.cursor/scripts/archive-detect-complete.sh`

    - Input: `--projects-dir <path>` (default: `docs/projects`)
    - Output: JSON array of completed project slugs
    - Logic: Check all 3 criteria (tasks, carryovers, final-summary)
    - Exit: 0 if any found, 1 if none

  - [ ] 1.2 Implement task completion check

    - Parse `tasks.md` for unchecked `- [ ]` items
    - Ignore items in `## Carryovers` section
    - Count unchecked items in main sections only

  - [ ] 1.3 Implement carryovers check

    - Detect if `## Carryovers` section exists
    - If exists, check for unchecked items within that section
    - Pass if: no section OR section exists but has zero unchecked items

  - [ ] 1.4 Implement final-summary check

    - Check for `final-summary.md` in project directory
    - Pass if file exists (content validation not required)

  - [ ] 1.5 JSON output format
    ```json
    [
      {
        "slug": "project-name",
        "title": "Project Title",
        "tasksComplete": true,
        "carryoversResolved": true,
        "finalSummaryExists": true
      }
    ]
    ```

- [x] 2.0 Create link fixing script (priority: high) [P]

  - [ ] 2.1 Create `.cursor/scripts/archive-fix-links.sh`

    - Flags: `--old-path <path>`, `--new-path <path>`, `--dry-run`
    - Output: List of files modified
    - Exit: 0 on success, 1 on error

  - [ ] 2.2 Find all references to old path

    - Search `.md` files in `docs/` and `.cursor/rules/`
    - Search for relative links: `](docs/projects/<slug>/`
    - Search for absolute links if any
    - Use `grep -r` or `rg` for efficiency

  - [ ] 2.3 Update relative links

    - Replace: `docs/projects/<slug>/` → `docs/projects/_archived/<YYYY>/<slug>/`
    - Handle both `](./path)` and `](docs/projects/path)` formats
    - Preserve anchor links: `#section`

  - [ ] 2.4 Report modified files
    - JSON output with files changed
    - Diff summary for PR description
    - Count of links fixed per file

- [x] 3.0 Add tests for detection script (priority: high) → 1.0

  - [ ] 3.1 Create `.cursor/scripts/archive-detect-complete.test.sh`

  - [ ] 3.2 Test: All criteria met → returns project

    - Fixture: all tasks checked, no carryovers, has final-summary.md
    - Expect: Project in JSON output

  - [ ] 3.3 Test: Missing task checkmarks → skips project

    - Fixture: has `- [ ]` unchecked tasks
    - Expect: Project NOT in output

  - [ ] 3.4 Test: Carryovers with unchecked items → skips

    - Fixture: `## Carryovers` with `- [ ]` items
    - Expect: Project NOT in output

  - [ ] 3.5 Test: Missing final-summary → skips

    - Fixture: no `final-summary.md` file
    - Expect: Project NOT in output

  - [ ] 3.6 Test: Empty carryovers section → allowed
    - Fixture: `## Carryovers` exists but no items
    - Expect: Project in output (passes)

- [x] 4.0 Add tests for link fixing script (priority: high) → 2.0

  - [ ] 4.1 Create `.cursor/scripts/archive-fix-links.test.sh`

  - [ ] 4.2 Test: Fixes relative links

    - Fixture: `[link](docs/projects/test-proj/file.md)`
    - Expect: `[link](docs/projects/_archived/2025/test-proj/file.md)`

  - [ ] 4.3 Test: Handles multiple references

    - Fixture: 3 files referencing old path
    - Expect: All 3 files updated

  - [ ] 4.4 Test: Preserves anchor links

    - Fixture: `[link](docs/projects/test-proj/file.md#section)`
    - Expect: Anchor preserved in new path

  - [ ] 4.5 Test: Dry-run mode

    - Expect: Shows changes without modifying files

  - [ ] 4.6 Test: No references found
    - Fixture: Project with no links to it
    - Expect: Exit 0, report 0 files modified

## Phase 2: GitHub Workflow [S] → 1.0, 2.0

**Dependencies**: Phase 1 complete  
**Estimated**: 3-4 hours

- [x] 5.0 Create GitHub Action workflow (priority: high)

  - [ ] 5.1 Create `.github/workflows/project-auto-archive.yml`

    - Trigger: `push` to `main` branch
    - Runs on: `ubuntu-latest`
    - Permissions: `contents: write`, `pull-requests: write`

  - [ ] 5.2 Step: Detect completed projects

    - Run: `archive-detect-complete.sh --projects-dir docs/projects`
    - Capture: JSON output of completed projects
    - Skip workflow if: output is empty array

  - [ ] 5.3 Step: Archive each project (loop)

    - For each project in JSON:
      - Run: `project-archive.sh --project <slug> --year $(date +%Y)`
      - Check: Exit code (fail workflow on error)
      - Update: ERD `status: completed` in archived location

  - [ ] 5.4 Step: Fix broken links (loop)

    - For each archived project:
      - Run: `archive-fix-links.sh --old-path docs/projects/<slug> --new-path docs/projects/_archived/<YYYY>/<slug>`
      - Collect: Modified files list for PR description

  - [ ] 5.5 Step: Regenerate projects README

    - Run: `generate-projects-readme.sh`
    - Ensure: `docs/projects/README.md` updated

  - [ ] 5.6 Step: Create archive PR

    - Branch: `bot/auto-archive-$(date +%Y%m%d-%H%M%S)`
    - Commit: All changes with conventional commit message
    - PR: Use template from ERD section 3.6
    - Labels: `auto-merge`, `bot`, `project-lifecycle`

  - [ ] 5.7 Step: Enable auto-merge
    - Use: GitHub API to enable auto-merge on created PR
    - Wait for: Required CI checks (as configured in branch protection)
    - Merge: Automatic when checks pass

- [x] 6.0 Handle edge cases in workflow (priority: medium) → 5.0

  - [ ] 6.1 Zero completed projects

    - Log: "No projects ready for archival"
    - Exit: 0 (success, no-op)

  - [ ] 6.2 Multiple projects batch

    - Archive all in single PR
    - List all in PR description

  - [ ] 6.3 Archive directory creation

    - Create `docs/projects/_archived/<YYYY>/` if not exists
    - Use `mkdir -p` for safety

  - [ ] 6.4 Error recovery
    - On any script failure: log error, exit 1
    - Do not create PR if archival incomplete
    - GitHub notifies via failed check

## Phase 3: Assistant Rules Integration [S] → 5.0

**Dependencies**: Phase 2 workflow created  
**Estimated**: 2-3 hours

- [x] 7.0 Update assistant behavior for final-summary prompt (priority: high)

  - [ ] 7.1 Add detection logic to rules

    - Trigger: When user checks last task in `tasks.md`
    - Detect: Count remaining unchecked tasks = 0
    - Check: No unchecked items in Carryovers (if section exists)

  - [ ] 7.2 Add prompt template

    - Message: "All tasks complete. Ready to write final summary for archival?"
    - On "yes": Generate `final-summary.md` using existing script
    - On "no": Explain that project won't auto-archive without it

  - [ ] 7.3 Update `.cursor/rules/project-lifecycle.mdc`
    - Add section: "Auto-Archive Integration"
    - Document: Completion criteria, final-summary prompt, action behavior
    - Link: Reference to project-auto-archive-action ERD

- [x] 8.0 Document automated workflow (priority: medium) → 7.0

  - [ ] 8.1 Update project-auto-archive-action README

    - Usage: How to trigger auto-archive
    - Criteria: What makes a project ready
    - Workflow: What the action does step-by-step
    - Troubleshooting: Common issues and fixes

  - [ ] 8.2 Add workflow diagram
    - Visual: Flowchart of detection → archive → PR → merge
    - Gates: Show where validation happens
    - Outcomes: Success vs skip vs error paths

## Phase 4: Testing & Validation [S] → 7.0, 8.0

**Dependencies**: All scripts and workflow created  
**Estimated**: 2-3 hours

- [ ] 9.0 End-to-end testing (priority: high)

  - [ ] 9.1 Create test project

    - Simple project with minimal tasks
    - Complete all tasks
    - Generate final-summary.md

  - [ ] 9.2 Trigger workflow manually

    - Use `workflow_dispatch` or push to test branch
    - Verify: Detection finds test project
    - Verify: Archival completes successfully

  - [ ] 9.3 Verify PR creation

    - Check: PR created with correct title/body
    - Check: Labels applied (`auto-merge`, `bot`)
    - Check: Auto-merge enabled

  - [ ] 9.4 Verify link fixing

    - Check: Links to test project updated
    - Check: No broken links remain
    - Run: `links-check.sh` on affected files

  - [ ] 9.5 Verify projects README
    - Check: Test project moved to Archived section
    - Check: Status shows "completed"
    - Check: Links point to `_archived/` location

- [ ] 10.0 Validate auto-merge behavior (priority: high) → 9.0

  - [ ] 10.1 Verify CI checks run

    - Ensure: Required checks configured in branch protection
    - Verify: Checks run on bot PR

  - [ ] 10.2 Verify auto-merge completes

    - Wait for: All checks to pass
    - Verify: PR merges automatically
    - Verify: Bot branch cleaned up

  - [ ] 10.3 Test failure scenarios
    - Simulate: Archive script failure
    - Verify: No PR created
    - Verify: Workflow reports error

## Phase 4: Testing & Validation (Manual - Real Usage)

Phase 4 (Tasks 9.0-10.0) will be validated when a real project is completed and the auto-archive workflow runs for the first time.

## Carryovers

- [ ] 9.0 End-to-end testing (deferred to first real usage)
- [ ] 10.0 Validate auto-merge behavior (deferred to first real usage)

**Rationale**: Testing requires a real completed project. Will validate during first auto-archive trigger.

## Completion Notes

**Phases 1-3 Complete:**

**Deliverables:**

- ✅ `.cursor/scripts/archive-detect-complete.sh` — Completion detection (8 tests passing)
- ✅ `.cursor/scripts/archive-fix-links.sh` — Link fixing (6 tests passing)
- ✅ `.github/workflows/project-auto-archive.yml` — Auto-archive workflow
- ✅ `.cursor/rules/project-lifecycle.mdc` — Updated with auto-archive integration

**Features:**

- 3-criteria completion detection (tasks, carryovers, final-summary)
- Automatic link fixing after archival
- Batch processing (multiple projects in one PR)
- Auto-merge integration (like changesets bot)
- Zero-touch operation after final PR merge

**Test Coverage:**

- Detection script: 8/8 tests passing ✅
- Link fixing script: 6/6 tests passing ✅
- Total: 14/14 tests passing ✅

**Next Steps:**

- Phase 4 will be validated during first real project completion
- Monitor first auto-archive run
- Iterate on workflow based on real usage

## Notes

- **Parallelizable**: Tasks 1.0-4.0 can be worked in parallel (all Phase 1)
- **Sequential**: Phase 2 depends on Phase 1 completion
- **Testing strategy**: TDD for scripts (Phase 1), integration tests deferred to real usage (Phase 4)
- **Similar patterns**: Reference `.github/workflows/changesets.yml` for auto-merge implementation
- **Link to scripts**: Use absolute paths in workflow to avoid CWD issues
