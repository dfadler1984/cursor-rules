# Show Session Allowlist

Display active session standing consent grants.

## Purpose

Shows which commands currently have standing consent in the current session, eliminating the need for per-command prompts.

## Output Format

```
Active session allowlist:
- <command-1>
- <command-2>
- <command-3>

To revoke: "Revoke consent for: <command>" or "Revoke all consent"
```

## Usage

Simply invoke `/allowlist` to see the current session state.

**Alternative triggers**:

- "Show active allowlist"
- "List session consent"
- "What has standing consent?"

## Managing Allowlist

**Grant standing consent**:

```
Grant standing consent for: <exact-command>
```

Example:

```
Grant standing consent for: git add -A, git commit -m "...", git push -u origin <branch>
```

**Revoke consent**:

Per-command:

```
Revoke consent for: <exact-command>
```

All at once:

```
Revoke all consent
```

or

```
Clear session allowlist
```

## Session Scope

- Standing consent is **session-scoped** (expires when session ends)
- User can revoke at any time
- Each command must be granted explicitly

## Recommended Defaults

Common commands to consider for standing consent:

**Git (local repo)**:

- `git checkout -b <branch>`
- `git add -A`
- `git commit -m "..."`
- `git push -u origin <branch>`

**Repository scripts**:

- `.cursor/scripts/pr-create.sh ...`
- `.cursor/scripts/pr-update.sh --pr <number> ...`
- `.cursor/scripts/checks-status.sh --pr <number>`

**Note**: Only grant standing consent for commands you use frequently and trust.

## See Also

- [assistant-behavior.mdc](../rules/assistant-behavior.mdc) - Session allowlist policy and grant/revoke syntax
- [security.mdc](../rules/security.mdc) - Command execution security guidelines
