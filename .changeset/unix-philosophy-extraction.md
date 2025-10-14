---
"cursor-rules": minor
---

feat: Unix Philosophy extraction - 9 focused scripts + enforcement rule

Complete Unix Philosophy compliance infrastructure for shell scripts:

- **9 new focused scripts** (all TDD-tested, D1-D6 compliant):
  - Rules validation: `rules-validate-frontmatter.sh`, `rules-validate-refs.sh`, `rules-validate-staleness.sh`, `rules-validate-format.sh`, `rules-autofix.sh`
  - GitHub automation: `git-context.sh`, `pr-create-simple.sh`, `pr-label.sh`
  - Context efficiency: `context-efficiency-score.sh`

- **Enforcement rule**: `.cursor/rules/shell-unix-philosophy.mdc` prevents future violations

- **ShellCheck integration**: Complete with `.shellcheckrc`, zero errors/warnings across 104 scripts

- **Documentation updates**: Corrected script counts (44 production, 55 tests) and status across all project docs

- **Infrastructure complete**: All validators passing (help, error, network, ShellCheck, tests)

This provides focused, single-responsibility alternatives to monolithic scripts while maintaining backward compatibility. Originals remain functional; orchestration updates are optional future work.

