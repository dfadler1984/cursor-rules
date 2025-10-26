# Decision: Section Ownership & Content Strategy

**Date**: 2025-10-26  
**Decider**: @dfadler1984  
**Status**: Draft (needs review of Priority Projects & Known Issues)

## Proposed README Structure

### 1. Header (Manual + Auto)

**Content**:

- Title + subtitle
- Health badge (AUTO)
- Repository description (Manual)

**Placeholder**: `{{HEALTH_BADGE}}`

**Manual Template Content**:

```markdown
# Cursor Rules — Shell Scripts Suite

{{HEALTH_BADGE}}

This repository includes a suite of standalone shell scripts to assist with
rules management, Git workflows, PR creation, and repo hygiene. Scripts target
macOS with bash and prefer POSIX sh where feasible.
```

---

### 2. Unified Workflow (Manual)

**Content**: Conceptual overview of Specify → Plan → Tasks → Implement workflow

**Rationale**: Rarely changes, high editorial value, core philosophy

**Template**: Keep existing section verbatim in template

---

### 3. Setup & Environment (Manual + Auto)

**Content**:

- Prerequisites (Manual)
- Supported environments (AUTO)
- Installation steps (Manual)
- Configuration (Manual)
- Auth setup (Manual, links to docs)

**Placeholders**: `{{SUPPORTED_ENVIRONMENTS}}`

**Data Source**:

- Node version from `package.json` engines
- Shell compatibility from script shebangs (bash/sh/zsh)
- macOS/Linux from CI matrix

**Format**:

```markdown
## Setup

### Prerequisites

- Node.js 18+ (current: {{NODE_VERSION}})
- Bash 4+ or Zsh 5+
- Git 2.30+

### Supported Environments

{{SUPPORTED_ENVIRONMENTS}}

### Installation

[Manual instructions from template]

### Authentication

[Manual content with links to docs/]
```

---

### 4. Available Rules (Auto)

**Content**: Categorized list of rules from `.cursor/rules/*.mdc`

**Placeholder**: `{{AVAILABLE_RULES}}`

**Data Source**:

- Scan `.cursor/rules/*.mdc`
- Extract `description:` from front matter
- Flag `alwaysApply: true` rules

**Categories**:

- Always Applied (alwaysApply: true)
- Workflow & Process
- Code Quality
- Git & CI
- Testing & TDD
- Documentation
- Security

**Format**:

```markdown
## Available Rules

**Always Applied** (active in all chats):

- `assistant-behavior.mdc` — Consent-first, status updates, minimal prompts
- `tdd-first.mdc` — Three Laws, R/G/R, owner specs
- [...]

**Workflow & Process**:

- `spec-driven.mdc` — Specify → Plan → Tasks with deterministic artifacts
- [...]

📚 **Full catalog**: See [`.cursor/rules/`](./.cursor/rules/)
```

---

### 5. Available Scripts (Auto)

**Content**: Categorized script inventory

**Placeholder**: `{{AVAILABLE_SCRIPTS}}`

**Data Source**:

- Scan `.cursor/scripts/*.sh` (exclude `.lib*.sh`, `*.test.sh`)
- Extract description from `# Description: ...` header
- Extract flags from `# Flags: ...` or `--help` output

**Categories** (derived from filename prefixes):

- **Git Workflows**: `git-*`, `pr-*`, `checks-*`
- **Rules Management**: `rules-*`
- **Project Lifecycle**: `project-*`, `final-summary-*`, `archive-*`
- **Validation**: `validate-*`, `*-validate*`, `shellcheck-*`, `lint-*`
- **CI & Health**: `security-*`, `health-*`, `compliance-*`
- **Utilities**: Everything else

**Format**:

```markdown
## Available Scripts

**📚 Complete Inventory**: See [`docs/scripts/README.md`](./docs/scripts/README.md)

### Git Workflows

- `.cursor/scripts/git-commit.sh` — Compose Conventional Commits
- `.cursor/scripts/pr-create.sh` — Create PRs via GitHub API
- [...]

### Rules Management

- `.cursor/scripts/rules-validate.sh` — Validate front matter, refs, staleness
- [...]

[Other categories...]
```

