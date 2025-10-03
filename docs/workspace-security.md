# Workspace Security (Cursor)

This short doc supports `.cursor/rules/workspace-security.mdc`.

## Purpose

Prevent IDE autoruns in Cursor that could execute untrusted code on folder open.

## Risks

- Tasks triggered automatically on folder open
- Elevated credential exposure via developer environment

## Required Practices

- Enable Workspace Trust before opening third‑party repos
- Do not commit `.vscode/tasks.json` with `runOptions.runOn: "folderOpen"` or `runOn: "folderOpen"`
- Audit `.vscode/` before running tasks in unknown repos

## Remediation

- Remove autorun settings from `.vscode/tasks.json`
- Run tasks manually via command palette

## References

- Policy: `.cursor/rules/workspace-security.mdc`
- External reference: [Cursor AI Code Editor Flaw Enables Silent Code Execution via Malicious Repositories — The Hacker News](https://thehackernews.com/2025/09/cursor-ai-code-editor-flaw-enables.html?m=1)
