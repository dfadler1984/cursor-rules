---
status: planning
owner: rules-maintainers
created: 2025-10-23
lastUpdated: 2025-10-23
---

# Engineering Requirements Document — Repo Health Badge (Lite)

## 1. Introduction/Overview

Add a repository health badge to the root README that displays the current health score (0-100) from `deep-rule-and-command-validate.sh`. The badge should update automatically on merge to main via GitHub Actions, be visually clear (color-coded by score), and require minimal maintenance.

**Trigger**: Achieved 100/100 health score in repo-health-validation-fixes project; want to maintain visibility and prevent regression.

## 2. Goals/Objectives

- Display current repository health score prominently in root README
- Auto-update badge on every merge to main (no manual updates)
- Color-code badge by score: red (<70), yellow (70-89), green (90-100)
- Minimal dependencies (no external services if possible)
- Track historical trend (optional stretch goal)

## 3. Functional Requirements

1. **Badge Generation Script**

   - Run `deep-rule-and-command-validate.sh --score-only` to get score
   - Generate shields.io badge URL with score and color
   - Output: badge markdown for README

2. **GitHub Action Workflow**

   - Trigger: push to main branch
   - Steps:
     1. Run health validation
     2. Extract score from output
     3. Update badge in root README (option 1: commit badge file) OR
     4. Store score as artifact/gist (option 2: dynamic endpoint)
   - Permissions: write access to repository

3. **Badge Display**

   - Location: Root README.md, near top (after title/description)
   - Format: `![Health Score](badge-url)`
   - Clicking badge links to latest validation run or score details

4. **Score Storage** (choose one approach)
   - **Option A (Static)**: Commit badge SVG file to repo
   - **Option B (Dynamic)**: Post score to GitHub Gist, shields.io reads it
   - **Option C (Status API)**: Use GitHub commit status, badge reflects status

## 4. Acceptance Criteria

- ✅ Badge visible in root README showing current score
- ✅ Badge color matches score range (red/yellow/green)
- ✅ GitHub Action runs on push to main and updates badge
- ✅ Badge reflects correct score within 5 minutes of merge
- ✅ No manual intervention needed for updates
- ✅ Badge remains functional after repository transfer/rename

## 5. Risks/Edge Cases

**Risks**:

- Commits from GH Action may trigger additional CI runs (use `[skip ci]` in commit message)
- Badge may show stale data if action fails silently
- External services (shields.io) may be rate-limited or unavailable

**Mitigations**:

- Use `[skip ci]` flag when committing badge updates
- Action should fail loudly if validation fails
- Prefer static badge file over external dependencies
- Add badge update timestamp to README for staleness detection

**Edge Cases**:

- Validation script returns non-zero exit (badge should show "error")
- Score drops below threshold (trigger notification? just badge color)
- Concurrent pushes to main (last-write-wins acceptable)

## 6. Rollout

**Owner**: rules-maintainers  
**Timeline**: 2-3 hours  
**Approach**: Static badge file (Option A) — simplest, no external dependencies

**Phases**:

1. Create badge generator script (30 min)
2. Create GitHub Action workflow (30 min)
3. Test in feature branch (30 min)
4. Add badge to root README (15 min)
5. Merge and verify auto-update works (15 min)

---

Owner: rules-maintainers  
Created: 2025-10-23
