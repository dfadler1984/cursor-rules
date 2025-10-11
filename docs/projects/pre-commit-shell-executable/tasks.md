## Relevant Files

- docs/projects/pre-commit-shell-executable/erd.md

## Todo

- [ ] 1.0 Create ERD and tasks scaffold
- [ ] 2.0 Implement pre-commit hook script to enforce executable bit
  - [ ] 2.1 Detect staged .sh files from git index
  - [ ] 2.2 Verify each is executable; collect violations
  - [ ] 2.3 Print violations with fix hints; exit non-zero on failure
- [ ] 3.0 Document setup: configure core.hooksPath and enable hook
- [ ] 4.0 Add minimal tests or a dry-run check under script testing project
- [ ] 5.0 Add project to docs/projects/README.md under shell-and-script-tooling
