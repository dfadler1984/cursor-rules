# Cursor Rules — Shell Scripts Suite

{{HEALTH_BADGE}}

This repository includes a suite of standalone shell scripts to assist with rules management, Git workflows, PR creation, and repo hygiene. Scripts target macOS with bash and prefer POSIX sh where feasible.

## Unified Workflow (No Configuration Required)

This repository uses a **unified workflow** integrating proven practices from ai-dev-tasks, github/spec-kit, and claude-task-master. All features are standardized — no toggles or configuration needed.

### Core Workflow: Specify → Plan → Tasks → Analyze → Implement

1. **Specify**: Create ERD with uncertainty markers and clarifications
2. **Plan**: Generate acceptance bundle with targets, exact changes, success criteria
3. **Tasks**: Two-phase generation (parents → "Go" → sub-tasks) with dependencies/priority
4. **Analyze**: Mandatory cross-check of ERD→plan→tasks coverage before implementation
5. **Implement**: TDD-first with owner specs and effects seams

### Standardized Features

- **Slash Commands** (first-class): `/specify`, `/clarify`, `/plan`, `/tasks`, `/analyze`, `/implement`
  - Phrase triggers remain as fallback
- **Task Metadata**: `dependencies`, `priority`, `[P]` markers included by default
- **Logging**: Operation blocks and Dependency Impact in all improvement logs
- **Artifacts**: Cross-linked ERD, Plan, Tasks with standard templates

### Quick References

- Commands overview: `.cursor/rules/git-slash-commands.mdc`
- Capabilities catalog: `.cursor/rules/capabilities.mdc`
- ERD creation: `.cursor/rules/create-erd.mdc`
- Tasks generation: `.cursor/rules/generate-tasks-from-erd.mdc`
- Spec-driven workflow: `.cursor/rules/spec-driven.mdc`

### Legacy Notes

- Assistant learning logs deprecated; see `docs/projects/assistant-self-improvement/legacy/`

## Setup

### Prerequisites

{{SUPPORTED_ENVIRONMENTS}}

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/dfadler1984/cursor-rules.git
   cd cursor-rules
   ```

2. Install dependencies:

   ```bash
   yarn install
   ```

3. Make scripts executable (if needed):

   ```bash
   chmod +x .cursor/scripts/*.sh
   ```

### Authentication

Some scripts require authentication tokens:

- **GitHub API** (`pr-create.sh`, `pr-update.sh`, `checks-status.sh`):
  - Set `GITHUB_TOKEN` or `GH_TOKEN` environment variable
  - Fine-grained or classic tokens supported
  - Minimum scope: `repo` (classic) or `Contents: Read`, `Pull requests: Write` (fine-grained)
  - For orgs with SSO: approve token for the org

For detailed auth setup, see [`docs/workspace-security.md`](./docs/workspace-security.md)

## Available Rules

{{AVAILABLE_RULES}}

📚 **Full catalog**: See [`.cursor/rules/`](./.cursor/rules/)

## Available Scripts

{{AVAILABLE_SCRIPTS}}

📚 **Complete Inventory**: See [`docs/scripts/README.md`](./docs/scripts/README.md)

## Available Commands

{{AVAILABLE_COMMANDS}}

📚 **Full reference**: See [`.cursor/rules/git-slash-commands.mdc`](./.cursor/rules/git-slash-commands.mdc)

## Active Projects

{{ACTIVE_PROJECTS}}

📚 **All projects**: See [`docs/projects/README.md`](./docs/projects/README.md)

## Priority Projects

{{PRIORITY_PROJECTS}}

## Tests

Run the test suite:

```bash
# All tests
yarn test

# Specific test file
yarn test path/to/test

# Watch mode
yarn test --watch

# Coverage
yarn test --coverage
```

{{TEST_STATS}}

## Documentation

{{DOCS_STRUCTURE}}

## What's New

- **2025-10-26**: Phase 0 complete for root-readme-generator project
- **2025-10-25**: Added root-readme-generator project for automated README generation
- See [`CHANGELOG.md`](./CHANGELOG.md) for full history

## How to mark a project completed

1. Add front matter to the project ERD (`docs/projects/<name>/erd.md`):

   ```yaml
   ---
   status: completed
   completed: YYYY-MM-DD
   owner: <you>
   ---
   ```

2. Ensure the Project Completion Checklist is satisfied (`docs/projects/project-lifecycle/completion-checklist.template.md`).
3. Add a brief final summary using the template (`docs/projects/project-lifecycle/final-summary.template.md`).
4. Update `docs/projects/README.md`: move the project from Active to Completed. If archiving, move the project folder to `docs/projects/_archived/<YYYY>/<name>/` and update the Completed link.

## Changelog & Versioning

This repository uses [Changesets](https://github.com/changesets/changesets) for versioning:

- Add changeset: `npx changeset`
- Version bump: `npx changeset version`
- Publish: Automated via GitHub Actions after PR approval

See [`CHANGELOG.md`](./CHANGELOG.md) for the full version history.

## Workspace Security

This repository follows strict workspace trust policies:

- No folder-open autoruns (no `runOn: "folderOpen"` in tasks)
- Explicit consent for command execution
- Scripts run via explicit user action only

See [`docs/workspace-security.md`](./docs/workspace-security.md) for the full security policy.

## Contributing

Contributions welcome! Please:

1. Follow the spec-driven workflow (Specify → Plan → Tasks)
2. Use TDD approach (Red → Green → Refactor)
3. Add tests for new scripts
4. Run validation before committing:

   ```bash
   # Validate rules
   ./.cursor/scripts/rules-validate.sh

   # Run tests
   yarn test

   # Lint workflows
   ./.cursor/scripts/lint-workflows.sh
   ```

5. Create Conventional Commits:

   ```bash
   ./.cursor/scripts/git-commit.sh --type feat --description "..."
   ```

6. Open PR via script:

   ```bash
   ./.cursor/scripts/pr-create.sh --title "..." --body "..."
   ```

See [`.cursor/rules/assistant-git-usage.mdc`](./.cursor/rules/assistant-git-usage.mdc) for commit and PR guidelines.

---

**Generated**: {{GENERATED_DATE}}  
**Version**: {{VERSION}}
