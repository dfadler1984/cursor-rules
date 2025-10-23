---
Mode: Lite
status: completed
owner: rules-maintainers
lastUpdated: 2025-10-23
completedDate: 2025-10-23
---

# Engineering Requirements Document — Collaboration Options (Lite)

Links: `.cursor/rules/github-config-only.mdc` | `docs/projects/collaboration-options/tasks.md` | `docs/projects/split-progress/erd.md`

## 1. Introduction/Overview

Outline collaboration surfaces (PR templates, optional remote sync like Google Docs/Confluence) while keeping the repo as source of truth.

## 2. Goals/Objectives

- Keep `.github/` boundaries configuration-only
- Use optional, opt-in templates for feature-specific PRs
- Defer remote sync by default; local artifacts remain canonical

## 3. Functional Requirements

### PR Templates

- Dedicated PR templates under `.github/PULL_REQUEST_TEMPLATE/` when needed
- Tooling may append per-PR content; generic template stays minimal
- Use opt-in dedicated templates for feature-specific requirements

### Remote Sync (Optional)

- **Default behavior**: Repository artifacts remain canonical (source of truth)
- **Supported providers**: Google Docs, Confluence (explicitly opt-in only)
- **Enablement criteria**:
  - Requires user-provided credentials (API tokens, OAuth)
  - Explicit configuration flag or command
  - Never auto-enabled or assumed
- **Use cases**: Share ERDs/docs with external stakeholders who can't access repo
- **Bi-directional sync**: Changes in remote must be manually pulled back to repo

## 4. Acceptance Criteria

- `.github/` boundaries documented; examples provided
- Guidance for when to use dedicated templates vs docs in `docs/`

## 5. Risks/Edge Cases

- Template sprawl; prefer opt-in templates to avoid clutter

## 6. Rollout Note

- Owner: rules-maintainers
- Comms: Link from README and progress doc

## 7. Testing

- Verify CI/workflows unaffected; confirm templates load when present

## 8. Examples

### Dedicated PR Template Placement

**Structure**:

```
.github/
  PULL_REQUEST_TEMPLATE/
    feature-checkout.md       # Feature-specific template
    security-review.md        # Security-focused template
  pull_request_template.md    # Generic default template
```

**When to use dedicated templates**:

- Feature requires specific checklist items (e.g., security review, DB migrations)
- Feature has unique acceptance criteria not shared with other PRs
- Tooling needs to inject feature-specific content

**When NOT to use dedicated templates**:

- General documentation updates → use generic template
- Standard bug fixes → use generic template
- One-off requirements → better suited for `docs/` with manual reference

**Usage**:

- URL parameter: `https://github.com/org/repo/compare/main...branch?template=feature-checkout.md`
- Script parameter: `pr-create.sh --template feature-checkout`

### Remote Sync Examples

**Google Docs sync** (opt-in):

```bash
# Requires GOOGLE_DOCS_TOKEN environment variable
export GOOGLE_DOCS_TOKEN="..."
sync-to-gdocs.sh --source docs/projects/my-project/erd.md --folder-id ABC123
```

**Confluence sync** (opt-in):

```bash
# Requires CONFLUENCE_TOKEN and CONFLUENCE_SPACE
export CONFLUENCE_TOKEN="..."
export CONFLUENCE_SPACE="MYSPACE"
sync-to-confluence.sh --source docs/projects/my-project/erd.md --page-id 123456
```

**Important**: Always commit back to repo after remote edits; repository remains source of truth.
