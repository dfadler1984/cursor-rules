# Create Branch

Generate branch name via repository script:

```bash
bash .cursor/scripts/git-branch-name.sh --task <slug> [--type <type>] [--feature <name>] [--apply]
```

## Branch Pattern

`<github-login>/<type>-<feature>-<task>`

**Example**: `dfadler1984/feat-auth-user-login`

## Available Types

`feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

## Options

**--task** (required): Task slug (e.g., `user-login`)

**--type** (optional): Conventional commit type (defaults to `feat`)

**--feature** (optional): Feature area name

**--apply**: Create and switch to the branch immediately

## Examples

```bash
# Suggest branch name only (doesn't create)
bash .cursor/scripts/git-branch-name.sh --task fix-login-bug

# Suggest with type
bash .cursor/scripts/git-branch-name.sh --task optimize-queries --type perf

# Create and switch to branch
bash .cursor/scripts/git-branch-name.sh --task add-auth --type feat --apply

# With feature area
bash .cursor/scripts/git-branch-name.sh --task user-profile --type feat --feature dashboard --apply
```

## See Also

- [assistant-git-usage.mdc](../.cursor/rules/assistant-git-usage.mdc) - Branch naming policy
