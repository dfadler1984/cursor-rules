# `/pr` Command Implementation

**Purpose:** Create pull request when user types `/pr [options]`

**Status:** Implementation specification for assistant behavior

---

## Command Syntax

```
/pr [--title <text>] [--body <text>] [--base <branch>] [--head <branch>] [--draft]
```

**All arguments optional:**

- `--title <text>` - PR title (default: derive from commit messages)
- `--body <text>` - PR body (default: use template)
- `--base <branch>` - Base branch (default: auto-detect, usually "main")
- `--head <branch>` - Head branch (default: current branch)
- `--draft` - Create as draft PR

---

## Detection & Routing

### 1. Detect Command

**Pattern:** Message starts with `/pr` (with or without options)

**Examples:**

```
/pr                                           → Valid (auto-detect everything)
/pr --title "Add feature X"                   → Valid (explicit title)
/pr --title "Fix bug" --body "Description"    → Valid (title + body)
/pr --draft                                   → Valid (draft PR)
```

### 2. Route to Workflow

**Attach rule:** `assistant-git-usage.mdc`

**Trigger:** `/pr` command detected (HIGHEST PRIORITY - bypasses consent gate per assistant-behavior.mdc)

**Note:** `/pr` is a slash command invocation = explicit consent to execute workflow (per intent-routing.mdc line 128)

---

## Execution Flow

### Step 1: Parse Options

**Parse command:**

```typescript
Input: "/pr --title \"Add feature X\" --draft"
→ {
    command: "pr",
    title: "Add feature X",
    body: null,
    base: null,
    head: null,
    draft: true
  }
```

**Quoted argument handling:**

- Strip quotes from title/body values
- Preserve spaces and special characters

### Step 2: Validate Prerequisites

**Check 1: Git repository**

```bash
git rev-parse --git-dir
```

**If not git repo:**

```
Error: Not in a git repository

Navigate to a git repository to create a PR.
```

**Check 2: GitHub token**

```bash
[ -n "$GITHUB_TOKEN" ] || [ -n "$GH_TOKEN" ]
```

**If no token:**

```
Warning: No GitHub token found

The PR script requires GITHUB_TOKEN or GH_TOKEN environment variable for API access.

Options:
1. Set token: export GITHUB_TOKEN=<your-token>
2. Continue anyway (script will print compare URL fallback)

Proceed? (Yes/No)
```

**Check 3: Git status (recommended)**

```bash
git status --porcelain
```

**If uncommitted changes:**

```
Warning: You have uncommitted changes

Uncommitted files:
  M src/file1.ts
  M src/file2.ts

Options:
1. Commit changes first (recommended)
2. Continue anyway (PR will not include these changes)
3. Cancel

Reply with "1", "2", or "3".
```

### Step 3: Build Script Command

**Map flags to script arguments:**

| `/pr` flag | Script flag       | Notes                                                  |
| ---------- | ----------------- | ------------------------------------------------------ |
| `--title`  | `--title`         | Pass through                                           |
| `--body`   | `--body`          | Pass through (use ANSI-C quoting if contains newlines) |
| `--base`   | `--base`          | Pass through                                           |
| `--head`   | `--head`          | Pass through                                           |
| `--draft`  | _(not supported)_ | Future enhancement                                     |

**Build command:**

```bash
bash .cursor/scripts/pr-create.sh \
  [--title "..."] \
  [--body "..."] \
  [--base <branch>] \
  [--head <branch>]
```

**Example transformations:**

```
Input: /pr --title "Add feature X"
Output: bash .cursor/scripts/pr-create.sh --title "Add feature X"

Input: /pr --title "Fix bug" --body "Handles edge cases"
Output: bash .cursor/scripts/pr-create.sh --title "Fix bug" --body "Handles edge cases"

Input: /pr
Output: bash .cursor/scripts/pr-create.sh
(Script auto-detects title from commits, uses template for body)
```

### Step 4: Request Consent

**Consent format:**

