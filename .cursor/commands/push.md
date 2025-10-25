# Push Changes

Push committed changes to remote repository.

## Basic Usage

```bash
# Push current branch to remote
git push

# Push and set upstream (first push)
git push -u origin <branch-name>
```

## Common Scenarios

### First Push (Set Upstream)

When pushing a new branch for the first time:

```bash
# Automatic upstream tracking
git push -u origin $(git branch --show-current)

# Or specify branch explicitly
git push -u origin feature/my-branch
```

### Subsequent Pushes

After upstream is set:

```bash
# Simple push
git push

# Verify before pushing
git log origin/main..HEAD  # See commits to be pushed
git diff origin/main..HEAD # See changes to be pushed
```

### Force Push (Careful!)

**⚠️ Use with extreme caution - can overwrite history**

```bash
# Force push after rebase (safer)
git push --force-with-lease

# Force push (dangerous, avoid on shared branches)
git push --force
```

**When to use:**

- After rebasing feature branch onto updated main
- After amending commits
- After interactive rebase to clean history

**Never use on:**

- `main` or `master` branches
- Branches others are working on

## Push with Validation

### Pre-Push Checks

Before pushing, verify:

```bash
# Check what will be pushed
git log origin/$(git branch --show-current)..HEAD --oneline

# Check remote status
git remote show origin

# Verify branch naming
git branch --show-current
```

### Repository Scripts

Use repository validation scripts before pushing:

```bash
# Validate branch name
.cursor/scripts/git-branch-name.sh --task <slug> --type <type>

# Run tests
bash .cursor/scripts/tests/run.sh

# Validate rules
.cursor/scripts/rules-validate.sh
```

## Push to Specific Remote

```bash
# Push to named remote
git push <remote-name> <branch-name>

# Example: push to upstream
git push upstream main

# List remotes
git remote -v
```

## Push Tags

```bash
# Push specific tag
git push origin v1.0.0

# Push all tags
git push --tags

# Push with tags
git push --follow-tags
```

## Troubleshooting

### Rejected Push

```bash
# Error: Updates were rejected
# Solution: Pull latest changes first
git pull --rebase origin main
git push
```

### Diverged Branches

```bash
# Local and remote have diverged
# Option 1: Rebase (cleaner history)
git pull --rebase origin $(git branch --show-current)
git push

# Option 2: Merge (preserves history)
git pull origin $(git branch --show-current)
git push
```

### Set Upstream After Push

```bash
# If you forgot -u flag
git branch --set-upstream-to=origin/<branch-name>
```

## Best Practices

1. **Always verify before pushing**

   ```bash
   git status
   git log --oneline -5
   ```

2. **Pull before push** (on shared branches)

   ```bash
   git pull --rebase
   git push
   ```

3. **Use descriptive commit messages**

   ```bash
   # Use the commit helper
   bash .cursor/scripts/git-commit.sh --type feat --description "..."
   ```

4. **Push frequently** (don't let branches diverge too much)

   - Push after completing logical units of work
   - Push before switching context
   - Push at end of day

5. **Never force push to main/master**
   - Repository may have protections enabled
   - Can cause data loss for collaborators

## Workflow Examples

### Feature Branch Workflow

```bash
# 1. Create and push new branch
git checkout -b feature/my-feature
# ... make changes and commit ...
git push -u origin feature/my-feature

# 2. Continue working
# ... more changes and commits ...
git push  # No -u needed after first push

# 3. Before creating PR
git pull --rebase origin main  # Update with latest main
git push --force-with-lease    # Push rebased commits
```

### Hotfix Workflow

```bash
# 1. Create hotfix branch from main
git checkout main
git pull
git checkout -b hotfix/critical-bug
# ... fix and commit ...
git push -u origin hotfix/critical-bug

# 2. Create PR and merge quickly
```

## Integration with Repository Scripts

### Complete Git Workflow

```bash
# 1. Create branch
bash .cursor/scripts/git-branch-name.sh --task fix-bug --type fix --apply

# 2. Make changes and commit
bash .cursor/scripts/git-commit.sh --type fix --description "resolve login issue"

# 3. Push
git push -u origin $(git branch --show-current)

# 4. Create PR
bash .cursor/scripts/pr-create.sh --title "fix: resolve login issue" --body "Details..."
```

## Exit Codes

- `0` - Success
- `1` - Generic error
- `128` - Remote not found
- Non-zero - Push rejected or failed

## See Also

- [branch.md](./branch.md) - Create branches
- [commit.md](./commit.md) - Commit changes
- [pr.md](./pr.md) - Create pull requests
- [assistant-git-usage.mdc](../../rules/assistant-git-usage.mdc) - Full git workflow documentation
