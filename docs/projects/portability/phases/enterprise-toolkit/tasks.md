## Relevant Files

- `docs/projects/portable-workflow-toolkit/erd.md` — Project requirements (enterprise portability)
- `docs/projects/ai-workflow-integration/portability-analysis.md` — Now reframed for enterprise use
- All `.cursor/rules/*.mdc` — Templates to parameterize
- All `.cursor/scripts/*.sh` — Scripts to make config-driven

### Notes

- **NOT minimal** — full enterprise features with zero hardcoding
- **Config-driven** — all paths, tools, conventions from config file
- **Adapter-based** — pluggable integrations for different tool ecosystems
- **Multi-Fortune-500** — validate in 3 different enterprise environments

## Tasks

- [ ] 1.0 Design configuration system (priority: high)

  - [ ] 1.1 Define config schema (structure, tools, features, templates)
  - [ ] 1.2 Define adapter interfaces (IssueTracker, CI, VCS)
  - [ ] 1.3 Create config loader and validator
  - [ ] 1.4 Build interactive config wizard (detect environment, generate config)

- [ ] 2.0 Parameterize templates (priority: high) (depends on: 1.0)

  - [ ] 2.1 Update ERD templates (full & lite) to use config paths
  - [ ] 2.2 Update Spec/Plan/Tasks templates to use config
  - [ ] 2.3 Create template resolver (reads config, generates paths)
  - [ ] 2.4 Test: same template, different configs → correct structure

- [ ] 3.0 Build adapter system (priority: high) (depends on: 1.0)

  - [ ] 3.1 Implement GitHub Issues adapter (reference implementation)
  - [ ] 3.2 Implement Jira adapter
  - [ ] 3.3 Implement GitHub Actions CI adapter
  - [ ] 3.4 Implement GitLab adapter (VCS + CI)
  - [ ] 3.5 Create generic REST adapter (for custom tools)
  - [ ] 3.6 Test: same workflow, different adapters → same experience

- [ ] 4.0 Refactor validation scripts (priority: high) (depends on: 1.0)

  - [ ] 4.1 Make erd-validate.sh config-aware (check sections based on erdMode)
  - [ ] 4.2 Make project-lifecycle-validate.sh config-aware (paths from config)
  - [ ] 4.3 Make rules-validate.sh config-aware (rulesDir from config)
  - [ ] 4.4 Update all validators to read config, NO hardcoded paths

- [ ] 5.0 Refactor automation scripts (priority: high) (depends on: 1.0, 3.0)

  - [ ] 5.1 Make project-create.sh config-driven (scaffold using config paths)
  - [ ] 5.2 Make project-status.sh config-driven (read from config structure)
  - [ ] 5.3 Make pr-create.sh adapter-based (use VCS adapter)
  - [ ] 5.4 Make git-\*.sh scripts config-aware
  - [ ] 5.5 Update all scripts: read config, use adapters, NO hardcoding

- [ ] 6.0 Build migration tool (priority: medium) (depends on: 2.0, 4.0, 5.0)

  - [ ] 6.1 Create cursor-rules scanner (detect paths, conventions, tools)
  - [ ] 6.2 Build config generator (output .workflow/config.json)
  - [ ] 6.3 Create reference rewriter (replace hardcoded paths with config vars)
  - [ ] 6.4 Add validation (ensure conversion complete, nothing hardcoded)
  - [ ] 6.5 Test: migrate cursor-rules → portable, validate identical behavior

- [ ] 7.0 Fortune 500 validation #1 (priority: high) (depends on: 2.0, 3.0, 4.0, 5.0)

  - [ ] 7.1 Choose target project (different tech stack from cursor-rules)
  - [ ] 7.2 Run config wizard, customize for their environment
  - [ ] 7.3 Execute full workflow (ERD → Tasks → Implement)
  - [ ] 7.4 Measure setup time and friction points
  - [ ] 7.5 Document: what worked, what needed manual intervention

- [ ] 8.0 Fortune 500 validation #2 (priority: high) (depends on: 7.0)

  - [ ] 8.1 Choose target project (different company, different tools)
  - [ ] 8.2 Deploy toolkit with NO code changes
  - [ ] 8.3 Execute full workflow
  - [ ] 8.4 Validate: same experience as validation #1
  - [ ] 8.5 Iterate on adapters/config based on feedback

- [ ] 9.0 Fortune 500 validation #3 (priority: high) (depends on: 8.0)

  - [ ] 9.1 Choose target project (different VCS — e.g., GitLab if others were GitHub)
  - [ ] 9.2 Deploy toolkit with NO code changes
  - [ ] 9.3 Execute full workflow
  - [ ] 9.4 Validate: 3/3 environments with zero code changes
  - [ ] 9.5 Document common patterns and edge cases

- [ ] 10.0 Dogfood: Convert cursor-rules (priority: medium) (depends on: 6.0, 9.0)

  - [ ] 10.1 Run migration tool on cursor-rules itself
  - [ ] 10.2 Generate .workflow/config.json for cursor-rules
  - [ ] 10.3 Validate: cursor-rules works identically via toolkit
  - [ ] 10.4 This proves toolkit IS the source, cursor-rules is just a config

- [ ] 11.0 Documentation (priority: medium) (depends on: 9.0)

  - [ ] 11.1 Write config reference (all schema options documented)
  - [ ] 11.2 Write adapter development guide (how to add new tools)
  - [ ] 11.3 Write multi-project deployment guide
  - [ ] 11.4 Write troubleshooting guide (common enterprise constraints)
  - [ ] 11.5 Document migration path (cursor-rules → portable)

- [ ] 12.0 Publish and package (priority: low) (depends on: 10.0, 11.0)
  - [ ] 12.1 Create standalone toolkit repo
  - [ ] 12.2 Package for distribution (npm/pip/brew if applicable)
  - [ ] 12.3 Write release notes and changelog
  - [ ] 12.4 Announce to user's Fortune 500 teams

## Carryovers (Future Enhancements)

- Additional adapters (Azure DevOps, Bitbucket Pipelines, Jenkins)
- Compliance hooks framework (inject security gates via config)
- Multi-repo/monorepo orchestration (coordinate workflows across 50+ projects)
- AI agent integration (LLM-aware workflow with context management)
- Metrics dashboard (track workflow usage across all deployments)
- Config inheritance (shared company-wide defaults + project overrides)