---

### 6. Available Commands (Auto)

**Content**: Slash commands and intent triggers

**Placeholder**: `{{AVAILABLE_COMMANDS}}`

**Data Source**:

- Extract from `intent-routing.mdc` (slash commands section)
- Extract from `git-slash-commands.mdc`

**Format**:

```markdown
## Available Commands

**Git Operations**:

- `/commit` — Create Conventional Commit
- `/pr` — Create pull request
- `/branch` — Generate branch name
- [...]

**Workflow**:

- `/plan` — Create specification
- `/tasks` — Generate task list
- [...]

**Session Management**:

- `/allowlist` — Show active consent grants

📚 **Full reference**: See [`.cursor/rules/git-slash-commands.mdc`](./.cursor/rules/git-slash-commands.mdc)
```

---

### 7. Active Projects (Auto)

**Content**: Current projects in `docs/projects/`

**Placeholder**: `{{ACTIVE_PROJECTS}}`

**Data Source**:

- Scan `docs/projects/*/erd.md`
- Filter: `status: active` in front matter
- Extract: project name, description (first H1 or description field)
- Count tasks: parse `tasks.md` completion ratio

**Format**:

```markdown
## Active Projects

- **root-readme-generator** — Automate root README generation (0% complete)
- **active-monitoring-formalization** — [description] (25% complete)
- [...]

**Total Active**: {{ACTIVE_COUNT}}

📚 **All projects**: See [`docs/projects/README.md`](./docs/projects/README.md)
```

---

### 8. Priority Projects (Auto) ⚠️ Needs Discussion

**Content**: High-priority pending/blocked projects

**Placeholder**: `{{PRIORITY_PROJECTS}}`

**Questions**:

1. **What defines "priority"?**

   - Front matter field: `priority: high|medium|low`?
   - Special status: `status: priority` or `status: blocked-high-priority`?
   - Tag-based: `tags: [priority]`?
   - Manual curation in template?

2. **What states qualify?**

   - Active projects with `priority: high`?
   - Pending/planned projects marked high-priority?
   - Blocked projects that are high-priority?

3. **How many to show?**
   - All high-priority (could be 0-10+)?
   - Top 3-5 only?

**DECIDED: Approach A** (Front Matter with Blocker Support)

```yaml
# In erd.md front matter:
---
status: active
priority: high # high|medium|low
blocked: true # optional, defaults to false
blocker: "Needs decision on X from maintainer Y"
# or for multiple blockers:
blockers:
  - "Depends on project-foo completion"
  - "Awaiting security review"
---
```

**Rationale**:

- Clean, explicit, filterable
- `blocked` flag clearly indicates blocking state
- `blocker` or `blockers` provides actionable context
- Generator can surface both priority AND blocking state

**Format**:

```markdown
## Priority Projects

**High Priority** ({{HIGH_PRIORITY_COUNT}}):

- **[project-name]** — [description] [25% complete]
- [...]

**Blocked** ({{BLOCKED_COUNT}} need unblocking):

- **[project-name]** (priority: high) — [description]
  - ⚠️ Blocker: [specific blocker reason]
- [...]
```

**Generator Logic**:

- Show all `priority: high` projects (active or blocked)
- Separate section for `blocked: true` projects with blocker details
- Include priority level in blocked section for context

---

### 9. Known Issues (Deferred) 🔮

**DECISION**: Defer to follow-up project (carry over item)

**Rationale**:

- GitHub Issues API integration is ideal long-term solution
- Requires careful design (labels, filtering, rate limits, auth)
- Not blocking for MVP README generator
- Will be captured in tasks as carry over

**Future Approach** (for follow-up project):

- Label strategy: `known-issue`, `limitation`, `wontfix-for-now`
- Generator queries GitHub API with `GITHUB_TOKEN`
- Falls back to manual template section if API unavailable
- Configurable: show top N issues or all with specific labels

**For Now**: Omit section from initial template, add as enhancement later

---

### 10. Tests (Manual + Auto)

**Content**: How to run tests

**Placeholder**: `{{TEST_STATS}}` (optional)

**Format**:

