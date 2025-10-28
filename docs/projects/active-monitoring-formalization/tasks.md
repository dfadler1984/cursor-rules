# Tasks — Active Monitoring Formalization

## Relevant Files

- `docs/projects/active-monitoring-formalization/erd.md` — Requirements (updated with YAML design)
- `docs/projects/ACTIVE-MONITORING.md` — Current system (to be migrated)

## Phase 1: Documentation & Structure (Week 1)

- [ ] 1.0 Document formal monitoring structure and workflows
  - [ ] 1.1 Create monitoring protocol template with YAML schema examples
  - [ ] 1.2 Document review workflow guide (when/how to review, closure criteria)
  - [ ] 1.3 Expand decision tree with additional categories and symptoms

## Phase 2: Core Implementation (Week 1)

- [ ] 2.0 Create monitoring templates with front matter schemas

  - [ ] 2.1 Create log document template (raw observations with review tracking)
  - [ ] 2.2 Create finding document template (analyzed conclusions with source logs)
  - [ ] 2.3 Create review checklist template for periodic validation

- [ ] 2.1 Implement core monitoring scripts with tests

  - [ ] 2.1.1 Create `monitoring-log-create.sh` + test (timestamped logs, auto-increment)
  - [ ] 2.1.2 Create `monitoring-finding-create.sh` + test (findings with front matter)
  - [ ] 2.1.3 Create `monitoring-review.sh` + test (mark reviewed, suggest patterns)

- [ ] 2.2 Update project creation workflow
  - [ ] 2.2.1 Add `--enable-monitoring` flag to `project-create.sh`
  - [ ] 2.2.2 Create `monitoring-setup.sh` + test for post-creation setup

## Phase 2.5: Migration (Week 1.5)

- [ ] 3.0 Migrate existing system to YAML-based structure

  - [ ] 3.1 Create `monitoring-migrate-legacy.sh` + test
  - [ ] 3.2 Create `active-monitoring.yaml` from current ACTIVE-MONITORING.md
  - [ ] 3.3 Create monitoring/ directories for active projects
  - [ ] 3.4 Migrate 35+ existing findings with front matter updates
  - [ ] 3.5 Validate migration (all projects, correct paths, no broken links)

- [ ] 3.1 Implement backward compatibility period
  - [ ] 3.1.1 Add deprecation notice to ACTIVE-MONITORING.md
  - [ ] 3.1.2 Update assistant rules to use active-monitoring.yaml
  - [ ] 3.1.3 Monitor for routing issues during transition

## Phase 3: Integration & Validation (Week 2)

- [ ] 4.0 Implement configuration and validation scripts

  - [ ] 4.1 Create `monitoring-validate-config.sh` + test (YAML schema validation)
  - [ ] 4.2 Create `monitoring-detect-stale.sh` + test (staleness criteria)
  - [ ] 4.3 Create `monitoring-dashboard.sh` + test (unified status view)

- [ ] 4.1 Update lifecycle integration

  - [ ] 4.1.1 Update `project-archive-workflow.sh` for monitoring transitions
  - [ ] 4.1.2 Update `project-lifecycle-validate-scoped.sh` for monitoring validation
  - [ ] 4.1.3 Add monitoring test cases to lifecycle scripts

- [ ] 4.2 System validation and cleanup
  - [ ] 4.2.1 Validate all active monitoring visible in dashboard
  - [ ] 4.2.2 Test archival workflow with monitoring project
  - [ ] 4.2.3 Remove legacy ACTIVE-MONITORING.md after validation
  - [ ] 4.2.4 Archive session documents after Phase 3 completion

## Phase 4: Automation (Future)

- [ ] 5.0 Advanced automation features
  - [ ] 5.1 Auto-detection of scope conflicts (findings in wrong project)
  - [ ] 5.2 Automated stale monitoring alerts
  - [ ] 5.3 CI integration for monitoring structure validation

## Success Criteria

- [ ] **Correct routing**: >95% of logs documented in correct project
- [ ] **Review compliance**: >90% of logs/findings reviewed within 30 days
- [ ] **Tool adoption**: >90% of operations use scripts vs manual creation
- [ ] **Migration success**: 0 broken links after legacy removal
- [ ] **Archival integration**: 100% of projects transition monitoring state properly

## Notes

**Key Design Decisions**:

- YAML configuration for machine-readable automation
- Logs (raw observations) vs Findings (analyzed patterns)
- Front matter review tracking in all documents
- Incremental numbering with timestamps
- Single migration, no backward compatibility

**Migration Impact**:

- 35+ existing findings in rules-enforcement-investigation
- 4 active monitoring projects to migrate
- 7-day compatibility period before legacy removal