```
Slash command: /pr [options]

This will:
  1. Check current branch: <current-branch>
  2. Push to origin (if needed)
  3. Execute: bash .cursor/scripts/pr-create.sh --title "..." [...]
  4. Create PR via GitHub API (or print compare URL)

Detected:
  Base: <base-branch> (or auto-detect)
  Head: <head-branch>
  Title: <title> (or derived from commits)
  Body: <template or provided body>

Proceed?
```

**User responses:**

- "Yes" / "Proceed" / "Go ahead" → Execute
- "No" / "Cancel" → Stop
- Silence → Stop (no retry per consent-first rules)

### Step 5: Execute Script

**Run command:**

```bash
bash .cursor/scripts/pr-create.sh \
  --title "$TITLE" \
  --body "$BODY"
```

**Capture output:**

- PR URL from script stdout
- Error messages from stderr
- Exit code

### Step 6: Parse & Display Result

**Success (PR created):**

Parse PR URL from output:

```
Output: https://github.com/owner/repo/pull/123
```

**Display:**

```
✓ PR created successfully!

PR #123: Add feature X
https://github.com/owner/repo/pull/123

Next steps:
1. Add labels (if needed): bash .cursor/scripts/pr-label.sh --pr 123 --label "enhancement"
2. Request reviews
3. Monitor CI checks: bash .cursor/scripts/checks-status.sh --pr 123

Related:
- See assistant-git-usage.mdc for commit standards
- See project-lifecycle.mdc for completion workflow
```

**Success (compare URL fallback):**

Parse compare URL:

```
Output: https://github.com/owner/repo/compare/main...branch
```

**Display:**

```
ℹ PR not created via API (no GitHub token)

Compare URL: https://github.com/owner/repo/compare/main...branch

Action required:
1. Open the compare URL in your browser
2. Complete PR creation manually
3. (Optional) Set GITHUB_TOKEN for future automation

To set token: export GITHUB_TOKEN=<your-token>
```

**Failure:**

Display script error output:

```
✗ PR creation failed

Error: <error message from script stderr>

Troubleshooting:
- Verify GitHub token is valid: curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
- Check branch exists on remote: git ls-remote origin <branch>
- Ensure you have push access to the repository

See: assistant-git-usage.mdc → PR creation (curl + GitHub API)
```

---

## Error Handling

### Missing GitHub Token (Warning, Not Error)

**Input:** `/pr --title "Add X"` (no token set)

**Response:**

```
Warning: GITHUB_TOKEN not set

The script will fall back to printing a compare URL that you can open in your browser to complete PR creation.

To automate fully, set: export GITHUB_TOKEN=<your-token>

Continue with fallback? (Yes/No)
```

### Script Execution Failure

**Input:** `/pr` (script exits with non-zero)

**Response:**

```
✗ PR creation script failed (exit code: <N>)

Error output:
<stderr from script>

Common issues:
1. Branch not pushed to origin
   Fix: git push -u origin <branch>

2. Invalid base/head branch
   Fix: Verify branches exist: git branch -a

3. GitHub API rate limit
   Fix: Wait or use authenticated token

4. Permission denied
   Fix: Verify repo access and token permissions
```

### Ambiguous Git State

**Input:** `/pr` (detached HEAD, no current branch)

**Response:**

```
Error: Detached HEAD state detected

Cannot create PR from detached HEAD.

Fix:
1. Create/switch to a branch: git checkout -b <branch-name>
2. Or: git checkout <existing-branch>

Then try: /pr again
```

---

## Integration with Other Commands

### After PR Created

**Suggest next actions:**

```
✓ PR created: https://github.com/owner/repo/pull/123

Suggested next steps:
1. Add changeset (if code changes): npx changeset
2. Add labels: bash .cursor/scripts/pr-label.sh --pr 123 --label <name>
3. Request reviews via GitHub UI
4. Monitor checks: bash .cursor/scripts/checks-status.sh --pr 123 [--wait]
```

### Integration with `/commit`

