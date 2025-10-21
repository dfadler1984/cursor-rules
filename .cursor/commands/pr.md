# Create Pull Request

Create PR via repository script (uses GitHub API, no `gh` CLI required):

```bash
bash .cursor/scripts/pr-create.sh --title "..." [--body "..."]
```

## Authentication

Set GitHub token in environment:

```bash
export GITHUB_TOKEN="ghp_..."
# or
export GH_TOKEN="ghp_..."
```

**Required permissions** (fine-grained token):

- Repository: Metadata (read), Contents (read), Pull requests (write)

## Multi-Line Body

Use ANSI-C quoting for real newlines:

```bash
BODY=$'## Summary\n\nDescription here\n\n## Changes\n\n- Item 1\n- Item 2'
bash .cursor/scripts/pr-create.sh --title "feat: add feature" --body "$BODY"
```

Or use heredoc:

```bash
BODY="$(cat <<'EOF'
## Summary

Description here

## Changes

- Item 1
- Item 2
EOF
)"
bash .cursor/scripts/pr-create.sh --title "feat: add feature" --body "$BODY"
```

## Options

**Custom base branch**:

```bash
--base develop
```

**Custom head branch**:

```bash
--head feature-branch
```

## Examples

```bash
# Simple PR
bash .cursor/scripts/pr-create.sh --title "fix: resolve login bug"

# With body
bash .cursor/scripts/pr-create.sh --title "feat: add authentication" --body "Implements OAuth2 flow"

# Custom branches
bash .cursor/scripts/pr-create.sh --title "feat: new feature" --base develop --head feature-123
```

## See Also

- [assistant-git-usage.mdc](../.cursor/rules/assistant-git-usage.mdc) - PR creation guidance
- [github-api-usage.mdc](../.cursor/rules/github-api-usage.mdc) - API details and troubleshooting
