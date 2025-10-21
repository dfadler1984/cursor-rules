# Repository Status

Check git repository status:

```bash
git status --porcelain=v1
```

## What it Shows

- Modified files (M)
- Added files (A)
- Deleted files (D)
- Untracked files (??)
- Renamed files (R)

## Options

**Standard output**:

```bash
git status
```

**Short format**:

```bash
git status -s
```

**Branch info**:

```bash
git status -sb
```

## Common Next Steps

**Stage changes**:

```bash
git add <file>
```

**Commit changes** (use helper):

```bash
bash .cursor/scripts/git-commit.sh --type <type> --description "..."
```

## See Also

- [assistant-git-usage.mdc](../rules/assistant-git-usage.mdc) - Git workflow
- Type `/commit` for commit helper
