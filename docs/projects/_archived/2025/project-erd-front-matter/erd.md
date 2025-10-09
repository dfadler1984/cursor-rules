---
status: completed
completed: 2025-10-09
owner: rules-maintainers
lastUpdated: 2025-10-09
---

# Engineering Requirements Document — Project ERD Front Matter (Lite)

Mode: Lite

Final summary: [final-summary.md](./final-summary.md)

## Purpose

Standardize minimal ERD front matter across projects for consistency and lifecycle alignment.

## Standard

- Required:
  - `status`: `active` | `completed`
  - `owner`: project owner or team
  - `lastUpdated`: YYYY-MM-DD
- Optional (when closing):
  - `completed`: YYYY-MM-DD (set when `status: completed`)

## Examples

Active:

```yaml
---
status: active
owner: rules-maintainers
lastUpdated: 2025-10-09
---
```

Completed:

```yaml
---
status: completed
completed: 2025-10-09
owner: rules-maintainers
lastUpdated: 2025-10-09
---
```