```markdown
## Tests

[Manual instructions from template]

**Coverage**: {{TEST_COVERAGE}}% ({{TEST_FILES}} test files)
```

---

### 11. Documentation (Auto)

**Content**: Links to docs structure

**Placeholder**: `{{DOCS_STRUCTURE}}`

**Data Source**:

- Scan `docs/` directories
- Count files in key sections

**Format**:

```markdown
## Documentation

- **Scripts**: [`docs/scripts/README.md`](./docs/scripts/README.md)
- **Projects**: [`docs/projects/README.md`](./docs/projects/README.md) ({{ACTIVE_COUNT}} active, {{ARCHIVED_COUNT}} archived)
- **Rules**: [`.cursor/rules/`](./.cursor/rules/) ({{RULES_COUNT}} rules)
- **Guides**: [`docs/guides/`](./docs/guides/)
```

---

### 12. What's New (Manual or Semi-Auto)

**Content**: Recent changes/completions

**Option A**: Manual template section (simplest)
**Option B**: Auto from `CHANGELOG.md` top 3 entries
**Option C**: Auto from recent archived projects

**Recommendation**: Start with Manual (Option A), iterate to Option C later

---

### 13. Changelog & Versioning (Manual)

**Content**: Link to CHANGELOG, version strategy

**Template**: Keep existing section

---

### 14. Workspace Security (Manual)

**Content**: Link to security policy

**Template**: Keep existing section

---

### 15. Contributing (Manual)

**Content**: How to contribute

**Template**: Keep existing section

---

## Summary Table

| Section             | Type          | Placeholder                  | Data Source                |
| ------------------- | ------------- | ---------------------------- | -------------------------- |
| Header              | Manual + Auto | `{{HEALTH_BADGE}}`           | CI badge script            |
| Unified Workflow    | Manual        | —                            | Template                   |
| Setup & Environment | Manual + Auto | `{{SUPPORTED_ENVIRONMENTS}}` | package.json, scripts      |
| Available Rules     | Auto          | `{{AVAILABLE_RULES}}`        | `.cursor/rules/*.mdc`      |
| Available Scripts   | Auto          | `{{AVAILABLE_SCRIPTS}}`      | `.cursor/scripts/*.sh`     |
| Available Commands  | Auto          | `{{AVAILABLE_COMMANDS}}`     | `intent-routing.mdc`       |
| Active Projects     | Auto          | `{{ACTIVE_PROJECTS}}`        | `docs/projects/*/erd.md`   |
| Priority Projects   | Auto          | `{{PRIORITY_PROJECTS}}`      | ERD front matter (TBD)     |
| Known Issues        | Auto          | `{{KNOWN_ISSUES}}`           | docs/known-issues.md (TBD) |
| Tests               | Manual + Auto | `{{TEST_STATS}}`             | Test runner output         |
| Documentation       | Auto          | `{{DOCS_STRUCTURE}}`         | `docs/` scan               |
| What's New          | Manual        | —                            | Template                   |
| Changelog           | Manual        | —                            | Template                   |
| Security            | Manual        | —                            | Template                   |
| Contributing        | Manual        | —                            | Template                   |

## Decisions Summary

### ✅ Resolved

1. **Generation Strategy**: Full replacement with template (see `generation-strategy.md`)

2. **Priority Projects**: Front matter approach with blocker support

   - Add `priority: high|medium|low` to ERD front matter
   - Add `blocked: true` + `blocker: "reason"` for blocked projects
   - Generator surfaces both priority and blocking state

3. **Known Issues**: Deferred to follow-up project

   - Not included in MVP
   - Future: GitHub Issues API integration
   - Captured as carry over task

4. **Scripts Section**: Full categorized list
   - Show all scripts organized by category (Git, Rules, Projects, Validation, CI, Utilities)
   - Link to `docs/scripts/README.md` for full details

## Next Steps

1. ✅ Document generation strategy
2. ✅ Document section ownership
3. ✅ Decide Priority Projects approach
4. ✅ Decide Known Issues approach
5. [ ] Update ERD with all decisions
6. [ ] Update tasks.md to mark Phase 0 complete and reflect decisions
7. [ ] Create initial template skeleton
8. [ ] Begin Phase 1 implementation
