# Guides — Permanent Documentation

**Purpose**: Reusable guides and best practices extracted from completed projects.

**Structure:**

- **Actual files:** `.cursor/docs/guides/` (portable, Cursor-specific namespace)
- **Symlinks:** `docs/guides/` (discoverability) → points to `.cursor/docs/guides/`

**Rationale:** Keeps all Cursor content under `.cursor/` while maintaining easy access via `docs/`.

---

## Chat Performance & Quality

**Canonical Location**: `.cursor/docs/guides/chat-performance/`  
**Symlink**: [chat-performance/](./chat-performance/) → `.cursor/docs/guides/chat-performance/`  
**Source Project**: [chat-performance-and-quality-tools](../projects/chat-performance-and-quality-tools/)

Practical guides for maintaining high-quality, efficient chats:

| Guide                                                                          | Purpose                                                    |
| ------------------------------------------------------------------------------ | ---------------------------------------------------------- |
| [Prompt Tightening Patterns](./chat-performance/prompt-tightening-patterns.md) | Transform vague requests into concrete, actionable prompts |
| [Task Splitting Templates](./chat-performance/task-splitting-templates.md)     | Break large tasks into minimal, verifiable slices          |
| [Summarize-to-Continue Workflow](./chat-performance/summarize-workflow.md)     | Reclaim context capacity when chat becomes heavy           |
| [Incident Playbook](./chat-performance/incident-playbook.md)                   | Quick corrective actions for common failure modes          |
| [Chunking Strategy](./chat-performance/chunking-strategy.md)                   | Split oversized artifacts into manageable chunks           |
| [Quality Rubric](./chat-performance/quality-rubric.md)                         | Manual assessment checklist for response quality           |
| [Prompt Versioning](./chat-performance/prompt-versioning.md)                   | Log and track prompt variants for reproducibility          |

**Full Index:** [chat-performance/README.md](./chat-performance/README.md)

---

## Adding New Guides

When completing a project that produces reusable documentation:

1. **Extract deliverables** to appropriate subdirectory under `docs/guides/`
2. **Update rule references** to point to permanent location (not project location)
3. **Add entry** to this index
4. **Note in project README** that guides have been promoted

**Rationale:** Permanent guides remain accessible after project archival (`docs/projects/_archived/<YYYY>/<slug>/`)

---

## Related

- **Scripts documentation:** [docs/scripts/README.md](../scripts/README.md)
- **Project lifecycle:** `.cursor/rules/project-lifecycle.mdc`
- **Active projects:** [docs/projects/README.md](../projects/README.md)
