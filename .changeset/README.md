# Changesets — Author Workflow

1. Run `npx changeset` in your branch and follow prompts.
2. Commit the generated file under `.changeset/` with your PR.
3. On merge to `main`, a bot will open/update a "Version Packages" PR.
4. Maintainers review/merge that PR; it updates `CHANGELOG.md` and `VERSION`.
