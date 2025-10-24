# Risk Tiers for Consent Gating

**Purpose**: Define clear criteria for categorizing operations by risk level to enable consistent, predictable consent behavior.

**Created**: 2025-10-24  
**Status**: Phase 2 deliverable

## Risk Tier Definitions

### Tier 1: Safe (No Consent Required)

**Criteria**:

- Read-only operations with no side effects
- Local operations only (no network, no remote git)
- Non-interactive (won't block or prompt)
- Cannot modify state, data, or history
- Cannot expose sensitive information

**Consent behavior**: Execute without prompt when imperatively requested or via slash command

**Examples**:

**Slash Commands** (highest priority):

- `/commit` → Executes full commit workflow
- `/pr` → Executes full PR creation workflow
- `/branch` → Executes branch name generation/creation
- `/allowlist` → Displays session consent state
- `/status` → Suggested (not mandatory) → `git status --porcelain=v1`
- `/diff` → Suggested (not mandatory) → `git diff --stat`

**Read-only Git**:

- `git status`
- `git status --porcelain=v1`
- `git branch --show-current`
- `git log -1 --oneline`
- `git log --oneline -n 10`
- `git diff --stat`
- `git diff --name-only`
- `git remote -v`
- `git branch -a`

**File System Reads**:

- `read_file` tool
- `list_dir` tool
- `grep` tool
- `codebase_search` tool
- `glob_file_search` tool

**Read-only Scripts**:

- `.cursor/scripts/rules-list.sh` (without flags)
- `.cursor/scripts/rules-validate.sh` (without `--autofix`)
- `.cursor/scripts/tdd-scope-check.sh <file>`
- `.cursor/scripts/project-status.sh <slug>`
- `.cursor/scripts/git-context.sh --format text`
- `.cursor/scripts/context-efficiency-score.sh` (read-only)

### Tier 2: Moderate (One-shot Consent Per Category)

**Criteria**:

- Local modifications (files, git state)
- Reversible operations (can undo/revert)
- No remote effects (no push, no network)
- Non-destructive (doesn't delete history or force-overwrite)
- May create new artifacts but doesn't destroy existing ones

**Consent behavior**: Require consent for first operation in category per turn; subsequent operations in same category don't need re-prompt

**Category definitions**:

- **Local file edits**: write, search_replace, delete_file
- **Local git operations**: add, commit, checkout, branch creation, stash
- **Test/build operations**: test runs, linters, type checkers, builds
- **Local script execution**: non-destructive repo scripts

**Examples**:

**Local File Edits**:

- `write` tool (create/overwrite files)
- `search_replace` tool (modify files)
- `delete_file` tool (remove files)
- `edit_notebook` tool (modify notebooks)

**Local Git Operations**:

- `git add -A` (stage changes)
- `git commit -m "..."` (commit to local branch)
- `git checkout -b <branch>` (create new branch)
- `git checkout <branch>` (switch branches)
- `git stash` (stash changes)
- `git stash pop` (restore stashed changes)
- `git branch -d <branch>` (delete merged local branch)

**Test/Build/Lint**:

- `yarn test` / `npm test`
- `yarn test <path>` (focused test run)
- `yarn lint` / `npm run lint`
- `yarn build` / `npm run build`
- `npx tsc --noEmit` (type check)
- `.cursor/scripts/shellcheck-run.sh`

**Non-destructive Scripts**:

- `.cursor/scripts/git-commit.sh --type ... --description ...`
- `.cursor/scripts/git-branch-name.sh --task ... [--apply]`
- `.cursor/scripts/rules-validate.sh --autofix` (modifies files)
- `.cursor/scripts/test-colocation-migrate.sh`
- `.cursor/scripts/project-lifecycle-validate-scoped.sh <slug>`
- `.cursor/scripts/rules-autofix.sh`

**Session Allowlist** (when granted):
Commands granted standing consent via "Grant standing consent for: <command>" are treated as Tier 2 and execute without re-prompting within the session.

### Tier 3: Risky (Always Require Consent)

**Criteria**:

- Remote operations (push, pull, fetch with potential conflicts)
- Destructive operations (force-push, hard reset, history rewrite)
- Network operations (web search, API calls, external services)
- Security-sensitive operations (secrets access, auth changes)
- Irreversible or difficult-to-reverse operations

**Consent behavior**: Always require explicit consent, even if same category used earlier in turn

**Examples**:

**Remote Git**:

- `git push` (push to remote)
- `git push -u origin <branch>` (push new branch)
- `git push --force` (force push - highest risk)
- `git push --force-with-lease` (safer force push, still risky)
- `git pull` (may cause merge conflicts)
- `git fetch` (less risky but can update remote refs)

**Destructive Git**:

- `git reset --hard` (loses uncommitted changes)
- `git reset --hard HEAD~N` (resets history)
- `git clean -fd` (deletes untracked files)
- `git branch -D <branch>` (force delete unmerged branch)
- `git rebase -i` (interactive rebase - history rewrite)
- `git commit --amend` (modifies history - moderate risk)

**Network Operations**:

- `web_search` tool
- External API calls (GitHub API, Confluence, JIRA, etc.)
- `fetch_mcp_resource` (MCP resources)
- Package installs requiring network (`yarn install` new deps)

**Security-Sensitive**:

- `.git/` directory modifications
- `.env` file creation/modification
- Secrets/token access
- SSH key operations
- Authentication configuration changes

**Scripts with Remote/Network Effects**:

- `.cursor/scripts/pr-create.sh` (creates remote PR via API)
- `.cursor/scripts/pr-update.sh` (modifies remote PR)
- `.cursor/scripts/checks-status.sh --pr <number>` (API call, but read-only - could be Tier 2 with token)
- `.cursor/scripts/changesets-automerge-dispatch.sh` (triggers remote workflow)

## Special Cases and Exceptions

### Slash Commands (Override All Tiers)

**Principle**: Slash command invocation IS the consent. User typing `/commit` is an explicit, intentional instruction.

**Behavior**:

- Check for slash commands BEFORE any tier-based logic
- Execute entire workflow without additional prompts
- Announce in status: "Executing cursor command: `/commit` → `git-commit.sh` workflow"

**Rationale**: Asking "Proceed?" after `/commit` adds unnecessary friction. The command itself is the consent.

### Composite Consent-After-Plan

**Principle**: When previous assistant message proposed concrete code edits and user replies with consent phrase ("proceed", "go ahead", "sounds good", "do it", "ship it"), treat as implementation consent.

**Behavior**:

- Recognize consent phrases within one turn of plan
- Execute proposed edits without re-asking
- If deviating from plan, pause and ask for approval of deviation

**Examples**:

- Assistant: "I'll update parse.ts to handle empty entries. Proceed?"
- User: "sounds good"
- → Execute without additional prompt

### Session Allowlist

**Principle**: User may grant standing consent for specific commands for the current session.

**Behavior**:

- Record exact commands verbatim
- Announce execution but don't re-prompt
- Fall back to normal consent gate for unlisted commands
- Expire at session end or user revocation

**Grant format**: `"Grant standing consent for: <exact-command>"`
**Revoke format**: `"Revoke consent for: <exact-command>"` or `"Revoke all consent"`
**Query format**: `"Show active allowlist"` or `/allowlist`

## Decision Flowchart

```
User Request
    |
    v
Is it a slash command (/commit, /pr, etc.)?
    |
    +-- YES --> Execute immediately (highest priority)
    |
    +-- NO
        |
        v
    Is previous turn a plan + this turn a consent phrase?
        |
        +-- YES --> Execute plan (composite consent)
        |
        +-- NO
            |
            v
        Is operation on session allowlist?
            |
            +-- YES --> Execute and announce
            |
            +-- NO
                |
                v
            Determine operation risk tier:
                |
                +-- Tier 1 (Safe) --> Is it imperative + exact match?
                |       |
                |       +-- YES --> Execute and announce
                |       +-- NO --> Ask consent
                |
                +-- Tier 2 (Moderate) --> First in category this turn?
                |       |
                |       +-- YES --> Ask consent (one-shot)
                |       +-- NO --> Execute
                |
                +-- Tier 3 (Risky) --> Always ask consent
```

## Risk Tier Migration Examples

### Promoting Operations (Less Restrictive)

**Example**: Read-only API calls with valid token

**Before**: Tier 3 (risky - API call)  
**After**: Tier 2 (moderate - read-only, token present, can be in session allowlist)

**Criteria for promotion**:

- Proven safe through usage
- Clear reversibility path
- User feedback: too restrictive
- No security incidents

### Demoting Operations (More Restrictive)

**Example**: `git commit --amend` (modifies history)

**Before**: Tier 2 (moderate - local git)  
**After**: Tier 3 (risky - history modification)

**Criteria for demotion**:

- Security incidents or near-misses
- User feedback: too lax
- Discovered hidden side effects
- Better safe than sorry

## Validation and Testing

### Test Scenarios by Tier

**Tier 1 tests**:

1. "Run `git status`" → Execute without prompt
2. "Show me the file tree" → `list_dir` without prompt
3. "/allowlist" → Display allowlist without prompt

**Tier 2 tests**:

1. "Implement feature X" → Ask consent for first file edit
2. Continue editing → No re-prompt for subsequent edits
3. "Now commit it" → Ask consent (category switch: edit → git)

**Tier 3 tests**:

1. "Push to main" → Always ask consent
2. After consent granted for first push → Still ask for second push (always risky)
3. "Force push" → Always ask consent (extra warning)

### Edge Cases

**Ambiguous phrasing**:

- "Can you commit?" (question or directive?)
- → Ask clarification: "Do you want me to commit now?"

**Multi-step workflow**:

- "Implement, test, and commit feature X"
- → Break into phases: ask consent at each tier boundary (edit → test → commit)

**Category switch mid-turn**:

- Edit file (granted) → then `git add`
- → Ask consent for git category (fresh category switch)

**Retry after failure**:

- Command failed, retry with fix
- → Re-ask consent (failure = new context)

## Related

- See `.cursor/rules/assistant-behavior.mdc` for consent gate implementation
- See `.cursor/rules/intent-routing.mdc` for slash command routing
- See `.cursor/rules/security.mdc` for security-sensitive operation details
- See `consent-gates-refinement/erd.md` for project requirements