**Future enhancement:**

If user hasn't committed changes:

```
Uncommitted changes detected.

Would you like to:
1. /commit first (recommended): Create conventional commit
2. Continue anyway (PR won't include changes)
3. Cancel

Reply with "1", "2", or "3".
```

### Integration with Project Completion

**Pattern:** PR is final step in project

**Detect:** All tasks complete + final PR

**Suggest:**

```
✓ PR created for project completion

This PR marks project completion.

Next steps:
1. Wait for CI checks to pass
2. Get approval
3. Merge PR
4. Run project completion: bash .cursor/scripts/project-complete.sh <slug>
5. Generate final summary: bash .cursor/scripts/final-summary-generate.sh --project <slug> --year <YYYY>
```

---

## Multi-line PR Bodies

**Challenge:** Newlines in `--body` argument

**Solution:** Use ANSI-C quoting or heredoc

**Example (assistant behavior):**

```bash
# User input:
/pr --title "Add feature X" --body "Summary\n\nDetails..."

# Assistant builds:
BODY=$'Summary\n\nDetails...'
bash .cursor/scripts/pr-create.sh --title "Add feature X" --body "$BODY"
```

**Or with heredoc:**

```bash
BODY="$(cat <<'EOF'
Summary

Details...
EOF
)"
bash .cursor/scripts/pr-create.sh --title "Add feature X" --body "$BODY"
```

**See:** `assistant-git-usage.mdc` → Multi-line PR bodies (required quoting)

---

## Testing Strategy

### Unit Tests (Parse & Build)

```typescript
describe("/pr command", () => {
  it("parses title flag", () => {
    const result = parsePRCommand('/pr --title "Add feature X"');
    expect(result.title).toBe("Add feature X");
  });

  it("builds script command with flags", () => {
    const cmd = buildPRCommand({ title: "Add X", body: "Details" });
    expect(cmd).toBe(
      'bash .cursor/scripts/pr-create.sh --title "Add X" --body "Details"'
    );
  });

  it("handles no flags (auto-detect)", () => {
    const cmd = buildPRCommand({});
    expect(cmd).toBe("bash .cursor/scripts/pr-create.sh");
  });

  it("handles multiline body with ANSI-C quoting", () => {
    const cmd = buildPRCommand({ body: "Line 1\nLine 2" });
    expect(cmd).toContain("$'Line 1\\nLine 2'");
  });
});
```

### Integration Tests (End-to-End)

1. **Create PR (full automation):**

   - Detect `/pr --title "Add feature X"`
   - Validate prerequisites (git repo, token, clean status)
   - Build script command
   - Request consent
   - Execute script
   - Parse PR URL from output
   - Display success with next steps

2. **Create PR (fallback):**

   - No GITHUB_TOKEN set
   - Script prints compare URL
   - Display fallback instructions

3. **Error handling:**
   - Script exits non-zero
   - Parse stderr
   - Display troubleshooting guidance

---

## Implementation Notes

**This is behavioral guidance for the assistant, not code to implement.**

When the assistant sees `/pr [options]`:

1. Parse command options
2. Validate prerequisites (git repo, optional token check, clean status)
3. Build `pr-create.sh` command with mapped flags
4. Request consent with exact command
5. Execute script and capture output
6. Parse PR URL or error messages
7. Display result with next steps

**Consent bypass:**

- Per `intent-routing.mdc` line 128, slash commands bypass normal consent gates
- `/pr` invocation = explicit consent to execute PR creation workflow
- Still show "This will..." message for transparency

**Script details:**

- Location: `.cursor/scripts/pr-create.sh`
- See: `assistant-git-usage.mdc` for usage details
- Deprecation note: Script is complex (282 lines, 14 flags); consider `pr-create-simple.sh` for future

**No repository code needed** - this is assistant behavior specification.

---

**Status:** Draft specification for task 4.0 (Implement `/pr` command)

**Completed:** 2025-10-23

**Next:** Task 5.0 - Error handling and help system
